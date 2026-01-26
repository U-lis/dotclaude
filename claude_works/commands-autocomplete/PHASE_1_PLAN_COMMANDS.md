# Phase 1: COMMANDS

## Objective

Create the `commands/` directory and 7 command files that enable autocomplete support for dotclaude skills in Claude Code.

## Prerequisites

- None (first phase)

## Instructions

### Step 1: Create commands/ directory

Create directory at repository root:
```
mkdir -p commands/
```

### Step 2: Create command files

Create 7 command files following this exact pattern for each skill.

#### Template

```yaml
---
description: {description from corresponding SKILL.md}
---
Base directory for this skill: skills/{skill-name}

Read skills/{skill-name}/SKILL.md and follow its instructions.
```

#### File: commands/dc:start-new.md

```yaml
---
description: Entry point for starting new work. Executes full 13-step orchestrator workflow with AskUserQuestion support.
---
Base directory for this skill: skills/start-new

Read skills/start-new/SKILL.md and follow its instructions.
```

#### File: commands/dc:design.md

```yaml
---
description: Transform SPEC into detailed implementation plan using Designer agent. Use after SPEC.md is approved or when user invokes /dc:design.
---
Base directory for this skill: skills/design

Read skills/design/SKILL.md and follow its instructions.
```

#### File: commands/dc:code.md

```yaml
---
description: Execute coding work for a specific phase. Use when implementing a phase like /dc:code 1, /dc:code 2, /dc:code 3A, /dc:code 3.5 for merge phases, or /dc:code all for fully automatic execution of all phases.
---
Base directory for this skill: skills/code

Read skills/code/SKILL.md and follow its instructions.
```

#### File: commands/dc:merge-main.md

```yaml
---
description: Merge feature branch to main with conflict resolution and branch cleanup
---
Base directory for this skill: skills/merge-main

Read skills/merge-main/SKILL.md and follow its instructions.
```

#### File: commands/dc:tagging.md

```yaml
---
description: Create version tag based on CHANGELOG
---
Base directory for this skill: skills/tagging

Read skills/tagging/SKILL.md and follow its instructions.
```

#### File: commands/dc:update-docs.md

```yaml
---
description: Update project documentation (README, CHANGELOG) after code implementation is complete.
---
Base directory for this skill: skills/update-docs

Read skills/update-docs/SKILL.md and follow its instructions.
```

#### File: commands/dc:validate-spec.md

```yaml
---
description: Validate consistency across all planning documents using spec-validator agent. Use after design documents are created or when user invokes /dc:validate-spec.
---
Base directory for this skill: skills/validate-spec

Read skills/validate-spec/SKILL.md and follow its instructions.
```

## Completion Checklist

- [ ] `commands/` directory created
- [ ] `commands/dc:start-new.md` created with correct content
- [ ] `commands/dc:design.md` created with correct content
- [ ] `commands/dc:code.md` created with correct content
- [ ] `commands/dc:merge-main.md` created with correct content
- [ ] `commands/dc:tagging.md` created with correct content
- [ ] `commands/dc:update-docs.md` created with correct content
- [ ] `commands/dc:validate-spec.md` created with correct content
- [ ] All 7 files have valid YAML frontmatter with `description` field
- [ ] All 7 files correctly reference their corresponding skill directory

## Notes

- Descriptions must match exactly with SKILL.md description fields
- File names include `dc:` prefix (this is how they appear in autocomplete)
- Content is minimal - full logic remains in skills/*/SKILL.md
