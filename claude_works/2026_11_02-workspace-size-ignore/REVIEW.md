# Review

User decision on 2026-11-02 after the second review: nested `.git`, `.venv`, `venv`, `node_modules` are not archived (row 1 is intended behavior), an archive failure stops the process and is reported (row 2), and a source folder named `venv` does not occur (row 3 is accepted). A third round was run on that basis.

## Phase 1

Second and final review (static). All 12 first-review items are fixed. BLOCKERS: 2.

| # | Axis | Severity | Location | Finding |
|---|------|----------|----------|---------|
| 1 | correctness | Blocker | `hooks/workspace-archive.sh:142`, `:95-97`; `commands/purge.md:222` | `preserve` uses the pruning `walk`, so files under a nested `.git`, `.venv`, `venv` or `node_modules` are not copied, with no row and exit 0, and worktree removal then deletes them. Regression from the nested-directory fix. |
| 2 | correctness | Blocker | `commands/purge.md:222`, `:231`, `:270`; `commands/merge.md:13` | Only `preserve` exit 1 skips worktree removal. Exit 2, 126 or 127 falls through to `git worktree remove`, with nothing preserved. |
| 3 | correctness | Major | `hooks/workspace-archive.sh:155`, `:160` | `deps` deletes any non-symlink `.venv`/`venv` without checking `pyvenv.cfg` or tracked files. |
| 4 | correctness | Major | `commands/purge.md:237` | `deps` plans with eligible worktrees but applies with confirmed ones, so "Select individually" can delete venvs the preview never listed. |
| 5 | correctness | Minor | `commands/purge.md:231`, `:237` | `--removing` names confirmed worktrees, though one can stay after a failed preserve or removal. |
| 6 | correctness | Minor | `hooks/workspace-archive.sh:100-104`, `:134` | A tracked clean source differing from the primary is skipped; for an orphaned worktree that commit may be reachable only through its HEAD. |
| 7 | correctness | Minor | `hooks/workspace-archive.sh:272-286` | If the archive path resolves to the source, the same-content branch removes the only copy. |
| 8 | scope | Minor | `hooks/workspace-archive.sh:231` | The `move` list includes `.pdf`, `.zip`, `.mp4`, `.parquet`, which FR-4 does not name. |
| 10 | maintainability | Minor | `hooks/workspace-archive.sh:2-35` | The 34-line header is long, and "real virtualenvs" overstates the check. |
| 11 | tests | Minor | `tests/hooks/test_stop_hook.sh` | The `(j) warn logged` removal leaves `log_line` of the warning unpinned. |
| 12 | tests | Minor | `tests/hooks/test_workspace_archive.sh:168`, `:161-162` | The prune test pins Blocker 1 as intended; `:106` needs both `fuser` and `lsof`. |

## Phase 1, third round

User decision on 2026-11-02: having nothing to do is not a failure, so rows 2, 3 and 4 skip, warn and report. A fourth round was run on that basis.

Review after the user-authorized third round (static, plus read-only plan calls). The stop rule holds: after an archive failure no path reaches `git worktree remove` or a branch deletion. BLOCKERS: 1.

| # | Axis | Severity | Location | Finding |
|---|------|----------|----------|---------|
| 2 | correctness | Blocker | `commands/purge.md:188`, `:223`, `:279`; `hooks/workspace-archive.sh:69` | A worktree whose directory is gone passes step 8, preserve exits 2, and the stop rule ends the workflow before `git worktree prune`, so every purge and re-run stops. No data is lost. Regression from the stop rule. |
| 3 | correctness | Major | `commands/purge.md:149`, `:188`, `:248`; `hooks/workspace-archive.sh:210-216` | With `workspace_archive_dir` unset and no candidates, "Proceed with all" read literally runs `files apply`, which exits 3 and stops the purge. |
| 4 | correctness | Minor | `commands/merge.md:13` | No "no worktree" branch: preserve on a missing path or the primary exits 2 and stops cleanup. |
| 5 | correctness | Minor | `commands/merge.md:13-14` | A preserve stop does not skip step 7, which rewrites the worktree's SPEC.md and can cause a false conflict on re-run. |
| 6 | correctness | Minor | `commands/purge.md:223` | NFR-2 covers "could not run", but the prose covers only non-zero exits. |
| 7 | correctness | Minor | `hooks/workspace-archive.sh:150`, `:335` | `find` exit status is lost in process substitution, so an unreadable subdirectory is skipped with exit 0. |
| 8 | correctness | Minor | `hooks/workspace-archive.sh:69` | The error prints an empty path. |
| 9 | correctness | Minor | `hooks/workspace-archive.sh:170`; `commands/purge.md:255` | A failed `ln` prints no message, and purge does not say how to report a non-zero `deps` exit. |
| 10 | correctness | Minor | `hooks/workspace-archive.sh:141` | A tracked clean source differing from the primary is skipped; for an orphaned worktree that commit may be reachable only through its HEAD. |
| 11 | scope | Minor | `hooks/workspace-archive.sh:239` | The `move` list includes types FR-4 does not name. |
| 12 | scope | Minor | `PHASE_1_PLAN_workspace-size-ignore.md:28` | In Scope omits `commands/merge.md`. |
| 14 | maintainability | Minor | `hooks/workspace-archive.sh:2-37` | The header is 36 lines. |
| 15 | maintainability | Minor | `hooks/workspace-archive.sh:94`, `:312` | Dependency directory names appear twice. |
| 16 | tests | Minor | `tests/hooks/test_workspace_archive.sh` | Exit 2 for a missing worktree and exit 3 with no candidates are unpinned. |
| 17 | tests | Minor | `PHASE_1_TEST.md:66-67` | Rows named "...which stops the purge" pin only the script's exit. |
| 18 | tests | Minor | `tests/hooks/test_workspace_archive.sh:116-117` | The open-file tests need both `fuser` and `lsof`. |

## Phase 1, fourth round

Narrow review of the fourth-round diff (static trace). BLOCKERS: 0. The five targeted cases are fixed, and a non-zero or incomplete call still stops purge and merge cleanup.

| # | Axis | Severity | Location | Finding |
|---|------|----------|----------|---------|
| 1 | correctness | Minor | `commands/merge.md:13`; `hooks/workspace-archive.sh:72-76` | Merge gates removal on the exit code alone, so a `preserve` returning `skip-missing` exit 0 falls through to `git worktree remove`. It needs a path mismatch within the step or a flapping mount; no documented flow reaches it. |
| 2 | correctness | Minor | `commands/purge.md:90-93`, `:116`, `:200`; `commands/merge.md:13` | A temporarily unmounted worktree is treated as gone: prune drops its registration, its files survive, and later purges no longer list it. A locked worktree is not pruned but would be reported as pruned. |
| 3 | correctness | Minor | `hooks/workspace-archive.sh:72` | `[ ! -e ]` is also true for access errors, dangling symlinks and an empty argument. |
| 4 | scope | Minor | `SPEC.md` | `check-approved` exits 1 after the validator ticks a checkbox. Existing behavior, seen in every round; it gates only the design stage. |
| 6 | maintainability | Minor | `commands/purge.md:249` | The Preserve documents row list omits `skip-missing`. |

## Full diff

The third-round review above covered the full branch diff against `main`, and the fourth-round review covered the rest. Open: 0 Blockers; third-round rows 7-18 and fourth-round rows 1-6 stay as follow-ups.
