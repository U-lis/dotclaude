<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-pruner-test-slimming
doc_dir: 2026_09_21-pruner-test-slimming
-->

# Pruner stage + PHASE_TEST template revision - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/76
**Target Version**: 0.6.0
**Work Type**: feature
**Branch**: feature/pruner-test-slimming

---

## 개요

**목적**: 코드 워크플로우에 삭제 전용 리뷰 단계(pruner 에이전트)를 도입하고, 테스트 템플릿 및 검증기를 수정하여 PR 크기가 인위적으로 팽창하는 문제를 방지한다.

**문제**: 플로우가 생성한 PR이 실제 로직 대비 과도하게 큰 것으로 반복 지적된다. 실제 사례: +974줄 PR에서 로직 ~60줄, 테스트 811줄, 트리거 함수 하나의 docstring이 34줄. 근본 원인:
1. `templates/PHASE_TEST.md`가 "더 많이"를 유도한다: 함수별 Unit 슬롯, 시나리오별 Integration 슬롯, 일반 Edge Cases 목록, 70% 커버리지 pass/fail 기준. Designer가 슬롯을 채우면 coder가 채워진 슬롯을 모두 구현한다.
2. 검증이 "통과하는가"만 확인하고 "필요한가"는 확인하지 않는다. `code-validator`는 체크리스트와 품질만 확인한다. `spec-validator`는 SPEC 문구를 근거로 테스트를 추가시킨 사례가 있다(mock `side_effect=[True, False, True]`만 반환하는 의미 없는 테스트 포함).
3. 동일한 동작이 두 레이어(unit + endpoint 테스트)에서 중복 검증된다(게이트 거부, cooldown, 예외 격리 등).
4. 설계 논의가 docstring에 누출된다(GLOBAL.md 근거가 코드 docstring에 그대로 복사됨).
5. GREEN 이후 축소 단계가 없다.

**해결책**: 두 지점에서 pruner를 도입한다. (1) 설계 단계(doc mode): TechnicalWriter가 PHASE_TEST/PLAN을 생성한 직후, 설계 커밋 전에 pruner(doc mode)를 실행하여 계획 단계에서 팽창을 차단한다. 이것이 1차 삭감 지점이다(근본 원인: designer가 테스트 케이스를 팽창시키고 coder가 이를 모두 구현). (2) 코드 단계(code mode): `code-validator` 내부 루프에 흡수한다 — PASS 후 pruner(code mode)를 한 번 호출하고, 후보 존재 시 coder가 적용(테스트 삭제/병합, docstring/주석 축소만, 로직 변경 없음)한 뒤 재검증한다. 오케스트레이터 플로우(`commands/code.md`, `commands/start-new.md`)는 그대로 유지하여 플로우 가시 길이를 늘리지 않는다. 동시에 `templates/PHASE_TEST.md`를 수정하고, 70% 커버리지 기준을 pass/fail 게이트에서 참고값으로 격하한다.

---

## 기능 요구사항

### 핵심 기능

- [ ] FR-1: 신규 에이전트 `agents/pruner.md` — 분석 및 보고 전용. 하나의 에이전트가 **두 가지 모드**로 동작한다.
  - Frontmatter: `name`, `model`(`docs/AGENT_MODEL_GUIDE.md` 결정 기준), `description`(기존 에이전트 패턴 준수).
  - **보고 전용**: 두 모드 모두에서 pruner는 어떠한 파일(코드, 테스트, 문서)도 수정해서는 안 된다. 분석 후 보고서만 출력한다. (이는 issue #76 원문에서 pruner에게 삭제/편집 권한을 부여한 것을 덮어쓰는 결정이다.)
  - 보고서 내용: 삭제/병합 후보(테스트)와 docstring/주석 축소 후보 목록, 각각 명시적 이유 포함.
  - 로직 변경은 절대 제안하지 않는다.

  **문서 모드 (doc mode)**
  - 입력: `PHASE_*_TEST.md`, `PHASE_*_PLAN.md`
  - 적용 기준: 기준 1(분기 조합은 하나의 레이어에서만; 상위 레이어는 배선·응답 계약·쿼리 수·대표 흐름으로 한정), 기준 3(기존 동작 또는 프로덕션에서 발생할 수 없는 입력), 기준 4(값 하나를 바꾸기 위한 신규 테스트 파일), 기준 6(계획된 빈/자명한/건너뛴 테스트). 코드 없이 적용 가능한 기준만 사용한다.
  - 안전장치: "제거할 것 없음"은 명시적으로 유효하고 정상적인 결과이다. 동작당 최소 1개의 테스트를 유지한다.

  **코드 모드 (code mode)**
  - 입력: 구현된 단계 코드 + 테스트
  - 주요 적용 기준: 기준 2(특정 프로덕션 라인을 삭제했을 때 이 테스트가 실패하는가; 유지를 제안하는 모든 테스트에 해당 라인 명시, 지목 불가 시 삭제 후보), 기준 5(docstring/주석: 코드에서 읽을 수 없는 "왜"만, 1–5줄), 기준 7(테스트 라인이 로직 라인의 약 3배 초과 시 경보). 추가로 coder가 새로 도입한 기준 1/3/4/6 위반도 포함한다.
  - 안전장치: "제거할 것 없음"은 명시적으로 유효하고 정상적인 결과이다. 동작당 최소 1개의 테스트를 유지한다.

  **판단 기준 전체 목록**:
  1. 분기 조합은 하나의 레이어에서만 검증한다. 동일 기능을 여러 레이어에서 검증하는 것 자체는 허용된다. 금지 대상은 하위 레이어에서 이미 검증된 분기 조합을 상위 레이어에서 반복하는 것이다.
     - 분기 로직의 경우의 수(각 거부/예외/경계 분기)는 하나의 레이어(보통 unit)에서만 검증한다.
     - 상위 레이어(endpoint/시나리오/integration) 테스트는 다음으로 한정한다: 배선(하위 로직이 실제로 호출·연결되는가), 응답 계약(상태 코드/응답 스키마), 쿼리 수, 대표 흐름(happy path 1개 + 응답 계약이 서로 다른 실패 경로마다 대표 1개).
     - 삭제 후보: 상위 레이어 테스트 중 위 한정 범위를 벗어나 하위 레이어 분기 조합을 재검증하는 것(예: unit에서 검증한 cooldown 분기 3종을 endpoint에서 동일 응답 계약으로 다시 3종 검증).
     - 삭제 후보 아님: 동일 기능에 대한 unit 테스트 + 시나리오 테스트 공존(시나리오가 위 한정 범위 안에 있는 한).
  2. 특정 프로덕션 라인을 삭제했을 때 이 테스트가 실패하는가? 아니라면 → 삭제 후보(예: mock의 반환값만 반환하는 테스트).
  3. 기존 동작 또는 프로덕션에서 발생할 수 없는 입력은 테스트하지 않는다.
  4. 값 하나를 바꾸기 위해 새 테스트 파일을 생성하지 않는다.
  5. Docstring/주석: 코드에서 읽을 수 없는 "왜"만, 1–5줄. 설계 논의는 PR body 또는 SPEC에 속한다.
  6. 의미 없는 테스트 유형(issue #73 항목 2에서 흡수): 빈 테스트, 자명한 테스트(예: `return True` / `assert True`), 건너뛴 테스트.
  7. 테스트 라인 수가 로직 라인 수의 약 3배를 초과하면 경보(경고 전용, 비블로킹).

- [ ] FR-2a: 설계 단계에 pruner(doc mode) 삽입 — `commands/design.md` 및 `commands/start-new.md`의 Step 7 → Step 8 구간(TechnicalWriter 설계 문서 생성 후, 설계 커밋 전)에 적용한다.
  - 단계 순서: TechnicalWriter가 PHASE_TEST/PLAN 설계 문서 생성 → pruner(doc mode) 실행 → 후보 존재 시: TechnicalWriter가 PHASE_TEST/PLAN에 적용 → 설계 커밋. 제거할 것이 없으면 바로 커밋한다.
  - **1차 삭감 지점**: designer가 테스트 케이스를 팽창시키고 coder가 이를 모두 구현하는 구조를 설계 시점에 차단한다.
  - 플로우 가시성: 기존 설계 커밋 단계 내에 흡수한다. 오케스트레이터 플로우에 별도 단계로 추가하지 않는다.

- [ ] FR-2b: 코드 단계 — 오케스트레이터 플로우 변경 없음. `agents/code-validator.md` 내부 루프에 흡수한다.
  - `commands/code.md` 및 `commands/start-new.md`의 오케스트레이터 플로우는 그대로 유지한다: coder → code-validator → 커밋.
  - `agents/code-validator.md` 내부 동작: code-validator의 validation PASS 후 pruner(code mode)를 한 번 호출한다. 후보 존재 시 code-validator가 coder를 호출하여 적용(테스트 파일의 테스트 삭제/병합만, 테스트 파일 외 파일 변경 없음)한다. 기준 5(docstring/주석) 후보와 테스트 파일이 아닌 파일의 후보는 적용하지 않고 PASS 리포트에 싣는다. 이후 단일 재검증 패스 실행(PLAN/TEST 체크 + 변경된 테스트 파일만 lint/type/test. 운영 코드 불변이므로 Step 1 전체 스위트 결과가 유효).
  - 수정 대상 파일: `agents/code-validator.md`(내부 동작 설명 및 호출 프롬프트). `commands/code.md` 및 `commands/start-new.md`는 오케스트레이터 흐름 설명 변경 없이 그대로 유지한다.
  - 실패 처리: pruning 적용 후 스위트가 RED가 되고 단일 재검증 패스가 실패하면 → pruning 변경 사항만 되돌리고 이전 GREEN 결과를 PASS로 반환한다(엣지 케이스 #3, #11 참조).

- [ ] FR-3: `templates/PHASE_TEST.md` 수정.
  - "함수별 케이스 나열" 형식을 "검증할 동작 목록 + 어느 레이어에서 각 동작을 검증하는지"로 교체한다.
  - 일반 Edge Cases 목록(Empty input / Invalid type / Network failure / Database error / Timeout / Maximum size ...) 제거. 해당 단계에 실제로 적용되는 edge case만 기술한다.
  - 커버리지 70%를 pass/fail 기준에서 참고값으로 격하한다(예: 70%는 게이트가 아닌 참고값이라는 노트).
  - `agents/technical-writer.md`(약 44줄 및 169줄, PHASE_TEST 구조 및 70% 언급), `agents/spec-validator.md`(약 44줄, 커버리지 체크), `commands/validate-spec.md`(63줄, "Coverage target achievable (≥ 70%)")를 동일하게 정렬한다: 커버리지는 참고값이며 pass/fail 게이트가 아니다.

- [ ] FR-4: `agents/spec-validator.md`(및 관련 `commands/validate-spec.md`) 제한.
  - `spec-validator`는 테스트를 직접 추가하거나 `TechnicalWriter`에게 테스트 케이스 추가를 지시해서는 안 된다. 누락된 동작 커버리지만 보고한다.
  - 테스트를 늘리도록 유도하는 일반 완전성 항목(예: "No missing edge cases")을 제거하거나 완화한다.

### 부가 기능

- [ ] FR-5: 독립 명령어 `commands/prune.md` → `/dotclaude:prune [target]`, pruner 에이전트 호출, 보고 전용.
  - 보고서 적용은 항상 별도의 명시적 사용자 지시가 필요하다. 명령어 자체는 변경을 적용하지 않는다.
  - **모드 선택**: git diff 또는 PR/issue/Jira diff를 대상으로 하는 경우 → 코드 모드. phase 인수에 해당 단계의 코드가 아직 없는 경우 → 해당 단계의 TEST/PLAN을 대상으로 문서 모드.
  - 인수 없음: 커밋되지 않은 변경 사항 분석(`git diff HEAD`, staged + unstaged) → 코드 모드. 커밋되지 않은 변경 사항이 없으면 → "분석 대상 없음"을 보고하고 종료한다.
  - 인수 = phase id (예: `1`, `3A`, `3.5`): 해당 단계의 변경 사항을 분석한다. 해당 단계의 코드가 없으면 문서 모드로 TEST/PLAN을 분석한다.
  - 인수 = 티켓:
    - GitHub PR (URL 또는 `#N`): `gh pr diff`로 diff를 가져온다. → 코드 모드.
    - GitHub issue (URL 또는 `#N`): 연결된 PR 또는 브랜치를 찾아 `base_branch` 대비 diff를 가져온다. → 코드 모드.
    - Jira 키 (예: `ABC-123`): 키를 포함하는 브랜치를 찾아 `base_branch` 대비 diff를 가져온다. → 코드 모드.
  - 경로 인수는 이번 이터레이션에서 지원하지 않는다.
  - 티켓에서 브랜치 또는 PR을 찾을 수 없으면: 오류를 보고하고 종료한다. 추측하지 않는다.

---

## 비기능 요구사항

### 성능
- [ ] NFR-1: 성능 요구사항 없음. pruner는 로컬 분석 패스로 실행되며 지연 시간은 문제가 되지 않는다.

### 보안
- [ ] NFR-2: pruner 에이전트는 분석 및 보고 전용이며 어떠한 파일도 편집해서는 안 된다. `agents/pruner.md` frontmatter가 도구 제한을 지원하면 그에 따라 제한한다(결정은 설계 단계로 위임).

### 언어
- [ ] NFR-3: 기존 에이전트 언어 관례를 따른다: AI 간 문서(에이전트, 명령어, 템플릿)는 영어로 작성한다.

---

## 제약 조건

### 기술적 제약
- `agents/*.md` 및 `commands/*.md`의 기존 패턴(frontmatter 필드, Language 섹션, 출력 형식 섹션)을 따른다.
- coder가 pruner 보고서를 적용할 때는 테스트 삭제/병합과 docstring/주석 축소만 허용한다. 적용 후 스위트는 GREEN을 유지해야 한다.
- 신규 pruner 에이전트의 모델 할당은 `docs/AGENT_MODEL_GUIDE.md`를 따른다. 해당 파일의 할당 테이블을 업데이트한다.

### 비즈니스 제약
- 목표 릴리즈 버전: 0.6.0.

---

## 범위 외

다음은 명시적으로 이번 작업에 포함하지 않는다:

- issue #73의 범용 코드 리뷰어(미사용 import, 재구현 로직, 불필요한 조건문, 불일치 주석, 경계 커버리지). issue #73 항목 2(의미 없는/빈/자명한/건너뛴 테스트)만 pruner 기준에 흡수한다. issue #73 자체는 편집하거나 주석을 달지 않는다.
- `/dotclaude:prune`의 경로 인수.
- pruner가 직접 파일을 편집하는 것(이는 무조건적으로 범위 외이며 사용자 결정사항이다).
- `agents/code-validator.md` 225줄("Test coverage: {X}%") — 정보성 출력으로 유지한다. 단, `agents/code-validator.md` 파일 자체는 FR-2b에 따라 내부 루프 설명 추가로 수정 대상이다.
- `commands/code.md` 및 `commands/start-new.md`의 오케스트레이터 플로우 변경 — 이 두 파일의 단계 순서 및 단계 설명은 그대로 유지한다(FR-2b는 code-validator 내부에만 적용).

---

## 가정

- `docs/AGENT_MODEL_GUIDE.md`에는 에이전트 할당 테이블이 있으며, designer가 pruner에 적합한 모델을 선택하고 해당 테이블을 업데이트한다.
- `commands/start-new.md`와 `commands/code.md`가 오케스트레이터 단계 실행을 정의하는 두 개의 유일한 권위 파일이다. 다른 파일이 독립적으로 단계를 트리거하지 않는다.
- `/dotclaude:prune` 인수 구분: `\d+[A-Z]?` 또는 `\d+\.\d+` 패턴과 일치하는 정수 또는 영숫자는 phase id로 처리한다. `#N` 또는 GitHub 도메인 URL은 GitHub issue/PR로 처리한다. `ABC-123`과 같이 대문자 접두사 패턴은 Jira 키로 처리한다.
- pruner의 code mode 재검증(FR-2b)은 code-validator의 3회 재시도 루프와 별도의 단일 패스이다. 재검증 실패 시 pruning 변경 사항을 되돌리는 것이 기존 재시도 예산에 영향을 주지 않는다.

---

## 충돌 및 설계 결정

| 충돌 | 결정 |
|------|------|
| Issue #76 원문: `commands/code.md`의 `code-validator` 후에 고정 단계 추가 vs 플로우 가시 길이 우려 | 사용자 결정: 설계 단계에 doc mode 삽입(FR-2a) + 코드 단계는 code-validator 내부 루프에 흡수(FR-2b). `commands/code.md` 및 `commands/start-new.md` 플로우는 외부적으로 변경 없음. |

---

## 엣지 케이스

| # | 케이스 | 기대 동작 |
|---|--------|-----------|
| 1 | pruner가 제거할 것을 찾지 못함 | "제거할 것 없음"을 정상적인 비오류 결과로 보고한다. 후속 단계(TechnicalWriter 적용 또는 coder 재호출) 없이 바로 커밋으로 진행한다. |
| 2 | 한 동작의 테스트 전체가 삭제 후보임 (doc mode 또는 code mode) | 동작당 최소 1개의 테스트를 유지한다. 가장 적합한 후보는 삭제 목록에서 제외한다. |
| 3 | code mode(FR-2b): pruning 적용 후 스위트가 RED가 됨 | code-validator의 pruning 재검증은 단일 패스로 실행된다. 재검증 실패 시 즉시 pruning 변경 사항만 되돌리고 이전 GREEN 결과를 PASS로 반환한다. 이 과정은 code-validator의 3회 재시도 루프와 독립적이다(엣지 케이스 #11 참조). |
| 4 | 테스트 라인이 로직 라인의 약 3배를 초과함 | pruner 보고서에 경고만 포함한다. 비블로킹. |
| 5 | 테스트가 없는 단계(예: docs 전용 단계) | pruner는 docstring/주석만 검토하거나 분석할 것이 없으면 "분석 대상 없음"을 보고한다. |
| 6 | `/dotclaude:prune` 인수 없음 + 커밋되지 않은 변경 없음 | "분석 대상 없음"을 보고하고 즉시 종료한다. |
| 7 | 인수 구분 | `1`, `3A`, `3.5` → phase id; `#N` 또는 GitHub URL → GitHub issue/PR (PR → `gh pr diff`; issue → 연결된 PR 또는 브랜치 diff vs `base_branch`); `ABC-123` 패턴 → Jira 키 → 키를 포함하는 브랜치, `base_branch` 대비 diff. |
| 8 | 티켓에서 브랜치 또는 PR을 찾을 수 없음 | 오류를 보고하고 종료한다. 추측하거나 폴백을 사용하지 않는다. |
| 9 | 독립형 `/dotclaude:prune` 결과 | 보고만 한다. 보고서 적용은 별도의 명시적 사용자 지시가 필요하다. |
| 10 | doc mode: 후보 적용 후 어떤 동작의 테스트가 0개가 됨 | TechnicalWriter는 해당 동작의 테스트를 최소 1개 유지한다. pruner 보고서의 해당 후보는 적용하지 않는다. |
| 11 | code-validator 내부 pruning 재검증 실패 및 재시도 예산 | pruning 적용 후 단일 재검증 패스가 실패하면 즉시 pruning 변경 사항만 되돌리고 이전 GREEN 결과를 반환한다. 이 단일 패스는 code-validator의 3회 최대 재시도 루프와 별도로 계산된다. 재시도 예산을 소모하지 않는다. |

---

## 미결 사항

- [x] OQ-1: 해결됨 → frontmatter `tools:` 필드로 read-only 도구 집합(Read, Grep, Glob, Bash)으로 제한한다. Bash는 diff/라인 수 계산에 필요하므로 프롬프트에서 Bash를 통한 파일 수정을 명시적으로 금지한다. frontmatter 지원 여부 최종 확인은 설계 단계에서 수행한다.
- [x] OQ-2: 해결됨 → README.md는 Step 11 DOCS_UPDATE 단계에서 업데이트한다. 이 SPEC의 코드 단계에는 포함하지 않는다.

---

## 참고

- 소스 이슈: https://github.com/U-lis/dotclaude/issues/76
- 관련 이슈 (부분 중복): https://github.com/U-lis/dotclaude/issues/73
- 관련 파일 (분석 기반):

| # | 파일 | 줄 | 관계 |
|---|------|----|------|
| 1 | `templates/PHASE_TEST.md` | 1–142 | 수정 대상(커버리지 70% 게이트, 함수별 unit 슬롯, 일반 edge cases 목록) |
| 2 | `commands/code.md` | 31–66 | 단일 단계 워크플로우; 오케스트레이터 플로우 변경 없음(FR-2b는 code-validator 내부에 흡수) |
| 3 | `commands/code.md` | 214–262 | `code all` 워크플로우; 오케스트레이터 플로우 변경 없음 |
| 4 | `commands/start-new.md` | 345, 755–815 | Step 10 단계 실행 + `code-validator` 호출; 오케스트레이터 플로우 변경 없음 |
| 5 | `commands/design.md` | Step 7 → Step 8 구간 | 수정 대상(FR-2a: TechnicalWriter 설계 문서 생성 후, 설계 커밋 전 pruner(doc mode) 삽입) |
| 6 | `commands/start-new.md` | Step 7 → Step 8 구간 | 수정 대상(FR-2a: 설계 단계 내 pruner(doc mode) 삽입; 행 4의 코드 단계와 별개) |
| 7 | `agents/spec-validator.md` | 42–50, 66–84 | 커버리지 70% 체크, 완전성 항목, "TechnicalWriter에게 수정 보고" 루프 |
| 8 | `commands/validate-spec.md` | 63 | "Coverage target achievable (≥ 70%)" |
| 9 | `agents/technical-writer.md` | 44, 165–181 | PHASE_TEST 설명 및 70% 포함 구조 |
| 10 | `agents/code-validator.md` | 내부 루프 전체 | 수정 대상(FR-2b: PASS 후 pruner(code mode) 호출 및 단일 재검증 로직 추가); 225줄("Test coverage: {X}%")은 정보성 출력으로 유지 |
| 11 | `docs/AGENT_MODEL_GUIDE.md` | — | 신규 pruner 에이전트 모델 할당; 에이전트 할당 테이블 업데이트 |
| 12 | `README.md` | — | spec-validator 언급; 명령어 목록에 `/dotclaude:prune` 포함 가능 |

**참고**: `agents/spec-validator.md`는 기본 start-new/code 플로우에 포함되지 않는다. `commands/design.md`:102를 통해 `/dotclaude:validate-spec`으로만 수동 실행을 권장한다. 따라서 FR-4는 수동 validate-spec 실행에만 영향을 준다.
