# Remove check_version and auto_update Settings - Design Document

## Overview

Remove the non-functional `check_version` and `auto_update` configuration settings from the dotclaude plugin. These settings are exposed in the local scope of `/dotclaude:configure` but serve no purpose: `check-update.sh` does not read the `check_version` config value, and `auto_update` has no implementation logic. Claude Code provides built-in marketplace-level auto-update, making these settings redundant. This is a single-phase cleanup affecting 6 files.

**Source Issue**: https://github.com/U-lis/dotclaude/issues/54
**Target Version**: 0.4.0
**Complexity**: SIMPLE (single phase)

## Architecture Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| AD-1 | Single-phase execution | All 6 files are independent edits with no build step, no tests to run, and no generated code. One phase is sufficient. |
| AD-2 | Delete `hooks/check-update.sh` entirely | Dead code. The script checks GitHub for newer tags on SessionStart but does not read the `check_version` config value. Claude Code handles updates natively via its marketplace mechanism. |
| AD-3 | No config migration needed | Existing configs with stale `check_version`/`auto_update` keys do not cause errors. `jq` with `// default` fallback gracefully ignores unknown keys. On next save via `/dotclaude:configure`, only 4 active keys are written. |
| AD-4 | Renumber settings 5,6 to 3,4 | Maintains a contiguous sequence: 1=Language, 2=Working Directory, 3=Base Branch, 4=Version Files. |
| AD-5 | Update all cross-references to "Setting 6" | CLAUDE.md (root) has 2 occurrences and README.md has 1 occurrence of "Setting 6" that must become "Setting 4". |

## Files to Change

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `commands/configure.md` | Modify | Remove check_version/auto_update from schema, defaults, loading, settings 3 and 4, saving, confirmation. Renumber 5->3, 6->4. |
| 2 | `hooks/init-config.sh` | Modify | Remove `check_version` and `auto_update` from default config heredoc. |
| 3 | `hooks/check-update.sh` | Delete | Remove entire file (dead code). |
| 4 | `hooks/hooks.json` | Modify | Remove `check-update.sh` hook entry from SessionStart array. |
| 5 | `README.md` | Modify | Remove `check_version` and `auto_update` rows from Available Settings table. Update "Setting 6" reference to "Setting 4". |
| 6 | `CLAUDE.md` (root) | Modify | Change "Setting 6" to "Setting 4" (2 occurrences). |

## Detailed Instructions

### File 1: `commands/configure.md`

This file requires the most changes. All modifications are deletions or renaming within the existing structure.

#### 1a. Configuration Schema (lines 50-59)

Remove the two settings from the JSON block in the Configuration Schema section.

Current:
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

Change to:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "base_branch": "main",
  "version_files": []
}
```

#### 1b. Default Values (lines 63-69)

Remove `DEFAULT_CHECK_VERSION` and `DEFAULT_AUTO_UPDATE` from the bash defaults block.

Current:
```bash
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_CHECK_VERSION=true
DEFAULT_AUTO_UPDATE=false
DEFAULT_BASE_BRANCH="main"
DEFAULT_VERSION_FILES="[]"  # empty = auto-detect
```

Change to:
```bash
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_BASE_BRANCH="main"
DEFAULT_VERSION_FILES="[]"  # empty = auto-detect
```

#### 1c. Step 1 Variable Initialization (lines 90-95)

Remove `CHECK_VERSION` and `AUTO_UPDATE` from the "Initialize with defaults" block.

Current:
```bash
# Initialize with defaults
LANGUAGE="en_US"
WORKING_DIR=".dc_workspace"
CHECK_VERSION="true"
AUTO_UPDATE="false"
BASE_BRANCH="main"
VERSION_FILES="[]"
```

Change to:
```bash
# Initialize with defaults
LANGUAGE="en_US"
WORKING_DIR=".dc_workspace"
BASE_BRANCH="main"
VERSION_FILES="[]"
```

#### 1d. Global Config Loading (lines 98-108)

Remove the two `jq` extraction lines for `CHECK_VERSION` and `AUTO_UPDATE` from the global config loading block.

Remove these two lines:
```bash
    CHECK_VERSION=$(jq -r '.check_version // true' "$GLOBAL_CONFIG")
    AUTO_UPDATE=$(jq -r '.auto_update // false' "$GLOBAL_CONFIG")
```

#### 1e. Local Config Loading (lines 112-126)

Remove the two `jq` extraction lines for `CHECK_VERSION` and `AUTO_UPDATE` from the local config loading block.

Remove these two lines:
```bash
    CHECK_VERSION=$(jq -r '.check_version // '"$CHECK_VERSION"'' "$LOCAL_CONFIG")
    AUTO_UPDATE=$(jq -r '.auto_update // '"$AUTO_UPDATE"'' "$LOCAL_CONFIG")
```

#### 1f. Config Output (lines 128-135)

Remove the two echo lines for `check_version` and `auto_update` from the "Output current configuration" block.

Remove these two lines:
```bash
echo "  check_version: $CHECK_VERSION"
echo "  auto_update: $AUTO_UPDATE"
```

#### 1g. Setting 3 and Setting 4 (lines 279-310)

Delete the entire "Setting 3: Check Version" section (lines 279-293) and the entire "Setting 4: Auto Update" section (lines 295-310).

#### 1h. Renumber Setting 5 to Setting 3 (line 312)

Change the heading `#### Setting 5: Base Branch` to `#### Setting 3: Base Branch`.

#### 1i. Renumber Setting 6 to Setting 4 (line 343)

Change the heading `#### Setting 6: Version Files` to `#### Setting 4: Version Files`.

#### 1j. Step 4 Save Script (lines 474-488)

Remove `--argjson cv` and `--argjson au` arguments and their corresponding JSON fields from the jq save command.

Current:
```bash
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
```

Change to:
```bash
jq -n \
  --arg lang "$LANGUAGE" \
  --arg wd "$WORKING_DIR" \
  --arg bb "$BASE_BRANCH" \
  --argjson vf "$VERSION_FILES" \
  '{
    language: $lang,
    working_directory: $wd,
    base_branch: $bb,
    version_files: $vf
  }' > "$TARGET_CONFIG"
```

#### 1k. Step 5 Confirmation Output (lines 506-521)

Remove the two lines for `check_version` and `auto_update` from the confirmation display block.

Current:
```
Settings:
  language: <value>
  working_directory: <value>
  check_version: <value>
  auto_update: <value>
  base_branch: <value>
  version_files: <value or "auto-detect">
```

Change to:
```
Settings:
  language: <value>
  working_directory: <value>
  base_branch: <value>
  version_files: <value or "auto-detect">
```

#### 1l. Testing Checklist (line 636)

Change `All 6 settings can be modified` to `All 4 settings can be modified`.

### File 2: `hooks/init-config.sh`

Remove the two config keys from the heredoc that creates the default global config (lines 16-17).

Current heredoc content:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
```

Change to:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "base_branch": "main"
}
```

### File 3: `hooks/check-update.sh`

Delete this file entirely. It is dead code: it checks GitHub for newer tags but does not read the `check_version` config value, and Claude Code has a built-in marketplace auto-update mechanism.

### File 4: `hooks/hooks.json`

Remove the `check-update.sh` hook entry from the SessionStart hooks array (lines 11-15).

Current:
```json
{
  "description": "dotclaude hooks - update check and validation enforcement",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/init-config.sh"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-update.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

Change to:
```json
{
  "description": "dotclaude hooks - validation enforcement",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/init-config.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

Note: Also update the description field to remove "update check and" since that functionality is being removed.

### File 5: `README.md`

#### 5a. Available Settings Table (lines 129-130)

Remove the two rows for `check_version` and `auto_update` from the Available Settings table.

Remove these two rows:
```
| `check_version` | boolean | `true` | Check for plugin updates on session start |
| `auto_update` | boolean | `false` | Auto-update when update available |
```

#### 5b. Version Files Section Reference (line 136)

Change `(Setting 6)` to `(Setting 4)` in the Version Files description paragraph.

Current:
```
Use `/dotclaude:configure` (Setting 6) to manage version files interactively.
```

Change to:
```
Use `/dotclaude:configure` (Setting 4) to manage version files interactively.
```

### File 6: `CLAUDE.md` (root)

Change "Setting 6" to "Setting 4" in both occurrences.

#### 6a. Line 58

Current:
```
Configure version files via `/dotclaude:configure` (Setting 6)
```

Change to:
```
Configure version files via `/dotclaude:configure` (Setting 4)
```

#### 6b. Line 84

Current:
```
See `/dotclaude:configure` Setting 6 to view which files are checked.
```

Change to:
```
See `/dotclaude:configure` Setting 4 to view which files are checked.
```

## Completion Checklist

### File 1: `commands/configure.md`
- [ ] Remove `"check_version": true,` and `"auto_update": false,` from Configuration Schema JSON block
- [ ] Remove `DEFAULT_CHECK_VERSION` and `DEFAULT_AUTO_UPDATE` from Default Values section
- [ ] Remove `CHECK_VERSION` and `AUTO_UPDATE` variables from Step 1 initialization
- [ ] Remove `CHECK_VERSION`/`AUTO_UPDATE` jq lines from global config loading
- [ ] Remove `CHECK_VERSION`/`AUTO_UPDATE` jq lines from local config loading
- [ ] Remove `check_version`/`auto_update` echo lines from config output
- [ ] Remove entire "Setting 3: Check Version" section
- [ ] Remove entire "Setting 4: Auto Update" section
- [ ] Rename "Setting 5: Base Branch" to "Setting 3: Base Branch"
- [ ] Rename "Setting 6: Version Files" to "Setting 4: Version Files"
- [ ] Remove `--argjson cv` and `--argjson au` from jq save command
- [ ] Remove `check_version: $cv,` and `auto_update: $au,` from JSON template in save
- [ ] Remove `check_version`/`auto_update` from confirmation output
- [ ] Update testing checklist "6 settings" to "4 settings"

### File 2: `hooks/init-config.sh`
- [ ] Remove `"check_version": true,` and `"auto_update": false,` from heredoc

### File 3: `hooks/check-update.sh`
- [ ] Delete entire file

### File 4: `hooks/hooks.json`
- [ ] Remove `check-update.sh` hook entry from SessionStart hooks array
- [ ] Update description field to remove "update check and"
- [ ] Verify valid JSON structure after edit

### File 5: `README.md`
- [ ] Remove `check_version` row from Available Settings table
- [ ] Remove `auto_update` row from Available Settings table
- [ ] Change "Setting 6" to "Setting 4" in Version Files paragraph

### File 6: `CLAUDE.md` (root)
- [ ] Change "Setting 6" to "Setting 4" on line 58
- [ ] Change "Setting 6" to "Setting 4" on line 84

## Test Plan

| # | Verification | Command / Method | Expected Result |
|---|--------------|------------------|-----------------|
| 1 | JSON validity of hooks.json | `jq empty hooks/hooks.json` | Exit code 0, no output |
| 2 | Shell syntax of init-config.sh | `bash -n hooks/init-config.sh` | Exit code 0, no output |
| 3 | File deletion confirmed | `test ! -f hooks/check-update.sh` | Exit code 0 (file does not exist) |
| 4 | Setting count in configure.md | Grep for `#### Setting` headings | Exactly 4 matches: Setting 1, 2, 3, 4 |
| 5 | No stale "Setting 5" references | `grep -r "Setting 5" commands/ CLAUDE.md README.md` | No matches |
| 6 | No stale "Setting 6" references | `grep -r "Setting 6" commands/ CLAUDE.md README.md` | No matches |
| 7 | No stale `check_version` references | `grep -r "check_version" commands/ hooks/ README.md CLAUDE.md` | No matches |
| 8 | No stale `auto_update` references | `grep -r "auto_update" commands/ hooks/ README.md CLAUDE.md` | No matches |
| 9 | No stale `CHECK_VERSION` references | `grep -r "CHECK_VERSION" commands/` | No matches |
| 10 | No stale `AUTO_UPDATE` references | `grep -r "AUTO_UPDATE" commands/` | No matches |
| 11 | Backward compatibility | Existing config with stale keys loads without error | Stale keys are silently ignored by jq `// default` pattern |

## Notes

- The `check-update.sh` script (30 lines) performs a `git ls-remote` to GitHub on every SessionStart. Removing it eliminates a network request with a 3-second timeout that runs on every session, improving startup performance.
- No changes are needed to `hooks/check-validation-complete.sh` (the Stop hook) as it is unrelated to update checking.
- The `version_files` setting in the configure command internally uses "Setting 6" labels in YAML question blocks and context strings. After renumbering, verify all internal references within `commands/configure.md` are consistent (the Setting headings are the authoritative labels; the YAML blocks reference them by section, not by number).
