---
name: init-refactor
description: Initialize refactoring work by gathering refactor details through step-by-step questions. Use when starting refactoring work or when routed from /start-new.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-refactor

Initialize refactoring work by gathering refactor details through step-by-step questions.

**IMPORTANT**: Read `_shared/init-workflow.md` first. This skill follows the common init workflow.

**CRITICAL**: Do NOT use plan mode (EnterPlanMode). Proceed directly through all workflow steps.

## Trigger

User invokes `/init-refactor` or is routed from `/start-new` (리팩토링 selected).

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
