# Phase 3: Test Matrix

Verification is by execution runs (NFR-2) with the worktree plugin: Zero-X-Flow/1Hour_Back #3493 and #3459 at an early head commit. Rows are recorded in `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Phase-depth call prints a table with axes 1, 4, 5 as `n/a (phase depth)`, ends with exactly `BLOCKERS: {n}`, is in English, and the transcript has no Bash execution other than the ledger append and no read of knowledge, open PRs or evidence | FR-1 | normal | scenario | - | - |
| PR-depth call: first tool call is a Write of `{round}/STATUS.md`; `.hook.log` shows no allowed intent MCP call and no allowed SPEC Read before the Restatement has content | FR-2 | normal | scenario | - | - |
| Report shows impact targets labelled 영향 있음/없음/확인 불가 with evidence, the fixed risk-zone checklist, a reinvention search with terms for each new function/class/query, Jira comments in time order, and existing PR comments as "교차 확인됨" | FR-2 | normal | scenario | - | - |
| A finding without `file:line`, search result or intent sentence is reported as a question, not an issue | FR-2 | invalid | scenario | - | - |
| Round REVIEW.md is in ko_KR with the header (verdict, 3-5 line summary, 사람이 직접 봐야 하는 곳 with `file:line` and reason, 대충 봐도 되는 곳), FR-3 sections in order, issue rows with `file:line` and severity, ends with exactly `BLOCKERS: {n}`, `FAIL` only when n >= 1 | FR-3 | normal | scenario | - | - |
| A change with no findings yields PASS and every axis marked `checked` or `n/a` | FR-3 | boundary | scenario | - | - |
| The caller prompt (template) carries only target, ticket key and round directory with no intent text, and the reviewer reads PRD/Jira itself | FR-5 | normal | scenario | - | - |
| With Jira or Notion absent or blocked, the source is listed under "확인하지 못한 것" and the review still completes | FR-5 | error | scenario | - | - |
| Re-runs happen in a temporary worktree gone at the end (`git worktree list` identical before and after), and rows go to `{round}/EVIDENCE.md` with `{doc_dir}/EVIDENCE.md` unchanged | FR-7 | normal | scenario | - | - |
| Environment that cannot start (no docker, missing Makefile target) is recorded as "실행하지 못함" with the reason and no tunnel substitute | FR-7 | error | scenario | - | - |
| A tunnel-only or shared-DB check appears as "실행 요청" and is not executed | FR-7 | permission | scenario | - | - |
| For #3459 the report catches the 3-level nested prefix bug (CR-5) and the findings that returned as CR-2/6/10/12; any miss is recorded in the EVIDENCE row | NFR-2 | normal | scenario | - | - |
| An evidence row without a command or raw output is reported under axis 5 and not counted as evidence | FR-2 | invalid | scenario | - | - |
| An evidence row whose commit differs from the reviewed head is reported as stale evidence | FR-2 | boundary | scenario | - | - |
| The reviewer transcript has no `gh` write call (`gh pr comment`, `gh api -X POST`) | NFR-3 | permission | scenario | - | - |
| `git -C {target worktree} status --porcelain` is unchanged after a run and nothing is written outside the round directory, the round EVIDENCE.md, the temporary worktree and the ledger `finding` appends | NFR-3 | permission | scenario | - | - |
| After a PR-depth run against a scratch ledger path and id prefix, the ledger gains exactly one tab-separated `finding` line per report issue row, ids `{prefix}-{row}`, in the GLOBAL Data Model format; a pre-existing scratch line stays byte-identical (sha256 of old prefix) (FR-12 reviewer side) | FR-3 | normal | scenario | - | - |
| A phase-depth run also appends one `finding` line per finding with the phase id prefix `{doc_dir}-p{k}`; a run with no findings appends nothing (FR-12 reviewer side) | FR-3 | boundary | scenario | - | - |
| The reviewer transcript shows the ledger touched only by a shell `printf ... >>` append: no Read of it and no Write or Edit call on it (FR-12 reviewer side) | FR-3 | permission | scenario | - | - |
| `docs/ARCHITECTURE.md:39` no longer says "Report-only"; `scripts/lint-prompts.sh` exits 0 with the total under 220000 bytes | FR-1 | boundary | scenario | - | - |

---

## Mock / Stub Requirements

- Local docker DB and test settings of the 1Hour_Back repository for re-run rows.
- A run with the Jira/Notion MCP absent or blocked (for the error row).
- A scratch ledger file with one pre-existing line, and a hand-made id prefix passed in the prompt (for the append rows).
