# Phase {K}.5: Merge Parallel Branches

## Objective

Merge parallel phase branches back to base branch and resolve any conflicts.

---

## Merge Targets

| Branch | Phase | Status |
|--------|-------|--------|
| {type}/{keyword}-{k}A | Phase {k}A | 🔴 Not Merged |
| {type}/{keyword}-{k}B | Phase {k}B | 🔴 Not Merged |
| {type}/{keyword}-{k}C | Phase {k}C | 🔴 Not Merged |

**Base Branch**: {type}/{keyword}

---

## Expected Conflict Areas

Based on Designer's analysis, potential conflicts may occur in:

| File | Reason | Resolution Strategy |
|------|--------|---------------------|
| {file1} | {reason} | {strategy} |
| {file2} | {reason} | {strategy} |

---

## Merge Order

The following order minimizes conflict resolution complexity:

1. **{type}/{keyword}-{k}A** → {type}/{keyword}
   - Expected conflicts: {none/minimal/list files}
   - Resolution notes: {notes}

2. **{type}/{keyword}-{k}B** → {type}/{keyword}
   - Expected conflicts: {list}
   - Resolution notes: {notes}

3. **{type}/{keyword}-{k}C** → {type}/{keyword}
   - Expected conflicts: {list}
   - Resolution notes: {notes}

---

## Merge Commands

```bash
# Ensure on base branch
git checkout {type}/{keyword}

# Merge first branch
git merge {type}/{keyword}-{k}A
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}A"

# Merge second branch
git merge {type}/{keyword}-{k}B
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}B"

# Merge third branch
git merge {type}/{keyword}-{k}C
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}C"
```

---

## Post-Merge Validation

### Quality Checks
Run the project's quality commands (as detected by code-validator): lint, type check, and the full test suite.

### Integration Verification
- [ ] All merged features work together
- [ ] No regression in existing functionality
- [ ] API contracts maintained

---

## Worktree Cleanup

After successful merge:

```bash
# Remove worktrees
git worktree remove ../{project_name}-{type}-{keyword}-{k}A
git worktree remove ../{project_name}-{type}-{keyword}-{k}B
git worktree remove ../{project_name}-{type}-{keyword}-{k}C

# Delete remote branches (optional)
git push origin --delete {type}/{keyword}-{k}A
git push origin --delete {type}/{keyword}-{k}B
git push origin --delete {type}/{keyword}-{k}C

# Delete local branches
git branch -d {type}/{keyword}-{k}A
git branch -d {type}/{keyword}-{k}B
git branch -d {type}/{keyword}-{k}C
```

---

## Completion Checklist

- [ ] All parallel branches merged
- [ ] All conflicts resolved
- [ ] Project quality commands passing (as detected by code-validator)
- [ ] Worktrees removed
- [ ] Local branches cleaned up
- [ ] Remote branches cleaned up (if applicable)

---

## Conflict Resolution Log

### {File 1}
- **Conflict type**: {e.g., both modified same function}
- **Resolution**: {what was done}

### {File 2}
- **Conflict type**: {description}
- **Resolution**: {what was done}

---

## Merge Commits

| Merge | Commit Hash | Timestamp |
|-------|-------------|-----------|
| Phase {k}A | - | - |
| Phase {k}B | - | - |
| Phase {k}C | - | - |

*Updated upon completion*

---

## Notes

- {Any issues encountered}
- {Lessons learned for future parallel phases}
