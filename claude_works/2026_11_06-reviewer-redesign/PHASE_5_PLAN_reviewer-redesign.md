# Phase 5: reviewer-redesign - phase-review and pre-integration wiring

## Objective

Wire the callers (GLOBAL AD-7): phase reviews call the reviewer with `Depth: phase`, the pre-integration full-diff review calls it with `Depth: pr` and a round directory, and `/dotclaude:pr` reuses a current review.

## Requirements

- FR-10
- NFR-4

---

## Prerequisites

- Phase 4 completed (round directory rules in `_contract.md`, PR-depth reviewer, template).

---

## Scope

### In Scope
- `commands/code.md`, `commands/start-new.md` (Step 10 and Run stages), `commands/pr.md` (9f and Review notes).

### Out of Scope
- Ledger lines, knowledge files and deferral handling in these files (phase 6).

---

## Instructions

### Step 1: Phase review caller

**Files**: `commands/code.md` (lines 30-31), `commands/start-new.md` (line 46, Step 10)

**Action**: The reviewer prompt gets `Depth: phase`, the ledger path (`{primary}/{working_directory}/review-ledger.log`) and the finding id prefix (`{doc_dir}-p{k}`). Keep the table appended under `## Phase {k}` in `{doc_dir}/REVIEW.md`, the `BLOCKERS: {n}` parse, and the single coder fix, validator run and re-review when Blockers > 0 (a phase with Blockers left is set `Blocked` and stops the chain).

### Step 2: Pre-integration review

**Files**: `commands/start-new.md` (line 66, Run stages full diff)

**Action**: Call the reviewer with `Depth: pr`, target, ticket key and a round directory created per `_contract.md` Names and paths. The `## Full diff` section of `{doc_dir}/REVIEW.md` holds a single pointer line `{round dir}/REVIEW.md (head {sha})`. The prompt also carries the ledger path (`{primary}/{working_directory}/review-ledger.log`) and the finding id prefix (`{target}-r{n}`).

### Ledger fields (all callers)

Every caller above passes the ledger path and the id prefix in the reviewer prompt (GLOBAL AD-8) so the reviewer appends its `finding` lines. The count check after the call is not added here; phase 6 adds it.

### Step 3: /dotclaude:pr

**Files**: `commands/pr.md` (step 9f and the Review notes rule)

**Action**: 9f computes the target and the ticket key, creates the round directory per `_contract.md` Names and paths, and calls the reviewer at `Depth: pr` passing target, ticket key, that path, the ledger path (`{primary}/{working_directory}/review-ledger.log`) and the finding id prefix (`{target}-r{n}`). Replace the existing skip rule in 9f with: skip a new reviewer call when the latest round's STATUS.md `head` equals HEAD, where the latest round is the highest `r{n}` under the most recent `reviews/*-{target}` directory. Review notes are built from the PR-depth report's issue rows, keeping `file:line`, ordered Blocker, Major, Minor. Keep today's carry-over (SPEC NFR-4): Review notes also include the Major and Minor rows from phase reviews in `{doc_dir}/REVIEW.md` that the PR-depth report does not already list (same location and finding).

---

## Implementation Notes

### Unchanged behavior (NFR-4)
Commit guard marker `.validated/PHASE_{k}`, the `BLOCKERS: {n}` parsing, one Blocker-fix attempt per phase, and the PR comment steps stay as they are.

---

## Completion Checklist

- [x] The reviewer prompt in the phase-review step carries `Depth: phase`: verified in commands/code.md:30
- [x] Step 10 reviewer prompt carries `Depth: phase`: verified in commands/start-new.md:46
- [x] Run stages full-diff review uses `Depth: pr` with target, ticket key and a round directory, and writes the `## Full diff` pointer line: verified in commands/start-new.md:67
- [x] 9f computes target and ticket key, creates the round directory per Contract: Names and paths, and passes target, ticket key and the path to the `Depth: pr` call: verified in commands/pr.md:68
- [x] 9f skips when the STATUS.md `head` of the highest `r{n}` under the most recent `reviews/*-{target}` directory equals HEAD, and the old skip rule is gone: verified in commands/pr.md:68
- [x] Review notes list PR-depth issue rows with `file:line`, ordered Blocker, Major, Minor: verified in commands/pr.md:69
- [x] Review notes keep the carry-over of Major and Minor rows from phase reviews in `{doc_dir}/REVIEW.md` not already in the PR-depth report (same location and finding): verified in commands/pr.md:69
- [x] Each reviewer prompt (phase review, Step 10, Run stages full diff, 9f) carries the ledger path and the id prefix (`{doc_dir}-p{k}` or `{target}-r{n}`): verified in commands/code.md:30, start-new.md:46,67, pr.md:68
- [x] The `BLOCKERS: {n}` parse and the single-fix rule are unchanged: verified in commands/code.md:30-31

---

## Verification

### Manual Verification
```bash
bash tests/hooks/run_all.sh
bash scripts/lint-prompts.sh
# worktree plugin: one /dotclaude:code {k} on a scratch work; one /dotclaude:pr up to 9f
```

### Expected Output
```
ALL PASSED
lint exits 0; EVIDENCE.md rows recorded for both runs; see PHASE_5_TEST.md
```

---

## Notes

- Verification rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.
