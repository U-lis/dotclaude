# Phase 1: Create /merge-main Skill

## Tasks

- [ ] Create `.claude/skills/merge-main/` directory
- [ ] Create `SKILL.md` with:
  - Frontmatter (name, description, user-invocable)
  - Trigger section
  - Workflow diagram
  - Conflict resolution guidance
  - Branch cleanup steps
  - PR creation option

## SKILL.md Structure

```yaml
---
name: merge-main
description: Merge feature branch to main with conflict resolution
user-invocable: true
---
```

## Workflow Steps

1. Save current branch name (or use argument)
2. Checkout main, pull latest
3. Merge feature branch
4. If conflict: guide resolution, wait for user
5. Run tests
6. Delete feature branch (local)
7. Option: create PR instead of merge
