# code-all - Global Documentation

## Feature Overview

**Purpose**: Add `/code all` option to automatically execute all phases without user intervention.

**Problem**: Currently `/code [phase]` requires manual invocation for each phase. For projects with many phases, this interrupts automation workflows.

**Solution**: Extend SKILL.md with `all` argument that orchestrates automatic execution of all phases in dependency order with worktree-based parallel execution.

---

## Architecture Decision

### Approach: Extend Existing SKILL.md

**Options Considered**:
1. Option A: Add new agent (`phase-orchestrator.md`) for orchestration logic
2. Option B: Extend SKILL.md directly with `/code all` section

**Decision**: Option B

**Rationale**:
- Single file modification minimizes complexity
- SKILL.md already contains phase handling logic
- No new agent registration needed
- Orchestration logic is documentation (prompts), not code

---

## Data Model

N/A - This feature adds documentation/workflow only, no data structures.

---

## File Structure

### Files to Modify
```
.claude/skills/code/SKILL.md  # Add /code all workflow section
```

### Files Already Created
```
claude_works/code-all/
├── SPEC.md                           # Requirements (done)
├── GLOBAL.md                         # This file
├── PHASE_1_PLAN_skill-update.md      # Implementation plan
└── PHASE_1_TEST.md                   # Verification checklist
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Update SKILL.md with /code all section | 🟢 Complete | - |

**Status Legend**:
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Complete
- ⚠️ Blocked

---

## Phase Dependencies

```
Phase 1 (single phase - no dependencies)
```

---

## Risk Mitigation

### Risk 1: Workflow Already Violated
**Impact**: Medium
**Mitigation**: Validate existing SKILL.md changes against PHASE_1_PLAN checklist. If compliant, mark complete. If not, fix discrepancies.

---

## Completion Criteria

Overall feature is complete when:
- [x] SKILL.md contains `/code all` section with all required subsections
- [x] Phase detection algorithm documented
- [x] Execution flow documented
- [x] Error handling documented
- [x] Output format documented
- [x] PHASE_1_TEST.md checklist all passed

---

## Next Steps

1. ✅ Created PHASE_1_PLAN_skill-update.md
2. ✅ Created PHASE_1_TEST.md
3. ✅ Validated existing SKILL.md against plan - ALL PASSED
4. ⏳ User review and commit
