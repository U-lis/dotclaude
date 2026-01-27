# Phase 1: Infrastructure

## Objective

Create the configuration infrastructure consisting of:
1. `/dotclaude:configure` command entry point
2. Configure skill with interactive workflow
3. SessionStart hook for automatic default config creation

---

## Prerequisites

- [ ] Repository is clean with no uncommitted changes
- [ ] Current working directory is dotclaude project root

---

## Scope

### In Scope
- Create `commands/configure.md` command file
- Create `skills/configure/SKILL.md` skill implementation
- Create `hooks/init-config.sh` SessionStart hook
- Modify `hooks/hooks.json` to register new hook
- Implement configuration loading, saving, and merging logic
- Implement working directory migration workflow
- Handle all edge cases (invalid JSON, permissions, path validation)

### Out of Scope
- Updating existing skills to use configuration (Phase 2)
- Documentation updates (Phase 3)
- Multi-language support (language setting stored but not used)
- Configuration schema versioning

---

## Instructions

### Step 1: Create Configure Command Entry Point

**File**: `commands/configure.md`

**Action**: Create new command file that:
- Defines command metadata in YAML frontmatter (name: configure, user-invocable: true)
- Brief description of what the command does
- References the skill file at `skills/configure/SKILL.md`
- Follows same structure as existing commands (e.g., `commands/start-new.md`)

### Step 2: Create Configure Skill Directory

**File**: Directory structure

**Action**: Create directory `skills/configure/` to contain the skill implementation

### Step 3: Create Configure Skill Implementation

**File**: `skills/configure/SKILL.md`

**Action**: Create comprehensive skill implementation with following sections:

#### YAML Frontmatter
- name: configure
- description: Interactive configuration management
- user-invocable: true

#### Role Section
Define the skill's role as configuration manager with responsibilities:
- Load existing configuration (global + local)
- Present interactive configuration workflow
- Validate user inputs
- Save configuration to appropriate file
- Handle working directory migration

#### Configuration Constants Section
Define default values for all settings:
```
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_CHECK_VERSION=true
DEFAULT_AUTO_UPDATE=false
DEFAULT_BASE_BRANCH="main"

GLOBAL_CONFIG_PATH="$HOME/.claude/dotclaude-config.json"
LOCAL_CONFIG_PATH="<git_root>/.claude/dotclaude-config.json"
```

#### Configuration Loading Function
Instructions for bash function that:
1. Initialize config with default values
2. If global config exists, load and merge (global overrides defaults)
3. If local config exists, load and merge (local overrides global)
4. Handle invalid JSON gracefully (log error, use defaults)
5. Return merged configuration as variables

#### Scope Selection Workflow
Use AskUserQuestion tool with:
- question: "Which configuration scope to edit?"
- options:
  - "Global (all projects)" - saves to `~/.claude/dotclaude-config.json`
  - "Local (this project only)" - saves to `<project_root>/.claude/dotclaude-config.json`
- Explain that local settings override global settings

#### Interactive Configuration Workflow
For each of the 5 settings, use AskUserQuestion tool:

1. **language**:
   - question: "Language for conversations and documents?"
   - Show current value
   - Accept any string input
   - Note: Translation not implemented in v0.2.0

2. **working_directory**:
   - question: "Working directory name (relative to project root)?"
   - Show current value
   - Validate: reject absolute paths, reject paths with `..`, reject empty string
   - If value changes and old directory exists with files, trigger migration workflow

3. **check_version**:
   - question: "Check for plugin updates on session start?"
   - options: true/false
   - Show current value

4. **auto_update**:
   - question: "Automatically update plugin when update available?"
   - options: true/false
   - Show current value
   - Note: Only applies when check_version=true

5. **base_branch**:
   - question: "Default base branch for git operations?"
   - Show current value
   - Validate: reject empty string

#### Working Directory Migration Workflow
When `working_directory` changes:
1. Check if old directory exists
2. Check if old directory contains files
3. If files exist:
   - Use AskUserQuestion: "Existing directory '{old_dir}' contains files. What to do?"
   - options:
     - "Migrate to new location '{new_dir}'" - Move entire directory
     - "Start fresh" - Keep old directory, create new empty directory
4. If no files or directory doesn't exist:
   - Silently use new directory name

#### Configuration Saving Function
Instructions for saving configuration:
1. Create parent directory if not exists (`mkdir -p`)
2. Format JSON with proper indentation (use jq)
3. Write to appropriate file based on scope
4. Handle permission errors with clear messages
5. Confirm success to user

#### Error Handling
- Invalid JSON: Log error, use defaults, continue
- Permission denied (read): Log error, use defaults
- Permission denied (write): Show error, abort save
- Invalid path (absolute, parent traversal): Reject with error message
- Empty required fields: Reject with error message

### Step 4: Create Init Config Hook

**File**: `hooks/init-config.sh`

**Action**: Create bash script that:
1. Add shebang: `#!/bin/bash`
2. Define global config path: `GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"`
3. Check if global config exists
4. If not exists:
   - Create `~/.claude/` directory if needed
   - Create default config file with all 5 settings at default values
   - Use proper JSON formatting
5. If exists: do nothing (silent)
6. Make script executable: chmod +x

Script should be idempotent (safe to run multiple times).

### Step 5: Register Init Config Hook

**File**: `hooks/hooks.json`

**Action**: Modify the SessionStart hooks array to include init-config.sh:
- Add new hook object to SessionStart hooks array
- type: "command"
- command: "${CLAUDE_PLUGIN_ROOT}/hooks/init-config.sh"
- No timeout needed (fast operation)
- Position: Add BEFORE check-update.sh (config must exist before update check)

Maintain existing JSON structure and formatting.

---

## Implementation Notes

### Configuration Loading Pattern
All skills will use this pattern in Phase 2:
```bash
# Load configuration
GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"
LOCAL_CONFIG="$(git rev-parse --show-toplevel 2>/dev/null)/.claude/dotclaude-config.json"

# Defaults
WORKING_DIR=".dc_workspace"
BASE_BRANCH="main"

# Load global
if [ -f "$GLOBAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // ".dc_workspace"' "$GLOBAL_CONFIG")
  BASE_BRANCH=$(jq -r '.base_branch // "main"' "$GLOBAL_CONFIG")
fi

# Load local (overrides global)
if [ -f "$LOCAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // "'"$WORKING_DIR"'"' "$LOCAL_CONFIG")
  BASE_BRANCH=$(jq -r '.base_branch // "'"$BASE_BRANCH"'"' "$LOCAL_CONFIG")
fi
```

### Path Validation
Reject these patterns for working_directory:
- Starts with `/` (absolute path)
- Contains `..` (parent traversal)
- Empty string
- `.` or `..` exactly

Accept examples: `.dc_workspace`, `claude_works`, `docs/workspace`

### JSON Formatting
Use jq for consistent formatting:
```bash
jq -n --arg lang "$LANGUAGE" \
      --arg wd "$WORKING_DIR" \
      --argjson cv "$CHECK_VERSION" \
      --argjson au "$AUTO_UPDATE" \
      --arg bb "$BASE_BRANCH" \
      '{
        language: $lang,
        working_directory: $wd,
        check_version: $cv,
        auto_update: $au,
        base_branch: $bb
      }' > "$CONFIG_FILE"
```

---

## Sample Code

### init-config.sh Hook Example
```bash
#!/bin/bash
# Initialize default global configuration if not exists

GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"

if [ ! -f "$GLOBAL_CONFIG" ]; then
  mkdir -p "$(dirname "$GLOBAL_CONFIG")"

  cat > "$GLOBAL_CONFIG" <<EOF
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
EOF
fi
```

---

## Completion Checklist

- [ ] `commands/configure.md` created with proper structure
- [ ] `skills/configure/` directory created
- [ ] `skills/configure/SKILL.md` created with complete implementation
- [ ] Skill includes all 5 configurable settings
- [ ] Skill implements scope selection (global/local)
- [ ] Skill implements interactive configuration workflow
- [ ] Skill implements working directory migration workflow
- [ ] Skill includes comprehensive error handling
- [ ] `hooks/init-config.sh` created and executable
- [ ] `hooks/hooks.json` modified to include init-config.sh
- [ ] Hook positioned before check-update.sh in SessionStart array
- [ ] All bash code follows existing conventions
- [ ] All AskUserQuestion calls use proper structure

---

## Verification

### Manual Verification
```bash
# Verify files created
ls -l commands/configure.md
ls -l skills/configure/SKILL.md
ls -l hooks/init-config.sh

# Verify hook is executable
test -x hooks/init-config.sh && echo "Executable" || echo "Not executable"

# Verify JSON is valid
jq empty hooks/hooks.json && echo "Valid JSON" || echo "Invalid JSON"

# Test hook manually
./hooks/init-config.sh
cat ~/.claude/dotclaude-config.json

# Test configure command (after plugin reload)
# Run: /dotclaude:configure
```

### Expected Output
- Command file exists and follows standard format
- Skill file exists with complete workflow
- Hook creates default config in ~/.claude/dotclaude-config.json
- hooks.json is valid JSON with init-config.sh registered

---

## Notes

- The configure skill should NOT modify version-related files (plugin.json, marketplace.json) as per CLAUDE.md guidelines
- Configuration changes take effect immediately (no restart required)
- Invalid JSON in config files should never crash skills - always fall back to defaults
- Working directory migration should be conservative: always prompt user, never auto-migrate
- Phase 1 creates infrastructure only; existing skills continue using hard-coded paths until Phase 2

---

## Completion Date

{To be filled by code-validator}

## Completed By

{To be filled by code-validator}
