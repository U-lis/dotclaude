#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
H="$HOOKS/check-validation-complete.sh"
run() { "$H" <<<"{\"session_id\":\"s\",\"cwd\":\"$1\",\"hook_event_name\":\"Stop\",\"stop_hook_active\":${2:-false}}"; }
LOG="$R/.dc_workspace/.hook.log"

# (d) clean worktree (only untracked docs under .dc_workspace)
out=$(run "$W"); empty "clean worktree -> pass" "$out"
# (b) docs only
echo "more" >>"$DOC/PHASE_1_PLAN_kw.md"
out=$(run "$W"); rc=$?; empty "docs only -> pass" "$out"; [ $rc = 0 ] && ok "docs only exit 0" || ko "docs only exit" $rc
# (a) uncommitted code
echo code >"$W/app.py"
out=$(run "$W"); contains "uncommitted code -> block" "$out" '"decision":"block"'
contains "reason mentions file" "$out" 'app.py'
# not from the primary cwd: another worktree's work is not this session's
out=$(run "$R"); empty "dirty worktree -> no block from primary cwd" "$out"
# from a subdirectory of the session's worktree
mkdir -p "$W/sub/dir"
out=$(run "$W/sub/dir"); contains "subdirectory of worktree -> block" "$out" '"decision":"block"'
# (c) stop_hook_active
out=$(run "$W" true); empty "stop_hook_active -> silent" "$out"
# (e) log
n=$(wc -l <"$LOG" 2>/dev/null || echo 0); [ "$n" -ge 4 ] && ok "hook.log has lines ($n)" || ko "hook.log" "lines=$n"
grep -q ' Stop block ' "$LOG" && grep -q ' Stop pass ' "$LOG" && ok "log has block and pass" || ko "log content" "$(cat "$LOG")"
before=$(wc -l <"$LOG"); run "$W" >/dev/null; after=$(wc -l <"$LOG")
[ "$after" -gt "$before" ] && ok "log appended per run" || ko "log append" "$before->$after"
# (h) stage design -> skip
SM="$HOOKS/spec-meta.sh"
"$SM" stage "$DOC/SPEC.md" design >/dev/null
out=$(run "$W"); empty "(h) stage design -> pass" "$out"
grep -q 'Stop skip' "$LOG" && ok "skip reason logged" || ko "skip log" "$(tail -3 "$LOG")"
# (i) stage code -> block
"$SM" stage "$DOC/SPEC.md" code >/dev/null
out=$(run "$W"); contains "(i) stage code -> block" "$out" '"decision":"block"'
# (g) no SPEC -> skip
mv "$DOC/SPEC.md" "$T/SPEC.bak"
out=$(run "$W"); empty "(g) no SPEC -> pass" "$out"
mv "$T/SPEC.bak" "$DOC/SPEC.md"
# (f) outside git
mkdir -p "$T/nogit"
out=$(run "$T/nogit"); rc=$?; empty "non-git cwd silent" "$out"; [ $rc = 0 ] && ok "non-git exit 0" || ko "non-git exit" $rc
# (j) workspace over 10MB -> warn, no block
git -C "$W" checkout -q -- . 2>/dev/null; rm -f "$W/app.py"
# (p) a worktree session is not blocked by a different dirty worktree, whose own session is
W2="$T/x-feature-other"; git -C "$R" worktree add -q -b feature/other "$W2"
mkdir -p "$W2/.dc_workspace/2026_01_02-other"; cp "$DOC/SPEC.md" "$W2/.dc_workspace/2026_01_02-other/SPEC.md"
echo code >"$W2/other.py"
out=$(run "$W"); empty "(p) other dirty worktree -> no block" "$out"
out=$(run "$W2"); contains "(p) dirty worktree's own session -> block" "$out" '"decision":"block"'
git -C "$R" worktree remove --force "$W2"
dd if=/dev/zero of="$DOC/big.bin" bs=1M count=11 status=none
out=$(run "$W"); contains "(j) big workspace -> additionalContext" "$out" '"additionalContext":"workspace '
contains "(j) hint text" "$out" 'or add the directory to workspace_size_ignore'
contains "(j) names largest dir" "$out" 'largest: 2026_01_01-kw '
case "$out" in *'"decision":"block"'*) ko "(j) must not block" "$out";; *) ok "(j) no block";; esac
grep -q "Stop warn $W: workspace [0-9]*MB (largest 2026_01_01-kw [0-9]*MB)" "$LOG" && ok "(j) warn logged" || ko "(j) warn logged" "$(tail -3 "$LOG")"
# (k) workspace_size_ignore glob leaves the directory out of the size
printf '{ "working_directory": ".dc_workspace", "workspace_size_ignore": ["2026_01_*"] }\n' >"$R/.claude/dotclaude-config.json"
out=$(run "$W"); empty "(k) ignored dir -> no warn" "$out"
NOJQ=$(tool_path jq)
out=$(PATH=$NOJQ run "$W"); empty "(k) no jq: ignored dir -> no warn" "$out"
# (l) a non-ignored directory still counts
mkdir -p "$W/.dc_workspace/2026_02_02-other"; mv "$DOC/big.bin" "$W/.dc_workspace/2026_02_02-other/"
out=$(run "$W"); contains "(l) other dir -> warn" "$out" 'largest: 2026_02_02-other '
out=$(PATH=$NOJQ run "$W"); contains "(l) no jq: other dir -> warn" "$out" '"additionalContext":"workspace '
# (n) only the session's own worktree is measured
printf '{ "working_directory": ".dc_workspace" }\n' >"$R/.claude/dotclaude-config.json"
out=$(run "$R"); empty "(n) primary cwd ignores big worktree workspace" "$out"
mkdir -p "$R/.dc_workspace/big"; dd if=/dev/zero of="$R/.dc_workspace/big/p.bin" bs=1M count=11 status=none
rm -rf "$W/.dc_workspace/2026_02_02-other"
out=$(run "$W"); empty "(n) worktree cwd ignores big primary workspace" "$out"
out=$(run "$R"); contains "(n) primary cwd warns on its own workspace" "$out" "largest: big "
rm -rf "$R/.dc_workspace/big"; mkdir -p "$W/.dc_workspace/2026_02_02-other"; dd if=/dev/zero of="$W/.dc_workspace/2026_02_02-other/big.bin" bs=1M count=11 status=none
# (m) trailing slash in the pattern is accepted
printf '{ "working_directory": ".dc_workspace", "workspace_size_ignore": ["2026_01_*", "2026_02_02-other/"] }\n' >"$R/.claude/dotclaude-config.json"
out=$(run "$W"); empty "(m) trailing slash pattern -> no warn" "$out"
# (o) a dated entry counts as ignored when its undated name matches, as preserve renames it
printf '{ "working_directory": ".dc_workspace", "workspace_size_ignore": ["2026_01_*", "oth*"] }\n' >"$R/.claude/dotclaude-config.json"
out=$(run "$W"); empty "(o) dated dir of an ignored name -> no warn" "$out"
printf '{ "working_directory": ".dc_workspace", "workspace_size_ignore": ["2026_01_*", "nomatch*"] }\n' >"$R/.claude/dotclaude-config.json"
out=$(run "$W"); contains "(o) dated dir of another name -> warn" "$out" 'largest: 2026_02_02-other '
# (q) workspace_size_warn_primary turns off the primary's warning only; each case runs on this same big fixture
CFG="$R/.claude/dotclaude-config.json"
cfg_warn() { printf '{ "working_directory": ".dc_workspace"%s }\n' "${1:+, \"workspace_size_warn_primary\": $1}" >"$CFG"; }
mkdir -p "$R/.dc_workspace/big"; dd if=/dev/zero of="$R/.dc_workspace/big/p.bin" bs=1M count=11 status=none
cfg_warn ""
out=$(run "$R"); contains "(q) key unset -> primary warns" "$out" 'largest: big '
contains "(q) primary warning names the key" "$out" 'workspace_size_warn_primary'
cfg_warn true
out=$(run "$R"); contains "(q) key true -> primary warns" "$out" 'largest: big '
cfg_warn false
out=$(run "$R"); empty "(q) key false -> primary silent" "$out"
out=$(PATH=$NOJQ run "$R"); empty "(q) no jq: key false -> primary silent" "$out"
ln -s "$R" "$T/x-alias"
out=$(run "$T/x-alias"); empty "(q) key false -> primary silent through a symlinked cwd" "$out"
before=$(wc -l <"$LOG"); run "$R" >/dev/null; after=$(wc -l <"$LOG")
[ $((after - before)) = 1 ] && ok "(q) key false logs only the pass line" || ko "(q) key false log lines" "$before->$after"
out=$(run "$W"); contains "(q) key false -> worktree warns" "$out" 'largest: 2026_02_02-other '
case "$out" in *workspace_size_warn_primary*) ko "(q) worktree warning omits the key" "$out";; *) ok "(q) worktree warning omits the key";; esac
# (r) the key leaves the block alone. .claude/ is untracked in this fixture and would count as code on a work branch, so exclude it.
printf '.claude/\n' >"$T/excludes"; git -C "$R" config core.excludesFile "$T/excludes"
git -C "$R" checkout -q -b feature/primary
mkdir -p "$R/.dc_workspace/2026_01_03-primary"; cp "$DOC/SPEC.md" "$R/.dc_workspace/2026_01_03-primary/SPEC.md"
out=$(run "$R"); empty "(r) key false, work branch, no code -> no block" "$out"
echo code >"$R/app.py"
out=$(run "$R"); contains "(r) key false, work branch, code -> block" "$out" '"decision":"block"'
contains "(r) block names the file" "$out" 'app.py'
rm -f "$R/app.py"; rm -rf "$R/.dc_workspace/2026_01_03-primary" "$R/.dc_workspace/big" "$T/x-alias"
git -C "$R" checkout -q main; git -C "$R" branch -qd feature/primary; git -C "$R" config --unset core.excludesFile
printf '{ "working_directory": ".dc_workspace" }\n' >"$CFG"
finish
