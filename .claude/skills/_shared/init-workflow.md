# Common Init Workflow

This file defines the shared workflow for all init-xxx skills (init-feature, init-bugfix, init-refactor).

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
│ 5. Draft SPEC.md                                        │
│    - Use TechnicalWriter agent                          │
│    - Write initial specification                        │
├─────────────────────────────────────────────────────────┤
│ 6. Commit SPEC.md                                       │
│    - git add claude_works/{subject}/SPEC.md             │
│    - git commit -m "docs: add SPEC.md for {subject}"    │
├─────────────────────────────────────────────────────────┤
│ 7. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
├─────────────────────────────────────────────────────────┤
│ 8. Next Step Selection                                  │
│    - Ask what to do next                                │
│    - Route to appropriate action                        │
└─────────────────────────────────────────────────────────┘
```

## Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of plan mode or permission settings.

### Steps 5-8 are MANDATORY
These steps CANNOT be skipped under any circumstances:
- Step 5: Create SPEC.md file in `claude_works/{subject}/`
- Step 6: Commit SPEC.md with git add/commit
- Step 7: Present SPEC.md to user and get approval
- Step 8: Ask "어디까지 진행할까요?" question

### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
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
5. **Create SPEC.md file** (MANDATORY)
6. **Commit SPEC.md** (MANDATORY)
7. **Present SPEC.md for user review** (MANDATORY)
8. **Ask Next Step Selection question** (MANDATORY)
9. Route based on user's explicit choice

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
