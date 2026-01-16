# SPEC: Fix init-xxx skill workflow bypass

## Overview

### Bug Description
When using `/init-xxx` skills in plan mode and selecting "작업 + permission bypass", Claude skips mandatory workflow steps (SPEC.md creation and Next Step Selection question), jumping directly to implementation.

### Problem Statement
The init-xxx SKILL.md files define a 7-step workflow but lack explicit instructions stating that Steps 5-7 are mandatory and cannot be skipped. This allows Claude to misinterpret "permission bypass" as authorization to skip the workflow.

## Functional Requirements

### FR-1: Add Mandatory Workflow Rules Section
Add a new "Mandatory Workflow Rules" section to each init-xxx SKILL.md file that explicitly states:
- Steps 5-7 are mandatory and cannot be skipped
- List of prohibited actions
- Correct execution order

### FR-2: Files to Modify
- `.claude/skills/init-feature/SKILL.md`
- `.claude/skills/init-bugfix/SKILL.md`
- `.claude/skills/init-refactor/SKILL.md`

## Non-Functional Requirements

### NFR-1: Clarity
Instructions must be clear enough that any AI agent can follow them without ambiguity.

### NFR-2: Consistency
All three init-xxx skills must have identical "Mandatory Workflow Rules" sections.

## Constraints

- Use skill-internal approach (hooks rejected per project decision)
- Maintain existing workflow structure
- No breaking changes to current skill behavior

## Out of Scope

- Hook-based enforcement
- Changes to other skills (design, code, finalize)
- Changes to settings.json
