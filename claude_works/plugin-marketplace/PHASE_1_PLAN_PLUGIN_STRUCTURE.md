# Phase 1: Create Plugin Marketplace Structure

## Objective

Create the `.claude-plugin/` directory structure and `hooks/hooks.json` file required for Claude Code plugin marketplace compatibility.

## Prerequisites

- None (new files only)

## Deliverables

### 1. `.claude-plugin/marketplace.json`

Create marketplace registry metadata file.

**Reference**: `/tmp/oh-my-claudecode/.claude-plugin/marketplace.json`

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "dotclaude",
  "description": "Structured development workflow orchestration with phased implementation and validation",
  "owner": {
    "name": "U-lis",
    "email": "TBD"
  },
  "plugins": [
    {
      "name": "dotclaude",
      "description": "Structured development workflow with SPEC-driven design, phased implementation, and mandatory validation. Includes Designer, TechnicalWriter, and Coder agent orchestration.",
      "version": "0.1.0",
      "author": {
        "name": "U-lis",
        "email": "TBD"
      },
      "source": "./",
      "category": "productivity",
      "homepage": "https://github.com/U-lis/dotclaude",
      "tags": ["workflow", "orchestration", "spec-driven", "phased-development", "validation"]
    }
  ]
}
```

**Note**: Email TBD - use placeholder or check for existing email in repository.

### 2. `.claude-plugin/plugin.json`

Create plugin configuration file.

**Reference**: `/tmp/oh-my-claudecode/.claude-plugin/plugin.json`

```json
{
  "name": "dotclaude",
  "version": "0.1.0",
  "description": "Structured development workflow orchestration for Claude Code",
  "skills": ".claude/skills/"
}
```

### 3. `hooks/hooks.json`

Create plugin-compatible hook configuration using `${CLAUDE_PLUGIN_ROOT}` variable.

**Reference**: `/tmp/oh-my-claudecode/hooks/hooks.json`

```json
{
  "description": "dotclaude validation hooks - ensure phase checklists are completed before stopping",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

**Key Difference from `.claude/settings.json`**:
- `settings.json`: `.claude/hooks/check-validation-complete.sh` (relative)
- `hooks.json`: `${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-validation-complete.sh` (plugin-aware)

---

## Checklist

### File Creation
- [x] Create `.claude-plugin/` directory
- [x] Create `.claude-plugin/marketplace.json` with schema reference
- [x] Create `.claude-plugin/plugin.json` with skills path
- [x] Create `hooks/` directory (at repo root, not inside .claude)
- [x] Create `hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}` paths

### Content Validation
- [x] `marketplace.json` includes required fields: name, description, owner, plugins array
- [x] `plugin.json` includes required fields: name, version, description, skills
- [x] `hooks.json` uses `${CLAUDE_PLUGIN_ROOT}` prefix for script paths
- [x] Version in both files matches: "0.1.0"

### Verification
- [x] JSON files are valid (no syntax errors)
- [x] Hook script path exists: `.claude/hooks/check-validation-complete.sh`
- [x] Skills directory exists: `.claude/skills/`

---

## Notes

- The `hooks/` directory is at repository root (not `.claude/hooks/`) to match plugin marketplace convention
- Both `.claude/settings.json` (manual) and `hooks/hooks.json` (plugin) reference the same script
- The `${CLAUDE_PLUGIN_ROOT}` variable is substituted at runtime by Claude Code when plugin is installed

---

## Dependencies

- None (this is Phase 1)

## Blocks

- Phase 2: Documentation updates depend on this structure
