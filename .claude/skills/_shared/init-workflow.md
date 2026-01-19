# Common Init Workflow

This file defines the shared workflow for all init-xxx skills (init-feature, init-bugfix, init-refactor).

## Plan Mode Policy

**CRITICAL**: init-xxx skills MUST NOT use plan mode (EnterPlanMode).

Reasons:
- Plan mode is for implementation planning, not requirements gathering
- ExitPlanMode can cause workflow interruption
- User approval happens at SPEC.md review stage, not plan approval

Instead:
- Use AskUserQuestion for sequential requirements gathering
- Proceed directly through workflow steps
- User reviews and approves at Step 8 (SPEC.md review)

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

## Generic Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Requirements (Step-by-Step)                   │
│    - Sequential questions using AskUserQuestion         │
│    - Each question builds on previous answers           │
├─────────────────────────────────────────────────────────┤
│ 2. Auto-Generate Branch Keyword                         │
│    - Extract core concept from conversation             │
│    - No user question needed                            │
├─────────────────────────────────────────────────────────┤
│ 3. Create Work Branch                                   │
│    - git checkout -b {type}/{keyword}                   │
├─────────────────────────────────────────────────────────┤
│ 4. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 5. Analysis Phase (Steps A-E)                           │
│    - See analysis-phases.md for details                 │
│    - Input analysis, codebase investigation, conflicts  │
├─────────────────────────────────────────────────────────┤
│ 6. Draft SPEC.md                                        │
│    - Use TechnicalWriter agent                          │
│    - Include Analysis Results section                   │
├─────────────────────────────────────────────────────────┤
│ 7. Commit SPEC.md                                       │
│    - git add claude_works/{subject}/SPEC.md             │
│    - git commit -m "docs: add SPEC.md for {subject}"    │
│ 8. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
└─────────────────────────────────────────────────────────┘
```

## Analysis Phase Workflow

**MANDATORY**: Execute analysis phases A-E after gathering requirements and before creating SPEC.md.

See `_shared/analysis-phases.md` for detailed instructions.

```
┌─────────────────────────────────────────────────────────┐
│ Step A: Input Analysis                                  │
│    - Identify gaps and ambiguities in user responses    │
│    - Generate clarifying questions                      │
│    - Resolve via AskUserQuestion                        │
├─────────────────────────────────────────────────────────┤
│ Step B: Codebase Investigation                          │
│    - Search for related code and patterns               │
│    - Work-type specific analysis (see skill files)      │
│    - Max 10 file reads                                  │
├─────────────────────────────────────────────────────────┤
│ Step C: Conflict Detection                              │
│    - Compare requirements vs existing implementation    │
│    - Document and resolve conflicts with user           │
├─────────────────────────────────────────────────────────┤
│ Step D: Edge Case Generation                            │
│    - Generate boundary conditions and error scenarios   │
│    - User confirms or adds cases                        │
├─────────────────────────────────────────────────────────┤
│ Step E: Summary + Clarification                         │
│    - Present complete summary to user                   │
│    - Iterate until user confirms (max 3 iterations)     │
└─────────────────────────────────────────────────────────┘
```

**Iteration Limits**:
- Input clarification: max 5 questions per category
- Clarification loop: max 3 iterations
- Codebase search: max 10 file reads

## Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of plan mode or permission settings.

### Steps 5-8 are MANDATORY
These steps CANNOT be skipped under any circumstances:
- Step 5: **Analysis Phase (A-E)** - Execute all analysis sub-phases
- Step 6: Create SPEC.md file in `claude_works/{subject}/` (includes Analysis Results)
- Step 7: Commit SPEC.md with git add/commit
- Step 8: Present SPEC.md to user and get approval

### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Skip Analysis Phase (Steps A-E)
- Bypass SPEC.md file creation
- Start coding without user explicitly selecting a scope that includes "Code"
- Assume permission bypass means skipping workflow steps

### Correct Execution Order
Even with permission bypass, follow this exact order:
1. Gather requirements (Step-by-Step Questions)
2. Auto-generate branch keyword
3. Create branch: `git checkout -b {type}/{keyword}`
4. Create directory: `mkdir -p claude_works/{subject}`
5. **Analysis Phase (A-E)** (MANDATORY) - See analysis-phases.md
6. **Create SPEC.md file** (MANDATORY) - Include Analysis Results
7. **Commit SPEC.md** (MANDATORY)
8. **Present SPEC.md for user review** (MANDATORY)
