#!/usr/bin/env bash
# Shared fixture for hook tests. Source it; sets T, HOME, R (primary), W (worktree), DOC.
# shellcheck disable=SC2034,SC2015
HOOKS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../hooks" && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export HOME="$T/home"; mkdir -p "$HOME"
fails=0
ok() { echo "PASS: $1"; }
ko() { echo "FAIL: $1 ($2)"; fails=$((fails+1)); }
contains() { case "$2" in *"$3"*) ok "$1";; *) ko "$1" "no [$3] in [$2]";; esac; }
empty() { [ -z "$2" ] && ok "$1" || ko "$1" "unexpected output [$2]"; }
finish() { [ "$fails" = 0 ] && exit 0 || { echo "$fails failure(s)"; exit 1; }; }
# tool_path <absent>... : print a dir for PATH that links the tools the hooks use, minus the named ones.
tool_path() {
  local d t; d=$(mktemp -d -p "$T" path.XXXX)
  for t in bash env git awk sed grep find stat du cut head tail date dirname basename mkdir mv rm cp cmp gzip sha256sum realpath rmdir chmod cat ls touch tr wc sort jq python3 fuser lsof; do
    case " $* " in *" $t "*) continue;; esac
    command -v "$t" >/dev/null && ln -s "$(command -v "$t")" "$d/$t"
  done
  printf '%s' "$d"
}

mk_fixture() {
  R="$T/x"; W="$T/x-feature-kw"
  mkdir -p "$R/.claude"
  git -C "$R" init -q -b main
  git -C "$R" config user.email t@t; git -C "$R" config user.name t
  echo base >"$R/README"; git -C "$R" add README; git -C "$R" commit -q -m init
  printf '{ "working_directory": ".dc_workspace" }\n' >"$R/.claude/dotclaude-config.json"
  git -C "$R" worktree add -q -b feature/kw "$W"
  DOC="$W/.dc_workspace/2026_01_01-kw"; mkdir -p "$DOC"
  cat >"$DOC/SPEC.md" <<'S'
<!-- dotclaude-config
working_directory: .dc_workspace
stage: code
approved_at: null
approved_hash: null
decisions: []
handoff: ""
-->
# Title

body line
S
  echo "- [ ] item" >"$DOC/PHASE_1_PLAN_kw.md"
}
