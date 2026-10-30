#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
H="$HOOKS/guard-commit.sh"
run() { # run <cwd> <command>
  jq -nc --arg c "$1" --arg m "$2" '{session_id:"s",cwd:$c,hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$m}}' | "$H"
}
echo code >"$W/app.py"; git -C "$W" add app.py
out=$(run "$W" 'git commit -m "feat(kw): complete phase 1"'); contains "(a) no marker -> deny" "$out" '"permissionDecision":"deny"'
contains "deny reason mentions PHASE_1" "$out" 'PHASE_1'
mkdir -p "$DOC/.validated"; touch "$DOC/.validated/PHASE_1"
out=$(run "$W" 'git commit -m "feat(kw): complete phase 1"'); empty "(b) marker -> allow" "$out"
rm "$DOC/.validated/PHASE_1"
out=$(run "$W" 'git commit -m "feat(kw): add stuff"'); contains "(g) no phase -> deny" "$out" '"permissionDecision":"deny"'
# (e) -C form
touch "$DOC/.validated/PHASE_2"
out=$(run "$T" "git -C $W commit -m \"feat: phase 2\""); empty "(e) -C with marker -> allow" "$out"
out=$(run "$T" "cd $W && git commit -m \"feat: phase 3\""); contains "cd form, missing marker -> deny" "$out" 'deny'
# (c) docs only
git -C "$W" reset -q
echo d >"$DOC/notes.md"; git -C "$W" add -f "$DOC/notes.md"
out=$(run "$W" 'git commit -m "docs: notes"'); empty "(c) docs only -> allow" "$out"
git -C "$W" reset -q
# (d) main in primary
echo more >>"$R/README"; git -C "$R" add README
out=$(run "$R" 'git commit -m "chore: x"'); empty "(d) main -> allow" "$out"
# (f) non-commit
out=$(run "$W" 'git status'); empty "(f) non-commit -> allow" "$out"
[ -s "$R/.dc_workspace/.hook.log" ] && ok "hook.log written" || ko "hook.log" "missing"
finish
