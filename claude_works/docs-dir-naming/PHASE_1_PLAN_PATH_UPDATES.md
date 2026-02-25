# Phase 1: Core Variable Introduction and Path Updates

## Objective

Introduce the `{doc_dir}` variable and update all directory path references across 12 files so that documentation directories use date-prefixed naming (`{yyyy_mm_dd}-{subject}`) while preserving `{subject}` for branch names and commit messages.

## Prerequisites

- SPEC.md approved and committed
- Feature branch created

## Instructions

### 1.1: Add date generation step in `_init-common.md`

**File**: `commands/_init-common.md`
**Location**: Branch Creation > Steps section (between current steps 5 and 6, around line 33-34)

Add a new step after "Change into worktree directory" (step 5) and before the `mkdir` step (step 6):

Insert a step that generates the `{doc_dir}` variable:
```
6. Generate doc_dir: `DOC_DIR="$(date +%Y_%m_%d)-{subject}"` (local timezone)
```

This step MUST come before the `mkdir` step so the generated value can be used in the directory path.

### 1.2: Change `mkdir` path in `_init-common.md`

**File**: `commands/_init-common.md`
**Location**: Line 34 (current step 6)

Change:
```
6. Create project directory: `mkdir -p {working_directory}/{subject}`
```
To:
```
7. Create project directory: `mkdir -p {working_directory}/{doc_dir}`
```

Note: Step numbering shifts by 1 due to the new step added in 1.1.

### 1.3: Add `doc_dir` to SPEC.md metadata block template in `start-new.md`

**File**: `commands/start-new.md`
**Location**: Lines 24-31 (SPEC.md Configuration Metadata section)

Add `doc_dir` field to the metadata block template. Change:
```html
<!-- dotclaude-config
working_directory: {resolved_value}
base_branch: {resolved_value}
language: {resolved_value}
worktree_path: ../{project_name}-{type}-{keyword}
-->
```
To:
```html
<!-- dotclaude-config
working_directory: {resolved_value}
base_branch: {resolved_value}
language: {resolved_value}
worktree_path: ../{project_name}-{type}-{keyword}
doc_dir: {doc_dir}
-->
```

### 1.4: Add documentation about `{doc_dir}` storage in `start-new.md`

**File**: `commands/start-new.md`
**Location**: After the metadata block template (around line 33)

Add a sentence explaining that `{doc_dir}` is stored in metadata:

```
Downstream commands read this metadata to resolve `{working_directory}`, `{worktree_path}`, `{doc_dir}`, and other config values. If they cannot find SPEC.md, they fall back to default values (`worktree_path` defaults to `.`, `doc_dir` defaults to `{subject}`).
```

This replaces the current sentence at line 33 that only mentions `{working_directory}` and `{worktree_path}`.

### 1.5: Replace directory path references in `start-new.md`

**File**: `commands/start-new.md`

Replace ALL occurrences of `{working_directory}/{subject}/` with `{working_directory}/{doc_dir}/` in directory path contexts ONLY. Do NOT change `{subject}` in commit messages.

Specific locations to update:

| Line | Current | New | Context |
|------|---------|-----|---------|
| 148 | `../{project_name}-{type}-{keyword}/{working_directory}/{subject}` | `../{project_name}-{type}-{keyword}/{working_directory}/{doc_dir}` | Post-Init Verification check 3 |
| 183 | `git add {working_directory}/{subject}/SPEC.md` | `git add {working_directory}/{doc_dir}/SPEC.md` | Step 4: Commit SPEC.md |
| 184 | `git commit -m "docs: add SPEC.md for {subject}"` | Keep unchanged | Commit message uses `{subject}` |
| 210 | `{working_directory}/{subject}/SPEC.md` must exist | `{working_directory}/{doc_dir}/SPEC.md` must exist | Step 6 Checkpoint SPEC.md Check |
| 215 | `git log --oneline -1 -- {working_directory}/{subject}/SPEC.md` | `git log --oneline -1 -- {working_directory}/{doc_dir}/SPEC.md` | Step 6 Checkpoint SPEC.md Committed Check |
| 234 | `spec_path: "{working_directory}/{subject}/SPEC.md"` | `spec_path: "{working_directory}/{doc_dir}/SPEC.md"` | Step 6: Designer input |
| 244 | `target_dir: "{working_directory}/{subject}/"` | `target_dir: "{working_directory}/{doc_dir}/"` | Step 7: TechnicalWriter input |
| 250 | `git add {working_directory}/{subject}/*.md` | `git add {working_directory}/{doc_dir}/*.md` | Step 8: Commit Design Documents |
| 251 | `git commit -m "docs: add design documents for {subject}"` | Keep unchanged | Commit message uses `{subject}` |
| 270 | `plan_path: "{working_directory}/{subject}/PHASE_{k}_PLAN_*.md"` | `plan_path: "{working_directory}/{doc_dir}/PHASE_{k}_PLAN_*.md"` | Step 10: Coder input |

Also update all occurrences in Subagent Call Patterns section and Output Contract section:
- `claude_works/{subject}/SPEC.md` -> `claude_works/{doc_dir}/SPEC.md`
- `claude_works/{subject}/` -> `claude_works/{doc_dir}/`
- `{working_directory}/{subject}/` -> `{working_directory}/{doc_dir}/` (in path contexts only)

IMPORTANT: Preserve `{subject}` in ALL commit messages (lines 184, 251, and any `git commit -m` patterns).

### 1.6: Replace hardcoded example paths in `start-new.md`

**File**: `commands/start-new.md`

Search for all `claude_works/{subject}/` patterns used as example paths and replace with `claude_works/{doc_dir}/`. These appear in:
- Subagent Call Patterns section (lines ~477, ~499, ~507, ~548)
- Output Contract section (line ~910)
- Verification section (lines ~437-438)
- Final Summary Report section (line ~960)

### 1.7: Replace directory path references in `design.md`

**File**: `commands/design.md`

3 occurrences to update:

| Line | Current | New |
|------|---------|-----|
| 20 | `{working_directory}/{subject}/SPEC.md` exists | `{working_directory}/{doc_dir}/SPEC.md` exists |
| 43 | `git add {working_directory}/{subject}/*.md` | `git add {working_directory}/{doc_dir}/*.md` |
| 80 | `{working_directory}/{subject}/` | `{working_directory}/{doc_dir}/` |

### 1.8: Replace directory path references in `code.md`

**File**: `commands/code.md`

3 occurrences to update:

| Line | Current | New |
|------|---------|-----|
| 203 | `{working_directory}/{subject}/` | `{working_directory}/{doc_dir}/` |
| 256 | `{working_directory}/{subject}/GLOBAL.md` | `{working_directory}/{doc_dir}/GLOBAL.md` |
| 264 | `{working_directory}/{subject}/PHASE_*_PLAN_*.md` | `{working_directory}/{doc_dir}/PHASE_*_PLAN_*.md` |

Note: There are additional occurrences throughout the file in contexts like PLAN path references, GLOBAL.md reads, etc. Search for ALL `{working_directory}/{subject}/` and `{subject}/PHASE_` and `{subject}/GLOBAL` patterns and replace the directory path portion with `{doc_dir}`.

### 1.9: Replace directory path references in `validate-spec.md`

**File**: `commands/validate-spec.md`

2 occurrences to update:

| Line | Current | New |
|------|---------|-----|
| 20 | `{working_directory}/{subject}/SPEC.md` exists | `{working_directory}/{doc_dir}/SPEC.md` exists |
| 21 | `{working_directory}/{subject}/GLOBAL.md` exists | `{working_directory}/{doc_dir}/GLOBAL.md` exists |

### 1.10: Replace directory path reference in `update-docs.md`

**File**: `commands/update-docs.md`

1 occurrence to update:

| Line | Current | New |
|------|---------|-----|
| 31 | `Read {working_directory}/{subject}/SPEC.md for context` | `Read {working_directory}/{doc_dir}/SPEC.md for context` |

### 1.11: Replace directory path references in `init-feature.md`

**File**: `commands/init-feature.md`

2 occurrences in Output section to update:

| Line | Current | New |
|------|---------|-----|
| 227 | `Directory {working_directory}/{subject}/ created` | `Directory {working_directory}/{doc_dir}/ created` |
| 228 | `{working_directory}/{subject}/SPEC.md created` | `{working_directory}/{doc_dir}/SPEC.md created` |

### 1.12: Replace directory path references in `init-bugfix.md`

**File**: `commands/init-bugfix.md`

2 occurrences in Output section to update:

| Line | Current | New |
|------|---------|-----|
| 259 | `Directory {working_directory}/{subject}/ created` | `Directory {working_directory}/{doc_dir}/ created` |
| 260 | `{working_directory}/{subject}/SPEC.md created` | `{working_directory}/{doc_dir}/SPEC.md created` |

### 1.13: Replace directory path references in `init-refactor.md`

**File**: `commands/init-refactor.md`

2 occurrences in Output section to update:

| Line | Current | New |
|------|---------|-----|
| 242 | `Directory {working_directory}/{subject}/ created` | `Directory {working_directory}/{doc_dir}/ created` |
| 243 | `{working_directory}/{subject}/SPEC.md created` | `{working_directory}/{doc_dir}/SPEC.md created` |

### 1.14: Replace directory path reference in `agents/designer.md`

**File**: `agents/designer.md`

1 occurrence to update:

| Line | Current | New |
|------|---------|-----|
| 34 | `{working_directory}/{subject}/SPEC.md` or user requirements | `{working_directory}/{doc_dir}/SPEC.md` or user requirements |

### 1.15: Replace directory path references in `agents/spec-validator.md`

**File**: `agents/spec-validator.md`

2 occurrences to update:

| Line | Current | New |
|------|---------|-----|
| 26 | All documents in `{working_directory}/{subject}/` folder | All documents in `{working_directory}/{doc_dir}/` folder |
| 68 | Read all documents in `{working_directory}/{subject}/` | Read all documents in `{working_directory}/{doc_dir}/` |

### 1.16: Update directory structure example in `README.md`

**File**: `README.md`
**Location**: Line 192 (Document Types > Complex Tasks section)

Change:
```
{working_directory}/{subject}/
```
To:
```
{working_directory}/{doc_dir}/
```

Where `{doc_dir}` = `{yyyy_mm_dd}-{subject}` (e.g., `claude_works/2026_02_25-auth/`).

### 1.17: Verify `templates/PHASE_MERGE.md` is NOT modified

**File**: `templates/PHASE_MERGE.md`

This file uses `{subject}` exclusively for branch naming (`feature/{subject}-{k}A`, etc.) and worktree naming. It does NOT reference documentation directory paths. Confirm that NO changes are made to this file.

### 1.18: Verify no `{subject}` in commit messages was accidentally changed

After all modifications, search across the entire codebase for `git commit -m` patterns. Verify that ALL commit messages still use `{subject}` (not `{doc_dir}`).

Expected commit message patterns (must remain unchanged):
- `git commit -m "docs: add SPEC.md for {subject}"`
- `git commit -m "docs: add design documents for {subject}"`
- `git commit -m "feat({subject}): complete PHASE_{k}"`
- `git commit -m "docs: update for vX.Y.Z"`

## Completion Checklist

- [ ] 1.1: `_init-common.md` -- `{doc_dir}` generation step added with `date +%Y_%m_%d` command
- [ ] 1.2: `_init-common.md` -- `mkdir` path changed from `{subject}` to `{doc_dir}`
- [ ] 1.3: `start-new.md` -- `doc_dir` field added to SPEC.md metadata block template
- [ ] 1.4: `start-new.md` -- documentation updated to mention `{doc_dir}` in metadata description
- [ ] 1.5: `start-new.md` -- all directory path `{subject}` references replaced with `{doc_dir}` (commit messages preserved)
- [ ] 1.6: `start-new.md` -- all hardcoded `claude_works/{subject}/` examples replaced with `claude_works/{doc_dir}/`
- [ ] 1.7: `design.md` -- 3 directory path references updated
- [ ] 1.8: `code.md` -- 3+ directory path references updated
- [ ] 1.9: `validate-spec.md` -- 2 directory path references updated
- [ ] 1.10: `update-docs.md` -- 1 directory path reference updated
- [ ] 1.11: `init-feature.md` -- 2 output path references updated
- [ ] 1.12: `init-bugfix.md` -- 2 output path references updated
- [ ] 1.13: `init-refactor.md` -- 2 output path references updated
- [ ] 1.14: `designer.md` (agent) -- 1 path reference updated
- [ ] 1.15: `spec-validator.md` (agent) -- 2 path references updated
- [ ] 1.16: `README.md` -- directory structure example updated
- [ ] 1.17: `templates/PHASE_MERGE.md` confirmed NOT modified
- [ ] 1.18: All `git commit -m` patterns verified to still use `{subject}`

## Notes

- The `{doc_dir}` variable is generated ONCE at directory creation time and stored in SPEC.md metadata. It is NOT re-computed by downstream commands.
- When downstream commands need the directory path, they read `doc_dir` from SPEC.md metadata. If metadata is missing (legacy projects), they fall back to `{subject}`.
- The `date +%Y_%m_%d` command uses the local timezone of the machine running the command. This is intentional (see AD-4).
- Checklist items 1.5 and 1.6 require careful attention -- `start-new.md` is the largest file with the most occurrences. A systematic search-and-replace approach is recommended, but each occurrence must be individually verified to ensure commit messages are not affected.
