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
