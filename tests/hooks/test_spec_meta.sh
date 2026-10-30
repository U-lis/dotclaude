#!/usr/bin/env bash
# shellcheck disable=SC2015
# Tests for hooks/spec-meta.sh
HERE=$(cd "$(dirname "$0")" && pwd)
SM="$HERE/../../hooks/spec-meta.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fails=0
ok() { echo "PASS: $1"; }
ko() { echo "FAIL: $1 ($2)"; fails=$((fails+1)); }
eq() { [ "$2" = "$3" ] && ok "$1" || ko "$1" "expected [$3] got [$2]"; }
rc() { local want=$1 name=$2; shift 2; "$@" >/dev/null 2>&1; local g=$?; [ "$g" = "$want" ] && ok "$name" || ko "$name" "exit $g, want $want"; }

mk() { cat >"$1" <<'S'
<!-- dotclaude-config
working_directory: .dc_workspace
stage: spec_review
approved_at: null
approved_hash: null
decisions: []
handoff: ""
-->
# Title

body line
S
}

# find
R="$T/repo"; mkdir -p "$R"; git -C "$R" init -q -b main 2>/dev/null || git -C "$R" init -q
git -C "$R" checkout -q -b feature/kw 2>/dev/null || git -C "$R" checkout -q feature/kw
rc 1 "find none" "$SM" find "$R"
mkdir -p "$R/.dc_workspace/2026_01_01-other"; mk "$R/.dc_workspace/2026_01_01-other/SPEC.md"
eq "find one" "$("$SM" find "$R")" "$R/.dc_workspace/2026_01_01-other/SPEC.md"
mkdir -p "$R/.dc_workspace/2026_02_02-kw"; mk "$R/.dc_workspace/2026_02_02-kw/SPEC.md"
touch -d '2020-01-01' "$R/.dc_workspace/2026_02_02-kw/SPEC.md"
eq "find many branch match" "$("$SM" find "$R")" "$R/.dc_workspace/2026_02_02-kw/SPEC.md"
git -C "$R" checkout -q -b fix/nomatch
eq "find many newest fallback" "$("$SM" find "$R")" "$R/.dc_workspace/2026_01_01-other/SPEC.md"
mkdir -p "$R/.claude"; echo '{ "working_directory": "ws2" }' >"$R/.claude/dotclaude-config.json"
rc 1 "find custom working_directory (empty)" "$SM" find "$R"
mkdir -p "$R/ws2/x-nomatch"; mk "$R/ws2/x-nomatch/SPEC.md"
eq "find custom working_directory" "$("$SM" find "$R")" "$R/ws2/x-nomatch/SPEC.md"

# get/set
S="$T/SPEC.md"; mk "$S"
eq "get existing" "$("$SM" get "$S" stage)" "spec_review"
rc 1 "get absent key" "$SM" get "$S" nokey
rc 2 "get missing file" "$SM" get "$T/none.md" stage
"$SM" set "$S" stage code; eq "set update" "$("$SM" get "$S" stage)" "code"
"$SM" set "$S" github_issue 12; eq "set add" "$("$SM" get "$S" github_issue)" "12"
cp "$S" "$T/before"; "$SM" set "$S" github_issue 12
cmp -s "$S" "$T/before" && ok "set idempotent" || ko "set idempotent" "file changed"
eq "set preserves body" "$(tail -n 3 "$S")" "$(printf '# Title\n\nbody line')"
printf 'x\nno newline' >"$T/nonl.md"; "$SM" set "$T/nonl.md" a b
eq "no-block set creates block" "$(head -n 3 "$T/nonl.md")" "$(printf '<!-- dotclaude-config\na: b\n-->')"
eq "no-block set keeps body bytes" "$(tail -c 12 "$T/nonl.md" | od -An -c | tr -d ' \n')" "x\nnonewline"
rc 2 "unterminated block set" bash -c "printf '<!-- dotclaude-config\na: b\n' >'$T/u.md'; '$SM' set '$T/u.md' a c"

# body-hash
mk "$S"; h1=$("$SM" body-hash "$S")
"$SM" set "$S" stage design; eq "hash unaffected by meta" "$("$SM" body-hash "$S")" "$h1"
echo "more" >>"$S"; [ "$("$SM" body-hash "$S")" != "$h1" ] && ok "hash changes on body edit" || ko "hash body" "same"
printf 'plain\ntext' >"$T/plain.md"
eq "hash no block = whole file" "$("$SM" body-hash "$T/plain.md")" "$(sha256sum <"$T/plain.md" | cut -d' ' -f1)"

# approve
mk "$S"; rc 1 "check-approved before approve" "$SM" check-approved "$S"
eq "not approved msg" "$("$SM" check-approved "$S")" "not approved"
"$SM" approve "$S" >/dev/null
rc 0 "check-approved after approve" "$SM" check-approved "$S"
eq "approve sets stage" "$("$SM" get "$S" stage)" "design"
case "$("$SM" check-approved "$S")" in "approved 20"*Z) ok "approved msg";; *) ko "approved msg" "$("$SM" check-approved "$S")";; esac
echo "edit" >>"$S"
rc 1 "check-approved after edit" "$SM" check-approved "$S"
case "$("$SM" check-approved "$S")" in "spec changed since approval (20"*Z\)) ok "changed msg";; *) ko "changed msg" "$("$SM" check-approved "$S")";; esac

# stage
mk "$S"
eq "stage get" "$("$SM" stage "$S")" "spec_review"
eq "stage set" "$("$SM" stage "$S" code)" "stage: spec_review -> code"
eq "stage set persisted" "$("$SM" stage "$S")" "code"
rc 2 "stage invalid" "$SM" stage "$S" bogus
"$SM" stage "$S" bogus 2>&1 | grep -q "spec_review design" && ok "stage invalid lists allowed" || ko "stage invalid msg" ""
eq "stage unchanged after invalid" "$("$SM" stage "$S")" "code"

# handoff
mk "$S"
"$SM" handoff "$S" 'say "hi" \ there'
eq "handoff roundtrip quotes" "$("$SM" handoff "$S")" 'say "hi" \ there'
eq "handoff stored escaped" "$("$SM" get "$S" handoff)" '"say \"hi\" \\ there"'

# decisions
mk "$S"
"$SM" decision "$S" add alpha; "$SM" decision "$S" add beta-2; "$SM" decision "$S" add alpha
eq "decision list deduped" "$("$SM" decision "$S" list | paste -sd,)" "alpha,beta-2"
eq "decision stored" "$("$SM" get "$S" decisions)" '["alpha", "beta-2"]'
rc 2 "decision invalid token" "$SM" decision "$S" add 'bad token'
mk "$S"; eq "decision list empty" "$("$SM" decision "$S" list)" ""

rc 0 "help" "$SM" --help
[ "$fails" -eq 0 ] && { echo "ALL PASS"; exit 0; } || { echo "$fails FAILED"; exit 1; }
