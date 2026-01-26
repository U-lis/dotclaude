# Plugin Directory Structure Migration - Global Documentation

## Feature Overview

### Purpose
Migrate plugin resource directories from `.claude/` prefix to root level for a cleaner, more standard plugin structure.

### Problem
Current structure places skills, agents, templates, and hooks under `.claude/` directory, creating:
- Inconsistent path references across configuration files
- Deep nesting that complicates plugin maintenance
- Non-standard directory structure compared to typical plugin layouts

### Solution
Move all plugin resources to root-level directories:
- `.claude/skills/` to `skills/`
- `.claude/agents/` to `agents/`
- `.claude/templates/` to `templates/`
- `.claude/hooks/` to `hooks/`

Update all path references in configuration files and internal documentation.

## Architecture Decision

### Directory Structure After Migration

```
dotclaude/
├── .claude/                    # Claude Code user settings (unchanged)
│   └── settings.json           # Updated hook path reference
├── .claude-plugin/             # Plugin metadata
│   ├── plugin.json             # Remove skills field, bump version
│   └── marketplace.json        # Unchanged
├── agents/                     # MOVED from .claude/agents/
│   ├── code-validator.md
│   ├── designer.md
│   ├── spec-validator.md
│   ├── technical-writer.md
│   └── coders/
│       ├── _base.md
│       ├── javascript.md
│       ├── python.md
│       ├── rust.md
│       ├── sql.md
│       └── svelte.md
├── hooks/                      # MOVED from .claude/hooks/
│   ├── hooks.json              # Updated command paths
│   ├── check-update.sh
│   └── check-validation-complete.sh
├── skills/                     # MOVED from .claude/skills/
│   ├── code/SKILL.md
│   ├── design/SKILL.md
│   ├── merge-main/SKILL.md
│   ├── start-new/
│   │   ├── SKILL.md            # Updated agent references
│   │   ├── _analysis.md
│   │   ├── init-bugfix.md
│   │   ├── init-feature.md
│   │   └── init-refactor.md
│   ├── tagging/SKILL.md
│   ├── update-docs/SKILL.md    # Updated agent references
│   └── validate-spec/SKILL.md
├── templates/                  # MOVED from .claude/templates/
│   ├── GLOBAL.md
│   ├── PHASE_MERGE.md
│   ├── PHASE_PLAN.md
│   ├── PHASE_TEST.md
│   └── SPEC.md
└── .dotclaude-manifest.json    # Updated all file paths
```

### Key Decisions

1. **Atomic Migration**: Use `git mv` to preserve history for all moved files
2. **Single Commit**: All changes in one atomic commit for easy rollback
3. **Version Bump**: Increment patch version (0.1.0 -> 0.1.1) for this structural change
4. **Remove `skills` field from plugin.json**: Claude Code discovers skills automatically; explicit field unnecessary

## Data Model

### Configuration Files Changed

| File | Change Type | Description |
|------|-------------|-------------|
| `.claude-plugin/plugin.json` | Modify | Remove `skills` field, bump version |
| `hooks/hooks.json` | Modify | Update hook command paths |
| `.claude/settings.json` | Modify | Update hook command path |
| `.dotclaude-manifest.json` | Modify | Update all managed file paths |

### Internal References Changed

| File | Change Type | Count |
|------|-------------|-------|
| `skills/start-new/SKILL.md` | Modify | 4 agent references |
| `skills/update-docs/SKILL.md` | Modify | 1 agent reference |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Directory Migration | Pending | None |
| 2 | Configuration Updates | Pending | Phase 1 |
| 3 | Internal Path Reference Updates | Pending | Phase 1 |
| 4 | Cleanup and Verification | Pending | Phase 2, 3 |

## File Structure

### Files to MOVE (git mv)

| Source | Destination |
|--------|-------------|
| `.claude/skills/` | `skills/` |
| `.claude/agents/` | `agents/` |
| `.claude/templates/` | `templates/` |
| `.claude/hooks/check-update.sh` | `hooks/check-update.sh` |
| `.claude/hooks/check-validation-complete.sh` | `hooks/check-validation-complete.sh` |

### Files to MODIFY

| File | Changes |
|------|---------|
| `.claude-plugin/plugin.json` | Remove `skills` field, version 0.1.0 -> 0.1.1 |
| `hooks/hooks.json` | Update 2 hook command paths |
| `.claude/settings.json` | Update 1 hook command path |
| `.dotclaude-manifest.json` | Update all 28 managed file paths |
| `skills/start-new/SKILL.md` | Update 4 agent path references |
| `skills/update-docs/SKILL.md` | Update 1 agent path reference |

## Commit Strategy

**Single Atomic Commit**

Commit message:
```
fix: migrate plugin directories to root level

Move skills, agents, templates, and hooks from .claude/ prefix
to root level for cleaner plugin structure.

- Move .claude/skills/ to skills/
- Move .claude/agents/ to agents/
- Move .claude/templates/ to templates/
- Move .claude/hooks/*.sh to hooks/
- Update all path references in config files
- Remove redundant skills field from plugin.json
- Bump version to 0.1.1
```

## Validation Criteria

After all phases complete:

1. All files accessible at new paths
2. `git status` shows no unexpected changes
3. Hook scripts executable and functional
4. No broken internal references
5. Plugin loads correctly in Claude Code
