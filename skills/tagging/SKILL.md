---
name: tagging
description: Create version tag based on CHANGELOG
user-invocable: true
---

# /dc:tagging

Create git tag based on CHANGELOG.md version.

## Prerequisites

- On main branch
- CHANGELOG.md exists with version entry

## Workflow

```
1. Parse CHANGELOG.md → extract latest version (## [X.Y.Z])
2. Get latest git tag → git describe --tags --abbrev=0
3. Compare versions
   → If match: "Already tagged"
   → If mismatch: proceed
4. Confirm with user
5. git tag -a vX.Y.Z -m "{Version Summary 1}" -m "{Version Summary 2}" ...
6. git push (push commits to remote)
7. git push --tags (push tags to remote)
8. Report summary
```

## Version Parsing

CHANGELOG format (Keep a Changelog):
```markdown
## [1.2.3] - 2024-01-15
### Added
- Feature X
```

Extract: `1.2.3` from `## [1.2.3]`

## Version Mismatch Handling

If CHANGELOG version != latest tag:
1. Show diff: `CHANGELOG: 1.2.0` vs `Latest tag: 1.1.0`
2. Ask confirmation to create new tag

## Output

```
# Tag Created & Pushed

- Version: v1.2.0
- Based on: CHANGELOG.md
- Previous tag: v1.1.0
- Pushed to: origin
```

## Safety

- Only create tags, never delete
- Require user confirmation
- Auto-push after user confirms tag creation
