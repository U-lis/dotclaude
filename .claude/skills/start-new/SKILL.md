---
name: start-new
description: Entry point for starting new work. Calls orchestrator agent to manage entire workflow.
user-invocable: true
---

# /start-new

Entry point for starting any new work. Routes to appropriate init skill based on work type selection.

## Trigger

User invokes `/start-new` to begin any new work.

## Workflow

```
User: /start-new
         ↓
AskUserQuestion → Work Type Selection
         ↓
Route to appropriate init skill:
  - Feature → /init-feature
  - Bugfix → /init-bugfix
  - Refactor → /init-refactor
         ↓
Init skill handles remaining workflow
```

## Step 1: Work Type Selection

IMPORTANT: Use AskUserQuestion directly (subagents cannot use this tool).

```
AskUserQuestion:
  question: "어떤 작업을 시작하려고 하나요?"
  header: "작업 유형"
  options:
    - label: "기능 추가/수정"
      description: "새로운 기능 개발 또는 기존 기능 개선"
    - label: "버그 수정"
      description: "발견된 버그나 오류 수정"
    - label: "리팩토링"
      description: "기능 변경 없이 코드 구조 개선"
  multiSelect: false
```

## Step 2: Route to Init Skill

Based on user selection, invoke the appropriate Skill:

| Selection | Skill to invoke |
|-----------|-----------------|
| 기능 추가/수정 | `Skill: init-feature` |
| 버그 수정 | `Skill: init-bugfix` |
| 리팩토링 | `Skill: init-refactor` |

Each init skill handles:
- Work-type-specific questions (via AskUserQuestion)
- Branch and directory creation
- Target version selection
- SPEC.md creation via TechnicalWriter
- SPEC review and iteration
- Scope selection
- Design, code, docs, merge phases

## Output

Each init skill returns its own summary. Display the result to the user.

## Direct Skill Access

Individual skills can be invoked directly if needed:

| Command | Description |
|---------|-------------|
| `/init-feature` | Start new feature work |
| `/init-bugfix` | Start bugfix work |
| `/init-refactor` | Start refactoring work |
| `/design` | Direct design phase execution |
| `/code [phase]` | Direct phase code execution |
| `/merge-main` | Direct merge to main |

Use direct access when:
- Resuming partial work
- Testing individual components
- Skipping work type selection
