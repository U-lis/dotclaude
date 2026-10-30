---
description: Entry point for starting new work. Runs the full workflow from requirements to integration, asking the user at each checkpoint.
---
# /dotclaude:start-new [text | github-url | #N | JIRA-KEY] [--prefill "<text>"]

You are the orchestrator for one unit of work: gather requirements, get SPEC.md approved, design, implement phase by phase, update docs, run the configured test stages, and integrate. The shared rules (configuration, language, naming, worktree, who does what, checkpoints, commits, retry policy, git safety) are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`. Read it once at the start and follow it; this file only describes the order of steps.

You interact with the user through AskUserQuestion. You run git yourself. You call agents with the Agent tool and never write SPEC.md, design documents, or code yourself (Contract: Who does what). Prompt templates for each agent call are in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`. At the start of each step print one line, `[Step {N}/13] {step name}: {current action}`, so the user can follow progress. Step numbers are kept stable across versions; Steps 1–2 are both performed by init. Step 5 no longer exists: Steps 1–4 are init, 6–8 design, 9–10 code, 11 docs, 12 stages and integration, 13 summary.

## Step 0: Resume or start

Run `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh find` in the current directory. If it finds a SPEC.md whose `stage` is set and not `done`, this is a resume: show the user the `handoff` line and the `decisions` tokens if any, then continue from that stage (`spec_review` → Step 3, `design` → Step 6, `code` → Step 9 at the first phase that is not Complete, `local_test`/`test_deploy`/`remote_test`/`pr` → Step 12) without asking anything else. Otherwise start new work.

## Init (Steps 1–4)

**Steps 1–2. Intake, work type, analysis, SPEC draft.** `Skill("dotclaude:init")` with the arguments as given: free text, a GitHub issue or PR URL or `#N`, a Jira key, `--prefill "<text>"`, or nothing. init infers and confirms the work type, creates the worktree and branch, analyzes the codebase, asks one combined question for whatever is still missing (target version included, when the project has a CHANGELOG or `version_files`), and has technical-writer write SPEC.md with `stage: spec_review`. `--prefill` text must be quoted on the command line; if the arguments look truncated (only one word after the flag), stop and tell the user instead of guessing.

After init returns, check that `git worktree list` contains `../{project_name}-{type}-{keyword}`, that the current branch is `{type}/{keyword}`, and that `{working_directory}/{doc_dir}/SPEC.md` exists in that worktree. If a check fails, stop and report what is missing; do not re-run init, because it already asked the user questions once.

**Step 3. SPEC review.** Two methods, chosen by config `spec_review` (default `editor`):

- `editor`: open the SPEC for the user with `xdg-open` (Linux), `open` (macOS), or `$EDITOR`, in the background so the session is not blocked, and say in chat that you are waiting for approval or change requests. The user replies in chat; any clear affirmative ("approved", "승인", "spec confirmed", "go") is approval, anything else is feedback. This is what users did anyway: in the recorded sessions a third of the Approve dialogs were dismissed and approval came as a chat sentence after reading the file in an editor.
- `ask`: summarize SPEC.md and AskUserQuestion with Approve or Needs Revision.

On feedback, call technical-writer with it and review again (at most 3 rounds, Contract: Limits). If the SPEC's Decisions Required table still has open rows, resolve them in the same exchange; a recommended option is still the user's choice.

**Step 4. Approve and commit.** Run `spec-meta.sh approve <spec>` (records `approved_at`, `approved_hash`, `stage: design`), then commit SPEC.md (Contract: Commits). This is the only SPEC commit.

## Before design

Check, in the worktree: the branch is `{type}/{keyword}` and not `base_branch`; `spec-meta.sh check-approved <spec>` exits 0 (the SPEC body is the approved one); `git rev-parse --show-toplevel` ends with `{project_name}-{type}-{keyword}`. If any check fails, stop and report. These checks exist because every later step writes into this worktree and commits on this branch.

## Design (Steps 6–8)

6. Call designer with the SPEC path. It returns architecture decisions, the phase breakdown with dependencies, and per-phase checklists. If it returns open questions instead, ask the user and call it again.
7. Call technical-writer with the designer output and the target directory. It writes GLOBAL.md, `PHASE_{k}_PLAN_{keyword}.md`, `PHASE_{k}_TEST.md`, and `PHASE_{k}.5_PLAN_MERGE.md` for parallel groups. Then call pruner in doc mode on the PLAN and TEST files; if it reports candidates, call technical-writer to apply them. Then call spec-validator; on issues, call technical-writer with the report and validate again, at most 3 rounds (Contract: Limits); if issues remain, show them to the user before continuing.
8. Commit the design documents (Contract: Commits) and run `spec-meta.sh stage <spec> code`.

## Code (Steps 9–10)

9. Read the Phase Overview table in GLOBAL.md. Sequential phases run in order; a parallel group `{k}A, {k}B, …` runs as one layer followed by its merge phase `{k}.5`.
10. For each phase:
   - Detect the language from the PLAN and call `dotclaude:coders:coder-{language}` with the phase id and the PLAN path.
   - Call code-validator once with the worktree path, the coder namespace, the phase id, and the PLAN/TEST/GLOBAL paths. It owns the validate-fix loop (Contract: Validate-fix loop).
   - On PASS, commit the phase (Contract: Commits). On FAIL the validator has already marked the phase Skipped in GLOBAL.md; record the error and continue with the next phase.
   - After the last phase, run `spec-meta.sh stage <spec> local_test`.

   For a parallel group, first create one worktree per phase (`../{project_name}-{type}-{keyword}-{phase}` on branch `{type}/{keyword}-{phase}` forked from `{type}/{keyword}`), then call the coders for all phases of the group in a single message so they run concurrently, each told its own worktree path. When all return, run the merge phase as written in `PHASE_{k}.5_PLAN_MERGE.md`: merge each branch into `{type}/{keyword}` with `--no-edit`, resolve conflicts, run the validator for the merge phase, commit, then remove the group's worktrees.

## Docs (Step 11)

Call technical-writer in its DOCS_UPDATE role with the commits since the last tag and the target version. It updates CHANGELOG.md and, when the work changed something user-visible, README.md. Commit (Contract: Commits).

## Run stages (Step 12)

After Docs, take `local_test`, `test_deploy`, and `remote_test` from config `stages`, in that order. For each:

- If the command is empty, record the stage as "not configured" and move on.
- Otherwise run the command from the worktree root and run `spec-meta.sh stage <spec> <name>`. On a non-zero exit, stop the chain and report the stage name and the command output. The user decides what happens next; do not fix anything automatically.
- If `stop_after` is `local_test`, stop after that stage (whether it ran or was not configured), report, and wait.

After `remote_test`, or after the last configured stage, stop and report which stages passed and which were not configured. Wait for the user to say "proceed" (any clear go-ahead) before integration. When `stop_after` is `pr`, do not wait; continue to integration directly.

Integration follows config `integration`. `pr` runs the `/dotclaude:pr` procedure, which sets `stage: pr` and leaves the worktree until the PR is merged. `merge` runs the `/dotclaude:merge` procedure, which removes the worktree and sets `stage: done`.

Before stopping for any reason, write one line for the next session with `spec-meta.sh handoff <spec> "..."` (what was done, what is next, anything decided in conversation), and record operating decisions with `spec-meta.sh decision <spec> add <token>`.

## Summary (Step 13)

Report once, at the end, in the configured language:

```yaml
status: SUCCESS | PARTIAL | FAILED
work_type: feature | bugfix | refactor
branch: {type}/{keyword}
spec: {working_directory}/{doc_dir}/SPEC.md   # approved, target_version
phases:
  - { phase: "1", status: SUCCESS, commit: abc123 }
  - { phase: "3B", status: SKIPPED, error: "..." }
docs_updated: [CHANGELOG.md, README.md]
stages:
  - { name: local_test, status: passed | failed | not configured | skipped }
  - { name: test_deploy, status: not configured }
  - { name: remote_test, status: not configured }
integration: { method: merge | pr | none, pr_url: ..., merged_to: ... }
issues: [...]
next_steps: [...]
```

Then list what the user should do next: for merge, review the log and push `base_branch`, then `/dotclaude:tagging`; for a PR, review it at its URL; after a failed stage, fix the cause and re-run the stage command, then say "proceed".

## Errors

If an agent call or a git command fails in a way the workflow does not define (not a validator FAIL, which is handled in Step 10), stop the chain, report the error and the step, and suggest how to resume: Steps 6–13 can be re-entered by invoking `/dotclaude:design`, `/dotclaude:code`, `/dotclaude:update-docs`, `/dotclaude:merge`, or `/dotclaude:pr` directly.

Do not enter plan mode during init. Requirements are gathered with AskUserQuestion and approved at Step 3; plan mode would add a second approval that interrupts the flow.
