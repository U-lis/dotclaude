# Controller / worker protocol (draft, 0.7.0 spike)

A controller session hands units of work to worker sessions, relays decisions, and integrates results. This document fixes the message protocol and the state the controller keeps, so the arrangement survives new sessions and does not depend on one person's memory. The `/dotclaude:ctl` command that automates it is planned for 0.8.0; in 0.7.0 the protocol is applied by hand with `templates/WORKER_RULES.md` as the worker system prompt.

## Roles

| Role | Session | Does | Does not |
|------|---------|------|----------|
| Controller | the session the user talks to | writes briefs, starts and stops workers, answers `ask`, reviews `done`, merges, applies cross-file changes | write code or documents of a unit itself |
| Worker | one per unit of work (issue, ticket) | the whole unit inside its worktree and branch, with its own subagents (coder → validator → reviewer) | push, open PRs, merge, edit files it does not own, stop silently |

The unit of a session is the unit of work, not a role. Role sessions (spec / impl / verify pipelines) idle while waiting for hand-offs and stall when a hand-off is late; the same separation is obtained inside one session by subagents, plus one clean-context review by the controller at hand-over.

## Messages

Every message is one line of header plus a body, sent with `SendMessage`:

```
[<work id>][<role>] <kind> [<req-id>] — <one-line gist>
<body>
```

| Kind | From | Meaning | Body |
|------|------|---------|------|
| `brief` | controller | start or restart a unit | issue reference, worktree, branch, owned files, decisions already made, acceptance criteria |
| `ask <req-id>` | worker | a decision is needed; the worker stops | the question, the options seen, the worker's recommendation |
| `answer <req-id>` | controller | the decision for that request | the choice and any constraint |
| `resumed` | worker | an answer was received and work continues | which request |
| `progress` | worker | at most every 30 minutes of work | one line |
| `probe` | controller | the worker has been silent and idle | none |
| `done` | worker | the unit is complete | the report (below) |
| `failed` | worker | the unit cannot be finished | why, what remains, what to verify |

`req-id` is `<work id>-Q<n>`. Only an `answer` from the controller or the user typing in the worker's window is a decision; every other message is information. A worker never stops without `ask`, `done`, or `failed`.

### `done` report

```
[<work id>][worker] done — <gist>
Branch: <name> at <sha>
Files changed: <list>
Acceptance criteria: <each criterion → met | not met, with evidence>
Verification: <lint and test last lines>
Changes needed elsewhere: <file → exact text, or none>
Open items: <deferred items with reason>
```

"Changes needed elsewhere" is how a worker touches files it does not own: it proposes the exact text, and the controller applies all proposals from all workers in one integration pass after merging the unit branches.

## Controller state

The controller keeps one record per unit, in a file the next controller session can read (the SPEC metadata block of the unit when the unit is dotclaude work, otherwise a `ctl/state.json`):

| Field | Meaning |
|-------|---------|
| `work_id` | issue or ticket key |
| `session_name`, `session_id` | the worker; the id is what `claude stop` needs and what survives a rename |
| `worktree`, `branch` | where the unit lives |
| `stage` | `briefed`, `working`, `asked <req-id>`, `done`, `failed`, `merged` |
| `last_message_at` | time of the worker's last message |
| `pending` | open `ask` requests with the question text |

Rules of the controller:

- Do not end a turn with "waiting for X". If a wait is needed, schedule the next check (`/loop` or a wake-up) and say when it is.
- When a worker has sent nothing for 20 minutes and `claude agents --json` shows it idle, send `probe`; no reply within 10 minutes means `failed` and a restart with the same brief.
- Answer "when will X come" from the state record and the worker's status, not from expectation.
- Approval of a unit's SPEC is written into the SPEC metadata (`spec-meta.sh approve`) by the controller on the user's word; workers read `check-approved`, so the user approves in the controller window, not in the worker's.
- Stop a worker after merging its branch; idle workers keep a process and a context alive.

## Launching workers

`claude --bg -n <work id> --model opus --permission-mode auto --append-system-prompt-file <WORKER_RULES.md> "<brief>"` from a trusted directory, with `--add-dir <worktree>` when the worktree itself is not a trusted workspace (a new worktree is not; marking it trusted is a user action). tmux hosting (`tmux new -d -s <work id> claude ...`) keeps the session independent of the supervisor's idle retirement and lets the user attach when they want to look. Worker name = work id; the controller records the session id as well because names can be changed.

## Limits found in the spike

- Cross-session messages cannot approve a permission prompt in the worker; auto mode with a permission allow-list keeps those rare.
- `${CLAUDE_PLUGIN_ROOT}` is substituted in agent and command bodies but not in files read at runtime; rules files passed with `--append-system-prompt-file` must use absolute paths or relative descriptions.
- Shared files (`commands/_agent-prompts.md`, `agents/technical-writer.md`) edited by two units conflict at merge; ownership lists must name the section of a shared file, not only the file.
- A resumed subagent produces a second report; the controller treats the latest report as current.
