# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Key false silences the primary's size warning | FR-1 | normal | integration | tests/hooks/test_stop_hook.sh::(q) key false -> primary silent | hooks/check-validation-complete.sh:59 |
| Key false keeps a worktree's size warning | FR-2 | boundary | integration | tests/hooks/test_stop_hook.sh::(q) key false -> worktree warns | hooks/check-validation-complete.sh:73 |
| Key unset warns on the primary | FR-3 | normal | integration | tests/hooks/test_stop_hook.sh::(q) key unset -> primary warns | hooks/check-validation-complete.sh:73 |
| Key true warns on the primary | FR-3 | boundary | integration | tests/hooks/test_stop_hook.sh::(q) key true -> primary warns | hooks/check-validation-complete.sh:73 |
| Key false keeps the uncommitted-code block on the primary | NFR-1 | boundary | integration | tests/hooks/test_stop_hook.sh::(r) key false, work branch, code -> block | hooks/check-validation-complete.sh:49 |
