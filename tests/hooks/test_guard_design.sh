#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
H="$HOOKS/guard-design.sh"; SM="$HOOKS/spec-meta.sh"
run() { # run <cwd> <subagent_type> <prompt>
  jq -nc --arg c "$1" --arg s "$2" --arg p "$3" '{session_id:"s",cwd:$c,hook_event_name:"PreToolUse",tool_name:"Agent",tool_input:{subagent_type:$s,prompt:$p}}' | "$H"
}
SPEC="$DOC/SPEC.md"
out=$(run "$W" dotclaude:designer "Design from $SPEC please"); contains "(a) unapproved -> deny" "$out" '"permissionDecision":"deny"'
"$SM" approve "$SPEC" >/dev/null
out=$(run "$W" dotclaude:designer "Design from $SPEC please"); empty "(b) approved -> allow" "$out"
echo "edited" >>"$SPEC"
out=$(run "$W" dotclaude:designer "Design from $SPEC please"); contains "(c) edited after approve -> deny" "$out" '"permissionDecision":"deny"'
out=$(run "$W" dotclaude:coders:coder-python "Design from $SPEC"); empty "(d) other agent -> allow" "$out"
mkdir -p "$T/empty"; git -C "$T/empty" init -q
out=$(run "$T/empty" dotclaude:designer "no path here"); empty "(e) no SPEC -> allow" "$out"
# fallback to spec-meta find when prompt has no path
out=$(run "$W" dotclaude:designer "no path here"); contains "fallback find -> deny" "$out" 'deny'
finish
