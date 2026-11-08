#!/usr/bin/env bash
# PreToolUse(Write|Read|Agent|mcp__.*) hook: restatement gate for dotclaude:reviewer.
# A reviewer's first Write to {WD}/reviews/{target}/r{n}/STATUS.md binds its agent_id to that file;
# until its "## Restatement" has content, intent MCP tools (review.intent_tools), Agent calls (a subagent
# would read for it) and Reads of SPEC.md and PHASE_*_PLAN_*.md are denied (intent MCP also while
# unbound). Not blocked: Bash or Grep reads of SPEC and PLAN, and SPEC, PLAN and Agent calls while unbound.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

REVIEWER=dotclaude:reviewer
INPUT=$(cat)
# Runs on every Read of every session: skip JSON parsing unless the reviewer is involved.
[[ "$INPUT" == *"\"$REVIEWER\""* ]] || exit 0
[ "$(json_get "$INPUT" agent_type)" = "$REVIEWER" ] || exit 0
AID=$(json_get "$INPUT" agent_id); AID=${AID//[^A-Za-z0-9_-]/}
TOOL=$(json_get "$INPUT" tool_name)
FP=$(json_get "$INPUT" tool_input.file_path)
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
STORE="${TMPDIR:-/tmp}/dotclaude-review-$(id -u)"
DEFAULT_INTENT_TOOLS=('*jira*' '*atlassian*' '*notion*')

# nearest_dir <path> : print the nearest existing directory at or above path.
nearest_dir() {
  local d=$1
  while [ -n "$d" ] && [ ! -d "$d" ]; do d=${d%/*}; done
  printf '%s' "${d:-/}"
}
# log_to <dir> <text> : log to {primary}/{WD}/.hook.log of the repository holding dir.
log_to() {
  local primary wd
  primary=$(find_worktrees "$1" | head -1 | cut -f1)
  [ -n "$primary" ] || return 0
  wd=$(HOOK_CWD=$1 cfg_get working_directory .dc_workspace); wd=${wd%/}
  log_line "$primary/$wd/.hook.log" "$2"
}
# restatement_filled <STATUS.md> : true if "## Restatement" (optionally followed by whitespace and text,
# e.g. "## Restatement (diff only)") has a line that is neither blank nor an HTML comment.
restatement_filled() {
  awk '
    /^## / { in_r = ($0 ~ /^## Restatement([[:space:]].*)?$/); next }
    !in_r { next }
    {
      line = $0
      while (line != "") {
        if (in_c) { i = index(line, "-->"); if (!i) { line = ""; break } line = substr(line, i + 3); in_c = 0; continue }
        i = index(line, "<!--"); if (!i) break
        if (substr(line, 1, i - 1) ~ /[^[:space:]]/) break
        line = substr(line, i + 4); in_c = 1
      }
      if (line ~ /[^[:space:]]/) { found = 1; exit }
    }
    END { exit !found }' "$1"
}

# Binding: first Write to a round's STATUS.md wins and is never rebound.
if [ "$TOOL" = Write ] && [ "${FP##*/}" = STATUS.md ]; then
  rdir=${FP%/*}; tdir=${rdir%/*}; revdir=${tdir%/*}
  [[ "${rdir##*/}" =~ ^r[0-9]+$ ]] || exit 0
  base=$(nearest_dir "$rdir")
  WD=$(HOOK_CWD=$base cfg_get working_directory .dc_workspace); WD=${WD%/}
  [[ "$revdir" == */"$WD"/reviews ]] || exit 0
  [ -d "$STORE" ] || mkdir -m 700 "$STORE" || exit 0
  # The store sits in a shared temp directory: write only into a real directory this user owns.
  [ ! -L "$STORE" ] && [ -O "$STORE" ] || exit 0
  # noclobber makes the first binding win atomically, also when two Writes race.
  (set -C; printf '%s' "$FP" >"$STORE/$AID") || exit 0
  log_to "$base" "guard-review bind $AID $FP"
  exit 0
fi

kind=""
if [[ "$TOOL" == mcp__* ]]; then
  kind="mcp"
elif [ "$TOOL" = Agent ]; then
  kind="agent"
elif [ "$TOOL" = Read ] && { [ "${FP##*/}" = SPEC.md ] || [[ "${FP##*/}" == PHASE_*_PLAN_*.md ]]; }; then
  kind="read"
fi
[ -n "$kind" ] || exit 0

BOUND=""
# Same ownership test as the write side: a binding behind a planted store is not trusted.
if [ -n "$AID" ] && [ -f "$STORE/$AID" ]; then
  [ ! -L "$STORE" ] && [ -O "$STORE" ] || exit 0
  BOUND=$(cat "$STORE/$AID")
fi
CTX=$CWD; [ -n "$BOUND" ] && CTX=$(nearest_dir "${BOUND%/*}")

if [ "$kind" = mcp ]; then
  globs=$(HOOK_CWD=$CTX cfg_get_list review.intent_tools) || exit 0
  if [ -n "$globs" ]; then mapfile -t GLOBS <<<"${globs,,}"; else GLOBS=("${DEFAULT_INTENT_TOOLS[@]}"); fi
  match_any_glob "${TOOL,,}" "${GLOBS[@]}" || exit 0
fi

if [ -z "$BOUND" ]; then
  [ "$kind" = mcp ] || exit 0
  log_to "$CTX" "guard-review deny ${AID:--} $TOOL unbound"
  deny_pretool "Restatement first: create STATUS.md in the round directory given in your prompt ({WD}/reviews/{target}/r{n}/STATUS.md) with a Write, fill its ## Restatement section, then call $TOOL."
  exit 0
fi

[ -r "$BOUND" ] || exit 0
if restatement_filled "$BOUND"; then
  log_to "$CTX" "guard-review allow $AID $TOOL ${FP:-}"
  exit 0
fi
log_to "$CTX" "guard-review deny $AID $TOOL ${FP:-}"
deny_pretool "Restatement first: the ## Restatement section of $BOUND is empty. Write your restatement of the diff there before calling $TOOL${FP:+ on $FP}."
exit 0
