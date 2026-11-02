# Phase 1: primary-size-warn-off

## Objective

Let a repository turn off the Stop hook size warning for its primary worktree only.

## Requirements

- FR-1
- FR-2
- FR-3
- FR-4
- NFR-1

---

## Scope

### In Scope
- `hooks/check-validation-complete.sh`, `tests/hooks/test_stop_hook.sh`
- `commands/_contract.md`, `commands/configure.md`, `README.md`, `CHANGELOG.md`, version files

### Out of Scope
- The 10MB threshold
- Warning once per session

---

## Instructions

### Step 1: Hook
Skip the size warning when the session's worktree is the primary and `workspace_size_warn_primary` is `false`.

### Step 2: Docs
Add the key next to `workspace_size_ignore`, and say which setting does what.

---

## Completion Checklist

- [x] `workspace_size_warn_primary` is read and applied: verified in hooks/check-validation-complete.sh:59
- [x] The key is in `commands/_contract.md`, `commands/configure.md`, `README.md`: verified in commands/_contract.md:18, commands/configure.md:41, README.md:138
- [x] `CHANGELOG.md` has a 0.8.2 entry and the version files say 0.8.2: verified in CHANGELOG.md:8, .claude-plugin/plugin.json:3
- [x] `tests/hooks/run_all.sh` and `scripts/lint-prompts.sh` pass: verified in tests/hooks/test_stop_hook.sh:84
