# Phase 2: Reduce init-workflow.md Scope

## Objective

Remove sections that were moved to orchestrator.md and add "Init Phase Attitude" section to clarify init-xxx skill responsibilities.

## Prerequisites

- Phase 1 complete (orchestrator.md has routing, non-stop execution, etc.)

## Checklist

### 2.1 Update Generic Workflow Diagram

**Location**: "## Generic Workflow Diagram" section (around line 19)

**Action**: Remove Step 9 from diagram. Diagram should end at Step 8.

**Current diagram ends with**:
```
├─────────────────────────────────────────────────────────┤
│ 9. Next Step Selection                                  │
│    - Ask what to do next                                │
│    - Route to appropriate action                        │
└─────────────────────────────────────────────────────────┘
```

**New diagram ends with**:
```
│ 8. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Add Init Phase Attitude Section

**Location**: After "## Plan Mode Policy" section (around line 17)

**Action**: Add new section

```markdown
## Init Phase Attitude

init-xxx skills handle **init phase only** (Steps 1-8).

### Scope

- Gather requirements
- Analyze codebase
- Create branch and directory
- Draft and commit SPEC.md
- Present SPEC for user review

### Not In Scope

- Scope selection (orchestrator responsibility)
- Routing to next skill (orchestrator responsibility)
- Non-stop execution (orchestrator responsibility)

### Invocation Behavior

| Context | After Init Complete |
|---------|---------------------|
| Direct call (`/init-feature`) | Return to user. User decides next action. |
| Via orchestrator (`/start-new`) | Return to orchestrator. Orchestrator continues workflow. |
```

### 2.3 Update Mandatory Workflow Rules

**Location**: "## Mandatory Workflow Rules" section (around line 96)

**Action**: Update to reflect Steps 5-8 only (not Step 9)

**Current header**:
```markdown
### Steps 5-9 are MANDATORY
```

**New header**:
```markdown
### Steps 5-8 are MANDATORY
```

**Current content includes**:
```markdown
- Step 9: Ask "어디까지 진행할까요?" question
```

**Remove this line entirely.**

### 2.4 Update Prohibited Actions

**Location**: "### Prohibited Actions" subsection (around line 109)

**Action**: Remove Step 9 references

**Remove this line**:
```markdown
- Skip the Next Step Selection question
```

### 2.5 Update Correct Execution Order

**Location**: "### Correct Execution Order" subsection (around line 117)

**Action**: Remove steps 9 and 10

**Current**:
```markdown
9. **Ask Next Step Selection question** (MANDATORY)
10. Route based on user's explicit choice
```

**Remove these two lines.**

### 2.6 DELETE Next Step Selection Section

**Location**: "## Next Step Selection" section (around line 130)

**Action**: DELETE entire section (lines ~130-147)

```markdown
## Next Step Selection

After SPEC is approved, ask:

Question: "어디까지 진행할까요?"
Header: "진행 범위"
Options:
  - label: "Design"
    ...
```

### 2.7 DELETE Routing Section

**Location**: "## Routing" section (around line 149)

**Action**: DELETE entire section

```markdown
## Routing

| Selection | Action |
|-----------|--------|
...
```

### 2.8 DELETE Non-Stop Execution Section

**Location**: "## Non-Stop Execution" section (around line 158)

**Action**: DELETE entire section including all subsections:
- Execution Rules
- Scope-to-Skill Chain Mapping
- CLAUDE.md Rule Overrides
- On Error
- Progress Indicator
- Final Summary Report

This is approximately lines 158-235 (everything from "## Non-Stop Execution" to end of file).

## File Modifications Summary

| Section | Action | Notes |
|---------|--------|-------|
| Plan Mode Policy | KEEP | No changes |
| Init Phase Attitude | ADD | New section after Plan Mode Policy |
| Generic Workflow Diagram | MODIFY | Remove Step 9 |
| Analysis Phase Workflow | KEEP | No changes |
| Mandatory Workflow Rules | MODIFY | Steps 5-8 only |
| Prohibited Actions | MODIFY | Remove Step 9 reference |
| Correct Execution Order | MODIFY | Remove steps 9-10 |
| Next Step Selection | DELETE | Entire section |
| Routing | DELETE | Entire section |
| Non-Stop Execution | DELETE | Entire section + subsections |

## Expected Result

init-workflow.md should contain approximately:
- Plan Mode Policy
- Init Phase Attitude (NEW)
- Generic Workflow Diagram (Steps 1-8 only)
- Analysis Phase Workflow
- Mandatory Workflow Rules (Steps 5-8)

Estimated final size: ~120-130 lines (from current ~235 lines)

## Completion Criteria

- [ ] Generic Workflow Diagram ends at Step 8 (no Step 9)
- [ ] Init Phase Attitude section added with scope, not-in-scope, invocation behavior
- [ ] Mandatory Workflow Rules references Steps 5-8 only
- [ ] No "어디까지 진행할까요?" text anywhere in file
- [ ] No "## Routing" section
- [ ] No "## Non-Stop Execution" section
- [ ] File ends after Mandatory Workflow Rules section
