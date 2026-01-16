---
name: init-refactor
description: Initialize refactoring work by gathering refactor details through step-by-step questions. Use when starting refactoring work or when routed from /start-new.
user-invocable: true
---

# /init-refactor

Initialize refactoring work by gathering refactor details through step-by-step questions.

## Trigger

User invokes `/init-refactor` or is routed from `/start-new` (리팩토링 selected).

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Refactor Info (Step-by-Step)                  │
│    - 6 sequential questions using AskUserQuestion       │
│    - Understand target and goals                        │
├─────────────────────────────────────────────────────────┤
│ 2. Auto-Generate Branch Keyword                         │
│    - Extract core target from conversation              │
│    - No user question needed                            │
├─────────────────────────────────────────────────────────┤
│ 3. Create Refactor Branch                               │
│    - git checkout -b refactor/{keyword}                 │
├─────────────────────────────────────────────────────────┤
│ 4. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 5. Draft SPEC.md                                        │
│    - Use refactor-specific template                     │
│    - Include XP principles reference                    │
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
3. Create branch: `git checkout -b refactor/{keyword}`
4. Create directory: `mkdir -p claude_works/{subject}`
5. **Create SPEC.md file** (MANDATORY)
6. **Commit SPEC.md** (MANDATORY)
7. **Present SPEC.md for user review** (MANDATORY)
8. **Ask Next Step Selection question** (MANDATORY)
9. Route based on user's explicit choice

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 대상
```
Question: "리팩토링 대상은 무엇인가요?"
Header: "리팩토링 대상"
→ Free text (파일, 모듈, 클래스, 함수 등)
```

### Step 2: 문제점
```
Question: "현재 어떤 문제가 있나요?"
Header: "문제점"
Options:
  - label: "중복 코드 (DRY 위반)"
    description: "같은 로직이 여러 곳에 반복됨"
  - label: "긴 메서드/클래스 (SRP 위반)"
    description: "하나의 단위가 너무 많은 책임을 가짐"
  - label: "복잡한 조건문"
    description: "if/switch 문이 복잡하게 중첩됨"
  - label: "강한 결합도"
    description: "모듈간 의존성이 높음"
  - label: "테스트 어려움"
    description: "유닛 테스트 작성이 어려움"
multiSelect: true
```

### Step 3: 목표 상태
```
Question: "리팩토링 후 기대하는 상태는?"
Header: "목표"
→ Free text (목표 아키텍처, 패턴 등)
```

### Step 4: 동작 변경
```
Question: "기존 동작이 변경되어도 괜찮나요?"
Header: "동작 변경"
Options:
  - label: "동작 유지 필수"
    description: "순수 리팩토링, 기능 변경 없음"
  - label: "일부 변경 가능"
    description: "개선을 위해 동작 변경 허용"
multiSelect: false
```

### Step 5: 테스트 현황
```
Question: "관련된 테스트가 있나요?"
Header: "테스트"
Options:
  - label: "있음"
    description: "테스트 커버리지 확보됨"
  - label: "일부 있음"
    description: "부분적으로 테스트 존재"
  - label: "없음"
    description: "테스트 먼저 작성 필요"
multiSelect: false
```

### Step 6: 의존 모듈
```
Question: "이 코드를 사용하는 다른 모듈이 있나요?"
Header: "의존성"
Options:
  - label: "없음/모름"
    description: "다른 모듈에서 사용 안함 또는 파악 필요"
→ Or free text via "Other"
```

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core target from answers (Step 1)
- Format: `refactor/{keyword}`
- Examples:
  - refactor/user-service
  - refactor/extract-api-client
  - refactor/simplify-auth-flow

## Output

1. Refactor branch `refactor/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with refactor-specific format:
   - Target (from Step 1)
   - Current Problems (from Step 2)
   - Goal State (from Step 3)
   - Behavior Change Policy (from Step 4)
   - Test Coverage (from Step 5)
   - Dependencies (from Step 6)
   - XP Principle Reference (auto-added based on problems)

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
