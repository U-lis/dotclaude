# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| A reviewer Write to `{WD}/reviews/X/r1/STATUS.md` records the agent_id to path pair; a later Write to `r2/STATUS.md` by the same agent leaves it unchanged | FR-4 | normal | unit | - | - |
| Bound reviewer, Restatement filled, makes the same intent MCP call or SPEC Read as before: allowed | FR-4 | normal | unit | - | - |
| Bound reviewer, Restatement empty, calls a Jira/Notion-like MCP tool: denied with restatement-first message | FR-4 | invalid | unit | - | - |
| Bound reviewer, Restatement empty, Reads `SPEC.md` or `PHASE_1_PLAN_x.md`: denied | FR-4 | invalid | unit | - | - |
| Non-reviewer agent or main session (`agent_type` other or null) makes the same calls while a STATUS.md exists: no output | FR-4 | permission | unit | - | - |
| Non-reviewer call with no binding and no STATUS.md: no output | FR-4 | permission | unit | - | - |
| Unreadable STATUS.md path or malformed hook input: no output (fail open) | FR-4 | error | unit | - | - |
| Two reviewers with different agent_ids bound to different STATUS.md, one filled and one empty, make the same MCP call: first allowed, second denied | FR-4 | concurrency | integration | - | - |
| `r1` restatement does not open the `r2` gate for an agent bound to `r2` of the same target | FR-4 | concurrency | integration | - | - |
| Unbound reviewer calls an intent MCP tool: denied with message naming STATUS.md and Restatement; SPEC and PLAN Reads allowed | FR-4 | boundary | unit | - | - |
| MCP tool outside the globs is never denied; configured `review.intent_tools` replaces the default globs | FR-4 | boundary | unit | - | - |
| Top-level `{WD}/review-ledger.log` over 100KB, untracked, older than 24h stays in place after `files apply` | NFR-1 | boundary | integration | - | - |
| `bash tests/hooks/run_all.sh` includes the new test file and prints `ALL PASSED` | NFR-1 | normal | integration | - | - |
| E1: `--plugin-dir` loads the worktree plugin (guard-review line in `.hook.log`) and the same-name collision is recorded | FR-4 | normal | scenario | - | - |
| E2: plugin `hooks.json` hook fires for a `dotclaude:reviewer` subagent with `agent_type` populated | FR-4 | normal | scenario | - | - |
| E3: reviewer without `tools:` can call an MCP tool and the deny JSON blocks it | FR-4 | permission | scenario | - | - |
| E4: two reviewers launched in one message receive different `agent_id` values | FR-4 | concurrency | scenario | - | - |
| E5: the reviewer Write input carries the absolute STATUS.md path in `tool_input.file_path` | FR-4 | normal | scenario | - | - |
| E6: the hook writes its binding store under `${TMPDIR:-/tmp}` in a real session | FR-4 | error | scenario | - | - |

---

## Mock / Stub Requirements

- Hook input JSON fixtures built per case; `mk_fixture` from `tests/hooks/_fixture.sh`; `TMPDIR` pointed at the fixture directory.
- A fake `review.intent_tools` config in the fixture for the glob-override row.
