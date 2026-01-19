# Init Flow Cleanup - Orchestrator and Init-xxx Common Flow Refactoring

## Overview

### Goal
Clarify responsibility boundaries between orchestrator and init-xxx skills by consolidating duplicated workflow sections and establishing clear ownership.

### Problem Statement

Current state exhibits multiple code smells:

| Code Smell | Location | Description |
|------------|----------|-------------|
| DRY violation | orchestrator.md + init-workflow.md | Next Step Selection (Step 9) duplicated with same options |
| SRP violation | init-xxx skills | Performs both SPEC creation AND scope selection + routing |
| Unclear ownership | orchestrator.md vs init-workflow.md | Routing, non-stop execution, progress indicator ownership unclear |

### Target State

Clear separation of concerns:

| Component | Responsibility |
|-----------|----------------|
| orchestrator.md | Full 13-step workflow, Scope Selection, routing, non-stop execution |
| init-workflow.md | Init phase attitude, mandatory tasks, required questions, init phase flow (Steps 1-8 only) |
| init-xxx SKILL.md | Work-type specific questions, analysis focus, SPEC structure only |

## Functional Requirements

### FR-1: Consolidate Workflow Sections to Orchestrator

Move from init-workflow.md to orchestrator.md:

| Section | Current Location | Target Location |
|---------|-----------------|-----------------|
| Next Step Selection (Step 9) | init-workflow.md | orchestrator.md (already exists as Step 5) |
| Routing section | init-workflow.md | orchestrator.md (new) |
| Non-Stop Execution section | init-workflow.md | orchestrator.md (new) |
| CLAUDE.md Rule Overrides | init-workflow.md | orchestrator.md (new) |
| Progress Indicator | init-workflow.md | orchestrator.md (merge with existing) |
| Final Summary Report | init-workflow.md | orchestrator.md (new) |

### FR-2: Reduce init-workflow.md Scope

Retain in init-workflow.md:

| Section | Purpose |
|---------|---------|
| Plan Mode Policy | Prevent init skills from using EnterPlanMode |
| Init Phase Attitude (NEW) | Explicitly state init-xxx only handles init phase |
| Generic Workflow Diagram | Steps 1-8 only (remove Step 9) |
| Analysis Phase Workflow | Reference to analysis-phases.md |
| Mandatory Workflow Rules | Steps 5-8 validation (adjust numbering) |

### FR-3: Clarify init-xxx Behavior by Invocation Context

Add clarification to each init-xxx SKILL.md:

| Invocation | Behavior |
|------------|----------|
| Direct call (user invokes `/init-feature`) | Complete init phase only, return control to user |
| Via orchestrator (routed from `/start-new`) | Complete init phase, return to orchestrator for continued workflow |

### FR-4: Update Orchestrator Integration

Orchestrator modifications:

| Item | Action |
|------|--------|
| Scope Selection | Keep existing Step 5 |
| Routing logic | Add from init-workflow.md |
| Non-stop execution rules | Add from init-workflow.md |
| Progress indicator | Merge format from init-workflow.md |
| Final summary report | Add from init-workflow.md |
| CLAUDE.md overrides | Add from init-workflow.md |

## Migration Details

### From init-workflow.md to orchestrator.md

#### Next Step Selection (remove duplicate)

Current in init-workflow.md (Step 9):
```markdown
After SPEC is approved, ask:
Question: "어디까지 진행할까요?"
...
```

Action: DELETE from init-workflow.md. Already exists in orchestrator.md as Step 5.

#### Routing Section

Current in init-workflow.md:
```markdown
## Routing
| Selection | Action |
| Design | Invoke `/design` |
...
```

Action: MOVE to orchestrator.md. Add as new section after Step 5.

#### Non-Stop Execution Section

Current in init-workflow.md:
```markdown
## Non-Stop Execution
When user selects a scope with multiple steps...
### Execution Rules
### Scope-to-Skill Chain Mapping
### CLAUDE.md Rule Overrides
### On Error
```

Action: MOVE entire section to orchestrator.md.

#### Progress Indicator

Current in init-workflow.md:
```markdown
### Progress Indicator
During multi-skill execution, display:
═══════════════════════════════════════════════════════════
[Step 2/4] Code implementation
...
```

Action: MERGE with existing orchestrator.md Progress Reporting section.

#### Final Summary Report

Current in init-workflow.md:
```markdown
### Final Summary Report
After all skills complete, display:
# Workflow Complete
...
```

Action: MOVE to orchestrator.md. Integrate with Output Contract section.

### Changes to init-workflow.md

#### Update Workflow Diagram

Remove Step 9 from diagram:
```markdown
## Generic Workflow Diagram
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Requirements (Step-by-Step)                   │
...
│ 8. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
└─────────────────────────────────────────────────────────┘
```
Note: Diagram ends at Step 8. No Step 9.

#### Add Init Phase Attitude Section

New section after Plan Mode Policy:
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

#### Update Mandatory Workflow Rules

Adjust to Steps 5-8 only (no Step 9):
```markdown
### Steps 5-8 are MANDATORY
- Step 5: **Analysis Phase (A-E)**
- Step 6: Create SPEC.md file
- Step 7: Commit SPEC.md
- Step 8: Present SPEC.md to user and get approval
```

Remove Step 9 from prohibited actions:
```markdown
### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Skip Analysis Phase (Steps A-E)
- Bypass SPEC.md file creation
- Start coding without user explicitly selecting a scope that includes "Code"
```

### Changes to init-xxx SKILL.md Files

Add to each (init-feature, init-bugfix, init-refactor):

#### Invocation Behavior Section

After "## Trigger" section:
```markdown
## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/init-feature`) | Complete init phase (Steps 1-8), return control to user |
| Via orchestrator | Complete init phase, return to orchestrator for workflow continuation |

When called directly, this skill completes after SPEC review (Step 8). User must manually invoke subsequent skills if needed.
```

#### Update Output Section

Clarify output is init phase completion only:
```markdown
## Output

Init phase artifacts:
1. Branch `{type}/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` created and committed
4. SPEC.md reviewed and approved by user

**Note**: Scope selection and subsequent workflow handled by orchestrator when invoked via `/start-new`.
```

#### Update Workflow Integration Section

Simplify to reflect init phase only:
```markdown
## Workflow Integration

This skill handles Steps 1-8 of the init phase:
1. Requirements gathering (skill-specific questions)
2. Branch keyword generation
3. Branch and directory creation
4. Analysis Phase (A-E)
5. SPEC.md creation
6. SPEC.md commit
7. User review

See `_shared/init-workflow.md` for init phase details.
See `orchestrator.md` for full workflow (when invoked via /start-new).
```

## Non-Functional Requirements

### NFR-1: No Backward Compatibility Required
- Direct init-xxx calls change behavior: no scope selection after init
- Users expecting scope selection must use `/start-new`

### NFR-2: Clear Documentation
- Each file clearly states its responsibility scope
- Cross-references point to correct location for related functionality

### NFR-3: Token Efficiency
- Remove duplicate content entirely (not just comment out)
- Keep sections concise after consolidation

## Constraints

- analysis-phases.md remains unchanged
- init-xxx hooks remain unchanged
- orchestrator 13-step numbering preserved (only content changes)

## Out of Scope

- Changing orchestrator step numbers
- Modifying analysis-phases.md
- Adding new functionality
- Changing hook behavior

## Affected Files

| File | Change Type | Size |
|------|-------------|------|
| .claude/agents/orchestrator.md | Modify - add routing, non-stop execution, merge progress indicator | Medium |
| .claude/skills/_shared/init-workflow.md | Modify - remove ~40% content (routing, execution, progress, summary) | Large |
| .claude/skills/_shared/analysis-phases.md | None | - |
| .claude/skills/init-feature/SKILL.md | Modify - add invocation behavior, clarify scope | Small |
| .claude/skills/init-bugfix/SKILL.md | Modify - add invocation behavior, clarify scope | Small |
| .claude/skills/init-refactor/SKILL.md | Modify - add invocation behavior, clarify scope | Small |

## Success Criteria

1. orchestrator.md contains all workflow control sections (routing, non-stop execution, progress, summary)
2. init-workflow.md contains only init phase content (Steps 1-8)
3. No duplicate "Next Step Selection" exists
4. Each init-xxx SKILL.md clearly states invocation behavior
5. Direct `/init-feature` call completes at SPEC review without scope selection
6. `/start-new` workflow continues with scope selection after init phase

## Validation Checklist

| Item | Validation Method |
|------|-------------------|
| No DRY violation | Grep for "어디까지 진행할까요" - should appear only in orchestrator.md |
| Clear ownership | Each section appears in exactly one file |
| Direct call behavior | `/init-feature` ends after SPEC review |
| Orchestrator call behavior | `/start-new` → init skill → scope selection → continued workflow |
