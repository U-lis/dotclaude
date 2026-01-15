# /finalize

Complete project documentation and final cleanup.

## Trigger

User invokes `/finalize` after all phases are complete.

## Prerequisites

- All phases completed and validated
- All tests passing
- Code committed

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Review Completion Status                             │
│    - Verify all phases in GLOBAL.md are complete        │
│    - Check for any skipped items                        │
├─────────────────────────────────────────────────────────┤
│ 2. Update/Create README.md                              │
│    - Project description                                │
│    - Installation instructions                          │
│    - Usage examples                                     │
│    - Configuration                                      │
├─────────────────────────────────────────────────────────┤
│ 3. Update CHANGELOG.md                                  │
│    - Review commits since last tag                      │
│    - Categorize changes (Added, Changed, Fixed, etc.)   │
│    - Follow Keep a Changelog format                     │
├─────────────────────────────────────────────────────────┤
│ 4. Final Cleanup                                        │
│    - Remove any temporary files                         │
│    - Update GLOBAL.md status to Complete                │
│    - Archive claude_works/{subject}/ if desired         │
├─────────────────────────────────────────────────────────┤
│ 5. Final Commit                                         │
│    - git add documentation changes                      │
│    - git commit (with user permission)                  │
├─────────────────────────────────────────────────────────┤
│ 6. Report Summary                                       │
│    - List all completed phases                          │
│    - Highlight any special notes                        │
│    - Suggest next steps (tagging, PR, etc.)             │
└─────────────────────────────────────────────────────────┘
```

## TechnicalWriter Tasks

### README.md Update
```markdown
# {Project Name}

## Overview
Brief description

## Features
- Feature 1
- Feature 2

## Installation
```bash
# installation commands
```

## Usage
```bash
# usage examples
```

## Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| VAR_NAME | description | value |

## Development
```bash
# dev setup
```
```

### CHANGELOG.md Entry
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature A
- New feature B

### Changed
- Modified behavior of X

### Fixed
- Bug fix for Y
```

## GLOBAL.md Update

Update phase status table:
```markdown
| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Setup | 🟢 Complete |
| 2 | Core | 🟢 Complete |
| 3A | Feature A | 🟢 Complete |
| 3B | Feature B | 🟢 Complete |
| 3.5 | Merge | 🟢 Complete |
| 4 | Polish | 🟢 Complete |
```

## Final Commit Message Format

```
docs: finalize {subject} implementation

- Update README with usage instructions
- Add CHANGELOG entry for vX.Y.Z
- Mark all phases complete in GLOBAL.md

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Output

### Finalization Report
```markdown
# Project Finalization Complete

## Summary
- Total Phases: {N}
- Completed: {N}
- Skipped: {M} (if any)

## Documentation Updated
- [x] README.md
- [x] CHANGELOG.md
- [x] GLOBAL.md

## Final Commit
{commit hash}

## Suggested Next Steps
1. Review changes: `git log --oneline -10`
2. Create tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
3. Push: `git push origin main --tags`
4. Create PR (if on feature branch)
```

## Archive Option

Optionally archive planning documents:
```bash
# Move to archive
mkdir -p claude_works/_archive
mv claude_works/{subject} claude_works/_archive/{subject}_{date}
```
