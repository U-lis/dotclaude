---
name: init-bugfix
description: Initialize bug fix work by gathering bug details through step-by-step questions. Use when starting bug fix work or when routed from /start-new.
user-invocable: true
---

# /init-bugfix

Initialize bug fix work by gathering bug details through step-by-step questions.

## Trigger

User invokes `/init-bugfix` or is routed from `/start-new` (버그 수정 selected).

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Bug Info (Step-by-Step)                       │
│    - 6 sequential questions using AskUserQuestion       │
│    - Understand bug symptoms and context                │
├─────────────────────────────────────────────────────────┤
│ 2. Auto-Generate Branch Keyword                         │
│    - Extract core issue from conversation               │
│    - No user question needed                            │
├─────────────────────────────────────────────────────────┤
│ 3. Create Bugfix Branch                                 │
│    - git checkout -b bugfix/{keyword}                   │
├─────────────────────────────────────────────────────────┤
│ 4. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 5. Draft SPEC.md                                        │
│    - Use bug-specific template                          │
│    - Include reproduction steps                         │
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
3. Create branch: `git checkout -b bugfix/{keyword}`
4. Create directory: `mkdir -p claude_works/{subject}`
5. **Create SPEC.md file** (MANDATORY)
6. **Present SPEC.md for user review** (MANDATORY)
7. **Ask Next Step Selection question** (MANDATORY)
8. Route based on user's explicit choice

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 증상
```
Question: "어떤 버그/문제가 발생하고 있나요?"
Header: "버그 증상"
→ Free text (증상 설명)
```

### Step 2: 재현 조건
```
Question: "버그가 발생하는 조건이나 재현 단계가 있나요?"
Header: "재현 조건"
→ Free text (재현 단계)
```

### Step 3: 예상 원인
```
Question: "예상되는 원인이 있나요?"
Header: "예상 원인"
Options:
  - label: "특정 코드 의심"
    description: "특정 파일이나 함수가 원인으로 의심됨"
  - label: "외부 의존성 문제"
    description: "라이브러리나 외부 서비스 관련 문제"
  - label: "설정 오류"
    description: "환경 설정이나 config 문제"
  - label: "모르겠음"
    description: "원인 파악이 필요함"
multiSelect: false
```

### Step 4: 심각도
```
Question: "버그의 심각도는 어느 정도인가요?"
Header: "심각도"
Options:
  - label: "Critical"
    description: "서비스 불가 또는 데이터 손실 위험"
  - label: "Major"
    description: "주요 기능 장애"
  - label: "Minor"
    description: "불편함이 있으나 우회 가능"
  - label: "Trivial"
    description: "미미한 문제"
multiSelect: false
```

### Step 5: 관련 파일
```
Question: "관련된 파일이나 모듈을 알고 있나요?"
Header: "관련 파일"
Options:
  - label: "모름"
    description: "조사가 필요함"
→ Or free text via "Other" (파일 경로 입력)
```

### Step 6: 영향 범위
```
Question: "이 버그가 영향을 주는 다른 기능이 있나요?"
Header: "영향 범위"
Options:
  - label: "없음/모름"
    description: "다른 기능에 영향 없거나 파악 필요"
→ Or free text via "Other"
```

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core issue from answers (Steps 1-2)
- Format: `bugfix/{keyword}`
- Examples:
  - bugfix/wrong-script-path
  - bugfix/null-pointer-exception
  - bugfix/login-timeout

## Output

1. Bugfix branch `bugfix/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with bug-specific format:
   - Bug Description (from Step 1)
   - Reproduction Steps (from Step 2)
   - Expected Cause (from Step 3)
   - Severity (from Step 4)
   - Related Files (from Step 5)
   - Impact Scope (from Step 6)

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
