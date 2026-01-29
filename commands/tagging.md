---
description: Create version tag based on CHANGELOG
---

# /dotclaude:tagging

Create git tag based on CHANGELOG.md version and push both commits and tags to remote.

## Prerequisites

- On main branch
- CHANGELOG.md exists with version entry
- `.claude-plugin/plugin.json` exists and contains a `"version"` field
- `.claude-plugin/marketplace.json` exists and contains a `"version"` field in `plugins[0]`

## Version Argument

If the user provides an explicit version argument (e.g., `/dotclaude:tagging 0.3.0`), use that as the target version directly.

If no argument is provided, fall back to auto-detection: parse CHANGELOG.md for the latest `## [X.Y.Z]` entry.

In both cases, the Version Consistency Check MUST pass before proceeding.

## Workflow

```
1. Determine target version
   - If explicit version argument provided: use it
   - Else: parse CHANGELOG.md for latest ## [X.Y.Z] entry
2. Version consistency check (MANDATORY GATE)
   - Read version from .claude-plugin/plugin.json
   - Read version from .claude-plugin/marketplace.json (plugins[0].version)
   - Read latest version from CHANGELOG.md
   - ALL THREE must match the target version
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

Files and fields to verify:

| File | Field | Example |
|------|-------|---------|
| `.claude-plugin/plugin.json` | `"version"` (root level) | `"version": "0.3.0"` |
| `.claude-plugin/marketplace.json` | `"version"` in `plugins[0]` | `"version": "0.3.0"` |
| `CHANGELOG.md` | Latest `## [X.Y.Z]` entry | `## [0.3.0] - 2024-01-15` |

All three values MUST match the target version. If ANY mismatch is found, HALT immediately and report which files have which versions. Do NOT proceed with tagging.

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

Version consistency failure format:
```
# Version Consistency Check Failed

- plugin.json: 0.2.1
- marketplace.json: 0.2.1
- CHANGELOG.md: 0.3.0
- Status: MISMATCH - cannot proceed
- Action required: update version files to match before tagging
```

## Safety

- Only create tags, never delete
- Require user confirmation
- Push is mandatory after tag creation
- Never rollback local tag on push failure
