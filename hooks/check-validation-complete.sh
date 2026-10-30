#!/usr/bin/env bash
# Stop hook: block when a work-branch worktree has uncommitted code (outside working_directory).
# Fail open on any error.
exec 2>/dev/null
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 0
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 0

INPUT=$(cat)
[ "$(json_get "$INPUT" stop_hook_active)" = true ] && exit 0
CWD=$(json_get "$INPUT" cwd); CWD=${CWD:-$PWD}
git -C "$CWD" rev-parse --git-dir >/dev/null || exit 0
export HOOK_CWD=$CWD

WD=$(cfg_get working_directory .dc_workspace); WD=${WD%/}
BASE=$(cfg_get base_branch main)
PRIMARY=$(find_worktrees "$CWD" | head -1 | cut -f1)
[ -n "$PRIMARY" ] || exit 0
LOG="$PRIMARY/$WD/.hook.log"

reason=""
while IFS=$'\t' read -r wt br; do
  [ -n "$wt" ] || continue
  work_branch "$br" || continue
  [ "$br" = "$BASE" ] && continue
  files=()
  while IFS= read -r line; do
    p=${line:3}; p=${p##* -> }; p=${p#\"}; p=${p%\"}
    under_ws "$p" "$WD" || files+=("$p")
  done < <(git -C "$wt" status --porcelain --untracked-files=all)
  if [ ${#files[@]} -gt 0 ]; then
    spec=$("$HERE/spec-meta.sh" find "$wt")
    if [ -z "$spec" ]; then
      log_line "$LOG" "Stop skip $wt on $br: no SPEC.md (not dotclaude work)"; continue
    fi
    stage=$("$HERE/spec-meta.sh" stage "$spec")
    case "$stage" in
      code|local_test|test_deploy|remote_test) ;;
      *) log_line "$LOG" "Stop skip $wt on $br: stage '${stage:-none}' has no phase in flight"; continue ;;
    esac
    e="${files[0]}"; [ ${#files[@]} -gt 1 ] && e="$e, ${files[1]}"
    reason="Uncommitted code in $wt on $br: ${#files[@]} file(s), e.g. $e. Run code-validator for the current phase and commit on PASS, or tell the user why the work stays uncommitted."
    break
  fi
done < <(find_worktrees "$CWD")

if [ -n "$reason" ]; then
  log_line "$LOG" "Stop block $reason"
  block_stop "$reason"
else
  log_line "$LOG" "Stop pass no uncommitted code on work branches"
fi
exit 0
