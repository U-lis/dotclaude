#!/usr/bin/env bash
# PreToolUse(Agent) hook: deny dotclaude:designer unless the SPEC is approved.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

INPUT=$(cat)
[ "$(json_get "$INPUT" tool_input.subagent_type)" = "dotclaude:designer" ] || exit 0
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
export HOOK_CWD=$CWD
PROMPT=$(json_get "$INPUT" tool_input.prompt)

SPEC=""
re_spec='[^[:space:]"'"'"'`]+/SPEC\.md'
if [[ "$PROMPT" =~ $re_spec ]]; then
  SPEC=${BASH_REMATCH[0]}
  [[ "$SPEC" = /* ]] || SPEC="$CWD/$SPEC"
  [ -f "$SPEC" ] || SPEC=""
fi
[ -n "$SPEC" ] || SPEC=$("$HERE/spec-meta.sh" find "$CWD")
[ -n "$SPEC" ] && [ -f "$SPEC" ] || exit 0

PRIMARY=$(find_worktrees "$CWD" | head -1 | cut -f1)
WD=$(cfg_get working_directory .dc_workspace); WD=${WD%/}
LOG="${PRIMARY:-$CWD}/$WD/.hook.log"
[ -n "$PRIMARY" ] || LOG=""

if msg=$("$HERE/spec-meta.sh" check-approved "$SPEC" 2>&1); then
  [ -n "$LOG" ] && log_line "$LOG" "Design allow approved $SPEC"
  exit 0
fi
msg=$(printf '%s' "$msg" | head -1)
reason="SPEC not approved (${msg:-hash mismatch or not approved}): $SPEC. Get the SPEC approved (spec-meta.sh approve) before calling the designer."
[ -n "$LOG" ] && log_line "$LOG" "Design deny $SPEC"
deny_pretool "$reason"
exit 0
