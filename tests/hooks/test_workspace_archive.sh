#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
S="$HOOKS/workspace-archive.sh"
A="$T/arch"
DAY=2026_03_04
cfg() { printf '{ "working_directory": ".dc_workspace", "workspace_archive_dir": "%s"%s }\n' "${2:-$A}" "${1:+, $1}" >"$R/.claude/dotclaude-config.json"; }
cfg
big() { mkdir -p "$(dirname "$1")"; head -c 150000 "${2:-/dev/urandom}" >"$1"; touch -d '3 days ago' "$1"; }
isin() { case "$2" in *"$3"*) ok "$1";; *) ko "$1" "no [$3]";; esac; }
notin() { case "$2" in *"$3"*) ko "$1" "found [$3]";; *) ok "$1";; esac; }
exists() { [ -e "$2" ] && ok "$1" || ko "$1" "missing $2"; }
gone() { [ -e "$2" ] && ko "$1" "still $2" || ok "$1"; }
rc_is() { [ "$3" = "$2" ] && ok "$1" || ko "$1" "exit $3, want $2"; }
D="$R/.dc_workspace/2026_01_01-done"; mkdir -p "$D"
KEEP_TYPES="tsx jsx java kt c h cpp rb css scss yaml yml toml"
echo keep >"$D/SPEC.md"
big "$D/big.md"; big "$D/script.py"; big "$D/run.log" /dev/zero; big "$D/img/a.jpg"; big "$D/data.xlsx"
big "$D/unknown.bin"; big "$D/test-results/trace.bin"; big "$D/keep.txt" /dev/zero
for e in $KEEP_TYPES; do big "$D/test-results/kept.$e" /dev/zero; done
big "$D/node_modules/n.log" /dev/zero; big "$D/sub/.venv/v.log" /dev/zero; big "$D/sub/venv/w.log" /dev/zero; big "$D/sub/.git/g.log" /dev/zero
big "$D/secret.log" /dev/zero; chmod 600 "$D/secret.log"; big "$D/shared.log" /dev/zero; chmod 640 "$D/shared.log"
mkdir -p "$D/was-empty"
head -c 1000 /dev/zero >"$D/small.log"; touch -d '3 days ago' "$D/small.log"
head -c 150000 /dev/zero >"$D/fresh.log"
big "$D/__pycache__/m.pyc" /dev/zero; big "$D/__pycache__/m.log" /dev/zero
big "$D/tracked.log" /dev/zero; git -C "$R" add -f .dc_workspace/2026_01_01-done/tracked.log; git -C "$R" commit -qm t

# plan changes nothing and classifies
out=$("$S" files plan "$R" --removing "$W" --date "$DAY"); rc=$?
rc_is "plan exit 0" 0 $rc
isin "gzip log" "$out" "gzip"$'\t'"150000"$'\t'"2026_01_01-done/run.log"
isin "move jpg" "$out" "move"$'\t'"150000"$'\t'"2026_01_01-done/img/a.jpg"
isin "move xlsx" "$out" "2026_01_01-done/data.xlsx"
isin "move test output" "$out" "2026_01_01-done/test-results/trace.bin"
isin "recent reported" "$out" "skip-recent"
notin "pycache not planned" "$out" "pycache"
for n in SPEC.md big.md script.py small.log unknown.bin tracked.log; do notin "$n not picked" "$out" "done/$n"; done
for e in $KEEP_TYPES; do notin ".$e under test output stays" "$out" "test-results/kept.$e"; done
for n in node_modules/n.log sub/.venv/v.log sub/venv/w.log sub/.git/g.log; do notin "$n pruned" "$out" "$n"; done
exists "plan keeps original" "$D/run.log"; gone "plan writes no archive" "$A"

# apply needs the setting, as an absolute path
printf '{ "working_directory": ".dc_workspace" }\n' >"$R/.claude/dotclaude-config.json"
out=$("$S" files apply "$R" --removing "$W" 2>&1); rc=$?
rc_is "unset dir -> exit 3" 3 $rc; isin "unset dir reported" "$out" "is not set"
exists "unset dir keeps original" "$D/run.log"
cfg "" rel/arch
out=$(cd "$T" && "$S" files apply "$R" --removing "$W" 2>&1); rc=$?
rc_is "relative dir -> exit 3" 3 $rc; isin "relative dir reported" "$out" "absolute"
gone "relative dir creates nothing" "$T/rel"; exists "relative dir keeps original" "$D/run.log"
cfg

# --date form and a working_directory that is the repository itself are refused
"$S" files plan "$R" --date 2026-03-04 2>/dev/null; rc_is "bad --date -> exit 2" 2 $?
for wd in . ./ sub/.. ..; do
  printf '{ "working_directory": "%s", "workspace_archive_dir": "%s" }\n' "$wd" "$A" >"$R/.claude/dotclaude-config.json"
  "$S" files plan "$R" 2>/dev/null; rc_is "working_directory $wd -> exit 2" 2 $?
done
cfg

# apply, with --exclude
sum=$(sha256sum <"$D/img/a.jpg" | cut -d' ' -f1); logsum=$(sha256sum <"$D/run.log" | cut -d' ' -f1)
"$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' --date "$DAY"; rc=$?
rc_is "apply exit 0" 0 $rc
B="$A/x/2026_01_01-done"
exists "gzip dest" "$B/run.log.gz"; gone "gzip original gone" "$D/run.log"
[ "$(gzip -dc "$B/run.log.gz" | sha256sum | cut -d' ' -f1)" = "$logsum" ] && ok "gzip content" || ko "gzip content" x
[ "$(stat -c %a "$B/secret.log.gz")" = 600 ] && ok "gzip keeps 0600 mode" || ko "gzip keeps 0600 mode" "$(stat -c %a "$B/secret.log.gz")"
[ "$(stat -c %a "$B/shared.log.gz")" = 640 ] && ok "gzip keeps 0640 mode" || ko "gzip keeps 0640 mode" "$(stat -c %a "$B/shared.log.gz")"
exists "move dest" "$B/img/a.jpg"; gone "move original gone" "$D/img/a.jpg"; gone "empty dir removed" "$D/img"
[ "$(sha256sum <"$B/img/a.jpg" | cut -d' ' -f1)" = "$sum" ] && ok "move content" || ko "move content" x
for n in SPEC.md small.log fresh.log tracked.log; do exists "$n stays" "$D/$n"; done
exists "excluded file stays" "$D/keep.txt"
exists "pycache left alone" "$D/__pycache__/m.log"
exists "dir the script did not empty stays" "$D/was-empty"
L=$(cat "$D/ARCHIVED.md")
isin "ledger row" "$L" "| run.log | $B/run.log.gz | 150000 | $logsum |"
isin "ledger method" "$L" "| move |"
isin "ledger date from --date" "$L" "| 2026-03-04 |"

# different file at the destination: fail, keep the original
big "$D/img/a.jpg"
out=$("$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' 2>&1); rc=$?
rc_is "conflict exit 1" 1 $rc
exists "conflict keeps original" "$D/img/a.jpg"; isin "conflict reported" "$out" "different file"
# identical file at the destination: original goes
cp -p "$B/img/a.jpg" "$D/img/a.jpg"
"$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' >/dev/null 2>&1; gone "same content -> original gone" "$D/img/a.jpg"

# a failing copy check keeps the original
STUB="$T/failing"; mkdir -p "$STUB"; printf '#!/bin/sh\nexit 1\n' >"$STUB/cmp"; printf '#!/bin/sh\n[ "$1" = -c ] && { echo garbage; exit 0; }\nexec %s "$@"\n' "$(command -v gzip)" >"$STUB/gzip"; chmod +x "$STUB/cmp" "$STUB/gzip"
big "$D/photo.png"; big "$D/verify.log" /dev/zero
out=$(PATH="$STUB:$PATH" "$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' 2>&1); rc=$?
rc_is "failed verification exit 1" 1 $rc; isin "failed verification reported" "$out" "verification failed"
exists "failed cmp keeps original" "$D/photo.png"; exists "failed gzip keeps original" "$D/verify.log"
gone "failed cmp leaves no copy" "$B/photo.png"; gone "failed gzip leaves no copy" "$B/verify.log.gz"
[ -z "$(find "$B" -name '*.tmp.*')" ] && ok "failed verification leaves no temp file" || ko "temp file" "$(find "$B" -name '*.tmp.*')"
notin "failed verification writes no ledger row" "$(cat "$D/ARCHIVED.md")" "photo.png"
rm -f "$D/photo.png" "$D/verify.log"

# open files stay, by fuser or by lsof; with neither, apply refuses
big "$D/open.log" /dev/zero
exec 9<"$D/open.log"
out=$("$S" files plan "$R" --removing "$W" --exclude '*/keep.txt'); isin "open file reported" "$out" "skip-open"$'\t'"150000"$'\t'"2026_01_01-done/open.log"
out=$(PATH=$(tool_path fuser) "$S" files plan "$R" --removing "$W"); isin "open file reported by lsof" "$out" "skip-open"$'\t'"150000"$'\t'"2026_01_01-done/open.log"
"$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' >/dev/null; exists "open file stays" "$D/open.log"
exec 9<&-
out=$(PATH=$(tool_path fuser lsof) "$S" files apply "$R" --removing "$W" --exclude '*/keep.txt' 2>&1); rc=$?
rc_is "no fuser or lsof -> apply exit 2" 2 $rc; isin "no fuser or lsof reported" "$out" "fuser"; exists "no fuser or lsof keeps file" "$D/open.log"
gone "no fuser or lsof archives nothing" "$B/open.log.gz"
errs=$(PATH=$(tool_path fuser lsof) "$S" files plan "$R" --removing "$W" 2>&1 >/dev/null); rc=$?
rc_is "no fuser or lsof -> plan exit 0" 0 $rc; isin "no fuser or lsof -> plan warns" "$errs" "fuser"
rm -f "$D/open.log"

# worktree: same repo folder, ledger in the primary
big "$W/.dc_workspace/2026_01_01-kw/wt.log" /dev/zero
"$S" files apply "$W" >/dev/null; exists "worktree dest under repo name" "$A/x/2026_01_01-kw/wt.log.gz"
exists "ledger in primary" "$R/.dc_workspace/2026_01_01-kw/ARCHIVED.md"
gone "no ledger in worktree" "$W/.dc_workspace/2026_01_01-kw/ARCHIVED.md"
# removal of emptied directories stops at the doc dir
big "$W/.dc_workspace/2026_01_02-only/deep/one.log" /dev/zero
"$S" files apply "$W" >/dev/null; gone "emptied subdir removed" "$W/.dc_workspace/2026_01_02-only/deep"; exists "emptied doc dir stays" "$W/.dc_workspace/2026_01_02-only"

# primary doc dir shared with a staying worktree stays; ignore list stays
big "$R/.dc_workspace/2026_01_01-kw/p.log" /dev/zero
big "$R/.dc_workspace/ign/i.log" /dev/zero
cfg '"workspace_size_ignore": ["ign"]'
out=$("$S" files plan "$R"); isin "in-flight reported" "$out" "skip-in-flight"$'\t'"0"$'\t'"2026_01_01-kw"; isin "ignored reported" "$out" "skip-ignored"$'\t'"0"$'\t'"ign"
"$S" files apply "$R" --exclude '*/keep.txt' >/dev/null; exists "in-flight stays" "$R/.dc_workspace/2026_01_01-kw/p.log"; exists "ignored stays" "$R/.dc_workspace/ign/i.log"

# the ignore list holds without jq; a value that cannot be read stops apply
NOJQ=$(tool_path jq)
out=$(PATH=$NOJQ "$S" files plan "$R"); isin "no jq: ignored reported" "$out" "skip-ignored"$'\t'"0"$'\t'"ign"
PATH=$NOJQ "$S" files apply "$R" --exclude '*/keep.txt' >/dev/null; exists "no jq: ignored stays" "$R/.dc_workspace/ign/i.log"
PATH=$(tool_path jq python3) "$S" preserve plan "$W" 2>/dev/null; rc_is "no jq or python3: preserve -> exit 2" 2 $?
PATH=$(tool_path jq python3) "$S" files apply "$R" 2>/dev/null; rc_is "no jq or python3 -> exit 2" 2 $?
exists "no jq or python3: ignored stays" "$R/.dc_workspace/ign/i.log"
bad='"ign"'
cfg "\"workspace_size_ignore\": $bad"
out=$("$S" files apply "$R" 2>&1); rc_is "unreadable ignore $bad -> exit 2" 2 $?; isin "unreadable ignore $bad reported" "$out" "workspace_size_ignore"
PATH=$NOJQ "$S" files apply "$R" 2>/dev/null; rc_is "no jq: unreadable ignore $bad -> exit 2" 2 $?
exists "unreadable ignore $bad: file stays" "$R/.dc_workspace/ign/i.log"
errs=$("$S" files plan "$R" 2>&1 >/dev/null); isin "unreadable ignore -> plan warns" "$errs" "workspace_size_ignore"

# tilde expands
cfg "" "~/arch2"
big "$R/.dc_workspace/t/t.log" /dev/zero; "$S" files apply "$R" --exclude '*/keep.txt' >/dev/null; exists "tilde expanded" "$HOME/arch2/x/t/t.log.gz"
cfg

# preserve: a dated doc dir keeps its name, an undated one gets the run's date
mkdir -p "$W/.dc_workspace/ONE-1-thing/sub" "$W/.dc_workspace/.validated"
echo s >"$W/.dc_workspace/ONE-1-thing/SPEC.md"; echo p >"$W/.dc_workspace/ONE-1-thing/sub/n.md"; echo v >"$W/.dc_workspace/.validated/m.json"
big "$W/.dc_workspace/ONE-1-thing/w.log" /dev/zero
"$S" files apply "$W" --date "$DAY" >/dev/null
exists "undated archive dest dated" "$A/x/$DAY-ONE-1-thing/w.log.gz"
exists "ledger beside dated docs" "$R/.dc_workspace/$DAY-ONE-1-thing/ARCHIVED.md"
gone "no undated ledger dir" "$R/.dc_workspace/ONE-1-thing"
out=$("$S" preserve plan "$W" --date "$DAY"); isin "preserve plan row" "$out" "copy"$'\t'"ONE-1-thing/SPEC.md"$'\t'"$DAY-ONE-1-thing/SPEC.md"
gone "preserve plan copies nothing" "$R/.dc_workspace/$DAY-ONE-1-thing/SPEC.md"
mkdir -p "$W/.dc_workspace/2026_01_01-kw/node_modules/m" "$W/.dc_workspace/2026_01_01-kw/__pycache__"
echo n >"$W/.dc_workspace/2026_01_01-kw/node_modules/m/README.md"; echo c >"$W/.dc_workspace/2026_01_01-kw/__pycache__/m.pyc"
"$S" preserve apply "$W" --date "$DAY" >/dev/null; rc_is "preserve exit 0" 0 $?
exists "undated doc dated" "$R/.dc_workspace/$DAY-ONE-1-thing/SPEC.md"
exists "nested doc copied" "$R/.dc_workspace/$DAY-ONE-1-thing/sub/n.md"
exists "dated dir keeps name" "$R/.dc_workspace/2026_01_01-kw/PHASE_1_PLAN_kw.md"
exists "hidden dir keeps name" "$R/.dc_workspace/.validated/m.json"
gone "preserve prunes node_modules" "$R/.dc_workspace/2026_01_01-kw/node_modules"
gone "preserve skips __pycache__" "$R/.dc_workspace/2026_01_01-kw/__pycache__"
"$S" preserve apply "$R" 2>/dev/null; rc_is "preserve on primary -> exit 2" 2 $?
"$S" preserve plan "$W" --date 20260304 2>/dev/null; rc_is "preserve bad --date -> exit 2" 2 $?

# an undated doc dir the primary already has keeps its name
mkdir -p "$R/.dc_workspace/SHARED" "$W/.dc_workspace/SHARED"; echo p >"$R/.dc_workspace/SHARED/primary.md"; echo w >"$W/.dc_workspace/SHARED/w.md"
big "$W/.dc_workspace/SHARED/x.log" /dev/zero
"$S" files apply "$W" --date "$DAY" >/dev/null
exists "existing undated: archive keeps name" "$A/x/SHARED/x.log.gz"; exists "existing undated: ledger keeps name" "$R/.dc_workspace/SHARED/ARCHIVED.md"
gone "existing undated: no dated archive" "$A/x/$DAY-SHARED"
"$S" preserve apply "$W" --date "$DAY" >/dev/null
exists "existing undated: preserve keeps name" "$R/.dc_workspace/SHARED/w.md"
gone "existing undated: no dated copy" "$R/.dc_workspace/$DAY-SHARED"

# --exclude holds under both names, so a kept file stays after preserve renames its dir
big "$W/.dc_workspace/REN/notes.txt" /dev/zero
out=$("$S" files plan "$W" --date "$DAY" --exclude 'REN/notes.txt'); notin "exclude matches a worktree's name" "$out" "notes.txt"
"$S" files apply "$W" --date "$DAY" --exclude "$DAY-REN/notes.txt" >/dev/null; exists "exclude matches the dated name" "$W/.dc_workspace/REN/notes.txt"
"$S" preserve apply "$W" --date "$DAY" >/dev/null
"$S" files apply "$R" --date "$DAY" --exclude '*/keep.txt' --exclude "$DAY-REN/notes.txt" >/dev/null
exists "excluded file stays after rename" "$R/.dc_workspace/$DAY-REN/notes.txt"

# an ignored undated dir stays ignored under the dated name preserve gives it
cfg '"workspace_size_ignore": ["IGD-*"]'
big "$W/.dc_workspace/IGD-1/i.log" /dev/zero
out=$("$S" files plan "$W" --date "$DAY"); isin "undated dir ignored reported" "$out" "skip-ignored"$'\t'"0"$'\t'"IGD-1"
"$S" preserve apply "$W" --date "$DAY" >/dev/null
exists "ignored dir copied under the dated name" "$R/.dc_workspace/$DAY-IGD-1/i.log"
out=$("$S" files plan "$R" --date "$DAY"); isin "dated dir of an ignored name reported" "$out" "skip-ignored"$'\t'"0"$'\t'"$DAY-IGD-1"
"$S" files apply "$R" --date "$DAY" --exclude '*/keep.txt' --exclude "$DAY-REN/notes.txt" >/dev/null
exists "dated dir of an ignored name stays" "$R/.dc_workspace/$DAY-IGD-1/i.log"
gone "dated dir of an ignored name is not archived" "$A/x/$DAY-IGD-1"
cfg

# preserve conflict: an untracked source that differs is reported and nothing is overwritten
KW="2026_01_01-kw"
echo primary >"$R/.dc_workspace/$KW/SPEC.md"; echo late >"$W/.dc_workspace/$KW/late.md"
out=$("$S" preserve plan "$W"); rc=$?
rc_is "preserve plan conflict exit 1" 1 $rc; isin "preserve plan conflict row" "$out" "conflict"$'\t'"$KW/SPEC.md"$'\t'"$KW/SPEC.md"
out=$("$S" preserve apply "$W"); rc=$?
rc_is "preserve conflict exit 1" 1 $rc; isin "preserve conflict row" "$out" "conflict"$'\t'"$KW/SPEC.md"$'\t'"$KW/SPEC.md"
[ "$(cat "$R/.dc_workspace/$KW/SPEC.md")" = primary ] && ok "preserve never overwrites" || ko "preserve never overwrites" x
exists "conflict still copies the rest" "$R/.dc_workspace/$KW/late.md"
# same content is silent
cp "$W/.dc_workspace/$KW/SPEC.md" "$R/.dc_workspace/$KW/SPEC.md"
out=$("$S" preserve apply "$W"); rc_is "preserve same content exit 0" 0 $?; notin "preserve same content no row" "$out" "SPEC.md"
# the top-level hook log differs by nature and is not a document
echo w >"$W/.dc_workspace/.hook.log"; echo r >"$R/.dc_workspace/.hook.log"
out=$("$S" preserve apply "$W"); rc_is "preserve skips hook log exit 0" 0 $?; notin "preserve skips hook log" "$out" ".hook.log"
[ "$(cat "$R/.dc_workspace/.hook.log")" = r ] && ok "hook log untouched" || ko "hook log untouched" x
rm -f "$W/.dc_workspace/.hook.log"
# a tracked, clean source is safe in git; a tracked, modified one is not
echo tr >"$W/.dc_workspace/$KW/tr.md"; git -C "$W" add -f ".dc_workspace/$KW/tr.md"; git -C "$W" commit -qm tr
echo other >"$R/.dc_workspace/$KW/tr.md"
out=$("$S" preserve apply "$W"); rc_is "preserve tracked clean exit 0" 0 $?; notin "preserve tracked clean no row" "$out" "tr.md"
[ "$(cat "$R/.dc_workspace/$KW/tr.md")" = other ] && ok "preserve tracked clean keeps primary" || ko "preserve tracked clean keeps primary" x
echo edit >>"$W/.dc_workspace/$KW/tr.md"
out=$("$S" preserve apply "$W"); rc_is "preserve tracked dirty exit 1" 1 $?; isin "preserve tracked dirty row" "$out" "conflict"$'\t'"$KW/tr.md"
git -C "$W" checkout -q -- ".dc_workspace/$KW/tr.md"

# deps
git -C "$R" worktree add -q -b feature/two "$T/x-two"; git -C "$R" worktree add -q -b feature/three "$T/x-three"
mkdir -p "$R/.venv/bin" "$W/.venv/bin" "$W/venv/bin" "$T/x-two/.venv/bin" "$T/x-two/sub"; ln -s ../x/.venv "$T/x-three/.venv"
out=$("$S" deps plan "$R" --current "$T/x-two")
isin "deps lists real .venv" "$out" "$W/.venv"; isin "deps lists real venv" "$out" "$W/venv"
notin "deps skips current" "$out" "x-two"; notin "deps skips symlink" "$out" "x-three"; notin "deps skips primary" "$out" "$R/.venv"
exists "deps plan keeps" "$W/.venv/bin"
# the session's worktree is skipped even when --current is omitted, and a subdirectory counts
out=$(cd "$T/x-two" && "$S" deps plan "$R"); notin "deps skips session worktree" "$out" "x-two"; isin "deps session still lists others" "$out" "$W/.venv"
out=$(cd "$T/x-two/sub" && "$S" deps plan "$R"); notin "deps skips session from a subdirectory" "$out" "x-two"
out=$("$S" deps plan "$R" --current "$T/x-two/sub"); notin "deps --current subdirectory" "$out" "x-two"; isin "deps --current still lists others" "$out" "$W/.venv"
"$S" deps apply "$R" --current "$T/x-two"; rc=$?; rc_is "deps exit 0" 0 $rc
[ -L "$W/.venv" ] && [ -d "$W/.venv/bin" ] && ok "relinked to primary" || ko "relink" "$(ls -la "$W")"
[ "$(readlink "$W/.venv")" = "../x/.venv" ] && ok "relative link" || ko "relative link" "$(readlink "$W/.venv")"
gone "no primary venv -> deleted only" "$W/venv"; exists "current kept" "$T/x-two/.venv/bin"; [ -L "$T/x-three/.venv" ] && ok "symlink kept" || ko "symlink" x
# --removing is left out, share off deletes without a link
out=$("$S" deps plan "$R" --removing "$T/x-two"); notin "removing skipped" "$out" "x-two"
printf '{ "working_directory": ".dc_workspace", "worktree": { "share_from_base": false } }\n' >"$R/.claude/dotclaude-config.json"
"$S" deps apply "$R"; gone "share off -> no link" "$T/x-two/.venv"
"$S" bogus plan "$R" 2>/dev/null; rc_is "usage exit 2" 2 $?
finish
