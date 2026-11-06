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

- [x] The hook sources `_lib.sh` and uses `json_get`, `cfg_get`, `cfg_get_list`, `match_any_glob`, `deny_pretool` without copying their logic: verified in hooks/guard-review.sh:11
- [x] The first decision is a string check for `"dotclaude:reviewer"` before any `jq` or `python3` call: verified in hooks/guard-review.sh:16
- [x] A reviewer Write to `.../{WD}/reviews/X/r1/STATUS.md` creates the binding file for its `agent_id`; a later Write to `r2/STATUS.md` does not change it: verified in hooks/guard-review.sh:66
- [x] Bound reviewer with empty Restatement: an intent MCP tool, a `SPEC.md` Read and a `PHASE_1_PLAN_x.md` Read are each denied; with content all three are allowed: verified in hooks/guard-review.sh:97
- [x] The `r1` restatement does not open the `r2` gate for a different agent bound to `r2`: verified in hooks/guard-review.sh:80
- [x] Concurrency: agent A filled and agent B empty making the same MCP call, A gets no output and B gets a deny: verified in tests/hooks/test_guard_review.sh:72
- [x] Unbound reviewer: intent MCP call denied with a message naming STATUS.md and Restatement; SPEC and PLAN Reads allowed: verified in hooks/guard-review.sh:89
- [x] Silent cases: `agent_type` null/missing/other, non-reviewer call with no binding and no STATUS.md, malformed JSON, unreadable STATUS.md: verified in hooks/guard-review.sh:16
- [x] An MCP tool outside the globs (e.g. `mcp__slack__x`) is never denied; `review.intent_tools` in config replaces the default globs: verified in hooks/guard-review.sh:86
- [x] The header states both known limitations: verified in hooks/guard-review.sh:6
- [x] The hook is registered with matcher `Write|Read|mcp__.*`: verified in hooks/hooks.json:38
- [x] A 100KB+ untracked 24h+ old top-level `review-ledger.log` stays in place after `files apply`, and `hooks/workspace-archive.sh` is unchanged: verified in tests/hooks/test_workspace_archive.sh:90
- [x] `guard-review.sh` is listed with a one-line description: verified in docs/ARCHITECTURE.md:66

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

- Experiment records (E1-E6), run 2026-11-06 with Claude Code 2.1.319. Scratch material (prompts, outputs, logs) is in `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/`, outside the worktree.
  - Setup: scratch git repo `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj` with `.dc_workspace/2026_11_06-demo/SPEC.md` and empty round dirs `.dc_workspace/reviews/2026_11_06-demo/r1`, `r2` (run 2 adds `r3`). For both runs `agents/reviewer.md` in the worktree was a temporary copy without the `tools:` line, with `model: sonnet` and the body line "Marker word: WORKTREE-REVIEWER-E1"; the original was restored afterwards (`git diff --stat agents/reviewer.md` empty). A tap hook given through `--settings /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/tap-settings.json` logged raw `tool_name`, `agent_type`, `agent_id`, `tool_input.file_path` to `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/tap.log`.
  - Run 1 (E1, E2, E4, E5, E6; E3 attempt): `cd /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj && claude -p "$(cat /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/main_prompt.txt)" --plugin-dir /home/ulismoon/Documents/dotclaude/dotclaude-feature-reviewer-redesign --settings /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/tap-settings.json --allowedTools "Read Write Edit Agent mcp__notion__authenticate" --model sonnet --debug=hooks,plugins --debug-file /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/debug.log < /dev/null`. The main session launched two `dotclaude:reviewer` Agent calls in one message: A writes `r1/STATUS.md` with an empty Restatement, Reads SPEC, fills the Restatement, Reads SPEC again; B writes `r2/STATUS.md`, Reads SPEC, never fills. Both call `mcp__notion__authenticate` before and after. Output: `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/run1.out`.
  - Run 2 (E3 deny part): `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj/.claude/dotclaude-config.json` set `"review": {"intent_tools": ["*godot__get_godot_version*"]}`; `cd /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj && claude -p "$(cat /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/main_prompt2.txt)" --plugin-dir <worktree> --settings /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/tap-settings.json --allowedTools "Read Write Edit Agent ToolSearch mcp__godot__get_godot_version" --model sonnet --debug=hooks --debug-file /tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/debug2.log < /dev/null`. One reviewer: call the tool, write `r3/STATUS.md` empty, call, fill, call. Output: `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/run2.out`.
  - E1 (pass): `--plugin-dir <worktree>` loads the worktree plugin, and with the same name it shadows the installed `dotclaude@dotclaude` 0.8.2 (enabled, user scope, per `claude plugin list`; its `hooks/hooks.json` has no `guard-review`) for that session. Proof: `.hook.log` in `/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj/.dc_workspace` has `2026-11-06T08:33:29Z guard-review bind a63dfa19eb400c97a .../r1/STATUS.md`; `debug.log` attributes every plugin hook to `(plugin dotclaude@inline)` with the worktree path, e.g. `Hooks: PreToolUse:Read ["/home/ulismoon/Documents/dotclaude/dotclaude-feature-reviewer-redesign"/hooks/guard-review.sh] (plugin dotclaude@inline) finished with status 0`; `grep -c plugins/cache/dotclaude debug.log` = 0, so no installed-plugin hook ran; both reviewer replies begin with `WORKTREE-REVIEWER-E1`, so the agent definition also came from the worktree. Workaround: none needed; the installed plugin was not touched.
  - E2 (pass): the plugin `hooks.json` hook fired for the subagent with `agent_type` populated. tap.log: `{"tool_name":"Read","agent_type":"dotclaude:reviewer","agent_id":"a816973d2a1f29a09","file_path":".../2026_11_06-demo/SPEC.md"}`; the same call returned `PreToolUse:Read hook error: Restatement first: the ## Restatement section of .../r2/STATUS.md is empty. ...` to reviewer B and was not executed.
  - E3 (pass with a substitute tool; Notion not confirmable here): in the nested `-p` session `mcp__notion__authenticate` was not exposed (`<tool_use_error>Error: No such tool available: mcp__notion__authenticate</tool_use_error>`; the harness said notion needs authentication; no tap.log line, so no hook ran for it). The reviewer without `tools:` did inherit MCP tools: it listed `mcp__slack__*`, `mcp__godot__*`, `mcp__claude_ai_Google_Drive__*`, `mcp__claude_ai_Claude_Docs__*`. Run 2 with `mcp__godot__get_godot_version` as the configured intent tool: step 1 (unbound) `PreToolUse:mcp__godot__get_godot_version hook error: Restatement first: create STATUS.md in the round directory ...`; step 3 (bound, empty) `... the ## Restatement section of .../r3/STATUS.md is empty ...`; step 5 (filled) returned `4.7.2.stable.official.ed1daf0bf`. `.hook.log`: `guard-review deny aec17ef3f5e085927 mcp__godot__get_godot_version unbound`, `guard-review bind aec17ef3f5e085927 .../r3/STATUS.md`, `guard-review deny aec17ef3f5e085927 mcp__godot__get_godot_version`, `guard-review allow aec17ef3f5e085927 mcp__godot__get_godot_version`. The deny JSON blocks an MCP call before it runs. A Notion or Jira call was not observed.
  - E4 (pass): the two reviewers launched in one message had `agent_id` `a63dfa19eb400c97a` (r1) and `a816973d2a1f29a09` (r2) (`.hook.log` bind lines, both 08:33:29Z). After A filled r1, A's SPEC Read was allowed (`guard-review allow a63dfa19eb400c97a Read ...`) while B stayed denied (`guard-review deny a816973d2a1f29a09 Read ...`).
  - E5 (pass): the reviewer Write input carried the absolute path: tap.log `{"tool_name":"Write","agent_type":"dotclaude:reviewer","agent_id":"a63dfa19eb400c97a","file_path":"/tmp/claude-1000/-home-ulismoon-Documents-dotclaude/dbbc667f-1c50-4c17-a5cf-2e6e9a4ebf40/scratchpad/phase1/proj/.dc_workspace/reviews/2026_11_06-demo/r1/STATUS.md"}`.
  - E6 (pass): `TMPDIR` was unset in the hook environment, so the store went to `/tmp`: `ls -la /tmp/dotclaude-review-1000/` showed `drwx------` with files `a63dfa19eb400c97a` and `a816973d2a1f29a09`, contents the r1 and r2 STATUS.md paths. The second Write by A (filling the Restatement) did not rebind. The store was removed after recording.
- Archive test pin: deleting `hooks/workspace-archive.sh:318` alone, or `:318` together with `-mindepth 1` at `:108`, still passes, because `archive_one` cannot write `ARCHIVED.md` under a file entry and keeps the source. An injected `rm` of top-level files at `:318` makes it fail (`FAIL: top-level review-ledger.log stays in place`). The test pins the composite behavior, not one line.
- Rejected designs: most-recent-directory guess, pointer file, shared bindings log, `{WD}/reviews/.agents/` (GLOBAL AD-1).
