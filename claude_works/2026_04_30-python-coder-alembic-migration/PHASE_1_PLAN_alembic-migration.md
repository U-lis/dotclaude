# Phase 1: Alembic Migration Workflow 섹션 추가

## Objective / 목표

`agents/coders/python.md` 에 Alembic migration 작업의 표준 워크플로우를 정의한 `## Migration Workflow` 섹션을 신설하여 SPEC의 FR-1 ~ FR-4 모두를 만족시킨다.

## Prerequisites / 선행 조건

- [x] SPEC.md 승인 완료
- [x] GLOBAL.md 작성 완료
- [x] 수정 대상 파일 (`agents/coders/python.md`) 및 참조 대상 파일 (`agents/coders/sql.md`) 의 현재 line 구조 확인 완료

## Target File / 대상 파일

| 항목 | 값 |
|------|-----|
| 파일 경로 | `agents/coders/python.md` |
| 삽입 위치 | L72 (Preferred Stack 표 마지막 행) 와 L73 (`## Environment Variables` 헤더) 사이 |
| 새 섹션 헤더 | `## Migration Workflow` |
| 하위 섹션 수 | 4개 |
| 영향받는 기존 line | 없음 (순수 삽입, 기존 line 수정/삭제 없음) |

## Section Layout / 섹션 구조

신설 섹션의 최상위 구조는 다음과 같다.

```
## Migration Workflow

### Autogenerate-First Principle      <- FR-1 매핑
### Validation Checklist (3 Steps)    <- FR-2 매핑
### Manual Edits (Reference: sql.md)  <- FR-3 매핑
### Local DB Verification             <- FR-4 매핑
```

## Instructions / 작성 가이드

### 공통 작성 원칙

1. 명령형 톤 사용 ("Use", "Run", "Verify", "Check")
2. bash code block + 주석은 `agents/coders/sql.md` L210-222 형식 (`# 주석` -> `명령어`)
3. 헤더 레벨: `##` (섹션) -> `###` (하위 섹션) -> `####` (필요 시만)
4. 모든 외부 파일 참조는 절대 path + line range 명시 (예: `agents/coders/sql.md:125-151`)

### Sub-section 1: `### Autogenerate-First Principle` (FR-1 매핑)

**작성 내용**:
- migration 작업의 기본 명령어로 `alembic revision --autogenerate -m "..."` 를 명시
- autogenerate가 표준 워크플로우이며, 수동 작성은 autogenerate가 처리할 수 없는 경우(enum 변경 등)에만 허용한다는 원칙 진술
- 명령어 예시 1개를 bash code block으로 제공

**예상 길이**: 5-8 줄 본문 + bash block 3-5 줄

**금지 사항**:
- "should", "may", "might" 같은 약한 표현 사용 금지 -> "Use", "Always" 사용
- autogenerate 가 만능이라는 인상 금지 (수동 수정 필요 케이스가 존재함을 명시)

### Sub-section 2: `### Validation Checklist (3 Steps)` (FR-2 매핑)

**작성 내용**:
SPEC FR-2 의 3단계를 그대로 옮긴 numbered list (1, 2, 3) 작성.

| # | 검증 항목 | 핵심 질문 |
|---|----------|----------|
| 1 | 변경 의도 반영 검증 | 변경하고자 한 모든 schema 변경이 generated migration에 포함되었는가? |
| 2 | 의도하지 않은 변경 검증 | autogenerate가 detect한 변경 중 의도하지 않은 것 (예: column drop, 잘못된 type 추론) 이 포함되지 않았는가? |
| 3 | 수동 처리 필요 항목 식별 | enum 변경, type mismatch (String <-> Text 등), data migration 필요 항목 등 autogenerate가 정확히 처리 못하는 케이스가 있는가? |

**Edge case 흡수**:
- EC-1 (의도치 않은 column drop) -> 검증 2 의 명시적 예시
- EC-3 (Type mismatch) -> 검증 3 의 예시

**예상 길이**: 8-12 줄 (각 검증 항목당 2-4 줄)

### Sub-section 3: `### Manual Edits (Reference: sql.md)` (FR-3 매핑)

**작성 내용**:
- 검증 단계에서 수동 수정 필요 항목 발견 시, `agents/coders/sql.md` 의 Migration Patterns (L125-151) 를 참조하여 올바른 문법으로 직접 수정한다는 절차 명시
- sql coder를 호출하지 않음을 명시 (작업 주체는 python coder)
- sql.md를 수정하지 않음을 명시 (참조 전용)
- enum 변경, NOT NULL column 추가 등 대표적 수동 수정 케이스를 짧게 나열

**Edge case 흡수**:
- EC-2 (Enum 변경) -> 대표 수동 수정 케이스로 명시

**예상 길이**: 6-10 줄

**참조 표기 형식 (정확히 사용)**:
```
See `agents/coders/sql.md` Migration Patterns section (lines 125-151) and Safe Migrations subsection (lines 143-151).
```

### Sub-section 4: `### Local DB Verification` (FR-4 매핑)

**작성 내용**:
- 사전 조건: `DATABASE_URL` 환경변수 및 `alembic.ini` 설정 확인
- 단계 1: `alembic upgrade head` 정상 적용 확인
- 단계 2: `alembic downgrade -1` -> `alembic upgrade head` 양방향 동작 검증
- 단계 3: 적용 후 schema 상태 확인 (예: `\d <table>` in pgcli, 또는 `alembic current`)
- 명령어 시퀀스를 bash code block + 주석으로 제공

**Edge case 흡수**:
- EC-4 (downgrade 실패) -> 양방향 검증 단계가 사전 발견 메커니즘
- EC-5 (Local DB 미설치) -> 사전 조건 명시

**예상 길이**: bash block 8-12 줄 + 본문 4-6 줄

## Completion Checklist / 완료 체크리스트

- [x] **C-1**: `agents/coders/python.md` L72와 L73 사이에 `## Migration Workflow` 헤더 삽입 (이전/이후 섹션 경계 유지 확인) — verified at python.md:73
- [x] **C-2**: `### Autogenerate-First Principle` 작성 완료 (FR-1 만족) — verified at python.md:77-87
- [x] **C-3**: `### Validation Checklist (3 Steps)` 작성 완료 (FR-2 만족, EC-1/EC-3 흡수) — verified at python.md:89-106
- [x] **C-4**: `### Manual Edits (Reference: sql.md)` 작성 완료 (FR-3 만족, EC-2 흡수, sql.md L125-151 참조 표기 정확) — verified at python.md:108-117
- [x] **C-5**: `### Local DB Verification` 작성 완료 (FR-4 만족, EC-4/EC-5 흡수) — verified at python.md:119-142
- [x] **C-6**: markdown 구조 수동 점검 - heading hierarchy (`##` -> `###`), code fence 닫힘, table 정렬, 빈 줄 spacing — 4 fences in section (even), 1 `##` + 4 `###`, no level skip
- [x] **C-7**: 다른 coder agent (`agents/coders/sql.md`, 기존 `agents/coders/python.md` 의 다른 섹션) 와 톤/형식 일관성 셀프 리뷰 — 명령형 톤("사용한다", "확인한다"), bash 주석 형식 일관

## Edge Case Mapping / 엣지 케이스 흡수 매핑

| Edge Case | SPEC 위치 | 흡수 위치 | 흡수 방법 |
|-----------|-----------|----------|----------|
| EC-1 (의도치 않은 column drop) | SPEC L93 | `### Validation Checklist` 검증 2 | 명시적 예시로 언급 |
| EC-2 (Enum 변경) | SPEC L94 | `### Validation Checklist` 검증 3 + `### Manual Edits` | 대표 수동 수정 케이스로 양쪽에 언급 |
| EC-3 (Type mismatch) | SPEC L95 | `### Validation Checklist` 검증 3 | 명시적 예시 (String -> Text) |
| EC-4 (downgrade 실패) | SPEC L96 | `### Local DB Verification` 단계 2 | `downgrade -1 -> upgrade head` 양방향 시퀀스로 사전 발견 |
| EC-5 (Local DB 미설치) | SPEC L97 | `### Local DB Verification` 사전 조건 | `DATABASE_URL`, `alembic.ini` 확인 단계 명시 |

## Verification / 검증 방법

본 phase는 instruction 문서 변경이므로 자동화된 unit/integration test가 없다. 검증은 다음 두 축으로 수행한다.

### 1. 사람 리뷰 (Manual Review)
- C-1 ~ C-7 체크리스트 모두 통과
- SPEC FR-1 ~ FR-4 모두 신설 섹션에서 만족됨
- 모든 Edge Case (EC-1 ~ EC-5) 가 mapping table에 따라 흡수됨

### 2. 구조 검증 (Structural Lint)
- markdown heading hierarchy 무결성 (`##` -> `###` 누락/역전 없음)
- code fence 모두 닫힘 (` ``` ` 짝수 개)
- 외부 파일 참조 line range 정확성:
  - `agents/coders/sql.md:125-151` 가 실제 Migration Patterns 섹션과 일치
  - `agents/coders/sql.md:143-151` 가 실제 Safe Migrations subsection과 일치

자세한 검증 절차는 `PHASE_1_TEST.md` 참조.

## Definition of Done / 완료 기준

- [x] C-1 ~ C-7 체크리스트 모두 통과
- [x] `PHASE_1_TEST.md` 의 Manual Review Checklist 및 Structural Lint 모두 통과
- [x] `agents/coders/sql.md` 가 본 작업으로 인해 변경되지 않음 (`git diff agents/coders/sql.md` 가 empty)
- [x] `agents/coders/python.md` 의 기존 섹션(L1-72, 기존 L73 이후) 내용이 변경되지 않고 유지됨 — 0 deletions in diff

## Notes / 특이사항

- 본 phase는 단일 파일, 단일 섹션 추가 작업이므로 별도 phase 분할 불필요
- merge 단계 (PHASE_1.5_PLAN_MERGE.md) 불필요
- 자동 테스트 작성 불필요 (instruction 문서). 단, `PHASE_1_TEST.md` 에 사람이 수행할 검증 체크리스트 별도 명시
- `dotclaude:code` 실행 시 본 PLAN의 Instructions 섹션을 그대로 따라 실행
