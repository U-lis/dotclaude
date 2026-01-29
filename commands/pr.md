---
description: Create GitHub Pull Request from current branch
---

# /dotclaude:pr

Create a GitHub Pull Request from the current branch to the configured base branch.

## Prerequisites

Before any git operations, verify the following in order:

1. **gh CLI installed**: Run `which gh` or `gh --version`. If command not found, display: "gh CLI is not installed. Install from https://cli.github.com/" and halt.
2. **gh CLI authenticated**: Run `gh auth status`. If not authenticated, display: "gh CLI is not authenticated. Run `gh auth login` first." and halt.

## Configuration

Resolve `base_branch` using the following priority:

1. SPEC.md metadata block in the current working directory (if present):
   ```html
   <!-- dotclaude-config
   base_branch: {value}
   -->
   ```
2. `dotclaude-config.json` (local project config, then global `~/.claude/dotclaude-config.json`)
3. Default: `main`

## Branch Validation

The command MUST reject execution when the current branch is any of:

- `main`
- `master`
- The configured `base_branch` value (if different from main/master)

On rejection, display: "Cannot create PR from base branch. Switch to a working branch first." and halt execution.

## Workflow

```
1. Verify prerequisites (gh installed + authenticated)
2. Load configuration (resolve base_branch)
3. Get current branch name: git branch --show-current
4. Validate branch (reject main, master, configured base_branch)
5. Check remote exists: git remote -v
   -> If no remote: "No remote configured. Add a remote with `git remote add origin <url>`." Halt.
6. Push branch to remote: git push -u origin {branch}
   -> If push fails: report error, abort PR creation
7. Check for existing PR: gh pr view --json url 2>/dev/null
   -> If PR exists: display existing PR URL, skip creation
8. Generate PR title from branch name (convert slashes/hyphens to readable format)
9. Generate PR body from: git log {base_branch}..HEAD --oneline + git diff --stat {base_branch}...HEAD
10. Create PR: gh pr create --base {base_branch} --title "{title}" --body "{body}"
```

## PR Title Generation

Convert the branch name to a human-readable PR title:

- Strip prefix: `feature/`, `bugfix/`, `refactor/`, etc.
- Replace hyphens and underscores with spaces
- Capitalize first letter

Example: `feature/add-pr-command` becomes `Add pr command`

## PR Body

The PR body is auto-generated from:

1. **Commit log**: `git log {base_branch}..HEAD --oneline` -- list of commits on this branch
2. **File stats**: `git diff --stat {base_branch}...HEAD` -- summary of files changed

Format the body as markdown:

```markdown
## Changes

- {commit message 1}
- {commit message 2}
- ...

## Files Changed

{git diff --stat output}
```

## Edge Cases

| # | Case | Behavior |
|---|------|----------|
| 1 | On main/master/base_branch | Error + halt |
| 2 | No remote configured | Error + halt |
| 3 | Push failure | Report error + abort |
| 4 | PR already exists | Show existing PR URL |
| 5 | gh CLI not installed | Installation guide + halt |
| 6 | gh not authenticated | Auth instructions + halt |

## Safety

- Never force push (`--force` or `-f` flags prohibited)
- Read-only validation (prerequisites and branch checks do not modify state)
- Require successful push before PR creation

## Output

```
# PR Created

- Branch: {branch}
- Target: {base_branch}
- Title: {pr_title}
- URL: {pr_url}

Next: Review and merge the PR on GitHub
```

When a PR already exists for the branch:

```
# PR Already Exists

- Branch: {branch}
- URL: {existing_pr_url}

The PR for this branch already exists.
```
