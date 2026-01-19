# Init Flow Cleanup - Global Context

## Overview

Refactoring to clarify responsibility boundaries between orchestrator and init-xxx skills by consolidating duplicated workflow sections and establishing clear ownership.

## Problem Statement

| Code Smell | Location | Issue |
|------------|----------|-------|
| DRY violation | orchestrator.md + init-workflow.md | "Next Step Selection" duplicated |
| SRP violation | init-xxx skills | Performs SPEC creation AND scope selection |
| Unclear ownership | Multiple files | Routing, non-stop execution, progress indicator scattered |

## Target Architecture

```
orchestrator.md
├── 13-Step Workflow (existing)
├── Scope Selection (Step 5 - existing)
├── Routing Logic (NEW - from init-workflow.md)
├── Non-Stop Execution (NEW - from init-workflow.md)
├── CLAUDE.md Rule Overrides (NEW - from init-workflow.md)
├── Progress Indicator (MERGE - enhanced format)
└── Final Summary Report (NEW - from init-workflow.md)

init-workflow.md
├── Plan Mode Policy (keep)
├── Init Phase Attitude (NEW)
├── Generic Workflow Diagram (Steps 1-8 only)
├── Analysis Phase Workflow (keep)
└── Mandatory Workflow Rules (Steps 5-8 only)

init-xxx SKILL.md
├── [existing content]
├── Invocation Behavior (NEW)
├── Output (clarified)
└── Workflow Integration (simplified)
```

## Phase Overview

| Phase | Description | Dependencies | Files Modified |
|-------|-------------|--------------|----------------|
| 1 | Enhance orchestrator.md | None | orchestrator.md |
| 2 | Reduce init-workflow.md | Phase 1 | init-workflow.md |
| 3 | Update init-xxx SKILL.md files | Phase 2 | init-feature/SKILL.md, init-bugfix/SKILL.md, init-refactor/SKILL.md |

## Dependency Analysis

### File-Level Dependencies

```
Phase 1: orchestrator.md (standalone)
           ↓
Phase 2: init-workflow.md (references orchestrator.md for "full workflow")
           ↓
Phase 3: init-xxx SKILL.md (references init-workflow.md)
```

### Module-Level Dependencies

- orchestrator.md: calls init-xxx skills via Skill tool
- init-workflow.md: shared by all init-xxx skills
- init-xxx SKILL.md: each uses init-workflow.md as base

### Test-Level Dependencies

No automated tests. Validation is manual review + grep-based checks.

## Parallel Phase Analysis

**Conclusion: No parallel phases**

Phases are strictly sequential:
1. Phase 1 adds sections to orchestrator.md
2. Phase 2 removes sections from init-workflow.md (must reference updated orchestrator.md)
3. Phase 3 updates init-xxx files (must reference updated init-workflow.md)

Within Phase 3, the three SKILL.md files could theoretically be parallel, but:
- Same template changes to all three
- No worktree complexity needed
- Sequential execution is simpler and sufficient

## Constraints

- analysis-phases.md remains unchanged
- init-xxx hooks remain unchanged
- orchestrator 13-step numbering preserved

## Success Criteria

1. Single source of truth for each section
2. grep "어디까지 진행할까요" returns only orchestrator.md
3. init-workflow.md contains only Steps 1-8
4. Each init-xxx SKILL.md clearly states invocation behavior

## Validation Strategy

| Check | Method | Expected Result |
|-------|--------|-----------------|
| DRY compliance | `grep -r "어디까지 진행할까요"` | Only orchestrator.md |
| Routing ownership | `grep -r "## Routing"` | Only orchestrator.md |
| Non-stop ownership | `grep -r "Non-Stop Execution"` | Only orchestrator.md |
| Init phase scope | Manual review | init-workflow.md ends at Step 8 |
| Invocation behavior | Manual review | All init-xxx have "Invocation Behavior" section |
