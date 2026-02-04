<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-init-invocation-fix
-->

# init-invocation-fix - Specification

**GitHub Issue**: [#52](https://github.com/U-lis/dotclaude/issues/52)
**Target Version**: 0.3.1
**Severity**: Major

## Overview

`/dotclaude:start-new` 오케스트레이터가 Step 1(작업 유형 선택) 완료 후, 해당하는 init-xxx 커맨드(예: `dotclaude:init-bugfix`, `dotclaude:init-feature`)를 호출하지 않는 버그를 수정한다. 현재 오케스트레이터는 init 커맨드를 로드하지 않고 즉흥적으로 질문을 생성하여, 전체 다운스트림 워크플로우(브랜치 생성, 분석, SPEC 작성 등)가 스킵된다.

## Bug Description (증상)

### 재현 절차

1. `/dotclaude:start-new` 실행
2. Step 1에서 "Bug Fix" (또는 다른 작업 유형) 선택
3. **예상 동작**: 오케스트레이터가 `dotclaude:init-bugfix`를 Skill 도구로 호출하여 구조화된 질문 흐름, 브랜치 생성, 분석 단계를 실행
4. **실제 동작**: 오케스트레이터가 ad-hoc 질문(예: "버그 제목이 무엇인가요?")을 생성하며 init-bugfix 내용을 로드하지 않음

### 영향 범위

init 커맨드가 호출되지 않으므로 모든 후속 워크플로우 단계가 스킵됨:

| 스킵되는 단계 | 설명 |
|---------------|------|
| 브랜치 생성 | bugfix/{keyword} 브랜치 + 워크트리 |
| 분석 단계 | init-bugfix에 정의된 분석 흐름 |
| Target version 질문 | Step 2.6 |
| SPEC.md 생성 | TechnicalWriter 위임 |
| SPEC review | 사용자 검토 (Step 3) |
| SPEC commit | git commit (Step 4) |
| Scope selection | AskUserQuestion (Step 5) |
| Checkpoint | 브랜치/SPEC/워크트리 검증 (Step 6) |
| Design | Designer + TechnicalWriter 위임 (Step 6-8) |
| Code | 오케스트레이터가 직접 코드 편집 (위임 규칙 위반, Step 10) |

## Root Cause Analysis

### 정확한 코드 위치

`commands/start-new.md` 라인 79-95 (Step 2: Load Init Instructions)

### 현재 코드 (문제)

```markdown
**Step 2: Load Init Instructions**

Based on Step 1 response, follow the corresponding init command (Claude auto-loads command content):

| User Selection | Init Command |
|----------------|--------------|
| Add/Modify Feature | Follow the `init-feature` command |
| Bug Fix | Follow the `init-bugfix` command |
| Refactoring | Follow the `init-refactor` command |
| GitHub Issue | Follow the `init-github-issue` command |
```

### 원인 분석

| # | 원인 | 설명 |
|---|------|------|
| 1 | 주요 원인 | "(Claude auto-loads command content)" 표현이 모호함. Claude가 직접 로드해야 하는지, 시스템이 자동 로드하는지 불명확 |
| 2 | 보조 원인 | init 커맨드 내용이 없을 때 즉흥적으로 질문을 생성하는 Claude의 행동 편향 |
| 3 | 3차 원인 | 호출 메커니즘(Skill 도구? 파일 읽기? Task 도구?)이 명시되지 않음 |

## Fix Strategy

이슈의 Option A(권장 수정안) 적용. Step 2의 텍스트를 수정하여 Skill 도구를 통한 명시적 호출 지시를 추가한다.

### 수정 내용

Step 2를 다음과 같이 변경:

```markdown
**Step 2: Load Init Instructions**

Based on Step 1 response, invoke the corresponding init command via the Skill tool:

| User Selection | Action |
|----------------|--------|
| Add/Modify Feature | `Skill("dotclaude:init-feature")` |
| Bug Fix | `Skill("dotclaude:init-bugfix")` |
| Refactoring | `Skill("dotclaude:init-refactor")` |
| GitHub Issue | `Skill("dotclaude:init-github-issue")` |

**CRITICAL**: Do NOT improvise questions. The init command defines its own question flow.
Wait for the Skill to load, then follow its instructions exactly.
```

### 수정 포인트 요약

1. "follow the corresponding init command (Claude auto-loads command content)" 텍스트를 "invoke the corresponding init command via the Skill tool"로 변경
2. 테이블 컬럼을 "Init Command" 에서 "Action"으로 변경하고 `Skill()` 호출 구문을 명시
3. "CRITICAL" 경고 추가: 질문을 즉흥적으로 생성하지 말 것
4. init 커맨드가 로드된 후 해당 지시를 정확히 따르도록 명시

## Affected Code Locations

| # | 파일 | 라인 | 관계 |
|---|------|------|------|
| 1 | `commands/start-new.md` | 79-95 | Step 2: 모호한 init 커맨드 로딩 지시 (수정 대상) |

## Functional Requirements

- [ ] FR-1: Step 2에서 Skill 도구를 통한 명시적 init-xxx 커맨드 호출 지시로 텍스트 변경
- [ ] FR-2: 즉흥 질문 생성 금지에 대한 CRITICAL 경고 추가

## Non-Functional Requirements

- [ ] NFR-1: 기존 워크플로우(Step 3 이후)에 영향 없음
- [ ] NFR-2: 4가지 작업 유형(Feature, Bug Fix, Refactoring, GitHub Issue) 모두 동일한 패턴으로 처리

## Edge Cases

| # | 케이스 | 예상 동작 |
|---|--------|-----------|
| 1 | GitHub Issue로 진입 시 | `Skill("dotclaude:init-github-issue")`가 호출됨 |
| 2 | Feature 선택 시 | `Skill("dotclaude:init-feature")`가 호출됨 |
| 3 | Bug Fix 선택 시 | `Skill("dotclaude:init-bugfix")`가 호출됨 |
| 4 | Refactoring 선택 시 | `Skill("dotclaude:init-refactor")`가 호출됨 |
| 5 | Skill 로드 후 | init 파일의 모든 단계가 순서대로 실행됨 |

## Constraints

- init-xxx 커맨드들은 `user-invocable: false`이지만 Claude의 Skill 도구를 통해 호출 가능
- 수정 범위는 `commands/start-new.md` 한 파일로 한정
- 충돌 가능성 없음: 다른 커맨드나 에이전트에 영향 없음

## Out of Scope

- init-xxx 커맨드 파일 자체의 수정 (init-bugfix, init-feature, init-refactor, init-github-issue)
- 오케스트레이터의 다른 Step 변경 (Step 1, Step 3 이후)
- `_init-common.md` 수정
- 버전 번호 변경 (릴리스 시점에 수행)
