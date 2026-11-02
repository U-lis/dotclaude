# Review

## Phase 1

BLOCKERS: 0. Behavior outside the scope is unchanged except a cwd inside `.git`.

| # | Axis | Severity | Location | Finding |
|---|------|----------|----------|---------|
| 1 | correctness | Major | `hooks/check-validation-complete.sh:22` | The block depends on the hook's `cwd` being inside the worktree. If a session stays in the primary and edits a worktree, its own uncommitted code passes silently. Not reproduced. Accepted: the user chose this scope, and it fails open. |
| 2 | correctness | Minor | `hooks/check-validation-complete.sh:27` | A cwd inside `.git` changed from blocking to passing. No command flow sits there. |
| 3 | correctness | Minor | `commands/code.md:28` | Parallel-phase worktrees lose the one-time block when the orchestrator stays on `{type}/{keyword}`. `parallel_phases` defaults to false. |
| 7 | maintainability | Minor | `hooks/check-validation-complete.sh:75` | The `Stop pass` log text says "work branches" and does not name the worktree checked. |
| 8 | maintainability | Minor | `tests/hooks/test_stop_hook.sh:46` | Block (p) sits between the (j) setup and its assertions. |

## Full diff

This review covered the full branch diff, because all of it was uncommitted.
