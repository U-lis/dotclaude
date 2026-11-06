# Phase 4: reviewer-redesign - review part of /dotclaude:review

## Objective

Make `/dotclaude:review` run the reviewer at PR depth against a round directory (GLOBAL AD-4), keeping the existing comment-triage steps and removing the offer to post the table.

## Requirements

- FR-6
- FR-9

---

## Prerequisites

- Phase 3 completed (PR-depth reviewer and template).

---

## Scope

### In Scope
- `commands/review.md` edits at lines 7, 11, 23-25, 34, 57; the round-directory row and `{target}`/`r{n}` rules in `commands/_contract.md` Names and paths.

### Out of Scope
- Phase and pre-integration wiring (phase 5), ledger and dispositions (phase 6).

---

## Instructions

### Step 1: Names and paths

**Files**: `commands/_contract.md` (Names and paths section)

**Action**: Add a row for the round directory `{primary}/{WD}/reviews/{YYYY_MM_DD}-{target}/r{n}/` with fixed file names `REVIEW.md`, `STATUS.md`, `EVIDENCE.md` plus `.log` outputs. State the `{target}` order (Jira key in PR title, same pattern in head branch, `pr-{N}`, branch keyword), the `n` rule (1 + highest existing `r*` that day, created by the orchestrator with `mkdir -p`), that the date part carries no time of day, that worktree runs still use the primary checkout, and that the reviewer reads only its own round. Define once here; other files refer to it.

### Step 2: review command

**Files**: `commands/review.md`

**Action**: Lines 7 and 11: language note updated for the PR-depth report. Lines 23-25: no-argument mode reviews the current branch at PR depth. Line 34: step 2 Review computes the round directory, creates it, calls the reviewer with `Depth: pr`, target, ticket key and the round directory, plus the ledger path (`{primary}/{working_directory}/review-ledger.log`) and the finding id prefix (`{target}-r{n}`) so the reviewer can append its `finding` lines (GLOBAL AD-8; the count check after the call is added in phase 6), then prints the round REVIEW.md. Line 57: remove edge case 2's offer to post the table. Keep the "#N is an issue, not a pull request" message and "Nothing to review.". Steps 3-9 (triage, ask, act) stay as they are; nothing is written to GitHub before the user answers.

---

## Implementation Notes

### Independence
The command must not pass previous round paths or findings to the reviewer; the reviewer judges the current code anew.

---

## Completion Checklist

- [ ] The round-directory row and the `{target}` and `n` rules exist once in Names and paths, with no time of day and primary-checkout rule: `commands/_contract.md`
- [ ] No-argument mode and `#N`/URL mode call the reviewer with `Depth: pr` and a freshly created round directory, then print REVIEW.md: `commands/review.md`
- [ ] The prompt passes target, ticket key, round directory, the ledger path and the id prefix `{target}-r{n}`, never earlier rounds or intent text: `commands/review.md`
- [ ] The offer to post the reviewer table is removed: `commands/review.md`
- [ ] The issue-not-PR message and "Nothing to review." are retained: `commands/review.md`
- [ ] Steps 3-9 are unchanged in behavior and nothing is written to GitHub before the user answers: `commands/review.md`

---

## Verification

### Manual Verification
```bash
bash scripts/lint-prompts.sh
# worktree plugin (E1 method): /dotclaude:review on a branch with no argument, and /dotclaude:review #3493
```

### Expected Output
```
lint exits 0; EVIDENCE.md rows recorded for both runs; see PHASE_4_TEST.md
```

---

## Notes

- Verification rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.
