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
- [x] Add `version_files` field to the Configuration Schema JSON block: Verified in commands/configure.md:43-52
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
- [x] Empty array `[]` means "use auto-detection": Verified in commands/configure.md:50

### Default Values Update
- [x] Add to the Default Values section: Verified in commands/configure.md:62
  ```bash
  DEFAULT_VERSION_FILES="[]"  # empty = auto-detect
  ```

### Step 1: Load Current Configuration Update
- [x] Add version_files loading to the bash script: Verified in commands/configure.md:88
  ```bash
  VERSION_FILES="[]"
  ```
- [x] In global config loading block, add: Verified in commands/configure.md:98
  ```bash
  VERSION_FILES=$(jq -c '.version_files // []' "$GLOBAL_CONFIG")
  ```
- [x] In local config loading block, add: Verified in commands/configure.md:112-115
  ```bash
  local_vf=$(jq -c '.version_files // null' "$LOCAL_CONFIG")
  if [ "$local_vf" != "null" ]; then
    VERSION_FILES="$local_vf"
  fi
  ```
  Note: For version_files, local config REPLACES (not merges with) global config when present.
- [x] Add to output: Verified in commands/configure.md:128
  ```bash
  echo "  version_files: $VERSION_FILES"
  ```

### Setting 6: Version Files (New Section)
- [x] Add after Setting 5 (Base Branch), before Step 4: Verified in commands/configure.md:336-454

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
- [x] If version_files is empty array: show "Auto-detection mode (no explicit config)": Verified in commands/configure.md:359
- [x] Then show what auto-detection WOULD find by checking file existence: Verified in commands/configure.md:360
- [x] If version_files is non-empty: show the configured list with path and pattern: Verified in commands/configure.md:361

#### Add Sub-action
- [x] Prompt for `path` (relative path to version file): Verified in commands/configure.md:365
- [x] Validate path: not empty, no leading `/`, no `..`, not `.` or `..`: Verified in commands/configure.md:369-397
- [x] Prompt for `pattern` (regex with capture group): Verified in commands/configure.md:400
- [x] Validate pattern: not empty, contains exactly one capture group `(...)` (excluding non-capturing groups `(?:...)`): Verified in commands/configure.md:403-429
- [x] Check for duplicate path (reject if already in list): Verified in commands/configure.md:434
- [x] If adding to an empty list (was auto-detect): warn user that explicit config overrides auto-detection: Verified in commands/configure.md:435
- [x] Auto-append CHANGELOG.md entry if not already present after add: Verified in commands/configure.md:436-439
- [x] Return to Setting 6 menu after add (allow multiple operations): Verified in commands/configure.md:440

#### Remove Sub-action
- [x] Show numbered list of current version_files entries: Verified in commands/configure.md:443
- [x] If list is empty: show "No explicit version files configured (using auto-detection)": Verified in commands/configure.md:445
- [x] Cannot remove CHANGELOG.md entry (show error if attempted): Verified in commands/configure.md:446
- [x] If removing the last non-CHANGELOG entry: warn that this reverts to CHANGELOG-only (suggest Reset instead): Verified in commands/configure.md:447
- [x] Return to Setting 6 menu after remove: Verified in commands/configure.md:448

#### Reset Sub-action
- [x] Clear version_files array (set to `[]`): Verified in commands/configure.md:452
- [x] Confirm: "Version files reset to auto-detection mode": Verified in commands/configure.md:453
- [x] Return to Setting 6 menu: Verified in commands/configure.md:454

### Step 4: Save Configuration Update
- [x] Add version_files to the jq command: Verified in commands/configure.md:467-481
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
- [x] Update the success output to include version_files: Verified in commands/configure.md:511

### Testing Checklist Update
- [x] Add these test items: Verified in commands/configure.md:636-644
  - [x] version_files can be viewed (auto-detect mode)
  - [x] version_files can be viewed (explicit config)
  - [x] Version file can be added with valid path and pattern
  - [x] Invalid path rejected (absolute, parent traversal)
  - [x] Invalid pattern rejected (no capture group, empty)
  - [x] Duplicate path rejected
  - [x] CHANGELOG.md cannot be removed
  - [x] Reset clears to auto-detection
  - [x] CHANGELOG.md auto-appended when missing from explicit config

## Changes to CLAUDE.md

### Version Files Section (replace lines 47-52)
- [x] Replace the hardcoded 3-file list: Verified in CLAUDE.md:47-59
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
- [x] Replace plugin-specific language: Verified in CLAUDE.md:63
  ```
  **CRITICAL**: Do NOT modify version numbers in `plugin.json` or `marketplace.json` during:
  ```
  With generic language:
  ```
  **CRITICAL**: Do NOT modify version numbers in version files during:
  ```

### Version Tagging Checklist Section (lines 67-87)
- [x] Replace the hardcoded bash snippet and 3-file verification with: Verified in CLAUDE.md:76-84
  ```
  **BEFORE creating a git tag**, verify version consistency using `/dotclaude:tagging`.

  The tagging command automatically:
  1. Resolves the version files list (from config or auto-detection)
  2. Checks all version files for consistency
  3. Reports any mismatches before proceeding

  For manual verification, check all configured version files match.
  See `/dotclaude:configure` Setting 6 to view which files are checked.
  ```
- [x] Keep the tag creation commands: Verified in CLAUDE.md:88-89
  ```bash
  git tag vX.Y.Z
  git push origin vX.Y.Z
  ```

### Workflow Section (lines 63-66)
- [x] Replace: Verified in CLAUDE.md:72
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
