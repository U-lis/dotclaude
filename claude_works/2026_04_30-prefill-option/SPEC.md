<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-prefill-option
doc_dir: 2026_04_30-prefill-option
-->

# SPEC: /dotclaude:start-new --prefill 옵션 추가

**Source Issue**: https://github.com/U-lis/dotclaude/issues/13
**Source Conversation**: prefill
**Target Version**: 0.5.0
**Work Type**: feature
**Branch**: feature/prefill-option

---

## Overview (개요)

**목표**: `/dotclaude:start-new` 명령에 `--prefill` 옵션을 추가하여, `/dotclaude` 컨텍스트 외부에서 진행된 일반 GP(General-Purpose) agent 대화 내용을 작업 초기화의 input으로 활용한다.

**문제**: `/dotclaude` 없이 일반 GP agent와 대화하다 내용이 정리되어 작업으로 전환할 때, 이미 정리된 정보를 init-xxx 단계에서 다시 입력해야 하는 중복이 발생한다. GitHub URL prefill은 이미 동일한 문제를 해결하지만, 일반 대화에는 적용되지 않는다.

**해결 방향**: GitHub Issue prefill의 라우팅/추출 패턴(`commands/init-github-issue.md`)을 그대로 재활용하여, 대화 본문을 입력 소스로 받아 work_type을 자동 감지하고 각 init-xxx의 `pre_filled` 인프라에 컨텍스트를 전달한다. 이로써 신규 인프라 도입 없이 동일한 사용자 경험을 일반 대화 시나리오로 확장한다.

---

## Functional Requirements (기능 요구사항)

### Core Features

- [ ] **FR-1**: `/dotclaude:start-new`가 `--prefill` 옵션을 인식하고 파싱한다.
- [ ] **FR-2**: `--prefill` 사용 시 직전 대화 내용이 input으로 전달된다 (사용자가 명시적으로 호출하면서 컨텍스트를 제공하는 형태).
- [ ] **FR-3**: `start-new`는 전달된 대화 내용을 분석하여 `work_type`(`feature` / `bugfix` / `refactor`)을 자동 감지한다. 감지 알고리즘은 `commands/init-github-issue.md`의 work type detection 로직을 그대로 재사용한다.
- [ ] **FR-4**: 대화 내용에서 각 init-xxx의 `pre_filled` 키를 휴리스틱으로 추출한다.
  - `init-feature` 대상 키: `goal`, `problem`, `core_features` 등
  - `init-bugfix` 대상 키: `symptoms`, `reproduction_steps` 등
  - `init-refactor` 대상 키: `target`, `problems` 등
- [ ] **FR-5**: 추출된 `pre_filled` 컨텍스트를 init-xxx에 전달하여 해당 질문은 자동 스킵된다. 모든 init-xxx는 이미 `pre_filled` 처리 인프라를 보유하고 있으므로 추가 구현 없이 동작한다 (`commands/init-feature.md` line 16-31, `commands/init-bugfix.md` line 16-31, `commands/init-refactor.md` line 16-31 참조).
- [ ] **FR-6**: SPEC.md 헤더에 `**Source Conversation**: prefill` 표기를 추가하여 prefill 사용 여부를 기록한다.

### Secondary Features

- [ ] **FR-7** (good to have): 명시적 `--prefill` 입력 없이도 현재 대화 컨텍스트가 풍부할 경우 자동 감지하여 prefill 활성화. 자동 감지 기준은 구현 단계에서 결정 (예: 대화 길이, 키워드 밀도 등).
- [ ] **FR-8**: prefill 미리보기 — 추출된 `pre_filled` 값을 SPEC 작성 전 단계에서 별도 미리보기로 노출하지 않는다. GitHub URL prefill과 동일한 원칙으로 SPEC.md 검토(start-new Step 3)를 최종 검증 게이트로 사용한다.
- [ ] **FR-9**: GitHub Issue/PR URL이 prefill flow와 함께 입력되면, 해당 URL을 fetch하여 내용을 summarize한 뒤 사용자에게 제시하고 `AskUserQuestion`으로 활용 방식을 확인한다. 다음 두 시나리오 모두 동일한 flow를 적용한다:
  - **Scenario A (명시적 동시 사용)**: `/dotclaude:start-new <github-url> --prefill <text>` — positional URL 인자와 `--prefill` 플래그가 동시에 입력됨. (Conflict #2 해소)
  - **Scenario B (URL이 prefill 본문에 포함)**: `--prefill` 본문 텍스트 내에서 GitHub Issue/PR URL이 정규식 매칭으로 발견됨. (Edge Case #5 해소)
  - 감지 정규식 패턴: `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`
  - 활용 방식 옵션 (`AskUserQuestion` 제공):
    - **병합(Merge)**: URL의 추출 정보(`init-github-issue` 패턴)와 prefill `pre_filled`를 합침. 동일 키 충돌 시 기본은 prefill 우선.
    - **URL 우선(Override)**: URL의 추출 정보로 prefill `pre_filled` 동일 키를 덮어씀.
    - **URL 무시(Ignore)**: URL은 단순 참조 링크로만 보존하고 prefill 컨텍스트만 사용.
    - **취소(Cancel)**: prefill 전체를 폐기하고 일반 init flow로 폴백.
  - URL fetch 실패 시: 사용자에게 알림 후 prefill 컨텍스트만으로 자동 폴백.

---

## Non-Functional Requirements (비기능 요구사항)

### Security

- [ ] **NFR-1**: 대화 내용에서 민감정보(API 토큰, 비밀번호, 인증서, 개인 식별 정보)를 추출 단계 이전에 필터링한다. 필터링 규칙은 정규식 기반 키 패턴 매칭을 사용한다.
  - 예시 패턴: `sk-...` (API 키), `password=...`, `Bearer ...`, 이메일 주소, 전화번호, 신용카드 번호, JWT 토큰
  - 필터링된 토큰은 `[REDACTED]` 등 마스킹 문자열로 치환

### Performance

- [ ] **NFR-2**: 추가 성능 요구사항 없음. 기존 init flow와 동등한 응답 시간을 유지한다.

---

## Constraints (제약사항)

### Technical Constraints

- **C-1 (기술 패턴)**: `commands/init-github-issue.md`의 prefill 라우팅 패턴을 그대로 따른다. 즉:
  - work type 감지 → 해당 init-xxx 호출
  - `pre_filled` 블록을 YAML 형식으로 전달
  - 빈/null 값은 omit (init-xxx의 pre-fill check 규약과 호환)
- **C-2**: 기존 `pre_filled` 인프라(`init-feature` / `init-bugfix` / `init-refactor`의 pre-fill check)를 재사용한다. **신규 인프라 도입 금지**.
- **C-3**: 본 작업 대상은 dotclaude plugin 명령 파일(`commands/*.md`)이며, 마크다운 지시문만 변경한다. **실행 코드(스크립트, 바이너리) 변경 없음**.

### Business Constraints

- 타임라인: 0.5.0 릴리스 사이클 내 완료
- 예산: 별도 제약 없음

---

## Out of Scope (제외 항목)

본 작업에서 명시적으로 다루지 않는 항목:

- **OOS-1**: GUI/웹 인터페이스를 통한 prefill 입력 지원. CLI 슬래시 명령에 한정한다.
- **OOS-2**: 대화 압축/요약을 위한 별도 LLM 전처리 단계. 매우 긴 대화도 그대로 전달하며, 전처리가 필요할 경우 별도 이슈로 분리한다.

---

## Analysis Results (분석 결과)

### Related Code

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | `commands/start-new.md` | 인자 처리부 (ARGUMENTS) | 메인 수정 대상. `--prefill` 인자 파싱 분기 추가 필요 |
| 2 | `commands/init-github-issue.md` | 130-294 | 참조 패턴. 본문→`pre_filled` 추출, work_type 감지, 각 init-xxx 라우팅 로직 모두 재활용 가능 |
| 3 | `commands/init-feature.md` | 16-31, 39-138 | `pre_filled` pre-fill check 인프라 이미 존재 — 그대로 사용 |
| 4 | `commands/init-bugfix.md` | 16-31 | 동일 인프라 |
| 5 | `commands/init-refactor.md` | 16-31 | 동일 인프라 |
| 6 | `commands/_init-common.md` | branch creation | 변경 없음, 그대로 사용 |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | `start-new`는 ARGUMENTS를 단일 위치 인자(GitHub URL)로 처리 | `--prefill <content>` 플래그 인식 필요 | 인자 파싱 분기: `--prefill`로 시작하면 prefill 모드, 그 외 URL 형식이면 GitHub Issue 모드, 빈 인자는 일반 모드 |
| 2 | `start-new <github-url> --prefill <text>` 형태로 두 prefill 소스가 동시 입력될 때 우선순위 미정의 | 두 소스를 어떻게 결합할지 명확히 정의 필요 | **FR-9 적용**. URL을 fetch+summarize 후 `AskUserQuestion`으로 4가지 옵션(병합/URL 우선/URL 무시/취소) 제공. 정적 우선순위 대신 사용자 결정에 위임 |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | `--prefill` 빈 내용 | 일반 init flow로 폴백 (Step 1부터 정상 진행) |
| 2 | 민감정보 포함 prefill | 추출 전 필터링 (NFR-1 규칙 적용), 필터링된 내용으로 진행 |
| 3 | `work_type` 자동 감지 모호 | `commands/init-github-issue.md` Step 3의 사용자 확인 패턴 동일 적용. `AskUserQuestion`으로 work_type 선택 |
| 4 | `pre_filled` 값 추출 실패한 필드 | 해당 필드는 omit. 정상 init-xxx 흐름에서 사용자에게 질문 |
| 5 | **Scenario B**: `--prefill` 본문 텍스트 안에 GitHub Issue/PR URL이 포함됨 | URL을 fetch+summarize 후 `AskUserQuestion`으로 활용 방식(병합/URL 우선/URL 무시/취소) 확인. FR-9 참조 |
| 6 | 매우 긴 prefill | 그대로 전달. 압축은 본 작업 범위 외 (OOS-2) |
| 7 | prefill 값이 후속 SPEC 검토에서 사용자 수정과 충돌 | SPEC 검토(start-new Step 3)가 최종 검증 게이트. 사용자 수정이 우선 |
| 8 | dotclaude 세션 내부에서 `--prefill` 호출 | 메타 처리 없이 동일 로직 적용. 외부 대화와 동일하게 처리 |
| 9 | **Scenario A**: `start-new <github-url> --prefill <text>` 동시 입력 | URL을 fetch+summarize 후 `AskUserQuestion`으로 활용 방식(병합/URL 우선/URL 무시/취소) 확인. FR-9 참조. (Conflict #2의 운영 정의) |

---

## Assumptions (가정)

- 사용자는 `--prefill` 호출 시 의미 있는 대화 컨텍스트(요구사항, 문제 설명, 목표 등)를 명령에 함께 전달한다.
- 각 init-xxx의 기존 `pre_filled` 인프라(line 16-31)는 본 작업 종료 시점까지 안정적으로 유지된다.
- Claude의 자연어 이해 능력으로 work_type 감지 및 `pre_filled` 키 추출이 충분히 정확하게 수행된다 (별도 ML/규칙 엔진 불필요).

---

## Open Questions (미해결 질문)

- [ ] FR-7(자동 감지) 활성화 임계값을 어떻게 정의할 것인가? (대화 길이, 키워드 밀도, 명시적 키워드 등)
- [ ] NFR-1 필터링 정규식 패턴 목록을 어디에 명시할 것인가? (`commands/start-new.md` 내부 vs 별도 공통 파일)
- [ ] FR-9의 GitHub URL 감지 시 기본 활용 옵션은 무엇으로 할 것인가? (병합/URL 우선/URL 무시 중 default) — design 단계에서 결정.
- [ ] FR-9에서 URL fetch 실패 시 재시도 정책 (즉시 폴백 vs 1회 재시도 후 폴백)

---

## References

- Source Issue: https://github.com/U-lis/dotclaude/issues/13
- Reference Pattern: `commands/init-github-issue.md` (line 130-294)
- Pre-fill Infrastructure: `commands/init-feature.md` (line 16-31), `commands/init-bugfix.md` (line 16-31), `commands/init-refactor.md` (line 16-31)
- Entry Point: `commands/start-new.md`
- Related Edge Cases: #5 (Scenario B: URL embedded in prefill body), #9 (Scenario A: simultaneous URL arg + --prefill)
- Related Conflict: #2 (simultaneous URL arg + --prefill resolution → FR-9)
