# Phase 2: SKILLMD

## Objective

Update all SKILL.md files to remove `dc:` prefix from name field, and create CLAUDE.md for development guidelines.

## Prerequisites

- Phase 1 completed (commands/ directory exists)

## Instructions

### Part A: Update SKILL.md Files

Update the `name` field in all 7 SKILL.md files to remove the `dc:` prefix.

#### File: skills/start-new/SKILL.md

Change frontmatter from:
```yaml
---
name: dc:start-new
description: Entry point for starting new work...
user-invocable: true
---
```

To:
```yaml
---
name: start-new
description: Entry point for starting new work...
user-invocable: true
---
```

#### File: skills/design/SKILL.md

Change `name: dc:design` to `name: design`

#### File: skills/code/SKILL.md

Change `name: dc:code` to `name: code`

#### File: skills/merge-main/SKILL.md

Change `name: dc:merge-main` to `name: merge-main`

#### File: skills/tagging/SKILL.md

Change `name: dc:tagging` to `name: tagging`

#### File: skills/update-docs/SKILL.md

Change `name: dc:update-docs` to `name: update-docs`

#### File: skills/validate-spec/SKILL.md

Change `name: dc:validate-spec` to `name: validate-spec`

### Part B: Create CLAUDE.md

Create `CLAUDE.md` at repository root with development guidelines to prevent confusion between local development files and installed plugin files.

#### File: CLAUDE.md

```markdown
# dotclaude Development Guidelines

## Important: Local vs Installed Plugin

When developing dotclaude, distinguish between:

| Location | Purpose | Action |
|----------|---------|--------|
| Current repo (`/path/to/dotclaude/`) | Development source | MODIFY these files |
| Installed plugin (`~/.claude/plugins/cache/...`) | Cached installation | NEVER modify |

## Development Rules

1. **Always modify source files in this repository**
   - Edit files under `skills/`, `commands/`, `agents/`, etc.
   - These are the source of truth

2. **Never modify installed plugin files**
   - Files in `~/.claude/plugins/cache/` are read-only copies
   - Changes there will be lost on plugin update/reinstall

3. **Testing changes**
   - After modifying source files, reinstall the plugin
   - Use `/plugin install` with local path or plugin name

## Directory Structure

```
dotclaude/
├── commands/           # Autocomplete entry points
├── skills/             # Full skill logic
├── agents/             # Agent definitions
├── claude_works/       # Work-in-progress documentation
└── .claude-plugin/     # Plugin configuration
```

## Skill vs Command

- `commands/dc:*.md` - Thin wrappers for autocomplete
- `skills/*/SKILL.md` - Full implementation details

When invoked via `/dc:*`, Claude reads the command file which directs to the corresponding SKILL.md.
```

## Completion Checklist

### SKILL.md Updates
- [ ] `skills/start-new/SKILL.md` - name changed to `start-new`
- [ ] `skills/design/SKILL.md` - name changed to `design`
- [ ] `skills/code/SKILL.md` - name changed to `code`
- [ ] `skills/merge-main/SKILL.md` - name changed to `merge-main`
- [ ] `skills/tagging/SKILL.md` - name changed to `tagging`
- [ ] `skills/update-docs/SKILL.md` - name changed to `update-docs`
- [ ] `skills/validate-spec/SKILL.md` - name changed to `validate-spec`

### CLAUDE.md Creation
- [ ] `CLAUDE.md` created at repository root
- [ ] Contains clear distinction between source and installed files
- [ ] Contains directory structure overview
- [ ] Contains skill vs command explanation

## Notes

- The `dc:` prefix now exists ONLY in command filenames (`commands/dc:*.md`)
- SKILL.md files use plain names without prefix
- This prevents duplication in display (e.g., "dc:dc:start-new")
- CLAUDE.md helps future development by clarifying what to modify
