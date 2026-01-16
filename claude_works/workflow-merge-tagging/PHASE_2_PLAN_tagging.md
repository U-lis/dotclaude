# Phase 2: Create /tagging Skill

## Tasks

- [ ] Create `.claude/skills/tagging/` directory
- [ ] Create `SKILL.md` with:
  - Frontmatter
  - CHANGELOG parsing logic
  - Version comparison
  - Tag creation workflow

## SKILL.md Structure

```yaml
---
name: tagging
description: Create version tag based on CHANGELOG
user-invocable: true
---
```

## Workflow Steps

1. Parse CHANGELOG.md for latest `## [X.Y.Z]` entry
2. Get latest git tag
3. Compare versions
4. If mismatch: prompt version bump commit
5. Create annotated tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
6. Show summary and manual push instruction
