# Bugfix: SPEC and Documents Created in Wrong Directory After Worktree Creation - Global Documentation

## Feature Overview

### Purpose

Fix the workflow so that after `git worktree add`, all subsequent file operations (SPEC.md creation, design documents, git add/commit) execute inside the worktree directory instead of the original repository directory.

### Problem

The `_init-common.md` command creates a worktree at `../{project_name}-{type}-{keyword}` and even creates the project subdirectory inside it via `mkdir -p ../{project_name}-{type}-{keyword}/{working_directory}/{subject}`. However, no `cd` instruction follows, so the shell remains in the original repository root. All downstream operations in `start-new.md` use relative paths (e.g., `{working_directory}/{subject}/SPEC.md`) that resolve against the original directory, not the worktree.

### Solution

1. Add a `cd ../{project_name}-{type}-{keyword}` instruction immediately after worktree creation in `_init-common.md`.
2. Simplify the `mkdir` command to use a relative path (`{working_directory}/{subject}`) since the shell is now inside the worktree.
3. Update the Step 6 Checkpoint Worktree Check in `start-new.md` to verify the current directory via `pwd` instead of only checking external directory existence.

## Architecture Decision

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-1 | Add `cd` instruction after `git worktree add` in `_init-common.md` | Ensures all subsequent relative-path operations resolve inside the worktree. This is the root cause fix. |
| AD-2 | Simplify `mkdir` to use relative path after `cd` | After `cd` into the worktree, `mkdir -p {working_directory}/{subject}` is cleaner and consistent with the new context. The previous absolute-style path (`../{project_name}-{type}-{keyword}/{working_directory}/{subject}`) becomes redundant. |
| AD-3 | Update Step 6 Checkpoint Worktree Check to verify current directory via `pwd` | The existing check only confirms the worktree directory exists externally. After the fix, the shell should already be inside the worktree, so verification should confirm `pwd` output contains `{project_name}-{type}-{keyword}`. Keep `git worktree list` as secondary validation. |
| AD-4 | Do NOT modify relative paths in `start-new.md` beyond Step 6 Checkpoint | All relative paths in `start-new.md` (e.g., `{working_directory}/{subject}/SPEC.md` in Steps 4, 8, TechnicalWriter invocations) automatically resolve correctly once the shell is inside the worktree. No changes needed. |
| AD-5 | Do NOT modify TechnicalWriter or any agent files | Paths are passed to agents via orchestrator prompts. The orchestrator (`start-new.md`) already uses relative paths, which resolve correctly after the `cd` fix. Agent definitions do not contain hardcoded paths. |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Fix worktree directory context after creation | Pending | None |

## File Structure

### Files to Modify

| File | Change Summary |
|------|----------------|
| `commands/_init-common.md` | Add `cd` after worktree creation (new step 4); simplify `mkdir` path (renumbered step 5) |
| `commands/start-new.md` | Update Step 6 Checkpoint Worktree Check to use `pwd` verification |

### Files Verified as No-Change-Needed

| File | Reason |
|------|--------|
| `commands/code.md` | Already handles worktree context correctly for parallel phases |
| `agents/technical-writer.md` | Paths come from orchestrator prompt, not hardcoded |
| `agents/designer.md` | Same as above |
| All other agent files | Same as above |
