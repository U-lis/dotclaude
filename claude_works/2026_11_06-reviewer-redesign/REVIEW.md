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
