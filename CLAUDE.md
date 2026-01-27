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

- `commands/*.md` - Thin wrappers for autocomplete
- `skills/*/SKILL.md` - Full implementation details

When invoked via `/dotclaude:*`, Claude reads the command file which directs to the corresponding SKILL.md.

## Version Management

### Version Files

These files contain version information and must stay in sync:
- `.claude-plugin/plugin.json` → `"version": "X.Y.Z"`
- `.claude-plugin/marketplace.json` → `"version": "X.Y.Z"`
- `CHANGELOG.md` → `## [X.Y.Z] - YYYY-MM-DD`

### Version Update Rules

**CRITICAL**: Do NOT modify version numbers in `plugin.json` or `marketplace.json` during:
- `/dotclaude:code` phase (implementation)
- `/dotclaude:update-docs` phase (documentation)

Version updates should ONLY happen at release time (tagging phase).

### Workflow

1. **During development**: Keep version files unchanged
2. **At release**: Update all three files to the new version, then tag

## Version Tagging Checklist

**BEFORE creating a git tag**, verify version consistency across all files:

```bash
# Check all three files have matching versions
grep '"version"' .claude-plugin/plugin.json
grep '"version"' .claude-plugin/marketplace.json
head -20 CHANGELOG.md | grep '## \['
```

All three must show the same version:
- `.claude-plugin/plugin.json` → `"version": "X.Y.Z"`
- `.claude-plugin/marketplace.json` → `"version": "X.Y.Z"`
- `CHANGELOG.md` → `## [X.Y.Z] - YYYY-MM-DD`

Only after verification, create the tag:
```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```
