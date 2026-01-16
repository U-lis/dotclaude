# SPEC: init-xxx Skill Flow Unification

## Overview

Refactor init-feature, init-bugfix, init-refactor skills to eliminate code duplication and add workflow enforcement via Stop hook.

## Target

- `.claude/skills/init-feature/SKILL.md`
- `.claude/skills/init-bugfix/SKILL.md`
- `.claude/skills/init-refactor/SKILL.md`

## Current Problems

### DRY Violation
- ~104 lines of identical content duplicated across 3 files
- Workflow diagram, Mandatory Workflow Rules, Next Step Selection, Phase Selection, Routing sections are copy-pasted
- Flow modification requires editing 3 files

### Workflow Bypass Issue
- Permission bypass allows AI to skip branch creation and SPEC.md writing
- Text-based instructions have no enforcement mechanism

## Goal State

### Single Source of Truth
- Common workflow extracted to `_shared/init-workflow.md`
- Each init-* skill references shared file
- Flow changes require editing only 1 file

### Hook-based Enforcement
- Stop hook checks branch creation and SPEC.md existence
- Prevents workflow bypass regardless of permission settings

## Behavior Change Policy

**동작 유지 필수** - Pure refactoring with no functional changes. Existing workflow behavior preserved.

## Test Coverage

None - These are documentation/configuration files, not executable code.

## Dependencies

All init-* skills are invoked from:
- Direct user invocation (`/init-feature`, `/init-bugfix`, `/init-refactor`)
- Routing from `/start-new` skill

## XP Principle Reference

| Problem | XP Principle | Solution |
|---------|--------------|----------|
| Duplicate code | DRY (Don't Repeat Yourself) | Extract to `_shared/init-workflow.md` |
| No enforcement | Fail Fast | Stop hook validates prerequisites |

## Implementation Summary

### Files to Create
| File | Purpose |
|------|---------|
| `.claude/hooks/check-init-complete.sh` | Stop hook script |
| `.claude/skills/_shared/init-workflow.md` | Shared workflow definition |

### Files to Modify
| File | Change |
|------|--------|
| `init-feature/SKILL.md` | Add hook, reference shared, remove duplicates |
| `init-bugfix/SKILL.md` | Add hook, reference shared, remove duplicates |
| `init-refactor/SKILL.md` | Add hook, reference shared, remove duplicates |

## Expected Results

| Metric | Before | After |
|--------|--------|-------|
| Total lines | ~687 | ~350 |
| Duplicate content | 312 lines | 0 |
| Files to edit for flow change | 3 | 1 |

## Out of Scope

- Changes to step-by-step questions (unique per skill)
- Changes to branch naming format
- Changes to SPEC.md output mapping
