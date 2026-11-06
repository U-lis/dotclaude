# Phase 5: Test Matrix

Verification is by execution with the worktree plugin: one `/dotclaude:code {k}` on a scratch work and one `/dotclaude:pr` dry path up to 9f. Rows go to `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`.

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| The phase-review prompt has `Depth: phase` and the table is appended under `## Phase {k}` in `{doc_dir}/REVIEW.md` | FR-10 | normal | scenario | - | - |
| The pre-integration prompt has `Depth: pr`, target, ticket key and round directory, and `## Full diff` holds the pointer line | FR-10 | normal | scenario | - | - |
| `/dotclaude:pr` Review notes list PR-depth issue rows with `file:line`, ordered Blocker, Major, Minor | FR-10 | normal | scenario | - | - |
| `/dotclaude:pr` Review notes also carry the Major and Minor rows from phase reviews in `{doc_dir}/REVIEW.md` that the PR-depth report does not list (same location and finding), and omit duplicates | NFR-4 | normal | scenario | - | - |
| 9f computes target and ticket key, creates the next `r{n}` directory per Contract: Names and paths, and the reviewer prompt carries `Depth: pr`, target, ticket key and that path | FR-10 | normal | scenario | - | - |
| Each reviewer prompt (phase review, pre-integration, 9f) contains the ledger path and the id prefix (`{doc_dir}-p{k}` or `{target}-r{n}`); after the run the ledger has `finding` lines with that prefix | FR-10 | normal | scenario | - | - |
| A second `/dotclaude:pr` run at the same HEAD makes no new reviewer call | FR-10 | boundary | scenario | - | - |
| With Blockers above 0 there is exactly one coder fix, one validator run and one re-review; a phase with Blockers left is set `Blocked` and stops the chain | NFR-4 | normal | scenario | - | - |
| The commit guard still requires `.validated/PHASE_{k}` | NFR-4 | permission | integration | - | - |

---

## Mock / Stub Requirements

- A scratch work with a phase plan for `/dotclaude:code {k}`, and a branch with a PR for the `/dotclaude:pr` dry path.
