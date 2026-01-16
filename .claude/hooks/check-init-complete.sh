#!/bin/bash
# Skill-scoped Stop hook for init-xxx skills
# Ensures branch creation and SPEC.md exist before stopping
# Uses JSON output for proper block behavior

BRANCH=$(git branch --show-current 2>/dev/null)

# On main/master - block only if there's uncommitted SPEC.md (work in progress without branch)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  # Check for uncommitted SPEC.md files in claude_works
  if git status --porcelain claude_works/*/SPEC.md 2>/dev/null | grep -q .; then
    cat << 'EOF'
{"decision": "block", "reason": "Work branch not created. Run: git checkout -b {type}/{keyword}"}
EOF
    exit 0
  fi
  # All committed - allow (completed work or nothing started)
  exit 0
fi

# On work branch - check SPEC.md exists
if [[ "$BRANCH" =~ ^(feature|bugfix|refactor)/ ]]; then
  if ! ls claude_works/*/SPEC.md 1>/dev/null 2>&1; then
    cat << 'EOF'
{"decision": "block", "reason": "SPEC.md not found. Create SPEC.md in claude_works/{subject}/ before stopping."}
EOF
    exit 0
  fi
fi

# All conditions met - allow stop
exit 0
