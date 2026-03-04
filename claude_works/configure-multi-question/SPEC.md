<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-configure-multi-question
-->

# configure multi-question - Specification

## Overview

`/dotclaude:configure` 커맨드의 UX를 개선하여 개별 순차 질문 방식에서 multi-question 배치 방식으로 전환한다. 사용자가 설정 항목을 한눈에 확인하고 왔다갔다하면서 수정할 수 있도록 한다.

**Source Issue**: https://github.com/U-lis/dotclaude/issues/55
**Target Version**: 0.4.0
**Severity**: Minor
**Impact Scope**: `/dotclaude:configure` 커맨드 UX에만 영향

## Bug Description (증상)

configure 세션에서 Setting 1~6을 각각 개별 `AskUserQuestion`으로 순차적으로 질문하며, 이전 질문으로 돌아가 수정할 수 없다. 사용자가 답하기 답답하고 이전 설정을 수정할 수 없는 문제.

## Reproduction Steps (재현 방법)

1. `/dotclaude:configure` 실행
2. Scope 선택 (Global/Local)
3. Setting 1 (Language) 질문 → 답변
4. Setting 2 (Working Directory) 질문 → 답변
5. Setting 3~6 순차 반복
6. 이전 질문으로 돌아갈 수 없음

## Root Cause Analysis (근본 원인 분석)

- **파일**: `commands/configure.md:165-462` (Step 3: Interactive Configuration Workflow)
- **원인**: Step 3에서 Setting 1~6을 각각 개별 `AskUserQuestion` 호출로 순차 질문하고 있음. `AskUserQuestion` 도구는 `questions` 배열 파라미터를 통해 최대 4개 질문을 한 번에 전달할 수 있으나, 현재 이 기능을 활용하지 않고 있음.
- **관련 PR**: PR #59에서 `check_version`과 `auto_update` 설정이 제거 예정 (현재 OPEN 상태). 이 PR 머지 후 설정이 4개로 줄어듦 (Language, Working Directory, Base Branch, Version Files).

## Functional Requirements

- [ ] FR-1: Setting 1~3 (Language, Working Directory, Base Branch)을 단일 `AskUserQuestion` multi-question 호출로 통합하여 한 번에 질문한다
- [ ] FR-2: multi-question 호출 시 각 질문에 현재 값을 `default_value`로 제공하여 사용자가 변경 없이 확인만 할 수 있도록 한다
- [ ] FR-3: Setting 4 (Version Files)는 기존과 동일한 별도 인터랙티브 단계로 유지한다
- [ ] FR-4: Working Directory 값이 변경된 경우, 배치 질문 완료 후 기존 마이그레이션 프롬프트를 발동한다
- [ ] FR-5: 각 질문의 유효성 검증 로직은 기존과 동일하게 유지한다 (배치 응답 수신 후 후처리로 검증)
- [ ] FR-6: `AskUserQuestion`의 자동 "Other" 옵션을 활용하여 수동 기타 옵션 추가를 제거한다

## Non-Functional Requirements

- [ ] NFR-1: `AskUserQuestion` 호출 횟수를 최소화하여 사용자 인터랙션 횟수를 줄인다 (Step 3에서 기존 4~6회 → 1회 + Version Files 단계)
- [ ] NFR-2: 기존 설정 값 유효성 검증의 정확도를 유지한다
- [ ] NFR-3: 설정 저장 형식(JSON)과 저장 위치는 변경하지 않는다

## Affected Code Locations (수정 대상 코드 위치)

| 파일 | 라인 범위 (현재) | 수정 내용 |
|------|------------------|----------|
| `commands/configure.md` | Step 3 (L165-462) | 개별 질문 구조를 multi-question 배치로 재구성 |

## Fix Strategy (수정 전략)

### 전제 조건

PR #59 (check_version, auto_update 제거) 머지 후 작업. 머지 후 설정 항목은 다음 4개:
1. Language
2. Working Directory
3. Base Branch
4. Version Files

### Step 3 재구성 방안

**Phase A: Multi-Question 배치 (Setting 1-3)**

Setting 1 (Language), Setting 2 (Working Directory), Setting 3 (Base Branch)을 단일 `AskUserQuestion` multi-question 호출로 통합한다 (3개 질문, 4개 제한 내).

```yaml
questions:
  - question: "Language code for conversations and documents?"
    default_value: <current_language>
    context: |
      Specify language code (e.g., en_US, fr_FR, ja_JP, ko_KR).
      The SessionStart hook reads this setting and outputs it as session context.

  - question: "Working directory name (relative path from project root)?"
    default_value: <current_working_dir>
    context: |
      This is where dotclaude stores plans, notepads, and work artifacts.
      Must be a relative path (no leading /, no ..).
      Examples: .dc_workspace, claude_works, workspace/dotclaude

  - question: "Default base branch for git operations?"
    default_value: <current_base_branch>
    context: |
      Used for creating feature branches, PR targets, comparing changes.
      Common values: main, master, develop
```

**Phase B: 배치 응답 후처리**

1. 각 응답에 대해 기존 유효성 검증 로직을 수행한다
2. 유효성 검증 실패 시 해당 항목만 재질문한다
3. Working Directory 값이 변경된 경우, 마이그레이션 프롬프트를 발동한다

**Phase C: Version Files 단계 (Setting 4)**

기존과 동일한 인터랙티브 워크플로우를 유지한다 (View/Add/Remove/Reset/Skip).

## Conflict Analysis (충돌 분석)

| 기존 동작 | 요구 동작 | 충돌 여부 | 해결 방법 |
|-----------|----------|-----------|-----------|
| Setting 1~4 개별 순차 질문 (PR #59 머지 후 기준) | Setting 1-3 한 번에 묶어서 질문 | 동작 변경 (개선) | multi-question 배치 사용 |
| Setting 4 (Version Files) 개별 질문 | 별도 단계로 유지 | 충돌 없음 | 기존 유지 |
| WD 변경 시 즉시 마이그레이션 프롬프트 | 배치 후 마이그레이션 프롬프트 | 시점 변경 | 배치 완료 후 후처리에서 발동 |

## Edge Cases (엣지 케이스)

| # | 케이스 | 예상 동작 |
|---|--------|-----------|
| 1 | 배치에서 일부 질문에 "기타(Other)" 선택 | `AskUserQuestion`이 자동으로 Other 옵션을 지원, 사용자 입력 값을 정상 처리 |
| 2 | Working Directory 변경 시 기존 디렉토리에 파일 존재 | 배치 완료 후 마이그레이션 프롬프트 발생 (Migrate / Start fresh) |
| 3 | Version Files 단계 진입 | 기존과 동일한 인터랙티브 워크플로우 (View/Add/Remove/Reset/Skip) |
| 4 | 빈 값 입력 시 | 유효성 검증 실패 → 해당 항목만 재질문 |
| 5 | 모든 값을 기본값 그대로 유지 | 변경 없이 정상 저장 (마이그레이션 미발동) |
| 6 | Language에 유효하지 않은 형식 입력 | 현재 로직상 비어있지 않으면 수락 (기존 동작 유지) |

## Constraints

- `AskUserQuestion` 도구 제한: 최대 4개 질문/호출
- PR #59 머지 선행 필요 (`check_version`, `auto_update` 제거)
- Version Files 인터랙티브 워크플로우는 변경하지 않음
- 설정 값 유효성 검증 로직은 기존과 동일하게 유지

## Out of Scope

- Version Files 설정 UI 개선
- 설정 값 유효성 검증 로직 변경
- 설정 파일 스키마 변경 (PR #59에서 처리)
- 설정 파일 저장 형식 변경
- Step 1 (Load Configuration), Step 2 (Select Scope), Step 4 (Save), Step 5 (Confirm) 변경

## Open Questions

- 없음 (요구사항이 명확하고 `AskUserQuestion` multi-question 기능 활용으로 해결 가능)
