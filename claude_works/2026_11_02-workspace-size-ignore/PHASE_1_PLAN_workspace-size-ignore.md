# Phase 1: workspace-size-ignore

## Objective

Narrow the Stop hook size warning and move purge's workspace cleanup into a tested script.

## Requirements

- FR-1
- FR-2
- FR-3
- FR-4
- FR-5
- FR-6
- FR-7
- FR-8
- FR-9
- FR-10
- NFR-1
- NFR-2

---

## Scope

### In Scope
- `hooks/check-validation-complete.sh`, `hooks/workspace-archive.sh`, `hooks/_lib.sh`, `hooks/spec-meta.sh`, `hooks/init-config.sh`
- `commands/purge.md`, `commands/_contract.md`, `commands/configure.md`, `README.md`, `CHANGELOG.md`, version files
- `tests/hooks/_fixture.sh`, `tests/hooks/test_stop_hook.sh`, `tests/hooks/test_workspace_archive.sh`, `tests/hooks/test_lib_cfg.sh`

### Out of Scope
- Renaming existing undated doc dirs in a primary checkout
- Project-local purge commands

---

## Instructions

### Step 1: Stop hook
Measure only `git rev-parse --show-toplevel` of the session cwd, skip entries matching `workspace_size_ignore`, and name the largest entry.

### Step 2: Script
Add `files`, `preserve` and `deps` subcommands, each with `plan` and `apply`. Dated names apply when the path is a worktree.

### Step 3: Config layer
Read `$CLAUDE_CONFIG_DIR/dotclaude-config.json` in `cfg_get`, `spec-meta.sh find` and `init-config.sh`.

### Step 4: Purge and docs
Replace the prose cleanup in `commands/purge.md` with script calls and document the keys.

---

## Completion Checklist

- [x] `commands/purge.md` and `commands/merge.md` stop and report on any non-zero exit of `files` or `preserve`, leaving that worktree and all unprocessed items: verified in commands/purge.md:221-236 and commands/merge.md:13
- [x] Stop hook measures the session worktree only (`hooks/check-validation-complete.sh`): verified in hooks/check-validation-complete.sh:53-54
- [x] `workspace_size_ignore` is read and applied (`hooks/check-validation-complete.sh`): verified in hooks/check-validation-complete.sh:49 and :58
- [x] `hooks/workspace-archive.sh` has `files`, `preserve`, `deps` with `plan` and `apply`: verified in hooks/workspace-archive.sh:4-6
- [x] `ARCHIVED.md` rows are written in the primary checkout (`hooks/workspace-archive.sh`): verified in hooks/workspace-archive.sh:249-250 and :294
- [x] `cfg_get` reads `$CLAUDE_CONFIG_DIR` (`hooks/_lib.sh`): verified in hooks/_lib.sh:75
- [x] `commands/purge.md` calls `workspace-archive.sh` for Compact workspace, Preserve documents and Dependency directories: verified in commands/purge.md:238-255
- [x] `workspace_size_ignore` and `workspace_archive_dir` are in `commands/_contract.md`, `commands/configure.md`, `README.md`: verified in commands/_contract.md (2 hits), commands/configure.md (3), README.md (3)
- [x] `tests/hooks/run_all.sh` and `scripts/lint-prompts.sh` pass: verified by run (exit 0, 349 pass)


---

## Notes

Status: Blocked. One Blocker is open after the third review (`REVIEW.md`, third round, row 2): a worktree whose directory is gone stops every purge. No data is lost. Do not release until the user decides.
