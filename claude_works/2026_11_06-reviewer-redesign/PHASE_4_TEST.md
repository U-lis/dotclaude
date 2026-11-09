# Phase 4: Test Matrix

Verification is by running `/dotclaude:review` with the worktree plugin twice: once with no argument on a branch, once with `#3493`. Rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| With no argument and changes present, the command creates `{primary}/{WD}/reviews/{today}-{target}/r1/` with REVIEW.md, STATUS.md and EVIDENCE.md and prints REVIEW.md | FR-6 | normal | scenario | phase4-check N1, N2, V1, V3 (content; scenario run pending) | `commands/_contract.md:97`, `commands/review.md:25` |
| `#N` or a URL reviews that PR at PR depth, then triage, ask and act run as before; nothing is written to GitHub before the user answers and there is no offer to post | FR-6 | normal | scenario | phase4-check V4, V8, V10, V11 (content; scenario run pending) | `commands/review.md:34`, `commands/review.md:57` |
| `#N` that is an issue prints "#N is an issue, not a pull request" and stops without a review | FR-6 | invalid | scenario | phase4-check V9 (content; scenario run pending) | `commands/review.md:18` |
| A branch with no changes prints "Nothing to review." | FR-6 | boundary | scenario | phase4-check V9 (content; scenario run pending) | `commands/review.md:17` |
| The reviewer prompt contains the ledger path and the id prefix `{target}-r{n}`; after the run the ledger has `finding` lines with that prefix | FR-6 | normal | scenario | phase4-check V5, V6 (content; scenario run pending) | `commands/review.md:34` |
| A second run on the same day writes `r2/`; `r1/` keeps its mtime and sha | FR-9 | boundary | scenario | phase4-check N4 (content; scenario run pending) | `commands/_contract.md:103` |
| A run on a later date starts at `r1` in a new date directory | FR-9 | boundary | scenario | phase4-check N5 (content; scenario run pending) | `commands/_contract.md:103` |
| The path contains no time of day, and a run from a worktree still writes under the primary checkout | FR-9 | normal | scenario | phase4-check N1, N5, N6 (content; scenario run pending) | `commands/_contract.md:97`, `commands/_contract.md:103` |

---

## Mock / Stub Requirements

- A scratch branch with changes and a PR number for the no-argument and `#N` runs; an issue number for the invalid row.
