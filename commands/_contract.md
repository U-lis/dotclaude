---
description: Single definition of the rules every dotclaude command and agent shares. Internal reference; other files point here instead of restating these rules.
user-invocable: false
---
# dotclaude Contract

Every rule below is defined once, here. Commands and agents reference a section by name (for example "see Contract: Commits") and do not restate it. If a command or agent file appears to contradict this file, this file wins.

## Configuration

Values resolve in this order, later entries overriding earlier ones: built-in defaults, `~/.claude/dotclaude-config.json`, `<git_root>/.claude/dotclaude-config.json`, then the `dotclaude-config` metadata block at the top of the work's `SPEC.md`.

| Key | Default | Meaning |
|-----|---------|---------|
| `working_directory` | `.dc_workspace` | Directory for work documents, relative to the repository root |
| `base_branch` | `main` | Branch that work branches fork from and merge into |
| `language` | `en_US` | Language of user-facing text (see Language) |
| `version_files` | `[]` | Files checked by `/dotclaude:tagging`; empty means auto-detect |

`/dotclaude:start-new` writes the resolved values plus `worktree_path` and `doc_dir` into SPEC.md as an HTML comment so later commands can read them without re-resolving:

```html
<!-- dotclaude-config
working_directory: .dc_workspace
base_branch: main
language: ko_KR
worktree_path: ../{project_name}-{type}-{keyword}
doc_dir: {YYYY_MM_DD}-{keyword}
target_version: {X.Y.Z}
github_issue: {N}            # only when the work came from a GitHub issue
-->
```

A command that runs without SPEC.md uses the config files, then defaults; `worktree_path` falls back to `.` and `doc_dir` to the keyword.

## Language

The SessionStart hook prints `[dotclaude] language: {code}`. If it printed nothing, the language is `en_US`.

Written in the configured language: everything the user reads directly. That is conversation, AskUserQuestion labels and descriptions, status and error messages, reports, `SPEC.md`, and pull request titles and bodies.

Written in English regardless of the setting: documents that only agents consume and project-facing files. That is `GLOBAL.md`, `PHASE_*_PLAN_*.md`, `PHASE_*_TEST.md`, `PHASE_*.5_PLAN_MERGE.md`, agent-to-agent reports, `CHANGELOG.md`, `README.md`, code, comments, and commit messages.

Reason: SPEC.md is the one document the user reviews and approves, so it must be in their language. The rest is read by agents or by the project's public audience, where English is the common form.

## Names and paths

| Item | Form | Example |
|------|------|---------|
| Work type | `feature`, `bugfix`, `refactor` | |
| Branch | `{type}/{keyword}` | `feature/user-auth` |
| Worktree | `../{project_name}-{type}-{keyword}` | `../shop-feature-user-auth` |
| Document directory | `{working_directory}/{doc_dir}` with `doc_dir = $(date +%Y_%m_%d)-{keyword}` | `.dc_workspace/2026_03_01-user-auth` |
| Documents | `SPEC.md`, `GLOBAL.md`, `PHASE_{k}_PLAN_{keyword}.md`, `PHASE_{k}_TEST.md`, `PHASE_{k}.5_PLAN_MERGE.md` | |
| Phase id | sequential `{k}`, parallel `{k}A`/`{k}B`, merge `{k}.5` | `3A`, `3.5` |
| Parallel worktree | `../{project_name}-{type}-{keyword}-{phase}` on branch `{type}/{keyword}-{phase}` forked from `{type}/{keyword}` | |

`{project_name}` is the directory name of the repository root. `{keyword}` is a short kebab-case slug derived from the work description.

## Worktree

Work never happens on `base_branch` and never in the primary checkout. Init creates the work branch with `git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}` after `git checkout {base_branch} && git pull origin {base_branch}`, verifies the directory exists, and changes into it. `git checkout -b` and `git switch -c` are not substitutes: the primary checkout is the user's and must stay on `base_branch`.

The worktree is removed by `/dotclaude:merge` after a successful merge, or by `/dotclaude:purge` once the branch is merged and deployed. `/dotclaude:pr` leaves it in place until the PR is merged.

## Who does what

The command that the user invoked is the orchestrator. It asks the user questions, runs git, and calls agents. It does not write SPEC.md, design documents, or code itself, because those files carry the quality rules encoded in the agent definitions.

| Work | Agent |
|------|-------|
| SPEC.md, GLOBAL/PLAN/TEST/MERGE documents, CHANGELOG and README updates, applying a pruner report to documents | `dotclaude:technical-writer` |
| Architecture decisions and phase decomposition | `dotclaude:designer` |
| Consistency check across SPEC/GLOBAL/PLAN/TEST | `dotclaude:spec-validator` |
| Implementing a phase, fixing validation errors, applying a pruner report to tests | `dotclaude:coders:coder-{language}` |
| Validating a phase and owning its validate-fix loop | `dotclaude:code-validator` |
| Finding redundant tests and over-long comments (report only) | `dotclaude:pruner` |
| Reading many files or searching the codebase to answer a question | the built-in `Explore` agent |

Agents run with a fresh context and cannot ask the user anything. When an agent needs a decision, it stops and returns the question in its report; the orchestrator asks the user and calls the agent again with the answer.

Answer the user from evidence: do not agree with or praise a claim you have not checked.

The orchestrator calls agents with the `Agent` tool and `subagent_type` set to the names above. The prompt carries the task and the paths; the agent's own definition supplies its rules.

## Models

Agent definitions name a model family, never a dated model id, so the plugin follows whatever the current generation is.

| Agents | `model` |
|--------|---------|
| designer, coders | `opus` |
| technical-writer, spec-validator, code-validator, pruner | `sonnet` |

Lookups and wide reads go to `Explore` with `model: haiku` or `sonnet`. The main session decides; agents produce.

## Checkpoints

These are the points where the orchestrator waits for the user, through AskUserQuestion, before continuing. Permission settings such as auto mode do not remove them, because each one fixes the scope of the work.

1. SPEC review: Approve or Needs Revision. Revision loops through technical-writer, at most 3 times.
2. SPEC "decisions required" items: the user picks, even when SPEC names a recommended option.
3. Scope selection after SPEC approval: Design, Design → Code, or Design → Code → Docs.
4. Integration method after the selected scope completes, unless scope was Design only: Direct Merge or Create PR.

Phase decomposition does not need user review: after SPEC approval, design runs through designer, technical-writer, and spec-validator, and coding starts when spec-validator passes. Between chained steps the orchestrator does not stop to ask "what next".

## Commits

| When | What | Message |
|------|------|---------|
| After SPEC approval, once | `{working_directory}/{doc_dir}/SPEC.md` | `docs: add SPEC.md for {keyword}` |
| After design documents are written and pruned | `{working_directory}/{doc_dir}/*.md` | `docs: add design documents for {keyword}` |
| After code-validator returns PASS for a phase | changed code plus the PLAN, GLOBAL, and TEST documents the validator updated | `feat/fix/refactor({keyword}): complete phase {k}` |
| After CHANGELOG/README update | `CHANGELOG.md`, `README.md` | `docs: update CHANGELOG and README for {version}` |

No commit happens without the validator's PASS for that phase, and no version number changes outside `/dotclaude:tagging`. The orchestrator commits; agents do not.

## Validate-fix loop

code-validator owns the loop for one phase: validate, and on failure call the coder with the error list, then validate again, for at most 3 attempts in total. After the third failure it marks the phase `Skipped` in GLOBAL.md and returns FAIL. The orchestrator calls the validator once per phase, does not retry around it, and on FAIL records the error and continues with the next phase. The only other loops are the bounded ones in Limits (SPEC revision, analysis refinement, spec-validator rounds).

## Git safety

`git reset --hard`, `git checkout -- <path>`, `git restore`, and `git stash` are not used to undo agent work, because they destroy uncommitted changes that may belong to another step. Revert by restoring from an explicit backup or `git show HEAD:<path>`. Never force-push. Never delete branches with `-D`.

The pruner never modifies files. Its Bash use is read-only.

## Limits

| Limit | Value |
|-------|-------|
| Clarifying questions during init | 5 per category |
| SPEC revision loop | 3 |
| Analysis summary refinement loop | 3 |
| Codebase reads during init analysis | 10 files |
| Validate-fix attempts per phase | 3 |
| spec-validator rounds (validate, fix, validate) | 3 |
| New parallel worktrees per phase group | one per parallel phase |
