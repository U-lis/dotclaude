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
├── templates/          # Document templates (SPEC, GLOBAL, PHASE_*)
├── hooks/              # Hook scripts and hooks.json
├── docs/               # ARCHITECTURE.md, AGENT_MODEL_GUIDE.md
├── {working_directory}/ # Working documents (configurable, default: .dc_workspace)
└── .claude-plugin/     # Plugin configuration
```

## Command Structure

- `commands/*.md` - Self-contained command files with full implementation
  - User-invocable commands: appear in slash menu (default)
  - Internal commands: `user-invocable: false` in frontmatter (Claude-only)
- `agents/*.md` - Agent definitions. Frontmatter has `name`, `model` (a family alias), `description`, and an optional `tools` list. Invoked via `dotclaude:{agent-name}`; coders via `dotclaude:coders:coder-{language}`

When invoked via `/dotclaude:*`, Claude reads the command file and follows its instructions directly.

## Prompt hygiene

- Shared rules live only in `commands/_contract.md`. Other files reference them by section name and do not restate them.
- Run `scripts/lint-prompts.sh` before committing prompt changes.

## Version Management

### Version Files

Version files are configurable per-project via `dotclaude-config.json`.

When `version_files` is configured, those files are checked.
When not configured, common version files are auto-detected
(CHANGELOG.md, package.json, pyproject.toml, Cargo.toml, pom.xml,
.claude-plugin/plugin.json, .claude-plugin/marketplace.json).

CHANGELOG.md is always mandatory and cannot be removed.

Configure version files via `/dotclaude:configure` (Setting 4)
or edit `dotclaude-config.json` directly.

### Version Update Rules

**CRITICAL**: Do NOT modify version numbers in version files during:
- `/dotclaude:code` phase (implementation)
- `/dotclaude:update-docs` phase (documentation)

Version updates should ONLY happen at release time (tagging phase).

### Workflow

1. **During development**: Keep version files unchanged
2. **At release**: Update all version files to the new version, then tag

## Version Tagging Checklist

**BEFORE creating a git tag**, verify version consistency using `/dotclaude:tagging`.

The tagging command automatically:
1. Resolves the version files list (from config or auto-detection)
2. Checks all version files for consistency
3. Reports any mismatches before proceeding

For manual verification, check all configured version files match.
See `/dotclaude:configure` Setting 4 to view which files are checked.

Only after verification, create the tag:
```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```
