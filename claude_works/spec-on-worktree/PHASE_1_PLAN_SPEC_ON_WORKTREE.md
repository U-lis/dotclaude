# Phase 1: Fix Worktree Directory Context After Creation

## Objective

Ensure that after `git worktree add` in the init workflow, the shell working directory changes into the newly created worktree so all subsequent relative-path operations resolve correctly.

## Prerequisites

- None (single phase, no prior dependencies)

## Instructions

### Change 1: `commands/_init-common.md` -- Branch Creation Section

**Target file:** `commands/_init-common.md`
**Target section:** Branch Creation > Steps (lines 17-23)

The current steps are:

```
1. Auto-generate branch keyword from the work description
2. Update base branch: `git checkout {base_branch} && git pull origin {base_branch}`
3. Create work branch via worktree: `git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}`
4. Create project directory: `mkdir -p ../{project_name}-{type}-{keyword}/{working_directory}/{subject}`
```

Modify to:

1. Keep steps 1-3 unchanged.
2. Add a new step 4: `cd ../{project_name}-{type}-{keyword}`
3. Renumber old step 4 to step 5 and simplify the `mkdir` path to use relative path: `mkdir -p {working_directory}/{subject}`

The resulting steps should be:

```
1. Auto-generate branch keyword from the work description
2. Update base branch: `git checkout {base_branch} && git pull origin {base_branch}`
3. Create work branch via worktree: `git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}`
4. Change into worktree directory: `cd ../{project_name}-{type}-{keyword}`
5. Create project directory: `mkdir -p {working_directory}/{subject}`
```

**Important:** Step 3 (worktree creation) can fail. If it fails, the workflow halts at that step. Step 4 (`cd`) only executes after successful worktree creation, so no additional error handling is needed for the `cd` instruction itself.

### Change 2: `commands/start-new.md` -- Step 6 Checkpoint, Worktree Check

**Target file:** `commands/start-new.md`
**Target section:** Step 6 Checkpoint (Before Design) > item 4. Worktree Check (lines 187-190)

The current Worktree Check is:

```
4. **Worktree Check**:
   - Directory `../{project_name}-{type}-{keyword}` must exist as a valid git worktree
   - Run: `git worktree list | grep {project_name}-{type}-{keyword}`
   - If not found: HALT and report "Worktree not found. Create worktree before design phase."
```

Replace with a current-directory verification approach:

```
4. **Worktree Check**:
   - Current directory must be inside the worktree
   - Run: `pwd` and verify output contains `{project_name}-{type}-{keyword}`
   - Secondary validation: `git worktree list | grep {project_name}-{type}-{keyword}`
   - If `pwd` does not contain worktree name: HALT and report "Not in worktree directory. Run cd to enter worktree before design phase."
```

Key differences from the original:
- Primary check changes from external directory existence to `pwd`-based current directory verification.
- `git worktree list` is retained as secondary validation.
- Error message changes from "Worktree not found" to "Not in worktree directory" to reflect the new check semantics.

## Completion Checklist

- [x] 1.1: Add `cd ../{project_name}-{type}-{keyword}` step after worktree creation in `commands/_init-common.md` -- Verified at line 23
- [x] 1.2: Simplify `mkdir` to relative path `{working_directory}/{subject}` in `commands/_init-common.md` -- Verified at line 24
- [x] 1.3: Update Step 6 Checkpoint Worktree Check in `commands/start-new.md` to use `pwd` verification -- Verified at lines 187-191
- [x] 1.4: Verify worktree creation failure edge case (instruction order handles it -- `cd` only runs after successful `git worktree add`) -- Verified: sequential step ordering ensures cd runs only after successful worktree add
- [x] 1.5: Verify no changes needed in `commands/code.md` (parallel phase worktree handling already correct) -- Verified: git diff empty
- [x] 1.6: Verify no changes to agent files (`agents/technical-writer.md`, `agents/designer.md`, etc.) -- Verified: git diff empty

## Notes

- All relative paths in `start-new.md` (Steps 4, 8, TechnicalWriter/Designer invocations) resolve correctly after the `cd` fix without any additional modifications. This is because those paths were always written as relative (e.g., `{working_directory}/{subject}/SPEC.md`), and the only issue was which directory they resolved against.
- The `commands/code.md` file already follows the correct pattern for parallel phase worktrees (`cd ../{project_name}-{type}-{keyword}-3A`), so this fix aligns the init workflow with the existing convention.
- The `worktree_path` metadata written into SPEC.md by `start-new.md` remains unchanged. Downstream commands like `/dotclaude:code` read this metadata and handle directory context independently.
