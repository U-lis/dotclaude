# Review

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
