# Fixture dc-88: reviewer axes 2, 4, 5

Input for a manual `dotclaude:reviewer` run (no automation). `repo/` is the base tree: a one-function `pricing.py`, its test, a SPEC with one requirement (FR-1, clamp the discount percent), the phase 1 PLAN, and `RULES.md` copied from `templates/RULES.md`. `change.patch` is the phase 1 diff. It implements FR-1 correctly and adds three defects:

- `apply_loyalty_bonus` in `pricing.py`: a function no SPEC requirement or PLAN item asks for (SPEC Out of scope says "Any other pricing rule").
- `0.93` and `3` in `apply_loyalty_bonus`: meaningful literals that are not named constants (RULES.md Code).
- `test_loyalty_bonus_reads_membership`: asserts only the mock's own configured return value; deleting any line of `apply_loyalty_bonus` leaves it passing.

## Setup

```bash
T=$(mktemp -d)
cp -r tests/fixtures/dc-88/repo/. "$T"
git -C "$T" init -q -b main && git -C "$T" add -A && git -C "$T" commit -qm base
git -C "$T" checkout -qb feature/discount
git -C "$T" apply "$PWD/tests/fixtures/dc-88/change.patch"
git -C "$T" add -A && git -C "$T" commit -qm "feat(discount): complete phase 1"
```

## Run

Call `dotclaude:reviewer` with the reviewer template from `commands/_agent-prompts.md`: scope "the full branch diff", `Worktree: $T`, `Base: main`, `SPEC: .dc_workspace/2026_10_30-discount/SPEC.md`, `RULES: .dc_workspace/RULES.md`, `PLAN: .dc_workspace/2026_10_30-discount/PHASE_1_PLAN_discount.md`.

## Expected report

- At least one row for each of the five axes, in axis order, and a last line `BLOCKERS: n`. A location may be a range that contains the line named below.
- Axis 2 scope: `issue` at `pricing.py:6` (`apply_loyalty_bonus`), traced to no FR.
- Axis 4 maintainability: `issue` at `pricing.py:9` for the `0.93` literal (the `3` on line 8 may be the same row or a second one).
- Axis 5 tests: `issue` at `tests/test_pricing.py:14-18` for the mock-only assertion.
- Axis 1 correctness: `checked` for the clamp (`pricing.py:2`). Axis 3 safety: `n/a` (no migration, permission, secret, or default change).

Severity is not fixed by the fixture: axis 2 may be Blocker or Major. Not expected: a correctness finding on the clamp line, or a finding that `test_apply_discount_clamps_above_100` is fake or out of scope (it implements the FR-1 boundary case). A Minor axis-5 note that the lower bound 0 has no test is acceptable.
