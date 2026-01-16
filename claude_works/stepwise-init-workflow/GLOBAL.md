# Stepwise Init Workflow - Global Documentation

## Feature Overview

**Purpose**: Restructure init workflow with step-by-step questioning and work type routing

**Problem**: Current /init-feature asks all questions at once, doesn't support bugfix/refactor work types

**Solution**: Add /start-new router, convert to step-by-step questions, add next action selection

---

## Architecture Decision

### Skill Structure
**Options Considered**:
1. Single unified init skill with mode parameter
2. Separate skills per work type with router

**Decision**: Option 2 - Separate skills with router

**Rationale**:
- Each work type has different question flow
- Easier to maintain and extend
- Follows existing skill pattern in codebase

### Next Step Selection
**Options Considered**:
1. Stop hook to detect completion
2. Skill-internal integration

**Decision**: Option 2 - Skill-internal

**Rationale**: More reliable, simpler implementation, no transcript parsing needed

---

## File Structure

### Files to Create
```
.claude/skills/
├── start-new/
│   └── SKILL.md         # Router skill
├── init-bugfix/
│   └── SKILL.md         # Bug fix init skill
└── init-refactor/
    └── SKILL.md         # Refactor init skill
```

### Files to Modify
```
.claude/skills/init-feature/SKILL.md  # Add step-by-step + next step selection
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Create /start-new router | 🟢 Complete | - |
| 2A | Update /init-feature | 🟢 Complete | Phase 1 |
| 2B | Create /init-bugfix | 🟢 Complete | Phase 1 |
| 2C | Create /init-refactor | 🟢 Complete | Phase 1 |

**Note**: Phases 2A, 2B, 2C modify different files - no merge phase needed.

**Status Legend**:
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Complete

---

## Phase Dependencies

```
Phase 1 ──→ Phase 2A (init-feature)
       └──→ Phase 2B (init-bugfix)
       └──→ Phase 2C (init-refactor)
```

---

## Completion Criteria

Overall feature is complete when:
- [x] /start-new routes correctly to each init-* skill
- [x] /init-feature uses step-by-step questions
- [x] /init-bugfix created with step-by-step questions
- [x] /init-refactor created with step-by-step questions
- [x] All init-* skills have next step selection
- [x] Branch keywords auto-generated

---

## Next Steps

1. ⏳ Phase 1: Create /start-new router skill
2. Phase 2A/2B/2C: Update/create init skills (can run in parallel)
