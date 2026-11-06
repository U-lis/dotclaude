#!/usr/bin/env bash
# shellcheck disable=SC2015
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
export TMPDIR="$T"
H="$HOOKS/guard-review.sh"
STORE="$T/dotclaude-review-$(id -u)"
RV="$R/.dc_workspace/reviews/2026_11_06-kw"
S1="$RV/r1/STATUS.md"; S2="$RV/r2/STATUS.md"
SPEC="$DOC/SPEC.md"; PLAN="$DOC/PHASE_1_PLAN_x.md"
deny='"permissionDecision":"deny"'
run() { # run <agent_type|-null|-missing> <agent_id> <tool_name> [file_path]
  local at
  case "$1" in -null) at=null ;; -missing) at='"__missing__"' ;; *) at=\"$1\" ;; esac
  jq -nc --arg c "$W" --argjson at "$at" --arg id "$2" --arg tn "$3" --arg fp "${4:-}" \
    '{session_id:"s",cwd:$c,hook_event_name:"PreToolUse",agent_type:$at,agent_id:$id,tool_name:$tn,
      tool_input:(if $fp=="" then {query:"x"} else {file_path:$fp} end)}
     | if $at=="__missing__" then del(.agent_type) else . end' | (cd "$T" && "$H")
}
status() { # status <path> <restatement body>
  mkdir -p "$(dirname "$1")"
  printf '## Target\nkw, pr, head abc, base main\n\n## Restatement\n%b\n## Progress\n- step 2\n' "$2" >"$1"
}
EMPTY_BODY='\n<!-- what the change claims to do -->\n\n'
FILLED_BODY='<!-- note -->\nAdds a gate before intent sources.\n'

# binding: first Write wins, a later Write by the same agent leaves it
out=$(run dotclaude:reviewer agentA Write "$S1"); empty "bind: Write STATUS.md allowed" "$out"
[ "$(cat "$STORE/agentA" 2>/dev/null)" = "$S1" ] && ok "bind: agent_id -> r1 path" || ko "bind: agent_id -> r1 path" "$(cat "$STORE/agentA" 2>&1)"
run dotclaude:reviewer agentA Write "$S2" >/dev/null
[ "$(cat "$STORE/agentA" 2>/dev/null)" = "$S1" ] && ok "bind: r2 Write does not rebind" || ko "bind: r2 Write does not rebind" "$(cat "$STORE/agentA")"
run dotclaude:reviewer 'agent/../B$' Write "$S2" >/dev/null
[ -f "$STORE/agentB" ] && ok "bind: agent_id sanitized" || ko "bind: agent_id sanitized" "$(ls "$STORE")"
rm -f "$STORE/agentB"
run dotclaude:reviewer agentX Write "$RV/r1/REVIEW.md" >/dev/null
[ -e "$STORE/agentX" ] && ko "bind: other file does not bind" "bound" || ok "bind: other file does not bind"
run dotclaude:reviewer agentX Write "$RV/notes/STATUS.md" >/dev/null
[ -e "$STORE/agentX" ] && ko "bind: non-round directory does not bind" "bound" || ok "bind: non-round directory does not bind"
run dotclaude:reviewer agentX Write "$R/.dc_workspace/reviews/r1/STATUS.md" >/dev/null
[ -e "$STORE/agentX" ] && ko "bind: path outside reviews/{target}/r{n} does not bind" "bound" || ok "bind: path outside reviews/{target}/r{n} does not bind"

# bound, Restatement empty (blank and comment lines only): intent calls denied
status "$S1" "$EMPTY_BODY"
out=$(run dotclaude:reviewer agentA mcp__notion__search); contains "empty: notion MCP denied" "$out" "$deny"
contains "empty: deny names Restatement" "$out" "Restatement"
out=$(run dotclaude:reviewer agentA mcp__claude_ai_Atlassian__getJiraIssue); contains "empty: atlassian MCP denied (case folded)" "$out" "$deny"
out=$(run dotclaude:reviewer agentA Read "$SPEC"); contains "empty: SPEC Read denied" "$out" "$deny"
out=$(run dotclaude:reviewer agentA Read "$PLAN"); contains "empty: PLAN Read denied" "$out" "$deny"
out=$(run dotclaude:reviewer agentA Read "$DOC/GLOBAL.md"); empty "empty: other Read allowed" "$out"
out=$(run dotclaude:reviewer agentA mcp__slack__x); empty "empty: MCP outside globs allowed" "$out"
grep -q 'guard-review deny agentA mcp__notion__search' "$R/.dc_workspace/.hook.log" && ok "deny logged" || ko "deny logged" "$(cat "$R/.dc_workspace/.hook.log" 2>&1)"
grep -q "guard-review bind agentA $S1" "$R/.dc_workspace/.hook.log" && ok "bind logged" || ko "bind logged" x

# non-reviewer or main session, with a STATUS.md present: nothing
for at in dotclaude:designer -null -missing; do
  out=$(run "$at" agentA mcp__notion__search); empty "agent_type $at: MCP silent" "$out"
  out=$(run "$at" agentA Read "$SPEC"); empty "agent_type $at: SPEC Read silent" "$out"
done
out=$(jq -nc --arg c "$W" '{cwd:$c,agent_type:null,agent_id:"agentA",tool_name:"mcp__notion__search",tool_input:{query:"dotclaude:reviewer"}}' | "$H")
empty "main session naming the reviewer in input: silent" "$out"

# bound, Restatement filled: same calls allowed
status "$S1" "$FILLED_BODY"
out=$(run dotclaude:reviewer agentA mcp__notion__search); empty "filled: notion MCP allowed" "$out"
out=$(run dotclaude:reviewer agentA Read "$SPEC"); empty "filled: SPEC Read allowed" "$out"
out=$(run dotclaude:reviewer agentA Read "$PLAN"); empty "filled: PLAN Read allowed" "$out"
grep -q 'guard-review allow agentA mcp__notion__search' "$R/.dc_workspace/.hook.log" && ok "allow logged" || ko "allow logged" x

# concurrency: A bound to r1 (filled), B bound to r2 of the same target (empty)
run dotclaude:reviewer agentB Write "$S2" >/dev/null
status "$S2" "$EMPTY_BODY"
out=$(run dotclaude:reviewer agentA mcp__notion__search); empty "concurrent: A (filled) allowed" "$out"
out=$(run dotclaude:reviewer agentB mcp__notion__search); contains "concurrent: B (empty) denied" "$out" "$deny"
out=$(run dotclaude:reviewer agentB Read "$SPEC"); contains "r1 restatement does not open the r2 gate" "$out" "$deny"

# unbound reviewer: intent MCP denied with how-to; SPEC and PLAN Reads allowed
out=$(run dotclaude:reviewer agentC mcp__notion__search); contains "unbound: MCP denied" "$out" "$deny"
contains "unbound: message names STATUS.md" "$out" "STATUS.md"; contains "unbound: message names Restatement" "$out" "Restatement"
grep -q 'guard-review deny agentC mcp__notion__search unbound' "$R/.dc_workspace/.hook.log" && ok "unbound deny logged" || ko "unbound deny logged" x
out=$(run dotclaude:reviewer agentC Read "$SPEC"); empty "unbound: SPEC Read allowed" "$out"
out=$(run dotclaude:reviewer agentC Read "$PLAN"); empty "unbound: PLAN Read allowed" "$out"
out=$(run dotclaude:reviewer agentC mcp__slack__x); empty "unbound: MCP outside globs allowed" "$out"

# configured review.intent_tools replaces the defaults
printf '{ "working_directory": ".dc_workspace", "review": { "intent_tools": ["*slack*"] } }\n' >"$R/.claude/dotclaude-config.json"
out=$(run dotclaude:reviewer agentB mcp__slack__x); contains "config: configured glob denied" "$out" "$deny"
out=$(run dotclaude:reviewer agentB mcp__notion__search); empty "config: default glob no longer applies" "$out"
printf '{ "working_directory": ".dc_workspace" }\n' >"$R/.claude/dotclaude-config.json"

# fail open: unreadable STATUS.md, malformed input
rm -f "$S2"
out=$(run dotclaude:reviewer agentB mcp__notion__search); empty "unreadable STATUS.md: allowed" "$out"
out=$(printf '{"agent_type":"dotclaude:reviewer","tool_name":"mcp__notion__x"' | "$H"); empty "malformed JSON: silent" "$out"
out=$(run dotclaude:reviewer "" mcp__notion__search); contains "no agent_id: treated as unbound" "$out" "STATUS.md"

# no binding, no STATUS.md, non-reviewer: nothing
rm -rf "$STORE" "$RV"
out=$(run -null "" Read "$SPEC"); empty "no binding, no STATUS.md: silent" "$out"

# the cheap string check runs before any jq/python3 call
SPY="$T/spy"; mkdir -p "$SPY"
printf '#!/bin/sh\necho called >>"%s/calls"\nexec %s "$@"\n' "$SPY" "$(command -v jq)" >"$SPY/jq"; chmod +x "$SPY/jq"
jq -nc --arg fp "$SPEC" '{agent_type:null,tool_name:"Read",tool_input:{file_path:$fp}}' | PATH="$SPY:$PATH" "$H" >/dev/null
[ -e "$SPY/calls" ] && ko "non-reviewer input calls no jq" "jq was called" || ok "non-reviewer input calls no jq"
finish
