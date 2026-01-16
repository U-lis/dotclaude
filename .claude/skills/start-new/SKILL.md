---
name: start-new
description: Entry point for starting new work. Routes to appropriate init skill based on work type.
user-invocable: true
---

# /start-new

Entry point for starting any new work. Routes to the appropriate initialization skill based on work type.

## Trigger

User invokes `/start-new` or wants to start new work (feature, bugfix, refactor).

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Ask Work Type                                        │
│    - Use AskUserQuestion tool                           │
│    - Single selection                                   │
├─────────────────────────────────────────────────────────┤
│ 2. Route to Appropriate Skill                           │
│    - 기능 추가/수정 → /init-feature                      │
│    - 버그 수정 → /init-bugfix                           │
│    - 리팩토링 → /init-refactor                          │
│    - 직접입력 → Handle manually                         │
└─────────────────────────────────────────────────────────┘
```

## Question

Use AskUserQuestion tool:

```
Question: "어떤 작업을 시작하려고 하나요?"
Header: "작업 유형"
Options:
  - label: "기능 추가/수정"
    description: "새로운 기능 개발 또는 기존 기능 개선"
  - label: "버그 수정"
    description: "발견된 버그나 오류 수정"
  - label: "리팩토링"
    description: "기능 변경 없이 코드 구조 개선"
multiSelect: false
```

## Routing

| Selection | Action |
|-----------|--------|
| 기능 추가/수정 | Invoke `/init-feature` skill |
| 버그 수정 | Invoke `/init-bugfix` skill |
| 리팩토링 | Invoke `/init-refactor` skill |
| Other | Parse input and route or handle manually |

## Next Steps

After routing, the selected init-* skill will:
1. Gather detailed requirements (step-by-step questions)
2. Auto-generate branch keyword from conversation
3. Create feature/bugfix/refactor branch
4. Create claude_works/{subject}/ directory
5. Draft SPEC.md
6. Ask about next action
