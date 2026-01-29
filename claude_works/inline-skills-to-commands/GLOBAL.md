# Inline Skills to Commands - Global Documentation

## Feature Overview

**Purpose**: Fix plugin path resolution by inlining skill content into command files and enabling direct agent invocation.

**Problem**: Command files reference `skills/{name}/SKILL.md` using relative paths that resolve against CWD, not the plugin installation path. When the plugin is installed in other projects, these paths fail because the `skills/` directory does not exist at CWD.

**Solution**: Eliminate the `skills/` indirection layer entirely. Each command file becomes self-contained with its full content. Agents get frontmatter so they can be invoked directly via `dotclaude:{agent-name}` instead of the `general-purpose` workaround pattern.

## Architecture Decision

### AD-1: Inline Skill Content, Not Reference

**Decision**: Copy SKILL.md content directly into command .md files, preserving the existing frontmatter `description` field and adding the full skill body after the `---` delimiter.

**Rationale**: The `${CLAUDE_PLUGIN_ROOT}` variable only works in JSON configuration files, not in markdown. There is no reliable way to reference sibling files from command markdown. The simplest fix is to make each command self-contained.

**Pattern (before)**:
```yaml
---
description: {description text}
---
Base directory for this skill: skills/{name}

Read skills/{name}/SKILL.md and follow its instructions.
```

**Pattern (after)**:
```yaml
---
description: {description text}
---

{Full content of SKILL.md starting from after its own frontmatter closing ---}
```

### AD-2: Internal Commands for start-new Sub-files

**Decision**: Move the 5 sub-files from `skills/start-new/` to `commands/` as internal commands with `user-invocable: false` frontmatter.

**Rationale**: These files (init-feature.md, init-bugfix.md, init-refactor.md, init-github-issue.md, _analysis.md) are referenced by the start-new command. In the plugin system, Claude can auto-load command files by name when they exist in the `commands/` directory, so the references change from "Read `init-feature.md` from this skill directory" to the command being available as `dotclaude:init-feature`.

**Internal command frontmatter**:
```yaml
---
description: {description text}
user-invocable: false
---
```

### AD-3: Update start-new.md Cross-References

**Decision**: After inlining start-new SKILL.md content and moving sub-files to commands, update the cross-references within start-new.md to use command names instead of relative file paths.

**Before**:
```
| Add/Modify Feature | Read `init-feature.md` from this skill directory |
```

**After**:
```
| Add/Modify Feature | Use the `init-feature` command (auto-loaded by Claude) |
```

Similarly, references like `Read _analysis.md for the common analysis workflow` become `Use the _analysis command (auto-loaded by Claude)`.

Also update the same references in the init sub-files themselves (init-feature.md, init-bugfix.md, init-refactor.md reference `_analysis.md`).

### AD-4: Agent Frontmatter Format

**Decision**: Add YAML frontmatter with `name` and `description` fields to all 10 agent files. Do NOT add `model` or `tools` fields in the markdown frontmatter.

**Rationale**: Looking at the existing SKILL.md files (which already have frontmatter like `name`, `description`, `user-invocable`), the markdown frontmatter is for metadata. The `model` and `tools` configuration for agents is handled by the plugin system (agents.json or plugin-level config), not by the markdown file itself. The SPEC lists `model` and `tools` fields, but these belong in plugin configuration, not agent markdown. We add only `name` and `description` to enable plugin system identification.

**Format for base agents**:
```yaml
---
name: designer
description: Transform SPEC into detailed implementation plans with architecture decisions and phase decomposition.
---
```

**Format for coder agents**:
```yaml
---
name: coder-javascript
description: JavaScript/TypeScript development specialist following TDD principles.
---
```

### AD-5: Agent Invocation Pattern Change

**Decision**: Change from `subagent_type="general-purpose"` with `prompt="You are {Agent}. Read agents/{path}.md..."` to `subagent_type="dotclaude:{agent-name}"`.

**Before**:
```
Task(
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.
{task instructions}
"""
)
```

**After**:
```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
{task instructions}
"""
)
```

The prompt no longer needs to instruct the agent to read its own definition file -- the plugin system handles that when a named agent is invoked.

### AD-6: Delete skills/ Directory Last

**Decision**: Only delete `skills/` after ALL inlining and moving is verified complete.

**Rationale**: The skills directory is the source of truth until inlining is done. Deleting it prematurely would lose content.

## Agent Name Mapping

Precise mapping from agent files to `dotclaude:{name}` invocation names:

| Agent File | Frontmatter `name` | Invocation Pattern |
|------------|--------------------|--------------------|
| `agents/designer.md` | `designer` | `dotclaude:designer` |
| `agents/technical-writer.md` | `technical-writer` | `dotclaude:technical-writer` |
| `agents/code-validator.md` | `code-validator` | `dotclaude:code-validator` |
| `agents/spec-validator.md` | `spec-validator` | `dotclaude:spec-validator` |
| `agents/coders/_base.md` | `coder-base` | `dotclaude:coder-base` |
| `agents/coders/javascript.md` | `coder-javascript` | `dotclaude:coder-javascript` |
| `agents/coders/python.md` | `coder-python` | `dotclaude:coder-python` |
| `agents/coders/rust.md` | `coder-rust` | `dotclaude:coder-rust` |
| `agents/coders/sql.md` | `coder-sql` | `dotclaude:coder-sql` |
| `agents/coders/svelte.md` | `coder-svelte` | `dotclaude:coder-svelte` |

## Invocation Pattern Changes (Exhaustive)

All files containing `general-purpose` invocations that need updating (only active source files, not claude_works/ history):

### In start-new SKILL.md (becomes commands/start-new.md)

| Line Context | Agent | Old Pattern | New Pattern |
|-------------|-------|-------------|-------------|
| Step 2 - SPEC.md Creation | TechnicalWriter | `subagent_type="general-purpose"` + `Read agents/technical-writer.md` | `subagent_type="dotclaude:technical-writer"` |
| Step 7 - Design Documents | TechnicalWriter | same | same |
| Step 11 - DOCS_UPDATE | TechnicalWriter | same | same |
| Step 6 - Design | Designer | `subagent_type="general-purpose"` + `Read agents/designer.md` | `subagent_type="dotclaude:designer"` |
| Step 10 - Code | Coder | `subagent_type="general-purpose"` + `Read agents/coders/{lang}.md` | `subagent_type="dotclaude:coder-{lang}"` |
| Step 10 - Validate | code-validator | `subagent_type="general-purpose"` + `Read agents/code-validator.md` | `subagent_type="dotclaude:code-validator"` |
| Delegation rules | All | `subagent_type: "general-purpose"` | `subagent_type: "dotclaude:{agent-name}"` |

### In update-docs SKILL.md (becomes commands/update-docs.md)

| Line Context | Agent | Old Pattern | New Pattern |
|-------------|-------|-------------|-------------|
| TechnicalWriter call | TechnicalWriter | `subagent_type: "general-purpose"` + `Read agents/technical-writer.md` | `subagent_type: "dotclaude:technical-writer"` |

### In code SKILL.md (becomes commands/code.md)

No direct `general-purpose` invocations in this file (it delegates to orchestrator to invoke agents).

### In other SKILL.md files

configure.md, design.md, validate-spec.md, merge-main.md, tagging.md: No agent invocation patterns found.

## Cross-Reference Update Inventory

### In start-new.md (after inlining)

References to update:
1. `Read init-feature.md from this skill directory` -> `The init-feature command will be auto-loaded by Claude`
2. `Read init-bugfix.md from this skill directory` -> same pattern
3. `Read init-refactor.md from this skill directory` -> same pattern
4. `Read init-github-issue.md from this skill directory` -> same pattern
5. `read _analysis.md for details` -> `the _analysis command contains the details`
6. `Read agents/technical-writer.md for your role` -> remove (handled by plugin system)
7. `Read agents/designer.md for your role` -> remove
8. `Read agents/coders/{lang}.md for your role` -> remove
9. `Read agents/code-validator.md for your role` -> remove

### In init-feature.md, init-bugfix.md, init-refactor.md (after moving to commands/)

References to update:
- `Read _analysis.md for the common analysis workflow` -> `The _analysis command provides the common analysis workflow`

### In update-docs.md (after inlining)

References to update:
- `Read agents/technical-writer.md` -> remove (handled by plugin system)

### In coder language agents (coders/javascript.md, python.md, etc.)

References to update:
- `Read and follow coders/_base.md first` -> `Read and follow the coder-base agent definition first` or keep as-is since agents can reference each other by relative path within the agents directory.

**Decision**: Keep the `coders/_base.md` reference in language agents as-is. The agents directory structure is not changing, and the reference is a relative path within the agents folder, which the plugin system resolves correctly for agent files.

## Phase Overview

| Phase | Description | Status | Dependencies | Files Changed |
|-------|-------------|--------|--------------|---------------|
| 1A | Add frontmatter to agent files | Pending | None | 10 agent files |
| 1B | Inline SKILL.md into 7 simple commands | Pending | None | 7 command files |
| 1.5 | Merge Phase 1A + 1B | Pending | 1A, 1B | None (merge only) |
| 2 | Inline start-new + move sub-files + update refs | Pending | 1.5 | 6 command files |
| 3 | Update agent invocation patterns in commands | Pending | 2 | 2 command files |
| 4 | Delete skills/ directory + verify | Pending | 3 | skills/ directory |

## File Structure

### Files Modified

**Phase 1A** (agents - frontmatter):
- `agents/designer.md`
- `agents/technical-writer.md`
- `agents/code-validator.md`
- `agents/spec-validator.md`
- `agents/coders/_base.md`
- `agents/coders/javascript.md`
- `agents/coders/python.md`
- `agents/coders/rust.md`
- `agents/coders/sql.md`
- `agents/coders/svelte.md`

**Phase 1B** (simple command inlining):
- `commands/configure.md` (inline from skills/configure/SKILL.md)
- `commands/code.md` (inline from skills/code/SKILL.md)
- `commands/design.md` (inline from skills/design/SKILL.md)
- `commands/update-docs.md` (inline from skills/update-docs/SKILL.md)
- `commands/validate-spec.md` (inline from skills/validate-spec/SKILL.md)
- `commands/merge-main.md` (inline from skills/merge-main/SKILL.md)
- `commands/tagging.md` (inline from skills/tagging/SKILL.md)

**Phase 2** (start-new complex inlining):
- `commands/start-new.md` (inline from skills/start-new/SKILL.md + update refs)
- `commands/init-feature.md` (NEW - moved from skills/start-new/)
- `commands/init-bugfix.md` (NEW - moved from skills/start-new/)
- `commands/init-refactor.md` (NEW - moved from skills/start-new/)
- `commands/init-github-issue.md` (NEW - moved from skills/start-new/)
- `commands/_analysis.md` (NEW - moved from skills/start-new/)

**Phase 3** (invocation pattern updates):
- `commands/start-new.md` (update general-purpose -> dotclaude:*)
- `commands/update-docs.md` (update general-purpose -> dotclaude:*)

**Phase 4** (cleanup):
- `skills/` (DELETE entire directory)

### Files NOT Modified (explicitly scoped out)
- `.claude-plugin/plugin.json` (no version bump per CLAUDE.md rules)
- `.claude-plugin/marketplace.json` (no version bump)
- `CHANGELOG.md` (docs phase, not code phase)
- `README.md` (docs phase, not code phase)
- `CLAUDE.md` / `.claude/CLAUDE.md` (no changes needed)
- `claude_works/` (historical documents, not active code)
