# reviewer redesign (#117) - Global Documentation

## Feature Overview

**Purpose**: Turn the reviewer into an external auditor that derives the author's intent and what the diff actually does separately, then compares them. The same procedure serves a pre-push self check and a teammate PR review, and the report reduces what a human has to read.

**Problem**: The current reviewer reads SPEC and PLAN, skims the diff and prints a table. It does not read intent sources (PRD, Jira) independently, does not investigate impact or reinvention, does not re-run tests, and does not say where a human must look. Defects missed by the internal review of ONE-7294 came back through seven CodeRabbit rounds.

**Solution**: One reviewer agent with two depths (`phase`, `pr`). PR depth follows restate, intent comparison, impact, reinvention, evidence and local re-run, dedupe and verdict. A PreToolUse hook blocks intent sources until the restatement exists. Around it: an evidence report form, a per-round review directory, knowledge records, an append-only review ledger and finding-disposition rules. SPEC.md is the authority for behavior; this file holds the architecture decisions once, and each PLAN refers to them as AD-n.

Terminology: "round" is one review pass. User-facing Korean text says 회차.

---

## Architecture Decision

All `file:line` citations are relative to the worktree root.

### AD-1. Restatement gate hook `hooks/guard-review.sh` (new)
**Options Considered**:
1. Hook gate keyed by `agent_id` and the STATUS.md the reviewer writes.
2. Call the reviewer twice (restatement call, then intent call).
3. Pointer file or "most recent directory" guess (rejected in SPEC D-2).

**Decision**: Option 1. Option 2 is the fallback if experiments E2, E3 or E4 fail (phase 1 stops and reports; it changes phases 3-5).

**Rationale / details**:
- Registered in the PreToolUse array of `hooks/hooks.json:19-43` with matcher `Write|Read|mcp__.*`.
- Cheap filter first: `[[ "$INPUT" == *'"dotclaude:reviewer"'* ]] || exit 0` before `json_get` (`hooks/_lib.sh:6`), because the hook fires on every Read of every session.
- Style follows `hooks/guard-design.sh:3-6`: `exec 2>/dev/null`, source `_lib.sh`, fail open. Denials use `deny_pretool` (`_lib.sh:54`). Decisions are logged with `log_line` (`_lib.sh:130`) to `{primary}/{WD}/.hook.log`; these lines are also the trace the experiments read.
- Binding (Write): a Write by `dotclaude:reviewer` whose `tool_input.file_path` matches `*/{WD}/reviews/*/r[0-9]*/STATUS.md` records the pair `agent_id -> absolute STATUS.md path`. First binding wins and is never rebound. `WD` comes from `cfg_get working_directory .dc_workspace` (`_lib.sh:71`) with `HOOK_CWD` set to the nearest existing parent of the target path, because the reviewer may review a repository other than the session `cwd`.
- Binding store: `${TMPDIR:-/tmp}/dotclaude-review-$(id -u)/{agent_id}`, file content is the path, `agent_id` sanitized to `[A-Za-z0-9_-]`. Rejected: `{WD}/reviews/.agents/` (lookup depends on `cwd`) and one shared bindings log (concurrent appends). Tests set `TMPDIR`.
- Gate (bound reviewer): "filled" means the bound STATUS.md `## Restatement` section has at least one line that is neither blank nor an HTML comment before the next `## ` heading. While empty, deny (a) MCP tools whose lowercased name matches a glob in `review.intent_tools` (read with `cfg_get_list`, `_lib.sh:95`, matched with `match_any_glob`, `_lib.sh:114`; default `*jira* *atlassian* *notion*`) and (b) Read of a file whose basename is `SPEC.md` or matches `PHASE_*_PLAN_*.md`. An unreadable STATUS.md means allow.
- Unbound reviewer: intent MCP call is denied with a message to create STATUS.md in the round directory and write the Restatement first; SPEC and PLAN Reads are allowed.
- Everything else (other `agent_type`, null, malformed input) prints nothing. The heading `## Restatement` is fixed in English because the hook parses it; its body may be in the configured language.
- Known limitations, stated in the hook header and in `agents/reviewer.md`: Bash or Grep reads of SPEC and PLAN are not blocked; a PR-depth reviewer that reads SPEC before creating STATUS.md is not blocked.
- Not adopted: a hook-level restriction on reviewer Write/Edit (user decision). FR-4 allows one enforced transition only.

### AD-2. Reviewer tools: remove the `tools:` line (`agents/reviewer.md:5`) and inherit
**Options Considered**:
1. Remove the line and inherit all tools.
2. List `Read, Grep, Glob, Bash, Write, Edit, mcp__<server>__*`.

**Decision**: Option 1.

**Rationale**: MCP server names differ per installation and `review.intent_tools` is configurable, so a fixed list would contradict the setting. Cost: the reviewer also inherits Edit and Agent, so NFR-3 rests on the prompt and is checked in the execution runs (`git -C {target worktree} status --porcelain` unchanged). Whether a plugin subagent inherits MCP tools is tested in E3.

### AD-3. STATUS.md skeleton, written inline by the reviewer with Write as its first PR-depth action
- Sections in order: `## Target` (target, depth, `head` sha, base), `## Restatement`, `## Progress` (steps 2-6, recorded only, not enforced).
- No template file: it would need its own Read for a few lines. The skeleton lives in `agents/reviewer.md`; the hook parsing rule is fixed in phase 1 and the prompt uses the same heading.
- The `head` line is what `/dotclaude:pr` uses to decide whether a review is current (AD-7).

### AD-4. Round directory, defined once in `commands/_contract.md` Names and paths
- Path: `{primary}/{WD}/reviews/{YYYY_MM_DD}-{target}/r{n}/`, always under the primary checkout.
- `{target}` is the first match of: (1) `[A-Z][A-Z0-9]+-[0-9]+` in the PR title; (2) the same pattern in the head branch name; (3) `pr-{N}`; (4) the branch keyword (part after `{type}/`).
- `n` = 1 + the highest existing `r*` under that day's directory. The orchestrator runs `mkdir -p` and passes only the path.
- Contents: `REVIEW.md`, `STATUS.md`, `EVIDENCE.md` written by the reviewer; raw re-run outputs as `.log` files in the same directory (purge may archive them once over 100KB and 24h old, recorded in ARCHIVED.md).
- `hooks/guard-workspace.sh` needs no change (checked: Writes to `reviews/.../STATUS.md`, `EVIDENCE.md`, `knowledge/...md` and `review-ledger.log` are allowed by the rules at `:37-39`, `:41-46`, `:48-49`). This answers the SPEC Open Question on name rules.

### AD-5. Reviewer evidence rows go only to the round directory's EVIDENCE.md
The reviewer reads `{doc_dir}/EVIDENCE.md` and never writes it, because `{doc_dir}` is inside the worktree under review (P4, NFR-3).

### AD-6. Evidence template `templates/EVIDENCE.md` (new)
One table with columns: stage (local/remote), behavior, data setup, command or action, result summary, raw output path, commit, author. Sections: `## coder`, `## orchestrator (run stages)`, `## verification session`, `## reviewer` (used only in a round directory). Rules live in a new `commands/_contract.md` section "Evidence"; a row without a command and raw output is not evidence.

### AD-7. Wiring
- Phase reviews keep the current table and `BLOCKERS: {n}` (`commands/code.md:30`).
- The pre-integration full-diff review becomes PR depth. The `## Full diff` section of `{doc_dir}/REVIEW.md` holds one pointer line: `{round dir}/REVIEW.md (head {sha})`.
- `/dotclaude:pr` 9f skips a new reviewer call when the latest round's STATUS.md `head` equals HEAD (replaces the skip rule at `commands/pr.md:68`). Review notes come from the PR-depth report issue rows, which keep `file:line` and severity, plus the existing carry-over of phase-review Major and Minor rows.

### AD-8. Ledger, knowledge records, dispositions, each defined once in `_contract.md`
- New sections: "Review ledger", "Knowledge records", "Finding dispositions".
- The ledger is tab-separated and append-only; no line is ever edited. Authors (user decision D-10): the reviewer appends one `finding` line per finding when it reports, with an append-only shell write (`printf ... >>`), at both depths (the single exception to "phase depth runs nothing"). It never reads the ledger and never rewrites it, so it must not use the Write tool on it. Reason: one author for the finding record and one place to implement instead of five call sites (`code.md`, start-new Step 10, start-new Run stages, `pr.md` 9f, `review.md`). Commands append only `disposition` lines (decided in the main session with the user).
- Finding id is deterministic so no read is needed: `{target}-r{n}-{row}` for PR depth, `{doc_dir}-p{k}-{row}` for phase depth. The caller's prompt carries the ledger path and the id prefix (`{target}-r{n}` or `{doc_dir}-p{k}`).
- Line format: the "Ledger lines" block in Data Model below is the single statement of it until phase 6 writes it into `_contract.md` "Review ledger"; phase 3 (reviewer) and phase 6 (contract) both reference it, neither restates the fields.
- Count check by the calling command after the reviewer returns: the number of `finding` lines with this review's id prefix equals the number of `issue` rows in the report. On mismatch the command reports the difference to the user and does not fix the ledger.
- Purge never archives the ledger: in `files` mode `hooks/workspace-archive.sh:317-318` loops only over top-level directories; `preserve` mode copies worktree to primary and skips only `.hook.log` (`:143`). Decision (user): no code change, a test pins the behavior.
- Deferral list (FR-13 "known constraints"): the `## Deferred` section of `{doc_dir}/REVIEW.md`, no PR body change. Each row holds finding id, repro command and output path, class (silent or loud). Only loud rows are accepted.
- Knowledge record candidates from the report section "새로 알게 된 것" are written as files by the command without asking; each candidate already carries `file:line` and the commit it was confirmed at.

---

## Data Model

### STATUS.md (per round)
```
## Target        target, depth, head sha, base
## Restatement   free text, gate parses "non-blank, non-comment line before next ## heading"
## Progress      steps 2-6, recorded only
```

### Binding record (hook)
```
${TMPDIR:-/tmp}/dotclaude-review-$(id -u)/{agent_id}   content: absolute STATUS.md path
```

### Ledger lines (`{primary}/{WD}/review-ledger.log`, tab-separated, append-only)
```
finding      id date target depth axis kind location severity verdict must_see
disposition  id disposition(accepted|deferred|rebutted|ignored) defer_class(silent|loud) cross(coderabbit|human|none) later(missed|false-alarm) date
```

### Knowledge record (`{primary}/{WD}/knowledge/{date}-{target}-{n}.md`)
One fact line, `file:line`, confirmed commit, source review. No index.

### Relationships
```
orchestrator --mkdir--> r{n}/ <--Write-- reviewer (STATUS.md -> REVIEW.md, EVIDENCE.md, *.log)
guard-review.sh: binds agent_id -> r{n}/STATUS.md; gates intent MCP + SPEC/PLAN Read
reviewer --append finding lines (printf >>)--> review-ledger.log
command --append disposition lines--> review-ledger.log; command --write--> knowledge/*.md, {doc_dir}/REVIEW.md (pointer, ## Deferred)
```

---

## API Design (if applicable)

Not applicable. The only configuration surface is two new keys in the `_contract.md` Configuration table: `review.intent_tools` (default `["*jira*","*atlassian*","*notion*"]`) and `knowledge_dirs` (default `[]`).

---

## File Structure

### Files to Create
```
hooks/guard-review.sh                    # restatement gate
tests/hooks/test_guard_review.sh         # hook tests
templates/EVIDENCE.md                    # evidence form
claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md   # this work's own evidence
```

### Files to Modify
```
hooks/hooks.json                  # register guard-review (P1)
tests/hooks/test_workspace_archive.sh  # ledger stays in place (P1)
docs/ARCHITECTURE.md              # hook list (P1), reviewer line (P3)
commands/_contract.md             # Evidence (P2); Language/Who does what/Git safety (P3); round dir (P4); config rows + 3 sections (P6)
commands/_coder-base.md           # evidence rows (P2)
commands/start-new.md             # Run stages (P2); Depth wiring (P5); ledger/knowledge (P6)
agents/reviewer.md                # rewrite (P3); knowledge/deferred/read limits (P6)
commands/_agent-prompts.md        # reviewer template (P3)
commands/review.md                # PR depth (P4); ledger/dispositions (P6)
commands/code.md                  # Depth: phase (P5); ledger (P6)
commands/pr.md                    # 9f (P5); ledger (P6)
commands/configure.md             # two keys (P6)
```
`hooks/workspace-archive.sh` and `hooks/guard-workspace.sh` are not changed.

---

## Phase Overview

| Phase | Description | Requirements | Status | Dependencies |
|-------|-------------|--------------|--------|--------------|
| 1 | Restatement gate hook, tests, experiments E1-E6 | FR-4, NFR-1 | Complete | - |
| 2 | Evidence template and contract | FR-8 | Complete | Phase 1 |
| 3 | Reviewer rewrite and prompt template | FR-1, FR-2, FR-3, FR-5, FR-7, NFR-2, NFR-3 | Not Started | Phase 2 |
| 4 | Review part of `/dotclaude:review`, round directory rules | FR-6, FR-9 | Not Started | Phase 3 |
| 5 | Phase-review and pre-integration wiring | FR-10, NFR-4 | Not Started | Phase 4 |
| 6 | Ledger, knowledge records, dispositions, settings | FR-11, FR-12, FR-13, FR-14, NFR-5 | Not Started | Phase 5 |

Six sequential phases in the user-approved order; no parallel group, so no merge phase. Phase 6 depends on phases 3-5, which the chain already satisfies.

**Status values**: `Not Started`, `In Progress`, `Complete`, `Skipped`.

---

## Phase Dependencies

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5 ──→ Phase 6
```

Phase 1 fallback: if E2, E3 or E4 fails, stop and report; the orchestrator takes the two-call alternative to the user.

---

## Risk Mitigation

### Risk 1: Plugin hook does not fire or lacks `agent_type` for subagents, or cannot deny MCP calls
**Impact**: High
**Mitigation**: Experiments E2, E3, E4 run first in phase 1 before phases 2-6 depend on the design; fallback is the two-call reviewer.

### Risk 2: `--plugin-dir` collides with the installed same-name 0.8.1 plugin
**Impact**: High (phases 3-6 verify by execution runs)
**Mitigation**: E1 records the collision behavior and the workaround; the installed plugin is never modified.

### Risk 3: Prompt size budget
**Impact**: Medium. `scripts/lint-prompts.sh` caps prompt files at 220000 bytes; the baseline is whatever `scripts/lint-prompts.sh` reports at the phase 1 prerequisite run (172499 when verified on 2026-11-06 by running the script), leaving the remainder for phases 2-6.
**Mitigation**: Define each rule once in `_contract.md` and reference it by section name; every phase runs the lint. The lint also bans the literal `claude_works` in prompt files and more than 4 ALL-CAPS emphasis tokens per file.

### Risk 4: Reviewer inherits Edit and Agent (AD-2)
**Impact**: Medium
**Mitigation**: Prompt-level rule plus `git status --porcelain` and `git worktree list` comparison in the execution runs.

### Risk 5: Hook-based gate has known bypasses (Bash/Grep reads, SPEC read before STATUS.md)
**Impact**: Low
**Mitigation**: Documented in the hook header and in `agents/reviewer.md`; accepted by the SPEC.

---

## Completion Criteria

Overall feature is complete when:
- [ ] All phases marked Complete
- [ ] `bash tests/hooks/run_all.sh` prints `ALL PASSED` and `scripts/lint-prompts.sh` exits 0 with the prompt total under 220000 bytes
- [ ] NFR-2 execution runs recorded in `claude_works/2026_11_06-reviewer-redesign/EVIDENCE.md`
- [ ] Documentation updated (`docs/ARCHITECTURE.md`)
- [ ] Code reviewed

---

## Next Steps

1. ⏳ Phase 1: implement the hook and tests, run E1-E6
2. Phase 2: evidence form and contract
3. Phases 3-6 in order
