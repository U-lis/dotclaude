#!/bin/bash
# Stop hook: Warn if code changes exist with unchecked PHASE_*_PLAN items
# Part of mandatory-validation feature

BRANCH=$(git branch --show-current 2>/dev/null)

# Only check on feature/bugfix/refactor branches
if [[ ! "$BRANCH" =~ ^(feature|bugfix|refactor)/ ]]; then
  exit 0
fi

# Extract subject from branch name (e.g., feature/configure-command -> configure-command)
SUBJECT="${BRANCH#*/}"

if [[ -z "$SUBJECT" ]]; then
  exit 0
fi

# Check for uncommitted code changes
# Exclude: working directories, .md files, config directories, plugin cache
CODE_CHANGES=$(git status --porcelain \
  | grep -v "claude_works/" \
  | grep -v "\.dc_workspace/" \
  | grep -v "^.. \.claude/" \
  | grep -v "^.. dotclaude/" \
  | grep -v "\.md$" \
  | head -1)

if [[ -z "$CODE_CHANGES" ]]; then
  # No code changes - allow stop
  exit 0
fi

# Load working_directory from config
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"
LOCAL_CONFIG="$GIT_ROOT/.claude/dotclaude-config.json"

WORKING_DIR=".dc_workspace"  # default

# Load local config first (overrides global)
if [ -f "$LOCAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // ".dc_workspace"' "$LOCAL_CONFIG" 2>/dev/null || echo ".dc_workspace")
elif [ -f "$GLOBAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // ".dc_workspace"' "$GLOBAL_CONFIG" 2>/dev/null || echo ".dc_workspace")
fi

# Check for unchecked items in PHASE_*_PLAN files for CURRENT BRANCH SUBJECT ONLY
# Check configured working_directory
UNCHECKED=$(grep -l '^\- \[ \]' "$WORKING_DIR/$SUBJECT"/PHASE_*_PLAN_*.md 2>/dev/null | head -1)

# Also check legacy claude_works/ for backward compatibility
if [[ -z "$UNCHECKED" ]] && [[ "$WORKING_DIR" != "claude_works" ]]; then
  UNCHECKED=$(grep -l '^\- \[ \]' "claude_works/$SUBJECT"/PHASE_*_PLAN_*.md 2>/dev/null | head -1)
fi

if [[ -n "$UNCHECKED" ]]; then
  cat << 'EOF'
{"decision": "block", "reason": "Code changes detected but PHASE_*_PLAN.md has unchecked items. Run code-validator to update checklists before stopping."}
EOF
  exit 0
fi

# All checks passed
exit 0
