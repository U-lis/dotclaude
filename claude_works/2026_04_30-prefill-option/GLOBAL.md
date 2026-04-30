# DESIGN: /dotclaude:start-new --prefill 옵션 추가

**Source SPEC**: `claude_works/2026_04_30-prefill-option/SPEC.md`
**Source Issue**: https://github.com/U-lis/dotclaude/issues/13
**Target Version**: 0.5.0
**Branch**: feature/prefill-option
**Worktree**: `../dotclaude-feature-prefill-option`

---

## Feature Overview

### Purpose
`/dotclaude:start-new` 명령에 `--prefill` 옵션을 추가하여, `/dotclaude` 컨텍스트 외부에서 진행된 일반 GP(General-Purpose) agent 대화 내용을 작업 초기화의 입력으로 활용한다.

### Problem
사용자가 `/dotclaude` 외부에서 일반 대화로 요구사항/문제를 정리한 뒤 작업으로 전환할 때, 동일 정보를 init-xxx 단계에서 다시 입력해야 하는 중복이 발생한다. GitHub URL prefill은 이미 동일한 문제를 GitHub issue에 한해 해결한다.

### Solution
`commands/init-github-issue.md`의 라우팅/추출 패턴을 그대로 재활용하는 신규 internal command `commands/init-prefill.md`를 도입한다. 이 명령은:
1. `--prefill <text>` 본문을 입력으로 받아
2. `work_type`(feature/bugfix/refactor)을 자동 감지하고
3. 각 init-xxx의 `pre_filled` 인프라를 통해 컨텍스트를 전달한다.

신규 인프라 도입 없이 기존 `pre_filled` 처리 인프라(`init-feature.md` line 16-31, `init-bugfix.md` line 16-31, `init-refactor.md` line 16-31)를 그대로 재사용한다.

---

## Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| **AD-1** | 신규 `commands/init-prefill.md`를 추가하고 `init-github-issue.md`와 평행한 internal command로 다룬다 (`user-invocable: false`). | `init-github-issue.md`의 검증된 라우팅/추출 패턴을 그대로 평행 복제하면, 신규 인프라 도입 없이 동등한 사용자 경험을 일반 대화 시나리오로 확장할 수 있다. start-new.md 본문 비대화 방지. |
| **AD-2** | `start-new.md`에 "Step 0: Argument Parsing" 섹션을 신설하고, `--prefill` / GitHub URL / 둘 다 / 빈 인자의 4-row 분기 매트릭스를 정의한다. | 기존 Step 1(Work Type Selection) 본문은 unmodified로 유지하면서, ARGUMENTS의 사전 파싱만 추가한다. 위치 인자(URL)와 `--prefill` 플래그의 라우팅 분기를 한 곳에 명문화. |
| **AD-3** | FR-9 (GitHub URL + prefill 동시 처리)는 `init-prefill.md` 내부 "Step 2.5: GitHub URL Detection & Resolution" 섹션에서 처리한다. | URL 감지/fetch/사용자 옵션 제시는 prefill 컨텍스트 분석과 분리할 수 없는 처리이며, init-prefill.md 내부에서 일관되게 다루는 것이 라우팅 분기와 정합성 유지에 유리하다. |
| **AD-4** | FR-9의 default & 권장 옵션은 **"병합(Merge), prefill 우선"**이다. | SPEC.md FR-9에서 "동일 키 충돌 시 기본은 prefill 우선"이 명시되었다. 사용자가 `--prefill`을 명시적으로 입력했다는 행위 자체가 prefill 본문을 1차 입력으로 의도한다는 신호이며, URL은 보조 컨텍스트로 작동한다. |
| **AD-5** | NFR-1 민감정보 필터링 정규식 패턴은 신규 `commands/_prefill-filters.md`에 별도로 명세하고, `init-prefill.md` Step 2에서 reference한다. | `_init-common.md`처럼 underscore-prefixed internal reference 파일 컨벤션을 따른다. start-new.md 또는 init-prefill.md 본문에 정규식을 직접 인라인하면 가독성이 저하되며, 향후 패턴 추가 시 변경 영향이 분산되는 것을 방지한다. |
| **AD-6** | FR-7 (명시적 `--prefill` 없이 자동 감지) 및 FR-9의 URL fetch 재시도 정책은 본 작업 범위에서 분리하여 후속 이슈로 처리한다. | FR-7은 SPEC에서 "good to have"로 표기되었고, 활성화 임계값 정의가 별도 설계가 필요하다. URL fetch 재시도 정책은 본 작업의 핵심(라우팅/추출/필터링)과 직교한다. 두 항목 모두 0.5.0 릴리스 사이클의 핵심 가치 제공에 필수적이지 않다. 본 작업에서는 즉시 폴백으로 처리(SPEC.md FR-9 마지막 항목 준수). |
| **AD-7** | `init-feature.md` / `init-bugfix.md` / `init-refactor.md`는 변경하지 않는다. | C-2 제약(신규 인프라 도입 금지)을 준수한다. 기존 `pre_filled` pre-fill check 인프라는 이미 안정적으로 동작하며, init-prefill.md에서 동일 YAML 스키마로 컨텍스트를 전달하면 그대로 호환된다. |

---

## Phase Overview

| Phase | Description | Type | Status | Dependencies | Effort |
|-------|-------------|------|--------|--------------|--------|
| 1 | ARGUMENTS 파싱 분기 추가 (start-new.md Step 0 신설) | sequential | Pending | - | small |
| 2 | init-prefill.md 신규 작성 (핵심 라우터: work_type 감지 + pre_filled 추출) | sequential | Pending | 1 | large |
| 3 | FR-9: GitHub URL Detection & Resolution flow | sequential | Pending | 2 | medium |
| 4 | NFR-1: 민감정보 필터링 규칙 (`_prefill-filters.md` + Step 2 연결) | sequential | Pending | 2 | medium |
| 5 | 통합 검증 및 문서 정합성 점검 (plugin manifest 등록 포함) | sequential | Pending | 3, 4 | small |

**Notes**:
- Parallel phase 없음. 모든 phase는 sequential 의존을 가진다.
- Merge phase 없음.
- Phase 3와 Phase 4는 모두 Phase 2의 init-prefill.md 산출물에 의존하므로 순차적으로 진행한다 (Phase 3 -> Phase 4 또는 그 반대로 가능하나, 본 설계에서는 3 -> 4 순서를 채택).

---

## File Structure

### Files to Create

| Path | Phase | Purpose |
|------|-------|---------|
| `commands/init-prefill.md` | 2 | prefill 본문 → work_type 감지 → pre_filled 추출 → init-xxx 라우팅 (internal command, `user-invocable: false`) |
| `commands/_prefill-filters.md` | 4 | 민감정보 필터링 정규식 패턴 명세 (internal reference, `user-invocable: false`) |

### Files to Modify

| Path | Phase | Change |
|------|-------|--------|
| `commands/start-new.md` | 1 | "Step 0: Argument Parsing" 섹션 신설 (Configuration Loading 직후) |
| `commands/start-new.md` | 2 | Step 0 placeholder → 실제 `Skill("dotclaude:init-prefill")` 호출로 변경 |
| `commands/start-new.md` | 3 | Step 0 분기 매트릭스 description 정밀화 (URL+prefill 동시 → init-prefill 위임) |
| `commands/init-prefill.md` | 3 | Step 2.5 placeholder → 실제 URL detection & resolution flow로 채움 |
| `commands/init-prefill.md` | 4 | Step 2 placeholder → `_prefill-filters.md` reference로 변환 |
| `.claude-plugin/plugin.json` 또는 `marketplace.json` | 5 | init-prefill 등록 필요 여부 확인 후 (필요 시) 등록 |

### Files NOT Modified (AD-7)

- `commands/init-feature.md` (line 16-31 pre_filled 인프라 그대로 사용)
- `commands/init-bugfix.md` (line 16-31 pre_filled 인프라 그대로 사용)
- `commands/init-refactor.md` (line 16-31 pre_filled 인프라 그대로 사용)
- `commands/_init-common.md` (branch/worktree 생성 로직 그대로 사용)

---

## Data Model

### --prefill 입력 형식

```
/dotclaude:start-new --prefill <text>
/dotclaude:start-new <github-url> --prefill <text>
```

`<text>`는 자유 형식의 대화 본문이며, 사용자가 직전 GP agent 대화에서 정리한 요구사항/문제 설명/목표 등을 담는다.

### init-prefill.md → init-xxx 전달 페이로드 (YAML)

`init-github-issue.md` 패턴과 동일하되 `github_issue` 블록을 `conversation` 블록으로 치환:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{github_url or null}"  # FR-9에서 URL이 함께 입력된 경우 보존

pre_filled:
  # work_type별로 다름. init-github-issue.md line 187-243 참조.
  # feature: goal, problem, core_features, additional_features, technical_constraints,
  #          performance, security, out_of_scope, branch_keyword, target_version
  # bugfix:  symptoms, reproduction_steps, expected_cause, severity, related_files,
  #          impact_scope, branch_keyword, target_version
  # refactor: target, problems, goal_state, behavior_change, test_status,
  #           dependencies, branch_keyword, target_version
```

### SPEC.md 헤더 표기 (FR-6)

```
**Source Conversation**: prefill
```

URL이 함께 입력되었고 사용자가 옵션에서 URL을 무시하지 않은 경우, 추가로:
```
**Source Issue**: {github_url}
```
를 함께 표기한다.

---

## FR/NFR ↔ Phase ↔ File Traceability

| Requirement | Description | Phase | Files |
|-------------|-------------|-------|-------|
| **FR-1** | `--prefill` 인자 인식/파싱 | 1, 2 | `commands/start-new.md` (Step 0), `commands/init-prefill.md` (Step 1) |
| **FR-2** | 대화 input 전달 | 1, 2 | `commands/start-new.md`, `commands/init-prefill.md` |
| **FR-3** | work_type 자동 감지 (init-github-issue.md 로직 재사용) | 2 | `commands/init-prefill.md` (Step 3) |
| **FR-4** | pre_filled 키 휴리스틱 추출 (3개 work_type별 표) | 2 | `commands/init-prefill.md` (Step 4) |
| **FR-5** | pre_filled 컨텍스트 → init-xxx 자동 스킵 (기존 인프라 활용) | 2 | `commands/init-prefill.md` (Step 5), `init-feature.md`/`init-bugfix.md`/`init-refactor.md` (변경 없음) |
| **FR-6** | SPEC.md 헤더 `**Source Conversation**: prefill` 표기 | 2 | `commands/init-prefill.md` (Step 5의 SPEC 작성 가이드) |
| **FR-7** | 자동 감지 (good to have) | **Deferred (AD-6)** | 후속 이슈로 분리 |
| **FR-8** | prefill 미리보기 미사용 (현행 SPEC 검토 게이트 활용) | 변경 없음 | - |
| **FR-9** | GitHub URL + prefill 동시 처리 | 3 | `commands/init-prefill.md` (Step 2.5), `commands/start-new.md` (분기 표) |
| **NFR-1** | 민감정보 필터링 (정규식 기반) | 4 | `commands/_prefill-filters.md`, `commands/init-prefill.md` (Step 2) |
| **NFR-2** | 성능 (기존 init flow와 동등) | 자동 충족 | 마크다운 변경만 → 성능 영향 없음 |

---

## Risks & Mitigations

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 1 | ARGUMENTS 파싱이 사용자 입력의 quoting 변형(예: 따옴표 누락, 줄바꿈 포함)에 취약하여 분기가 어긋날 수 있음 | High | Phase 1에서 Step 0에 quoting 가이드(따옴표 사용, 본문 멀티라인 시 `"<text>"` 형태) 명시. Phase 5의 통합 시나리오에서 quoting edge case 검증. |
| 2 | `init-prefill.md` 미존재 상태에서 사용자가 `--prefill`을 호출하면 분기 후 호출 대상이 없어 흐름이 끊김 | High | Phase 1에서 init-prefill.md 미존재 시 명시적 에러 메시지 placeholder 작성. Phase 2 완료 시 placeholder를 실제 Skill 호출로 치환. |
| 3 | work_type 감지가 모호한 본문(예: "리팩터링 김에 버그도 고치자")에서 잘못된 init-xxx로 라우팅 | Medium | `init-github-issue.md` Step 3의 사용자 확인 패턴(AskUserQuestion)을 그대로 재사용. 모호 시 사용자 명시 선택. SPEC.md 검토(start-new Step 3)가 최종 게이트. |
| 4 | 민감정보 필터링이 정규식 false-positive로 정상 본문 일부를 마스킹 | Medium | `_prefill-filters.md`에 false positive 노트 섹션 추가. 사용자가 `--prefill` 본문을 직접 입력했다는 점에서 본인 데이터는 본인이 검수하는 것이 가능. SPEC.md 검토 단계에서 최종 검증. |
| 5 | `pre_filled` YAML 스키마가 미래의 init-xxx 변경과 어긋남 | Medium | Phase 5에서 init-feature/bugfix/refactor의 line 16-31 표와 init-prefill.md의 Step 5 YAML이 키 단위로 일치하는지 검증. |
| 6 | URL fetch 실패 시 사용자 혼란 (어떤 정보로 진행하는지 불명확) | Low | Phase 3에서 fetch 실패 시 사용자 알림 + prefill 컨텍스트만으로 자동 폴백 명시. AD-6에 따라 1회 시도 후 즉시 폴백. |

---

## Testing Strategy

### Manual Test Scenarios

| # | Scenario | Phase | 검증 대상 |
|---|----------|-------|----------|
| 1 | `--prefill` only with feature-style 대화 | 2 | start-new.md Step 0 → init-prefill 라우팅 → init-feature.md pre_filled 자동 스킵 |
| 2 | `--prefill` + GitHub URL (Scenario A: 명시적 동시 사용) | 3 | URL fetch + AskUserQuestion 4-옵션 → 선택별 후속 처리 |
| 3 | `--prefill` 본문 안에 URL 포함 (Scenario B: 정규식 매칭) | 3 | URL 정규식 감지 → AskUserQuestion 4-옵션 → 선택별 후속 처리 |
| 4 | `--prefill` 본문에 민감정보 포함 (API key, 이메일 등) | 4 | 추출 전 필터링 적용 확인. SPEC.md에 `[REDACTED]` 등 마스킹 반영 |

### Regression Checks

- 빈 인자 `/dotclaude:start-new` 호출 → 기존 Step 1 (Work Type Selection)이 변경 없이 동작
- `/dotclaude:start-new <github-url>` (URL only) → 기존 init-github-issue 라우팅이 변경 없이 동작
- init-feature/bugfix/refactor의 직접 호출 (pre_filled 없이) → 기존 동작 유지

### Coverage Target
≥ 70% (수동 시나리오 기반. 마크다운 명령 파일이므로 자동화된 단위 테스트는 적용 외)

---

## Open Questions Resolution (Designer 결정)

SPEC.md "Open Questions" 섹션의 4개 질문에 대한 본 설계의 결정:

| Question | Resolution | Rationale |
|----------|------------|-----------|
| FR-7 자동 감지 활성화 임계값 | **Deferred to follow-up issue** (AD-6) | 본 작업의 핵심(라우팅/추출/필터링)과 직교. 0.5.0 릴리스 사이클에서 분리. |
| NFR-1 필터링 정규식 명시 위치 | **신규 `commands/_prefill-filters.md`** (AD-5) | `_init-common.md` 컨벤션 따름. start-new.md/init-prefill.md 본문 가독성 보존. |
| FR-9 기본 활용 옵션 | **"병합(Merge), prefill 우선"** (AD-4) | SPEC.md FR-9에 "동일 키 충돌 시 기본은 prefill 우선" 명시. 사용자가 `--prefill`을 입력한 행위 자체가 prefill 1차 입력 의도. |
| FR-9 URL fetch 실패 재시도 | **즉시 폴백 (1회 시도 후 폴백)** (AD-6) | SPEC.md FR-9 마지막 항목 ("URL fetch 실패 시: 사용자에게 알림 후 prefill 컨텍스트만으로 자동 폴백") 준수. 재시도 정책 정교화는 후속 이슈. |
