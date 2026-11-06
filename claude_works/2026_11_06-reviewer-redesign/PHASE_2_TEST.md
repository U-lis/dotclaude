# Phase 2: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| The template carries the eight columns and four author sections, and `scripts/lint-prompts.sh` exits 0 with the template path resolving | FR-8 | normal | scenario | - | - |
| An EVIDENCE row without a command or raw output path is defined by the contract as not evidence | FR-8 | invalid | scenario | - | - |
| An evidence row whose commit differs from the head under review is defined as stale evidence | FR-8 | boundary | scenario | - | - |
| This work's EVIDENCE.md holds E1-E6 rows each with command, raw output path, commit and author | FR-8 | normal | scenario | - | - |
| Coder and Run stages instructions refer to the Evidence section instead of restating its rules | FR-8 | normal | scenario | - | - |

---

## Mock / Stub Requirements

- None. Verification is a reading and lint check of the prompt files.
