#!/usr/bin/env bash
# Move bulky non-document files out of {working_directory} and report or drop .venv/venv directories.
#
#   workspace-archive.sh files plan|apply <path> [--removing <worktree>]... [--exclude <glob>]... [--date YYYY_MM_DD]
#   workspace-archive.sh preserve plan|apply <worktree> [--date YYYY_MM_DD]
#   workspace-archive.sh deps  plan|apply <repo> [--removing <worktree>]... [--current <worktree>]
#
# --date is the prefix for undated doc dirs and the ledger date; default today, computed once per run.
# Nested .git, .venv, venv and node_modules directories are never entered, so they are not archived.
#
# files: <path> is the primary checkout or a worktree. Destination is
#   {workspace_archive_dir}/{primary checkout name}/{doc_dir}/{relative path}[.gz]
#   and every archived file gets a row in {primary}/{working_directory}/{doc_dir}/ARCHIVED.md.
#   Originals go only after the copy is verified, then the directories that emptied, up to the doc
#   dir. Tracked files, *.md, code and config, files of 100KB or less, files changed in the last
#   24h, open files, __pycache__ contents and doc dirs matching workspace_size_ignore (YYYY_MM_DD-{name}
#   also when {name} matches) stay. For the
#   primary checkout, doc dirs also present in a staying worktree stay. --removing names worktrees
#   that will be removed. --exclude globs match {doc_dir}/{relative path} under the doc dir's name
#   here or under the name it takes in the primary; use them for work records the plan picked up.
#   apply refuses when workspace_size_ignore cannot be read or neither fuser nor lsof exists;
#   plan warns on stderr instead.
# preserve: copy documents of a worktree that will be removed into the primary, never overwriting.
#   An undated doc dir the primary does not have gets a date prefix ({date}-{name}), so the record
#   shows when the work was handled. `files` run on a worktree uses the same name for the archive
#   and ARCHIVED.md. A differing destination is a conflict unless the source is tracked and clean,
#   which git holds. The top-level .hook.log and __pycache__ contents are skipped. A copy reaches
#   its destination whole or not at all, so a re-run sees no false conflict.
# deps: non-symlink .venv/venv at the root of staying worktrees. The session's worktree (from $PWD)
#   and --current are skipped; a subdirectory stands for its worktree.
#
# files and preserve on a path that does not exist print "skip-missing\t-\t<path>", warn on stderr
#   and exit 0.
# files and deps plan print "<action>\t<size bytes>\t<path>" and change nothing.
# preserve prints "copy|conflict\t<path in worktree>\t<path in primary>", relative to
#   {working_directory}, and "skip-dep\t<dir in worktree>\t-" per directory it did not enter, which
#   does not affect the exit status; its plan changes nothing and exits as apply would.
# Exit: 0 ok, 1 some items failed or conflict (originals kept), 2 usage or refused,
#   3 workspace_archive_dir unset or not absolute on apply with a file to archive.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 2
# shellcheck source=_lib.sh
. "$HERE/_lib.sh" || exit 2

usage() {
  {
    echo "usage: workspace-archive.sh files plan|apply <path> [--removing <wt>]... [--exclude <glob>]... [--date YYYY_MM_DD]"
    echo "       workspace-archive.sh preserve plan|apply <worktree> [--date YYYY_MM_DD]"
    echo "       workspace-archive.sh deps plan|apply <repo> [--removing <wt>]... [--current <wt>]"
  } >&2
  exit 2
}
[ $# -ge 3 ] || usage
KIND=$1; MODE=$2; ROOT=$3; shift 3
case "$KIND" in files|preserve|deps) ;; *) usage ;; esac
case "$MODE" in plan|apply) ;; *) usage ;; esac
REMOVING=(); CURRENT=""; SESSION=""; EXCL=(); DATE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --removing) [ $# -ge 2 ] || usage; REMOVING+=("$(realpath -m -- "$2")"); shift 2 ;;
    --current) [ $# -ge 2 ] || usage; CURRENT=$2; shift 2 ;;
    --exclude) [ $# -ge 2 ] || usage; EXCL+=("$2"); shift 2 ;;
    --date)
      [ $# -ge 2 ] || usage
      [[ "$2" =~ ^[0-9]{4}_[0-9]{2}_[0-9]{2}$ ]] || usage
      DATE=$2; shift 2 ;;
    *) usage ;;
  esac
done
DATE=${DATE:-$(date +%Y_%m_%d)}
# A worktree whose directory is gone has nothing to archive, which is not a failure.
if [ ! -e "$ROOT" ] && [ "$KIND" != deps ]; then
  printf 'skip-missing\t-\t%s\n' "$ROOT"
  echo "warning: $ROOT does not exist; nothing to archive" >&2
  exit 0
fi
GIVEN=$ROOT
ROOT=$(git -C "$GIVEN" rev-parse --show-toplevel 2>/dev/null) || { echo "not a git checkout: $GIVEN" >&2; exit 2; }
export HOOK_CWD=$ROOT
PRIMARY=$(find_worktrees "$ROOT" | head -1 | cut -f1)
[ -n "$PRIMARY" ] || exit 2
# Without a JSON reader every config value falls back to its default, which is the wrong directory.
command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || { echo "workspace-archive.sh needs jq or python3 to read the config" >&2; exit 2; }
WD=$(cfg_get working_directory .dc_workspace); WD=${WD%/}; WD=${WD#./}
case "$(realpath -ms -- "$ROOT/$WD")" in
  "$ROOT"/*) ;;
  *) echo "working_directory must be a directory inside the repository, not '$WD'" >&2; exit 2 ;;
esac
fails=0

removing() { local r; for r in "${REMOVING[@]}"; do [ "$r" = "$1" ] && return 0; done; return 1; }

# staying worktrees other than the primary
staying() {
  local wt
  while IFS=$'\t' read -r wt _; do
    [ -n "$wt" ] && [ "$wt" != "$PRIMARY" ] || continue
    removing "$wt" || printf '%s\n' "$wt"
  done < <(find_worktrees "$ROOT")
  return 0
}

DEP_DIRS=(-name .git -o -name .venv -o -name venv -o -name node_modules)

# walk <dir> <find tests...> : print matching paths, NUL separated, outside repositories and dependency trees.
walk() {
  local dir=$1; shift
  find "$dir" -mindepth 1 \
    -type d \( "${DEP_DIRS[@]}" \) -prune -o \
    \( "$@" \) -print0
}

# tracked_clean <path below the checkout> : true when git holds the file exactly as it is on disk.
tracked_clean() {
  git --literal-pathspecs -C "$ROOT" ls-files --error-unmatch -- "$1" >/dev/null 2>&1 &&
    git --literal-pathspecs -C "$ROOT" diff --quiet HEAD -- "$1" 2>/dev/null
}

# dated_name <doc_dir> : name a worktree's doc dir takes in the primary; hidden directories and names the primary has keep theirs.
dated_name() {
  [ ! -e "$PRIMARY/$WD/$1" ] || { printf '%s' "$1"; return; }
  if [[ "$1" =~ ^[0-9]{4}[_-][0-9]{2}[_-][0-9]{2} || "$1" == .* ]]; then printf '%s' "$1"
  else printf '%s-%s' "$DATE" "$1"; fi
}

# same_file <a> <b> : same content, or for symlinks the same target.
same_file() {
  if [ -L "$1" ] || [ -L "$2" ]; then
    [ -L "$1" ] && [ -L "$2" ] && [ "$(readlink -- "$1")" = "$(readlink -- "$2")" ]
  else
    cmp -s -- "$1" "$2"
  fi
}

if [ "$KIND" = preserve ]; then
  [ "$ROOT" != "$PRIMARY" ] || { echo "preserve needs a worktree, not the primary" >&2; exit 2; }
  [ -d "$ROOT/$WD" ] || exit 0
  while IFS= read -r -d '' d; do
    printf 'skip-dep\t%s\t-\n' "${d#"$ROOT/$WD/"}"
  done < <(find "$ROOT/$WD" -mindepth 1 -type d \( "${DEP_DIRS[@]}" \) -prune -print0)
  while IFS= read -r -d '' f; do
    rel=${f#"$ROOT/$WD/"}
    [ "$rel" != .hook.log ] || continue
    case "/$rel/" in */__pycache__/*) continue ;; esac
    if [ "$rel" = "${rel#*/}" ]; then to=$rel
    else to="$(dated_name "${rel%%/*}")/${rel#*/}"; fi
    dest="$PRIMARY/$WD/$to"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      same_file "$f" "$dest" && continue
      tracked_clean "$WD/$rel" && continue
      printf 'conflict\t%s\t%s\n' "$rel" "$to"
      fails=$((fails + 1))
      continue
    fi
    printf 'copy\t%s\t%s\n' "$rel" "$to"
    [ "$MODE" = apply ] || continue
    tmp="$dest.tmp.$$"
    { mkdir -p "$(dirname "$dest")" && cp -Pp -- "$f" "$tmp" && mv -- "$tmp" "$dest"; } || { rm -f -- "$tmp"; echo "FAIL $f" >&2; fails=$((fails + 1)); }
  done < <(walk "$ROOT/$WD" -type f -o -type l)
  [ "$fails" = 0 ] && exit 0 || exit 1
fi

if [ "$KIND" = deps ]; then
  share=$(cfg_get worktree.share_from_base true)
  # A subdirectory stands for its worktree; a path git no longer knows is compared as given.
  SESSION=$(git rev-parse --show-toplevel 2>/dev/null)
  [ -z "$CURRENT" ] || CURRENT=$(git -C "$CURRENT" rev-parse --show-toplevel 2>/dev/null || realpath -m -- "$CURRENT")
  while IFS= read -r wt; do
    [ "$wt" != "$CURRENT" ] && [ "$wt" != "$SESSION" ] || continue
    for name in .venv venv; do
      d="$wt/$name"
      [ -d "$d" ] && [ ! -L "$d" ] || continue
      if [ "$MODE" = plan ]; then
        printf 'delete-venv\t%s\t%s\n' "$(du -sb "$d" | cut -f1)" "$d"
        continue
      fi
      if ! rm -rf -- "$d"; then echo "FAIL $d" >&2; fails=$((fails + 1)); continue; fi
      if [ "$share" = true ] && [ -e "$PRIMARY/$name" ]; then
        ln -s "$(realpath -m --relative-to="$wt" "$PRIMARY/$name")" "$d" || fails=$((fails + 1))
      fi
    done
  done < <(staying)
  [ "$fails" = 0 ] && exit 0 || exit 1
fi

MIN_BYTES=$((100 * 1024))
MIN_AGE_SECS=$((24 * 60 * 60))

# refuse_or_warn <message> : a precondition for apply; plan only warns, since it changes nothing.
refuse_or_warn() {
  if [ "$MODE" = apply ]; then echo "refusing to archive: $1" >&2; exit 2; fi
  echo "warning: $1" >&2
}

IGN=()
if ign_list=$(cfg_get_list workspace_size_ignore); then
  mapfile -t IGN < <(printf '%s' "$ign_list")
else
  refuse_or_warn "workspace_size_ignore is set but is not a JSON array of strings"
fi

OPEN_TOOL=""
for t in fuser lsof; do
  if command -v "$t" >/dev/null 2>&1; then OPEN_TOOL=$t; break; fi
done
[ -n "$OPEN_TOOL" ] || refuse_or_warn "neither fuser nor lsof is available, so open files cannot be detected"

# file_open <absolute path> : true when a process holds the file. psmisc fuser rejects "--" as a name.
file_open() {
  case "$OPEN_TOOL" in
    fuser) fuser -s "$1" 2>/dev/null ;;
    lsof) lsof -- "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

ARCHIVE=$(cfg_get workspace_archive_dir "")
case "$ARCHIVE" in \~|\~/*) ARCHIVE="$HOME${ARCHIVE#\~}" ;; esac
# require_archive_dir : called at each candidate, so nothing to archive needs no location.
require_archive_dir() {
  [ -n "$ARCHIVE" ] || { echo "workspace_archive_dir is not set" >&2; exit 3; }
  case "$ARCHIVE" in
    /*) ;;
    *) echo "workspace_archive_dir must be an absolute path, not '$ARCHIVE'" >&2; exit 3 ;;
  esac
}
REPO=$(basename "$PRIMARY")

# in_flight <doc_dir> : for the primary checkout, true when a staying worktree holds the same doc dir.
in_flight() {
  [ "$ROOT" = "$PRIMARY" ] || return 1
  local wt
  while IFS= read -r wt; do [ -e "$wt/$WD/$1" ] && return 0; done < <(staying)
  return 1
}

# action <rel path below the doc dir> : gzip, move or keep, by extension and test-output directory.
action() {
  local lower=${1,,} base
  base=${lower##*/}
  case "$base" in
    *.md|*.tar.gz) echo keep; return ;;
    *.py|*.sh|*.bash|*.zsh|*.ipynb|*.js|*.jsx|*.mjs|*.cjs|*.ts|*.tsx|*.vue|*.svelte|*.go|*.rs) echo keep; return ;;
    *.java|*.kt|*.kts|*.scala|*.swift|*.dart|*.gd|*.c|*.h|*.cc|*.cpp|*.cxx|*.hpp|*.cs|*.rb|*.php|*.lua|*.pl) echo keep; return ;;
    *.css|*.scss|*.sass|*.less|*.yaml|*.yml|*.toml|*.ini|*.cfg|*.conf|*.properties|*.gradle|*.tf) echo keep; return ;;
  esac
  case "$base" in
    *.log|*.out|*.txt|*.csv|*.tsv|*.json|*.jsonl|*.ndjson|*.dump|*.sql|*.html|*.xml) echo gzip; return ;;
    *.jpg|*.jpeg|*.png|*.gif|*.webp|*.bmp|*.tif|*.tiff|*.mp4|*.mov|*.webm|*.xlsx|*.xls|*.pdf|*.zip|*.gz|*.xz|*.zst|*.parquet) echo move; return ;;
  esac
  case "/$lower" in
    */test-results/*|*/playwright-report/*|*/coverage/*|*/htmlcov/*|*/screenshots/*) echo move; return ;;
  esac
  echo keep
}

sha() { sha256sum | cut -d' ' -f1; }

ledger() { # ledger <doc_dir> <rel> <dest> <bytes> <sha> <method>
  local f="$PRIMARY/$WD/$1/ARCHIVED.md"
  mkdir -p "$(dirname "$f")" || return 1
  if [ ! -f "$f" ]; then
    {
      echo "# Archived files"
      echo
      echo "Moved out by /dotclaude:purge. Restore: \`gunzip -c <location> > <original>\` (gzip) or \`mv <location> <original>\` (move)."
      echo
      echo "| Original | Location | Bytes | sha256 | Date | Method |"
      echo "|----------|----------|-------|--------|------|--------|"
    } >"$f" || return 1
  fi
  printf '| %s | %s | %s | %s | %s | %s |\n' "$2" "$3" "$4" "$5" "${DATE//_/-}" "$6" >>"$f"
}

# verified_copy <src> <tmp> <method> <sha of src> : write the copy and prove it matches the source.
verified_copy() {
  if [ "$3" = gzip ]; then
    # Private until it carries the source's mode: the source may be readable only by its owner.
    ( umask 077; gzip -c -- "$1" >"$2" ) || return 1
    [ "$(gzip -dc -- "$2" | sha)" = "$4" ]
  else
    cp -p -- "$1" "$2" || return 1
    cmp -s -- "$1" "$2"
  fi
}

# archive_one <abs src> <doc_dir> <rel below doc dir> <method> <bytes>
archive_one() {
  local src=$1 doc=$2 rel=$3 method=$4 bytes=$5 dest tmp s existing
  dest="$ARCHIVE/$REPO/$doc/$rel"
  [ "$method" = gzip ] && dest="$dest.gz"
  [ "$(realpath -m -- "$dest")" != "$(realpath -m -- "$src")" ] || { echo "FAIL $src: archive destination is the source itself" >&2; return 1; }
  mkdir -p "$(dirname "$dest")" || return 1
  s=$(sha <"$src") || return 1
  if [ -e "$dest" ]; then
    if [ "$method" = gzip ]; then existing=$(gzip -dc -- "$dest" | sha); else existing=$(sha <"$dest"); fi
    [ "$existing" = "$s" ] || { echo "FAIL $src: different file already at $dest" >&2; return 1; }
  else
    tmp="$dest.tmp.$$"
    verified_copy "$src" "$tmp" "$method" "$s" || { rm -f -- "$tmp"; echo "FAIL $src: verification failed" >&2; return 1; }
    chmod --reference="$src" -- "$tmp" || { rm -f -- "$tmp"; return 1; }
    mv -- "$tmp" "$dest" || { rm -f -- "$tmp"; return 1; }
  fi
  ledger "$doc" "$rel" "$dest" "$bytes" "$s" "$method" || { echo "FAIL $src: ledger not written" >&2; return 1; }
  rm -f -- "$src"
}

# remove_emptied <dir> <doc dir> : rmdir from an archived file's parent upward, stopping at the doc dir.
remove_emptied() {
  local d=$1
  while [ "$d" != "$2" ] && rmdir -- "$d" 2>/dev/null; do d=${d%/*}; done
}

WS="$ROOT/$WD"
[ -d "$WS" ] || exit 0
now=$(date +%s)
for entry in "$WS"/* "$WS"/.[!.]*; do
  [ -d "$entry" ] && [ ! -L "$entry" ] || continue
  doc=${entry##*/}
  outdoc=$doc
  [ "$ROOT" = "$PRIMARY" ] || outdoc=$(dated_name "$doc")
  case "$doc" in .archive|.snapshots|.validated|.git|.venv|venv|node_modules) continue ;; esac
  if ignored_entry "$doc" "${IGN[@]}"; then [ "$MODE" = plan ] && printf 'skip-ignored\t0\t%s\n' "$doc"; continue; fi
  if in_flight "$doc"; then [ "$MODE" = plan ] && printf 'skip-in-flight\t0\t%s\n' "$doc"; continue; fi
  while IFS= read -r -d '' f; do
    rel=${f#"$entry/"}
    case "/$rel/" in */__pycache__/*) continue ;; esac
    match_any_glob "$doc/$rel" "${EXCL[@]}" && continue
    match_any_glob "$outdoc/$rel" "${EXCL[@]}" && continue
    method=$(action "$rel")
    [ "$method" != keep ] || continue
    bytes=$(stat -c %s -- "$f") || continue
    [ "$bytes" -gt "$MIN_BYTES" ] || continue
    [ $((now - $(stat -c %Y -- "$f"))) -ge "$MIN_AGE_SECS" ] || { [ "$MODE" = plan ] && printf 'skip-recent\t%s\t%s\n' "$bytes" "$doc/$rel"; continue; }
    git --literal-pathspecs -C "$ROOT" ls-files --error-unmatch -- "$WD/$doc/$rel" >/dev/null 2>&1 && continue
    if file_open "$f"; then
      [ "$MODE" = plan ] && printf 'skip-open\t%s\t%s\n' "$bytes" "$doc/$rel"; continue
    fi
    if [ "$MODE" = plan ]; then printf '%s\t%s\t%s\n' "$method" "$bytes" "$doc/$rel"; continue; fi
    require_archive_dir
    if archive_one "$f" "$outdoc" "$rel" "$method" "$bytes"; then
      remove_emptied "$(dirname "$f")" "$entry"
    else
      fails=$((fails + 1))
    fi
  done < <(walk "$entry" -type f)
done
[ "$fails" = 0 ] && exit 0 || exit 1
