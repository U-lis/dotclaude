#!/bin/bash
# Stop hook: Warn if code changes exist with unchecked PHASE_*_PLAN items
# Part of mandatory-validation feature

BRANCH=$(git branch --show-current 2>/dev/null)

# Only check on feature/bugfix/refactor branches
if [[ ! "$BRANCH" =~ ^(feature|bugfix|refactor)/ ]]; then
  exit 0
fi

# Check for uncommitted code changes (excluding claude_works/ and .md files)
CODE_CHANGES=$(git status --porcelain | grep -v "claude_works/" | grep -v "\.md$" | head -1)

if [[ -z "$CODE_CHANGES" ]]; then
  # No code changes - allow stop
  exit 0
fi

# Code changes exist - check for unchecked items in PHASE_*_PLAN files
UNCHECKED=$(grep -l '^\- \[ \]' claude_works/*/PHASE_*_PLAN_*.md 2>/dev/null | head -1)

if [[ -n "$UNCHECKED" ]]; then
  cat << 'EOF'
{"decision": "block", "reason": "Code changes detected but PHASE_*_PLAN.md has unchecked items. Run code-validator to update checklists before stopping."}
EOF
  exit 0
fi

# All checks passed
exit 0
