#!/usr/bin/env bash
# PreToolUse(Write|Edit|MultiEdit|Bash) hook: keep non-document files and report/variant names out of {working_directory}.
# Fail open on any parse doubt.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

INPUT=$(cat)
TOOL=$(json_get "$INPUT" tool_name)
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
git -C "$CWD" rev-parse --git-dir >/dev/null || exit 0
export HOOK_CWD=$CWD
WD=$(cfg_get working_directory .dc_workspace); WD=${WD%/}; WD=${WD#./}
[ -n "$WD" ] || exit 0
mapfile -t ROOTS < <(find_worktrees "$CWD" | cut -f1)
[ ${#ROOTS[@]} -gt 0 ] || exit 0
PRIMARY=${ROOTS[0]}
LOG="$PRIMARY/$WD/.hook.log"

REASON=""
# check_path <path> [src-for-cp] : sets REASON and returns 1 when the path is a disallowed target under a workspace.
check_path() {
  local p=$1 root rel base comp
  [[ "$p" == *'$'* || "$p" == *'`'* || "$p" == '~'* || "$p" == /dev/* ]] && return 0
  [[ "$p" = /* ]] || p="$CWD/$p"
  command -v realpath >/dev/null 2>&1 && { p=$(realpath -m -- "$p") || return 0; }
  for root in "${ROOTS[@]}"; do
    [[ "$p" == "$root/$WD/"* ]] || continue
    rel=${p#"$root/$WD/"}
    [[ "$rel" == .validated/* || "$rel" == */.validated/* || "$rel" == .snapshots/*.tar.gz ]] && return 0
    base=${rel##*/}
    case "$base" in
      COMPLETION_REPORT.md|FINAL_REPORT.md|PROGRESS.md|VALIDATION.md)
        REASON="Reports are not files: no $base in $WD/; results go to chat and the PR body."; return 1 ;;
    esac
    if [[ "$base" == *_W[0-9]*.md ]]; then
      REASON="A follow-up wave gets a new date-prefixed directory; $base (_W{n} variant) is not created."; return 1
    fi
    local IFS=/
    for comp in $rel; do
      if [[ "$comp" == *__[0-9]* ]]; then
        unset IFS
        REASON="A follow-up wave gets a new date-prefixed directory; $comp (__{n} variant) is not created."; return 1
      fi
    done
    unset IFS
    case "$base" in
      *.md|*.json|*.log|*.tar.gz) return 0 ;;
    esac
    REASON="Only documents (.md/.json/.log) belong in $WD/; put data files elsewhere (53GB of jsonl ended up there once)."
    return 1
  done
  return 0
}

unq() { local s=$1; s=${s#[\"\']}; s=${s%[\"\']}; printf '%s' "$s"; }

deny=0
case "$TOOL" in
  Write|Edit|MultiEdit)
    F=$(json_get "$INPUT" tool_input.file_path)
    [ -n "$F" ] || exit 0
    check_path "$F" || deny=1
    ;;
  Bash)
    CMD=$(json_get "$INPUT" tool_input.command)
    [ -n "$CMD" ] || exit 0
    [[ "$CMD" == *"$WD"* ]] || exit 0
    targets=()
    rest=$CMD
    re_redir='>>?[[:space:]]*([^[:space:];&|<>()]+)'
    while [[ "$rest" =~ $re_redir ]]; do
      targets+=("$(unq "${BASH_REMATCH[1]}")")
      rest=${rest#*"${BASH_REMATCH[0]}"}
    done
    segs=${CMD//&&/$'\n'}; segs=${segs//||/$'\n'}; segs=${segs//;/$'\n'}; segs=${segs//|/$'\n'}
    re_tee='^[[:space:]]*tee[[:space:]]+(.*)$'
    re_cpmv='^[[:space:]]*(cp|mv)[[:space:]]+(.*)$'
    while IFS= read -r seg; do
      if [[ "$seg" =~ $re_tee ]]; then
        for t in ${BASH_REMATCH[1]}; do [[ "$t" == -* ]] || targets+=("$(unq "$t")"); done
      elif [[ "$seg" =~ $re_cpmv ]]; then
        args=()
        for t in ${BASH_REMATCH[2]}; do [[ "$t" == -* ]] || args+=("$(unq "$t")"); done
        if [ ${#args[@]} -ge 2 ]; then
          dest=${args[${#args[@]}-1]}
          if [[ "$dest" == */ || -d "$dest" ]]; then
            for ((i=0;i<${#args[@]}-1;i++)); do targets+=("${dest%/}/${args[i]##*/}"); done
          else
            targets+=("$dest")
          fi
        fi
      fi
    done <<<"$segs"
    for t in "${targets[@]}"; do
      check_path "$t" || { deny=1; break; }
    done
    ;;
  *) exit 0 ;;
esac

if [ "$deny" = 1 ]; then
  log_line "$LOG" "Workspace deny $TOOL: $REASON"
  deny_pretool "$REASON"
fi
exit 0
