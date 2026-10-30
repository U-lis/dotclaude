#!/usr/bin/env bash
# PreToolUse(Bash) hook: deny code commits on work branches without a validator PASS marker.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

INPUT=$(cat)
CMD=$(json_get "$INPUT" tool_input.command)
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
re_commit='git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?commit([[:space:]]|$)'
[[ "$CMD" =~ $re_commit ]] || exit 0
export HOOK_CWD=$CWD

# Repo directory: -C path, else leading cd path, else cwd.
DIR=$CWD
re_C='git[[:space:]]+-C[[:space:]]+([^[:space:]]+)'
re_cd='^[[:space:]]*cd[[:space:]]+([^[:space:]&;]+)'
if [[ "$CMD" =~ $re_C ]]; then DIR=${BASH_REMATCH[1]}
elif [[ "$CMD" =~ $re_cd ]]; then DIR=${BASH_REMATCH[1]}; fi
DIR=${DIR//\"/}; DIR=${DIR//\'/}
[[ "$DIR" = /* ]] || DIR="$CWD/$DIR"
[ -d "$DIR" ] || exit 0

BR=$(git -C "$DIR" branch --show-current)
work_branch "$BR" || exit 0
WT=$(git -C "$DIR" rev-parse --show-toplevel) || exit 0
PRIMARY=$(find_worktrees "$DIR" | head -1 | cut -f1)
WD=$(cfg_get working_directory .dc_workspace); WD=${WD%/}
LOG="${PRIMARY:-$WT}/$WD/.hook.log"

# Files that will be committed.
STRIPPED=$(printf '%s' "$CMD" | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")
files=$(git -C "$DIR" diff --cached --name-only)
re_all='[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)'
if [[ "$STRIPPED" =~ $re_all ]]; then
  files="$files"$'\n'$(git -C "$DIR" diff --name-only)
fi
if [[ "$STRIPPED" == *" -- "* ]]; then
  after=${STRIPPED#* -- }; after=${after%%[;&|]*}
  for t in $after; do files="$files"$'\n'"$t"; done
fi

code=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  f=${f#./}
  under_ws "$f" "$WD" || code=$((code+1))
done <<<"$files"
if [ "$code" -eq 0 ]; then
  log_line "$LOG" "Commit allow docs-only on $BR"
  exit 0
fi

re_phase='[Pp][Hh][Aa][Ss][Ee][ _]([0-9]+(\.[0-9]+)?[A-Za-z]?)'
ID=""
[[ "$CMD" =~ $re_phase ]] && ID=${BASH_REMATCH[1]}

SPEC=$("$HERE/spec-meta.sh" find "$WT")
if [ -z "$SPEC" ]; then
  log_line "$LOG" "Commit allow no SPEC found on $BR"
  exit 0
fi
DOC_DIR=$(dirname "$SPEC")
if [ -n "$ID" ] && [ -e "$DOC_DIR/.validated/PHASE_$ID" ]; then
  log_line "$LOG" "Commit allow PHASE_$ID on $BR"
  exit 0
fi
reason="Code commit without validator PASS: no marker .validated/PHASE_${ID:-<id>} under $DOC_DIR. Run dotclaude:code-validator for the phase first; docs-only commits (files under $WD/) are allowed without it."
log_line "$LOG" "Commit deny phase=${ID:-none} on $BR"
deny_pretool "$reason"
exit 0
