---
description: Create version tag based on CHANGELOG
---

# /dotclaude:tagging

Create git tag based on CHANGELOG.md version and push both commits and tags to remote.

## Prerequisites

- On main branch
- CHANGELOG.md exists with version entry
- Version files are configured in `dotclaude-config.json` OR auto-detectable in project root

## Version Argument

If the user provides an explicit version argument (e.g., `/dotclaude:tagging 0.3.0`), use that as the target version directly.

If no argument is provided, fall back to auto-detection: parse CHANGELOG.md for the latest `## [X.Y.Z]` entry.

In both cases, the Version Consistency Check MUST pass before proceeding.

## Version Files Resolution

Before performing the version consistency check, resolve which files to check and how to extract versions from them.

### Configuration Schema

The `version_files` field is an array of objects in `dotclaude-config.json`:

```json
{
  "version_files": [
    { "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" },
    { "path": "package.json", "pattern": "\"version\":\\s*\"([^\"]+)\"" }
  ]
}
```

Each entry has:
- `path`: relative path from project root to the file
- `pattern`: regex with exactly one capture group that extracts the version string

### Resolution Order

1. **Load config**: Read merged config from global (`~/.claude/dotclaude-config.json`) overlaid with local (`<project_root>/.claude/dotclaude-config.json`). Local values override global values.
2. **Check `version_files` field**:
   - If the field is **present and non-empty**: use those entries as-is, but ensure a CHANGELOG.md entry exists (append the default CHANGELOG.md entry if missing).
   - If the field is **absent, null, or an empty array**: run auto-detection (see below).

### Auto-Detection

When no explicit `version_files` are configured, scan the project root for known version files in this order. Only files that actually exist in the project root are included.

| Priority | File | Pattern | Notes |
|----------|------|---------|-------|
| 1 | `CHANGELOG.md` | `## \[([^\]]+)\]` | Always included (mandatory) |
| 2 | `package.json` | `"version":\s*"([^"]+)"` | Node.js projects |
| 3 | `pyproject.toml` | `version\s*=\s*"([^"]+)"` | Python projects |
| 4 | `Cargo.toml` | `version\s*=\s*"([^"]+)"` | Rust projects |
| 5 | `pom.xml` | `<version>([^<]+)</version>` | Java/Maven projects |
| 6 | `.claude-plugin/plugin.json` | `"version":\s*"([^"]+)"` | dotclaude plugin projects |
| 7 | `.claude-plugin/marketplace.json` | `"version":\s*"([^"]+)"` | dotclaude plugin projects |

### CHANGELOG.md Mandatory Rule

CHANGELOG.md is **always** included in the version files list. If a user provides explicit `version_files` without a CHANGELOG.md entry, the system auto-appends:

```json
{ "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" }
```

The CHANGELOG.md entry cannot be removed.

### Pseudo-Code for Resolution

```bash
# 1. Load merged config
GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"
LOCAL_CONFIG="<project_root>/.claude/dotclaude-config.json"

# Merge: local overrides global
CONFIG = merge(read_json(GLOBAL_CONFIG), read_json(LOCAL_CONFIG))

# 2. Check version_files field
if CONFIG.version_files is non-empty array:
    VERSION_FILES = CONFIG.version_files
    # Ensure CHANGELOG.md is present
    if no entry has path == "CHANGELOG.md":
        VERSION_FILES.append({ path: "CHANGELOG.md", pattern: "## \\[([^\\]]+)\\]" })
else:
    # 3. Auto-detect: check each known file in priority order
    VERSION_FILES = []
    for each (file, pattern) in AUTO_DETECT_TABLE:
        if file exists in project root:
            VERSION_FILES.append({ path: file, pattern: pattern })
```

## Workflow

```
1. Determine target version
   - If explicit version argument provided: use it
   - Else: parse CHANGELOG.md for latest ## [X.Y.Z] entry
2. Version consistency check (MANDATORY GATE)
   - Resolve version_files list (configured or auto-detected, see Version Files Resolution above)
   - For each entry in version_files, read the file at `path` and extract the version using `pattern`
   - ALL extracted versions must match the target version
   - If ANY mismatch: HALT immediately, report inconsistency, do NOT proceed
3. Get latest git tag (git describe --tags --abbrev=0)
   - If target version matches latest tag: report "Already tagged" and stop
   - If mismatch: proceed
4. Confirm with user (show target version and previous tag)
5. Create annotated tag: git tag -a vX.Y.Z -m "{Section1}" -m "{Section2}" ...
6. git push (MANDATORY - push commits to remote)
7. git push --tags (MANDATORY - push tags to remote)
8. Report summary
```

## Version Consistency Check

Before any tag is created, this check MUST pass.

For each entry in the resolved `version_files` list (see Version Files Resolution above):

1. Read the file at `path`
2. Apply the `pattern` regex to extract the version string (first capture group)
3. Compare the extracted version against the target version

All extracted versions MUST match the target version. If ANY mismatch is found (including files that are missing or where the pattern does not match), HALT immediately and report which files have which versions. Do NOT proceed with tagging.

## Version Parsing

CHANGELOG format (Keep a Changelog):
```markdown
## [1.2.3] - 2024-01-15
### Added
- Feature X
- Feature Y
### Fixed
- Bug A
- Bug B
```

Extract: `1.2.3` from `## [1.2.3]`

After extracting the version number, also extract each section header (`### Added`, `### Changed`, `### Fixed`, etc.) and its content under the target version entry. Each section becomes a separate `-m` argument for `git tag -a`.

Example: if CHANGELOG has `### Added` and `### Fixed` sections, the tag command becomes:
```
git tag -a v1.2.3 -m "Added: Feature X, Feature Y" -m "Fixed: Bug A, Bug B"
```

## Version Mismatch Handling

If target version != latest tag:
1. Show diff: `Target: 1.2.0` vs `Latest tag: 1.1.0`
2. Ask confirmation to create new tag

## Push Steps

After creating the tag, the command MUST execute `git push` to push commits to remote.

After pushing commits, the command MUST execute `git push --tags` to push tags to remote.

These push steps are MANDATORY. Do NOT skip them.

## Error Handling

If `git push` fails:
- Report the error with the failure message
- Note that the local tag is preserved
- Suggest the user retry manually with `git push`

If `git push --tags` fails:
- Report the error with the failure message
- Note that commits were pushed but tags were not
- Suggest the user retry manually with `git push --tags`

Never rollback or delete the local tag on push failure. The local tag MUST be preserved regardless of push outcome.

## Output

Success format:
```
# Tag Created & Pushed

- Version: v1.2.0
- Based on: CHANGELOG.md
- Previous tag: v1.1.0
- Commits pushed: success
- Tags pushed: success
```

Partial failure format (example: tag push failed):
```
# Tag Created - Push Partially Failed

- Version: v1.2.0
- Based on: CHANGELOG.md
- Previous tag: v1.1.0
- Commits pushed: success
- Tags pushed: FAILED (error message)
- Local tag preserved: yes
- Action required: retry `git push --tags`
```

Version consistency failure format (dynamically lists all checked files):
```
# Version Consistency Check Failed

- <file_path>: <extracted_version or "not found" or "no version match">
  (repeat for each entry in version_files)
- Status: MISMATCH - cannot proceed
- Action required: update version files to match before tagging
```

Example for a dotclaude plugin project:
```
# Version Consistency Check Failed

- CHANGELOG.md: 0.3.0
- .claude-plugin/plugin.json: 0.2.1
- .claude-plugin/marketplace.json: 0.2.1
- Status: MISMATCH - cannot proceed
- Action required: update version files to match before tagging
```

## Safety

- Only create tags, never delete
- Require user confirmation
- Push is mandatory after tag creation
- Never rollback local tag on push failure
