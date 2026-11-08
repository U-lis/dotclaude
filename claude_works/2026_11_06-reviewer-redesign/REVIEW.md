# Review: reviewer-redesign

## Phase 1

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `hooks/guard-review.sh:86` | Minor | The tool name is lowercased (`${TOOL,,}`) but the configured `review.intent_tools` globs are not. A user glob such as `*Jira*` silently never matches, so the gate never fires for that config. | Follows GLOBAL AD-1, so the defaults work. Suggested direction: lowercase each glob too, or document "globs must be lowercase" when `configure` gets the key in phase 6. E3 used `mcp__godot__get_godot_version` instead of a Notion tool; recorded in the PLAN Notes; the gate matches by tool name. |
| 2 | 2 scope | checked | — | — | — | Every change traces to PLAN Steps 1-5 and FR-4 / NFR-1. `agents/reviewer.md` and `hooks/workspace-archive.sh` unchanged, as the PLAN requires. |
| 3 | 3 safety | issue | `hooks/guard-review.sh:64` | Minor | The binding store is accepted if any directory already exists at `${TMPDIR:-/tmp}/dotclaude-review-$(id -u)`; owner and symlink are not checked. On a shared host another user could create it first and read or replace binding files. | Low risk: needs another user on the same host, and the gate is a workflow guard, not a security boundary. Suggested direction: use the store only if owned by the current user, not a symlink, mode 700; otherwise fail open. Binding files are never cleaned up (small, under /tmp). |
| 4 | 4 maintainability | issue | `hooks/guard-review.sh:2-7` | Minor | The header comment is 6 lines and mostly says what the hook does; RULES.md asks for 1-5 lines of "why". | Keep the two known limitations the PLAN requires; trim the description. Side note: the closing sentence of SPEC FR-4 still says the plugin-path hook and MCP deny are "not yet confirmed"; E2 and E3 now confirm them. |
| 5 | 5 tests | checked | — | — | — | Each assertion maps to a PHASE_1_TEST row with pinned hook lines. `:98` overlaps `:104` but SPEC NFR-1 lists the case. The archive case pins a combination of behaviors, explained in the Notes. |

BLOCKERS: 0

## Phase 2

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `commands/_contract.md:173`, `:160`, `commands/start-new.md:47` | Major | The rule that the orchestrator replaces `phase {k} (uncommitted)` with the hash was not reachable from the commit steps, and no commit carried the edited EVIDENCE.md. | Fixed before the phase commit: Commits table lists EVIDENCE.md and `evidence/*.log`; the replaced hash goes into the next phase's commit or the docs commit; `code.md` step 6 and the start-new commit step refer to Contract: Evidence. |
| 2 | 2 scope | issue | `SPEC.md:12` | Minor | The `decisions` list adds `warn-commit-ok-for-markdown-phases`, which the review prompt did not mention. | Recorded user decision (2026-11-06, AskUserQuestion). No change. |
| 3 | 3 safety | issue | `commands/_contract.md:172` | Major | Raw outputs are saved and committed with no rule about secrets. | Fixed before the phase commit: Contract: Evidence requires redacting credentials, tokens, cookies, env dumps. The 17 logs present were grepped; no secrets. |
| 4 | 4 maintainability | issue | `EVIDENCE.md:3` | Minor | The work's Rules line no longer matched the template. | Fixed before the phase commit. |
| 5 | 5 tests | issue | `PHASE_2_TEST.md:5-9` | Major | The two follow-up rules had no matrix rows. | Fixed before the phase commit: rows R6–R10 added. |
| 6 | 5 tests | issue | `PHASE_2_TEST.md:5-9`, `EVIDENCE.md:9-17` | Major | Test refs and commands pointed at a session path. | Fixed before the phase commit: the repository copy `evidence/phase2-check.sh.log` is the one that runs; passed=32 failed=0. |

BLOCKERS: 0

The fixes were not re-reviewed (no Blocker round); the orchestrator re-ran the check script, the prompt lint, and the hook tests after them.

## Phase 3

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `commands/_contract.md:174`, `commands/init.md:40` | Major | The contract now says "raw outputs are not committed". But the reviewer's raw `.log` files sit in `{working_directory}/reviews/*/r*/`, and none of the four ignore lines matches that path. `git check-ignore -v claude_works/reviews/a/r1/x.log` matched nothing; the same check on `.../evidence/x.log` matched `.gitignore:5`. D-11 lists what gets committed and leaves out round-directory STATUS.md and `.log` files. Run 1 produced two re-run logs of 2.6 MB each (EVIDENCE.md, "Run 1: round directory contents"). In a repo with `workspace_tracking: commit` these would be committed. | Suggested direction: add a round-directory ignore line now, or record in PLAN/GLOBAL that phase 4 adds it and qualify the line-174 sentence until then. |
| 2 | 2 scope | issue | `claude_works/2026_11_06-reviewer-redesign/GLOBAL.md:157` | Major | Phase 3 is marked `Complete`, but the #3459 run that PLAN Step 5 and NFR-2 require was not done. The PHASE_3_TEST.md:18 evidence cell reads "- (not run in this call)", and SPEC.md:63 still leaves NFR-2 unchecked. The Completion Checklist has no Step 5 item, so it shows all ticked while Step 5 is unfinished. | Suggested direction: keep Phase 3 `In Progress`, or add a checklist item and a GLOBAL note saying the #3459 run is moved to a named later point. |
| 3 | 2 scope | issue | `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md:30` | Major | This row, which will be committed, quotes a finding from the reviewed repository. That breaks SPEC D-11 and the new `commands/_contract.md:175`. | Suggested direction: replace the quoted line with a field count and a check result and cite the round-directory ledger path. Fix this before the phase commit. |
| 4 | 3 safety | checked | — | — | — | (a) Removing the frontmatter `tools:` line gives the reviewer every tool, including Write, Edit, Agent and MCP write tools. This is the AD-2 decision (GLOBAL.md:39-44), recorded as Risk 4 (GLOBAL.md:192-194). The limits are prompt-level only (`agents/reviewer.md:120`) and were checked by before/after snapshots in runs 1, 2 and the phase-depth run. (b) Untracking `evidence/` and `.validated/` loses no data: all files are still on disk. `hooks/guard-commit.sh:65` checks the marker with `[ -e ]` on the filesystem, so ignoring `.validated/` does not break the commit guard. (c) No secrets in the diff. The ledger is append-only (`agents/reviewer.md:116`), and no GitHub writes are allowed (`agents/reviewer.md:120`). |
| 5 | 4 maintainability | issue | `agents/reviewer.md` | Minor | The file grew from 4922 to 13022 bytes (2.6x). The PLAN note "Prompt budget" says it "must stay near the size of the old file". The lint still passes: 186466 of 220000 bytes. That leaves about 33.5 KB for phases 4-6. | Suggested direction: either trim the file or change the PLAN note to state the real budget used. |
| 6 | 4 maintainability | issue | `claude_works/2026_11_06-reviewer-redesign/GLOBAL.md:75` | Minor | GLOBAL says phase 3 and phase 6 "both reference it, neither restates the fields". But `agents/reviewer.md:116` lists all 11 ledger fields and adds a list of `kind` values that the GLOBAL Data Model (GLOBAL.md:97-101) does not define. The restating is needed, since GLOBAL.md does not ship with the plugin, so the GLOBAL sentence is the inaccurate one. | Suggested direction: change GLOBAL:75, and add the `kind` values to the Data Model block so phase 6 has one place to copy from. |
| 7 | 4 maintainability | issue | `README.md:190`, `commands/review.md:2` | Minor | README still calls the reviewer "Report-only five-axis diff review", which contradicts `docs/ARCHITECTURE.md:39` and `commands/_contract.md:124` as changed in this diff. | These are probably meant for the docs stage or phase 4. If so, record that. |
| 8 | 5 tests | issue | `claude_works/2026_11_06-reviewer-redesign/PHASE_3_TEST.md:10,12,16,19,20` | Minor | Five behavior rows have only grep checks of the prompt text as evidence, marked "(not exercised)". NFR-2 says prompt phases are verified by running them. The phase-depth run row also records a deviation (the reviewer read EVIDENCE.md). The F10 fix for it was checked only by text and has not been re-run. | Suggested direction: cover these behaviors in a repeated phase-depth run, or label the rows as text-only checks. |

BLOCKERS: 0

### Disposition

This review was run by the installed 0.8.1 reviewer (five axes, no ledger lines), not the new phase-depth reviewer.

- #1 fixed: `reviews/` added to the ignore list in `.gitignore`, `commands/init.md`, `commands/_contract.md`; D-11 updated.
- #2 resolved: the #3459 run is done (EVIDENCE rows 60-68), PHASE_3_TEST row 18 updated, NFR-2 ticked.
- #3 fixed: EVIDENCE row 30 rewritten.
- #5 deferred to the phase 6 prompt-budget pass (lint 186 KB of 220 KB).
- #6 fixed in GLOBAL (line 75 sentence and the `kind` values in the Data Model block).
- #7 deferred to the Docs step.
- #8 rows labeled text-only; the F10 phase-depth re-run is deferred to phase 5 wiring.

### NFR-2 실행 검증 결과

Meta-review of the new reviewer; counts only.

- Five runs. In every run the first tool call was a Write of STATUS.md with an empty Restatement, the second filled it, and intent MCP tools were called only afterwards. The guard hook produced no deny because of that order.
- The reviewed repository's git status and worktree list were unchanged in all runs. No GitHub write.
- Ledger lines equal issue rows in runs 1, 2, 4, 5 (run 3 unmeasured).
- Runs took 6.5 to 9 minutes and 2.3 to 2.5 USD each.
- Run 2 reused the previous round and run 3 read assistant memory files before the prohibitions were added; after that, run 5 did neither.
- On the complex PR at its pre-review head the reviewer caught 4 of 10 known defects, missed 6 whose common trait is that they require systematic enumeration of input-shape combinations, and raised 2 findings outside the known set.
- It could not run the repository's test suite because settings load cloud secrets at import, and used minimal-settings probes instead.

Conclusion: the restatement gate, write scope and read-only behavior work as designed. Recall on combinatorial defects is the open weakness and is not addressed by prompt changes alone (relates to #110).

## Phase 4

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `commands/review.md:25` | Major | No-argument mode now goes through PR depth, which can miss uncommitted and untracked changes. Line 17 defines the target as `{base_branch}...HEAD` plus uncommitted and untracked files, and "Nothing to review." is decided on that basis. But the PR-depth reviewer reads and runs the code in a temporary worktree at the head commit (`agents/reviewer.md:46`), and the prompt only passes `Base: {base_branch}` with scope "the full branch diff". | If a branch has only uncommitted work, the round reviews an empty or stale diff and nobody is told. Suggested direction: say in the prompt that no-argument mode includes the working-tree changes, or limit no-argument mode to committed changes. |
| 2 | 1 correctness | issue | `commands/_contract.md:103` | Minor | The `{target}` fallback chain has no answer when no-argument mode runs on a branch without a `{type}/` prefix and without a Jira key. | Suggested direction: fall back to the full branch name. |
| 3 | 1 correctness | issue | `commands/_contract.md:103` | Minor | The `n` rule (1 + highest existing `r*`, then `mkdir -p`) does not stop two runs on the same target on the same day from getting the same `r{n}`. | SPEC FR-4 says concurrent reviews are common. Suggested direction: plain `mkdir` and retry with `n+1`. |
| 4 | 2 scope | checked | — | — | — | Every hunk in `commands/_contract.md` (row at line 97, rules at line 103) and `commands/review.md` (lines 7, 11, 25, 34, 56-57, 69) traces to FR-6/FR-9 and to PLAN Steps 1-2. Steps 3-9 match HEAD (phase4-check V10). |
| 5 | 3 safety | checked | — | — | — | No migration, secret, permission or default-value change. The diff only removes a GitHub write: the `gh pr comment` offer in edge case 2 (`commands/review.md:57`). Ledger and round paths point to the primary checkout and are git-ignored (`.gitignore:9`). |
| 6 | 4 maintainability | issue | `commands/review.md:34` | Minor | Step 2 repeats the reviewer prompt fields already in `commands/_agent-prompts.md:99-115`. | Against CLAUDE.md "Prompt hygiene". Keep only review.md-specific values and point to the template. |
| 7 | 4 maintainability | issue | `commands/_contract.md:103` | Minor | "The reviewer reads and writes only its own round directory" repeats `commands/_contract.md:190` and `agents/reviewer.md:46`. | Small duplication inside the contract. |
| 8 | 5 tests | issue | `claude_works/2026_11_06-reviewer-redesign/PHASE_4_TEST.md:7` | Major | Every TEST row is at the scenario layer, yet each one is backed only by grep content checks and marked "scenario run pending". Even so, the PLAN checklist says "verified", GLOBAL.md:159 says Complete, and SPEC FR-6/FR-9 are ticked. | The PLAN Expected Output asks for EVIDENCE rows for both runs (no-argument and `#3493`). Suggested direction: run both scenarios and record them, or leave FR-6/FR-9 open until they are run. |
| 9 | 5 tests | issue | `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md` | Minor | `evidence/phase4-check-red.log` exists, but there is no EVIDENCE row for the RED run. | — |

BLOCKERS: 0

### Disposition

- #1 fixed: `commands/review.md:25` passes scope "including working-tree changes" and the current worktree; `agents/reviewer.md:46` reviews in the given worktree for that scope; the `## reviewer` template line 102 gained that scope option.
- #2 fixed: full branch name fallback.
- #3 fixed: `mkdir` without `-p`, retry n+1.
- #6 fixed: step 2 refers to the template.
- #7 fixed: read rule kept, write rule stays at the contract's Who does what.
- #9 no change needed: the RED row already existed at EVIDENCE.md:53.
- #8 deferred: the live no-argument run is the pre-integration full-diff review of this branch, which is the same scenario, and the `#N` run goes to the verification session after phase 5 wiring. FR-6/FR-9 stay ticked on content checks (28 passed after the fix round), as accepted for the earlier markdown phases.

Review run by the installed 0.8.1 reviewer.

## Phase 5

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `commands/pr.md:68` | Major | Step 9f skips a new review when the latest round's STATUS.md `head` equals HEAD, but the reviewer writes that head early, in its Restate step (`agents/reviewer.md:50-61`), before REVIEW.md exists. If a round stopped partway, it still matches HEAD: 9f skips the call and builds Review notes from a REVIEW.md that is missing or incomplete. | Suggested direction: also require `{round}/REVIEW.md` to exist and end with a `BLOCKERS: n` line before skipping. |
| 2 | 1 correctness | issue | `commands/pr.md:68` | Minor | On the skip path, 9f never runs the "BLOCKERS above 0 → AskUserQuestion" step, because that step only follows a fresh call. | Suggested direction: read `BLOCKERS: n` from the reused round's REVIEW.md and apply the same question. |
| 3 | 1 correctness | issue | `commands/pr.md:68` | Minor | The glob `reviews/*-{target}` also matches another target that ends in `-{target}`. The Contract fixes the prefix as `{YYYY_MM_DD}-` (`commands/_contract.md:97`). | Suggested direction: match the date-shaped prefix. |
| 4 | 1 correctness | issue | `commands/start-new.md:67` | Minor | The pre-integration review writes the `## Full diff` pointer line into `{doc_dir}/REVIEW.md` but does not say whether it is committed. If it is committed before `/dotclaude:pr`, HEAD moves past the round's `head`, 9f's skip check fails, and a second PR-depth round runs on the same code. | Suggested direction: state when the pointer is committed, or compare against the last commit that touched code. |
| 5 | 2 scope | checked | — | — | — | Every change traces to PLAN Steps 1-3 (FR-10, NFR-4): `commands/code.md:30`, `commands/start-new.md:46,67`, `commands/pr.md:68-69,157,213`. Ledger count check, deferrals and knowledge are correctly left out for phase 6. |
| 6 | 3 safety | n/a | — | — | — | Only prompt and document text changed. No migrations, defaults, permissions or secrets. `.validated/PHASE_{k}` and the commit guard are unchanged (`commands/code.md:29`). |
| 7 | 4 maintainability | checked | — | — | — | The round-directory path and target rules are referenced as "Contract: Names and paths" and not restated. The prompt fields match the `## reviewer` template (`commands/_agent-prompts.md:101-115`). |
| 8 | 5 tests | issue | `claude_works/2026_11_06-reviewer-redesign/SPEC.md` (FR-10, NFR-4) | Minor | FR-10 and NFR-4 are ticked, but every PHASE_5_TEST.md row says "scenario run pending". The only evidence is the grep check script. | Text checks fit a prompt repository; the ticks overstate verification until the scenario rows run. |

BLOCKERS: 0

### Disposition

- #1 fixed: 9f skips only when STATUS.md `head` equals HEAD and REVIEW.md ends with `BLOCKERS: n`.
- #2 fixed: the skip path reads BLOCKERS and asks the same question.
- #3 fixed: date-shaped glob `????_??_??-{target}`.
- #4 fixed with a deviation: `/dotclaude:pr` commits nothing, so the pointer line stays uncommitted until the next commit, which keeps HEAD equal to the round head (`commands/start-new.md:67`).
- #8 deferred: scenario runs go to the verification session after phase 6, FR-10/NFR-4 stay ticked on content checks (29 passed after the fix round).

Review run by the installed 0.8.1 reviewer.

## Phase 6

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `commands/_contract.md:193` | Major | Finding ids can be the same for two different findings, so a `disposition` line cannot tell which finding it means. At phase depth the second review after a Blocker fix uses the same prefix `{doc_dir}-p{k}` and the same row numbers. At pr depth `{target}-r{n}` has no date, but `r{n}` restarts at `r1` each day, so `{target}-r1-1` repeats across days. | The id form comes from SPEC FR-12, so fixing it needs a SPEC change. Suggested direction: put the round's date in the pr prefix and a review-round counter in the phase prefix. |
| 2 | 1 correctness | issue | `commands/_contract.md:204` | Minor | "the command writes each fact ... as a new record" never says which directory. The inputs are `knowledge_dirs` plus `{primary}/{WD}/knowledge/`, so a command could write into a user's research directory. | Suggested direction: state the primary `knowledge/` as the only write target. |
| 3 | 1 correctness | issue | `commands/_contract.md:202` | Minor | The 오래됨 check `git log {confirmed commit}..{head} -- {path}` does not say what to do when the confirmed commit is not in the repository. git exits non-zero and nothing is listed, so the record is not marked 오래됨. | Suggested direction: treat a missing commit as 오래됨. |
| 4 | 2 scope | checked | — | — | — | Every hunk traces to PLAN Steps 1-4 or to the three earlier-review Minors declared in scope. Knowledge records are written only at pr depth, matching FR-11. |
| 5 | 3 safety | issue | `hooks/guard-review.sh:85` | Minor | The symlink/owner check protects only the binding write. The read side still runs `cat "$STORE/$AID"` without it, so a planted binding could point `restatement_filled` at a file another user controls. | Low risk (needs a guessed `agent_id`). Suggested direction: apply the same test before reading. |
| 6 | 4 maintainability | issue | `hooks/guard-review.sh:6` | Minor | The header says only "a SPEC Read before STATUS.md exists" is not blocked, but an unbound reviewer's PLAN Reads are not blocked either. | Suggested direction: "SPEC and PLAN Reads while unbound". |
| 7 | 4 maintainability | checked | — | — | — | The kind list and the ledger field order are defined only in `_contract.md:193`; `agents/reviewer.md:116` refers to them. Callers refer to the contract sections by name. |
| 8 | 5 tests | checked | — | — | — | The two new hook cases fail before the hook edit and pass after it. The `-O` branch has no test (needs a second user). TEST rows point to content checks with "scenario run pending", as in phases 4-5. Content checks RED 4/37, GREEN 41/0. |

BLOCKERS: 0

### Disposition

- #1 fixed: ids are now `{YYYY_MM_DD}-{target}-r{n}-{row}` and `{doc_dir}-p{k}-r{m}-{row}`, defined once in `commands/_contract.md:193`; SPEC FR-10/FR-12 wording aligned, re-approval requested.
- #2 fixed: `commands/_contract.md:204` writes only into the primary `knowledge/`.
- #3 fixed: `commands/_contract.md:202` treats a missing commit as 오래됨.
- #5 fixed: read-side store check at `hooks/guard-review.sh:80-85`, new test case.
- #6 fixed: header.

Review run by the installed 0.8.1 reviewer.

## Deferred

- Phase 3 #5: `agents/reviewer.md` size (13.2 KB; lint 195.9 KB of 220 KB).
- Phase 3 #7: README/review.md "report-only" wording, to the Docs step.
- Phase 3 #8 / Phase 4 #8 / Phase 5 #8: live scenario runs, to the verification session after the full-diff review.
- Phase 1 Minor: none open (lowercase globs, store check, header fixed in phase 6).
