# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Session worktree with uncommitted code blocks | FR-1 | normal | integration | `tests/hooks/test_stop_hook.sh::uncommitted code -> block` | `hooks/check-validation-complete.sh:46` |
| Session in a subdirectory of its worktree blocks | FR-1 | boundary | integration | `tests/hooks/test_stop_hook.sh::subdirectory of worktree -> block` | `hooks/check-validation-complete.sh:22` |
| Primary session is not blocked by a dirty worktree | FR-2 | normal | integration | `tests/hooks/test_stop_hook.sh::dirty worktree -> no block from primary cwd` | `hooks/check-validation-complete.sh:22` |
| Worktree session is not blocked by another dirty worktree | FR-2 | boundary | integration | `tests/hooks/test_stop_hook.sh::(p) other dirty worktree -> no block` | `hooks/check-validation-complete.sh:22` |
| Stage without a phase in flight does not block | NFR-1 | boundary | integration | `tests/hooks/test_stop_hook.sh::(h) stage design -> pass` | `hooks/check-validation-complete.sh:43` |
| stop_hook_active stays silent | NFR-1 | normal | integration | `tests/hooks/test_stop_hook.sh::stop_hook_active -> silent` | `hooks/check-validation-complete.sh:10` |
