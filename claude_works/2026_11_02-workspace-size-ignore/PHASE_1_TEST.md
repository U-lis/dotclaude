# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Primary session ignores a big worktree workspace | FR-1 | normal | integration | tests/hooks/test_stop_hook.sh::(n) primary cwd ignores big worktree workspace | hooks/check-validation-complete.sh:53 |
| Primary session warns on its own workspace | FR-1 | normal | integration | tests/hooks/test_stop_hook.sh::(n) primary cwd warns on its own workspace | hooks/check-validation-complete.sh:53 |
| Worktree session ignores a big primary workspace | FR-1 | boundary | integration | tests/hooks/test_stop_hook.sh::(n) worktree cwd ignores big primary workspace | hooks/check-validation-complete.sh:54 |
| Matching glob leaves the entry out of the size | FR-2 | normal | integration | tests/hooks/test_stop_hook.sh::(k) ignored dir -> no warn | hooks/check-validation-complete.sh:58 |
| Dated entry with a matching undated name is left out of the size | FR-2 | boundary | integration | tests/hooks/test_stop_hook.sh::(o) dated dir of an ignored name -> no warn | hooks/_lib.sh:126 |
| Pattern with a trailing slash matches | FR-2 | boundary | integration | tests/hooks/test_stop_hook.sh::(m) trailing slash pattern -> no warn | hooks/_lib.sh:117 |
| Ignore list holds in the Stop hook without jq | FR-2 | invalid | integration | tests/hooks/test_stop_hook.sh::(k) no jq: ignored dir -> no warn | hooks/_lib.sh:108 |
| Warning is logged | FR-3 | normal | integration | tests/hooks/test_stop_hook.sh::(j) warn logged | hooks/check-validation-complete.sh:64 |
| Warning names the largest entry | FR-3 | normal | integration | tests/hooks/test_stop_hook.sh::(j) names largest dir | hooks/check-validation-complete.sh:65 |
| Warning is emitted with python3 when jq is absent | FR-3 | invalid | integration | tests/hooks/test_stop_hook.sh::(l) no jq: other dir -> warn | hooks/_lib.sh:46 |
| Log is gzipped to the repo folder | FR-4 | normal | integration | tests/hooks/test_workspace_archive.sh::gzip dest | hooks/workspace-archive.sh:291 |
| Image is moved as is | FR-4 | normal | integration | tests/hooks/test_workspace_archive.sh::move dest | hooks/workspace-archive.sh:282 |
| Gzip output keeps the source's mode | FR-4 | boundary | integration | tests/hooks/test_workspace_archive.sh::gzip keeps 0640 mode | hooks/workspace-archive.sh:301 |
| Ledger row records the file | FR-4 | normal | integration | tests/hooks/test_workspace_archive.sh::ledger row | hooks/workspace-archive.sh:304 |
| Ledger date comes from --date | FR-4 | normal | integration | tests/hooks/test_workspace_archive.sh::ledger date from --date | hooks/workspace-archive.sh:272 |
| --date with another form is refused | FR-7 | invalid | integration | tests/hooks/test_workspace_archive.sh::bad --date -> exit 2 | hooks/workspace-archive.sh:65 |
| Tracked and small files stay | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::$n stays | hooks/workspace-archive.sh:335 |
| Code and config types stay under test output | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::.$e under test output stays | hooks/workspace-archive.sh:245 |
| Recently changed file is left alone | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::recent reported | hooks/workspace-archive.sh:334 |
| Open file stays (fuser) | FR-5 | concurrency | integration | tests/hooks/test_workspace_archive.sh::open file stays | hooks/workspace-archive.sh:211 |
| Open file is reported (lsof) | FR-5 | concurrency | integration | tests/hooks/test_workspace_archive.sh::open file reported by lsof | hooks/workspace-archive.sh:212 |
| No fuser or lsof stops apply | FR-5 | error | integration | tests/hooks/test_workspace_archive.sh::no fuser or lsof -> apply exit 2 | hooks/workspace-archive.sh:206 |
| Excluded file stays | FR-5 | normal | integration | tests/hooks/test_workspace_archive.sh::exclude matches a worktree's name | hooks/workspace-archive.sh:328 |
| Excluded file stays after preserve renames its dir | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::excluded file stays after rename | hooks/workspace-archive.sh:329 |
| Nested repositories and dependency trees are not entered | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::$n pruned | hooks/workspace-archive.sh:109 |
| __pycache__ contents are left alone | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::pycache left alone | hooks/workspace-archive.sh:327 |
| Directories the script emptied go, up to the doc dir | FR-5 | normal | integration | tests/hooks/test_workspace_archive.sh::emptied subdir removed | hooks/workspace-archive.sh:311 |
| Primary doc dir shared with a staying worktree stays | FR-5 | concurrency | integration | tests/hooks/test_workspace_archive.sh::in-flight stays | hooks/workspace-archive.sh:324 |
| Ignore list holds in files without jq | FR-5 | invalid | integration | tests/hooks/test_workspace_archive.sh::no jq: ignored reported | hooks/_lib.sh:19 |
| Dated doc dir whose undated name is ignored is not archived | FR-5 | boundary | integration | tests/hooks/test_workspace_archive.sh::dated dir of an ignored name stays | hooks/_lib.sh:126 |
| Unreadable ignore list stops apply | FR-5 | invalid | integration | tests/hooks/test_workspace_archive.sh::unreadable ignore $bad -> exit 2 | hooks/workspace-archive.sh:191 |
| No jq or python3 stops the script | FR-5 | error | integration | tests/hooks/test_workspace_archive.sh::no jq or python3: preserve -> exit 2 | hooks/workspace-archive.sh:83 |
| working_directory at or above the repository root is refused | FR-5 | invalid | integration | tests/hooks/test_workspace_archive.sh::working_directory $wd -> exit 2 | hooks/workspace-archive.sh:87 |
| Unset archive dir stops apply | FR-6 | invalid | integration | tests/hooks/test_workspace_archive.sh::unset dir reported | hooks/workspace-archive.sh:221 |
| Non-absolute archive dir stops apply | FR-6 | invalid | integration | tests/hooks/test_workspace_archive.sh::relative dir -> exit 3 | hooks/workspace-archive.sh:224 |
| Undated doc dir gets a date on preserve | FR-7 | normal | integration | tests/hooks/test_workspace_archive.sh::undated doc dated | hooks/workspace-archive.sh:123 |
| Existing undated dir in the primary keeps its name | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::existing undated: no dated copy | hooks/workspace-archive.sh:121 |
| Existing undated dir keeps its name in the archive | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::existing undated: archive keeps name | hooks/workspace-archive.sh:121 |
| Preserve reports a directory it did not enter | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::preserve row for pruned $n | hooks/workspace-archive.sh:139 |
| A plain file named like a dependency directory is copied | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::file named venv is copied | hooks/workspace-archive.sh:109 |
| Preserve failed copy leaves no partial destination | FR-7 | error | integration | tests/hooks/test_workspace_archive.sh::preserve failed copy leaves no destination | hooks/workspace-archive.sh:158 |
| Preserve conflict is reported | FR-7 | error | integration | tests/hooks/test_workspace_archive.sh::preserve conflict row | hooks/workspace-archive.sh:151 |
| Preserve never overwrites the primary | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::preserve never overwrites | hooks/workspace-archive.sh:153 |
| Preserve is silent on the same content | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::preserve same content exit 0 | hooks/workspace-archive.sh:149 |
| Preserve skips a tracked, clean source | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::preserve tracked clean exit 0 | hooks/workspace-archive.sh:150 |
| Preserve reports a tracked, modified source | FR-7 | error | integration | tests/hooks/test_workspace_archive.sh::preserve tracked dirty exit 1 | hooks/workspace-archive.sh:116 |
| Preserve skips the top-level hook log | FR-7 | boundary | integration | tests/hooks/test_workspace_archive.sh::preserve skips hook log exit 0 | hooks/workspace-archive.sh:143 |
| Real venv is replaced with a relative link | FR-8 | normal | integration | tests/hooks/test_workspace_archive.sh::relative link | hooks/workspace-archive.sh:179 |
| Current worktree and symlinks are skipped | FR-8 | boundary | integration | tests/hooks/test_workspace_archive.sh::deps skips current | hooks/workspace-archive.sh:169 |
| Session worktree is skipped with --current omitted | FR-8 | boundary | integration | tests/hooks/test_workspace_archive.sh::deps skips session worktree | hooks/workspace-archive.sh:166 |
| Subdirectory as --current counts as its worktree | FR-8 | boundary | integration | tests/hooks/test_workspace_archive.sh::deps --current subdirectory | hooks/workspace-archive.sh:167 |
| CLAUDE_CONFIG_DIR overrides ~/.claude | FR-9 | normal | integration | tests/hooks/test_lib_cfg.sh::CLAUDE_CONFIG_DIR overrides ~/.claude | hooks/_lib.sh:75 |
| spec-meta.sh find reads CLAUDE_CONFIG_DIR | FR-9 | normal | integration | tests/hooks/test_lib_cfg.sh::find: CLAUDE_CONFIG_DIR over ~/.claude | hooks/spec-meta.sh:95 |
| init-config.sh reads CLAUDE_CONFIG_DIR | FR-9 | normal | integration | tests/hooks/test_lib_cfg.sh::init-config: CLAUDE_CONFIG_DIR over ~/.claude | hooks/init-config.sh:60 |
| Different file at the destination keeps the original | NFR-1 | error | integration | tests/hooks/test_workspace_archive.sh::conflict keeps original | hooks/workspace-archive.sh:297 |
| Same content at the destination removes the original | NFR-1 | boundary | integration | tests/hooks/test_workspace_archive.sh::same content -> original gone | hooks/workspace-archive.sh:305 |
| Destination that resolves to the source keeps the file | NFR-1 | error | integration | tests/hooks/test_workspace_archive.sh::destination is the source keeps the file | hooks/workspace-archive.sh:292 |
| Re-run after a failed copy finishes the archive | NFR-2 | normal | integration | tests/hooks/test_workspace_archive.sh::re-run after failure archives the original | hooks/workspace-archive.sh:341 |
| Preserve re-run after a failed copy succeeds | NFR-2 | normal | integration | tests/hooks/test_workspace_archive.sh::preserve re-run writes the whole file | hooks/workspace-archive.sh:158 |
| Preserve failure exits non-zero, which stops the purge | NFR-2 | error | integration | tests/hooks/test_workspace_archive.sh::preserve conflict exit 1 | hooks/workspace-archive.sh:152 |
| files failure exits non-zero, which stops the purge | NFR-2 | error | integration | tests/hooks/test_workspace_archive.sh::failed verification exit 1 | hooks/workspace-archive.sh:344 |
| Missing path is skipped with a row (files, preserve) | NFR-3 | boundary | integration | tests/hooks/test_workspace_archive.sh::missing path: $kind $mode row | hooks/workspace-archive.sh:73 |
| Missing path warns on stderr | NFR-3 | boundary | integration | tests/hooks/test_workspace_archive.sh::missing path: $kind $mode warns | hooks/workspace-archive.sh:74 |
| Missing path exits 0 | NFR-3 | boundary | integration | tests/hooks/test_workspace_archive.sh::missing path: $kind $mode -> exit 0 | hooks/workspace-archive.sh:75 |
| Existing path that is not a checkout exits 2 and names the path | NFR-3 | invalid | integration | tests/hooks/test_workspace_archive.sh::not a checkout names the path | hooks/workspace-archive.sh:78 |
| Unset archive dir with no candidates exits 0 | NFR-3 | boundary | integration | tests/hooks/test_workspace_archive.sh::unset dir, no candidates -> exit 0 | hooks/workspace-archive.sh:340 |
| No candidates changes nothing | NFR-3 | boundary | integration | tests/hooks/test_workspace_archive.sh::no candidates changes nothing | hooks/workspace-archive.sh:340 |
| Unset archive dir with candidates still exits 3 | FR-6 | invalid | integration | tests/hooks/test_workspace_archive.sh::unset dir -> exit 3 | hooks/workspace-archive.sh:340 |
| Failed copy verification keeps the original (cmp) | NFR-1 | error | integration | tests/hooks/test_workspace_archive.sh::failed cmp keeps original | hooks/workspace-archive.sh:283 |
| Failed copy verification keeps the original (gzip) | NFR-1 | error | integration | tests/hooks/test_workspace_archive.sh::failed gzip keeps original | hooks/workspace-archive.sh:280 |

- Test names are the first argument of the `ok`/`ko` helpers in `tests/hooks/_fixture.sh`, or the literal label in the test file; `bash tests/hooks/run_all.sh` runs them. `$n stays` is the loop over SPEC.md, small.log, fresh.log, tracked.log. `$n pruned` is the loop over node_modules/n.log, sub/.venv/v.log, sub/venv/w.log, sub/.git/g.log. `.$e under test output stays` is the loop over tsx, jsx, java, kt, c, h, cpp, rb, css, scss, yaml, yml, toml. `unreadable ignore $bad` is the loop over a string, an object and a list holding a number. `working_directory $wd` is the loop over `.`, `./`, `sub/..`, `..`. `preserve row for pruned $n` is the loop over node_modules, .git, venv and .venv directories. `missing path: $kind $mode` is the loop over files and preserve, plan and apply.
- NFR-2 has two parts. The rows above pin the script's non-zero exit and that a re-run is safe. The stop rule itself is prose in `commands/purge.md` (Stop on archive failure) and `commands/merge.md` step 6, with no automated test: nothing in `tests/hooks` reads command files, and `scripts/lint-prompts.sh` only forbids patterns.
- NFR-3 also has prose parts with no automated test, for the same reason: the missing-worktree and no-candidates rules in `commands/purge.md`, and the no-separate-worktree rule in `commands/merge.md` step 6.
