<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-config-global-settings
-->

# Remove check_version and auto_update Settings - Specification

## Overview

The `check_version` and `auto_update` configuration settings are exposed in the local scope of `/dotclaude:configure`, but they only have meaning as global settings. Furthermore, investigation reveals that these settings are entirely non-functional: `check-update.sh` does not read the `check_version` config value, and `auto_update` has no implementation logic. Claude Code has a built-in marketplace-level auto-update toggle, making these settings redundant. This bug fix removes both settings and the associated dead code entirely.

**Source Issue**: https://github.com/U-lis/dotclaude/issues/54
**Target Version**: 0.4.0
**Severity**: Minor

## Functional Requirements

- [x] FR-1: Remove `check_version` and `auto_update` settings from `commands/configure.md`
  - Remove from Configuration Schema (reduce from 6 settings to 4)
  - Remove from Default Values section (`DEFAULT_CHECK_VERSION`, `DEFAULT_AUTO_UPDATE`)
  - Remove `CHECK_VERSION` and `AUTO_UPDATE` variables from Step 1 config loading script
  - Remove Setting 3 (Check Version) and Setting 4 (Auto Update) from Step 3
  - Renumber remaining settings: Setting 5 (Base Branch) becomes Setting 3, Setting 6 (Version Files) becomes Setting 4
  - Remove `check_version` and `auto_update` from Step 4 save script (`--argjson cv`, `--argjson au` and corresponding JSON fields)
  - Remove `check_version` and `auto_update` from Step 5 confirmation output
  - Update Testing Checklist to reflect 4 settings instead of 6

- [x] FR-2: Delete `hooks/check-update.sh` file entirely
  - This script checks GitHub for newer tags on SessionStart but does not read the `check_version` config value
  - Claude Code has a built-in marketplace auto-update mechanism that replaces this functionality

- [x] FR-3: Remove `check-update.sh` hook registration from `hooks/hooks.json`
  - Remove the second hook entry from the `SessionStart` hooks array (the one referencing `check-update.sh` with timeout: 5)
  - Keep `init-config.sh` hook entry intact

- [x] FR-4: Remove `check_version` and `auto_update` from `hooks/init-config.sh` default config
  - Remove `"check_version": true,` and `"auto_update": false,` lines from the heredoc that creates the default global config JSON
  - Keep `language`, `working_directory`, and `base_branch` fields

- [x] FR-5: Remove `check_version` and `auto_update` rows from `README.md` Available Settings table
  - Remove the two rows for `check_version` (boolean, `true`, "Check for plugin updates on session start") and `auto_update` (boolean, `false`, "Auto-update when update available")
  - Keep all other setting rows

- [x] FR-6: Backward compatibility with existing config files
  - If a user's existing config file contains `check_version` or `auto_update` keys, the application must not produce errors
  - These keys are simply ignored during config loading (not explicitly read into variables)
  - No migration script is needed; stale keys in JSON are harmless

## Non-Functional Requirements

- [x] NFR-1: Backward Compatibility - Existing config files containing `check_version` and `auto_update` keys must continue to load without errors. The keys are silently ignored.
- [x] NFR-2: Setting Number Consistency - After removing Settings 3 and 4, the remaining settings must be renumbered (1: Language, 2: Working Directory, 3: Base Branch, 4: Version Files) and all cross-references must be updated (e.g., CLAUDE.md root mentions "Setting 6" for version files).
- [x] NFR-3: No Session Startup Regression - Removing `check-update.sh` from `hooks.json` must not affect the remaining `init-config.sh` hook or the `Stop` hook (`check-validation-complete.sh`).

## Constraints

- The fix must not introduce any new configuration settings.
- The fix must not modify the plugin update mechanism of Claude Code itself.
- The fix must not change the behavior of `init-config.sh` beyond removing the two config keys from the default JSON.
- `CLAUDE.md` at project root mentions "Setting 6" for version files configuration; this reference must be updated to "Setting 4".

## Affected Code Locations

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `commands/configure.md` | Modify | Remove check_version/auto_update from schema, defaults, loading, settings, saving, and confirmation output. Renumber Settings 5,6 to 3,4. |
| 2 | `hooks/init-config.sh` | Modify | Remove check_version and auto_update from default config JSON heredoc (lines 17-18). |
| 3 | `hooks/check-update.sh` | Delete | Remove entire file (dead code, duplicates Claude Code built-in functionality). |
| 4 | `hooks/hooks.json` | Modify | Remove check-update.sh entry from SessionStart hooks array (lines 11-15). |
| 5 | `README.md` | Modify | Remove check_version and auto_update rows from Available Settings table (lines 129-130). |
| 6 | `CLAUDE.md` (root) | Modify | Update "Setting 6" reference to "Setting 4" for version files. |

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Existing global config contains `check_version` and `auto_update` keys | Keys are ignored during loading. No error. Config file is not automatically rewritten. |
| 2 | Existing local config contains `check_version` and `auto_update` keys | Same as above: keys ignored, no error. |
| 3 | User runs `/dotclaude:configure` and saves | New config JSON contains only 4 keys: `language`, `working_directory`, `base_branch`, `version_files`. Old keys are dropped on save. |
| 4 | SessionStart fires after fix | Only `init-config.sh` runs. `check-update.sh` no longer executes. No GitHub network request on session start. |
| 5 | New installation (no existing config) | `init-config.sh` creates config with 3 keys: `language`, `working_directory`, `base_branch`. No `check_version` or `auto_update`. |

## Conflict Analysis

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | `check-update.sh` runs on every SessionStart, makes GitHub network request | No update check on SessionStart | Remove hook. Rely on Claude Code built-in marketplace update mechanism. |
| 2 | Local config can override `check_version`/`auto_update` from global | Settings removed entirely | Both global and local scopes no longer contain these settings. |
| 3 | Existing config files have `check_version`/`auto_update` keys | Keys become stale | Silently ignored. JSON parsing with `jq` fallback defaults handles unknown keys gracefully. |

## Out of Scope

- Customizing Claude Code's built-in plugin update mechanism
- Building a new update notification system to replace `check-update.sh`
- Automated config migration tool to clean stale keys from existing config files
- Any changes to the `Stop` hook (`check-validation-complete.sh`)
