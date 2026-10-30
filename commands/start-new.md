---
description: Entry point for starting new work. Runs the full workflow from requirements to integration, asking the user at each checkpoint.
---
# /dotclaude:start-new [github-issue-url] [--prefill "<text>"]

You are the orchestrator for one unit of work: gather requirements, get SPEC.md approved, design, implement phase by phase, update docs, and integrate. The shared rules (configuration, language, naming, worktree, who does what, checkpoints, commits, retry policy, git safety) are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`. Read it once at the start and follow it; this file only describes the order of steps.

You interact with the user through AskUserQuestion. You run git yourself. You call agents with the Agent tool and never write SPEC.md, design documents, or code yourself (Contract: Who does what). Prompt templates for each agent call are in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`. At the start of each step print one line, `[Step {N}/13] {step name}: {current action}`, so the user can follow progress.

## Step 0: Route on arguments

First run `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh find` in the current directory. If it finds a SPEC.md whose `stage` is set and not `done`, this is a resume: show the user the `handoff` line and the `decisions` tokens if any, then continue from that stage (`spec_review` → Step 3, `design` → Step 6, `code` → Step 9 at the first phase that is not Complete, `local_test`/`test_deploy`/`remote_test`/`pr` → Step 12) without asking the work type again. Otherwise route on the arguments:

| Arguments | Action |
|-----------|--------|
| A GitHub issue or PR URL (`https://github.com/<owner>/<repo>/(issues|pull)/<n>`) and no `--prefill` | `Skill("dotclaude:init-github-issue")` with the URL. Work type is inferred from the issue, so Step 1 is skipped. |
| `--prefill "<text>"` with or without a URL | `Skill("dotclaude:init-prefill")` with `prefill_body` = the text and `url_reference` = the URL or null. init-prefill detects the work type, pre-fills answers, and routes to the matching init command. If the body is empty it returns here and Step 1 runs. |
| Nothing | Continue with Step 1. |

`--prefill` text must be quoted on the command line; an unquoted body is tokenized by the shell and only its first word arrives. If the arguments look truncated that way, stop and tell the user instead of guessing a route.

## Init

**Step 1. Work type.** Ask: "What type of work do you want to start?" with options Add/Modify Feature, Bug Fix, Refactoring, GitHub Issue.

**Step 2. Run the init command.** `Skill("dotclaude:init-feature")`, `init-bugfix`, `init-refactor`, or `init-github-issue` according to the answer. The init command owns its questions, the analysis steps, the worktree and branch creation, and the SPEC.md draft through technical-writer. Do not improvise questions; follow the loaded file.

Before the SPEC draft, unless the init command already set the version from a GitHub milestone, ask the target version: read CHANGELOG.md, show the last three versions in a short table, and offer `{patch}`, `{minor}`, `{major}` computed from the current version. The answer goes into SPEC.md and is used again in Step 11.

After the init command returns, check that `git worktree list` contains `../{project_name}-{type}-{keyword}`, that the current branch is `{type}/{keyword}`, and that `{working_directory}/{doc_dir}/SPEC.md` exists in that worktree. If any check fails, stop and report what is missing. Do not re-run the init command: it already asked the user questions once, and repeating them without explanation is worse than a clear error.

**Step 3. SPEC review.** The init command set `stage: spec_review`. Summarize SPEC.md and ask: Approve or Needs Revision. On revision, call technical-writer with the user's feedback and ask again (at most 3 rounds, Contract: Limits). If SPEC.md lists decisions the user still has to make (Decisions Required table), ask each one here and have technical-writer record the choice; a recommended option is still a question.

**Step 4. Approve and commit.** Run `spec-meta.sh approve <spec>` (records `approved_at`, `approved_hash`, `stage: design`), then commit SPEC.md (Contract: Commits). This is the only SPEC commit.

**Step 5. Scope.** Ask: "How far should we proceed?" with options Design, Design → Code, Design → Code → Docs.

## Before design

Check, in the worktree: the branch is `{type}/{keyword}` and not `base_branch`; `spec-meta.sh check-approved <spec>` exits 0 (the SPEC body is the approved one); `git rev-parse --show-toplevel` ends with `{project_name}-{type}-{keyword}`. If any check fails, stop and report. These checks exist because every later step writes into this worktree and commits on this branch.

## Design (Steps 6–8)

6. Call designer with the SPEC path. It returns architecture decisions, the phase breakdown with dependencies, and per-phase checklists. If it returns open questions instead, ask the user and call it again.
7. Call technical-writer with the designer output and the target directory. It writes GLOBAL.md, `PHASE_{k}_PLAN_{keyword}.md`, `PHASE_{k}_TEST.md`, and `PHASE_{k}.5_PLAN_MERGE.md` for parallel groups. Then call pruner in doc mode on the PLAN and TEST files; if it reports candidates, call technical-writer to apply them. Then call spec-validator; on issues, call technical-writer with the report and validate again, at most 3 rounds (Contract: Limits); if issues remain, show them to the user before continuing.
8. Commit the design documents (Contract: Commits) and run `spec-meta.sh stage <spec> code`.

If scope was Design, go to Step 13.

## Code (Steps 9–10)

9. Read the Phase Overview table in GLOBAL.md. Sequential phases run in order; a parallel group `{k}A, {k}B, …` runs as one layer followed by its merge phase `{k}.5`.
10. For each phase:
   - Detect the language from the PLAN and call `dotclaude:coders:coder-{language}` with the phase id and the PLAN path.
   - Call code-validator once with the worktree path, the coder namespace, the phase id, and the PLAN/TEST/GLOBAL paths. It owns the validate-fix loop (Contract: Validate-fix loop).
   - On PASS, commit the phase (Contract: Commits). On FAIL the validator has already marked the phase Skipped in GLOBAL.md; record the error and continue with the next phase.
   - After the last phase, run `spec-meta.sh stage <spec> local_test`.

   For a parallel group, first create one worktree per phase (`../{project_name}-{type}-{keyword}-{phase}` on branch `{type}/{keyword}-{phase}` forked from `{type}/{keyword}`), then call the coders for all phases of the group in a single message so they run concurrently, each told its own worktree path. When all return, run the merge phase as written in `PHASE_{k}.5_PLAN_MERGE.md`: merge each branch into `{type}/{keyword}` with `--no-edit`, resolve conflicts, run the validator for the merge phase, commit, then remove the group's worktrees.

If scope was Design → Code, skip Step 11.

## Docs (Step 11)

Call technical-writer in its DOCS_UPDATE role with the commits since the last tag and the target version. It updates CHANGELOG.md and, when the work changed something user-visible, README.md. Commit (Contract: Commits).

## Integration (Step 12)

Ask: "How would you like to integrate this work?" with options Direct Merge and Create PR. Direct Merge runs the `/dotclaude:merge` procedure, which also removes the worktree and sets `stage: done`. Create PR runs the `/dotclaude:pr` procedure, which sets `stage: pr` and leaves the worktree until the PR is merged.

Before stopping for any reason, write one line for the next session with `spec-meta.sh handoff <spec> "..."` (what was done, what is next, anything decided in conversation), and record operating decisions with `spec-meta.sh decision <spec> add <token>`.

## Summary (Step 13)

Report once, at the end, in the configured language:

```yaml
status: SUCCESS | PARTIAL | FAILED
work_type: feature | bugfix | refactor
branch: {type}/{keyword}
scope: Design | Design → Code | Design → Code → Docs
spec: {working_directory}/{doc_dir}/SPEC.md   # approved, target_version
phases:
  - { phase: "1", status: SUCCESS, commit: abc123 }
  - { phase: "3B", status: SKIPPED, error: "..." }
docs_updated: [CHANGELOG.md, README.md]
integration: { method: merge | pr | none, pr_url: ..., merged_to: ... }
issues: [...]
next_steps: [...]
```

Then list what the user should do next: for merge, review the log and push `base_branch`, then `/dotclaude:tagging`; for a PR, review it at its URL; for design only, review the documents and run `/dotclaude:code` when ready.

## Errors

If an agent call or a git command fails in a way the workflow does not define (not a validator FAIL, which is handled in Step 10), stop the chain, report the error and the step, and suggest how to resume: Steps 6–13 can be re-entered by invoking `/dotclaude:design`, `/dotclaude:code`, `/dotclaude:update-docs`, `/dotclaude:merge`, or `/dotclaude:pr` directly.

Do not enter plan mode during init. Requirements are gathered with AskUserQuestion and approved at Step 3; plan mode would add a second approval that interrupts the flow.
