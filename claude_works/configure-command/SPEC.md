# Configure Command - Specification

## Overview

Add a `/dotclaude:configure` command to enable interactive management of dotclaude settings at both global and local (per-project) scopes. This feature replaces hard-coded defaults with user-configurable values stored in JSON configuration files.

**Source Issue**: https://github.com/U-lis/dotclaude/issues/7
**Target Version**: 0.2.0

## Functional Requirements

### FR-1: Configuration Command Entry Point
- [ ] Create `/dotclaude:configure` command file in `commands/` directory
- [ ] Command invokes corresponding skill in `skills/configure/SKILL.md`
- [ ] Skill uses interactive workflow with AskUserQuestion pattern

### FR-2: Configuration Scope Selection
- [ ] First interaction asks: "Which configuration to edit? (1) Local (this project) or (2) Global (all projects)"
- [ ] Display explanation: "Local settings override global settings"
- [ ] User selects scope before proceeding to settings management

### FR-3: Configurable Settings

All settings must be manageable through the configure command:

| Setting | Default Value | Type | Description |
|---------|--------------|------|-------------|
| `language` | `en_US` | string | Language for conversation and generated documents |
| `working_directory` | `.dc_workspace` | string | Directory name for dotclaude work files (relative to project root) |
| `check_version` | `true` | boolean | Check for plugin updates on session start |
| `auto_update` | `false` | boolean | Automatically update plugin when `check_version=true` and update available |
| `base_branch` | `main` | string | Default base branch for init/merge/PR operations |

### FR-4: Configuration File Storage

- [ ] **Global configuration**: `~/.claude/dotclaude-config.json`
  - Applies to all projects
  - Created automatically on first session start if not exists

- [ ] **Local configuration**: `<project_root>/.claude/dotclaude-config.json`
  - Applies only to current project
  - Created manually via `/dotclaude:configure` when user selects local scope
  - Local settings override global settings (merge strategy: local wins on conflict)

### FR-5: Configuration File Format

JSON structure:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
```

### FR-6: Working Directory Migration

When user changes `working_directory` setting:

1. Check if old working directory exists and contains files
2. If files exist:
   - Ask: "Existing work directory '{old_dir}' contains files. (1) Migrate to new location '{new_dir}' or (2) Start fresh?"
   - Option 1: Move entire directory contents to new location
   - Option 2: Keep old directory as-is, create new empty directory
3. If no files or directory does not exist:
   - Silently use new directory name

### FR-7: Initial Configuration Creation

- [ ] Add SessionStart hook that creates default global config if `~/.claude/dotclaude-config.json` does not exist
- [ ] Hook runs automatically on session start
- [ ] Does NOT create local config automatically (only via `/dotclaude:configure`)

### FR-8: Configuration Loading

All skills must load configuration in this order:

1. Load global config from `~/.claude/dotclaude-config.json` (if exists)
2. Load local config from `<project_root>/.claude/dotclaude-config.json` (if exists)
3. Merge: local values override global values
4. Apply defaults for any missing keys

### FR-9: Update Existing Skills

Update skills that currently use hard-coded paths:

- [ ] `skills/start-new/SKILL.md` - Replace `claude_works/` with config value
- [ ] `skills/design/SKILL.md` - Replace `claude_works/` with config value
- [ ] `skills/code/SKILL.md` - Replace `claude_works/` with config value
- [ ] `skills/update-docs/SKILL.md` - Replace `claude_works/` with config value
- [ ] Any other skills referencing `claude_works/` directory

## Non-Functional Requirements

### NFR-1: User Experience
- [ ] Interactive prompts are clear and concise
- [ ] Default values are shown when asking for input
- [ ] Invalid inputs receive helpful error messages
- [ ] Configuration changes take effect immediately (no session restart required)

### NFR-2: Code Quality
- [ ] Follow existing skill structure (YAML frontmatter + markdown workflow)
- [ ] Use AskUserQuestion for all user interactions
- [ ] Error handling for invalid JSON, missing files, permission issues

### NFR-3: Documentation
- [ ] Update README.md with configuration section
- [ ] Add configuration examples to documentation
- [ ] Document migration path from hard-coded `claude_works/` to configurable directory

### NFR-4: Backward Compatibility
- [ ] Existing projects without configuration files continue to work with defaults
- [ ] Gradual migration: no breaking changes to existing workflows

## Constraints

### C-1: File System Permissions
- Configuration files must be readable/writable by user
- Working directory must be creatable in project root

### C-2: JSON Format
- Configuration files must be valid JSON
- Invalid JSON triggers error message and fallback to defaults

### C-3: Path Restrictions
- Working directory must be relative path (no absolute paths)
- Working directory cannot be `.` or `..` or contain `..` (no parent directory traversal)
- Working directory cannot be empty string

### C-4: Language Values
- Accept any string value for language (no validation)
- No translation of skill files in v0.2.0 (future enhancement)

## Edge Cases

| Case | Expected Behavior | Priority |
|------|-------------------|----------|
| No config file exists | Use default values, no error | High |
| Invalid JSON in config file | Log error message, use defaults, continue execution | High |
| Working dir change with existing files | Prompt user: migrate or start fresh | High |
| Unknown setting key in config | Ignore unknown keys, use known keys | Medium |
| Global + Local config both exist | Merge with local overriding global | High |
| Permission denied reading config | Log error, use defaults | Medium |
| Permission denied writing config | Show error, abort configuration update | Medium |
| `working_directory` is absolute path | Reject with error message, keep current value | High |
| `working_directory` contains `..` | Reject with error message, keep current value | High |
| `base_branch` is empty string | Reject with error, require non-empty value | Medium |

## Out of Scope

### OS-1: Automatic Migration
- Automatically migrating existing `claude_works/` directories to new configured path
- User must manually migrate if needed

### OS-2: Multi-Language Support
- Translation of skill files, agent prompts, or documentation
- Language setting is stored but not used in v0.2.0

### OS-3: Configuration Validation UI
- Advanced validation of setting values beyond basic type checking
- Interactive wizard for bulk configuration

### OS-4: Environment Variables
- Configuration via environment variables (only JSON files supported)

### OS-5: Configuration Schema Versioning
- Migration of config schema between dotclaude versions
- Assume single schema version in v0.2.0

## Open Questions

None at this time. All requirements are clearly defined based on source issue.

## Dependencies

### Dependent Files
- All existing skills that reference `claude_works/` directory
- `hooks/hooks.json` for SessionStart hook registration

### Breaking Changes
None. Default behavior matches current hard-coded behavior.

## Acceptance Criteria

- [ ] User can run `/dotclaude:configure` and select global or local scope
- [ ] User can view and edit all five settings interactively
- [ ] Configuration is persisted to correct JSON file based on scope
- [ ] Local config overrides global config when both exist
- [ ] Working directory migration prompts user when files exist
- [ ] SessionStart hook creates default global config if missing
- [ ] All skills use configured working directory instead of `claude_works/`
- [ ] Invalid JSON config does not crash, falls back to defaults
- [ ] Documentation updated with configuration examples
