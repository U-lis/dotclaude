# auto-workflow - Global Documentation

## Feature Overview

**Purpose**: Enable user-controlled automation workflow that executes multiple phases without human intervention after SPEC.md approval.

**Problem**: Current workflow stops after each skill completion, requiring manual "What's next?" interaction.

**Solution**: Enhance `_shared/init-workflow.md` with explicit non-stop execution instructions that chain skills based on user's selected scope.

---

## Architecture Decision

### Approach: Enhance init-workflow.md

**Options Considered**:
1. Option A: Create new orchestrator skill (`auto-workflow/SKILL.md`)
2. Option B: Enhance existing `_shared/init-workflow.md` with execution instructions

**Decision**: Option B

**Rationale**:
- Question UI and routing table already exist in init-workflow.md
- Keeps logic co-located with routing logic
- No new skill registration needed
- Follows existing pattern: skills reference init-workflow.md for shared behavior
- Less token overhead than creating a new skill

---

## File Structure

### Files to Modify
```
.claude/skills/_shared/init-workflow.md   # Add Non-Stop Execution section
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Enhance init-workflow.md with Non-Stop Execution section | Not Started | - |

---

## Key Design Details

### Execution Flow

```
User selects scope (e.g., "Design → Code → CHANGELOG → Merge")
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ Execute /design                                              │
│   → On completion: Check if scope includes "Code"           │
│   → If yes: Proceed immediately (no user prompt)            │
├─────────────────────────────────────────────────────────────┤
│ Execute /code all                                            │
│   → On completion: Check if scope includes "CHANGELOG"      │
│   → If yes: Proceed immediately                             │
├─────────────────────────────────────────────────────────────┤
│ Execute CHANGELOG workflow                                   │
│   → On completion: Check if scope includes "Merge"          │
│   → If yes: Proceed immediately                             │
├─────────────────────────────────────────────────────────────┤
│ Execute /merge-main                                          │
│   → Merge complete                                          │
├─────────────────────────────────────────────────────────────┤
│ Generate Final Summary Report                                │
│   → Present to user                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Completion Criteria

- [ ] init-workflow.md contains "Non-Stop Execution" section
- [ ] Execution instructions are explicit and unambiguous
- [ ] CLAUDE.md rule overrides are documented
- [ ] Progress indicator format is defined (optional)
- [ ] Final summary report format is defined (optional)
