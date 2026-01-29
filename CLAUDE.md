# dotclaude Development Guidelines

## Important: Local vs Installed Plugin

When developing dotclaude, distinguish between:

| Location | Purpose | Action |
|----------|---------|--------|
| Current repo (`/path/to/dotclaude/`) | Development source | MODIFY these files |
| Installed plugin (`~/.claude/plugins/cache/...`) | Cached installation | NEVER modify |

## Development Rules

1. **Always modify source files in this repository**
   - Edit files under `commands/`, `agents/`, etc.
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
├── commands/           # Self-contained command files (user-invocable + internal)
├── agents/             # Agent definitions with frontmatter
├── {working_directory}/ # Working documents (configurable, default: .dc_workspace)
└── .claude-plugin/     # Plugin configuration
```

## Command Structure

- `commands/*.md` - Self-contained command files with full implementation
  - User-invocable commands: appear in slash menu (default)
  - Internal commands: `user-invocable: false` in frontmatter (Claude-only)
- `agents/*.md` - Agent definitions with `name`/`description` frontmatter, invoked via `dotclaude:{agent-name}`

When invoked via `/dotclaude:*`, Claude reads the command file and follows its instructions directly.

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
