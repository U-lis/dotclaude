# Fixture dc-87: code-validator mechanical checks

Input for a manual code-validator run (no automation). Each directory is one project with its work documents in `.dc_workspace/greet/`.

## Setup

The validator lists changed files with `git status`, so copy a directory out of this repository and leave the code uncommitted:

```bash
cp -r tests/fixtures/dc-87/missing-fr "$TMP/missing-fr"
cd "$TMP/missing-fr" && git init -q && git add .dc_workspace && git commit -qm docs
```

Call `dotclaude:code-validator` with the `_agent-prompts.md` code-validator prompt: worktree `$TMP/missing-fr`, phase `1`, keyword `greet`, working directory `.dc_workspace`, doc dir `greet`. To see the first validation without the fix loop, add "Report the first validation only; do not call the coder."

## missing-fr

SPEC has FR-1 and FR-2, the PLAN lists both, the code implements only FR-1. `pyproject.toml` configures pytest and ruff. The second matrix row pins `src/greet/core.py:40`; the file has 4 lines.

Expected `Status: FAIL` with exactly these error rows:

1. checklist: `farewell` in `src/greet/core.py` not found.
2. requirement FR-2: `not implemented`.
3. matrix "greet rejects an empty name" (invalid): pinned line `src/greet/core.py:40` does not exist.

Expected ok rows: checklist `greet` (`src/greet/core.py:1`), requirement FR-1 (`implemented at src/greet/core.py:1`), the first matrix row, and pytest (2 passed) when pytest is installed. If the `pytest` or `ruff` binary is missing on the machine, the corresponding quality row is `WARN: no test runner` or `WARN: no linter`; the status stays FAIL. No `.validated/PHASE_1` marker, and SPEC.md is unchanged.

## no-runner

Same SPEC and PLAN; both FRs are implemented and every matrix row resolves. `pyproject.toml` has no pytest, ruff, or type checker configuration.

Expected `Status: PASS-WITH-WARN` with quality rows `WARN: no test runner` and `WARN: no linter` (types N/A) and no error rows. The validator updates PLAN, GLOBAL (`Complete`), and SPEC (`- [x] FR-1`, `- [x] FR-2`), does not create `.dc_workspace/greet/.validated/PHASE_1`, and the status line says the user must confirm before the commit.

Not expected in either directory: findings about scope, design, or test adequacy (those belong to the reviewer, not the validator).
