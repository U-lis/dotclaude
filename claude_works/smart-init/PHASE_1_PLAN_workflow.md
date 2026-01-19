# Phase 1: Update Shared Init Workflow

## Objective
Update `_shared/init-workflow.md` to include new analysis phases (A-E) after question gathering.

## Prerequisites
- None (first phase)

## Instructions

### Step 1: Add Analysis Phase Diagram
Insert new analysis workflow diagram after "Generic Workflow Diagram" section:

```
Location: After line ~52 (after Generic Workflow Diagram closing fence)
```

Add new section "Analysis Phase Workflow" with diagram showing:
- Step A: Input Analysis
- Step B: Codebase Investigation
- Step C: Conflict Detection
- Step D: Edge Case Generation
- Step E: Summary + Clarification Loop

### Step 2: Update Workflow Steps
Modify the numbered workflow to insert analysis phases between step 4 (Create Project Structure) and step 5 (Draft SPEC.md):

Current:
```
4. Create Project Structure
5. Draft SPEC.md
```

New:
```
4. Create Project Structure
5. Analysis Phase (Steps A-E) - See analysis-phases.md
6. Draft SPEC.md (now includes Analysis Results)
```

Update all subsequent step numbers accordingly.

### Step 3: Add Analysis Phase Reference
Add instruction at step 5 (new):

```markdown
## Step 5: Analysis Phase

**MANDATORY**: Before creating SPEC.md, execute analysis phases A-E.

See `_shared/analysis-phases.md` for detailed instructions.

Summary:
- Step A: Input Analysis - identify gaps and ambiguities
- Step B: Codebase Investigation - search for related code
- Step C: Conflict Detection - compare against existing implementation
- Step D: Edge Case Generation - generate boundary conditions
- Step E: Summary + Clarification - iterate with user until confirmed
```

### Step 4: Update Mandatory Rules
In "Mandatory Workflow Rules" section, update step numbers and add:

```markdown
### Step 5 (Analysis Phase) is MANDATORY
MUST execute all analysis sub-phases (A-E) before creating SPEC.md.
Iteration limits apply to prevent infinite loops.
```

### Step 5: Update Next Step Selection
Ensure "어디까지 진행할까요?" question appears AFTER SPEC.md creation (now step 8).

## Completion Checklist
- [ ] Analysis workflow diagram added
- [ ] Analysis phase (Step 5) inserted between structure creation and SPEC creation
- [ ] Step numbers updated throughout document
- [ ] Mandatory rules section updated
- [ ] Reference to analysis-phases.md added
- [ ] All subsequent step numbers incremented correctly

## Notes
- This phase establishes the framework; actual analysis logic defined in Phase 2
- All three init skills will reference these shared workflow steps
