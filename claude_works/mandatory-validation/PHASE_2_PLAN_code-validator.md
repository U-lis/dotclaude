# Phase 2: code-validator Enhancement

## Objective

Strengthen code-validator agent with mandatory checklist update instructions.

---

## Target File

`.claude/agents/code-validator.md`

---

## Instructions

### Step 1: Update Checklist Update Authority Section

**Location**: Replace "## Checklist Update Authority" section (lines 154-158)

**New Content**:

```markdown
## Checklist Update Authority (MANDATORY)

**These updates are REQUIRED, not optional.**

Upon successful validation:

### 1. Update PHASE_{k}_PLAN_{keyword}.md

**MUST** check off each completed item:

```markdown
## Completion Checklist

- [x] Item 1: Verified in {file}:{line}
- [x] Item 2: Verified in {file}:{line}
- [ ] Item 3: NOT implemented (if applicable)
```

### 2. Update GLOBAL.md Phase Overview

**MUST** update phase status in table:

```markdown
| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | ... | Complete | - |
```

Status values:
- `Not Started` → `In Progress` → `Complete`
- `Skipped` (if validation failed after 3 attempts)

### 3. Verification Before Reporting

Before reporting validation complete:

- [ ] All implemented items checked in PHASE_*_PLAN.md
- [ ] GLOBAL.md phase status updated
- [ ] Files actually modified (not just reported)

**DO NOT report completion without updating documents.**
```

---

## Completion Checklist

- [x] "## Checklist Update Authority (MANDATORY)" header
- [x] "MUST check off" instruction for PHASE_*_PLAN.md
- [x] "MUST update phase status" instruction for GLOBAL.md
- [x] Status values defined (Not Started, In Progress, Complete, Skipped)
- [x] "DO NOT report completion" warning
