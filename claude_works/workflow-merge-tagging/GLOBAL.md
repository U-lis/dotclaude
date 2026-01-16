# Workflow: Merge-Main & Tagging

## Architecture

New skills added to `.claude/skills/`:
```
.claude/skills/
├── merge-main/SKILL.md    (new)
├── tagging/SKILL.md       (new)
└── finalize/              (delete)
```

## Phase Overview

| Phase | Description | Dependencies | Status |
|-------|-------------|--------------|--------|
| 1 | Create /merge-main skill | - | Pending |
| 2 | Create /tagging skill | - | Pending |
| 3 | Remove /finalize, update refs | Phase 1, 2 | Pending |

## Workflow Update

```
init-xxx → design → code → merge-main → tagging
                              ↓
                         (PR option)
```
