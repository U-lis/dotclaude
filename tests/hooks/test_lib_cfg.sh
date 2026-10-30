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
finish
