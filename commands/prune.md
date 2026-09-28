---
description: Analyze current diff or a target (phase id / PR number / issue / Jira key) and report test deletion/merge candidates and docstring trim candidates. Report-only; never applies changes.
---

# /dotclaude:prune

Run the `dotclaude:pruner` agent against the current diff or a resolved target and show its report. Report-only.

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (status messages, reports, error messages) MUST use the configured language.
- The pruner always reports in English. When presenting its report to the user, translate the prose (Reason / Notes columns, warning text) into the configured language. Keep file paths, line numbers, criterion numbers (`criterion #N`), and `Kind` values (`delete` / `merge` / `trim`) as-is.
- Internal flows (code-validator, `/dotclaude:design`, `/dotclaude:start-new` doc mode) consume the English report unchanged; this translation applies only to this command's output.
- If no language was provided at session start, default to English (en_US).

## Configuration Loading

Resolve `base_branch` and `working_directory` using this priority:

1. SPEC.md metadata block (`<!-- dotclaude-config ... -->`), if present
2. `dotclaude-config.json` (local project config, then global `~/.claude/dotclaude-config.json`)
3. Defaults: `base_branch: main`, `working_directory: .dc_workspace`

## Argument Resolution

Evaluate in order; the first match wins. Path arguments are not supported.

| # | Argument | Mode | Action |
|---|----------|------|--------|
| 1 | None | Code | `git diff HEAD` (staged + unstaged); empty diff → print "Nothing to analyze." and exit |
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
Task(subagent_type="dotclaude:pruner",
     prompt="Mode: {code|doc}. Working dir: {cwd}. Target: {resolved description}. Files: {file list}. Diff: {diff or diff command}. Report only.")
```

Present the pruner report per the Language section. `Nothing to prune.` is a valid, non-error result.

## Edge Cases

- **#6 No argument + empty diff**: print "Nothing to analyze." and exit immediately; do not call the pruner.
- **#7 Argument disambiguation**: phase id = `^\d+[A-Z]?$` or `^\d+\.\d+$`; GitHub = PR/issue URL or `#N` (type resolved via `gh api`); Jira key = `^[A-Z][A-Z0-9]+-\d+$`. A bare number (e.g., `12`) is a phase id, not a GitHub number.
- **#8 Ticket with no linked branch or PR**: report the error and exit. Never guess a branch or PR.
- **#9 Report-only**: this command never edits files. Applying candidates requires a separate, explicit user instruction.
