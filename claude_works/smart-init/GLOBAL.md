# Smart Init - Global Documentation

## Feature Overview

### Purpose
Enhance init-xxx skills (init-feature, init-bugfix, init-refactor) to perform intelligent requirements analysis, codebase investigation, and iterative clarification before creating SPEC.md.

### Problem
Current init-xxx skills:
- Follow fixed question flow without adaptive analysis
- Do not analyze codebase for related code, conflicts, or dependencies (except init-bugfix partially)
- Do not clarify ambiguous or incomplete user inputs
- Do not generate test cases or edge cases
- Produce incomplete SPEC.md that fails as Source of Truth

### Solution
Add analysis phases after question gathering:
1. Input Analysis - identify gaps and ambiguities in user responses
2. Codebase Investigation - search for related code, patterns, conflicts
3. Conflict Detection - compare requirements against existing implementation
4. Edge Case Generation - generate boundary conditions and error scenarios
5. Iterative Clarification - allow user to refine requirements

## Architecture Decision

### AD-1: Shared Analysis Module
**Decision**: Create common analysis utilities in `_shared/analysis-phases.md`
**Rationale**: Avoid code duplication across three init skills
**Trade-off**: All skills depend on shared module; changes affect all skills

### AD-2: Modular Phase Structure
**Decision**: Add analysis phases A-E after existing question phases
**Rationale**: Clear separation of concerns; each phase has single responsibility
**Trade-off**: Longer init workflow; more token usage

### AD-3: Enhanced SPEC.md Template
**Decision**: Add "Analysis Results" section to SPEC.md with tables for Related Code, Conflicts, Edge Cases
**Rationale**: Token-efficient structured format; consistent across all init types
**Trade-off**: More complex SPEC.md structure

### AD-4: Iteration Limits
**Decision**: Max 5 questions per analysis category; max 3 clarification iterations; max 10 file reads
**Rationale**: Prevent infinite loops and excessive token usage
**Trade-off**: May miss some edge cases in complex scenarios

## Data Model

### Analysis Results Structure
```markdown
## Analysis Results

### Related Code
| # | File | Line | Relationship |
|---|------|------|--------------|

### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|

### Edge Cases
| # | Case | Expected Behavior |
|---|------|-------------------|
```

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Update shared init-workflow with analysis flow | Pending | None |
| 2 | Create shared analysis utilities | Pending | Phase 1 |
| 3A | Enhance init-feature with analysis | Pending | Phases 1, 2 |
| 3B | Enhance init-bugfix with analysis | Pending | Phases 1, 2 |
| 3C | Enhance init-refactor with analysis | Pending | Phases 1, 2 |
| 3.5 | Merge parallel phases and integration test | Pending | Phases 3A, 3B, 3C |

### Dependency Matrix

| | Phase 1 | Phase 2 | Phase 3A | Phase 3B | Phase 3C | Phase 3.5 |
|---|---|---|---|---|---|---|
| Phase 1 | - | | | | | |
| Phase 2 | X | - | | | | |
| Phase 3A | X | X | - | | | |
| Phase 3B | X | X | | - | | |
| Phase 3C | X | X | | | - | |
| Phase 3.5 | | | X | X | X | - |

### Parallel Phase Justification

**Phases 3A, 3B, 3C are parallel because:**
1. No shared files: Each modifies different SKILL.md file
2. No runtime dependency: Each skill works independently
3. Independently testable: Each skill can be tested in isolation

**Conflict Predictions:**
- Merge conflicts: None expected (different files)
- Integration points: All import from `_shared/analysis-phases.md`
- Test coordination: Each skill tests independently

## File Structure

### Files to Modify
| File | Phase | Change Type |
|------|-------|-------------|
| `.claude/skills/_shared/init-workflow.md` | 1 | Modify - add analysis phases to workflow |
| `.claude/skills/_shared/analysis-phases.md` | 2 | Create - shared analysis utilities |
| `.claude/skills/init-feature/SKILL.md` | 3A | Modify - add analysis instructions |
| `.claude/skills/init-bugfix/SKILL.md` | 3B | Modify - enhance existing analysis |
| `.claude/skills/init-refactor/SKILL.md` | 3C | Modify - add analysis instructions |

### Directory Structure
```
.claude/skills/
├── _shared/
│   ├── init-workflow.md        (modified)
│   └── analysis-phases.md      (new)
├── init-feature/
│   └── SKILL.md                (modified)
├── init-bugfix/
│   └── SKILL.md                (modified)
└── init-refactor/
    └── SKILL.md                (modified)
```
