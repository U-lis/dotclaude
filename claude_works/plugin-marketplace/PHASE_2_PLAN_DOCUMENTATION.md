# Phase 2: Update Documentation and Skills

## Objective

Update README.md with plugin installation instructions, modify `/dotclaude:update` skill to detect plugin installation, and update manifest with new files.

## Prerequisites

- Phase 1 complete (`.claude-plugin/` and `hooks/` directories exist)

## Deliverables

### 1. Update `README.md`

Add plugin marketplace installation section. Insert **before** the existing manual installation instructions.

**Add section**:

```markdown
## Installation

### Option 1: Plugin Marketplace (Recommended)

Install dotclaude via Claude Code's plugin marketplace:

```bash
# Add the marketplace repository (first time only)
/plugin marketplace add https://github.com/U-lis/dotclaude

# Install the plugin
/plugin install dotclaude
```

### Option 2: Manual Installation

For direct control or customization, clone and copy manually:

```bash
git clone https://github.com/U-lis/dotclaude.git
cp -r dotclaude/.claude your-project/
cp dotclaude/.dotclaude-manifest.json your-project/
```

**Note**: Manual installation requires the `/dotclaude:update` skill for updates. Plugin installation uses the marketplace update mechanism.
```

**Modify existing content**:
- Remove or consolidate existing installation instructions
- Keep `/dotclaude:version` and `/dotclaude:update` documentation but note plugin vs manual difference

### 2. Update `.claude/skills/dotclaude/update/SKILL.md`

Add plugin installation detection at the beginning of execution.

**Add Step 0 before Step 1**:

```markdown
### Step 0: Check Installation Type

Detect if running in plugin-installed environment:

```bash
# Check if CLAUDE_PLUGIN_ROOT environment variable is set
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  # Plugin installation detected
  echo "Plugin installation detected."
fi
```

**If plugin installation detected:**

Display message and stop:

```markdown
## Plugin Installation Detected

dotclaude is installed via the plugin marketplace.

To update, use the plugin marketplace commands:
```
/plugin update dotclaude
```

The `/dotclaude:update` skill is only for manual installations.
```

**If manual installation:** Proceed with existing Step 1 onwards.
```

### 3. Update `.dotclaude-manifest.json`

Add new files to `managed_files` and update version.

**Changes**:
1. Update `"version": "0.0.10"` to `"version": "0.1.0"`
2. Add to `managed_files` array:
   - `.claude-plugin/marketplace.json`
   - `.claude-plugin/plugin.json`
   - `hooks/hooks.json`

**Result structure**:
```json
{
  "version": "0.1.0",
  "managed_files": [
    ".claude-plugin/marketplace.json",
    ".claude-plugin/plugin.json",
    "hooks/hooks.json",
    ".claude/agents/code-validator.md",
    ... (existing files)
  ],
  "merge_files": [
    ".claude/settings.json"
  ]
}
```

---

## Checklist

### README.md Updates
- [x] Add "Installation" section with two options
- [x] Option 1: Plugin marketplace commands (`/plugin marketplace add`, `/plugin install`)
- [x] Option 2: Manual installation (existing `git clone` + `cp` commands)
- [x] Add note explaining difference between plugin and manual update methods
- [x] Remove duplicate/outdated installation instructions if any

### SKILL.md Updates
- [x] Add Step 0: Check Installation Type
- [x] Add `CLAUDE_PLUGIN_ROOT` environment check
- [x] Add user-friendly message explaining plugin update path
- [x] Ensure existing workflow (Steps 1-12) unchanged for manual installations

### Manifest Updates
- [x] Update version from "0.0.10" to "0.1.0"
- [x] Add `.claude-plugin/marketplace.json` to managed_files
- [x] Add `.claude-plugin/plugin.json` to managed_files
- [x] Add `hooks/hooks.json` to managed_files
- [x] Preserve all existing entries in managed_files
- [x] Preserve merge_files array unchanged

### Verification
- [x] README installation instructions are clear and complete
- [x] SKILL.md gracefully handles both installation types
- [x] Manifest JSON is valid
- [x] All new Phase 1 files are in manifest

---

## Notes

- The version bump to 0.1.0 reflects the significant feature addition (plugin support)
- Plugin users will see a clear message redirecting them to marketplace update
- Manual installation users see no change in workflow

---

## Dependencies

- Phase 1: Requires `.claude-plugin/` and `hooks/` structure to exist

## Blocks

- None (final phase)
