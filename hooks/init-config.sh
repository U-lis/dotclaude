#!/bin/bash
# SessionStart hook: Initialize default global configuration if not exists
# This hook is idempotent - safe to run multiple times

GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"

if [ ! -f "$GLOBAL_CONFIG" ]; then
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$GLOBAL_CONFIG")"

  # Create default configuration file
  cat > "$GLOBAL_CONFIG" <<'EOF'
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
EOF
fi

exit 0
