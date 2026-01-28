# Configure Command - Global Documentation

## Feature Overview

**Purpose**: Enable users to configure dotclaude settings interactively at global and local scopes

**Problem**: Current implementation uses hard-coded values (e.g., `claude_works/` for working directory, `main` for base branch). Users cannot customize these settings without modifying plugin source code.

**Solution**: Add `/dotclaude:configure` command with interactive workflow that manages JSON configuration files at two scopes:
- Global: `~/.claude/dotclaude-config.json` (applies to all projects)
- Local: `<project_root>/.claude/dotclaude-config.json` (project-specific overrides)

All skills load configuration with merge strategy (local overrides global, defaults applied for missing keys).

---

## Architecture Decision

### Decision 1: Configuration File Format
**Options Considered**:
1. JSON files - Simple, universally supported, easy to edit manually
2. YAML files - More human-readable but requires parser
3. Shell script with variables - Bash-native but harder to parse from other contexts

**Decision**: Option 1 (JSON)

**Rationale**:
- JSON is simple and universally supported
- Easy to parse with jq in bash hooks and skills
- No additional dependencies
- Consistent with Claude Code's ecosystem

### Decision 2: Configuration Loading Strategy
**Options Considered**:
1. Load config once per session and cache
2. Load config on every skill invocation
3. Hybrid: load on session start + reload on configure command

**Decision**: Option 2 (Load on every skill invocation)

**Rationale**:
- Configuration changes take effect immediately
- No cache invalidation complexity
- Minimal performance impact (config files are small)
- Simpler implementation

### Decision 3: Working Directory Migration
**Options Considered**:
1. Auto-migrate existing files when working_directory changes
2. Prompt user: migrate or start fresh
3. Reject directory change if files exist

**Decision**: Option 2 (Prompt user)

**Rationale**:
- Gives user control over migration
- Prevents accidental data loss
- Allows users to keep old directory for reference

---

## Data Model

### Configuration Schema
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
```

### Configuration Merge Logic
```
Final Config = DefaultValues
             + GlobalConfig (override defaults)
             + LocalConfig (override global)
```

### File Locations
- Global: `~/.claude/dotclaude-config.json`
- Local: `<git_root>/.claude/dotclaude-config.json`

---

## File Structure

### Files to Create
```
dotclaude/
├── commands/
│   └── configure.md                    # Command entry point
├── skills/
│   └── configure/
│       └── SKILL.md                    # Configure skill implementation
└── hooks/
    └── init-config.sh                  # SessionStart hook: create default config
```

### Files to Modify
```
hooks/hooks.json                        # Add SessionStart hook for init-config.sh

# Skills to update with config loading pattern:
skills/start-new/SKILL.md               # Replace claude_works/ with {working_directory}
skills/start-new/init-feature.md        # Replace claude_works/ with {working_directory}
skills/start-new/init-bugfix.md         # Replace claude_works/ with {working_directory}
skills/start-new/init-refactor.md       # Replace claude_works/ with {working_directory}
skills/design/SKILL.md                  # Replace claude_works/ with {working_directory}
skills/code/SKILL.md                    # Replace claude_works/ with {working_directory}
skills/update-docs/SKILL.md             # Replace claude_works/ with {working_directory}
skills/validate-spec/SKILL.md           # Replace claude_works/ with {working_directory}
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Configuration Infrastructure | 🟢 Complete | - |
| 2 | Skill Migration | 🟢 Complete | Phase 1 |
| 3 | Documentation | 🟢 Complete | Phase 2 |

**Status Legend**:
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Complete
- ⚠️ Blocked

---

## Phase Dependencies

```
Phase 1 ──→ Phase 2 ──→ Phase 3
```

All phases are sequential:
1. First establish configuration infrastructure
2. Then migrate existing skills to use configuration
3. Finally update documentation

---

## Risk Mitigation

### Risk 1: Invalid JSON Breaking All Skills
**Impact**: High
**Mitigation**:
- All config loading includes error handling
- Invalid JSON falls back to defaults with error message
- Skills continue execution with default values

### Risk 2: Permission Denied on Config Files
**Impact**: Medium
**Mitigation**:
- Check file permissions before reading/writing
- Show clear error messages
- Gracefully fall back to defaults on read errors

### Risk 3: Working Directory Migration Data Loss
**Impact**: High
**Mitigation**:
- Always prompt user before moving files
- Validate paths before migration
- Reject dangerous paths (absolute, parent traversal)

---

## Completion Criteria

Overall feature is complete when:
- [x] All phases marked 🟢 Complete
- [x] `/dotclaude:configure` command works for global and local scopes
- [x] All five settings are configurable
- [x] Local config correctly overrides global config
- [x] SessionStart hook creates default global config
- [x] All skills use `{working_directory}` from config instead of hard-coded `claude_works/`
- [x] Working directory migration prompts user when changing with existing files
- [x] Invalid JSON config falls back to defaults without breaking skills
- [x] README.md includes configuration section
- [x] CHANGELOG.md includes v0.2.0 entry

---

## Next Steps

1. ✅ Phase 1: Create configuration infrastructure (Complete)
2. ✅ Phase 2: Update existing skills to use configuration (Complete)
3. ✅ Phase 3: Update documentation (Complete)

All phases complete. Ready for commit and merge.
