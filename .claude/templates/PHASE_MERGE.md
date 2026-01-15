# Phase {K}.5: Merge Parallel Branches

## Objective

Merge parallel phase branches back to base branch and resolve any conflicts.

---

## Merge Targets

| Branch | Phase | Status |
|--------|-------|--------|
| feature/{subject}-{k}A | Phase {k}A | 🔴 Not Merged |
| feature/{subject}-{k}B | Phase {k}B | 🔴 Not Merged |
| feature/{subject}-{k}C | Phase {k}C | 🔴 Not Merged |

**Base Branch**: feature/{subject}

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

1. **feature/{subject}-{k}A** → feature/{subject}
   - Expected conflicts: {none/minimal/list files}
   - Resolution notes: {notes}

2. **feature/{subject}-{k}B** → feature/{subject}
   - Expected conflicts: {list}
   - Resolution notes: {notes}

3. **feature/{subject}-{k}C** → feature/{subject}
   - Expected conflicts: {list}
   - Resolution notes: {notes}

---

## Merge Commands

```bash
# Ensure on base branch
git checkout feature/{subject}

# Merge first branch
git merge feature/{subject}-{k}A
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}A"

# Merge second branch
git merge feature/{subject}-{k}B
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}B"

# Merge third branch
git merge feature/{subject}-{k}C
# Resolve conflicts if any
# git add .
# git commit -m "Merge phase {k}C"
```

---

## Post-Merge Validation

### Quality Checks
```bash
# Run linter
ruff check .

# Run type checker
ty check

# Run all tests
pytest
```

### Integration Verification
- [ ] All merged features work together
- [ ] No regression in existing functionality
- [ ] API contracts maintained

---

## Worktree Cleanup

After successful merge:

```bash
# Remove worktrees
git worktree remove ../{subject}-{k}A
git worktree remove ../{subject}-{k}B
git worktree remove ../{subject}-{k}C

# Delete remote branches (optional)
git push origin --delete feature/{subject}-{k}A
git push origin --delete feature/{subject}-{k}B
git push origin --delete feature/{subject}-{k}C

# Delete local branches
git branch -d feature/{subject}-{k}A
git branch -d feature/{subject}-{k}B
git branch -d feature/{subject}-{k}C
```

---

## Completion Checklist

- [ ] All parallel branches merged
- [ ] All conflicts resolved
- [ ] Linter passing
- [ ] Type checker passing
- [ ] All tests passing
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
