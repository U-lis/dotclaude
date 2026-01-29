<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Branching Strategy - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/22
**Target Version**: 0.3.0

## Overview

Enforce proper branching strategy in the dotclaude workflow. Currently, `git checkout -b {type}/{keyword}` creates branches from whatever HEAD is at the time, which can lead to branches based on stale or incorrect base commits. Additionally, hardcoded `main` references should use the configured `base_branch` value.

The fix ensures:
1. Always checkout and pull the configured `base_branch` before creating a new work branch
2. All hardcoded `main` references in git commands are replaced with the configurable `{base_branch}` value

## Functional Requirements

- [ ] FR-1: Before creating a new work branch, checkout the configured `base_branch` first
- [ ] FR-2: Pull the latest changes from remote `base_branch` before creating the new branch
- [ ] FR-3: Create the new work branch from the updated `base_branch` HEAD
- [ ] FR-4: Replace all hardcoded `main` references in git commands with `{base_branch}` config value
- [ ] FR-5: The branching strategy applies to all work types: feature, bugfix, refactor, and github-issue

## Non-Functional Requirements

- [ ] NFR-1: Branch creation must gracefully handle offline scenarios (pull fails -> warn but proceed with local `base_branch`)
- [ ] NFR-2: Must warn user if there are uncommitted changes before switching branches

## Constraints

- Must not change the branch naming convention (`{type}/{keyword}`)
- Must read `base_branch` from the SPEC.md config metadata or dotclaude-config.json
- Must maintain backward compatibility with existing workflows

## Out of Scope

- Changing branch naming conventions
- Adding new configuration options (`base_branch` already exists)
- Modifying the merge workflow beyond replacing hardcoded `main`

## Analysis Results

### Related Code

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | `commands/start-new.md` | 85 | Branch creation: `git checkout -b {type}/{keyword}` -- needs `base_branch` checkout + pull before this |
| 2 | `commands/start-new.md` | 283 | Merge step: hardcoded `git checkout main` -- must use `{base_branch}` |
| 3 | `commands/merge-main.md` | 19 | Merge step: hardcoded `git checkout main && git pull origin main` -- must use `{base_branch}` |
| 4 | `commands/init-feature.md` | 145 | Documents branch format (`feature/{keyword}`) but not creation logic -- no change needed |
| 5 | `commands/init-bugfix.md` | 177 | Documents branch format (`bugfix/{keyword}`) but not creation logic -- no change needed |
| 6 | `commands/init-refactor.md` | 165 | Documents branch format (`refactor/{keyword}`) but not creation logic -- no change needed |
| 7 | `commands/init-github-issue.md` | 155 | Branch creation: `git checkout -b {work_type}/{branch_keyword}` -- needs same base_branch checkout + pull fix |
| 8 | `commands/code.md` | 116 | Worktree operations: `git checkout feature/subject` -- may reference branch names but does not hardcode `main` |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | Branch created from current HEAD (whatever commit is checked out) | Branch created from latest remote `base_branch` HEAD | Add `git checkout {base_branch} && git pull origin {base_branch}` before `git checkout -b {type}/{keyword}` |
| 2 | `git checkout main` hardcoded in merge steps (`start-new.md` line 283, `merge-main.md` line 19) | Use `{base_branch}` from config | Replace literal `main` with `{base_branch}` config value in all git commands |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Already on `base_branch` | Skip checkout, just pull latest changes |
| 2 | Uncommitted changes on current branch | Warn user before switching; do not silently discard changes |
| 3 | Remote not available (offline) | Warn that pull failed but proceed with local `base_branch` state |
| 4 | `base_branch` does not exist locally | Attempt `git fetch origin {base_branch}` then `git checkout {base_branch}`; fail with clear error if branch not found |
| 5 | Branch name already exists | Warn and ask user for alternative name or confirm overwrite |
