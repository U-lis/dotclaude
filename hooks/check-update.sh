#!/bin/bash
# SessionStart hook: Check for dotclaude updates
# Outputs update notification if newer version available

# Get current version from plugin.json
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | cut -d'"' -f4)

if [[ -z "$CURRENT_VERSION" ]]; then
  # Can't determine current version, skip check
  exit 0
fi

# Get latest version from GitHub (with timeout)
LATEST_VERSION=$(timeout 3 git ls-remote --tags --sort=-v:refname https://github.com/U-lis/dotclaude.git 2>/dev/null | head -1 | sed 's/.*refs\/tags\/v//' | sed 's/\^{}//')

if [[ -z "$LATEST_VERSION" ]]; then
  # Can't reach GitHub, skip silently
  exit 0
fi

# Compare versions (simple string comparison works for semver)
if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" && "$CURRENT_VERSION" < "$LATEST_VERSION" ]]; then
  cat << EOF
{"notification": "dotclaude update available: v${CURRENT_VERSION} → v${LATEST_VERSION}. Run '/plugin update dotclaude' to update."}
EOF
fi

exit 0
