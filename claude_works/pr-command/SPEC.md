<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# dc:pr Command - Specification

**Target Version**: 0.3.0
**Source Issue**: https://github.com/U-lis/dotclaude/issues/9
**GitHub Issue Number**: #9

## Overview

### Purpose

Add `/dotclaude:pr` command to create GitHub Pull Requests from feature/bugfix/refactor branches.

### Problem

After completing work in the dotclaude workflow, users must manually push branches and create PRs. No automated PR creation command exists within the dotclaude workflow.

### Solution

Create a new user-invocable command `pr` that pushes the current branch to remote and creates a PR targeting the configured base branch using `gh` CLI.

## Functional Requirements

- [ ] FR-1: Push current branch to remote using `git push -u origin {branch}`
- [ ] FR-2: Create PR using `gh pr create` targeting base branch (read from dotclaude-config or SPEC.md metadata, default: `main`)
- [ ] FR-3: Support any working branch (reject `main`, `master`, or the configured `base_branch`)
- [ ] FR-4: Auto-generate PR title from branch name or commit history
- [ ] FR-5: Auto-generate PR body with summary of changes (commit log, files changed)

## Non-Functional Requirements

- [ ] NFR-1: No specific performance requirements
- [ ] NFR-2: No specific security requirements

## Constraints

- Must follow existing codebase patterns (command frontmatter format with `description` field, config loading via SPEC.md metadata or config files)
- Requires `gh` CLI installed and authenticated (`gh auth status` must succeed)
- Must document `gh` as a prerequisite in README
- Must be a user-invocable command (default frontmatter behavior, no `user-invocable: false`)

## Out of Scope

- Draft PR support (`--draft` flag)
- PR template customization
- PR review assignment (`--reviewer` flag)

## Related Code

| # | File | Relationship |
|---|------|--------------|
| 1 | `commands/merge-main.md` | Has PR creation option via `gh pr create` - closest existing pattern for `gh` CLI usage |
| 2 | `commands/tagging.md` | Similar git operation command pattern (push, tag operations) |
| 3 | `commands/start-new.md` | Config loading pattern (`base_branch`, `working_directory`) from SPEC.md metadata and config files |
| 4 | `commands/init-github-issue.md` | Uses `gh` CLI for GitHub operations, error handling pattern for `gh` commands |

## Conflicts

No conflicts identified. The new `pr` command does not overlap with existing command names or functionality.

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Running on `main`, `master`, or configured `base_branch` | Display error message: "Cannot create PR from base branch. Switch to a working branch first." Halt execution. |
| 2 | Remote not configured | Display error message: "No remote configured. Add a remote with `git remote add origin <url>`." Halt execution. |
| 3 | Push failure (no permissions, network error) | Report the git push error output to user. Abort PR creation. |
| 4 | PR already exists for this branch | Detect existing PR via `gh pr view` or `gh pr list`. Display existing PR URL instead of creating a duplicate. |
| 5 | `gh` CLI not installed | Display installation guide: "gh CLI is not installed. Install from https://cli.github.com/" Halt execution. |
| 6 | `gh` CLI not authenticated | Detect via `gh auth status`. Display message: "gh CLI is not authenticated. Run `gh auth login` first." Halt execution. |
