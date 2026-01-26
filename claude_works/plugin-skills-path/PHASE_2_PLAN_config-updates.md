# Phase 2: Configuration Updates

## Objective

Update all configuration files to reflect the new directory structure after migration.

## Prerequisites

- Phase 1 completed (directories moved)
- All moves staged with `git mv`

## Files Affected

| File | Type of Change |
|------|----------------|
| `.claude-plugin/plugin.json` | Remove field, bump version |
| `hooks/hooks.json` | Update 2 command paths |
| `.claude/settings.json` | Update 1 command path |
| `.dotclaude-manifest.json` | Update 28 file paths |

## Instructions

### Step 1: Update plugin.json

**File**: `.claude-plugin/plugin.json`

**Before**:
```json
{
  "name": "dotclaude",
  "version": "0.1.0",
  "description": "Structured development workflow orchestration for Claude Code",
  "skills": ".claude/skills/"
}
```

**After**:
```json
{
  "name": "dotclaude",
  "version": "0.1.1",
  "description": "Structured development workflow orchestration for Claude Code"
}
```

**Changes**:
1. Remove `"skills": ".claude/skills/"` line entirely (Claude Code auto-discovers skills)
2. Bump version from `0.1.0` to `0.1.1`

### Step 2: Update hooks/hooks.json

**File**: `hooks/hooks.json`

**Before**:
```json
{
  "description": "dotclaude hooks - update check and validation enforcement",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-update.sh",
            "timeout": 5
          }
        ]
      }
    ],
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

**After**:
```json
{
  "description": "dotclaude hooks - update check and validation enforcement",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-update.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

**Changes**:
1. Line 9: `${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-update.sh` -> `${CLAUDE_PLUGIN_ROOT}/hooks/check-update.sh`
2. Line 20: `${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-validation-complete.sh` -> `${CLAUDE_PLUGIN_ROOT}/hooks/check-validation-complete.sh`

### Step 3: Update .claude/settings.json

**File**: `.claude/settings.json`

**Before**:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

**After**:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

**Changes**:
1. Line 8: `.claude/hooks/check-validation-complete.sh` -> `hooks/check-validation-complete.sh`

### Step 4: Update .dotclaude-manifest.json

**File**: `.dotclaude-manifest.json`

**Before**:
```json
{
  "version": "0.1.0",
  "managed_files": [
    ".claude-plugin/marketplace.json",
    ".claude-plugin/plugin.json",
    "hooks/hooks.json",
    ".claude/agents/code-validator.md",
    ".claude/agents/coders/_base.md",
    ".claude/agents/coders/javascript.md",
    ".claude/agents/coders/python.md",
    ".claude/agents/coders/rust.md",
    ".claude/agents/coders/sql.md",
    ".claude/agents/coders/svelte.md",
    ".claude/agents/designer.md",
    ".claude/agents/spec-validator.md",
    ".claude/agents/technical-writer.md",
    ".claude/hooks/check-update.sh",
    ".claude/hooks/check-validation-complete.sh",
    ".claude/settings.json",
    ".claude/skills/code/SKILL.md",
    ".claude/skills/design/SKILL.md",
    ".claude/skills/merge-main/SKILL.md",
    ".claude/skills/start-new/SKILL.md",
    ".claude/skills/start-new/_analysis.md",
    ".claude/skills/start-new/init-bugfix.md",
    ".claude/skills/start-new/init-feature.md",
    ".claude/skills/start-new/init-refactor.md",
    ".claude/skills/tagging/SKILL.md",
    ".claude/skills/update-docs/SKILL.md",
    ".claude/skills/validate-spec/SKILL.md",
    ".claude/templates/GLOBAL.md",
    ".claude/templates/PHASE_MERGE.md",
    ".claude/templates/PHASE_PLAN.md",
    ".claude/templates/PHASE_TEST.md",
    ".claude/templates/SPEC.md"
  ],
  "merge_files": [
    ".claude/settings.json"
  ]
}
```

**After**:
```json
{
  "version": "0.1.1",
  "managed_files": [
    ".claude-plugin/marketplace.json",
    ".claude-plugin/plugin.json",
    "hooks/hooks.json",
    "hooks/check-update.sh",
    "hooks/check-validation-complete.sh",
    "agents/code-validator.md",
    "agents/coders/_base.md",
    "agents/coders/javascript.md",
    "agents/coders/python.md",
    "agents/coders/rust.md",
    "agents/coders/sql.md",
    "agents/coders/svelte.md",
    "agents/designer.md",
    "agents/spec-validator.md",
    "agents/technical-writer.md",
    "skills/code/SKILL.md",
    "skills/design/SKILL.md",
    "skills/merge-main/SKILL.md",
    "skills/start-new/SKILL.md",
    "skills/start-new/_analysis.md",
    "skills/start-new/init-bugfix.md",
    "skills/start-new/init-feature.md",
    "skills/start-new/init-refactor.md",
    "skills/tagging/SKILL.md",
    "skills/update-docs/SKILL.md",
    "skills/validate-spec/SKILL.md",
    "templates/GLOBAL.md",
    "templates/PHASE_MERGE.md",
    "templates/PHASE_PLAN.md",
    "templates/PHASE_TEST.md",
    "templates/SPEC.md",
    ".claude/settings.json"
  ],
  "merge_files": [
    ".claude/settings.json"
  ]
}
```

**Changes**:
1. Update `version` from `0.1.0` to `0.1.1`
2. Replace all `.claude/agents/` paths with `agents/`
3. Replace all `.claude/skills/` paths with `skills/`
4. Replace all `.claude/templates/` paths with `templates/`
5. Replace `.claude/hooks/check-update.sh` with `hooks/check-update.sh`
6. Replace `.claude/hooks/check-validation-complete.sh` with `hooks/check-validation-complete.sh`
7. Move `.claude/settings.json` to end of managed_files (remains unchanged as path)
8. Keep `merge_files` unchanged (`.claude/settings.json` is still in `.claude/`)

## Completion Checklist

- [ ] `.claude-plugin/plugin.json`: `skills` field removed
- [ ] `.claude-plugin/plugin.json`: version bumped to `0.1.1`
- [ ] `hooks/hooks.json`: SessionStart hook path updated
- [ ] `hooks/hooks.json`: Stop hook path updated
- [ ] `.claude/settings.json`: hook command path updated
- [ ] `.dotclaude-manifest.json`: version bumped to `0.1.1`
- [ ] `.dotclaude-manifest.json`: all 28 managed file paths updated
- [ ] All JSON files remain valid (no syntax errors)

## Validation Criteria

1. **JSON Validity**: All modified JSON files parse without errors
   ```bash
   jq . .claude-plugin/plugin.json
   jq . hooks/hooks.json
   jq . .claude/settings.json
   jq . .dotclaude-manifest.json
   ```

2. **Path Consistency**: No paths contain `.claude/skills/`, `.claude/agents/`, `.claude/templates/`, or `.claude/hooks/` (except `.claude/settings.json`)

3. **Version Consistency**: Both `plugin.json` and `.dotclaude-manifest.json` show version `0.1.1`

## Notes

- The `.claude/settings.json` file path in `merge_files` remains unchanged because this file stays in `.claude/` directory
- Only the internal command path within `.claude/settings.json` is updated
- Do NOT commit at this phase; continue to Phase 3
