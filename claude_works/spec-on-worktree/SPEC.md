<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-spec-on-worktree
-->

# Bugfix: SPEC and Documents Created in Wrong Directory After Worktree Creation - Specification

**GitHub Issue**: #48
**Target Version**: 0.3.1
**Severity**: Minor

## Overview

After creating a worktree with `git worktree add`, SPEC.md and other documents are created in the main branch's original directory instead of the worktree directory. The `start-new` workflow creates the worktree at `../{project_name}-{type}-{keyword}` but then continues all document operations (SPEC.md creation, design documents, git add/commit) relative to the original working directory because no `cd` instruction is issued after worktree creation.

## User-Reported Information

### Bug Description

After creating a worktree with `git worktree add`, SPEC.md and other documents are created in the main branch's original directory instead of the worktree directory. The workflow creates the worktree at `../{project_name}-{type}-{keyword}` but then continues all document operations (SPEC.md creation, design documents, git add/commit) relative to the original working directory.

### Reproduction Steps

1. Run `/dotclaude:start-new`
2. Select any work type (feature/bugfix/refactor)
3. Complete the init questions
4. Observe that worktree is created at `../{project_name}-{type}-{keyword}`
5. Observe that SPEC.md is created in the original directory's `{working_directory}/{subject}/` path instead of the worktree's `{working_directory}/{subject}/` path

### Expected Cause

The `_init-common.md` command creates the worktree and even creates the project directory inside it (`mkdir -p ../{project_name}-{type}-{keyword}/{working_directory}/{subject}`), but never instructs to `cd` into the worktree. All subsequent operations in `start-new.md` use relative paths like `{working_directory}/{subject}/SPEC.md` which resolve to the original directory.

### Related Files

| # | File | Lines | Relationship |
|---|------|-------|--------------|
| 1 | `commands/_init-common.md` | 19-23 | Worktree creation without cd |
| 2 | `commands/start-new.md` | 152 | SPEC.md git add uses relative path |
| 3 | `commands/start-new.md` | 218 | Design document git add uses relative path |
| 4 | `commands/start-new.md` | 430-459 | TechnicalWriter invocation paths |

### Impact Scope

Design stage also affected -- design documents would be created in the wrong directory too. All file operations after worktree creation (SPEC.md, design docs, git add/commit) resolve paths relative to the original repository directory instead of the worktree.

## AI Analysis Results

### Root Cause Analysis

- **Exact code location**: `commands/_init-common.md`, lines 19-23 (Branch Creation section)
- **Why the bug occurs**: The workflow creates a worktree at `../{project_name}-{type}-{keyword}` and creates the directory structure inside it, but never issues a `cd` command to change into the worktree. All subsequent file operations (SPEC.md creation via TechnicalWriter, design document creation, git add/commit) use relative paths that resolve to the original repository directory.
- **Correct pattern exists**: `commands/code.md` correctly reads the `worktree_path` from SPEC.md metadata and uses it to determine the working directory for parallel phase worktrees.

### Affected Code Locations

| # | File | Section | Issue |
|---|------|---------|-------|
| 1 | `commands/_init-common.md` | Branch Creation (lines 19-23) | Missing cd after worktree creation |
| 2 | `commands/start-new.md` | Step 4 (line 152) | `git add {working_directory}/{subject}/SPEC.md` uses relative path without being in worktree |
| 3 | `commands/start-new.md` | Step 8 (line 218) | `git add {working_directory}/{subject}/*.md` uses relative path without being in worktree |
| 4 | `commands/start-new.md` | Step 6 Checkpoint (lines 170-193) | Checks worktree existence but not current directory location |
| 5 | `commands/start-new.md` | TechnicalWriter invocation (lines 430-459) | Paths passed to TechnicalWriter do not account for worktree |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | No conflicts -- this is a pure fix to workflow instructions | N/A | N/A |

The `/dotclaude:code` command already correctly handles worktree context changes for parallel phases, so this fix aligns with existing patterns.

### Fix Strategy

Adding `cd` after worktree creation is sufficient because all subsequent operations in `start-new.md` use relative paths (`{working_directory}/{subject}/...`). Once the working directory changes to the worktree, these relative paths automatically resolve to the correct location.

1. Add `cd ../{project_name}-{type}-{keyword}` instruction after worktree creation in `_init-common.md`
2. Simplify `mkdir` to use relative path (since cd changes context)
3. Update Step 6 Checkpoint Worktree Check in `start-new.md` to verify current directory is the worktree (using `pwd` instead of external directory check)

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Worktree creation failure | Should not attempt cd; halt and report error |
| 2 | Design documents path resolution | Fix propagates to design stage since same relative path mechanism is used |
| 3 | Re-entry scenario (resuming workflow) | Need to verify worktree exists and cd into it before resuming |
| 4 | Parallel phase worktrees (3A, 3B, 3C) | Already work correctly; no changes needed |

## Functional Requirements

- [ ] FR-1: After worktree creation in `_init-common.md`, add `cd` instruction to change directory into the worktree
- [ ] FR-2: Simplify `mkdir` in `_init-common.md` to use relative path after cd (remove `../{project_name}-{type}-{keyword}/` prefix)
- [ ] FR-3: Update Step 6 Checkpoint Worktree Check in `start-new.md` to verify current directory is the worktree (e.g., `pwd` contains worktree name)

## Non-Functional Requirements

- [ ] NFR-1: No changes to TechnicalWriter agent file (`agents/technical-writer.md`) -- paths come from orchestrator prompt
- [ ] NFR-2: Backward compatibility with existing worktree naming convention (`{project_name}-{type}-{keyword}`)
- [ ] NFR-3: Consistent pattern with `commands/code.md`'s existing worktree handling approach

## Constraints

- Markdown command files only (no executable code changes)
- Must not break existing parallel phase worktree handling in `commands/code.md`
- Must maintain the `worktree_path` metadata in SPEC.md for downstream commands
- Changes are limited to `commands/_init-common.md` and `commands/start-new.md`

## Out of Scope

- Parallel phase worktree handling (already works correctly in `commands/code.md`)
- TechnicalWriter agent definition changes (`agents/technical-writer.md`) -- paths come from orchestrator prompt
- Coder agent definition changes
- `start-new.md` relative path modifications -- cd resolves these automatically
- Changes to other command files beyond `_init-common.md` and `start-new.md`
