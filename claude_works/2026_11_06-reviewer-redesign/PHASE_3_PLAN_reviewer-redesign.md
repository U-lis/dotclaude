# Phase 3: reviewer-redesign - reviewer rewrite and prompt template

## Objective

Rewrite `agents/reviewer.md` as one agent with `Depth: phase | pr` (GLOBAL AD-2, AD-3, AD-5, AD-8 for the finding lines it appends), update the reviewer prompt template, narrow the contract rules that conflict, and verify by execution runs (NFR-2).

## Requirements

- FR-1
- FR-2
- FR-3
- FR-5
- FR-7
- NFR-2
- NFR-3

---

## Prerequisites

- Phase 1 completed (gate and binding format; E1 method for loading the worktree plugin).
- Phase 2 completed (evidence form and Contract: Evidence).

---

## Scope

### In Scope
- Full rewrite of `agents/reviewer.md`, the reviewer template in `commands/_agent-prompts.md`, three `_contract.md` edits, `docs/ARCHITECTURE.md:39`, and the NFR-2 execution runs.

### Out of Scope
- Round directory naming rules in `_contract.md` (phase 4), command wiring (phases 4-5), knowledge search, deferred re-check and read limits in the reviewer (phase 6).

---

## Instructions

### Step 1: Rewrite the reviewer

**Files**: `agents/reviewer.md`

**Action**: Replace the whole file (old lines 1-69). Remove the frontmatter `tools:` line (AD-2) and update the description. Content:
- Phase depth: reads SPEC and the phase PLAN only; fills axes 2 (scope) and 3 (safety), answers axes 1, 4, 5 as `n/a (phase depth)`; reads no knowledge, open PRs or evidence; runs nothing except appending its `finding` lines to the ledger (single exception, AD-8); table in English; last line exactly `BLOCKERS: {n}` (FR-1).
- PR depth, first action: Write `{round}/STATUS.md` with the AD-3 skeleton (Target with head sha and base, Restatement, Progress), then the Restatement from the diff and surrounding code only. Then steps 2-6 of FR-2 in order: intent comparison in both directions with Jira comments read in time order and PRD/Jira conflicts raised as questions; impact investigation with each target labelled 영향 있음/없음/확인 불가 plus evidence, the fixed risk-zone checklist (migrations, permissions, default changes, secrets, payments and settlement, outbound sends); reinvention search for each new function, class or query with search terms, treating the coder's "Existing implementations" as claims; evidence comparison and local re-run; dedupe against existing PR comments marked "교차 확인됨". A finding without evidence (`file:line`, search term and result, or intent sentence) becomes a question.
- Intent sources (FR-5): the reviewer reads PRD, Jira description and comments, SPEC, and the GitHub issue (SPEC `github_issue` or PR-body link) itself; the caller supplies only target, ticket key and round directory. An unreadable source goes under "확인하지 못한 것" and scope is judged only against what was read.
- Local re-run (FR-7): test runner, isolated test DB, or server on local docker, in a temporary worktree removed at the end; local config even if the default start command uses a tunnel; start-up method found in the target repo's Makefile, README, CLAUDE.md; missing edges written as test code inside the temporary worktree; tunnel/shared DB checks, QA, sends, deploys are only output as "실행 요청"; if the environment cannot start, record the reason as "실행하지 못함" with no tunnel substitute. Never modify the target branch (P4).
- Report (FR-3): write `{round}/REVIEW.md` in the configured language with the header (verdict `PASS|PASS+NOTES|FAIL`, 3-5 line summary, "사람이 직접 봐야 하는 곳" with `file:line` and the reason for each, "대충 봐도 되는 곳"), sections in order: 재진술, `1 correctness` to `5 tests` (each `checked`, `n/a` or `issue`, an issue stated once under the first axis that explains it), 같이 생각할 점, 확인하지 못한 것, 새로 알게 된 것. Issue rows carry `file:line` and Blocker/Major/Minor. `FAIL` only when Blockers >= 1. Last line exactly `BLOCKERS: {n}`.
- Evidence rows go only to `{round}/EVIDENCE.md` with raw outputs as `.log` files in the round directory; `{doc_dir}/EVIDENCE.md` is read, never written (AD-5).
- Ledger (AD-8, FR-3 report): after the report, at both depths, appends one `finding` line per finding to the ledger path given in the prompt, using an append-only shell write (`printf ... >>`), one line per finding, in the format of the GLOBAL Data Model "Ledger lines" block. Ids are `{id prefix from the prompt}-{row}`, row being the finding's order in the report. It never reads the ledger and never rewrites it (no Write tool on it). It writes no `disposition` lines.
- Writes only to the round directory, the reviewer section of the round EVIDENCE.md, its temporary worktree and the appended `finding` lines of the ledger; no GitHub writes; no changes to the target worktree (NFR-3).
- States the two known limitations of the gate (AD-1).

### Step 2: Prompt template

**Files**: `commands/_agent-prompts.md`

**Action**: In the reviewer template keep the existing path fields (Worktree, Base or Diff source, SPEC, RULES, PLAN paths) and add Depth, target, ticket key, round directory, the deferred list, the ledger path (`{primary}/{working_directory}/review-ledger.log`) and the finding id prefix (`{target}-r{n}` at PR depth, `{doc_dir}-p{k}` at phase depth); only intent text is excluded. This is the enabler for FR-10 (phase 5).

### Step 3: Contract edits

**Files**: `commands/_contract.md`

**Action**: Language section: add the PR-depth report to the configured-language list. Who does what section: the reviewer is no longer "report only". Git safety section: narrow the rule so the reviewer never modifies the reviewed code or worktree and writes only to the round directory, its EVIDENCE section, its temporary worktree and `finding` lines appended to the ledger (SPEC conflict resolution).

### Step 4: Architecture doc

**Files**: `docs/ARCHITECTURE.md`

**Action**: Replace "Report-only five-axis diff review" (the reviewer line) with a description of the two depths and the write scope.

### Step 5: Execution runs (NFR-2)

**Action**: Using the E1 method (`claude --plugin-dir` with the worktree), run the new reviewer on Zero-X-Flow/1Hour_Back #3493 and on #3459 at an early head commit without its existing review comments. Run once with the Jira/Notion MCP absent or blocked. Record rows in `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md` (new form); for #3459 record which of the 3-level nested prefix bug (CR-5) and the deferred findings that came back as CR-2/6/10/12 were caught and which were missed.

---

## Implementation Notes

### Prompt budget
The rewritten reviewer must stay near the size of the old file; shared rules are referenced by section name (GLOBAL Risk 3). Prompt files stay in English except that report headings quoted in Korean are the user-facing contract.

### Gate compatibility
The Restatement heading in the skeleton must be exactly `## Restatement` (the hook parses it).

---

## Completion Checklist

- [ ] The frontmatter has no `tools:` line and the description names both depths: `agents/reviewer.md`
- [ ] Phase depth section: axes 1, 4, 5 answered `n/a (phase depth)`, no execution, no knowledge/PR/evidence reads, last line `BLOCKERS: {n}`: `agents/reviewer.md`
- [ ] PR depth names Write of `STATUS.md` with the Target/Restatement/Progress skeleton as the first action: `agents/reviewer.md`
- [ ] PR depth lists the FR-2 steps in order, the risk-zone checklist, the three impact labels, reinvention search with terms, and "교차 확인됨" dedupe: `agents/reviewer.md`
- [ ] Intent sources are read by the reviewer and unreadable ones go under "확인하지 못한 것": `agents/reviewer.md`
- [ ] Local re-run rules: temporary worktree removed at the end, local config, "실행 요청" for tunnel/shared checks, "실행하지 못함" with reason, no edits to the target branch: `agents/reviewer.md`
- [ ] Report format sections, header and verdict rule (`FAIL` only when Blockers >= 1) match FR-3, ending with `BLOCKERS: {n}`; phase table stays English: `agents/reviewer.md`
- [ ] Evidence rows without a command or raw output are reported under axis 5 and not counted as evidence, and rows whose commit differs from the reviewed head are reported as stale evidence: `agents/reviewer.md`
- [ ] Evidence rows are written only to `{round}/EVIDENCE.md`; `{doc_dir}/EVIDENCE.md` is read-only; no `gh` write commands; both known gate limitations are stated: `agents/reviewer.md`
- [ ] At both depths the reviewer appends one `finding` line per finding with `printf ... >>` to the ledger path from the prompt, with id `{prefix}-{row}`; it never reads or rewrites the ledger and does not use Write on it; the allowed write set names this append: `agents/reviewer.md`
- [ ] The reviewer template keeps the Worktree, Base or Diff source, SPEC, RULES and PLAN path fields, adds Depth, target, ticket key, round directory, deferred list, ledger path and finding id prefix, and carries no intent text: `commands/_agent-prompts.md`
- [ ] Language lists the PR-depth report; Who does what no longer says report only; Git safety is narrowed as specified: `commands/_contract.md`
- [ ] The line no longer says "Report-only": `docs/ARCHITECTURE.md`

---

## Verification

### Manual Verification
```bash
bash scripts/lint-prompts.sh
git worktree list            # before and after a run: identical
git -C <target worktree> status --porcelain   # unchanged by the run
```

### Expected Output
```
lint exits 0, prompt total under 220000 bytes
NFR-2 runs recorded in EVIDENCE.md; see PHASE_3_TEST.md for the observable behaviors
```

---

## Notes

- The ledger line format is defined in GLOBAL Data Model ("Ledger lines"); `_contract.md` "Review ledger" arrives in phase 6, and the count check and `disposition` lines on the command side are phase 6 (FR-12). The phase 3 runs pass a scratch ledger path and an id prefix by hand.
- The deferred list is empty until phase 6 adds deferral handling, and the phase 3 execution runs pass a hand-made round directory path because phase 4 defines the naming.
- Phase 3 is verified by execution runs; the installed 0.8.x reviewer is what the surrounding flow calls, so the runs must load the worktree plugin (SPEC Technical Constraints).
