#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
H="$HOOKS/title-prefix.sh"; OUT="$T/tty"
setcfg() { printf '%s\n' "$1" >"$R/.claude/dotclaude-config.json"; : >"$OUT"; }
ev() { TITLE_PREFIX_TTY="$OUT" "$H" "${@:2}" <<<"$1"; }
NAME=x-feature-kw
notif="{\"cwd\":\"$W\",\"hook_event_name\":\"Notification\",\"notification_type\":\"permission_prompt\",\"message\":\"m\"}"

setcfg '{"working_directory":".dc_workspace","title_prefix":true,"language":"en_US"}'
ev "$notif"; got=$(cat "$OUT")
[ "$got" = "$(printf '\033]0;[INPUT] %s\007' "$NAME")" ] && ok "Notification en -> [INPUT]" || ko "en" "$(printf %q "$got")"
setcfg '{"title_prefix":true,"language":"ko_KR"}'
ev "$notif"; contains "ko -> [확인요청]" "$(cat "$OUT")" "[확인요청] $NAME"
: >"$OUT"; ev "{\"cwd\":\"$W\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"AskUserQuestion\"}"
contains "AskUserQuestion -> prefix" "$(cat "$OUT")" "[확인요청] $NAME"
: >"$OUT"; ev "{\"cwd\":\"$W\",\"hook_event_name\":\"UserPromptSubmit\",\"prompt\":\"hi\"}"
got=$(cat "$OUT"); [ "$got" = "$(printf '\033]0;%s\007' "$NAME")" ] && ok "UserPromptSubmit -> plain name" || ko "ups" "$(printf %q "$got")"
: >"$OUT"; ev "{\"cwd\":\"$W\"}" --event UserPromptSubmit
[ -s "$OUT" ] && ok "--event arg" || ko "--event arg" "empty"
: >"$OUT"; ev "{\"cwd\":\"$W\",\"hook_event_name\":\"Notification\",\"notification_type\":\"auth_success\"}"
empty "other notification type -> nothing" "$(cat "$OUT")"
setcfg '{"working_directory":".dc_workspace"}'
ev "$notif"; empty "title_prefix unset -> nothing" "$(cat "$OUT")"
finish
