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
# also from primary cwd (any worktree of repo)
out=$(run "$R"); contains "block seen from primary cwd" "$out" '"decision":"block"'
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
finish
