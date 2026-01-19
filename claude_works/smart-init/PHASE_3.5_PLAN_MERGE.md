# Phase 3.5: Merge Parallel Phases

## Objective
Merge results from phases 3A, 3B, and 3C into the main feature branch and perform integration verification.

## Prerequisites
- Phase 3A completed (init-feature enhanced)
- Phase 3B completed (init-bugfix enhanced)
- Phase 3C completed (init-refactor enhanced)

## Context

### Parallel Phase Summary
| Phase | File Modified | Status |
|-------|---------------|--------|
| 3A | `.claude/skills/init-feature/SKILL.md` | Pending |
| 3B | `.claude/skills/init-bugfix/SKILL.md` | Pending |
| 3C | `.claude/skills/init-refactor/SKILL.md` | Pending |

### Expected Conflicts
- None: Each phase modifies a different file
- All phases reference `_shared/analysis-phases.md` (read-only)
- All phases reference `_shared/init-workflow.md` (modified in Phase 1, read-only in 3A/3B/3C)

## Instructions

### Step 1: Verify Parallel Branches (If Using Worktrees)
If worktrees were used:
```bash
# Check branch status
git worktree list

# Verify each branch has commits
git log feature/smart-init-3A --oneline -3
git log feature/smart-init-3B --oneline -3
git log feature/smart-init-3C --oneline -3
```

### Step 2: Merge Branches
```bash
# Ensure on main feature branch
git checkout feature/smart-init

# Merge each parallel branch
git merge feature/smart-init-3A --no-edit -m "feat: integrate init-feature analysis (Phase 3A)"
git merge feature/smart-init-3B --no-edit -m "feat: integrate init-bugfix analysis (Phase 3B)"
git merge feature/smart-init-3C --no-edit -m "feat: integrate init-refactor analysis (Phase 3C)"
```

### Step 3: Conflict Resolution (If Any)
Expected: No conflicts due to separate files.

If unexpected conflicts occur:
1. Document conflict details
2. Resolve favoring the parallel branch change
3. Test after resolution

### Step 4: Integration Verification

#### Cross-Reference Check
Verify all skills reference shared files correctly:
```bash
# Check references to analysis-phases.md
grep -r "analysis-phases.md" .claude/skills/

# Check references to init-workflow.md
grep -r "init-workflow.md" .claude/skills/
```

#### Structure Consistency Check
Verify all three skills have consistent structure:
- [ ] init-feature has "Analysis Phase" section
- [ ] init-bugfix has "Analysis Phase" section
- [ ] init-refactor has "Analysis Phase" section

#### Section Consistency Check
Verify analysis sections follow common pattern:
- [ ] All reference `_shared/analysis-phases.md`
- [ ] All have work-type-specific Step B instructions
- [ ] All have Step C (Conflict Detection) section
- [ ] All have Step D (Edge Case Generation) section
- [ ] All have updated Output section with Analysis Results

### Step 5: Cleanup Worktrees (If Used)
```bash
# Remove worktrees
git worktree remove ../smart-init-3A
git worktree remove ../smart-init-3B
git worktree remove ../smart-init-3C

# Delete temporary branches
git branch -d feature/smart-init-3A
git branch -d feature/smart-init-3B
git branch -d feature/smart-init-3C
```

### Step 6: Final Commit
If any integration fixes were needed:
```bash
git add .
git commit -m "feat(smart-init): integrate parallel phases 3A/3B/3C"
```

## Completion Checklist
- [ ] All parallel branches merged
- [ ] No unresolved conflicts
- [ ] Cross-reference check passed
- [ ] Structure consistency verified
- [ ] Section consistency verified
- [ ] Worktrees cleaned up (if used)
- [ ] Integration commit created (if fixes needed)

## Notes
- This phase is primarily verification; actual merge should be clean
- If conflicts occur, they indicate a planning error in parallel phase identification
- All three init skills should now have consistent analysis capabilities
