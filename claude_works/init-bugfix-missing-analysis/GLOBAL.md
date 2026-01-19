# init-bugfix Missing Analysis - Global Context

## Overview

Fix the `/init-bugfix` skill to include codebase analysis step before SPEC.md creation.

## Architecture

### Current State
```
User Questions (1-6) → Branch → SPEC.md (user info only)
```

### Target State
```
User Questions (1-6) → Codebase Analysis (Step 7) → Branch → SPEC.md (user info + analysis)
```

## Phase Overview

| Phase | Keyword | Description | Status |
|-------|---------|-------------|--------|
| 1 | skill-update | Update SKILL.md with analysis step and new SPEC format | Pending |

## Technical Decisions

### Decision 1: Analysis Step Placement
**Choice**: Add Step 7 after user questions, before branch creation
**Rationale**: Analysis results inform branch naming and SPEC content

### Decision 2: SPEC.md Structure
**Choice**: Two sections - "User-Reported Information" + "AI Analysis Results"
**Rationale**: Clear separation of source (user vs AI) while keeping single document

### Decision 3: Analysis Tools
**Choice**: Use existing Explore agent + Read tool
**Rationale**: No new infrastructure needed; leverage existing capabilities

## Files to Modify

| File | Changes |
|------|---------|
| `.claude/skills/init-bugfix/SKILL.md` | Add Step 7, update Output section |

## Dependencies

None - standalone documentation change.

## Risks

- **Low**: Minor risk that AI might not find root cause in all cases
- **Mitigation**: Document fallback behavior when analysis inconclusive
