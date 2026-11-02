#!/usr/bin/env bash
# Stop hook: block when the session's worktree, on a work branch, has uncommitted code (outside working_directory).
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

# Both checks cover only the worktree this session works in; others may belong to other sessions (#113).
wt=$(git -C "$CWD" rev-parse --show-toplevel)
br=$(git -C "$CWD" branch --show-current)

reason=""
check_own_worktree() {
  [ -n "$wt" ] || return
  work_branch "$br" || return
  [ "$br" = "$BASE" ] && return
  files=()
  while IFS= read -r line; do
    p=${line:3}; p=${p##* -> }; p=${p#\"}; p=${p%\"}
    under_ws "$p" "$WD" || files+=("$p")
  done < <(git -C "$wt" status --porcelain --untracked-files=all)
  if [ ${#files[@]} -gt 0 ]; then
    spec=$("$HERE/spec-meta.sh" find "$wt")
    if [ -z "$spec" ]; then
      log_line "$LOG" "Stop skip $wt on $br: no SPEC.md (not dotclaude work)"; return
    fi
    stage=$("$HERE/spec-meta.sh" stage "$spec")
    case "$stage" in
      code|local_test|test_deploy|remote_test) ;;
      *) log_line "$LOG" "Stop skip $wt on $br: stage '${stage:-none}' has no phase in flight"; return ;;
    esac
    e="${files[0]}"; [ ${#files[@]} -gt 1 ] && e="$e, ${files[1]}"
    reason="Uncommitted code in $wt on $br: ${#files[@]} file(s), e.g. $e. Run code-validator for the current phase and commit on PASS, or tell the user why the work stays uncommitted."
  fi
}
check_own_worktree

# workspace_size_ignore: JSON array of globs relative to {working_directory}; matches are left out of the size.
IGN=()
mapfile -t IGN < <(cfg_get_list workspace_size_ignore)

warn=""
if [ -n "$wt" ] && [ -d "$wt/$WD" ]; then
  kb=0; top=""; topkb=0
  while IFS=$'\t' read -r k p; do
    rel=${p#"$wt/$WD/"}
    ignored_entry "$rel" "${IGN[@]}" && continue
    kb=$((kb + k))
    [ "$k" -gt "$topkb" ] && { topkb=$k; top=$rel; }
  done < <(find "$wt/$WD" -mindepth 1 -maxdepth 1 -exec du -sk {} + 2>/dev/null)
  mb=$((kb / 1024))
  if [ "$mb" -gt 10 ]; then
    log_line "$LOG" "Stop warn $wt: workspace ${mb}MB (largest $top $((topkb / 1024))MB)"
    warn="workspace ${mb}MB in $wt (largest: $top $((topkb / 1024))MB); run /dotclaude:purge, move data files out, or add the directory to workspace_size_ignore"
  fi
fi

if [ -n "$reason" ]; then
  log_line "$LOG" "Stop block $reason"
  block_stop "$reason"
else
  log_line "$LOG" "Stop pass no uncommitted code on work branches"
  [ -z "$warn" ] || stop_context "$warn"
fi
exit 0
