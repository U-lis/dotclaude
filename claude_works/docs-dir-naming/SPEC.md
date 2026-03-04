<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-docs-dir-naming
-->

# Documentation Directory Date-Prefixed Naming - Specification

## GitHub Issue

- Issue: https://github.com/U-lis/dotclaude/issues/50
- Target Version: 0.4.0

## Overview

Currently, documentation directories use the format `{working_directory}/{subject}/SPEC.md`, which makes it difficult to determine when the work was performed. By adding a date prefix in `yyyy_mm_dd` format, directories become chronologically sortable and the work timeline is immediately visible.

### Problem

- `{working_directory}/{keyword}/` format provides no temporal context
- With 30+ existing directories, finding recent work requires checking git history
- Alphabetical sorting does not reflect work chronology

### Solution

- Change directory naming to `{working_directory}/{yyyy_mm_dd}-{keyword}/` format
- Introduce a new variable `{doc_dir}` = `{yyyy_mm_dd}-{subject}` for directory paths only
- Keep `{subject}` variable unchanged for branch names and commit messages
- Provide migration support for existing directories

## Functional Requirements

- [ ] FR-1: Change documentation directory naming from `{working_directory}/{subject}/` to `{working_directory}/{doc_dir}/` where `{doc_dir}` = `{yyyy_mm_dd}-{subject}`
- [ ] FR-2: Introduce new variable `{doc_dir}` that combines date prefix and subject, used exclusively for directory paths
- [ ] FR-3: Maintain `{subject}` variable unchanged -- it continues to be used for branch names (in `templates/PHASE_MERGE.md`) and commit messages
- [ ] FR-4: Use local timezone date in `yyyy_mm_dd` format (e.g., `2026_02_25`)
- [ ] FR-5: Support migration of existing date-less directories to the new `{yyyy_mm_dd}-{keyword}/` format

## Non-Functional Requirements

- [ ] NFR-1: No special performance requirements -- date generation is a trivial operation
- [ ] NFR-2: No special security requirements
- [ ] NFR-3: Follow existing codebase patterns for variable substitution and directory creation

## Affected Files

### Related Code

| # | File | Line(s) | Current Behavior | Required Change |
|---|------|---------|------------------|-----------------|
| 1 | `commands/_init-common.md` | 34 | `mkdir -p {working_directory}/{subject}` | Change to `mkdir -p {working_directory}/{doc_dir}` |
| 2 | `commands/start-new.md` | Multiple | References `{working_directory}/{subject}/` paths | Change all directory path references to `{working_directory}/{doc_dir}/` |
| 3 | `commands/code.md` | 203, 243, 256, 264 | References PLAN/GLOBAL file paths | Update path references to use `{doc_dir}` |
| 4 | `commands/design.md` | 20, 43, 80 | References SPEC file path | Update path references to use `{doc_dir}` |
| 5 | `commands/validate-spec.md` | 20-21 | Document validation paths | Update path references to use `{doc_dir}` |
| 6 | `commands/update-docs.md` | 31 | SPEC reference path | Update path references to use `{doc_dir}` |
| 7 | `commands/init-feature.md` | 227-228 | Output path references | Update path references to use `{doc_dir}` |
| 8 | `commands/init-bugfix.md` | 259-260 | Output path references | Update path references to use `{doc_dir}` |
| 9 | `commands/init-refactor.md` | 242-243 | Output path references | Update path references to use `{doc_dir}` |
| 10 | `agents/designer.md` | 34 | Agent path reference | Update path references to use `{doc_dir}` |
| 11 | `agents/spec-validator.md` | 26, 68 | Agent path reference | Update path references to use `{doc_dir}` |
| 12 | `templates/PHASE_MERGE.md` | Multiple | Uses `{subject}` for branch names | NO CHANGE -- `{subject}` remains for branch names |
| 13 | `README.md` | 192 | Directory structure documentation | Update to reflect new naming convention |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | `{subject}` serves as both directory name and branch name | Directory name needs date prefix, branch name must not change | Introduce new variable `{doc_dir}` = `{yyyy_mm_dd}-{subject}` for directory paths only. `{subject}` remains unchanged for branch names and commit messages. |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Same keyword used on different dates | No directory collision -- different dates produce different `{doc_dir}` values (e.g., `2026_02_25-auth` vs `2026_02_26-auth`) |
| 2 | Existing date-less directories (30+) | Migration script converts them in bulk to `{yyyy_mm_dd}-{keyword}/` format |
| 3 | Timezone difference causes date mismatch | Local timezone is used consistently; UTC option is out of scope |
| 4 | Workflow resume needs path matching | SPEC.md metadata stores `doc_dir` value so downstream commands can resolve the correct directory path |

## Constraints

- MUST follow existing codebase patterns for variable handling and directory creation
- `{subject}` variable MUST NOT be modified -- it is used for branch names (`templates/PHASE_MERGE.md`) and commit messages
- Date format is fixed as `yyyy_mm_dd` (e.g., `2026_02_25`) -- no customization
- `{doc_dir}` is derived from `{subject}`: `{doc_dir}` = `{yyyy_mm_dd}-{subject}`

## Out of Scope

- Date format customization (fixed as `yyyy_mm_dd`)
- UTC timezone configuration option (local timezone only)
- Renaming `{subject}` variable itself
- Changes to branch naming conventions
