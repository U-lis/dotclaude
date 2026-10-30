#!/usr/bin/env bash
# Title hook: set terminal title to "[INPUT] <name>" when input is needed, "<name>" on prompt submit.
# Opt-in via title_prefix=true in dotclaude-config.json.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

EVENT=""
if [ "$1" = "--event" ]; then EVENT=$2; fi
INPUT=$(cat)
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
export HOOK_CWD=$CWD
[ "$(cfg_get title_prefix false)" = true ] || exit 0
[ -n "$EVENT" ] || EVENT=$(json_get "$INPUT" hook_event_name)

NAME=$(basename "$CWD")
case "$EVENT" in
  Notification)
    case "$(json_get "$INPUT" notification_type)" in
      permission_prompt|idle_prompt|agent_needs_input) ;;
      *) exit 0 ;;
    esac
    need=1 ;;
  PreToolUse)
    [ "$(json_get "$INPUT" tool_name)" = AskUserQuestion ] || exit 0
    need=1 ;;
  UserPromptSubmit) need=0 ;;
  *) exit 0 ;;
esac

TITLE=$NAME
if [ "$need" = 1 ]; then
  case "$(cfg_get language en_US)" in
    ko*) TITLE="[확인요청] $NAME" ;;
    *) TITLE="[INPUT] $NAME" ;;
  esac
fi

find_tty() {
  local pid=$PPID t i=0
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] && [ $i -lt 30 ]; do
    t=$(ps -o tty= -p "$pid" | tr -d ' ')
    if [ -n "$t" ] && [ "$t" != "?" ] && [ -w "/dev/$t" ]; then echo "/dev/$t"; return 0; fi
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
    i=$((i+1))
  done
  return 1
}

TARGET=${TITLE_PREFIX_TTY:-$(find_tty)}
[ -n "$TARGET" ] || exit 0
printf '\033]0;%s\007' "$TITLE" >>"$TARGET"
exit 0
