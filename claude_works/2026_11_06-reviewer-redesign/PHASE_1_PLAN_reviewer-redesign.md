# Phase 1: reviewer-redesign - restatement gate hook, tests, experiments

## Objective

Add the PreToolUse hook `hooks/guard-review.sh` that enforces the restatement gate (GLOBAL AD-1), its tests, a ledger-stays-in-place archive test, and run experiments E1-E6 that confirm the assumptions the later phases depend on.

## Requirements

- FR-4
- NFR-1

---

## Prerequisites

- Worktree `/home/ulismoon/Documents/dotclaude/dotclaude-feature-reviewer-redesign` exists; baseline `bash tests/hooks/run_all.sh` prints `ALL PASSED` and `scripts/lint-prompts.sh` exits 0.
- `claude` CLI with `--plugin-dir` (line 163 of `claude --help`).

---

## Scope

### In Scope
- `hooks/guard-review.sh`, its registration, tests, the archive test case, the ARCHITECTURE.md hook line, experiments E1-E6.

### Out of Scope
- `hooks/workspace-archive.sh` and `hooks/guard-workspace.sh` (no change; AD-1, AD-4, AD-8).
- Reviewer prompt, evidence form, commands (phases 2-6).

---

## Instructions

### Step 1: Write the hook

**Files**: `hooks/guard-review.sh` (new)

**Action**: Model on `hooks/guard-design.sh:3-6` and `:24-35` (`exec 2>/dev/null`, source `_lib.sh`, fail open, `log_line` to `{primary}/{WD}/.hook.log`). Implement GLOBAL AD-1 exactly: string check for `"dotclaude:reviewer"` before any jq/python call; then `json_get` for `agent_type`, `agent_id`, `tool_name`, `tool_input.file_path`; Write binding for `*/{WD}/reviews/*/r[0-9]*/STATUS.md` (first binding wins, store under `${TMPDIR:-/tmp}/dotclaude-review-$(id -u)/{sanitized agent_id}`); gate for bound reviewer (intent MCP globs via `cfg_get_list review.intent_tools` defaulting to `*jira* *atlassian* *notion*`, Read of `SPEC.md` or `PHASE_*_PLAN_*.md` while `## Restatement` has no non-blank non-comment line); unbound reviewer denies intent MCP calls with a message naming STATUS.md and Restatement and allows SPEC/PLAN Reads; unreadable STATUS.md allows. `WD` is resolved with `HOOK_CWD` set to the nearest existing parent of the target path. The header comment states both known limitations.

### Step 2: Register the hook

**Files**: `hooks/hooks.json`

**Action**: Add a PreToolUse entry (array at lines 19-43) with matcher `Write|Read|mcp__.*` running `guard-review.sh`, in the same command form as the neighbouring entries.

### Step 3: Hook tests

**Files**: `tests/hooks/test_guard_review.sh` (new)

**Action**: Model on `tests/hooks/test_guard_design.sh:1-19` using `mk_fixture` from `tests/hooks/_fixture.sh`; set `TMPDIR=$T`. Cover every row of PHASE_1_TEST.md. Confirm `tests/hooks/run_all.sh` picks the new file up.

### Step 4: Archive test

**Files**: `tests/hooks/test_workspace_archive.sh`

**Action**: Add a case: an untracked top-level `{WD}/review-ledger.log` over 100KB and older than 24h stays in place after `files apply`. Do not modify `hooks/workspace-archive.sh`.

### Step 5: Architecture doc

**Files**: `docs/ARCHITECTURE.md`

**Action**: Add a `guard-review.sh` line with a one-line description to the hooks tree (lines 59-67), next to `guard-design.sh` at line 65.

### Step 6: Experiments E1-E6

**Action**: Run with the worktree plugin and record command, output and result for each in this file's Notes (phase 2 copies them into the work's EVIDENCE.md).
- E1: `claude -p --plugin-dir <worktree> ...` loads the worktree plugin, not installed 0.8.1; proof is a `guard-review` line in `.hook.log`. Record the same-name collision behavior and the workaround.
- E2: a plugin `hooks.json` hook fires for a `dotclaude:reviewer` subagent and receives `agent_type`.
- E3: the reviewer with no `tools:` line can call an MCP tool, and the hook deny JSON blocks it. Use a Notion MCP tool (no Jira/Atlassian server in this session).
- E4: two reviewers launched in one message get different `agent_id` values (read from the log).
- E5: `tool_input.file_path` of the reviewer Write is the absolute STATUS.md path.
- E6: the hook can write its binding store under `${TMPDIR:-/tmp}` in a real session.

Experiments need a reviewer without the `tools:` line (AD-2). For this phase only, use a temporary copy of the agent definition in the worktree plugin; the full rewrite is phase 3.

---

## Implementation Notes

### Fail-open
Every internal error (missing jq, unreadable file, malformed JSON) exits 0 with no output, consistent with existing hooks.

### Fallback
If E2, E3 or E4 fails, stop the phase and report; the orchestrator takes the two-call reviewer alternative to the user because it changes phases 3-5.

---

## Completion Checklist

- [ ] The hook sources `_lib.sh` and uses `json_get`, `cfg_get`, `cfg_get_list`, `match_any_glob`, `deny_pretool` without copying their logic: `hooks/guard-review.sh`
- [ ] The first decision is a string check for `"dotclaude:reviewer"` before any `jq` or `python3` call: `hooks/guard-review.sh`
- [ ] A reviewer Write to `.../{WD}/reviews/X/r1/STATUS.md` creates the binding file for its `agent_id`; a later Write to `r2/STATUS.md` does not change it: `hooks/guard-review.sh`
- [ ] Bound reviewer with empty Restatement: an intent MCP tool, a `SPEC.md` Read and a `PHASE_1_PLAN_x.md` Read are each denied; with content all three are allowed: `hooks/guard-review.sh`
- [ ] The `r1` restatement does not open the `r2` gate for a different agent bound to `r2`: `hooks/guard-review.sh`
- [ ] Concurrency: agent A filled and agent B empty making the same MCP call, A gets no output and B gets a deny: `tests/hooks/test_guard_review.sh`
- [ ] Unbound reviewer: intent MCP call denied with a message naming STATUS.md and Restatement; SPEC and PLAN Reads allowed: `hooks/guard-review.sh`
- [ ] Silent cases: `agent_type` null/missing/other, non-reviewer call with no binding and no STATUS.md, malformed JSON, unreadable STATUS.md: `hooks/guard-review.sh`
- [ ] An MCP tool outside the globs (e.g. `mcp__slack__x`) is never denied; `review.intent_tools` in config replaces the default globs: `hooks/guard-review.sh`
- [ ] The header states both known limitations: `hooks/guard-review.sh`
- [ ] The hook is registered with matcher `Write|Read|mcp__.*`: `hooks/hooks.json`
- [ ] A 100KB+ untracked 24h+ old top-level `review-ledger.log` stays in place after `files apply`, and `hooks/workspace-archive.sh` is unchanged: `tests/hooks/test_workspace_archive.sh`
- [ ] `guard-review.sh` is listed with a one-line description: `docs/ARCHITECTURE.md`

---

## Verification

### Manual Verification
```bash
bash tests/hooks/run_all.sh
bash scripts/lint-prompts.sh
```

### Expected Output
```
ALL PASSED
(lint exits 0)
```
E1-E6 each recorded with command, output and result in Notes.

---

## Notes

- Experiment records (E1-E6): to be filled in by the coder.
- Rejected designs: most-recent-directory guess, pointer file, shared bindings log, `{WD}/reviews/.agents/` (GLOBAL AD-1).
