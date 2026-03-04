# Documentation Directory Date-Prefixed Naming - Global Documentation

## Feature Overview

### Purpose

Add date prefix to documentation directory names so that directories are chronologically sortable and the work timeline is immediately visible.

### Problem

- `{working_directory}/{subject}/` format provides no temporal context
- With 30+ existing directories, finding recent work requires checking git history
- Alphabetical sorting does not reflect work chronology

### Solution

- Introduce a new variable `{doc_dir}` = `$(date +%Y_%m_%d)-{subject}` for directory paths only
- Change directory creation to `mkdir -p {working_directory}/{doc_dir}`
- Keep `{subject}` unchanged for branch names and commit messages
- Store `{doc_dir}` in SPEC.md metadata for downstream command path resolution

## Architecture Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| AD-1 | Introduce `{doc_dir}` as new variable, keep `{subject}` intact | `{subject}` is used for branch names and commit messages -- changing it would affect git operations |
| AD-2 | Generate `{doc_dir}` in `_init-common.md` at directory creation time | Single point of directory creation -- all init commands flow through `_init-common.md` |
| AD-3 | Store `{doc_dir}` in SPEC.md metadata block | Downstream commands (`design`, `code`, `validate-spec`, `update-docs`) read metadata for path resolution |
| AD-4 | Use `date +%Y_%m_%d` shell command for local timezone date | Simplest portable approach; no external dependencies |
| AD-5 | Replace `{working_directory}/{subject}/` with `{working_directory}/{doc_dir}/` ONLY in directory path contexts | Commit messages and branch names must keep `{subject}` unchanged |
| AD-6 | Replace hardcoded `claude_works/{subject}/` examples with `claude_works/{doc_dir}/` | Consistency between variable-based and hardcoded path references |
| AD-7 | No changes to `templates/PHASE_MERGE.md` | This template uses `{subject}` exclusively for branch naming, not directory paths |

## Data Model

### New Variable

```
{doc_dir} = $(date +%Y_%m_%d)-{subject}
```

- Generated once at directory creation time in `_init-common.md`
- Stored in SPEC.md metadata block as `doc_dir: {value}`
- Used by all downstream commands to resolve documentation directory paths

### SPEC.md Metadata Block (Updated)

```html
<!-- dotclaude-config
working_directory: {resolved_value}
base_branch: {resolved_value}
language: {resolved_value}
worktree_path: ../{project_name}-{type}-{keyword}
doc_dir: {yyyy_mm_dd}-{subject}
-->
```

### Path Resolution Pattern

| Context | Variable Used | Example |
|---------|---------------|---------|
| Documentation directory path | `{doc_dir}` | `claude_works/2026_02_25-auth/SPEC.md` |
| Branch name | `{subject}` | `feature/auth` |
| Commit message | `{subject}` | `docs: add SPEC.md for auth` |
| Worktree path | `{subject}` (via keyword) | `../dotclaude-feature-auth` |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Core Variable Introduction and Path Updates | Complete | None |
| 2 | Migration Support and Documentation | Complete | Phase 1 |

## File Structure

### Files to Modify

#### Phase 1: Core Variable Introduction and Path Updates (12 files)

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `commands/_init-common.md` | Modify | Add `{doc_dir}` generation step; change `mkdir` path |
| 2 | `commands/start-new.md` | Modify | Add `doc_dir` to SPEC.md metadata; replace directory path references |
| 3 | `commands/design.md` | Modify | Replace 3 directory path references |
| 4 | `commands/code.md` | Modify | Replace 3 directory path references |
| 5 | `commands/validate-spec.md` | Modify | Replace 2 directory path references |
| 6 | `commands/update-docs.md` | Modify | Replace 1 directory path reference |
| 7 | `commands/init-feature.md` | Modify | Replace 2 directory path references in output section |
| 8 | `commands/init-bugfix.md` | Modify | Replace 2 directory path references in output section |
| 9 | `commands/init-refactor.md` | Modify | Replace 2 directory path references in output section |
| 10 | `agents/designer.md` | Modify | Replace 1 directory path reference |
| 11 | `agents/spec-validator.md` | Modify | Replace 2 directory path references |
| 12 | `README.md` | Modify | Update directory structure example |

#### Phase 2: Migration Support and Documentation (2 files)

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `commands/_init-common.md` | Modify | Add migration guidance section |
| 2 | `README.md` | Modify | Add `{doc_dir}` convention explanation subsection |

### Files NOT Modified

| File | Reason |
|------|--------|
| `templates/PHASE_MERGE.md` | Uses `{subject}` for branch naming only -- no directory path references |
