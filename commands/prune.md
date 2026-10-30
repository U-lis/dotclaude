---
description: Analyze current diff or a target (phase id / PR number / issue / Jira key) and report test deletion/merge candidates and docstring trim candidates. Report-only; never applies changes.
---

# /dotclaude:prune

Run the `dotclaude:pruner` agent against the current diff or a resolved target and show its report. Report-only.

## Configuration

`base_branch` and `working_directory` are resolved as in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md` (Configuration). The pruner reports in English; present its report to the user in the configured language, translating only the prose (Reason, Notes, warning text) and keeping paths, line numbers, criterion numbers, and Kind values as-is. Internal callers (code-validator, `/dotclaude:design`) consume the English report unchanged.

## Argument Resolution

Evaluate in order; the first match wins. Path arguments are not supported.

| # | Argument | Mode | Action |
|---|----------|------|--------|
| 1 | None | Code | `git diff HEAD` (staged + unstaged) plus untracked files (`git ls-files --others --exclude-standard`); no changes → print "Nothing to analyze." and exit |
| 2 | Phase id (`^\d+[A-Z]?$` or `^\d+\.\d+$`) | Code (Doc if no code yet) | That phase's changes; if the phase has no code yet → doc mode on `PHASE_{k}_TEST.md` + `PHASE_{k}_PLAN_*.md` |
| 3a | GitHub PR URL, or `#N` resolving to a PR | Code | `gh pr diff N` |
| 3b | GitHub issue URL, or `#N` resolving to an issue | Code | Linked PR or branch → diff vs `base_branch` |
| 4 | Jira key (`^[A-Z][A-Z0-9]+-\d+$`) | Code | Branch containing the key → diff vs `base_branch` |
| 5 | Unrecognized, or no branch/PR found | — | Report error and exit; never guess |

Resolution details:

- **Phase id**: locate `{working_directory}/*/PHASE_{k}_PLAN_*.md`. Not found → step 5. The phase's changes are the files the PLAN lists, diffed vs `base_branch` (plus uncommitted changes). No such changes → doc-mode fallback (below).
- **`#N` disambiguation**: `gh api repos/{owner}/{repo}/issues/N --jq 'has("pull_request")'` → `true` = PR (3a), `false` = issue (3b).
- **Issue → PR/branch**: linked branches via `gh issue develop --list N`; a PR from that branch via `gh pr list --state all --head <branch>`. PR found → `gh pr diff <pr>`; branch only → `git diff {base_branch}...<branch>`. Neither → step 5.
- **Jira key**: `git branch -a --list "*{KEY}*"`. Exactly one branch → `git diff {base_branch}...<branch>`. Zero or multiple → step 5 (list the matches when multiple).

## Doc-Mode Fallback

When a phase id is given but the phase has no code yet, run doc mode with targets `PHASE_{k}_TEST.md` and `PHASE_{k}_PLAN_*.md` from the same directory.

## Agent Invocation

```
Agent(subagent_type="dotclaude:pruner",
     prompt="Mode: {code|doc}. Working dir: {cwd}. Target: {resolved description}. Files: {file list}. Diff: {diff or diff command}. Report only.")
```

Present the pruner report per the Configuration section above. `Nothing to prune.` is a valid, non-error result.

## Edge Cases

- **#6 No argument + no changes** (empty `git diff HEAD` and no untracked files): print "Nothing to analyze." and exit immediately; do not call the pruner.
- **#7 Argument disambiguation**: phase id = `^\d+[A-Z]?$` or `^\d+\.\d+$`; GitHub = PR/issue URL or `#N` (type resolved via `gh api`); Jira key = `^[A-Z][A-Z0-9]+-\d+$`. A bare number (e.g., `12`) is a phase id, not a GitHub number.
- **#8 Ticket with no linked branch or PR**: report the error and exit. Never guess a branch or PR.
- **#9 Report-only**: this command never edits files. Applying candidates requires a separate, explicit user instruction.
