# Python Coder - Alembic Migration Autogenerate 기본화 - 전역 설계

## Feature Overview

### 목적
Python coder 에이전트의 `agents/coders/python.md` instruction에 Alembic migration 작업의 표준 워크플로우를 명시한다. autogenerate 우선 원칙, 3단계 검증, 수동 수정 시 참조 가이드, local DB 양방향 적용 검증까지 단일 섹션으로 통합한다.

### 해결하는 문제
- python coder가 migration 작성 시 autogenerate를 사용하지 않아 누락/오류 발생
- autogenerate 결과 검증 절차 부재로 의도치 않은 변경이 commit됨
- 수동 수정이 필요한 경우 참조할 자료 (sql.md Migration Patterns) 가 instruction에 명시되지 않음
- migration이 local DB에서 실제 동작하는지 확인하지 않은 채 commit됨

### 솔루션 개요
`agents/coders/python.md` 의 Preferred Stack 표(L72)와 Environment Variables(L73) 사이에 `## Migration Workflow` 섹션을 신설한다. 4개 하위 섹션이 SPEC의 FR-1 ~ FR-4에 1:1 매핑된다.

## Architecture Decisions

| ID | 결정 | 근거 |
|----|------|------|
| AD-1 | `## Migration Workflow` 섹션을 L72(Preferred Stack 표 끝)와 L73(`## Environment Variables`) 사이에 삽입 | Alembic이 Preferred Stack에 명시된 직후 워크플로우를 설명하는 것이 자연스러움. 기존 섹션 순서(Stack -> Workflow -> Env -> Testing)를 깨지 않음 |
| AD-2 | 4개 하위 섹션을 FR-1 ~ FR-4 와 1:1 매핑 (`### Autogenerate-First Principle`, `### Validation Checklist (3 Steps)`, `### Manual Edits (Reference: sql.md)`, `### Local DB Verification`) | SPEC 검증 가능성 확보. 각 FR이 하나의 하위 섹션과 직결됨 |
| AD-3 | sql.md 참조는 `agents/coders/sql.md` (Migration Patterns section, lines 125-151) 형식으로 명시 | 다른 coder agent가 `coders/_base.md` 를 참조하는 패턴과 일관. 정확한 line range로 ambiguity 제거 |
| AD-4 | 명령형(imperative) instruction 톤 사용 ("Use", "Run", "Verify") | 기존 python.md/sql.md 의 instruction 톤과 일관 (예: L131 "Run before completion") |
| AD-5 | bash code block + 주석으로 명령어 시퀀스 제시 | sql.md L210-222 Quality Checks 섹션과 동일 형식 |
| AD-6 | Edge case는 별도 섹션 없이 Validation Checklist / Local DB Verification 안에 inline 흡수 | SIMPLE 복잡도 유지. instruction 가독성 향상 |

## Data Model

해당 사항 없음 (instruction 문서 변경 작업, schema/data 변경 없음).

## Phase Overview

| Phase | 설명 | Status | 선행조건 |
|-------|------|--------|----------|
| 1 | `agents/coders/python.md` 에 `## Migration Workflow` 섹션 (4개 하위 섹션 포함) 추가 | Pending | SPEC.md 승인 완료 |

## File Structure

| 파일 | 변경 유형 | 비고 |
|------|-----------|------|
| `agents/coders/python.md` | 수정 (섹션 추가) | L72와 L73 사이에 `## Migration Workflow` 섹션 삽입. 기존 내용은 유지 |
| `agents/coders/sql.md` | 변경 없음 (참조 대상) | L125-151 Migration Patterns 섹션을 python.md에서 참조. 본 작업에서 수정 금지 |

## Cross-File Reference Map

| Source | Target | 목적 |
|--------|--------|------|
| `agents/coders/python.md` (신설 `### Manual Edits` 섹션) | `agents/coders/sql.md` L125-151 (Migration Patterns) | autogenerate가 처리하지 못하는 수동 수정 시 문법 참조 |
| `agents/coders/python.md` (신설 `### Manual Edits` 섹션) | `agents/coders/sql.md` L143-151 (Safe Migrations) | NOT NULL column 추가 등 안전한 migration 패턴 참조 |
