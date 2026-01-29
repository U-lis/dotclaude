# Phase 1: PR Command

## Objective

Create the `/dotclaude:pr` command file and update `README.md` to document the new command and its `gh` CLI prerequisite. This is a single-phase task that delivers the complete PR creation feature.

## Prerequisites

- SPEC.md reviewed and approved
- Familiarity with existing command patterns (`commands/merge-main.md`, `commands/tagging.md`)
- Understanding of config loading pattern from `commands/start-new.md`

## File Operations

| Operation | File | Description |
|-----------|------|-------------|
| CREATE | `commands/pr.md` | New PR creation command (~80-100 lines) |
| MODIFY | `README.md` | Add `gh` prerequisite and `/dotclaude:pr` to skills table |

**DO NOT MODIFY**: `plugin.json`, `marketplace.json`, `CHANGELOG.md` -- version files are unchanged during implementation.

## Instructions

### Part A: Create `commands/pr.md`

Create the file `commands/pr.md` with the following structure and content.

#### A.1: YAML Frontmatter

Add YAML frontmatter with only the `description` field. Follow the same pattern as `commands/merge-main.md` and `commands/tagging.md`.

```yaml
---
description: Create GitHub Pull Request from current branch
---
```

Do NOT add `user-invocable: false`. The command must appear in the slash menu (default behavior).

#### A.2: Title and Summary

```markdown
# /dotclaude:pr

Create a GitHub Pull Request from the current branch to the configured base branch.
```

#### A.3: Prerequisites Section

Add a prerequisites section that instructs Claude to verify `gh` CLI availability and authentication BEFORE any git operations. Use the following checks:

1. **gh CLI installed**: Run `which gh` or `gh --version`. If command not found, display: "gh CLI is not installed. Install from https://cli.github.com/" and halt.
2. **gh CLI authenticated**: Run `gh auth status`. If not authenticated, display: "gh CLI is not authenticated. Run `gh auth login` first." and halt.

Format this as a numbered check list within a `## Prerequisites` section, similar to the prerequisites pattern in `commands/tagging.md`.

#### A.4: Configuration Loading Section

Add a `## Configuration` section that documents how `base_branch` is resolved. Follow the config loading pattern from `commands/start-new.md`:

1. Read `base_branch` from SPEC.md metadata block (`<!-- dotclaude-config ... -->`) if a SPEC.md exists in the current working directory
2. Fall back to `dotclaude-config.json` (local then global)
3. Default to `main` if no configuration found

Present this as a numbered priority list. Include the exact metadata block format for reference:

```html
<!-- dotclaude-config
base_branch: {value}
-->
```

#### A.5: Branch Validation Section

Add a `## Branch Validation` section. The command MUST reject execution when the current branch is any of:

- `main`
- `master`
- The configured `base_branch` value (if different from main/master)

On rejection, display: "Cannot create PR from base branch. Switch to a working branch first." and halt execution.

#### A.6: Workflow Section

Add a `## Workflow` section with a code block containing 10 numbered steps. The workflow must be:

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

#### A.7: PR Title Generation Section

Add a `## PR Title Generation` section. Document the branch-name-to-title conversion logic:

- Strip prefix: `feature/`, `bugfix/`, `refactor/` etc.
- Replace hyphens and underscores with spaces
- Capitalize first letter

Example: `feature/add-pr-command` becomes `Add pr command`

#### A.8: PR Body Generation Section

Add a `## PR Body` section. Document that the body is auto-generated from:

1. **Commit log**: `git log {base_branch}..HEAD --oneline` -- list of commits on this branch
2. **File stats**: `git diff --stat {base_branch}...HEAD` -- summary of files changed

Format the body as markdown with `## Changes` and `## Files Changed` sections.

#### A.9: Edge Cases Table

Add a `## Edge Cases` section with a table matching the 6 cases from SPEC.md:

| # | Case | Behavior |
|---|------|----------|
| 1 | On main/master/base_branch | Error + halt |
| 2 | No remote configured | Error + halt |
| 3 | Push failure | Report error + abort |
| 4 | PR already exists | Show existing PR URL |
| 5 | gh CLI not installed | Installation guide + halt |
| 6 | gh not authenticated | Auth instructions + halt |

#### A.10: Safety Rules Section

Add a `## Safety` section following the style of `commands/merge-main.md`:

- Never force push (`--force` or `-f` flags prohibited)
- Read-only validation (prerequisites and branch checks do not modify state)
- Require successful push before PR creation

#### A.11: Output Format Section

Add a `## Output` section with a code block matching the output style of `commands/merge-main.md` and `commands/tagging.md`:

```
# PR Created

- Branch: {branch}
- Target: {base_branch}
- Title: {pr_title}
- URL: {pr_url}

Next: Review and merge the PR on GitHub
```

Also include the variant for when a PR already exists:

```
# PR Already Exists

- Branch: {branch}
- URL: {existing_pr_url}

The PR for this branch already exists.
```

### Part B: Update `README.md`

#### B.1: Add gh CLI Prerequisite

The README does not currently have a "Prerequisites" section. However, the `gh` CLI dependency must be documented. Add `gh` CLI as a prerequisite in a way that fits the existing README structure.

**Option**: If no dedicated Prerequisites section exists, add a note under the Installation section or create a new `## Prerequisites` section after the Installation section. The section should contain:

```markdown
## Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) - Required for `/dotclaude:pr` command
  - Install: `brew install gh` (macOS) or see [installation guide](https://github.com/cli/cli#installation)
  - Authenticate: `gh auth login`
```

#### B.2: Add `/dotclaude:pr` to Skills Table

In the `## Skills (Commands)` section, add a new row to the table:

| Command | Description |
|---------|-------------|
| `/dotclaude:pr` | Create GitHub Pull Request from current branch |

Insert the new row in a logical position. Since `pr` is a git operation command, place it after `/dotclaude:merge-main` and before `/dotclaude:tagging`, grouping git-related commands together.

#### B.3: Add `pr.md` to Directory Structure

In the `## Structure` section, add `pr.md` to the `commands/` listing:

```
│   ├── pr.md                  # /dotclaude:pr
```

Insert it alphabetically or after `merge-main.md` to keep git-related commands grouped.

## Completion Checklist

- [ ] 1. `commands/pr.md` created with YAML frontmatter (`description` field only)
- [ ] 2. Prerequisites section present (gh CLI installation and authentication checks)
- [ ] 3. Configuration loading section present (base_branch from SPEC.md metadata, config files, default)
- [ ] 4. Complete workflow section present (10 steps with exact gh/git commands)
- [ ] 5. Branch validation present (reject main, master, configured base_branch)
- [ ] 6. Existing PR detection present (gh pr view before creating)
- [ ] 7. Auto-generated title logic documented (branch name to readable title)
- [ ] 8. Auto-generated body logic documented (git log and git diff --stat)
- [ ] 9. Edge cases table present (6 cases matching SPEC.md)
- [ ] 10. Safety rules present (no force push, read-only validation)
- [ ] 11. Output format block present (matches merge-main.md and tagging.md style)
- [ ] 12. README.md updated with gh CLI prerequisite
- [ ] 13. README.md Skills table includes `/dotclaude:pr`
- [ ] 14. README.md directory structure includes `pr.md`
- [ ] 15. No version file modifications (plugin.json, marketplace.json, CHANGELOG.md unchanged)

## Notes

- The `commands/pr.md` file is a command definition file (markdown with YAML frontmatter), NOT executable code. Claude reads and follows the instructions when the user invokes `/dotclaude:pr`.
- Follow the structural patterns of `commands/merge-main.md` (closest analogy: git operation + output format) and `commands/tagging.md` (closest analogy: prerequisites pattern).
- The `gh pr view --json url` check at step 7 must use `2>/dev/null` to suppress errors when no PR exists, as `gh pr view` returns non-zero exit code when no PR is found.
- The config loading priority (SPEC.md metadata > config files > default) must match the pattern established in `commands/start-new.md`.
