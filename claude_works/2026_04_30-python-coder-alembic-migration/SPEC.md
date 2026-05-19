<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-python-coder-alembic-migration
doc_dir: 2026_04_30-python-coder-alembic-migration
-->

# SPEC: Python Coder - Alembic Migration Autogenerate 기본화

## Metadata

| 항목 | 값 |
|------|-----|
| Source Issue | https://github.com/U-lis/dotclaude/issues/62 |
| Target Version | 0.5.0 |
| Work Type | feature |
| Branch | feature/python-coder-alembic-migration |

## Overview / 목표

Python coder 에이전트가 Alembic migration을 작성할 때 기본 워크플로우로 `alembic revision --autogenerate` 를 사용하도록 `agents/coders/python.md` instruction을 업데이트한다. autogenerate 결과의 검증, 수동 수정이 필요한 경우의 참조 가이드, local DB 적용 확인까지 모두 python coder의 표준 절차로 명시한다.

Migration 작업의 주체는 python coder이며, sql coder가 아니다. 검증 후 수동 수정이 필요한 경우 `agents/coders/sql.md`의 기존 Migration Patterns / Safe Migrations 섹션을 참조하여 올바른 문법으로 직접 작성한다.

## Problem / 해결하려는 문제

현재 instruction에는 Alembic이 사용 도구로만 언급되어 있고 (`agents/coders/python.md:70` Preferred Stack), 실제 migration 작성 워크플로우는 어디에도 명시되지 않았다. 또한 `agents/coders/sql.md:125-151` 의 Migration Patterns 섹션에는 수동 작성 예시 (`op.create_index()`, `op.add_column()` 등)만 제공되어 있다. 이로 인해 다음과 같은 문제가 발생한다.

- python coder가 migration 작업 시 autogenerate workflow를 따르지 않아 실수와 누락이 발생
- 검증 절차가 없어 의도치 않은 변경이 migration에 포함될 가능성 존재
- migration이 실제 local DB에서 동작하는지 확인하지 않은 채 commit되는 경우 발생
- 수동 수정이 필요한 경우 어떤 자료를 참조해야 하는지 명시되지 않음

## Functional Requirements / 핵심 기능

- [ ] **FR-1: python.md에 Autogenerate 우선 워크플로우 가이드 추가**
  - 가이드 위치: `agents/coders/python.md`
  - `alembic revision --autogenerate -m "..."`을 기본 명령으로 명시
  - 수동 작성은 autogenerate가 처리하지 못하는 경우(enum 변경 등)에만 사용한다는 원칙 명시

- [ ] **FR-2: Autogenerate 결과 3단계 검증 절차 명시 (python.md)**
  - 검증 1: 변경하고자 하는 것이 모두 반영되었는가
  - 검증 2: 변경하고자 하지 않은 것이 detect되어 포함되지 않았는가
  - 검증 3: 수동 처리 필요 항목(enum 변경, type mismatch 등) 식별

- [ ] **FR-3: 수동 수정 가이드 (sql.md 참조 명시)**
  - 검증 단계에서 수정 필요 항목 발견 시 `agents/coders/sql.md`의 Migration Patterns 및 Safe Migrations 섹션 (line 125-151)을 참조하여 올바른 문법으로 직접 수정
  - sql.md를 직접 수정하지 않음 (참조용 유지)

- [ ] **FR-4: Local DB 적용 검증 절차 명시 (python.md)**
  - `alembic upgrade head` 실행하여 정상 적용 확인
  - `alembic downgrade -1` 후 다시 `alembic upgrade head` 로 양방향 동작 검증
  - 적용 후 schema 상태 확인 단계 명시

## Non-Functional Requirements

- [ ] **NFR-1: 성능** — 별도 요구사항 없음 (instruction 문서 개선 작업)
- [ ] **NFR-2: 보안** — 별도 요구사항 없음

## Constraints / 제약사항

- 기존 codebase 패턴 준수 (다른 coder agent instruction 형식과 일관성 유지)
- 기술 스택: Alembic, SQLAlchemy 2.0+, PostgreSQL (기존 Preferred Stack 유지)
- Migration 작업 주체는 python coder (sql coder가 아님)

## Out of Scope / 범위 제외

- enum 변경 등 autogenerate가 정확히 처리하지 못하는 케이스는 자동화 범위 외 (수동 작성 가이드만 제공)
- Alembic 이외 migration 도구 (Prisma 등) 가이드 변경 없음
- `agents/coders/sql.md`는 구조/예시 변경 없음 (참조용으로 유지)

## Analysis Results / 분석 결과

### Related Code

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | agents/coders/python.md | 70 | Alembic이 Preferred Stack에만 언급되고 workflow 가이드 부재 |
| 2 | agents/coders/sql.md | 125-151 | Migration Patterns 섹션에 수동 작성 예시 존재 (참조용으로 활용) |
| 3 | agents/coders/sql.md | 211-222 | Quality Checks 섹션에 alembic 명령어는 있으나 autogenerate workflow 부재 |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | python.md에 migration workflow 언급 없음 (line 70만 Preferred Stack) | python coder가 autogenerate workflow + 검증 + 수동 수정 절차를 알아야 함 | python.md에 Migration Workflow 섹션 신설. 수동 수정 시 sql.md (line 125-151) 참조하도록 명시 |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | autogenerate가 의도하지 않은 column drop을 detect | 검증 단계에서 식별 → 해당 변경을 migration에서 제거 |
| 2 | Enum type 변경 (PostgreSQL ENUM 추가/제거) | autogenerate가 정확히 처리 못함 → sql.md 참조하여 수동 작성 |
| 3 | Type mismatch (e.g., String → Text) | autogenerate detect되나 명시적 검토 필요 → 검증 체크리스트 항목 |
| 4 | Migration upgrade는 성공하나 downgrade 실패 | upgrade/downgrade 양방향 검증 단계에서 사전 발견 |
| 5 | Local DB 미설치 환경 | 사전 조건 명시 (DATABASE_URL, alembic.ini 설정 확인) |
