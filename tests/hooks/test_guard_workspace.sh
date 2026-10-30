#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
H="$HOOKS/guard-workspace.sh"
WS="$W/.dc_workspace"
w() { # w <cwd> <tool> <file_path>
  jq -nc --arg c "$1" --arg t "$2" --arg f "$3" '{session_id:"s",cwd:$c,hook_event_name:"PreToolUse",tool_name:$t,tool_input:{file_path:$f}}' | "$H"
}
b() { # b <cwd> <command>
  jq -nc --arg c "$1" --arg m "$2" '{session_id:"s",cwd:$c,hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$m}}' | "$H"
}
out=$(w "$W" Write "$DOC/NOTES.md"); empty "Write .md -> allow" "$out"
out=$(w "$W" Write "$DOC/data.jsonl"); contains "Write .jsonl -> deny" "$out" '"permissionDecision":"deny"'
contains "deny reason text" "$out" 'Only documents (.md/.json/.log) belong in .dc_workspace/'
out=$(b "$W" "python gen.py > $DOC/out.csv"); contains "Bash > .csv -> deny" "$out" '"permissionDecision":"deny"'
out=$(b "$W" "python gen.py > $DOC/run.log"); empty "Bash > .log -> allow" "$out"
out=$(b "$W" "python gen.py 2>&1 | tee $DOC/x.txt"); contains "Bash tee .txt -> deny" "$out" 'deny'
out=$(b "$W" "cp /tmp/a.bin $DOC/a.bin"); contains "Bash cp .bin -> deny" "$out" 'deny'
out=$(w "$W" Write "$W/src/data.jsonl"); empty "outside workspace -> allow" "$out"
out=$(b "$W" "echo x > $W/out.csv"); empty "Bash outside workspace -> allow" "$out"
out=$(w "$W" Write "$DOC/.validated/PHASE_1"); empty ".validated -> allow" "$out"
out=$(w "$W" Write "$WS/.snapshots/20260101-000000.tar.gz"); empty "snapshot tar.gz -> allow" "$out"
out=$(w "$W" Write "$DOC/COMPLETION_REPORT.md"); contains "report file -> deny" "$out" 'Reports are not files'
for n in FINAL_REPORT.md PROGRESS.md VALIDATION.md; do
  out=$(w "$W" Write "$DOC/$n"); contains "$n -> deny" "$out" 'deny'
done
out=$(w "$W" Write "$DOC/SPEC_W2.md"); contains "_W2 variant -> deny" "$out" 'deny'
out=$(w "$W" Write "$WS/referral__2/SPEC.md"); contains "__2 dir -> deny" "$out" 'deny'
out=$(w "$W" Write "$DOC/GLOBAL.md"); empty "GLOBAL.md -> allow" "$out"
mkdir -p "$T/nogit"
out=$(w "$T/nogit" Write "$T/nogit/.dc_workspace/data.jsonl"); empty "no-git cwd -> allow" "$out"
out=$(echo 'garbage' | "$H"); empty "bad input -> allow" "$out"
finish
