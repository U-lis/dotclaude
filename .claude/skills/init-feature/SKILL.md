---
name: init-feature
description: Initialize a new feature by gathering requirements and creating SPEC document. Use when starting a new feature, project initialization, or when user invokes /init-feature.
user-invocable: true
---

# /init-feature

Initialize a new feature by gathering requirements through step-by-step questions.

## Trigger

User invokes `/init-feature` or is routed from `/start-new`.

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Requirements (Step-by-Step)                   │
│    - 8 sequential questions using AskUserQuestion       │
│    - Each question builds on previous answers           │
├─────────────────────────────────────────────────────────┤
│ 2. Auto-Generate Branch Keyword                         │
│    - Extract core concept from conversation             │
│    - No user question needed                            │
├─────────────────────────────────────────────────────────┤
│ 3. Create Feature Branch                                │
│    - git checkout -b feature/{keyword}                  │
├─────────────────────────────────────────────────────────┤
│ 4. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 5. Draft SPEC.md                                        │
│    - Use TechnicalWriter agent                          │
│    - Write initial specification                        │
├─────────────────────────────────────────────────────────┤
│ 6. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
├─────────────────────────────────────────────────────────┤
│ 7. Next Step Selection                                  │
│    - Ask what to do next                                │
│    - Route to appropriate action                        │
└─────────────────────────────────────────────────────────┘
```

## Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of plan mode or permission settings.

### Steps 5-7 are MANDATORY
These steps CANNOT be skipped under any circumstances:
- Step 5: Create SPEC.md file in `claude_works/{subject}/`
- Step 6: Present SPEC.md to user and get approval
- Step 7: Ask "다음으로 진행할 작업은?" question

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
3. Create branch: `git checkout -b feature/{keyword}`
4. Create directory: `mkdir -p claude_works/{subject}`
5. **Create SPEC.md file** (MANDATORY)
6. **Present SPEC.md for user review** (MANDATORY)
7. **Ask Next Step Selection question** (MANDATORY)
8. Route based on user's explicit choice

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 목표
```
Question: "이 기능의 주요 목표는 무엇인가요?"
Header: "목표"
→ Free text response
```

### Step 2: 문제
```
Question: "어떤 문제를 해결하려고 하나요?"
Header: "문제"
→ Free text response
```

### Step 3: 핵심 기능
```
Question: "반드시 있어야 하는 핵심 기능은 무엇인가요?"
Header: "핵심 기능"
→ Free text (can list multiple)
```

### Step 4: 부가 기능
```
Question: "있으면 좋지만 필수는 아닌 기능이 있나요?"
Header: "부가 기능"
Options:
  - label: "없음"
    description: "필수 기능만 구현"
→ Or free text via "Other"
```

### Step 5: 기술 제약
```
Question: "기술적 제약이 있나요?"
Header: "기술 제약"
Options:
  - label: "언어/프레임워크 지정"
    description: "특정 기술 스택 사용 필요"
  - label: "기존 패턴 따르기"
    description: "코드베이스의 기존 패턴 준수"
  - label: "제약 없음"
    description: "자유롭게 구현 가능"
multiSelect: false
```

### Step 6: 성능 요구
```
Question: "성능 요구사항이 있나요?"
Header: "성능"
Options:
  - label: "있음"
    description: "상세 내용을 입력해주세요"
  - label: "없음"
    description: "특별한 성능 요구사항 없음"
multiSelect: false
```

### Step 7: 보안 고려
```
Question: "보안 고려사항이 있나요?"
Header: "보안"
Options:
  - label: "인증/인가 필요"
    description: "사용자 인증 또는 권한 검증 필요"
  - label: "데이터 암호화"
    description: "민감 데이터 암호화 필요"
  - label: "입력 검증"
    description: "사용자 입력 검증 필요"
  - label: "없음"
    description: "특별한 보안 요구사항 없음"
multiSelect: true
```

### Step 8: 범위 제외
```
Question: "명시적으로 범위에서 제외할 것은?"
Header: "범위 제외"
Options:
  - label: "없음"
    description: "제외할 항목 없음"
→ Or free text via "Other"
```

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core concept from answers (Steps 1-3)
- Format: `feature/{keyword}`
- Examples:
  - feature/external-api
  - feature/user-metrics
  - feature/step-by-step-init

## Output

1. Feature branch `feature/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with:
   - Overview (from Steps 1-2)
   - Functional Requirements (from Steps 3-4)
   - Non-Functional Requirements (from Steps 6-7)
   - Constraints (from Step 5)
   - Out of Scope (from Step 8)

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
