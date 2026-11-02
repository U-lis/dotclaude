# Phase 1: stop-hook-own-worktree

## Objective

Limit the Stop hook's uncommitted-code block to the session's own worktree.

## Requirements

- FR-1
- FR-2
- FR-3
- NFR-1

---

## Scope

### In Scope
- `hooks/check-validation-complete.sh`, `tests/hooks/test_stop_hook.sh`
- `README.md`, `commands/_contract.md`, `docs/ARCHITECTURE.md`, `CHANGELOG.md`, version files

### Out of Scope
- Transcript-based tracking of edited paths
- Warnings about other worktrees

---

## Instructions

### Step 1: Hook
Replace the loop over every worktree with a check of the session's own worktree (`git rev-parse --show-toplevel` of the session cwd), keeping the branch, SPEC and stage conditions.

### Step 2: Docs
State the new scope where the hook's behavior is described.

---

## Completion Checklist

- [x] The uncommitted-code check reads only the session's worktree: verified in hooks/check-validation-complete.sh:22
- [x] A dirty other worktree does not block, from the primary or from a worktree: verified in tests/hooks/test_stop_hook.sh:18
- [x] README.md, commands/_contract.md, docs/ARCHITECTURE.md describe the scope: verified in README.md:201
- [x] CHANGELOG.md has a 0.8.1 entry and the version files say 0.8.1: verified in CHANGELOG.md:8
- [x] tests/hooks/run_all.sh and scripts/lint-prompts.sh pass: verified by run (ALL PASSED, lint OK)
