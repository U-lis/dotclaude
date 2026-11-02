#!/usr/bin/env bash
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/_fixture.sh"
mk_fixture
. "$HOOKS/_lib.sh"
export HOOK_CWD="$W"
cat >"$R/.claude/dotclaude-config.json" <<'J'
{ "working_directory": ".dc_workspace", "stages": { "stop_after": "pr", "local_test": "make test" },
  "pr": { "assignee": "@me" }, "worktree": { "share_from_base": false } }
J
eq() { [ "$2" = "$3" ] && ok "$1" || ko "$1" "got [$2] want [$3]"; }
eq "flat key" "$(cfg_get working_directory x)" ".dc_workspace"
eq "nested stages.stop_after" "$(cfg_get stages.stop_after remote_test)" "pr"
eq "nested stages.local_test" "$(cfg_get stages.local_test '')" "make test"
eq "nested pr.assignee" "$(cfg_get pr.assignee none)" "@me"
eq "nested false boolean" "$(cfg_get worktree.share_from_base true)" "false"
eq "missing nested -> default" "$(cfg_get stages.remote_test dflt)" "dflt"
eq "missing parent -> default" "$(cfg_get integration pr)" "pr"
mkdir -p "$HOME/.claude"; printf '{ "stages": { "stop_after": "local_test" } }\n' >"$HOME/.claude/dotclaude-config.json"
eq "local overrides global" "$(cfg_get stages.stop_after remote_test)" "pr"
# $CLAUDE_CONFIG_DIR layer sits between ~/.claude and the repository
mkdir -p "$T/work"; printf '{ "workspace_archive_dir": "/from/work", "stages": { "stop_after": "local_test" } }\n' >"$T/work/dotclaude-config.json"
printf '{ "workspace_archive_dir": "/from/home", "language": "ko_KR" }\n' >"$HOME/.claude/dotclaude-config.json"
eq "no CLAUDE_CONFIG_DIR -> ~/.claude" "$(cfg_get workspace_archive_dir x)" "/from/home"
export CLAUDE_CONFIG_DIR="$T/work"
eq "CLAUDE_CONFIG_DIR overrides ~/.claude" "$(cfg_get workspace_archive_dir x)" "/from/work"
eq "~/.claude still supplies other keys" "$(cfg_get language x)" "ko_KR"
eq "repo overrides CLAUDE_CONFIG_DIR" "$(cfg_get stages.stop_after x)" "pr"
unset CLAUDE_CONFIG_DIR

# spec-meta.sh find reads the same layer: repository, then $CLAUDE_CONFIG_DIR, then ~/.claude
N="$T/n"; for d in from-home from-work from-repo; do mkdir -p "$N/$d/d"; : >"$N/$d/d/SPEC.md"; done
printf '{ "working_directory": "from-home" }\n' >"$HOME/.claude/dotclaude-config.json"
printf '{ "working_directory": "from-work" }\n' >"$T/work/dotclaude-config.json"
eq "find: ~/.claude without CLAUDE_CONFIG_DIR" "$("$HOOKS/spec-meta.sh" find "$N")" "$N/from-home/d/SPEC.md"
eq "find: CLAUDE_CONFIG_DIR over ~/.claude" "$(CLAUDE_CONFIG_DIR="$T/work" "$HOOKS/spec-meta.sh" find "$N")" "$N/from-work/d/SPEC.md"
mkdir -p "$N/.claude"; printf '{ "working_directory": "from-repo" }\n' >"$N/.claude/dotclaude-config.json"
eq "find: repository over CLAUDE_CONFIG_DIR" "$(CLAUDE_CONFIG_DIR="$T/work" "$HOOKS/spec-meta.sh" find "$N")" "$N/from-repo/d/SPEC.md"

# init-config.sh reads it too, between ~/.claude and the repository
printf '{ "language": "ko_KR" }\n' >"$HOME/.claude/dotclaude-config.json"
printf '{ "language": "ja_JP" }\n' >"$T/work/dotclaude-config.json"
eq "init-config: ~/.claude without CLAUDE_CONFIG_DIR" "$(cd "$R" && "$HOOKS/init-config.sh")" "[dotclaude] language: ko_KR"
eq "init-config: CLAUDE_CONFIG_DIR over ~/.claude" "$(cd "$R" && CLAUDE_CONFIG_DIR="$T/work" "$HOOKS/init-config.sh")" "[dotclaude] language: ja_JP"
printf '{ "working_directory": ".dc_workspace", "language": "fr_FR" }\n' >"$R/.claude/dotclaude-config.json"
eq "init-config: repository over CLAUDE_CONFIG_DIR" "$(cd "$R" && CLAUDE_CONFIG_DIR="$T/work" "$HOOKS/init-config.sh")" "[dotclaude] language: fr_FR"

# json_get prints a list or dict as JSON with jq or python3; cfg_get_list parses the value with either
NOJQ=$(tool_path jq)
J='{"l":["a","b c"],"d":{"k":[1,true]},"s":"v","n":null,"t":true}'
for key in l d s t; do
  eq "json_get $key: python3 matches jq" "$(PATH=$NOJQ json_get "$J" "$key")" "$(json_get "$J" "$key")"
done
eq "json_get null: python3 empty" "$(PATH=$NOJQ json_get "$J" n)" ""
list() { printf '{ "working_directory": ".dc_workspace", "L": %s }\n' "$1" >"$R/.claude/dotclaude-config.json"; }
want=$'a*\nb c'
list '["a*", "b c"]'
eq "cfg_get_list with jq" "$(cfg_get_list L)" "$want"
eq "cfg_get_list with python3" "$(PATH=$NOJQ cfg_get_list L)" "$want"
list '[]'
cfg_get_list L >/dev/null; [ $? = 0 ] && ok "cfg_get_list empty -> 0" || ko "cfg_get_list empty -> 0" x
eq "cfg_get_list unset -> nothing" "$(cfg_get_list NOPE)" ""
cfg_get_list NOPE; [ $? = 0 ] && ok "cfg_get_list unset -> 0" || ko "cfg_get_list unset -> 0" x
for bad in '"a"' '{"a":1}' '["a",1]'; do
  list "$bad"
  cfg_get_list L >/dev/null; [ $? != 0 ] && ok "cfg_get_list $bad with jq -> non-zero" || ko "cfg_get_list $bad with jq -> non-zero" x
  (PATH=$NOJQ; cfg_get_list L >/dev/null); [ $? != 0 ] && ok "cfg_get_list $bad with python3 -> non-zero" || ko "cfg_get_list $bad with python3 -> non-zero" x
done
(PATH=$(tool_path jq python3); cfg_get_list L >/dev/null); [ $? != 0 ] && ok "cfg_get_list without a parser -> non-zero" || ko "cfg_get_list without a parser -> non-zero" x
match_any_glob "ONE-1" "x" "ONE-*" && ok "match_any_glob glob" || ko "match_any_glob glob" x
match_any_glob "dir" "dir/" && ok "match_any_glob trailing slash" || ko "match_any_glob trailing slash" x
match_any_glob "dir" && ko "match_any_glob no globs" x || ok "match_any_glob no globs"
match_any_glob "2026_01_01-ONE-1" "ONE-*" && ko "match_any_glob ignores no date prefix" x || ok "match_any_glob ignores no date prefix"
ignored_entry "ONE-1" "ONE-*" && ok "ignored_entry undated" || ko "ignored_entry undated" x
ignored_entry "2026_01_01-ONE-1" "ONE-*" && ok "ignored_entry dated" || ko "ignored_entry dated" x
ignored_entry "2026_01_01-ONE-1" "2026_*" && ok "ignored_entry full name" || ko "ignored_entry full name" x
ignored_entry "2026_01_01-TWO" "ONE-*" && ko "ignored_entry other name" x || ok "ignored_entry other name"
ignored_entry "2026-01-01-ONE-1" "ONE-*" && ko "ignored_entry other date form" x || ok "ignored_entry other date form"
eq "stop_context with jq" "$(stop_context 'a "b"')" '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"a \"b\""}}'
eq "stop_context with python3" "$(PATH=$NOJQ stop_context 'a "b"')" "$(stop_context 'a "b"')"
finish
