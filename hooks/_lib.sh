#!/usr/bin/env bash
# Shared helpers for dotclaude hooks. Source this file; do not execute it.
# All helpers are fail-open: on any problem they print nothing / return non-zero.

# json_get <json> <dotted.path> : print a scalar as is and a list or dict as compact JSON; empty if missing/null.
json_get() {
  local json=$1 path=$2
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r --arg p "$path" \
      'getpath($p|split("."))|if .==null then empty else tostring end' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$json" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        d = d[k]
    if isinstance(d, (list, dict)):
        print(json.dumps(d, separators=(",", ":"), ensure_ascii=False))
    elif d is not None:
        print(str(d).lower() if isinstance(d, bool) else d)
except Exception:
    pass' "$path" 2>/dev/null
  fi
  return 0
}

# json_out <jq-filter-args...> helpers: build compact JSON for decisions.
_json_obj() { # _json_obj <kind> <reason>
  local kind=$1 reason=$2
  if command -v jq >/dev/null 2>&1; then
    if [ "$kind" = stop ]; then
      jq -nc --arg r "$reason" '{decision:"block",reason:$r}'
    elif [ "$kind" = context ]; then
      jq -nc --arg r "$reason" '{hookSpecificOutput:{hookEventName:"Stop",additionalContext:$r}}'
    else
      jq -nc --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    fi
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import sys, json
k, r = sys.argv[1], sys.argv[2]
if k == "stop":
    o = {"decision": "block", "reason": r}
elif k == "context":
    o = {"hookSpecificOutput": {"hookEventName": "Stop", "additionalContext": r}}
else:
    o = {"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": r}}
print(json.dumps(o, separators=(",", ":")))' "$kind" "$reason"
  fi
}
block_stop() { _json_obj stop "$1"; }
stop_context() { _json_obj context "$1"; }
deny_pretool() { _json_obj pre "$1"; }

# find_worktrees <repo> : print "path<TAB>branch" per worktree (branch empty if detached). First line = primary.
find_worktrees() {
  git -C "$1" worktree list --porcelain 2>/dev/null | awk '
    /^worktree /{ if (p!="") print p "\t" b; p=substr($0,10); b="" }
    /^branch /{ b=substr($0,8); sub("^refs/heads/","",b) }
    END{ if (p!="") print p "\t" b }'
  return 0
}

# work_branch <branch> : true if feature|bugfix|refactor/...
work_branch() { [[ "$1" =~ ^(feature|bugfix|refactor)/ ]]; }

# cfg_get <key> <default> : <key> may be a dotted path (stages.stop_after). Needs jq or python3.
#   Order: ~/.claude config, $CLAUDE_CONFIG_DIR config, primary-repo config, cwd-repo config (later wins).
# Uses $HOOK_CWD (defaults to $PWD) to locate repositories.
cfg_get() {
  local key=$1 def=$2 val="" v f cwd=${HOOK_CWD:-$PWD} primary top files=()
  command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || { printf '%s' "$def"; return 0; }
  files+=("$HOME/.claude/dotclaude-config.json")
  [ -n "${CLAUDE_CONFIG_DIR:-}" ] && [ "$CLAUDE_CONFIG_DIR" != "$HOME/.claude" ] && files+=("$CLAUDE_CONFIG_DIR/dotclaude-config.json")
  primary=$(find_worktrees "$cwd" | head -1 | cut -f1)
  [ -n "$primary" ] && files+=("$primary/.claude/dotclaude-config.json")
  top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  [ -n "$top" ] && [ "$top" != "$primary" ] && files+=("$top/.claude/dotclaude-config.json")
  for f in "${files[@]}"; do
    [ -f "$f" ] || continue
    if command -v jq >/dev/null 2>&1; then
      v=$(jq -r --arg k "$key" 'getpath($k|split("."))|if .==null then empty else tostring end' "$f" 2>/dev/null)
    else
      v=$(json_get "$(cat "$f")" "$key")
    fi
    [ -n "$v" ] && val=$v
  done
  printf '%s' "${val:-$def}"
  return 0
}

# cfg_get_list <key> : print a config array of strings, one per line. Unset prints nothing and returns 0;
#   a value that is not such an array, or no jq or python3 to read it, returns non-zero.
cfg_get_list() {
  local raw
  command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || return 1
  raw=$(cfg_get "$1" "")
  [ -n "$raw" ] || return 0
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$raw" | jq -r 'if type=="array" and all(.[]; type=="string") then .[] else error("not a list of strings") end' 2>/dev/null
  else
    printf '%s' "$raw" | python3 -c '
import sys, json
d = json.load(sys.stdin)
if not (isinstance(d, list) and all(isinstance(x, str) for x in d)):
    sys.exit(1)
for x in d:
    print(x)' 2>/dev/null
  fi
}

# match_any_glob <name> <glob>... : true if name matches a glob; a trailing slash on a glob is dropped.
match_any_glob() {
  local name=$1 g; shift
  # shellcheck disable=SC2053 # $g is an intentional glob
  for g; do g=${g%/}; [[ "$name" == $g ]] && return 0; done
  return 1
}

# ignored_entry <top-level entry> <glob>... : true if the name matches, or YYYY_MM_DD-{name} with {name} matching,
#   because preserve renames an undated doc dir and it stays the same work.
ignored_entry() {
  local name=$1; shift
  match_any_glob "$name" "$@" && return 0
  [[ "$name" =~ ^[0-9]{4}_[0-9]{2}_[0-9]{2}-(.+)$ ]] && match_any_glob "${BASH_REMATCH[1]}" "$@"
}

# log_line <file> <text> : append "ISO-time text"; silently skip on failure.
log_line() {
  mkdir -p "$(dirname "$1")" 2>/dev/null || return 0
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$2" >>"$1" 2>/dev/null || true
  return 0
}

# under_ws <path> <wd> : true if path is inside the working directory.
under_ws() { [[ "$1" == "$2"/* || "$1" == "$2" ]]; }
