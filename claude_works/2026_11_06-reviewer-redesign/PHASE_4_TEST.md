# Phase 4: Test Matrix

Verification is by running `/dotclaude:review` with the worktree plugin twice: once with no argument on a branch, once with `#3493`. Rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| With no argument and changes present, the command creates `{primary}/{WD}/reviews/{today}-{target}/r1/` with REVIEW.md, STATUS.md and EVIDENCE.md and prints REVIEW.md | FR-6 | normal | scenario | - | - |
| `#N` or a URL reviews that PR at PR depth, then triage, ask and act run as before; nothing is written to GitHub before the user answers and there is no offer to post | FR-6 | normal | scenario | - | - |
| `#N` that is an issue prints "#N is an issue, not a pull request" and stops without a review | FR-6 | invalid | scenario | - | - |
| A branch with no changes prints "Nothing to review." | FR-6 | boundary | scenario | - | - |
| The reviewer prompt contains the ledger path and the id prefix `{target}-r{n}`; after the run the ledger has `finding` lines with that prefix | FR-6 | normal | scenario | - | - |
| A second run on the same day writes `r2/`; `r1/` keeps its mtime and sha | FR-9 | boundary | scenario | - | - |
| A run on a later date starts at `r1` in a new date directory | FR-9 | boundary | scenario | - | - |
| The path contains no time of day, and a run from a worktree still writes under the primary checkout | FR-9 | normal | scenario | - | - |

---

## Mock / Stub Requirements

- A scratch branch with changes and a PR number for the no-argument and `#N` runs; an issue number for the invalid row.
