# PHASE 2: User Surface - Configure Command + CLAUDE.md Documentation

## Objective

Add version_files management to the configure command (Setting 6) and update CLAUDE.md to replace hardcoded version file references with the new configurable system.

## Target Files

- `commands/configure.md`
- `CLAUDE.md` (project root)

## Dependencies

- PHASE_1 must be complete (schema and auto-detection logic finalized in tagging.md)

## Changes to commands/configure.md

### Configuration Schema Update
- [ ] Add `version_files` field to the Configuration Schema JSON block:
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
- [ ] Empty array `[]` means "use auto-detection"

### Default Values Update
- [ ] Add to the Default Values section:
  ```bash
  DEFAULT_VERSION_FILES="[]"  # empty = auto-detect
  ```

### Step 1: Load Current Configuration Update
- [ ] Add version_files loading to the bash script:
  ```bash
  VERSION_FILES="[]"
  ```
- [ ] In global config loading block, add:
  ```bash
  VERSION_FILES=$(jq -c '.version_files // []' "$GLOBAL_CONFIG")
  ```
- [ ] In local config loading block, add:
  ```bash
  local_vf=$(jq -c '.version_files // null' "$LOCAL_CONFIG")
  if [ "$local_vf" != "null" ]; then
    VERSION_FILES="$local_vf"
  fi
  ```
  Note: For version_files, local config REPLACES (not merges with) global config when present.
- [ ] Add to output:
  ```bash
  echo "  version_files: $VERSION_FILES"
  ```

### Setting 6: Version Files (New Section)
- [ ] Add after Setting 5 (Base Branch), before Step 4

Interactive workflow using AskUserQuestion:

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

#### View Sub-action
- [ ] If version_files is empty array: show "Auto-detection mode (no explicit config)"
- [ ] Then show what auto-detection WOULD find by checking file existence
- [ ] If version_files is non-empty: show the configured list with path and pattern

#### Add Sub-action
- [ ] Prompt for `path` (relative path to version file)
- [ ] Validate path: not empty, no leading `/`, no `..`, not `.` or `..`
- [ ] Prompt for `pattern` (regex with capture group)
- [ ] Validate pattern: not empty, contains exactly one capture group `(...)` (excluding non-capturing groups `(?:...)`)
- [ ] Check for duplicate path (reject if already in list)
- [ ] If adding to an empty list (was auto-detect): warn user that explicit config overrides auto-detection
- [ ] Auto-append CHANGELOG.md entry if not already present after add
- [ ] Return to Setting 6 menu after add (allow multiple operations)

#### Remove Sub-action
- [ ] Show numbered list of current version_files entries
- [ ] If list is empty: show "No explicit version files configured (using auto-detection)"
- [ ] Cannot remove CHANGELOG.md entry (show error if attempted)
- [ ] If removing the last non-CHANGELOG entry: warn that this reverts to CHANGELOG-only (suggest Reset instead)
- [ ] Return to Setting 6 menu after remove

#### Reset Sub-action
- [ ] Clear version_files array (set to `[]`)
- [ ] Confirm: "Version files reset to auto-detection mode"
- [ ] Return to Setting 6 menu

### Step 4: Save Configuration Update
- [ ] Add version_files to the jq command:
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
- [ ] Update the success output to include version_files

### Testing Checklist Update
- [ ] Add these test items:
  - [ ] version_files can be viewed (auto-detect mode)
  - [ ] version_files can be viewed (explicit config)
  - [ ] Version file can be added with valid path and pattern
  - [ ] Invalid path rejected (absolute, parent traversal)
  - [ ] Invalid pattern rejected (no capture group, empty)
  - [ ] Duplicate path rejected
  - [ ] CHANGELOG.md cannot be removed
  - [ ] Reset clears to auto-detection
  - [ ] CHANGELOG.md auto-appended when missing from explicit config

## Changes to CLAUDE.md

### Version Files Section (replace lines 47-52)
- [ ] Replace the hardcoded 3-file list:
  ```
  These files contain version information and must stay in sync:
  - `.claude-plugin/plugin.json` -> `"version": "X.Y.Z"`
  - `.claude-plugin/marketplace.json` -> `"version": "X.Y.Z"`
  - `CHANGELOG.md` -> `## [X.Y.Z] - YYYY-MM-DD`
  ```
  With:
  ```
  Version files are configurable per-project via `dotclaude-config.json`.

  When `version_files` is configured, those files are checked.
  When not configured, common version files are auto-detected
  (CHANGELOG.md, package.json, pyproject.toml, Cargo.toml, pom.xml,
  .claude-plugin/plugin.json, .claude-plugin/marketplace.json).

  CHANGELOG.md is always mandatory and cannot be removed.

  Configure version files via `/dotclaude:configure` (Setting 6)
  or edit `dotclaude-config.json` directly.
  ```

### Version Update Rules Section (lines 54-60)
- [ ] Replace plugin-specific language:
  ```
  **CRITICAL**: Do NOT modify version numbers in `plugin.json` or `marketplace.json` during:
  ```
  With generic language:
  ```
  **CRITICAL**: Do NOT modify version numbers in version files during:
  ```

### Version Tagging Checklist Section (lines 67-87)
- [ ] Replace the hardcoded bash snippet and 3-file verification with:
  ```
  **BEFORE creating a git tag**, verify version consistency using `/dotclaude:tagging`.

  The tagging command automatically:
  1. Resolves the version files list (from config or auto-detection)
  2. Checks all version files for consistency
  3. Reports any mismatches before proceeding

  For manual verification, check all configured version files match.
  See `/dotclaude:configure` Setting 6 to view which files are checked.
  ```
- [ ] Keep the tag creation commands:
  ```bash
  git tag vX.Y.Z
  git push origin vX.Y.Z
  ```

### Workflow Section (lines 63-66)
- [ ] Replace:
  ```
  2. **At release**: Update all three files to the new version, then tag
  ```
  With:
  ```
  2. **At release**: Update all version files to the new version, then tag
  ```

## Acceptance Criteria

1. configure.md has Setting 6 with full View/Add/Remove/Reset workflow
2. configure.md schema includes version_files field
3. configure.md save logic includes version_files
4. CLAUDE.md no longer contains hardcoded `.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json` references in version management sections
5. CLAUDE.md references the configurable version_files system
6. CLAUDE.md references `/dotclaude:tagging` for version consistency checks
7. All user-facing text in configure.md follows the language configuration pattern (uses configured language)
