---
description: Execute coding work for a specific phase. Use when implementing a phase like /dotclaude:code 1, /dotclaude:code 2, /dotclaude:code 3A, /dotclaude:code 3.5 for merge phases, or /dotclaude:code all for fully automatic execution of all phases.
---
# /dotclaude:code [phase | all]

Implement one phase (or every remaining phase) from the design documents, validate it, and commit it. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; prompt templates in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`.

## Resolve paths

Locate SPEC.md with `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh find` and read `worktree_path` and `doc_dir` from its metadata block. Without SPEC.md, use the config files, `worktree_path = .`, and the only directory under `{working_directory}` that contains PLAN files. Run from inside the worktree; if the current branch is `base_branch`, stop.

Prerequisites: `GLOBAL.md` and the phase's `PHASE_{k}_PLAN_{keyword}.md` and `PHASE_{k}_TEST.md` exist, and the phases this one depends on (GLOBAL.md Phase Overview) are Complete.

## One phase

1. Read the PLAN, the TEST, and GLOBAL.md.
2. Pick the coder from the language the PLAN names:

   | Language | Agent |
   |----------|-------|
   | Python | `dotclaude:coders:coder-python` |
   | JavaScript / TypeScript | `dotclaude:coders:coder-javascript` |
   | Svelte | `dotclaude:coders:coder-svelte` |
   | Rust | `dotclaude:coders:coder-rust` |
   | SQL / database | `dotclaude:coders:coder-sql` |

3. Call the coder with the phase id, the worktree path, and the document paths. For a parallel phase (`3A`), the worktree is `../{project_name}-{type}-{keyword}-3A`; create it first with `git worktree add <path> -b {type}/{keyword}-3A {type}/{keyword}` if it does not exist.
4. Call code-validator once with the worktree path, the coder namespace, the phase id, and the PLAN/TEST/GLOBAL paths. It runs the validate-fix loop, updates the documents, and leaves the `.validated/PHASE_{k}` marker on PASS (Contract: Validate-fix loop).
5. On PASS, commit the changed code together with the PLAN, GLOBAL, TEST, and SPEC documents (the validator checked off this phase's requirements in SPEC.md; Contract: Commits). On FAIL, the phase is already marked Skipped in GLOBAL.md; report the validator's unresolved issues and stop. When every phase in GLOBAL.md is Complete or Skipped, run `spec-meta.sh stage <spec> local_test`.

Report: phase, status, files changed, validator summary (lint, types, tests), commit hash, and the next command (`/dotclaude:code {next}`, `/dotclaude:code {k}.5` after a parallel group, or `/dotclaude:merge` when all phases are done).

## Merge phase (`{k}.5`)

Follow `PHASE_{k}.5_PLAN_MERGE.md`: from the main worktree on `{type}/{keyword}`, merge each `{type}/{keyword}-{k}X` branch in the listed order with `--no-edit`, resolve conflicts as the plan describes, run code-validator for the merge phase (full suite), commit, then `git worktree remove` each parallel worktree and delete its branch with `git branch -d`.

## `all`

Run every phase that is not Complete, in dependency order from the GLOBAL.md Phase Overview (fallback: `PHASE_*_PLAN_*.md` file names, where `{k}` depends on `{k-1}`, `{k}A/B` on `{k-1}`, and `{k}.5` on all `{k}X`). Parallel phases in one group are run in a single message so the coders work concurrently, each in its own worktree, then the merge phase runs. A FAIL does not stop the run: the phase stays Skipped and the next phase starts, because later phases may not depend on it and the user gets one report at the end.

The `all` invocation is the user's instruction to commit each phase and continue to the next without asking.

Final report: a table of phase, status, commit, and note; the unresolved issues of skipped phases with file and line; and the commands to retry them (`/dotclaude:code {k}`) before `/dotclaude:merge` and `/dotclaude:tagging`.
