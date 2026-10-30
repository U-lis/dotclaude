#!/usr/bin/env bash
# spec-meta.sh - read/write the dotclaude-config metadata block in SPEC.md
set -u

STAGES="init spec_review design code local_test test_deploy remote_test pr done"

usage() {
  cat <<'USAGE'
Usage: spec-meta.sh <command> [args]

Commands:
  find [root_dir]                 Print path of the SPEC.md for the current work
  get <spec> <key>                Print metadata value (exit 1 if absent)
  set <spec> <key> <value>        Set/add metadata key (creates block if missing)
  body-hash <spec>                sha256 of the content after the closing '-->'
  approve <spec>                  Record approved_at/approved_hash, stage=design
  check-approved <spec>           Exit 0 if approved_hash matches the body, else 1
  stage <spec> [new_stage]        Get or set stage
                                  (init spec_review design code local_test
                                   test_deploy remote_test pr done)
  handoff <spec> [text]           Get (decoded) or set the handoff string
  decision <spec> add <token>     Add token to decisions array (deduped)
  decision <spec> list            List decision tokens, one per line
  --help                          Show this help

Exit codes: 0 ok, 1 negative check / not found, 2 usage or file error.
USAGE
}

die() { echo "spec-meta: $*" >&2; exit 2; }

need_file() { [ -f "${1:-}" ] || die "file not found: ${1:-<none>}"; }
need_key() { case "${1:-}" in ''|*[!A-Za-z0-9_]*) die "invalid key: ${1:-}";; esac; }

# Print the line number of the closing '-->' of the metadata block, or nothing.
block_end() {
  awk '
    NR==1 { if ($0 !~ /^<!-- dotclaude-config[ \t\r]*$/) exit; next }
    { l=$0; sub(/^[ \t]+/,"",l); sub(/[ \t\r]+$/,"",l); if (l=="-->") { print NR; exit } }
  ' "$1"
}

# Trimmed value of key; return 1 if absent.
meta_get() {
  local f=$1 k=$2 n
  n=$(block_end "$f")
  [ -n "$n" ] || return 1
  SM_KEY=$k awk -v n="$n" '
    BEGIN { k=ENVIRON["SM_KEY"] }
    NR>1 && NR<n && index($0, k ":")==1 {
      v=substr($0, length(k)+2); sub(/^[ \t]+/,"",v); sub(/[ \t\r]+$/,"",v)
      print v; found=1; exit
    }
    END { exit found ? 0 : 1 }
  ' "$f"
}

meta_set() {
  local f=$1 k=$2 v=$3 n tmp
  tmp=$(mktemp) || die "mktemp failed"
  n=$(block_end "$f")
  if [ -z "$n" ]; then
    if [ "$(head -n1 "$f" 2>/dev/null)" = "<!-- dotclaude-config" ]; then
      rm -f "$tmp"; die "unterminated dotclaude-config block in $f"
    fi
    { printf '<!-- dotclaude-config\n%s: %s\n-->\n' "$k" "$v"; cat "$f"; } >"$tmp"
  else
    {
      SM_KEY=$k SM_VAL=$v awk -v n="$n" '
        BEGIN { k=ENVIRON["SM_KEY"]; v=ENVIRON["SM_VAL"]; done=0 }
        NR==1 { print; next }
        NR==n { if (!done) print k ": " v; print; exit }
        index($0, k ":")==1 { if (!done) { print k ": " v; done=1 }; next }
        { print }
      ' "$f"
      tail -n +"$((n+1))" "$f"
    } >"$tmp"
  fi
  cat "$tmp" >"$f"
  rm -f "$tmp"
}

body_hash() {
  local f=$1 n
  n=$(block_end "$f")
  if [ -z "$n" ]; then
    sha256sum <"$f" | cut -d' ' -f1
  else
    tail -n +"$((n+1))" "$f" | sha256sum | cut -d' ' -f1
  fi
}

cmd_find() {
  local root=${1:-.} wd="" cfg line branch kw d
  for cfg in "$root/.claude/dotclaude-config.json" "$HOME/.claude/dotclaude-config.json"; do
    if [ -f "$cfg" ]; then
      line=$(grep '"working_directory"' "$cfg" | head -n1 | sed -n 's/.*"working_directory"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
      if [ -n "$line" ]; then wd=$line; break; fi
    fi
  done
  wd=${wd:-.dc_workspace}
  local specs=() 
  for d in "$root/$wd"/*/SPEC.md; do
    [ -f "$d" ] && specs+=("$d")
  done
  [ "${#specs[@]}" -gt 0 ] || { echo "no SPEC.md found under $root/$wd" >&2; exit 1; }
  if [ "${#specs[@]}" -eq 1 ]; then echo "${specs[0]}"; exit 0; fi
  branch=$(git -C "$root" branch --show-current 2>/dev/null || true)
  kw=${branch#*/}
  if [ -n "$kw" ]; then
    for d in "${specs[@]}"; do
      case "$(basename "$(dirname "$d")")" in
        *-"$kw") echo "$d"; exit 0;;
      esac
    done
  fi
  # shellcheck disable=SC2012
  ls -t -- "${specs[@]}" | head -n1
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case "$cmd" in
  ''|-h|--help|help) usage; [ -n "$cmd" ] && exit 0; exit 2;;
  find) cmd_find "$@";;
  get)
    [ $# -eq 2 ] || die "usage: get <spec> <key>"
    need_file "$1"; need_key "$2"
    meta_get "$1" "$2" || exit 1;;
  set)
    [ $# -eq 3 ] || die "usage: set <spec> <key> <value>"
    need_file "$1"; need_key "$2"
    meta_set "$1" "$2" "$3";;
  body-hash)
    [ $# -eq 1 ] || die "usage: body-hash <spec>"
    need_file "$1"; body_hash "$1";;
  approve)
    [ $# -eq 1 ] || die "usage: approve <spec>"
    need_file "$1"
    at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    h=$(body_hash "$1")
    meta_set "$1" approved_at "$at"
    meta_set "$1" approved_hash "$h"
    meta_set "$1" stage design
    echo "approved_at: $at"; echo "approved_hash: $h"; echo "stage: design";;
  check-approved)
    [ $# -eq 1 ] || die "usage: check-approved <spec>"
    need_file "$1"
    ah=$(meta_get "$1" approved_hash || true)
    at=$(meta_get "$1" approved_at || true)
    case "$ah" in ''|null) echo "not approved"; exit 1;; esac
    if [ "$ah" = "$(body_hash "$1")" ]; then echo "approved $at"; exit 0; fi
    echo "spec changed since approval ($at)"; exit 1;;
  stage)
    [ $# -ge 1 ] && [ $# -le 2 ] || die "usage: stage <spec> [new_stage]"
    need_file "$1"
    if [ $# -eq 1 ]; then meta_get "$1" stage || exit 1; exit 0; fi
    ok=0; for s in $STAGES; do [ "$s" = "$2" ] && ok=1; done
    [ "$ok" -eq 1 ] || die "invalid stage '$2'. allowed: $STAGES"
    old=$(meta_get "$1" stage || true)
    meta_set "$1" stage "$2"
    echo "stage: ${old:-none} -> $2";;
  handoff)
    [ $# -ge 1 ] && [ $# -le 2 ] || die "usage: handoff <spec> [text]"
    need_file "$1"
    if [ $# -eq 1 ]; then
      raw=$(meta_get "$1" handoff) || exit 1
      raw=${raw#\"}; raw=${raw%\"}
      printf '%s\n' "$raw" | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g'
      exit 0
    fi
    esc=$(printf '%s' "$2" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
    meta_set "$1" handoff "\"$esc\"";;
  decision)
    [ $# -ge 2 ] || die "usage: decision <spec> add <token> | list"
    need_file "$1"; f=$1; sub=$2
    cur=$(meta_get "$f" decisions || true)
    toks=$(printf '%s' "$cur" | tr -d '[]" \t' | tr ',' '\n' | grep -v '^$' || true)
    case "$sub" in
      list) [ -z "$toks" ] || printf '%s\n' "$toks";;
      add)
        [ $# -eq 3 ] || die "usage: decision <spec> add <token>"
        case "$3" in ''|*[!A-Za-z0-9_-]*) die "invalid token: $3";; esac
        if printf '%s\n' "$toks" | grep -qx -- "$3"; then exit 0; fi
        all=$(printf '%s\n%s\n' "$toks" "$3" | grep -v '^$')
        arr=$(printf '%s\n' "$all" | sed 's/.*/"&"/' | paste -sd, - | sed 's/,/, /g')
        meta_set "$f" decisions "[$arr]";;
      *) die "usage: decision <spec> add <token> | list";;
    esac;;
  *) usage >&2; exit 2;;
esac
