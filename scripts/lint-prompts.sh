#!/usr/bin/env bash
# Read-only lint for prompt files. Exit 1 on any failure.
# Usage: scripts/lint-prompts.sh [--fix-none]   (--fix-none is a no-op; the script never modifies files)
set -u
for a in "$@"; do
  case "$a" in
    --fix-none) ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

MAX_EMPHASIS=4
MAX_BYTES=220000
EMPH_RE='\b(MUST|NEVER|MANDATORY|CRITICAL|FORBIDDEN|ALWAYS|IMPORTANT|UNCONDITIONAL)\b'

shopt -s nullglob
FILES=(commands/*.md agents/*.md agents/coders/*.md templates/*.md)
fails=0
fail() { echo "$1:$2: $3"; fails=$((fails+1)); }

# grep_fail <ERE> <message> [exclude-file ...]
grep_fail() {
  local re="$1" msg="$2"; shift 2
  local f line ex skip
  for f in "${FILES[@]}"; do
    skip=0; for ex in "$@"; do [ "$f" = "$ex" ] && skip=1; done
    [ $skip = 1 ] && continue
    while IFS=: read -r line _; do
      [ -n "$line" ] && fail "$f" "$line" "$msg"
    done < <(grep -nE -- "$re" "$f")
  done
}

# a. ## Language section only in _contract.md
grep_fail '^##[[:space:]]+Language\b' '"## Language" section is only allowed in commands/_contract.md' commands/_contract.md
# b. claude_works
grep_fail 'claude_works' 'literal "claude_works" is not allowed'
# c. dated model id
grep_fail '^[[:space:]]*model:[[:space:]]*claude-' 'dated model id in frontmatter; use opus, sonnet, haiku or inherit'
for f in agents/*.md agents/coders/*.md; do
  while IFS=: read -r line val; do
    v="$(echo "$val" | sed -E 's/^[[:space:]]*model:[[:space:]]*//; s/[[:space:]]+$//; s/^["'\'']//; s/["'\'']$//')"
    case "$v" in opus|sonnet|haiku|inherit|claude-*) ;; *) fail "$f" "$line" "model '$v' not in opus|sonnet|haiku|inherit" ;; esac
  done < <(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} /^[[:space:]]*model:/{print NR":"$0}' "$f")
done
# e. Task tool
grep_fail 'Task tool|Task\(' 'use "Agent" tool name instead of "Task tool"/"Task("'
# f. PHASE_*_PLAN.md
grep_fail 'PHASE_[^[:space:]`_]*\*_PLAN\.md|PHASE_\{?[A-Za-z0-9.]*\}?_PLAN\.md' 'glob PHASE_*_PLAN.md is wrong; use PHASE_{k}_PLAN_{keyword}.md'
# g. {SUBJECT}.md
grep_fail '\{SUBJECT\}\.md' '{SUBJECT}.md is obsolete (single-document mode removed)'

# d. emphasis counts
declare -A EC
for f in "${FILES[@]}"; do
  n=$(grep -oE -- "$EMPH_RE" "$f" | wc -l)
  EC[$f]=$n
  [ "$n" -gt "$MAX_EMPHASIS" ] && fail "$f" 1 "$n ALL-CAPS emphasis tokens (max $MAX_EMPHASIS)"
done

# h. total bytes
total=$(cat "${FILES[@]}" | wc -c)
[ "$total" -gt "$MAX_BYTES" ] && fail "(scope)" 0 "total size $total bytes exceeds $MAX_BYTES"

# i. CLAUDE_PLUGIN_ROOT paths
for f in "${FILES[@]}"; do
  while IFS=: read -r line rest; do
    while read -r p; do
      [ -z "$p" ] && continue
      rel="${p#\$\{CLAUDE_PLUGIN_ROOT\}/}"
      rel="${rel%%[\`\"\')>,;:]*}"
      rel="${rel%.}"
      [ -e "$ROOT/$rel" ] || fail "$f" "$line" "path \${CLAUDE_PLUGIN_ROOT}/$rel does not exist"
    done < <(echo "$rest" | grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./{}*-]+')
  done < <(grep -nF '${CLAUDE_PLUGIN_ROOT}/' "$f")
done

# j. duplicate definitions
dupe() { # <fixed-string> <allowed files...>
  local s="$1"; shift
  local f line ok a
  for f in "${FILES[@]}"; do
    ok=0; for a in "$@"; do [ "$f" = "$a" ] && ok=1; done
    [ $ok = 1 ] && continue
    while IFS=: read -r line _; do
      [ -n "$line" ] && fail "$f" "$line" "duplicate definition of '$s' (allowed only in: $*)"
    done < <(grep -nF -- "$s" "$f")
  done
}
dupe 'git worktree add ../{project_name}-{type}-{keyword} -b' commands/_contract.md commands/_init-common.md
for s in 'max 3' 'maximum 3' '3 attempts' '3 iterations'; do
  dupe "$s" commands/_contract.md agents/code-validator.md
done

# report
echo
echo "ALL-CAPS emphasis tokens per file (max $MAX_EMPHASIS)"
printf '%-36s %s\n' FILE COUNT
for f in "${FILES[@]}"; do printf '%-36s %s\n' "$f" "${EC[$f]}"; done
echo
echo "Total bytes in scope: $total (ceiling $MAX_BYTES)"
if [ "$fails" -gt 0 ]; then echo "FAILED: $fails problem(s)"; exit 1; fi
echo "OK"
