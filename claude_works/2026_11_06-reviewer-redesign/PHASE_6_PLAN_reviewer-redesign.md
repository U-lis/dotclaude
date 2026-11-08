# Phase 6: reviewer-redesign - ledger, knowledge records, dispositions, settings

## Objective

Add the review ledger contract, knowledge records and finding-disposition rules (GLOBAL AD-8), the two settings, the command-side ledger work (count check and `disposition` lines; the reviewer itself appends `finding` lines since phase 3), and the reviewer's bounded reading rules (NFR-5).

## Requirements

- FR-11
- FR-12
- FR-13
- FR-14
- NFR-5

---

## Prerequisites

- Phases 3-5 completed (reviewer, `/dotclaude:review`, callers).

---

## Scope

### In Scope
- `_contract.md` configuration rows and three new sections; `configure.md`; reviewer knowledge search, deferred re-check and read limits; ledger/knowledge/deferral handling in `review.md`, `code.md`, `start-new.md`, `pr.md`.

### Out of Scope
- A retrospective command, automatic comparison between rounds, `hooks/workspace-archive.sh` changes (the archive test was added in phase 1).

---

## Instructions

### Step 1: Contract

**Files**: `commands/_contract.md`

**Action**: Configuration table: add `review.intent_tools` (default `["*jira*","*atlassian*","*notion*"]`) and `knowledge_dirs` (default `[]`). Add sections "Review ledger" (path `{primary}/{WD}/review-ledger.log`, tab-separated append-only events `finding` and `disposition` with the fields in GLOBAL Data Model, `finding` lines appended by the reviewer and `disposition` lines by commands, both with `printf ... >>`, the reviewer never reading or rewriting the ledger, never edited, a changed disposition is a new line, finding id forms, and the command's count check: `finding` lines with the review's id prefix equal the report's `issue` rows, a mismatch is reported to the user and the ledger is not fixed), "Knowledge records" (inputs `knowledge_dirs` and `{primary}/{WD}/knowledge/`, one file per record `{date}-{target}-{n}.md` with one fact line, `file:line`, confirmed commit, source review; no index; targeted search only; stale marking; commands write candidates from "새로 알게 된 것" without asking) and "Finding dispositions" (accepted/deferred/rebutted/ignored; deferral needs a repro result and class; silent omissions cannot be deferred and must be guarded with an error; loud failures may be deferred and are listed in `## Deferred` of `{doc_dir}/REVIEW.md` with finding id, repro command and output path, class; loud verdict only after all input shapes were checked; no PR body change).

### Step 2: Configure command

**Files**: `commands/configure.md`

**Action**: Add both keys to the Step 3c list (lines 34-43) and the Step 5 key list (line 65); saved as JSON arrays.

### Step 3: Reviewer reading rules

**Files**: `agents/reviewer.md`

**Action**: Add: knowledge search with changed paths and symbols over `knowledge_dirs` and `{primary}/{WD}/knowledge/`, reading only matches, marking records whose path changed after the confirmed commit as "오래됨" and not citing them; re-check of each `## Deferred` item by reproducing it and judging the class again; read limits (own round only, never the ledger, nothing under `reviews/` outside its round, no EVIDENCE row whose commit differs from head: report as stale).

### Step 4: Callers

**Files**: `commands/review.md`, `commands/code.md` (line 30), `commands/start-new.md` (lines 46, 66), `commands/pr.md` (line 68)

**Action**: Commands do not append `finding` lines (the reviewer does, phase 3). After each reviewer call run the count check from Contract: Review ledger (the number of `finding` lines carrying this review's id prefix equals the number of `issue` rows in the report; on mismatch report the difference to the user and leave the ledger untouched) and write knowledge files for the report's candidates. `review.md` step 4 appends a `disposition` line when the user states a disposition in the session. `code.md` handles deferrals through `## Deferred` (phase findings).

---

## Implementation Notes

### Prompt budget
Each rule is defined only in `_contract.md`; callers reference it by section name (GLOBAL Risk 3).

### Purge
No change to `hooks/workspace-archive.sh`; the top-level ledger is never a candidate (GLOBAL AD-8) and phase 1 pins this.

---

## Completion Checklist

- [x] The Configuration table has `review.intent_tools` and `knowledge_dirs` with the stated defaults: verified in `commands/_contract.md`
- [x] "Review ledger" defines path, event fields, append-only writing (reviewer for `finding`, commands for `disposition`), new line for changed disposition, finding id forms, and the count check with its mismatch handling: verified in `commands/_contract.md`
- [x] "Knowledge records" defines inputs, file naming and fields, no index, targeted search, stale marking, candidate writing without asking: verified in `commands/_contract.md`
- [x] "Finding dispositions" defines the four dispositions, repro and class for deferral, the silent-vs-loud rule, `## Deferred` rows, no PR body change: verified in `commands/_contract.md`
- [x] Both keys are offered and saved as JSON arrays: verified in `commands/configure.md`
- [x] Reviewer rules: targeted knowledge search, stale marking, deferred re-check, read limits (own round only, no ledger, no stale evidence rows): verified in `agents/reviewer.md`
- [x] Callers run the finding-line count check after each reviewer call (report mismatch, never edit the ledger), append no `finding` lines, and write knowledge files: verified in commands/review.md:34, commands/code.md:30, commands/start-new.md:46, commands/pr.md:68
- [x] Step 4 of review appends `disposition` lines for dispositions stated in the session: verified in `commands/review.md`
- [x] Phase deferrals go to `## Deferred` of `{doc_dir}/REVIEW.md`: verified in `commands/code.md`

---

## Verification

### Manual Verification
```bash
bash scripts/lint-prompts.sh
bash tests/hooks/run_all.sh
# worktree plugin: run #3493 as round 2 and state one disposition in the session
sha256sum review-ledger.log   # before/after: old prefix identical
```

### Expected Output
```
lint exits 0 under 220000 bytes; ALL PASSED; see PHASE_6_TEST.md
```

---

## Notes

- Verification rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.
- Phase 1 checklist already pins that `review.intent_tools` in config changes what `guard-review.sh` denies.
