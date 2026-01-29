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

# --- Language Resolution (read-only) ---
LANGUAGE="en_US"

# Determine local config path from git root (if in a git repo)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
LOCAL_CONFIG=""
if [ -n "$GIT_ROOT" ]; then
  LOCAL_CONFIG="$GIT_ROOT/.claude/dotclaude-config.json"
fi

# Helper: extract language from a config file
# Sets LANGUAGE if extraction succeeds; keeps current value otherwise.
_resolve_language() {
  local config_file="$1"
  [ -f "$config_file" ] || return 0

  if command -v jq >/dev/null 2>&1; then
    # jq available: validate JSON first, then extract
    if jq empty "$config_file" 2>/dev/null; then
      local val
      val=$(jq -r '.language // empty' "$config_file" 2>/dev/null)
      if [ -n "$val" ]; then
        LANGUAGE="$val"
      fi
    fi
  else
    # Fallback: grep/sed for simple flat JSON
    local val
    val=$(grep -o '"language"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" 2>/dev/null \
        | sed 's/.*"language"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null)
    if [ -n "$val" ]; then
      LANGUAGE="$val"
    fi
  fi
}

# Read global config first (lower priority)
_resolve_language "$GLOBAL_CONFIG"

# Read local config second (higher priority, overrides global)
if [ -n "$LOCAL_CONFIG" ]; then
  _resolve_language "$LOCAL_CONFIG"
fi

echo "[dotclaude] language: $LANGUAGE"

exit 0
