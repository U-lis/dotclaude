# Phase 2: Flow Integrations

## Objective

Wire the pruner agent into the two integration points (design-stage doc mode and code-stage code mode), create the standalone `/dotclaude:prune` command, and add the README command-table row.

## Prerequisites

- Phase 1 complete: `agents/pruner.md` exists and `docs/AGENT_MODEL_GUIDE.md` updated.

## Instructions

### Step 1: Edit `agents/code-validator.md` — Add "Post-PASS Pruning Pass" (FR-2b, AD-3)

Locate the Validate-Fix Loop section. The current loop ends at "Step 3: Document Update (AFTER final success ONLY)" when validation passes. Insert a new sub-section labeled **"Post-PASS Pruning Pass"** between the GREEN exit of the validate-fix loop and "Step 3: Document Update". This is an internal sub-step; it does not change the external step numbering visible to the orchestrator.

The sub-section must include all 8 points from AD-3:

1. Call pruner in code mode:
   ```
   Task(subagent_type="dotclaude:pruner", prompt="Mode: code. Phase source files: {list}. Test files: {list}. Primary criteria: 2, 5, 7. Also flag newly introduced violations of criteria 1, 3, 4, 6.")
   ```

2. If pruner reports zero candidates → skip to Document Update (edge case #1: "Nothing to prune" is a valid non-error result).

3. If ≥1 candidate → back up every file named in the pruner report:
   ```bash
   BACKUP_DIR=$(mktemp -d)
   # copy each named file into BACKUP_DIR, preserving relative paths
   ```
   Record `git status --porcelain` output before applying changes.

4. Call coder to apply:
   ```
   Task(subagent_type="{coder_namespace}", prompt="Apply pruner report: delete/merge tests and trim docstrings/comments only. No logic changes, no production code changes, no PLAN checklist changes.")
   ```

5. Out-of-scope guard: compare `git status --porcelain` after coder with the recorded snapshot. Any file changed that is NOT in the pruner report's file list → treat as revalidation failure; restore from backup immediately.

6. Single revalidation pass (lint / type-check / tests):
   - GREEN → delete `BACKUP_DIR`, proceed to Document Update with pruned state.
   - RED (or guard failure from step 5) → restore every file in `BACKUP_DIR` to its pre-pruning state (and revert/delete any out-of-scope changes); proceed to Document Update returning the pre-pruning GREEN result as PASS.

7. Include the exact sentence: "The pruning revalidation is a SINGLE pass. It is EXCLUDED from the max-3 retry budget."

8. State explicitly: "The revert mechanism is file backup/restore only. `git stash`, `git reset --hard`, and `git checkout -- <path>` are FORBIDDEN for this revert purpose."

Do NOT modify the line at `agents/code-validator.md:225` containing `Test coverage: {X}%` (out of scope).

### Step 2: Edit `commands/design.md` — Add Pruner Doc-Mode Sub-Flow (FR-2a, AD-4)

Locate the Step 3 ASCII box (~lines 23-33) in the workflow diagram. The box currently reads:
```
│ 3. Pass Results to TechnicalWriter                      │
│    - Create GLOBAL.md                                   │
│    - Create PHASE_{k}_PLAN_{keyword}.md for each phase  │
│    - Create PHASE_{k}_TEST.md for each phase            │
│    - Create PHASE_{k}.5_PLAN_MERGE.md if parallel phases│
```

After the TechnicalWriter document creation step and before "Step 4: Commit Documents", insert the pruner doc-mode sub-flow as an inline step or continuation within Step 3. The visible step numbers (1–5) must remain unchanged.

Insert the following logic:
```
│    - Call pruner (doc mode):                            │
│      Task(subagent_type="dotclaude:pruner",             │
│           prompt="Mode: doc. Targets: PHASE_*_TEST.md   │
│           + PHASE_*_PLAN_*.md")                         │
│      Zero candidates → proceed to commit               │
│      ≥1 candidate → Task(                              │
│        subagent_type="dotclaude:technical-writer",      │
│        prompt="Apply pruner doc-mode report to          │
│        PHASE_*_TEST.md and PHASE_*_PLAN_*.md; keep      │
│        ≥1 test per behavior") → proceed to commit       │
```

Do NOT add a new top-level step. The "Next Steps" section and all other content in `commands/design.md` remain unchanged.

### Step 3: Edit `commands/start-new.md` — Add Pruner Doc-Mode Sub-Flow (FR-2a, AD-4)

Locate Step 7 (~lines 310-318):
```
**Step 7: Design - Create Documents**
```
Task tool -> TechnicalWriter
  Input:
    document_type: "DESIGN"
    designer_output: {Designer results}
    target_dir: "{working_directory}/{doc_dir}/"
  Output: GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md
```

After the TechnicalWriter invocation and before Step 8 (Commit Design Documents), insert the pruner doc-mode sub-flow inline within Step 7. The step numbers (Step 7, Step 8, etc.) must not change.

Insert after the TechnicalWriter Task block:
```
After TechnicalWriter completes, run pruner doc mode:
Task(subagent_type="dotclaude:pruner",
     prompt="Mode: doc. Working dir: {worktree_path}. Targets: all PHASE_*_TEST.md and PHASE_*_PLAN_*.md in {target_dir}.")

If zero candidates: proceed to Step 8.
If ≥1 candidate:
  Task(subagent_type="dotclaude:technical-writer",
       prompt="Apply pruner doc-mode report to PHASE_*_TEST.md and PHASE_*_PLAN_*.md in {target_dir}. Keep ≥1 test per behavior (edge case #10).")
  Then proceed to Step 8.
```

Do NOT modify the `code-validator` invocation prompt at ~lines 750-816. Do NOT change any orchestrator step descriptions. The README.md 13-Step Workflow table at ~lines 236-249 must remain unchanged.

### Step 4: Create `commands/prune.md` (FR-5, AD-5, AD-7)

Create the file `commands/prune.md` from scratch. Follow the existing command file conventions (refer to `commands/design.md` or `commands/code.md` for frontmatter and section patterns).

**Frontmatter**:
```yaml
---
description: Analyze current diff or a target (phase id / PR number / issue / Jira key) and report test deletion/merge candidates and docstring trim candidates. Report-only; never applies changes.
---
```

**Required sections**:

1. **Configuration Loading** — same pattern as other commands (load `dotclaude-config.json`).

2. **Language** — same pattern as other commands.

3. **Argument Resolution** — document AD-7 as a decision table or numbered tree (must match all 5 resolution steps from AD-7 verbatim):

   | Argument | Mode | Action |
   |----------|------|--------|
   | None | Code | `git diff HEAD` (staged+unstaged); empty diff → "Nothing to analyze." and exit |
   | Phase id (`^\d+[A-Z]?$` or `^\d+\.\d+$`) | Code (or Doc if no code yet) | That phase's changes; if no code → doc mode on PHASE_{k}_TEST.md + PHASE_{k}_PLAN_*.md |
   | GitHub PR URL or `#N` | Code | `gh pr diff N` |
   | GitHub issue URL or `#N` | Code | Find linked PR or branch → diff vs `base_branch` |
   | Jira key (`^[A-Z][A-Z0-9]+-\d+$`) | Code | Branch containing the key → diff vs `base_branch` |
   | Unrecognized / branch/PR not found | — | Report error and exit; never guess |

4. **Agent Invocation** — call `dotclaude:pruner` with the resolved mode and target.

5. **Edge Cases** — must cover:
   - Edge #6: no argument + empty diff → "Nothing to analyze." and exit immediately.
   - Edge #7: argument disambiguation (phase id vs GitHub vs Jira key) — document the patterns.
   - Edge #8: ticket with no linked branch or PR → report error and exit, no guessing.
   - Edge #9: the command itself never applies changes; applying requires a separate explicit user instruction.

6. **Doc-Mode Fallback** — when the phase argument is given but the phase has no code yet, use doc mode targeting `PHASE_{k}_TEST.md` and `PHASE_{k}_PLAN_*.md`.

### Step 5: Edit `README.md` — Add `/dotclaude:prune` Row (AD-5)

Locate the command table (~lines 143-163). Add one row:

```markdown
| `/dotclaude:prune [target]` | Analyze current diff or target (phase id / PR / issue / Jira key) and report deletion/merge candidates. Report-only. |
```

Do NOT change any other row. Do NOT change the 13-Step Workflow table (~lines 236-249).

## Completion Checklist

- [ ] `agents/code-validator.md` contains `dotclaude:pruner` reference in the Post-PASS Pruning Pass section
- [ ] `agents/code-validator.md` contains "EXCLUDED from the max-3 retry budget"
- [ ] `agents/code-validator.md` contains `mktemp -d` (backup directory creation)
- [ ] `agents/code-validator.md`: `git stash` and `git reset --hard` appear ONLY inside the "FORBIDDEN" sentence of the Post-PASS Pruning Pass section (not elsewhere as instructions)
- [ ] `agents/code-validator.md` line 225 (`Test coverage: {X}%`) is unchanged
- [ ] `commands/design.md` contains `dotclaude:pruner` reference; visible step numbers 1–5 unchanged
- [ ] `commands/start-new.md` contains `dotclaude:pruner` reference inside Step 7; Step numbers unchanged
- [ ] `commands/start-new.md` code-validator invocation (~lines 750-816) unchanged
- [ ] `commands/prune.md` created with `dotclaude:pruner` invocation
- [ ] `commands/prune.md` documents all 5 AD-7 resolution steps
- [ ] `commands/prune.md` covers edge cases #6, #7, #8, #9
- [ ] `README.md` contains `/dotclaude:prune` in command table
- [ ] `README.md` 13-Step Workflow table is byte-identical to main (only the command-table row changed)
- [ ] `commands/code.md` is unchanged (verify: `git diff main -- commands/code.md | wc -l` = 0)

## Notes

- The Post-PASS Pruning Pass in `code-validator.md` is an internal addition. The orchestrator step descriptions in `commands/code.md` and `commands/start-new.md` do not mention it explicitly (per FR-2b: absorbed internally).
- The only orchestrator-visible change in `commands/start-new.md` is the pruner sub-flow inside Step 7. All other steps remain identical.
- `commands/prune.md` path arguments are out of scope for this iteration; do not document them.
- Do NOT modify `CHANGELOG.md` or version files (per project convention).
