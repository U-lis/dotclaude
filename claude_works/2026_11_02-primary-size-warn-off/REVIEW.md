# Review

## Phase 1

BLOCKERS: 0.

| # | Axis | Severity | Location | Finding |
|---|------|----------|----------|---------|
| 1 | correctness | Minor | `hooks/check-validation-complete.sh:57` | In a submodule or a `--separate-git-dir` checkout, `wt` probably never equals `PRIMARY`, so `false` has no effect and the warning stays. Fails toward warning. Not executed. |
| 6 | tests | Minor | `tests/hooks/test_stop_hook.sh:84-96` | No test covers a non-boolean value such as `"False"`, which keeps the warning on. |
| 7 | tests | Minor | `PHASE_1_TEST.md` | The matrix omits assertions the diff adds: no jq, symlinked cwd, log lines, the hint, and the `(r)` no-code case. |

## Full diff

This review covered the full branch diff, because all of it was uncommitted.
