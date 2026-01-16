---
name: init-bugfix
description: Initialize bug fix work by gathering bug details through step-by-step questions. Use when starting bug fix work or when routed from /start-new.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-bugfix

Initialize bug fix work by gathering bug details through step-by-step questions.

**IMPORTANT**: Read `_shared/init-workflow.md` first. This skill follows the common init workflow.

## Trigger

User invokes `/init-bugfix` or is routed from `/start-new` (버그 수정 selected).

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
