# Phase 1: code-skill Enhancement

## Objective

Add "Mandatory Validation" section to `/code` skill with explicit enforcement language.

---

## Target File

`.claude/skills/code/SKILL.md`

---

## Instructions

### Step 1: Add Mandatory Validation Section

**Location**: After "## Workflow" section (line ~63), before "## Parallel Phase Handling"

**Content to Add**:

```markdown
## Mandatory Validation (CRITICAL)

**This section is NON-NEGOTIABLE. Validation MUST occur before commit.**

### Validation Requirements

After Coder completes implementation:

1. **MUST** invoke code-validator agent
2. **MUST** wait for validation result
3. **MUST** ensure checklist updates are complete before commit

### Validation Loop

```
┌─────────────────────────────────────────────────────────┐
│ Coder completes implementation                          │
│         ↓                                               │
│ Invoke code-validator                                   │
│         ↓                                               │
│ Validation passed? ──NO──→ Coder fixes (attempt N/3)   │
│         │                         ↓                     │
│        YES                  Retry validation            │
│         ↓                         │                     │
│ code-validator updates:           │                     │
│   - PHASE_{k}_PLAN.md checklist   │                     │
│   - GLOBAL.md phase status        │                     │
│         ↓                         │                     │
│ Proceed to commit ←───────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### Pre-Commit Checklist

Before `git add` and `git commit`:

- [ ] code-validator invoked and completed
- [ ] All items in PHASE_{k}_PLAN.md checked off
- [ ] GLOBAL.md phase status updated to "Complete"
- [ ] Quality checks passed (linter, type check, tests)

**DO NOT commit if any item above is unchecked.**
```

---

## Completion Checklist

- [ ] "## Mandatory Validation (CRITICAL)" section exists
- [ ] Validation Requirements subsection with 3 MUST rules
- [ ] Validation Loop diagram added
- [ ] Pre-Commit Checklist with 4 items
- [ ] "DO NOT commit" warning at end
