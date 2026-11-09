# Phase 6: Test Matrix

Verification is by running #3493 as round 2 with the worktree plugin and recording one disposition the user states in the session. Rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Planted knowledge records unrelated to the change are not read by the reviewer | FR-11 | boundary | scenario | evidence/phase6-check.sh.log N3 R1 (content); scenario run pending | agents/reviewer.md:71; commands/_contract.md:202 |
| A planted record whose cited path changed after its confirmed commit is shown as "오래됨" and not cited as fact | FR-11 | boundary | scenario | evidence/phase6-check.sh.log N4 R2 (content); scenario run pending | agents/reviewer.md:71; commands/_contract.md:202 |
| The reviewer greps `knowledge_dirs` and `{primary}/{WD}/knowledge/` for changed paths and symbols and reads only matches; candidates are written as `{date}-{target}-{n}.md` with fact, `file:line`, commit and source review | FR-11 | normal | scenario | evidence/phase6-check.sh.log N1 N2 N5 R1 X1 X4 X5 (content); scenario run pending | commands/_contract.md:202; commands/_contract.md:204; agents/reviewer.md:71 |
| After a review the ledger holds one tab-separated `finding` line per report issue row with all ten fields, written by the reviewer (phase 3) and not by the command; earlier lines stay byte-identical (sha256 of old prefix); the command's count check passes silently | FR-12 | normal | scenario | evidence/phase6-check.sh.log L1-L7 R6 X9 (content); scenario run pending | commands/_contract.md:193; commands/_contract.md:196; agents/reviewer.md:116 |
| The count of `finding` lines with the review's id prefix differs from the report's issue rows (one line removed from a scratch copy): the command reports the difference to the user, and the ledger sha256 is unchanged by the command | FR-12 | error | scenario | evidence/phase6-check.sh.log L8 X1-X5 (content); scenario run pending | commands/_contract.md:198; commands/code.md:30; commands/start-new.md:46; commands/start-new.md:67; commands/pr.md:68; commands/review.md:34 |
| A disposition stated in the session appends a `disposition` line; changing it appends another and leaves the old line | FR-12 | normal | scenario | evidence/phase6-check.sh.log L3 L6 X6 (content); scenario run pending | commands/_contract.md:194; commands/review.md:45 |
| A deferral without repro and class, or of a silent omission, is not accepted and stays an open finding | FR-13 | invalid | scenario | evidence/phase6-check.sh.log D2 D3 D7 (content); scenario run pending | commands/_contract.md:208 |
| A loud deferral is recorded under `## Deferred` with evidence; the PR body does not change; the PR-depth review reproduces each deferred item and judges its class again | FR-13 | normal | scenario | evidence/phase6-check.sh.log D4 D5 D6 R3 X7 X8 (content); scenario run pending | commands/_contract.md:208; commands/code.md:30; agents/reviewer.md:81; commands/_agent-prompts.md:112 |
| `/dotclaude:configure` offers `review.intent_tools` and `knowledge_dirs` and saves them as JSON arrays; the Configuration table documents both | FR-14 | normal | scenario | evidence/phase6-check.sh.log C1 C2 G1 G2 (content); scenario run pending | commands/configure.md:44; commands/configure.md:66; commands/_contract.md:36; commands/_contract.md:37 |
| The reviewer transcript shows no Read of the ledger and no Read under `reviews/` outside its own round (including `r1/` when running `r2`) | NFR-5 | boundary | scenario | evidence/phase6-check.sh.log R4 (content); scenario run pending | agents/reviewer.md:46 |
| An EVIDENCE row whose commit differs from head is not read and is reported as stale | NFR-5 | boundary | scenario | evidence/phase6-check.sh.log R5 (content); scenario run pending | agents/reviewer.md:79 |
| An untracked top-level `review-ledger.log` over 100KB stays in place after purge archive; pinned by `tests/hooks/test_workspace_archive.sh` added in phase 1 (no new test in phase 6) | FR-12 | boundary | scenario | tests/hooks/test_workspace_archive.sh (phase 1) | - |
| `scripts/lint-prompts.sh` exits 0 with the total under 220000 bytes and `bash tests/hooks/run_all.sh` prints `ALL PASSED` | NFR-5 | normal | integration | evidence/phase6-check.sh.log U2; evidence/phase6-lint.log; evidence/phase6-hooks.log | scripts/lint-prompts.sh:16; scripts/lint-prompts.sh:66 |

---

## Mock / Stub Requirements

- Planted knowledge records (one unrelated, one stale) in a scratch `knowledge_dirs` and `{WD}/knowledge/`.
- An existing ledger from the phase 3-5 runs to check the old-prefix sha256.
