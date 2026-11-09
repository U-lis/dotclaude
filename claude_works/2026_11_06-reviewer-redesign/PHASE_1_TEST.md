# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| A reviewer Write to `{WD}/reviews/X/r1/STATUS.md` records the agent_id to path pair; a later Write to `r2/STATUS.md` by the same agent leaves it unchanged | FR-4 | normal | unit | tests/hooks/test_guard_review.sh:28-40 | hooks/guard-review.sh:66 (binding write, noclobber); :60, :63 (round path) |
| Bound reviewer, Restatement filled, makes the same intent MCP call or SPEC Read as before: allowed | FR-4 | normal | unit | tests/hooks/test_guard_review.sh:64-67 | hooks/guard-review.sh:97-100 |
| Bound reviewer, Restatement empty, calls a Jira/Notion-like MCP tool: denied with restatement-first message | FR-4 | invalid | unit | tests/hooks/test_guard_review.sh:44-46, :51 | hooks/guard-review.sh:85-86, :102 |
| Bound reviewer, Restatement empty, Reads `SPEC.md` or `PHASE_1_PLAN_x.md`: denied | FR-4 | invalid | unit | tests/hooks/test_guard_review.sh:47-49 | hooks/guard-review.sh:74, :102 |
| Non-reviewer agent or main session (`agent_type` other or null) makes the same calls while a STATUS.md exists: no output | FR-4 | permission | unit | tests/hooks/test_guard_review.sh:55-60 | hooks/guard-review.sh:17 |
| Non-reviewer call with no binding and no STATUS.md: no output | FR-4 | permission | unit | tests/hooks/test_guard_review.sh:98, :100-104 | hooks/guard-review.sh:16 (no jq call, test :104); test :98 has no single pin, :16 and :17 each suffice |
| Unreadable STATUS.md path or malformed hook input: no output (fail open) | FR-4 | error | unit | tests/hooks/test_guard_review.sh:92-94 | hooks/guard-review.sh:96 (unreadable); malformed (test :93) has no single pin, fail-open by construction |
| Two reviewers with different agent_ids bound to different STATUS.md, one filled and one empty, make the same MCP call: first allowed, second denied | FR-4 | concurrency | integration | tests/hooks/test_guard_review.sh:69-73 | hooks/guard-review.sh:80, :102 |
| `r1` restatement does not open the `r2` gate for an agent bound to `r2` of the same target | FR-4 | concurrency | integration | tests/hooks/test_guard_review.sh:74 | hooks/guard-review.sh:80 (lookup by agent_id), :102 |
| Unbound reviewer calls an intent MCP tool: denied with message naming STATUS.md and Restatement; SPEC and PLAN Reads allowed | FR-4 | boundary | unit | tests/hooks/test_guard_review.sh:77-82 | hooks/guard-review.sh:90-92 |
| MCP tool outside the globs is never denied; configured `review.intent_tools` replaces the default globs | FR-4 | boundary | unit | tests/hooks/test_guard_review.sh:50, :82, :84-88 | hooks/guard-review.sh:84-86 |
| Top-level `{WD}/review-ledger.log` over 100KB, untracked, older than 24h stays in place after `files apply` | NFR-1 | boundary | integration | tests/hooks/test_workspace_archive.sh:90, :94 | hooks/workspace-archive.sh:318 with :108 and the ARCHIVED.md write; no single-line deletion fails it (see Notes) |
| `bash tests/hooks/run_all.sh` includes the new test file and prints `ALL PASSED` | NFR-1 | normal | integration | tests/hooks/run_all.sh:5 (glob `test_*.sh`) | - |
| E1: `--plugin-dir` loads the worktree plugin (guard-review line in `.hook.log`) and the same-name collision is recorded | FR-4 | normal | scenario | PHASE_1_PLAN Notes E1 | - |
| E2: plugin `hooks.json` hook fires for a `dotclaude:reviewer` subagent with `agent_type` populated | FR-4 | normal | scenario | PHASE_1_PLAN Notes E2 | - |
| E3: reviewer without `tools:` can call an MCP tool and the deny JSON blocks it | FR-4 | permission | scenario | PHASE_1_PLAN Notes E3 | - |
| E4: two reviewers launched in one message receive different `agent_id` values | FR-4 | concurrency | scenario | PHASE_1_PLAN Notes E4 | - |
| E5: the reviewer Write input carries the absolute STATUS.md path in `tool_input.file_path` | FR-4 | normal | scenario | PHASE_1_PLAN Notes E5 | - |
| E6: the hook writes its binding store under `${TMPDIR:-/tmp}` in a real session | FR-4 | error | scenario | PHASE_1_PLAN Notes E6 | - |

---

## Mock / Stub Requirements

- Hook input JSON fixtures built per case; `mk_fixture` from `tests/hooks/_fixture.sh`; `TMPDIR` pointed at the fixture directory.
- A fake `review.intent_tools` config in the fixture for the glob-override row.
