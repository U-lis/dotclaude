#!/bin/bash
# Skill-scoped Stop hook for init-xxx skills
# Ensures branch creation and SPEC.md exist before stopping

BRANCH=$(git branch --show-current 2>/dev/null)

# On main/master - branch not created yet
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "CONTINUE: Create work branch first (git checkout -b {type}/{keyword})"
  exit 0
fi

# On work branch - check SPEC.md exists
if [[ "$BRANCH" =~ ^(feature|bugfix|refactor)/ ]]; then
  if ! ls claude_works/*/SPEC.md 1>/dev/null 2>&1; then
    echo "CONTINUE: Create SPEC.md using TechnicalWriter before stopping"
    exit 0
  fi
fi

# All conditions met
exit 0
