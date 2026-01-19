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
├─────────────────────────────────────────────────────────┤
│ 8. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
├─────────────────────────────────────────────────────────┤
│ 9. Next Step Selection                                  │
│    - Ask what to do next                                │
│    - Route to appropriate action                        │
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

### Steps 5-9 are MANDATORY
These steps CANNOT be skipped under any circumstances:
- Step 5: **Analysis Phase (A-E)** - Execute all analysis sub-phases
- Step 6: Create SPEC.md file in `claude_works/{subject}/` (includes Analysis Results)
- Step 7: Commit SPEC.md with git add/commit
- Step 8: Present SPEC.md to user and get approval
- Step 9: Ask "어디까지 진행할까요?" question

### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Skip Analysis Phase (Steps A-E)
- Bypass SPEC.md file creation
- Skip the Next Step Selection question
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
9. **Ask Next Step Selection question** (MANDATORY)
10. Route based on user's explicit choice

## Next Step Selection

After SPEC is approved, ask:

```
Question: "어디까지 진행할까요?"
Header: "진행 범위"
Options:
  - label: "Design"
    description: "설계 문서만 작성 (GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md)"
  - label: "Design → Code"
    description: "설계 + 코드 구현"
  - label: "Design → Code → CHANGELOG"
    description: "설계 + 코드 구현 + CHANGELOG 작성"
  - label: "Design → Code → CHANGELOG → Merge"
    description: "설계 + 코드 + CHANGELOG + main 병합 및 브랜치 정리"
multiSelect: false
```

## Routing

| Selection | Action |
|-----------|--------|
| Design | Invoke `/design` |
| Design → Code | `/design`, then `/code all` |
| Design → Code → CHANGELOG | `/design`, `/code all`, changelog workflow |
| Design → Code → CHANGELOG → Merge | Full: design, code, changelog, merge, branch cleanup |

## Non-Stop Execution

When user selects a scope with multiple steps (e.g., "Design → Code"), execute all steps automatically without stopping.

### Execution Rules

1. **DO NOT** ask "What's next?" between chained skills
2. **DO NOT** wait for user input between steps
3. **MUST** proceed immediately to next skill in chain
4. **MUST** halt chain on error and report to user

### Scope-to-Skill Chain Mapping

| User Selection | Skill Chain |
|----------------|-------------|
| Design | `/design` → STOP |
| Design → Code | `/design` → `/code all` → STOP |
| Design → Code → CHANGELOG | `/design` → `/code all` → CHANGELOG → STOP |
| Design → Code → CHANGELOG → Merge | `/design` → `/code all` → CHANGELOG → `/merge-main` → STOP |

### CLAUDE.md Rule Overrides

During non-stop execution, these CLAUDE.md rules are suspended:

- **"Do NOT proceed to next phase without user instruction"**
  → User's scope selection IS the instruction to proceed

- **"Report summary upon completion and wait for user review"**
  → Report only at final STOP point, not between skills

### On Error

If any skill fails during chain:
1. STOP the chain immediately
2. Report error to user
3. Suggest manual resolution
4. User can resume by re-selecting scope

### Progress Indicator

During multi-skill execution, display:

```
═══════════════════════════════════════════════════════════
[Step 2/4] Code implementation
Current: Executing /code all
═══════════════════════════════════════════════════════════
```

### Final Summary Report

After all skills complete, display:

```markdown
# Workflow Complete

## Scope: {selected scope}

## Results

| Step | Skill | Status |
|------|-------|--------|
| 1 | /design | SUCCESS |
| 2 | /code all | SUCCESS |
| 3 | CHANGELOG | SUCCESS |
| 4 | /merge-main | SUCCESS |

## Files Changed
- claude_works/{subject}/*.md
- [implementation files...]
- CHANGELOG.md

## Next Steps
1. Review changes: `git log --oneline -10`
2. Push to remote: `git push origin main`
3. (Optional) Create tag: `/tagging`
```
