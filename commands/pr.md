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

## Document Detection

To generate rich PR body content, detect available design documents before composing the body:

1. **Resolve `working_directory`** using the same priority chain as `base_branch`:
   - SPEC.md metadata block: `working_directory: {value}`
   - `dotclaude-config.json` (local project config, then global `~/.claude/dotclaude-config.json`)
   - Default: `.dc_workspace`

2. **Scan for SPEC.md**: Look for `{working_directory}/*/SPEC.md` (any subdirectory under the working directory, relative to project root).

3. **If SPEC.md found**, also check the **same directory** for:
   - `GLOBAL.md`
   - `PHASE_*_TEST.md` (glob pattern, may match multiple files)
   - `PHASE_*_PLAN.md` (glob pattern, may match multiple files)

4. **Each document is optional.** Missing documents trigger the fallback path for their respective PR body section:
   - No SPEC.md → fallback for Summary and Resolves
   - No GLOBAL.md → skip supplementary Summary context
   - No PHASE_*_PLAN.md → fallback for Changes descriptions
   - No PHASE_*_TEST.md → fallback for Test plan items

5. If the resolved `working_directory` path does not exist, treat as no design docs and use git-based fallback for all sections.

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
9. Generate PR body:
   a. Detect design documents (see Document Detection section above)
   b. Generate Summary:
      - If SPEC.md exists: extract `## Overview` section content as bullet points
      - If GLOBAL.md exists: supplement with Feature Overview (Purpose/Problem/Solution)
      - Fallback: summarize commit messages from `git log {base_branch}..HEAD --oneline`, grouped by type/area
   c. Generate issue link:
      - If SPEC.md has `GitHub Issue Number` metadata: prepare `Resolves #N` line
      - If not present, omit the Resolves line entirely
   d. Generate Changes:
      - Run `git diff --stat {base_branch}...HEAD` to get list of changed files
      - For each changed file, generate a description:
        - If PHASE_*_PLAN.md exists: derive description from plan instructions mentioning the file
        - Fallback: derive description from commit messages that touch the file (`git log {base_branch}..HEAD -- {file_path} --oneline`)
      - Format as markdown list: `- \`{file_path}\`: {description}`
   e. Generate Test plan:
      - If PHASE_*_TEST.md files exist: extract checkbox items from Unit Tests, Integration Tests, Edge Cases sections
      - If multiple PHASE_*_TEST.md files exist: aggregate items from all files, deduplicate
      - Fallback: generate minimal test items:
        - "Verify {primary change} works correctly"
        - "Verify no regressions in {affected area}"
   f. Append attribution footer: `Generated with [Claude Code](https://claude.com/claude-code)`
   g. Assemble final PR body in order: Summary -> Resolves -> Changes -> Test plan -> Attribution
10. Resolve label from branch prefix:
    -> feature/ -> "enhancement", bugfix/ -> "bug", refactor/ -> "refactoring"
    -> Check label exists: gh label list --search "{label}"
    -> If not found: gh label create "{label}" (warn on failure, do not halt)
11. Resolve milestone from SPEC.md Target Version:
    -> Check milestone exists: gh api repos/{owner}/{repo}/milestones --jq '.[].title'
    -> If not found: gh api repos/{owner}/{repo}/milestones -f title="{version}" (warn on failure, do not halt)
12. Create PR: gh pr create --base {base_branch} --title "{title}" --body "{body}" [--label "{label}"] [--milestone "{milestone}"]
```

## PR Title Generation

Convert the branch name to a human-readable PR title:

- Strip prefix: `feature/`, `bugfix/`, `refactor/`, etc.
- Replace hyphens and underscores with spaces
- Capitalize first letter

Example: `feature/add-pr-command` becomes `Add pr command`

## PR Body

The PR body is auto-generated using design documents when available, with git-based fallback. The structure matches the pattern established in merged PRs (#34-#38).

### Primary Template (design docs available)

When SPEC.md and/or other design documents are found via Document Detection:

```markdown
## Summary
- {bullet point from SPEC.md Overview}
- {bullet point from SPEC.md Overview}
- {supplementary point from GLOBAL.md Feature Overview, if available}

Resolves #{N}

## Changes
- `{file_path_1}`: {description derived from PHASE_*_PLAN or commit messages}
- `{file_path_2}`: {description derived from PHASE_*_PLAN or commit messages}

## Test plan
- [ ] {test item from PHASE_*_TEST.md}
- [ ] {test item from PHASE_*_TEST.md}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Fallback Template (no design docs)

When no SPEC.md, GLOBAL.md, or PHASE_* documents exist:

```markdown
## Summary
- {summarized from commit messages, grouped by type/area}

## Changes
- `{file_path}`: {derived from commit messages touching this file}

## Test plan
- [ ] Verify {primary change} works correctly
- [ ] Verify no regressions in {affected area}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Template Rules

- **Resolves line**: Include `Resolves #N` ONLY when SPEC.md contains `GitHub Issue Number` metadata. Omit the line entirely otherwise.
- **Summary**: Limit to 1-5 bullet points. If source material is longer, condense to the most important points.
- **Changes**: List only files that appear in `git diff --stat`. Do not list files that were not modified. Each entry provides a meaningful description of what changed in that file.
- **Test plan**: Minimum 2 items, maximum 10 items. Prioritize the most important test cases if source material has more than 10.
- **Attribution footer**: Always present, always the last line of the PR body.

## Milestone

Assign a GitHub milestone matching the `Target Version` from SPEC.md:

1. Read `Target Version` from SPEC.md (e.g., `0.3.0`, `1.0.0`)
2. If present, check existing milestones: `gh api repos/{owner}/{repo}/milestones --jq '.[].title'`
3. If milestone does not exist, create it: `gh api repos/{owner}/{repo}/milestones -f title="{version}"`
4. Pass `--milestone "{version}"` to `gh pr create`

If SPEC.md has no `Target Version`, skip milestone assignment. If milestone creation fails (e.g., insufficient permissions), warn the user and continue PR creation without milestone.

## Label

Auto-assign a label based on branch prefix:

| Branch Prefix | Label |
|---------------|-------|
| `feature/` | `enhancement` |
| `bugfix/` | `bug` |
| `refactor/` | `refactoring` |

1. Determine the label from current branch prefix
2. Check if the label exists: `gh label list --search "{label}"`
3. If the label does not exist, create it: `gh label create "{label}"`
4. Pass `--label "{label}"` to `gh pr create`

If the branch prefix doesn't match any known pattern, skip label assignment. If label creation fails (e.g., insufficient permissions), warn the user and continue PR creation without label.

## Edge Cases

| # | Case | Behavior |
|---|------|----------|
| 1 | On main/master/base_branch | Error + halt |
| 2 | No remote configured | Error + halt |
| 3 | Push failure | Report error + abort |
| 4 | PR already exists | Show existing PR URL |
| 5 | gh CLI not installed | Installation guide + halt |
| 6 | gh not authenticated | Auth instructions + halt |
| 7 | SPEC.md has no `GitHub Issue Number` | Skip `Resolves #N`, no error |
| 8 | SPEC.md has no `Target Version` | Skip milestone, no error |
| 9 | Milestone creation fails | Warn + continue without milestone |
| 10 | Label creation fails | Warn + continue without label |
| 11 | Unknown branch prefix | Skip label, no error |
| 12 | No SPEC.md exists (manual PR outside dotclaude workflow) | Fall back to git log-based Summary and Changes; generate minimal Test plan |
| 13 | No GLOBAL.md exists (design step skipped) | Skip supplementary context in Summary; use SPEC.md or commits only |
| 14 | No PHASE_*_TEST.md exists | Generate minimal Test plan from implementation scope (2 generic items) |
| 15 | SPEC.md exists but has no Overview section | Fall back to git log for Summary |
| 16 | Multiple PHASE_*_TEST.md files exist | Aggregate test items from all test files, deduplicate |
| 17 | Empty commit log (no commits ahead of base) | Show "No changes detected" in Summary; empty Changes table |
| 18 | Very long commit history (50+ commits) | Summarize by grouping related changes; limit Summary to 5 bullet points |
| 19 | SPEC.md has working_directory but directory does not exist | Treat as no design docs; use git-based fallback |

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
- Label: {label} (if assigned)
- Milestone: {milestone} (if assigned)
- Issue: Resolves #{N} (if linked)
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
