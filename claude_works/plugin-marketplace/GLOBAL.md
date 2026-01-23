# Plugin Marketplace - Global Context

## Overview

Convert dotclaude to Claude Code plugin marketplace format to enable easy installation via `/plugin install dotclaude`.

## Architecture Decisions

### AD-1: Directory Structure Strategy

**Decision**: Create `.claude-plugin/` directory at repository root alongside existing `.claude/` directory.

**Rationale**:
- Plugin marketplace expects `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json`
- Existing `.claude/` structure remains for manual installation compatibility
- Skills referenced from `plugin.json` point to existing `.claude/skills/`

**Structure**:
```
dotclaude/
├── .claude-plugin/              # NEW: Plugin marketplace metadata
│   ├── marketplace.json         # Registry metadata
│   └── plugin.json              # Plugin configuration
├── hooks/                       # NEW: Plugin-compatible hooks
│   └── hooks.json               # Hook definitions with ${CLAUDE_PLUGIN_ROOT}
├── .claude/                     # EXISTING: Manual installation support
│   ├── settings.json            # Local settings (unchanged)
│   ├── hooks/                   # Hook scripts (unchanged)
│   ├── skills/                  # Skills (unchanged)
│   ├── agents/                  # Agents (unchanged)
│   └── templates/               # Templates (unchanged)
└── .dotclaude-manifest.json     # EXISTING: Manual update tracking
```

### AD-2: Dual Hook Configuration

**Decision**: Maintain two hook configuration paths:

1. `.claude/settings.json` - For manual installation (relative paths)
2. `hooks/hooks.json` - For plugin installation (`${CLAUDE_PLUGIN_ROOT}` paths)

**Rationale**:
- `${CLAUDE_PLUGIN_ROOT}` is only available when installed via plugin marketplace
- Manual installation (`cp -r .claude`) still needs relative paths
- Both configurations reference the same hook scripts

**Implementation**:
- `.claude/settings.json` keeps existing relative paths: `.claude/hooks/check-validation-complete.sh`
- `hooks/hooks.json` uses plugin-aware paths: `${CLAUDE_PLUGIN_ROOT}/.claude/hooks/check-validation-complete.sh`

### AD-3: Skills Path Reference

**Decision**: `plugin.json` skills field points to `.claude/skills/`.

**Rationale**:
- Keeps existing skills structure intact
- No file reorganization required
- Reference implementation (oh-my-claudecode) uses similar pattern

### AD-4: Version Management

**Decision**: Keep both `plugin.json` version and `.dotclaude-manifest.json` version synchronized.

**Rationale**:
- `plugin.json` version used by marketplace
- `.dotclaude-manifest.json` version used by `/dotclaude:update` skill
- Both need to match for consistency

### AD-5: Update Skill Modification

**Decision**: Modify `/dotclaude:update` skill to detect plugin vs manual installation and warn accordingly.

**Rationale**:
- Plugin-installed users should use marketplace update mechanism
- Manual-installed users continue using `/dotclaude:update`
- Detection via environment variable check or file presence

---

## Phase Summary

| Phase | Description | Files Modified |
|-------|-------------|----------------|
| 1 | Create plugin marketplace structure | NEW: `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `hooks/hooks.json` |
| 2 | Update documentation and skills | MODIFY: `README.md`, `.claude/skills/dotclaude/update/SKILL.md`, `.dotclaude-manifest.json` |

---

## Dependency Analysis

### File-Level Dependencies

| Phase | Creates/Modifies | Depends On |
|-------|------------------|------------|
| 1 | `.claude-plugin/*`, `hooks/hooks.json` | None (new files) |
| 2 | `README.md`, `SKILL.md`, manifest | Phase 1 structure must exist |

### Module-Level Dependencies

- Phase 2 documentation references Phase 1 file structure
- No code import dependencies (markdown/json only)

### Test-Level Dependencies

- No automated tests for this change
- Manual verification via plugin installation

**Conclusion**: Phases are SEQUENTIAL due to documentation dependency on Phase 1 structure.

---

## File Mapping

### New Files (Phase 1)

| File | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Plugin registry metadata (name, description, author, etc.) |
| `.claude-plugin/plugin.json` | Plugin configuration (version, skills path) |
| `hooks/hooks.json` | Plugin-compatible hook definitions |

### Modified Files (Phase 2)

| File | Change |
|------|--------|
| `README.md` | Add plugin installation instructions |
| `.claude/skills/dotclaude/update/SKILL.md` | Add plugin installation detection and warning |
| `.dotclaude-manifest.json` | Add new files to managed_files, update version to 0.1.0 |

---

## Edge Cases

| Case | Handling |
|------|----------|
| User has both plugin and manual installation | Undefined - document as unsupported |
| Plugin uninstall leaves settings.json hooks | Document that hooks remain but don't execute |
| Version mismatch between plugin.json and manifest | Validate during release, not runtime |

---

## Out of Scope (Per SPEC)

- npm package distribution
- Global vs project installation options
- Automatic version update notifications
- Plugin marketplace registration process

---

## Success Criteria

1. `.claude-plugin/` directory structure passes marketplace schema validation
2. `hooks/hooks.json` correctly uses `${CLAUDE_PLUGIN_ROOT}` variable
3. Manual installation continues to work (backward compatible)
4. README clearly documents both installation methods
5. `/dotclaude:update` warns when used in plugin-installed environment
