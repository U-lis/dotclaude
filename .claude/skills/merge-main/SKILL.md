---
name: dc:merge-main
description: Merge feature branch to main with conflict resolution and branch cleanup
user-invocable: true
---

# /dc:merge-main [branch]

Merge feature branch to main, resolve conflicts, cleanup.

## Arguments

| Arg | Description | Default |
|-----|-------------|---------|
| branch | Feature branch to merge | Current branch |

## Workflow

```
1. Save feature branch name
2. git checkout main && git pull origin main
3. git merge {feature-branch}
   → If conflict: guide user, wait for resolution
4. Run tests (if configured)
5. git branch -d {feature-branch}
6. Report summary
```

## Conflict Resolution

If merge conflict occurs:
1. List conflicted files
2. User resolves manually
3. User signals completion
4. Continue with `git add . && git commit`

## PR Option

Before merge, ask:
```
Question: "How to proceed?"
Options:
  - "Direct merge" → continue workflow
  - "Create PR" → gh pr create, skip local merge
```

## Safety

- Never force push
- Never commit directly to main (only merge)
- Confirm before branch deletion

## Output

```
# Merge Complete

- Feature: {branch}
- Merged to: main
- Conflicts: {resolved/none}
- Branch deleted: yes/no

Next: git push origin main
```
