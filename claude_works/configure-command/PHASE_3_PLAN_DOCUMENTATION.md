# Phase 3: Documentation

## Objective

Update project documentation to reflect the new configuration feature. Add comprehensive configuration guide to README.md and create v0.2.0 changelog entry documenting the new feature.

---

## Prerequisites

- [x] Phase 1 completed (configuration infrastructure exists)
- [x] Phase 2 completed (skills migrated to use configuration)
- [x] Configuration feature is fully functional
- [x] Manual testing of configuration workflows completed

---

## Scope

### In Scope
- Add Configuration section to README.md
- Document all five configurable settings
- Document global vs local configuration scopes
- Document configuration file locations and format
- Provide configuration examples and use cases
- Add CHANGELOG.md entry for v0.2.0
- Document migration path from hard-coded `claude_works/` to configurable directory

### Out of Scope
- Updating version numbers in plugin.json or marketplace.json (done at release time per CLAUDE.md)
- Translating documentation to other languages
- Creating separate configuration guide document (keep in README.md)

---

## Instructions

### Step 1: Add Configuration Section to README.md

**File**: `README.md`

**Action**: Add a new section titled "## Configuration" after the Installation section and before Usage section

Section should include:

#### Subsection: Overview
- Brief explanation: dotclaude can be configured at global and local scopes
- Global: `~/.claude/dotclaude-config.json` (applies to all projects)
- Local: `<project_root>/.claude/dotclaude-config.json` (project-specific, overrides global)
- Configuration managed via `/dotclaude:configure` command

#### Subsection: Configuration Command
- How to invoke: `/dotclaude:configure`
- Interactive workflow: select scope (global/local), edit settings
- Changes take effect immediately

#### Subsection: Available Settings
Create table documenting all five settings:

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `language` | string | `en_US` | Language for conversations and generated documents (stored but not used in v0.2.0) |
| `working_directory` | string | `.dc_workspace` | Directory name for dotclaude work files (relative to project root) |
| `check_version` | boolean | `true` | Check for plugin updates on session start |
| `auto_update` | boolean | `false` | Automatically update plugin when update is available |
| `base_branch` | string | `main` | Default base branch for git operations (init, merge, PR) |

#### Subsection: Configuration File Format
Show JSON structure example:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
```

Note: Configuration files can be edited manually or via `/dotclaude:configure` command

#### Subsection: Configuration Scopes
Explain precedence:
1. Default values (hard-coded)
2. Global configuration (overrides defaults)
3. Local configuration (overrides global)

Example scenario:
- Global config sets `working_directory: "docs"`
- Local config sets `working_directory: "project_workspace"`
- Result: Project uses `project_workspace`, other projects use `docs`

#### Subsection: Working Directory Migration
Explain migration workflow:
- When changing `working_directory` setting
- If old directory contains files, user is prompted:
  - Option 1: Migrate files to new location
  - Option 2: Start fresh (keep old directory as-is)
- Automatic migration is never performed without user consent

#### Subsection: Common Use Cases

**Use Case 1: Change working directory globally**
```
1. Run /dotclaude:configure
2. Select "Global (all projects)"
3. Set working_directory to "docs"
4. All future projects use "docs" directory
```

**Use Case 2: Per-project working directory**
```
1. Navigate to project
2. Run /dotclaude:configure
3. Select "Local (this project only)"
4. Set working_directory to "project_docs"
5. Only this project uses "project_docs"
```

**Use Case 3: Migrate existing projects**
```
Existing projects with claude_works/ directory:
Option A: Keep existing name
  - Set working_directory: "claude_works" in local config
Option B: Migrate to new name
  - Run /dotclaude:configure
  - Change working_directory
  - Select "Migrate" when prompted
```

**Use Case 4: Different base branch**
```
For projects using "develop" instead of "main":
1. Run /dotclaude:configure
2. Select scope (local for one project, global for all)
3. Set base_branch to "develop"
```

### Step 2: Update CHANGELOG.md

**File**: `CHANGELOG.md`

**Action**: Add new version entry at the top of the file (below "Unreleased" section if it exists)

Format following Keep a Changelog standard:

```markdown
## [0.2.0] - YYYY-MM-DD

### Added
- `/dotclaude:configure` command for interactive configuration management
- Global configuration file support (`~/.claude/dotclaude-config.json`)
- Local configuration file support (`<project_root>/.claude/dotclaude-config.json`)
- Configuration settings: `language`, `working_directory`, `check_version`, `auto_update`, `base_branch`
- Working directory migration workflow when changing `working_directory` setting
- SessionStart hook for automatic default configuration initialization
- Configuration loading with merge strategy (local overrides global)

### Changed
- All skills now use configurable `working_directory` instead of hard-coded `claude_works/`
- Working directory is now customizable per-project or globally
- Base branch for git operations is now configurable (default: `main`)

### Technical
- Configuration files use JSON format
- Configuration loading includes graceful error handling
- Invalid JSON falls back to default values without breaking skills
- Path validation prevents security issues (absolute paths, parent traversal rejected)
```

**Important**: Use actual release date when creating the entry (YYYY-MM-DD format)

### Step 3: Update README.md Features Section

**File**: `README.md`

**Action**: Locate the Features section and add configuration to the feature list

Add bullet point:
- **Configurable Settings**: Customize working directory, base branch, and other settings globally or per-project

Maintain existing feature list formatting.

### Step 4: Verify Documentation Consistency

**Action**: Review all documentation changes to ensure:
- No contradictions between README.md and CHANGELOG.md
- All five settings are documented consistently
- File paths are correct (global: `~/.claude/`, local: `<project_root>/.claude/`)
- Examples use proper JSON format
- Default values match those in code (from Phase 1)
- Terminology is consistent throughout

### Step 5: Check for Other Documentation Files

**Action**: Search for other documentation files that might reference `claude_works/` or configuration:
- Check for any `docs/` directory
- Check for any other `.md` files in repository root
- Update any references to hard-coded paths or configuration

If found, update with configuration-aware language:
- Replace "claude_works directory" with "working directory (default: .dc_workspace)"
- Add note about configuration via `/dotclaude:configure`

---

## Implementation Notes

### Documentation Style
- Use clear, concise language
- Provide concrete examples
- Explain "why" not just "how"
- Anticipate common questions

### README.md Structure
Configuration section should be self-contained:
- User can understand configuration without reading code
- All settings are explained with examples
- Common use cases are covered
- Migration path is clear

### CHANGELOG.md Format
Follow Keep a Changelog conventions:
- Group changes by category (Added, Changed, Removed, Fixed, etc.)
- Use present tense ("Add" not "Added" in descriptions)
- Be specific about what changed
- Include context for why changes were made when helpful

### Version Number
- Use v0.2.0 as target version (from SPEC.md)
- Do NOT update plugin.json or marketplace.json version fields (per CLAUDE.md guidelines)
- Version updates happen at release/tagging time only

---

## Completion Checklist

- [x] README.md Configuration section added
- [x] All five settings documented in README.md
- [x] Configuration file format example included
- [x] Global vs local scope explained clearly
- [x] Configuration precedence documented
- [x] Working directory migration workflow explained
- [x] Common use cases provided with examples
- [x] CHANGELOG.md v0.2.0 entry added
- [x] CHANGELOG entry follows Keep a Changelog format
- [x] CHANGELOG entry uses correct date format
- [x] README.md Features section updated
- [x] No hard-coded `claude_works/` references in documentation
- [x] All documentation is consistent and accurate
- [x] Examples use valid JSON format
- [x] File paths are correct

---

## Verification

### Manual Verification
```bash
# Check README.md includes configuration section
grep -A 20 "## Configuration" README.md

# Check CHANGELOG.md includes v0.2.0 entry
grep -A 20 "\[0.2.0\]" CHANGELOG.md

# Verify no documentation references hard-coded paths
grep -r "claude_works" *.md

# Verify JSON examples are valid
# Extract JSON blocks and validate with jq
```

### Expected Output
- README.md has comprehensive Configuration section
- CHANGELOG.md has properly formatted v0.2.0 entry
- All documentation uses configuration-aware language
- Examples are clear and helpful
- No hard-coded path references remain in user-facing documentation

---

## Documentation Examples

### Example README.md Configuration Section Structure
```markdown
## Configuration

### Overview
[Explain global vs local configuration...]

### Configuration Command
[How to use /dotclaude:configure...]

### Available Settings
[Table with all 5 settings...]

### Configuration File Format
[JSON example...]

### Configuration Scopes
[Precedence explanation...]

### Working Directory Migration
[Migration workflow...]

### Common Use Cases
[4-5 concrete examples...]
```

### Example CHANGELOG.md Entry
```markdown
## [0.2.0] - 2026-01-27

### Added
- [List of additions...]

### Changed
- [List of changes...]

### Technical
- [Technical implementation details...]
```

---

## Notes

- Documentation should be user-focused, not implementation-focused
- Assume reader is familiar with basic git and CLI concepts
- Examples should cover most common scenarios users will encounter
- Migration path is important - many users will have existing `claude_works/` directories
- Configuration is optional - defaults work for users who don't need customization
- Emphasize that configuration changes take effect immediately (no restart)
- Do NOT update version numbers in plugin.json or marketplace.json (per CLAUDE.md)

---

## Completion Date

2026-01-27

## Completed By

Claude Opus 4.5
