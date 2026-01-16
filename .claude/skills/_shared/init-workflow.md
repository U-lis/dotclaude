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
- Step 8: Ask "다음으로 진행할 작업은?" question

### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Bypass SPEC.md file creation
- Skip the Next Step Selection question
- Start coding without user explicitly selecting "기능 개발"
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
Question: "다음으로 진행할 작업은?"
Header: "다음 작업"
Options:
  - label: "Design"
    description: "GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md 작성"
  - label: "기능 개발"
    description: "Phase 선택 후 코드 구현"
  - label: "main merge 및 branch 정리"
    description: "현재 브랜치를 main에 병합"
  - label: "CHANGELOG 작성"
    description: "새 버전을 위한 CHANGELOG 업데이트"
  - label: "새 버전 태깅"
    description: "git tag로 새 버전 생성"
multiSelect: false
```

### If "기능 개발" selected:

```
Question: "현재 {N}개 phase가 계획되어 있습니다. 어디까지 진행할까요?"
Header: "Phase 선택"
Options:
  - label: "전부 다"
    description: "모든 phase를 순서대로 진행"
  - label: "Phase 1까지: {name}"
    description: "Phase 1만 진행"
  - label: "Phase 2까지: {name}"
    description: "Phase 1-2 진행"
  - label: "Phase 3까지: {name}"
    description: "Phase 1-3 진행"
  ...
multiSelect: false
```

Note: Single selection. Each option includes all previous phases due to dependencies.

## Routing

| Selection | Action |
|-----------|--------|
| Design | Invoke `/design` skill |
| 기능 개발 | Invoke `/code` with selected phase range |
| main merge | Execute merge workflow |
| CHANGELOG | Invoke changelog writing workflow |
| 새 버전 태깅 | Execute git tag workflow |
