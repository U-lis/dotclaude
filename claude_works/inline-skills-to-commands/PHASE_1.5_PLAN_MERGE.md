# Phase 1.5: Merge Parallel Phases 1A and 1B

## Objective

Merge the results of Phase 1A (agent frontmatter) and Phase 1B (simple command inlining) into the main feature branch.

## Prerequisites

- Phase 1A complete (all 10 agent files have frontmatter)
- Phase 1B complete (7 command files have inlined SKILL.md content)

## Predicted Conflicts

### File-Level Conflicts

**None expected.** Phase 1A and 1B modify completely disjoint file sets:
- Phase 1A: `agents/` directory only
- Phase 1B: `commands/` directory only

### Integration Points

**None.** The phases are independent transformations with no shared interfaces.

### Test Coordination

**None.** Both phases can be verified independently by checking file content.

## Merge Procedure

```bash
# From the feature branch
git merge feature/{subject}-1A --no-edit
git merge feature/{subject}-1B --no-edit

# Cleanup worktrees
git worktree remove ../{subject}-1A
git worktree remove ../{subject}-1B
```

## Post-Merge Verification

After merge, verify:
1. All 10 agent files have frontmatter (Phase 1A result)
2. All 7 command files have inlined content (Phase 1B result)
3. No merge conflicts introduced
4. `commands/start-new.md` still contains the original redirect (not yet inlined)

## Completion Checklist

- [ ] Phase 1A branch merged successfully
- [ ] Phase 1B branch merged successfully
- [ ] No merge conflicts
- [ ] All 10 agent files verified with frontmatter
- [ ] All 7 command files verified with inlined content
- [ ] Worktrees cleaned up
