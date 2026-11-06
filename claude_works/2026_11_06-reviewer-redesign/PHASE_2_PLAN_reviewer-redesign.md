# Phase 2: reviewer-redesign - evidence template and contract

## Objective

Introduce the evidence form (GLOBAL AD-6): the template, the contract section that defines who writes it and what counts as evidence, and the producers that must write rows (coder, run-stage orchestrator). Start this work's own EVIDENCE.md with the phase 1 experiment rows.

## Requirements

- FR-8

---

## Prerequisites

- Phase 1 completed (its Notes hold the experiment records that become the first EVIDENCE rows).

---

## Scope

### In Scope
- `templates/EVIDENCE.md`, `_contract.md` Evidence section and Documents row, `_coder-base.md` and start-new Run stages references, this work's EVIDENCE.md.

### Out of Scope
- The reviewer writing its section (phase 3), round directory rules (phase 4), ledger and knowledge (phase 6).

---

## Instructions

### Step 1: Template

**Files**: `templates/EVIDENCE.md` (new)

**Action**: One table with the eight FR-8 columns (stage local/remote, behavior, data setup, command or action, result summary, raw output path, commit, author) and four sections `## coder`, `## orchestrator (run stages)`, `## verification session`, `## reviewer`. Add a one-line note that the reviewer section is used only in a round directory. No ALL-CAPS emphasis beyond the lint limit.

### Step 2: Contract

**Files**: `commands/_contract.md`

**Action**: Add a section "Evidence" stating: location `{working_directory}/{doc_dir}/EVIDENCE.md`; template `${CLAUDE_PLUGIN_ROOT}/templates/EVIDENCE.md`; who writes it (coder, run-stage orchestrator, verification sessions outside the dotclaude flow using the same form, reviewer); a row without a command and raw output is not evidence; a reviewer writes only to its round directory's EVIDENCE.md and reads `{doc_dir}/EVIDENCE.md` without writing it (AD-5); team PRs have no such file and CI results and PR-body test claims are read as claims. Add `EVIDENCE.md` to the Documents row in `_contract.md` Names and paths.

### Step 3: Producers

**Files**: `commands/_coder-base.md`, `commands/start-new.md`

**Action**: In `_coder-base.md` sections "3. Test first" and "4. Self-review" and the Report section, instruct the coder to write rows to the coder section of EVIDENCE.md, referring to "Contract: Evidence" without restating it. In start-new Run stages, the orchestrator writes one row per stage it ran, same reference.

### Step 4: This work's EVIDENCE.md

**Files**: `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md` (new)

**Action**: Create from the template and add the phase 1 experiment rows E1-E6 (copied from PHASE_1 Notes) with command, raw output path, commit and author.

---

## Implementation Notes

### Prompt budget
Keep the added Evidence section short; other files only refer to it by section name (GLOBAL Risk 3).

---

## Completion Checklist

- [x] The template has the eight FR-8 columns and the four author sections: verified in templates/EVIDENCE.md:7,5,10,15,20
- [x] Evidence states location, template path, writers, the no-command-no-evidence rule, the outside-flow verification form, and the reviewer round-directory rule: verified in commands/_contract.md:167-173
- [x] The Documents row lists `EVIDENCE.md`: verified in commands/_contract.md:94
- [x] The coder steps and Report point to "Contract: Evidence" without restating it: verified in commands/_coder-base.md:36,48,70
- [x] Run stages say the orchestrator writes one row per stage run, referring to "Contract: Evidence": verified in commands/start-new.md:62
- [x] E1-E6 rows exist in the new form: verified in claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md:9-14

---

## Verification

### Manual Verification
```bash
bash scripts/lint-prompts.sh
```

### Expected Output
```
exit 0 (rule i: every ${CLAUDE_PLUGIN_ROOT} path exists)
```

---

## Notes

- Evidence rows written by the reviewer in phases 3-6 land in round directories, not in this file's reviewer section.
- These rules come from the user decisions `evidence-raw-output-in-doc-dir` and `evidence-commit-filled-by-orchestrator` (2026-11-06) and from the phase 2 review (secrets redaction, commit wiring).
