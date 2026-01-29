# Inline Skills to Commands - Specification

## Overview

Inline skill content into command files to fix plugin path resolution issues. Currently, command files reference SKILL.md files using relative paths (e.g., `skills/start-new/SKILL.md`), which fail when the plugin is installed in projects other than the dotclaude development repository.

**Target Version**: 0.2.1

## Problem Statement

- Command files use relative paths like `skills/start-new/SKILL.md`
- These paths are resolved relative to the current working directory, not the plugin installation path
- Result: `/dotclaude:start-new` fails in projects other than the dotclaude dev repo
- The `${CLAUDE_PLUGIN_ROOT}` variable only works in JSON configuration files, not in markdown files

## Functional Requirements

### FR-1: Inline Skill Content into Commands (User-Invocable)
- [ ] FR-1.1: Inline `skills/start-new/SKILL.md` into `commands/start-new.md`
- [ ] FR-1.2: Inline `skills/configure/SKILL.md` into `commands/configure.md`
- [ ] FR-1.3: Inline `skills/code/SKILL.md` into `commands/code.md`
- [ ] FR-1.4: Inline `skills/update-docs/SKILL.md` into `commands/update-docs.md`
- [ ] FR-1.5: Inline `skills/validate-spec/SKILL.md` into `commands/validate-spec.md`
- [ ] FR-1.6: Inline `skills/design/SKILL.md` into `commands/design.md`
- [ ] FR-1.7: Inline `skills/merge-main/SKILL.md` into `commands/merge-main.md`
- [ ] FR-1.8: Inline `skills/tagging/SKILL.md` into `commands/tagging.md`

### FR-1B: Create Internal Commands (user-invocable: false)
- [ ] FR-1B.1: Move `skills/start-new/init-feature.md` to `commands/init-feature.md` with `user-invocable: false`
- [ ] FR-1B.2: Move `skills/start-new/init-bugfix.md` to `commands/init-bugfix.md` with `user-invocable: false`
- [ ] FR-1B.3: Move `skills/start-new/init-refactor.md` to `commands/init-refactor.md` with `user-invocable: false`
- [ ] FR-1B.4: Move `skills/start-new/init-github-issue.md` to `commands/init-github-issue.md` with `user-invocable: false`
- [ ] FR-1B.5: Move `skills/start-new/_analysis.md` to `commands/_analysis.md` with `user-invocable: false`
- [ ] FR-1B.6: Update `commands/start-new.md` to reference internal commands by name (Claude auto-loads context)

### FR-2: Delete Skills Directory
- [ ] FR-2.1: Remove `skills/` directory entirely after content inlining is complete
- [ ] FR-2.2: Verify no remaining references to `skills/` directory in codebase

### FR-3: Add Frontmatter to All Agents
- [ ] FR-3.1: Add frontmatter to `agents/designer.md` with `name`, `description`, `model`, `tools` fields
- [ ] FR-3.2: Add frontmatter to `agents/technical-writer.md`
- [ ] FR-3.3: Add frontmatter to `agents/code-validator.md`
- [ ] FR-3.4: Add frontmatter to `agents/spec-validator.md`
- [ ] FR-3.5: Add frontmatter to `agents/coders/_base.md`
- [ ] FR-3.6: Add frontmatter to `agents/coders/javascript.md`
- [ ] FR-3.7: Add frontmatter to `agents/coders/python.md`
- [ ] FR-3.8: Add frontmatter to `agents/coders/rust.md`
- [ ] FR-3.9: Add frontmatter to `agents/coders/sql.md`
- [ ] FR-3.10: Add frontmatter to `agents/coders/svelte.md`

### FR-4: Update Agent Invocation Patterns in Commands
- [ ] FR-4.1: Change agent invocations from `Task(subagent_type="general-purpose", prompt="Read agents/designer.md...")` to `Task(subagent_type="dotclaude:designer", ...)`
- [ ] FR-4.2: Update all TechnicalWriter invocation patterns
- [ ] FR-4.3: Update all Designer invocation patterns
- [ ] FR-4.4: Update all Coder invocation patterns
- [ ] FR-4.5: Update all code-validator invocation patterns
- [ ] FR-4.6: Update all spec-validator invocation patterns

## Non-Functional Requirements

- [ ] NFR-1: Maintain backward compatibility with existing functionality (no behavior change from user perspective)
- [ ] NFR-2: Follow OMC/claude-hud pattern for command structure (frontmatter + content)
- [ ] NFR-3: Plugin must work correctly in any project directory, not just the dev repo
- [ ] NFR-4: Ensure agent frontmatter enables direct invocation via Claude Code plugin system

## Files to Modify

### Command Files (User-Invocable)

| File | Current Lines | Estimated Target Lines | Action |
|------|---------------|------------------------|--------|
| `commands/start-new.md` | ~6 | ~960 | Inline SKILL.md |
| `commands/configure.md` | ~6 | ~520 | Inline SKILL.md |
| `commands/code.md` | ~6 | ~360 | Inline SKILL.md |
| `commands/update-docs.md` | ~6 | ~145 | Inline SKILL.md |
| `commands/validate-spec.md` | ~6 | ~125 | Inline SKILL.md |
| `commands/design.md` | ~6 | ~115 | Inline SKILL.md |
| `commands/merge-main.md` | ~6 | ~65 | Inline SKILL.md |
| `commands/tagging.md` | ~6 | ~65 | Inline SKILL.md |

### Internal Commands (user-invocable: false)

| File | Lines | Action |
|------|-------|--------|
| `commands/init-feature.md` | ~130 | Move from skills/start-new/, add frontmatter |
| `commands/init-bugfix.md` | ~160 | Move from skills/start-new/, add frontmatter |
| `commands/init-refactor.md` | ~155 | Move from skills/start-new/, add frontmatter |
| `commands/init-github-issue.md` | ~140 | Move from skills/start-new/, add frontmatter |
| `commands/_analysis.md` | ~160 | Move from skills/start-new/, add frontmatter |

### Agent Files (Add Frontmatter)

| File | Action |
|------|--------|
| `agents/designer.md` | Add frontmatter with name, description, model, tools |
| `agents/technical-writer.md` | Add frontmatter with name, description, model, tools |
| `agents/code-validator.md` | Add frontmatter with name, description, model, tools |
| `agents/spec-validator.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/_base.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/javascript.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/python.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/rust.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/sql.md` | Add frontmatter with name, description, model, tools |
| `agents/coders/svelte.md` | Add frontmatter with name, description, model, tools |

### Directories to Delete

| Directory | Action |
|-----------|--------|
| `skills/` | Delete entirely after inlining complete |

## Constraints

- Must work with Claude Code plugin system
- `${CLAUDE_PLUGIN_ROOT}` variable only works in JSON configs, not markdown
- Agent frontmatter must follow Claude Code plugin specification for subagent invocation

## Out of Scope

- Adding new skills or commands
- Changing workflow logic or behavior
- Modifying plugin.json structure
- Adding new agent capabilities

## Related Code Analysis

### Current Architecture

```
dotclaude/
├── commands/           # Entry points (thin wrappers)
│   └── {skill}.md     # Contains: Read skills/{skill}/SKILL.md
├── skills/             # Skill implementations
│   └── {skill}/
│       ├── SKILL.md   # Main skill logic
│       └── *.md       # Additional files (for start-new)
└── agents/             # Agent definitions
    ├── designer.md
    ├── technical-writer.md
    ├── code-validator.md
    ├── spec-validator.md
    └── coders/
        ├── _base.md
        └── {language}.md
```

### Target Architecture

```
dotclaude/
├── commands/                    # All commands in flat structure
│   ├── start-new.md            # User-invocable: true (default)
│   ├── configure.md            # User-invocable: true
│   ├── code.md                 # User-invocable: true
│   ├── design.md               # User-invocable: true
│   ├── update-docs.md          # User-invocable: true
│   ├── validate-spec.md        # User-invocable: true
│   ├── merge-main.md           # User-invocable: true
│   ├── tagging.md              # User-invocable: true
│   ├── init-feature.md         # user-invocable: false (internal)
│   ├── init-bugfix.md          # user-invocable: false (internal)
│   ├── init-refactor.md        # user-invocable: false (internal)
│   ├── init-github-issue.md    # user-invocable: false (internal)
│   └── _analysis.md            # user-invocable: false (internal)
└── agents/                      # Agent definitions with frontmatter
    ├── designer.md             # With frontmatter: name, description, model, tools
    ├── technical-writer.md
    ├── code-validator.md
    ├── spec-validator.md
    └── coders/
        ├── _base.md
        └── {language}.md
```

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Existing plugin installations | Will work correctly after plugin update/reinstall |
| 2 | Dev repo usage | Still works (commands function regardless of installation location) |
| 3 | Agent invocation without frontmatter (pre-update) | Should fail gracefully with clear error message |

## Acceptance Criteria

1. All 8 user-invocable command files contain their complete skill content (SKILL.md inlined)
2. 5 internal commands created with `user-invocable: false` frontmatter (init-feature, init-bugfix, init-refactor, init-github-issue, _analysis)
3. Internal commands are not shown in autocomplete but Claude can reference them
4. `skills/` directory is completely removed
5. All 10 agent files have proper frontmatter with name, description, model, tools
6. Agent invocations in commands use `dotclaude:{agent-name}` pattern
7. Plugin works correctly when installed in any project directory
8. No behavior changes from user perspective - all existing functionality preserved
