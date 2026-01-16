# GLOBAL: Parallel Phase Detection Enhancement

## Overview

Single-phase enhancement to `.claude/agents/designer.md` adding explicit parallel phase detection methodology.

## Architecture Decisions

### AD-1: Structured Dependency Analysis in Designer Agent
Add formal three-level dependency analysis framework directly into designer agent instructions.

### AD-2: Three-Level Dependency Matrix
- **File-level**: Direct file modifications
- **Module-level**: Import/export dependencies
- **Test-level**: Shared fixtures, test data, mocks

### AD-3: Explicit Parallelization Criteria
Mandatory checklist before declaring phases parallel:
- No shared file modifications
- No runtime dependencies
- Independently testable

### AD-4: Conflict Prediction in Output
Require designer to document predicted conflicts for merge phase planning.

## Phase Structure

| Phase | Description | Type |
|-------|-------------|------|
| 1 | Enhance Designer Agent Instructions | Sequential |

**Rationale for single phase**:
- Single file modification (`designer.md`)
- All changes interdependent
- No code, only documentation

## File Impact

| File | Action |
|------|--------|
| `.claude/agents/designer.md` | Modify - add 3 sections, update handoff |

## Constraints

- Token efficient (no redundant prose)
- Maintain existing naming conventions
- Compatible with `/code` skill
