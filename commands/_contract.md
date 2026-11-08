---
description: Single definition of the rules every dotclaude command and agent shares. Internal reference; other files point here instead of restating these rules.
user-invocable: false
---
# dotclaude Contract

Every rule below is defined once, here. Commands and agents reference a section by name (for example "see Contract: Commits") and do not restate it. If a command or agent file appears to contradict this file, this file wins.

## Configuration

Values resolve in this order, later entries overriding earlier ones: built-in defaults, `~/.claude/dotclaude-config.json`, `$CLAUDE_CONFIG_DIR/dotclaude-config.json` (when set; this is the global config file to write when it is set), `<git_root>/.claude/dotclaude-config.json`, then the `dotclaude-config` metadata block at the top of the work's `SPEC.md`.

| Key | Default | Meaning |
|-----|---------|---------|
| `working_directory` | `.dc_workspace` | Directory for work documents, relative to the repository root |
| `workspace_tracking` | `commit` | `commit` tracks `{working_directory}` in git, except `*/.validated/`, `*/evidence/`, `review-ledger.log`, `knowledge/` and `reviews/`, which stay ignored; `ignore` keeps it in `.gitignore` and takes snapshots instead of commits (see Commits) |
| `workspace_size_ignore` | `[]` | Globs matched against top-level entries of `{working_directory}` (e.g. `2026_06_29-exam-vision-eval`, `ONE-*`), and `YYYY_MM_DD-{name}` also matches when `{name}` does; matches are left out of the Stop hook's 10MB size warning and of `/dotclaude:purge` archiving. A primary checkout full of doc dirs is `workspace_size_warn_primary`'s case: `*` here would also turn off the worktree warning and purge archiving |
| `workspace_size_warn_primary` | `true` | `false` turns off the Stop hook's 10MB size warning when the session's worktree is the primary checkout; worktree warnings, `workspace_size_ignore`, `/dotclaude:purge` archiving, and the uncommitted-code block do not change |
| `workspace_archive_dir` | unset | Where `/dotclaude:purge` puts files moved out of `{working_directory}`, as `{dir}/{primary checkout name}/{doc_dir}/...`; `~` expands. Unset means purge asks, and never chooses |
| `base_branch` | `main` | Branch that work branches fork from and merge into |
| `language` | `en_US` | Language of user-facing text (see Language) |
| `version_files` | `[]` | Files checked by `/dotclaude:tagging`; empty means auto-detect |
| `title_prefix` | `false` | Put `[확인요청]`/`[INPUT]` in the terminal title while waiting for the user |
| `spec_review` | `editor` | How SPEC approval is collected: `editor` (open the file, approve in chat) or `ask` (AskUserQuestion) |
| `default_work_type` | unset | `feature`, `bugfix`, or `refactor`; when set, init does not ask to confirm the inferred type |
| `stages.local_test` | `""` | Shell command run from the worktree root after Docs; empty means the stage is skipped and reported as "not configured" |
| `stages.test_deploy` | `""` | Same, run after `local_test` (for example a deploy to a test environment) |
| `stages.remote_test` | `""` | Same, run after `test_deploy` (for example tests against that environment) |
| `stages.stop_after` | `remote_test` | Where start-new stops and waits for the user: `local_test`, `remote_test`, or `pr` (`pr` means no stop before integration) |
| `integration` | `pr` | How finished work is integrated: `pr` (the `/dotclaude:pr` procedure) or `merge` (the `/dotclaude:merge` procedure) |
| `pr.labels` | `[]` | Labels added to the pull request besides the branch-prefix label |
| `pr.assignee` | `@me` | Pull request assignee; empty means none |
| `pr.reviewers` | `[]` | Pull request reviewers |
| `parallel_phases` | false | Allow the designer to propose parallel phase groups ({k}A/{k}B plus merge {k}.5); when false, phases are sequential unless the user asks |
| `worktree.share_from_base` | `true` | Init symlinks dependency directories from the primary checkout into the new worktree (see Worktree) |
| `review.intent_tools` | `["*jira*","*atlassian*","*notion*"]` | Globs, matched case-insensitively against MCP tool names, of the intent tools `hooks/guard-review.sh` denies the reviewer until its restatement is written |
| `knowledge_dirs` | `[]` | Directories of existing research documents the reviewer searches besides `{primary}/{working_directory}/knowledge/` (see Knowledge records); `~` expands |

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
stage: spec_review           # see State
approved_at: null            # ISO time of SPEC approval
approved_hash: null          # sha256 of the SPEC body (below this block) at approval
decisions: []                # operating decisions that must survive a new session
handoff: ""                  # one line for the next session
-->
```

A command that runs without SPEC.md uses the config files, then defaults; `worktree_path` falls back to `.` and `doc_dir` to the keyword.

Read and write the block with `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh` (`find`, `get`, `set`, `stage`, `approve`, `check-approved`, `handoff`, `decision`). The script edits only the block, so the SPEC body and its approval hash are untouched.

## State

The SPEC metadata block is the work's state. A new session reads it before asking anything, so decisions made in an earlier session are not lost.

`stage` moves forward through `init → spec_review → design → code → local_test → test_deploy → remote_test → pr → done`. The command that completes a stage sets the next one: init sets `spec_review` when SPEC.md is drafted; SPEC approval sets `design`; the design commit sets `code`; the last phase commit sets `local_test`; `/dotclaude:pr` sets `pr`; `/dotclaude:merge` sets `done`. Stages that a project does not use are passed through without stopping.

**Approval** is recorded as `approved_at` plus `approved_hash`, the hash of the SPEC body below the block. Approval holds while the body is unchanged; editing the body after approval requires a new review, while editing the block (stage, handoff, decisions) does not. `spec-meta.sh check-approved` makes that judgment; a PreToolUse hook denies calling the designer agent when it fails.

**Requirement checkboxes** in SPEC.md are owned by code-validator: when a phase passes, it checks off the `FR`/`NFR` items that phase's PLAN lists under Requirements. A merged work therefore has every requirement checked, and an unchecked one points at the phase that did not deliver it.

`{working_directory}/RULES.md` holds the project's coding rules (template `${CLAUDE_PLUGIN_ROOT}/templates/RULES.md`); init creates it when missing and never overwrites it; coders and the reviewer read it, code-validator does not.

`decisions` holds short tokens for operating decisions that would otherwise live only in conversation (for example `stacked-pr`, `deploy-before-merge`); commands read them before acting. `handoff` is one line the current session leaves for the next.

GLOBAL.md Phase Overview Status uses `Not Started`, `In Progress`, `Complete`, `Skipped`, `Blocked`. A phase whose review leaves Blockers open after one fix round is `Blocked`; the chain stops there.

## Language

The SessionStart hook prints `[dotclaude] language: {code}`. If it printed nothing, the language is `en_US`.

Written in the configured language: everything the user reads directly. That is conversation, AskUserQuestion labels and descriptions, status and error messages, reports, `SPEC.md`, the PR-depth review report (`REVIEW.md` of a review round directory), and pull request titles and bodies.

Written in English regardless of the setting: documents that only agents consume and project-facing files. That is `GLOBAL.md`, `PHASE_*_PLAN_*.md`, `PHASE_*_TEST.md`, `PHASE_*.5_PLAN_MERGE.md`, agent-to-agent reports, `CHANGELOG.md`, `README.md`, code, comments, and commit messages.

Reason: SPEC.md is the one document the user reviews and approves, so it must be in their language. The rest is read by agents or by the project's public audience, where English is the common form.

## Names and paths

| Item | Form | Example |
|------|------|---------|
| Work type | `feature`, `bugfix`, `refactor` | |
| Branch | `{type}/{keyword}` | `feature/user-auth` |
| Worktree | `../{project_name}-{type}-{keyword}` | `../shop-feature-user-auth` |
| Document directory | `{working_directory}/{doc_dir}` with `doc_dir = $(date +%Y_%m_%d)-{keyword}` | `.dc_workspace/2026_03_01-user-auth` |
| Documents | `SPEC.md`, `GLOBAL.md`, `PHASE_{k}_PLAN_{keyword}.md`, `PHASE_{k}_TEST.md`, `PHASE_{k}.5_PLAN_MERGE.md`, `REVIEW.md`, `EVIDENCE.md` (GLOBAL.md is omitted for proportional work) | |
| Phase id | sequential `{k}`, parallel `{k}A`/`{k}B`, merge `{k}.5` | `3A`, `3.5` |
| Parallel worktree | `../{project_name}-{type}-{keyword}-{phase}` on branch `{type}/{keyword}-{phase}` forked from `{type}/{keyword}` | |
| Review round directory | `{primary}/{working_directory}/reviews/{YYYY_MM_DD}-{target}/r{n}/`, holding only `REVIEW.md`, `STATUS.md`, `EVIDENCE.md` and the `.log` outputs its EVIDENCE rows cite | `.dc_workspace/reviews/2026_11_06-ONE-7384/r2/` |

Preserve documents (`/dotclaude:purge`) adds today's date prefix to an undated doc dir copied from a removed worktree, unless the primary already has that name. A follow-up wave of the same subject gets a new date-prefixed directory; names like `SPEC_W2.md`, `referral__2`, or `GLOBAL_v2.md` are not created. Reports are not files: no `COMPLETION_REPORT.md`, `FINAL_REPORT.md`, `PROGRESS.md`, `VALIDATION.md`; results go to chat and the PR body. Only documents (`.md`, `.json`, `.log`) live in `{working_directory}`; data files go elsewhere. `hooks/guard-workspace.sh` enforces the file types and the name rules.

`{project_name}` is the directory name of the repository root. `{keyword}` is a short kebab-case slug derived from the work description.

A review round directory is the single place a PR-depth review writes. `{primary}` is the primary checkout, also when the review runs from a worktree. `{target}` is the first match of: a Jira key `[A-Z][A-Z0-9]+-[0-9]+` in the PR title, the same pattern in the head branch name, `pr-{N}`, the branch keyword (the part after `{type}/`), the full branch name; a matched Jira key is also the ticket key. The date is the run date, as in the document directory, and the path carries no time of day, so a run on a later date starts again at `r1`. `n` is 1 + the highest existing `r*` under that day's directory (1 when there is none); the orchestrator creates it with `mkdir` (no `-p`) and, if it already exists, retries with n+1, so two concurrent runs on the same target and day get different rounds; it passes only the path. The reviewer reads no other round directory, earlier rounds included.

## Worktree

Work never happens on `base_branch` and never in the primary checkout. Init creates the work branch with `git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}` after `git checkout {base_branch} && git pull origin {base_branch}`, verifies the directory exists, and changes into it. `git checkout -b` and `git switch -c` are not substitutes: the primary checkout is the user's and must stay on `base_branch`.

With `worktree.share_from_base` true, init also links `.venv`, `venv`, `node_modules`, `target`, and `vendor` from the primary checkout into the worktree as relative symlinks, for each that exists in the primary and not in the worktree.

Before a worktree is removed, files in its `{working_directory}` that the primary checkout's `{working_directory}` lacks are copied to the primary, so documents of finished work survive the removal. `/dotclaude:purge` defines this once (Preserve documents) and `/dotclaude:merge` uses it.

The worktree is removed by `/dotclaude:merge` after a successful merge, or by `/dotclaude:purge` once the branch is merged and deployed. `/dotclaude:pr` leaves it in place until the PR is merged.

## Who does what

The command that the user invoked is the orchestrator. It asks the user questions, runs git, and calls agents. It does not write SPEC.md, design documents, or code itself, because those files carry the quality rules encoded in the agent definitions.

| Work | Agent |
|------|-------|
| SPEC.md, GLOBAL/PLAN/TEST/MERGE documents, CHANGELOG and README updates, applying a pruner report to documents | `dotclaude:technical-writer` |
| Architecture decisions and phase decomposition | `dotclaude:designer` |
| Consistency check across SPEC/GLOBAL/PLAN/TEST | `dotclaude:spec-validator` |
| Implementing a phase, fixing validation errors, applying a pruner report to tests | `dotclaude:coders:coder-{language}` (`dotclaude:coders:coder-generic` for languages without a dedicated coder) |
| Validating a phase and owning its validate-fix loop | `dotclaude:code-validator` |
| Finding redundant tests and over-long comments (report only) | `dotclaude:pruner` |
| Reviewing a change on the five axes (correctness, scope, safety, maintainability, tests): phase depth after validator PASS (table only), PR depth before integration and for pull requests (report, re-runs and evidence rows in its review round directory) | `dotclaude:reviewer` |
| Reading many files or searching the codebase to answer a question | the built-in `Explore` agent |

Agents run with a fresh context and cannot ask the user anything. When an agent needs a decision, it stops and returns the question in its report; the orchestrator asks the user and calls the agent again with the answer.

Answer the user from evidence: do not agree with or praise a claim you have not checked.

The orchestrator calls agents with the `Agent` tool and `subagent_type` set to the names above. The prompt carries the task and the paths; the agent's own definition supplies its rules.

## Models

Agent definitions name a model family, never a dated model id, so the plugin follows whatever the current generation is.

| Agents | `model` |
|--------|---------|
| designer, coders, reviewer | `opus` |
| technical-writer, spec-validator, code-validator, pruner | `sonnet` |

Lookups and wide reads go to `Explore` with `model: haiku` or `sonnet`. The main session decides; agents produce.

## Checkpoints

These are the points where the orchestrator waits for the user, through AskUserQuestion, before continuing. Permission settings such as auto mode do not remove them, because each one fixes the scope of the work.

1. SPEC review: approval in chat after the file is opened in an editor (`spec_review: editor`) or an Approve / Needs Revision question (`ask`). Revision loops through technical-writer, at most 3 times.
2. SPEC "decisions required" items: the user picks, even when SPEC names a recommended option.
3. Go-ahead after the run stages, before integration: the user says "proceed" in chat. It is skipped when `stages.stop_after` is `pr`.

Phase decomposition does not need user review: after SPEC approval, design runs through designer, technical-writer, and spec-validator, and coding starts when spec-validator passes. After SPEC approval, Design, Code, and Docs always run as one set; there is no scope question. Between chained steps the orchestrator does not stop to ask "what next". When designer returns `OPEN` items (unconfirmed symbols, more than 4 phases, work outside the SPEC requirements), the orchestrator asks the user all of them in one AskUserQuestion and calls designer again with the answers. For proportional work (SPEC has at most 2 FR and the design touches at most 3 files: one PLAN, one TEST, no GLOBAL.md), the orchestrator records `spec-meta.sh decision <spec> add proportional` and may skip spec-validator; code-validator still runs.

## Commits

| When | What | Message |
|------|------|---------|
| After SPEC approval, once | `{working_directory}/{doc_dir}/SPEC.md` | `docs: add SPEC.md for {keyword}` |
| After design documents are written and pruned | `{working_directory}/{doc_dir}/*.md` | `docs: add design documents for {keyword}` |
| After code-validator returns PASS for a phase | changed code plus the PLAN, GLOBAL, TEST, SPEC, REVIEW, and `EVIDENCE.md` documents the coder, validator, and reviewer updated | `feat/fix/refactor({keyword}): complete phase {k}` |
| After CHANGELOG/README update | `CHANGELOG.md`, `README.md`, and the last phase's EVIDENCE.md hash edit | `docs: update CHANGELOG and README for {version}` |

No commit happens without the validator's PASS for that phase, and no version number changes outside `/dotclaude:tagging`. The orchestrator commits; agents do not. Two hooks enforce this: a PreToolUse guard denies `git commit` of code on a work branch unless `{working_directory}/{doc_dir}/.validated/PHASE_{k}` exists for the phase named in the message (documents-only commits pass), and the Stop hook refuses to end a turn while the session's own worktree, on a work branch, holds uncommitted code. Commit messages for phases therefore always contain `phase {k}`. The `.validated/` marker directory is git-ignored: it is a local signal for the commit guard and is never committed.

When `workspace_tracking` is `ignore`, document files are untracked and cannot be committed; each design commit point instead runs `mkdir -p {working_directory}/.snapshots && tar -czf {working_directory}/.snapshots/$(date +%Y%m%d-%H%M%S).tar.gz -C {working_directory} {doc_dir}` and keeps the newest 5 files in `.snapshots/` (`ls -1t {working_directory}/.snapshots/*.tar.gz | tail -n +6 | xargs -r rm --`).

## Evidence

`{working_directory}/{doc_dir}/EVIDENCE.md` records checks that someone else can repeat and get the same result. Its first writer creates it from `${CLAUDE_PLUGIN_ROOT}/templates/EVIDENCE.md`; each writer appends rows to its own section: the coder (`## coder`), the orchestrator, one row per run stage it ran (`## orchestrator (run stages)`), and a verification session outside the dotclaude flow, which uses the same form (`## verification session`). The reviewer reads `{doc_dir}/EVIDENCE.md` and never writes it, because it lies inside the worktree under review; its own rerun rows go to the `EVIDENCE.md` of its review round directory.

- A row without a command and a raw output path is not evidence; it is read as a claim.
- Raw outputs are saved as `.log` files under `{working_directory}/{doc_dir}/evidence/` (a reviewer's under its round directory), never under a temporary or session path. That directory and the reviewer's round directories are git-ignored (`{working_directory}/*/evidence/` and `{working_directory}/reviews/`), so raw outputs stay on the machine that ran the check and a row is checked there; the row's raw output path is relative to the repository root.
- A row written while its phase is still uncommitted carries `phase {k} (uncommitted)` in the commit column; right after the phase commit the orchestrator replaces that value with the commit hash in EVIDENCE.md, and the row then counts as evidence for that commit. That edit is committed with the next phase's commit, or with the CHANGELOG/README docs commit after the last phase.
- Secrets (credentials, tokens, cookies, env dumps) are redacted from raw output before it is saved: raw outputs are not committed, yet they are read by later sessions and agents.
- EVIDENCE.md rows are committed, so a row states the check and its result only; it does not quote code, findings or data from a repository other than the one being worked on (a run of a dotclaude agent against another repository is such a case). Where the raw output lives in the other repository's review round directory, the row cites that path.
- A row whose commit differs from the head under review is stale evidence: it shows the behavior at that commit only.
- A team member's PR has no EVIDENCE.md; its CI results and the test statements in its PR body are read as claims.

## Review ledger

`{primary}/{working_directory}/review-ledger.log` is one append-only event log for every review of the repository, also when the review runs from a worktree. Each line is one event, tab-separated, in this field order:

```
finding  id date target depth axis kind location severity verdict must_see
disposition  id disposition defer_class cross later date
```

- `finding`: one line per issue row of a report. `id` is `{prefix}-{row}`, `{row}` being the row's `#`, so it is known without reading the ledger; the caller passes the prefix as `Finding id prefix`: `{YYYY_MM_DD}-{target}-r{n}` at pr depth, the same date, target and round as the round directory, and `{doc_dir}-p{k}-r{m}` at phase depth, `m` being the review call number within the phase (1 for the first call, 2 after the Blocker fix), so no two reviews share an id. `date` is `YYYY-MM-DD`; `depth` is `phase` or `pr`; `kind` is one of missing, unexplained, mismatch, side-effect, risk, reinvention, untested, defect; `verdict` is the report's verdict, `-` at phase depth; `must_see` is `yes` when the row is also under 사람이 직접 봐야 하는 곳, otherwise `no`.
- `disposition`: points at a finding `id`. `disposition` is one of Finding dispositions; `defer_class` is `silent` or `loud` for `deferred`, otherwise `-`; `cross` is `coderabbit`, `human` or `none` (who else raised it); `later` is `missed` or `false-alarm` once known, otherwise `-`.

The reviewer appends `finding` lines when it reports, at both depths; commands append `disposition` lines when the user states a disposition in the session, and leave the rest to a later retrospective. Both write with a shell append (`printf 'finding\t%s\t...\n' ... >> {ledger}`), never with Write or Edit. The reviewer never reads the ledger. A line is never edited: a changed disposition is a new line and a re-review adds new `finding` lines, so reversals stay visible.

Count check, run by the command after each reviewer call: count the `finding` lines whose id starts with `{prefix}-` before and after the call; the increase must equal the report's issue rows (rows with severity Blocker, Major or Minor). On a mismatch, report the difference to the user and leave the ledger as it is.

## Knowledge records

Inputs are the directories in `knowledge_dirs` and `{primary}/{working_directory}/knowledge/` (the primary checkout's, also from a worktree). A record is one file `{date}-{target}-{n}.md` holding one fact line, its `file:line`, the confirmed commit and the source review (round directory); no guesses. No index is stored or built. The reviewer searches the inputs only for the change's changed paths and symbols and reads only the matching files. Before citing a record it checks the code still says so; when `git log {confirmed commit}..{head} -- {path}` lists commits, or the confirmed commit is not in the repository (`git cat-file -e {confirmed commit}` fails), the record is marked 오래됨 and not cited as fact.

After a pr-depth review the command writes each fact under 새로 알게 된 것 of the report as a new record, without asking, only into `{primary}/{working_directory}/knowledge/` and never into a `knowledge_dirs` directory, `{n}` being 1 + the highest existing for that date and target.

## Finding dispositions

A finding on your own work is `accepted`, `deferred`, `rebutted` or `ignored` (`ignored` for duplicates and noise). A deferral needs a repro result (command and its output) and a class; without them the deferral is not accepted and the finding stays open. A silent omission (a result that is wrong or missing without an error) cannot be deferred; it is fixed, or a guard that raises an error is added so it becomes loud. A loud failure (an error the user sees) may be deferred: it is listed as a known limitation under `## Deferred` of `{working_directory}/{doc_dir}/REVIEW.md`, one row per finding with finding id, repro command, raw output path and class. Call a failure loud only after every input shape was checked. The PR body does not change. PR-depth callers pass the `## Deferred` rows as `Deferred`, and the reviewer reproduces each and judges its class again.

## Validate-fix loop

code-validator owns the loop for one phase: validate, and on failure call the coder with the error list, then validate again, for at most 3 attempts in total. After the third failure it marks the phase `Skipped` in GLOBAL.md and returns FAIL. The orchestrator calls the validator once per phase, does not retry around it, and on FAIL records the error and continues with the next phase. The only other loops are the bounded ones in Limits (SPEC revision, analysis refinement, spec-validator rounds).

## Git safety

`git reset --hard`, `git checkout -- <path>`, `git restore`, and `git stash` are not used to undo agent work, because they destroy uncommitted changes that may belong to another step. Revert by restoring from an explicit backup or `git show HEAD:<path>`. Never force-push. Never delete branches with `-D`.

The pruner never modifies files and its Bash use is read-only. The reviewer never modifies the reviewed code, branch, or worktree; it writes only to its review round directory (`REVIEW.md`, `STATUS.md`, its own `EVIDENCE.md` rows, `.log` outputs), its temporary worktree, and the `finding` lines it appends to the review ledger.

## Limits

| Limit | Value |
|-------|-------|
| Questions during init | 2 AskUserQuestion calls: work-type confirmation and one combined question for missing information |
| SPEC revision loop | 3 |
| Codebase reads during init analysis | 10 files |
| Validate-fix attempts per phase | 3 |
| spec-validator rounds (validate, fix, validate) | 3 |
| New parallel worktrees per phase group | one per parallel phase |
