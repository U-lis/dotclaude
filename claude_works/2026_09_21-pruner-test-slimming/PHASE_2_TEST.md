# Phase 2: Test Cases

## Test Coverage

Coverage: N/A. No executable test suite exists in this repository (Markdown plugin). The 70% figure is a reference, not a gate.

## Test Strategy

All verification is by file-content inspection using grep and read checks. Each check below is a deterministic command against the resulting filesystem state.

All paths are relative to the worktree root: `/home/ulismoon/Documents/dotclaude/dotclaude-feature-pruner-test-slimming`.

---

## Behaviors to Verify

### B-1: `agents/code-validator.md` references `dotclaude:pruner` (FR-2b, AD-3)

Verification layer: grep checks

- [x] B-1.1: `dotclaude:pruner` appears in code-validator, start-new, design, and prune files
  ```bash
  grep -n 'dotclaude:pruner' agents/code-validator.md commands/start-new.md commands/design.md commands/prune.md
  ```
  Expected: at least one match in each of the four files

### B-2: Pruning re-validation is excluded from the max-3 retry budget (AD-3 point 7)

Verification layer: grep check

- [x] B-2.1: "EXCLUDED from the max-3 retry budget" present in code-validator
  ```bash
  grep -c 'EXCLUDED from the max-3 retry budget' agents/code-validator.md
  ```
  Expected: `>=1`

### B-3: Backup directory uses `mktemp -d` (AD-3 point 3)

Verification layer: grep check

- [x] B-3.1: `mktemp -d` present in code-validator Post-PASS Pruning Pass section
  ```bash
  grep -c 'mktemp -d' agents/code-validator.md
  ```
  Expected: `>=1`

### B-4: `git stash` and `git reset --hard` appear only inside the FORBIDDEN sentence (AD-3 point 8)

Verification layer: grep check (manual review of each hit)

- [x] B-4.1: Every match of `git stash` or `git reset --hard` in code-validator is inside the "FORBIDDEN" sentence of the Post-PASS Pruning Pass section — not elsewhere as an instruction
  ```bash
  grep -nE 'git stash|git reset --hard' agents/code-validator.md
  ```
  Expected: all hits are within the "FORBIDDEN for this revert purpose" clause; no hit is an operational instruction

### B-5: `Test coverage: {X}%` line at :225 is unchanged (out-of-scope guard)

Verification layer: grep check

- [x] B-5.1: `Test coverage: {X}%` still present exactly once
  ```bash
  grep -c 'Test coverage: {X}%' agents/code-validator.md
  ```
  Expected: `1`

### B-6: `/dotclaude:prune` appears in README command table (AD-5)

Verification layer: grep check

- [x] B-6.1: `/dotclaude:prune` present in README
  ```bash
  grep -n '/dotclaude:prune' README.md
  ```
  Expected: `>=1` match (the added command-table row)

### B-7: `commands/code.md` is byte-identical to main (FR-2b scope guard)

Verification layer: git diff

- [x] B-7.1: No changes to `commands/code.md`
  ```bash
  git diff main -- commands/code.md | wc -l
  ```
  Expected: `0`

### B-8: README 13-Step Workflow table is unchanged (AD-4)

Verification layer: git diff + read

- [x] B-8.1: `git diff main -- README.md` shows only the command-table row addition; the 13-Step Workflow table block is byte-identical to main
  Read the README 13-Step Workflow table and confirm it is unchanged. The only diff in README.md is the new `/dotclaude:prune` row in the command table.

### B-9: `commands/start-new.md` code-validator invocation is unchanged (FR-2b scope guard)

Verification layer: read check

- [x] B-9.1: The code-validator invocation prompt at ~lines 750-816 of `commands/start-new.md` is unchanged
  Read `commands/start-new.md` lines 750-816 and confirm no pruner-related changes there (pruner sub-flow is in Step 7 only, not in the code-validator invocation block).

## FR / NFR Coverage Mapping

| Requirement | Covered by |
|-------------|------------|
| FR-2a (pruner doc mode in design.md and start-new.md Step 7) | B-1.1 (design.md and start-new.md hits) |
| FR-2b (pruner code mode in code-validator internal loop) | B-1.1 (code-validator hit), B-2, B-3, B-4, B-5 |
| FR-5 (commands/prune.md command with AD-7 resolution) | B-1.1 (prune.md hit) |
| AD-5 (README command table row) | B-6 |
| Scope guard: commands/code.md unchanged | B-7 |
| Scope guard: README 13-step table unchanged | B-8 |
| Scope guard: code-validator invocation prompt unchanged | B-9 |
