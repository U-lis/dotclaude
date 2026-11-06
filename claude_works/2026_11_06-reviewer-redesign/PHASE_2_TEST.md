# Phase 2: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| The template carries the eight columns and four author sections, and `scripts/lint-prompts.sh` exits 0 with the template path resolving | FR-8 | normal | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R1 | `templates/EVIDENCE.md:5,10,15,20`, `commands/_contract.md:169` |
| An EVIDENCE row without a command or raw output path is defined by the contract as not evidence | FR-8 | invalid | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R2 | `commands/_contract.md:171` |
| An evidence row whose commit differs from the head under review is defined as stale evidence | FR-8 | boundary | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R3 | `commands/_contract.md:175` |
| This work's EVIDENCE.md holds E1-E6 rows each with command, raw output path, commit and author | FR-8 | normal | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R4 | EVIDENCE.md:9-14 in this work's doc dir |
| Coder and Run stages instructions refer to the Evidence section instead of restating its rules | FR-8 | normal | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R5 | `commands/_coder-base.md:36,48,70`, `commands/start-new.md:62`, `commands/_contract.md:94` |
| Raw outputs are `.log` files under `{working_directory}/{doc_dir}/evidence/` (a reviewer's under its round directory), never a temporary or session path, and the raw output path is repository-relative | FR-8 | normal | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R6 | `commands/_contract.md:172` |
| A row written before the phase commit carries `phase {k} (uncommitted)`; the orchestrator replaces it with the commit hash right after the phase commit | FR-8 | boundary | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R7 | `commands/_contract.md:173` |
| The phase-commit row of the Commits table lists EVIDENCE.md and evidence/*.log, the replaced hash is committed with the next phase's commit or the docs commit, and `code.md` step 6 and the start-new phase-commit step refer to Contract: Evidence | FR-8 | normal | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R8 | `commands/_contract.md:160,173`, `commands/code.md:31`, `commands/start-new.md:47` |
| Secrets are redacted from raw output before it is saved | FR-8 | invalid | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R9 | `commands/_contract.md:174` |
| No Command cell of this work's phase 2 evidence rows contains a session path | FR-8 | boundary | scenario | `claude_works/2026_11_06-reviewer-redesign/evidence/phase2-check.sh.log`::R10 | EVIDENCE.md phase 2 rows in this work's doc dir |

---

## Mock / Stub Requirements

- None. Verification is a reading and lint check of the prompt files.
