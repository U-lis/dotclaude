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

`base_branch`, `working_directory`, and `pr.labels`, `pr.assignee`, `pr.reviewers` are resolved as in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md` (Configuration). The PR title and body are written in the configured language (Contract: Language).

## Document Detection

Look for `{working_directory}/*/SPEC.md`. If found, also look in the same directory for `GLOBAL.md`, `PHASE_*_TEST.md`, and `PHASE_*_PLAN_*.md`. Each document is optional; a missing one switches its PR body section to the git-based fallback below. A `working_directory` that does not exist means no design documents.

## Branch Validation

Stop when the current branch is any of:

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
      - If the SPEC metadata block has `github_issue`: prepare `Resolves #N` line
      - If not present, omit the Resolves line entirely
   d. Generate Changes:
      - Run `git diff --stat {base_branch}...HEAD` to get list of changed files
      - For each changed file, generate a description:
        - If PHASE_*_PLAN_*.md exists: derive description from plan instructions mentioning the file
        - Fallback: derive description from commit messages that touch the file (`git log {base_branch}..HEAD -- {file_path} --oneline`)
      - Format as markdown list: `- \`{file_path}\`: {description}`
   e. Generate Test plan (only verification CI does not cover):
      - `[x]` items: manual / e2e / real-environment checks already performed, with their result, taken from the current session context
      - `[ ]` items: checks still pending before merge or deploy
      - Do NOT copy items from PHASE_*_TEST.md (automated tests already run in CI) and do NOT generate generic items. Never invent a check that was not performed.
      - Nothing to list → omit the Test plan section
   f. Full-diff review: skip the call when REVIEW.md already has a `## Full diff` section from this commit range and build Review notes from that table. Otherwise call `dotclaude:reviewer` once with scope "the full branch diff", `Base: {base_branch}`, and the SPEC, RULES, and PLAN paths (prompt in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`, reviewer). If `BLOCKERS` is above 0, show the table and ask with AskUserQuestion: create the PR with the Blockers listed, or stop so they can be fixed first (`/dotclaude:review` after the fix). Stopping ends the command here; the branch stays pushed and no PR is created.
      - Build the Review notes section from the reviewer table: the `issue` rows, Blocker first, then Major, then Minor, plus the Major and Minor rows carried from phase reviews in `{working_directory}/{doc_dir}/REVIEW.md` that the full-diff table does not already list (same location and finding). Translate only the Finding and Notes prose into the configured language. No `issue` rows anywhere → the section is the single line `No issues on the five review axes.`
   g. Append attribution footer: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
   h. Assemble final PR body in order: Summary -> Resolves -> Changes -> Test plan (if any) -> Review notes -> Attribution
10. Resolve label from branch prefix:
    -> feature/ -> "enhancement", bugfix/ -> "bug", refactor/ -> "refactoring"
    -> Check label exists: gh label list --search "{label}"
    -> If not found: gh label create "{label}" (warn on failure, do not halt)
    -> Do the same for each label in pr.labels; the labels passed to gh pr create are the branch-prefix label plus pr.labels
11. Resolve milestone from the SPEC metadata `target_version`:
    -> Check milestone exists: gh api repos/{owner}/{repo}/milestones --jq '.[].title'
    -> If not found: gh api repos/{owner}/{repo}/milestones -f title="{version}" (warn on failure, do not halt)
12. Create PR: gh pr create --base {base_branch} --title "{title}" --body "{body}" [--label "{label}"]... [--assignee "{pr.assignee}"] [--reviewer "{reviewer}"]... [--milestone "{milestone}"]
    -> --assignee only when pr.assignee is non-empty; --reviewer once per entry of pr.reviewers
    -> If a later gh pr edit fails, fall back to gh api -X POST repos/{owner}/{repo}/issues/{n}/labels (labels) or /assignees (assignees); warn on failure, do not halt
13. If a SPEC.md was found: ${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh stage <spec> pr
```

## PR Title Generation

Convert the branch name to a human-readable PR title:

- Strip prefix: `feature/`, `bugfix/`, `refactor/`, etc.
- Replace hyphens and underscores with spaces
- Capitalize first letter

Example: `feature/add-pr-command` becomes `Add pr command`

## PR Body

The PR body is generated from design documents when available, with a git-based fallback.

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
- [x] {verification performed outside CI, with result}
- [ ] {check pending before merge/deploy}

## Review notes
| Axis | Location | Severity | Finding | Source |
|------|----------|----------|---------|--------|
| {2 scope} | `{file}:{line}` | {Blocker / Major / Minor} | {one line} | {full diff \| phase {k}} |

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
- [x] {verification performed outside CI, with result}
- [ ] {check pending before merge/deploy}

## Review notes
| Axis | Location | Severity | Finding | Source |
|------|----------|----------|---------|--------|
| {2 scope} | `{file}:{line}` | {Blocker / Major / Minor} | {one line} | {full diff \| phase {k}} |

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Template Rules

- **Resolves line**: Include `Resolves #N` only when the SPEC metadata block has `github_issue`. Omit the line otherwise.
- **Summary**: Limit to 1-5 bullet points. If source material is longer, condense to the most important points.
- **Changes**: List only files that appear in `git diff --stat`. Do not list files that were not modified. Each entry provides a meaningful description of what changed in that file.
- **Test plan**: Only verification CI does not cover (performed or pending). Maximum 10 items. Omit the section when there is nothing to list.
- **Review notes**: Always present. Rows come only from the reviewer output (step 9f); `checked` and `n/a` axes are not listed. Do not drop or soften a row.
- **Attribution footer**: Always present, always the last line of the PR body.

## Milestone

Assign a GitHub milestone matching `target_version` in the SPEC metadata block:

1. Read `target_version` from the SPEC metadata block (e.g., `0.3.0`, `1.0.0`)
2. If present, check existing milestones: `gh api repos/{owner}/{repo}/milestones --jq '.[].title'`
3. If milestone does not exist, create it: `gh api repos/{owner}/{repo}/milestones -f title="{version}"`
4. Pass `--milestone "{version}"` to `gh pr create`

If the metadata has no `target_version`, skip milestone assignment. If milestone creation fails (e.g., insufficient permissions), warn the user and continue PR creation without milestone.

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
4. Pass `--label "{label}"` to `gh pr create`, followed by one `--label` per entry of `pr.labels` (created the same way when missing)

The assignee (`pr.assignee`, default `@me`) and reviewers (`pr.reviewers`) are passed as `--assignee` and `--reviewer`. If `gh pr edit` is needed afterwards and fails, add them with `gh api -X POST repos/{owner}/{repo}/issues/{n}/labels` or `/assignees` instead; a failure there is a warning, not a halt.

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
| 7 | SPEC metadata has no `github_issue` | Skip `Resolves #N`, no error |
| 8 | SPEC metadata has no `target_version` | Skip milestone, no error |
| 9 | Milestone creation fails | Warn + continue without milestone |
| 10 | Label creation fails | Warn + continue without label |
| 11 | Unknown branch prefix | Skip the prefix label, no error; `pr.labels` still apply |
| 12 | No SPEC.md exists (manual PR outside dotclaude workflow) | Fall back to git log-based Summary and Changes |
| 13 | No GLOBAL.md exists (design step skipped) | Skip supplementary context in Summary; use SPEC.md or commits only |
| 14 | No non-CI verification performed or pending | Omit the Test plan section |
| 15 | SPEC.md exists but has no Overview section | Fall back to git log for Summary |
| 16 | Empty commit log (no commits ahead of base) | Show "No changes detected" in Summary; empty Changes table |
| 17 | Very long commit history (50+ commits) | Summarize by grouping related changes; limit Summary to 5 bullet points |
| 18 | SPEC.md has working_directory but directory does not exist | Treat as no design docs; use git-based fallback |
| 19 | Full-diff review reports Blockers | Ask: create the PR with them listed in Review notes, or stop before `gh pr create` |
| 20 | No `REVIEW.md` (no phase reviews, or PR outside the dotclaude workflow) | Review notes come from the full-diff review only |

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
- Label: {label}, {pr.labels} (if assigned)
- Assignee / reviewers: {assignee}, {reviewers} (if set)
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
