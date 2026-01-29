# Branching Strategy - Design Document

## Feature Overview

### Purpose
Enforce a proper branching strategy in the dotclaude workflow so that new work branches are always created from the latest configured base branch, not from an arbitrary HEAD.

### Problem
Currently, `git checkout -b {type}/{keyword}` creates branches from whatever commit is checked out at the time. This can produce branches based on stale or incorrect base commits. Additionally, several git commands hardcode `main` instead of reading from the configurable `base_branch` value.

### Solution
Insert an explicit `git checkout {base_branch} && git pull origin {base_branch}` step before every branch creation, and replace all hardcoded `main` references in git commands with the `{base_branch}` config value.

## Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-1 | Single-phase implementation | All changes are small textual edits to three markdown files; no code compilation, no new modules, no test infrastructure needed. A single phase keeps overhead minimal. |
| AD-2 | Use `{base_branch}` placeholder consistently | The placeholder is resolved dynamically from SPEC.md metadata or dotclaude-config.json at runtime. This keeps all commands config-driven rather than hardcoded. |
| AD-3 | Add checkout+pull as separate steps before branch creation | Explicit two-command sequence (`git checkout` then `git pull`) makes each operation visible in the workflow and allows Claude to handle errors at each point independently. |
| AD-4 | Do NOT add NFR edge-case handling instructions | Claude already handles git errors (dirty working tree, offline, missing branch) at runtime through its standard error-handling logic. Adding inline prose for every edge case would bloat the command files without benefit. |
| AD-5 | Replace hardcoded `main` only in git commands and output templates, not in descriptive prose | Sentences like "Never commit directly to main (only merge)" are conceptual guidelines, not executable commands. Replacing `main` there would reduce readability without functional benefit. |

## Data Model

No new data structures or schemas are introduced. The existing `base_branch` configuration value (already defined in SPEC.md metadata and dotclaude-config.json) is the sole data input.

Configuration resolution order (unchanged):
1. Default: `base_branch = "main"`
2. Global override: `~/.claude/dotclaude-config.json`
3. Local override: `<git_root>/.claude/dotclaude-config.json`
4. SPEC.md metadata block (written at init time, read by downstream commands)

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Apply branching strategy changes to 3 command files | Pending | None |

## File Structure

### Files to Modify

| # | File | Change Summary |
|---|------|----------------|
| 1 | `commands/start-new.md` | Insert base_branch checkout+pull before branch creation (line ~85); replace hardcoded `main` in merge step (lines ~283-284) |
| 2 | `commands/merge-main.md` | Replace hardcoded `main` in checkout+pull (line ~19), safety instruction (line ~47), output template (line ~57), and push command (line ~62) |
| 3 | `commands/init-github-issue.md` | Insert base_branch checkout+pull before branch creation (line ~155) |

### Files NOT Modified (with rationale)

| File | Reason |
|------|--------|
| `commands/init-feature.md` | Documents branch format only; does not contain branch creation git commands |
| `commands/init-bugfix.md` | Documents branch format only; does not contain branch creation git commands |
| `commands/init-refactor.md` | Documents branch format only; does not contain branch creation git commands |
| `commands/code.md` | References branch names in worktree operations but does not hardcode `main` |
