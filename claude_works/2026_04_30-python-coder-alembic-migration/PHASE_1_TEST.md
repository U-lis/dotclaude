# Phase 1: 검증 체크리스트

## Test Coverage Target

본 phase는 instruction 문서 (markdown) 변경 작업이므로 코드 coverage 측정 대상이 아니다. 대신 다음 3축의 검증을 100% 통과해야 한다.

| 검증 축 | 통과 기준 |
|---------|----------|
| Manual Review (FR/EC 매핑 검증) | 9개 항목 (FR-1~4 + EC-1~5) 모두 충족 |
| Structural Lint (markdown 구조) | 5개 항목 모두 통과 |
| Cross-reference Verification (sql.md 참조 정확성) | 2개 line range 모두 정확 |

자동 테스트는 없으나 본 문서의 모든 체크리스트를 사람이 수동으로 검증한다.

## 1. Manual Review Checklist

### 1.1 FR 매핑 검증

각 FR이 신설 섹션에서 만족되는지 확인.

- [x] **FR-1 만족 검증**: `### Autogenerate-First Principle` 섹션에 다음이 모두 포함됨
  - [x] `alembic revision --autogenerate -m "..."` 가 기본 명령으로 명시됨 — python.md:83
  - [x] 수동 작성은 autogenerate 가 처리하지 못하는 경우에만 허용됨이 명시됨 — python.md:79
  - [x] bash code block 으로 명령어 예시 제공됨 — python.md:81-84

- [x] **FR-2 만족 검증**: `### Validation Checklist (3 Steps)` 섹션에 다음이 모두 포함됨
  - [x] 검증 1: 변경 의도가 모두 반영되었는지 확인 절차 명시 — python.md:93-94
  - [x] 검증 2: 의도하지 않은 변경이 detect되어 포함되지 않았는지 확인 절차 명시 — python.md:96-100
  - [x] 검증 3: 수동 처리 필요 항목(enum, type mismatch 등) 식별 절차 명시 — python.md:102-106

- [x] **FR-3 만족 검증**: `### Manual Edits (Reference: sql.md)` 섹션에 다음이 모두 포함됨
  - [x] `agents/coders/sql.md` Migration Patterns 섹션 참조가 line range (125-151) 와 함께 명시됨 — python.md:112
  - [x] sql.md 를 직접 수정하지 않는다는 점이 명시됨 — python.md:113
  - [x] 수동 수정 작업 주체가 python coder임이 (암시적이라도) 명확함 — python.md:110 ("python coder가 직접 ... sql coder를 호출하지 않는다")

- [x] **FR-4 만족 검증**: `### Local DB Verification` 섹션에 다음이 모두 포함됨
  - [x] `alembic upgrade head` 정상 적용 확인 단계 명시 — python.md:130
  - [x] `alembic downgrade -1` -> `alembic upgrade head` 양방향 검증 명시 — python.md:137-138
  - [x] 적용 후 schema 상태 확인 단계 명시 — python.md:132-134
  - [x] bash code block 으로 명령어 시퀀스 제공됨 — python.md:128-139

### 1.2 Edge Case 흡수 검증

- [x] **EC-1 (column drop)**: `### Validation Checklist` 검증 2 본문에 의도치 않은 변경 예시로 column drop 이 언급됨 — python.md:98
- [x] **EC-2 (Enum)**: `### Validation Checklist` 검증 3 또는 `### Manual Edits` 본문에 enum 이 수동 처리 케이스로 언급됨 — python.md:104, python.md:115
- [x] **EC-3 (Type mismatch)**: `### Validation Checklist` 검증 3 본문에 type mismatch (예: String -> Text) 가 언급됨 — python.md:105
- [x] **EC-4 (downgrade 실패)**: `### Local DB Verification` 양방향 검증 단계가 downgrade 실패 사전 발견 메커니즘으로 동작함이 명확함 — python.md:141 ("downgrade() 함수 누락/오류를 사전에 발견하기 위한 필수 절차")
- [x] **EC-5 (Local DB 미설치)**: `### Local DB Verification` 에 사전 조건 (`DATABASE_URL`, `alembic.ini` 설정) 이 명시됨 — python.md:123-125

### 1.3 톤 및 일관성 검증

- [x] 명령형 톤 사용 ("Use", "Run", "Verify", "Check") - "should", "may" 같은 약한 표현 없음 — "사용한다", "확인한다", "검증한다" 형태로 일관
- [x] bash code block 형식이 기존 `agents/coders/sql.md:210-222` Quality Checks 섹션과 일관 — `# 주석` -> `명령어` 패턴 준수
- [x] 헤더 레벨이 다른 `## ...` 섹션과 일관 (`##` -> `###`) — 1 `##` + 4 `###`, no skipping
- [x] 외부 파일 참조 형식이 `path:line-range` 또는 `path` (lines X-Y) 패턴으로 통일 — "agents/coders/sql.md ... (lines 125-151)" 형식

## 2. Structural Lint

markdown 구조 무결성 검증.

- [x] **L-1**: heading hierarchy 무결성 - `##` 섹션 헤더 1개, `###` 하위 섹션 헤더 4개. heading level skip 없음 (`##` -> `####` 직행 등) — 검증 통과
- [x] **L-2**: code fence 모두 닫힘 - 신설 섹션의 ` ``` ` 개수가 짝수 — 4개 (2 pairs)
- [x] **L-3**: 섹션 경계 spacing - `## Migration Workflow` 헤더 위/아래에 빈 줄, 각 `###` 사이에 빈 줄 — diff 검증 통과
- [x] **L-4**: 기존 섹션 무결성 - L1-72 (Preferred Stack 표 끝까지) 와 기존 L73 이후 (`## Environment Variables` 부터) 내용이 변경 없이 유지됨 — diff에 0 deletions
- [x] **L-5**: list 형식 일관성 - bullet list (`-`) 또는 numbered list (`1.`) 만 사용. 한 list 안에서 mixing 없음 — Validation Checklist는 numbered, 그 외는 bullet

## 3. Cross-reference Verification

신설 섹션이 인용하는 sql.md line range 가 실제와 일치하는지 검증.

### 3.1 정확성 검증 절차

다음 명령으로 sql.md 해당 line 의 실제 내용 확인.

```bash
# Migration Patterns 섹션 시작/끝 확인
sed -n '125p;151p' agents/coders/sql.md

# Safe Migrations subsection 확인
sed -n '143p;151p' agents/coders/sql.md
```

### 3.2 검증 체크리스트

- [x] **CR-1**: `agents/coders/sql.md:125` 가 `## Migration Patterns` 헤더로 시작 — `sed -n '125p'` 결과: `## Migration Patterns`
- [x] **CR-2**: `agents/coders/sql.md:151` 이 Safe Migrations 마지막 줄 — L150이 `op.alter_column('users', 'role', server_default=None)`, L151은 닫는 ` ``` ` (Safe Migrations 코드 블록 종료). 인용 범위 125-151는 Safe Migrations subsection 종료 시점까지 정확히 포함
- [x] **CR-3**: `agents/coders/sql.md:143` 가 `### Safe Migrations` 헤더임 — `sed -n '143p'` 결과: `### Safe Migrations`
- [x] **CR-4**: 신설 `### Manual Edits` 섹션의 모든 line range 인용이 위 사실과 일치 — python.md:112에 "(lines 125-151) ... (lines 143-151)" 정확히 일치

### 3.3 만약 sql.md line 번호가 변동되었다면

본 phase 작업 전에 `agents/coders/sql.md` 가 변경되어 line 번호가 달라진 경우, 다음 절차를 따름.

1. 실제 Migration Patterns 섹션 line range 확인:
   ```bash
   grep -n '^## Migration Patterns' agents/coders/sql.md
   grep -n '^## ' agents/coders/sql.md  # 다음 ## 헤더 line 으로 끝 line 추정
   ```
2. 신설 `### Manual Edits` 섹션의 인용 line range 를 실제 값으로 업데이트
3. 본 TEST 문서의 CR-1 ~ CR-3 도 함께 업데이트
4. SPEC.md L48, L80 의 line 번호도 동일하게 업데이트 필요한지 확인 후 별도 보고

## 4. 회귀 검증 (Regression)

본 phase로 인해 의도하지 않은 변경이 없음을 확인.

- [x] **R-1**: `git diff agents/coders/sql.md` 결과가 empty (sql.md 무수정) — 검증 통과
- [x] **R-2**: `git diff agents/coders/python.md` 결과가 신설 `## Migration Workflow` 섹션 추가 부분만 포함 (기존 line 수정/삭제 없음) — 0 deletions, 71 additions
- [x] **R-3**: 다른 agent 정의 파일 (`agents/coders/_base.md` 등) 무수정 — `git status`상 python.md만 modified

## 5. 통과 기준 (Pass Criteria)

위 1-4 의 모든 체크박스가 체크되어야 본 phase 가 PASS 처리된다. 하나라도 실패 시 PHASE_1_PLAN_alembic-migration.md 의 Instructions 로 돌아가 해당 항목을 보완한 후 재검증.
