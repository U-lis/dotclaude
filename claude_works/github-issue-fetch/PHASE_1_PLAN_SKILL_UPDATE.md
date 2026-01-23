# Phase 1: SKILL.md Update

## Objective

Add "GitHub Issue" as 4th option in Step 1 work type selection of `/dc:start-new`.

## Prerequisites

- None

## Instructions

### 1. Modify Step 1 AskUserQuestion

In `.claude/skills/start-new/SKILL.md`, find the Step 1 options section (around line 38-45) and add a 4th option:

```yaml
options:
  - { label: "기능 추가/수정", description: "새로운 기능 개발 또는 기존 기능 개선" }
  - { label: "버그 수정", description: "발견된 버그나 오류 수정" }
  - { label: "리팩토링", description: "기능 변경 없이 코드 구조 개선" }
  - { label: "GitHub Issue", description: "GitHub 이슈 URL로 자동 초기화" }  # ADD THIS
```

### 2. Update Step 2 Routing Table

In the same file, find the Step 2 routing table (around line 49-55) and add a new row:

```markdown
| User Selection | Init File to Read |
|----------------|-------------------|
| 기능 추가/수정 | Read `init-feature.md` from this skill directory |
| 버그 수정 | Read `init-bugfix.md` from this skill directory |
| 리팩토링 | Read `init-refactor.md` from this skill directory |
| GitHub Issue | Read `init-github-issue.md` from this skill directory |  # ADD THIS
```

## Completion Checklist

- [ ] Add 4th option "GitHub Issue" to Step 1 AskUserQuestion options
- [ ] Add routing entry for "GitHub Issue" in Step 2 table
- [ ] Verify existing 3 options remain unchanged
- [ ] Verify option label matches exactly for routing

## Notes

- The option label "GitHub Issue" must match exactly in both Step 1 and Step 2 for routing to work
- Keep Korean descriptions for consistency with existing options
