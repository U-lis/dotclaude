---
description: Interactive configuration management for dotclaude settings
---

# /dotclaude:configure

Interactive configuration manager for dotclaude plugin settings.

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

## Role

You are the dotclaude Configuration Manager. Your responsibilities:

1. Load existing configuration from global and local config files
2. Present interactive configuration workflow to user
3. Validate all user inputs
4. Save configuration to appropriate file (global or local)
5. Handle working directory migration when path changes
6. Provide clear error messages for invalid inputs

## Configuration Architecture

### Configuration Files

- **Global Config**: `~/.claude/dotclaude-config.json`
  - Applies to all projects
  - Created automatically on first session by init-config.sh hook

- **Local Config**: `<project_root>/.claude/dotclaude-config.json`
  - Applies to current project only
  - Optional, created by user via this command
  - Overrides global settings

### Merge Order

1. Start with default values (hardcoded)
2. Apply global config (if exists)
3. Apply local config (if exists)

Final values = Defaults < Global < Local

### Configuration Schema

```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main",
  "version_files": []
}
```

## Default Values

```bash
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_CHECK_VERSION=true
DEFAULT_AUTO_UPDATE=false
DEFAULT_BASE_BRANCH="main"
DEFAULT_VERSION_FILES="[]"  # empty = auto-detect

GLOBAL_CONFIG_PATH="$HOME/.claude/dotclaude-config.json"
LOCAL_CONFIG_PATH="<git_root>/.claude/dotclaude-config.json"
```

## Workflow

### Step 1: Load Current Configuration

Execute bash script to load merged configuration:

```bash
#!/bin/bash

# Define paths
GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
LOCAL_CONFIG="$GIT_ROOT/.claude/dotclaude-config.json"

# Initialize with defaults
LANGUAGE="en_US"
WORKING_DIR=".dc_workspace"
CHECK_VERSION="true"
AUTO_UPDATE="false"
BASE_BRANCH="main"
VERSION_FILES="[]"

# Load global config (if exists)
if [ -f "$GLOBAL_CONFIG" ]; then
  if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
    LANGUAGE=$(jq -r '.language // "en_US"' "$GLOBAL_CONFIG")
    WORKING_DIR=$(jq -r '.working_directory // ".dc_workspace"' "$GLOBAL_CONFIG")
    CHECK_VERSION=$(jq -r '.check_version // true' "$GLOBAL_CONFIG")
    AUTO_UPDATE=$(jq -r '.auto_update // false' "$GLOBAL_CONFIG")
    BASE_BRANCH=$(jq -r '.base_branch // "main"' "$GLOBAL_CONFIG")
    VERSION_FILES=$(jq -c '.version_files // []' "$GLOBAL_CONFIG")
  else
    echo "Warning: Invalid JSON in global config, using defaults" >&2
  fi
fi

# Load local config (if exists and we're in a git repo)
if [ -n "$GIT_ROOT" ] && [ -f "$LOCAL_CONFIG" ]; then
  if jq empty "$LOCAL_CONFIG" 2>/dev/null; then
    LANGUAGE=$(jq -r '.language // "'"$LANGUAGE"'"' "$LOCAL_CONFIG")
    WORKING_DIR=$(jq -r '.working_directory // "'"$WORKING_DIR"'"' "$LOCAL_CONFIG")
    CHECK_VERSION=$(jq -r '.check_version // '"$CHECK_VERSION"'' "$LOCAL_CONFIG")
    AUTO_UPDATE=$(jq -r '.auto_update // '"$AUTO_UPDATE"'' "$LOCAL_CONFIG")
    BASE_BRANCH=$(jq -r '.base_branch // "'"$BASE_BRANCH"'"' "$LOCAL_CONFIG")
    local_vf=$(jq -c '.version_files // null' "$LOCAL_CONFIG")
    if [ "$local_vf" != "null" ]; then
      VERSION_FILES="$local_vf"
    fi
  else
    echo "Warning: Invalid JSON in local config, using global/defaults" >&2
  fi
fi

# Output current configuration
echo "Current Configuration:"
echo "  language: $LANGUAGE"
echo "  working_directory: $WORKING_DIR"
echo "  check_version: $CHECK_VERSION"
echo "  auto_update: $AUTO_UPDATE"
echo "  base_branch: $BASE_BRANCH"
echo "  version_files: $VERSION_FILES"
```

Store loaded values for display in interactive prompts.

### Step 2: Select Configuration Scope

Use AskUserQuestion to determine where to save configuration:

```yaml
question: "Which configuration scope would you like to edit?"
options:
  - "Global (all projects)"
  - "Local (this project only)"
context: |
  Global configuration applies to all dotclaude usage system-wide.
  Local configuration applies only to this project and overrides global settings.

  Current files:
  - Global: ~/.claude/dotclaude-config.json (always exists)
  - Local: <project_root>/.claude/dotclaude-config.json (optional)
```

Based on response:
- "Global" → `TARGET_CONFIG="$GLOBAL_CONFIG"`
- "Local" → `TARGET_CONFIG="$LOCAL_CONFIG"` (requires git repo)

**Error Handling**:
- If "Local" selected but not in git repo: Show error message and ask again

### Step 3: Interactive Configuration Workflow

For each setting, use AskUserQuestion to get new value. Show current value in context.

#### Setting 1: Language

```yaml
question: "Language code for conversations and documents?"
default_value: <current_language>
context: |
  Current value: <current_language>

  Specify language code (e.g., en_US, fr_FR, ja_JP).
  The SessionStart hook reads this setting and outputs it as session context.
```

**Validation**:
- Accept any non-empty string
- If empty: show error, ask again

#### Setting 2: Working Directory

```yaml
question: "Working directory name (relative path from project root)?"
default_value: <current_working_dir>
context: |
  Current value: <current_working_dir>

  This is where dotclaude stores plans, notepads, and work artifacts.
  Must be a relative path (no leading /, no ..).

  Examples: .dc_workspace, claude_works, workspace/dotclaude
```

**Validation**:
```bash
validate_working_dir() {
  local path="$1"

  # Reject empty
  if [ -z "$path" ]; then
    echo "Error: Working directory cannot be empty"
    return 1
  fi

  # Reject absolute paths
  if [[ "$path" == /* ]]; then
    echo "Error: Working directory must be relative (cannot start with /)"
    return 1
  fi

  # Reject parent traversal
  if [[ "$path" == *".."* ]]; then
    echo "Error: Working directory cannot contain .. (parent traversal)"
    return 1
  fi

  # Reject exactly . or ..
  if [[ "$path" == "." ]] || [[ "$path" == ".." ]]; then
    echo "Error: Working directory cannot be . or .."
    return 1
  fi

  return 0
}
```

**Migration Workflow**:

If working directory value changes from old value:

```bash
OLD_DIR="<previous_working_dir>"
NEW_DIR="<new_working_dir>"
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# Only trigger migration if in git repo and old directory exists with files
if [ -n "$GIT_ROOT" ] && [ -d "$GIT_ROOT/$OLD_DIR" ]; then
  # Check if directory has any files
  if [ -n "$(ls -A "$GIT_ROOT/$OLD_DIR" 2>/dev/null)" ]; then
    # Directory has files, ask user what to do
    echo "Existing working directory '$OLD_DIR' contains files."
  fi
fi
```

Use AskUserQuestion for migration:

```yaml
question: "Existing directory '$OLD_DIR' contains files. What would you like to do?"
options:
  - "Migrate to new location '$NEW_DIR'"
  - "Start fresh (keep old directory)"
context: |
  You are changing the working directory from '$OLD_DIR' to '$NEW_DIR'.
  The old directory contains work files (plans, notepads, etc.).

  - Migrate: Move entire '$OLD_DIR' directory to '$NEW_DIR'
  - Start fresh: Keep old directory as-is, create new empty '$NEW_DIR'
```

Based on response:

```bash
if [ "$response" == "Migrate" ]; then
  # Move directory
  mv "$GIT_ROOT/$OLD_DIR" "$GIT_ROOT/$NEW_DIR"
  echo "Migrated $OLD_DIR -> $NEW_DIR"
else
  # Start fresh - do nothing (new directory will be created on demand)
  echo "Keeping old directory, will use new directory for future work"
fi
```

#### Setting 3: Check Version

```yaml
question: "Check for plugin updates on session start?"
options:
  - "true"
  - "false"
default_value: <current_check_version>
context: |
  Current value: <current_check_version>

  When enabled, dotclaude checks GitHub for updates at session start.
  Shows notification if newer version available.
  No automatic updates unless auto_update is also enabled.
```

#### Setting 4: Auto Update

```yaml
question: "Automatically update plugin when update available?"
options:
  - "true"
  - "false"
default_value: <current_auto_update>
context: |
  Current value: <current_auto_update>

  When enabled, automatically runs 'plugin update dotclaude' when update detected.
  Only applies if check_version is also enabled.

  Warning: Auto-update requires trust in update source and may introduce breaking changes.
```

#### Setting 5: Base Branch

```yaml
question: "Default base branch for git operations?"
default_value: <current_base_branch>
context: |
  Current value: <current_base_branch>

  This is the branch used for:
  - Creating new feature branches
  - Pull request targets
  - Comparing changes

  Common values: main, master, develop
```

**Validation**:
```bash
validate_base_branch() {
  local branch="$1"

  # Reject empty
  if [ -z "$branch" ]; then
    echo "Error: Base branch cannot be empty"
    return 1
  fi

  return 0
}
```

#### Setting 6: Version Files

```yaml
question: "Manage version files for tagging consistency check?"
options:
  - "View current version files"
  - "Add a version file"
  - "Remove a version file"
  - "Reset to auto-detection"
  - "Skip (no changes)"
context: |
  Current value: <current_version_files or "auto-detect (no explicit config)">

  Version files are checked during /dotclaude:tagging to ensure all files
  contain the same version before creating a git tag.

  When no explicit version_files are configured, auto-detection finds
  common version files (CHANGELOG.md, package.json, pyproject.toml, etc.)
  in your project.
```

##### View Sub-action

- If version_files is empty array (`[]`): show "Auto-detection mode (no explicit config)"
  - Then show what auto-detection WOULD find by checking file existence in the project
- If version_files is non-empty: show the configured list with path and pattern

##### Add Sub-action

Prompt for `path` (relative path to version file).

**Path Validation**:
```bash
validate_version_file_path() {
  local path="$1"

  # Reject empty
  if [ -z "$path" ]; then
    echo "Error: Path cannot be empty"
    return 1
  fi

  # Reject absolute paths
  if [[ "$path" == /* ]]; then
    echo "Error: Path must be relative (cannot start with /)"
    return 1
  fi

  # Reject parent traversal
  if [[ "$path" == *".."* ]]; then
    echo "Error: Path cannot contain .. (parent traversal)"
    return 1
  fi

  # Reject exactly . or ..
  if [[ "$path" == "." ]] || [[ "$path" == ".." ]]; then
    echo "Error: Path cannot be . or .."
    return 1
  fi

  return 0
}
```

Prompt for `pattern` (regex with capture group).

**Pattern Validation**:
```bash
validate_version_pattern() {
  local pattern="$1"

  # Reject empty
  if [ -z "$pattern" ]; then
    echo "Error: Pattern cannot be empty"
    return 1
  fi

  # Must contain exactly one capture group (...) excluding non-capturing groups (?:...)
  # Count capturing groups: remove non-capturing (?:...) first, then count remaining (
  local cleaned=$(echo "$pattern" | sed 's/(?://g')
  local count=$(echo "$cleaned" | grep -o '(' | wc -l)

  if [ "$count" -eq 0 ]; then
    echo "Error: Pattern must contain exactly one capture group (...)"
    return 1
  fi

  if [ "$count" -gt 1 ]; then
    echo "Error: Pattern must contain exactly one capture group (found $count)"
    return 1
  fi

  return 0
}
```

**Add workflow**:
1. Validate path and pattern
2. Check for duplicate path (reject if already in list)
3. If adding to an empty list (was auto-detect): warn user that explicit config overrides auto-detection
4. Auto-append CHANGELOG.md entry if not already present after add:
   ```json
   {"path": "CHANGELOG.md", "pattern": "## \\[(\\d+\\.\\d+\\.\\d+)\\]"}
   ```
5. Return to Setting 6 menu after add (allow multiple operations)

##### Remove Sub-action

- Show numbered list of current version_files entries
- If list is empty: show "No explicit version files configured (using auto-detection)"
- Cannot remove CHANGELOG.md entry (show error if attempted)
- If removing the last non-CHANGELOG entry: warn that this reverts to CHANGELOG-only (suggest Reset instead)
- Return to Setting 6 menu after remove

##### Reset Sub-action

- Clear version_files array (set to `[]`)
- Confirm: "Version files reset to auto-detection mode"
- Return to Setting 6 menu

### Step 4: Save Configuration

After all settings collected, save to target config file:

```bash
#!/bin/bash

# Create parent directory if needed
mkdir -p "$(dirname "$TARGET_CONFIG")"

# Build JSON using jq
jq -n \
  --arg lang "$LANGUAGE" \
  --arg wd "$WORKING_DIR" \
  --argjson cv "$CHECK_VERSION" \
  --argjson au "$AUTO_UPDATE" \
  --arg bb "$BASE_BRANCH" \
  --argjson vf "$VERSION_FILES" \
  '{
    language: $lang,
    working_directory: $wd,
    check_version: $cv,
    auto_update: $au,
    base_branch: $bb,
    version_files: $vf
  }' > "$TARGET_CONFIG"

if [ $? -eq 0 ]; then
  echo "Configuration saved to $TARGET_CONFIG"
  echo ""
  echo "New configuration:"
  cat "$TARGET_CONFIG" | jq .
else
  echo "Error: Failed to save configuration to $TARGET_CONFIG"
  echo "Please check file permissions"
  exit 1
fi
```

### Step 5: Confirm Success

Display final configuration to user:

```
Configuration Updated Successfully!

Scope: <Global|Local>
File: <config_file_path>

Settings:
  language: <value>
  working_directory: <value>
  check_version: <value>
  auto_update: <value>
  base_branch: <value>
  version_files: <value or "auto-detect">

Changes take effect immediately (no restart required).
```

## Error Handling

### Invalid JSON in Config Files

```bash
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "Warning: Invalid JSON in $CONFIG_FILE" >&2
  echo "Using default values for this scope" >&2
  # Continue with defaults, don't abort
fi
```

### Permission Denied (Read)

```bash
if [ ! -r "$CONFIG_FILE" ]; then
  echo "Warning: Cannot read $CONFIG_FILE (permission denied)" >&2
  echo "Using default values" >&2
  # Continue with defaults
fi
```

### Permission Denied (Write)

```bash
if [ ! -w "$(dirname "$TARGET_CONFIG")" ]; then
  echo "Error: Cannot write to $(dirname "$TARGET_CONFIG")" >&2
  echo "Please check directory permissions" >&2
  exit 1
fi
```

### Not in Git Repo (Local Config)

```bash
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$GIT_ROOT" ]; then
  echo "Error: Local configuration requires a git repository" >&2
  echo "Please run this command from within a git repository" >&2
  echo "or choose Global configuration scope" >&2
  exit 1
fi
```

### Invalid Path Values

Show specific error message for each validation failure:

```bash
# Absolute path
"Error: Working directory must be relative (cannot start with /)"

# Parent traversal
"Error: Working directory cannot contain .. (parent traversal)"

# Exactly . or ..
"Error: Working directory cannot be . or .."

# Empty value
"Error: <setting_name> cannot be empty"
```

## Implementation Notes

### Boolean Values in JSON

Store as actual JSON booleans (not strings):
- `true` and `false` (no quotes)
- Use `--argjson` flag in jq for boolean args

### Path Normalization

Don't normalize paths (remove trailing slashes, etc.). Store exactly as user provides (after validation).

### Working Directory Creation

Don't create working directory during configuration. It will be created on-demand by skills that need it (e.g., start-new).

### Configuration Reload

Configuration changes take effect immediately. Skills read config files on each invocation, so no reload/restart needed.

### Git Root Detection

Always use `git rev-parse --show-toplevel` to find git root. Never assume current directory is git root.

### SessionStart Hook

The init-config.sh hook ensures global config always exists. This skill can assume `~/.claude/dotclaude-config.json` exists.

## Safety

- Never delete or overwrite config files without confirmation
- Never auto-migrate working directory without user approval
- Always validate paths before saving
- Always handle invalid JSON gracefully
- Never crash on permission errors - show clear message instead

## Future Enhancements (Out of Scope for v0.2.0)

- Configuration schema versioning
- Configuration validation command
- Configuration export/import
- Configuration diff viewer (show global vs local)
- Per-setting reset to default
- Configuration file encryption
- Configuration templates

## Testing Checklist

- [ ] Global config can be edited
- [ ] Local config can be edited (in git repo)
- [ ] Local config rejected when not in git repo
- [ ] All 6 settings can be modified
- [ ] Invalid working directory paths rejected
- [ ] Working directory migration prompts when directory has files
- [ ] Working directory migration works correctly
- [ ] Empty required fields rejected
- [ ] Invalid JSON in config handled gracefully
- [ ] Permission errors handled gracefully
- [ ] version_files can be viewed (auto-detect mode)
- [ ] version_files can be viewed (explicit config)
- [ ] Version file can be added with valid path and pattern
- [ ] Invalid path rejected (absolute, parent traversal)
- [ ] Invalid pattern rejected (no capture group, empty)
- [ ] Duplicate path rejected
- [ ] CHANGELOG.md cannot be removed
- [ ] Reset clears to auto-detection
- [ ] CHANGELOG.md auto-appended when missing from explicit config
- [ ] Configuration saved with correct JSON format
- [ ] Boolean values saved as true/false (not "true"/"false")
- [ ] Changes take effect immediately
