# Commands Autocomplete - Global Documentation

## Feature Overview

**Purpose**: Enable autocomplete support for dotclaude skills in Claude Code CLI

**Problem**: dotclaude plugin skills (dc:start-new, dc:design, etc.) do not appear in autocomplete when typing `/` in Claude Code, while other plugins like claude-hud work correctly.

**Solution**: Add `commands/` directory structure that Claude Code recognizes for autocomplete, while maintaining existing `skills/` structure for internal logic.

## Root Cause

Claude Code only exposes commands from `commands/*.md` files for autocomplete. The current dotclaude structure uses `skills/*/SKILL.md` which works for direct invocation but is not recognized by the autocomplete system.

## Architecture Decision

### Dual Directory Structure

Maintain both directories with clear separation of concerns:

| Directory | Purpose | Autocomplete |
|-----------|---------|--------------|
| `commands/` | Entry points for autocomplete | Yes |
| `skills/` | Full skill logic and instructions | No (internal) |

### Command File Pattern

Each command file in `commands/` serves as a thin wrapper that:
1. Provides `description` for autocomplete display
2. Points to the corresponding skill directory
3. Instructs Claude to read and follow the SKILL.md

### Naming Convention

- Command files: `commands/dc:{skill-name}.md` (includes `dc:` prefix for namespace)
- SKILL.md name field: `name: {skill-name}` (without `dc:` prefix to avoid duplication)

## Data Model

### Command File Format

```yaml
---
description: {skill description from SKILL.md}
---
Base directory for this skill: skills/{skill-name}

Read skills/{skill-name}/SKILL.md and follow its instructions.
```

### SKILL.md Name Field Change

Before: `name: dc:start-new`
After: `name: start-new`

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Create 7 command files in `commands/` directory | Pending | None |
| 2 | Update SKILL.md files + Create CLAUDE.md | Pending | Phase 1 |

## File Structure

### New Files (Phase 1)

```
commands/                          # NEW directory
├── dc:start-new.md
├── dc:design.md
├── dc:code.md
├── dc:merge-main.md
├── dc:tagging.md
├── dc:update-docs.md
└── dc:validate-spec.md
```

### Modified Files (Phase 2)

```
skills/
├── start-new/SKILL.md            # name: dc:start-new → start-new
├── design/SKILL.md               # name: dc:design → design
├── code/SKILL.md                 # name: dc:code → code
├── merge-main/SKILL.md           # name: dc:merge-main → merge-main
├── tagging/SKILL.md              # name: dc:tagging → tagging
├── update-docs/SKILL.md          # name: dc:update-docs → update-docs
└── validate-spec/SKILL.md        # name: dc:validate-spec → validate-spec

CLAUDE.md                          # NEW - development guidelines
```

## Verification Method

Manual verification via plugin reinstall:
1. Reinstall plugin: `/plugin install dotclaude` (or reinstall from path)
2. Type `/` in Claude Code
3. Verify all 7 `dc:` commands appear in autocomplete
4. Test `/dc:start-new` invocation to confirm functionality

## Constraints

- Do NOT modify `.claude-plugin/plugin.json`
- Do NOT change skill behavior or logic
- Command files must be minimal wrappers only
