# PHASE 5 TEST

## Test Status

- **Status**: Passed
- **Last Run**: 2026-04-30
- **Result**: PASS (정적 일관성 검증 완료, 런타임 시나리오는 사용자 직접 수행으로 인계)

---

## Test Items

### Task 5.1: Routing Branch Consistency

- [x] `start-new.md` Step 0 4-row 분기 매트릭스 표가 존재한다 — **PASS**
- [x] "URL only" row → init-github-issue.md Step 1 (line 20-32)이 GitHub URL 입력을 정상 수신 — **PASS**
- [x] "--prefill only" row → init-prefill.md Step 1 (Prefill Input Reception)이 prefill_body를 정상 수신 — **PASS**
- [x] "URL + --prefill 동시" row → init-prefill.md Step 1 + Step 2.5 흐름이 url_reference를 정상 수신 — **PASS**
- [x] "neither" row → 기존 Step 1 (Work Type Selection, line 68-79)으로 진행 — **PASS**

### Task 5.2: pre_filled YAML Schema Consistency

#### Feature work_type

- [x] init-prefill.md Step 5 Feature 페이로드의 `pre_filled` 키 = init-feature.md line 22-31의 키 = init-github-issue.md line 197-202의 키 — **PASS**
- [x] 8개 키 모두 존재: `goal`, `problem`, `core_features`, `additional_features`, `technical_constraints`, `performance`, `security`, `out_of_scope` — **PASS**
- [x] 추가 키 `branch_keyword`, `target_version`도 일관 — **PASS**

#### Bugfix work_type

- [x] init-prefill.md Step 5 Bugfix 페이로드의 `pre_filled` 키 = init-bugfix.md line 16-31의 키 = init-github-issue.md line 215-220의 키 — **PASS**
- [x] 6개 키 모두 존재: `symptoms`, `reproduction_steps`, `expected_cause`, `severity`, `related_files`, `impact_scope` — **PASS**

#### Refactor work_type

- [x] init-prefill.md Step 5 Refactor 페이로드의 `pre_filled` 키 = init-refactor.md line 16-31의 키 = init-github-issue.md line 234-239의 키 — **PASS**
- [x] 6개 키 모두 존재: `target`, `problems`, `goal_state`, `behavior_change`, `test_status`, `dependencies` — **PASS**

#### YAML Block Structure

- [x] init-prefill.md는 `conversation` 블록을 사용 (`source`, `body`, `url_reference`) — **PASS**
- [x] init-github-issue.md는 `github_issue` 블록을 사용 (line 188-191): `url`, `number`, `title`, `body` — **PASS**
- [x] 두 블록은 평행 구조 (init-xxx 인프라가 추가 변경 없이 둘 다 처리 가능) — **PASS**

### Task 5.3: FR/NFR Traceability

GLOBAL.md의 traceability 표를 점검:

- [x] FR-1: Phase 1, 2 / start-new.md, init-prefill.md → 실제 산출물 존재 — **PASS**
- [x] FR-2: Phase 1, 2 / 동일 → 실제 흐름 존재 — **PASS**
- [x] FR-3: Phase 2 / init-prefill.md Step 3 → 키워드 분석 + AskUserQuestion 분기 존재 — **PASS**
- [x] FR-4: Phase 2 / init-prefill.md Step 4 → 3개 heuristic 표 존재 — **PASS**
- [x] FR-5: Phase 2 / init-prefill.md Step 5 + init-feature/bugfix/refactor.md (변경 없음) → pre_filled 페이로드가 기존 인프라 호환 — **PASS**
- [x] FR-6: Phase 2 / init-prefill.md Step 5 SPEC.md 헤더 가이드 → `**Source Conversation**: prefill` 존재 — **PASS**
- [x] FR-7: Deferred (AD-6) — GLOBAL.md에 명시 확인 — **PASS** (Deferred 명시 확인)
- [x] FR-8: 변경 없음 — 기존 SPEC 검토 게이트 활용 명시 확인 — **PASS**
- [x] FR-9: Phase 3 / init-prefill.md Step 2.5 → AskUserQuestion 4-옵션, default = Merge — **PASS**
- [x] NFR-1: Phase 4 / _prefill-filters.md + init-prefill.md Step 2 → 7-row 패턴 + reference 존재 — **PASS**
- [x] NFR-2: 자동 충족 — 마크다운 변경만 확인 — **PASS**

### Task 5.4: Plugin Manifest

- [x] `.claude-plugin/plugin.json` 파일 검토 완료 — **PASS**
- [x] init-github-issue 등록 형태 파악 완료 — **PASS** (plugin.json에 명시 등록되지 않음. 자동 스캔 컨벤션)
- [x] init-prefill 등록 필요 여부 결정:
  - [ ] **Case A**: 등록 필요 → 추가 완료
  - [x] **Case B**: 등록 불필요 → 사유 명시 — **선택됨**: dotclaude plugin은 commands/*.md 자동 인식. init-github-issue.md도 등록되지 않음. init-prefill.md도 동일 컨벤션 적용. 코드 변경 없음.
- [x] _prefill-filters는 internal reference이므로 등록 대상 아님 (확인) — **PASS**
- [x] `.claude-plugin/marketplace.json` 검토 완료 — **PASS** (등록 불필요 확인)

### Task 5.5: 4 Scenarios Integration Test

- [x] **Scenario 1** (Phase 2): `--prefill <feature-style text>` → 정상 — **검증 인계** (런타임은 사용자 직접 수행)
- [x] **Scenario 2** (Phase 3): `<url> --prefill <text>` → 4-옵션 정상, sub-scenario 4개 모두 동작 — **검증 인계**
- [x] **Scenario 3** (Phase 3): `--prefill "<text including url>"` → 정규식 매칭 + 4-옵션 정상 — **검증 인계**
- [x] **Scenario 4** (Phase 4): `--prefill "<text with secrets>"` → 필터링 적용 + SPEC.md disclosure 정상 — **검증 인계**

### Task 5.6: Regression Tests

- [x] `/dotclaude:start-new` (빈 인자) → 기존 Step 1 정상 노출 — **PASS** (정적 일관성)
- [x] `/dotclaude:start-new https://github.com/U-lis/dotclaude/issues/13` → init-github-issue 라우팅 정상 — **PASS**
- [x] `/dotclaude:init-feature` 직접 호출 → 모든 질문 정상 진행 (pre_filled 없음) — **PASS** (init-feature.md unchanged)
- [x] `/dotclaude:init-bugfix` 직접 호출 → 동일 — **PASS** (init-bugfix.md unchanged)
- [x] `/dotclaude:init-refactor` 직접 호출 → 동일 — **PASS** (init-refactor.md unchanged)

### Task 5.7: Inter-Document Links

- [x] init-prefill.md → `commands/_prefill-filters.md` reference 경로 정확 — **PASS**
- [x] init-prefill.md → init-github-issue.md reference의 line 번호 정확 (line 80-87, 135-168 등) — **PASS**
- [x] start-new.md → `Skill("dotclaude:init-prefill")` namespace 정확 — **PASS**
- [x] start-new.md → `Skill("dotclaude:init-github-issue")` namespace 정확 (변경 없음) — **PASS**

### Task 5.8: GLOBAL.md Phase Status

- [x] Phase 1~5 Status가 모두 "Pending"으로 시작하여, code-validator가 phase 완료 시 "Complete"로 갱신할 수 있는 형태 — **PASS**
- [x] Phase 5 Status는 본 phase 종료 시 "Complete"로 갱신 — **완료**

---

## Manual Test Scenarios

### Integrated Scenario A: Full feature flow with prefill

**입력**:
```
/dotclaude:start-new --prefill "사용자가 작성 권한 요청 기능을 원합니다. core: 1) 요청 양식 2) 승인 워크플로우 3) 알림. 기술 제약: 기존 권한 모델과 호환. 보안: 요청 로그 보존."
```

**검증 절차**:
1. start-new.md Step 0 "--prefill only" 분기 → init-prefill 호출
2. Step 1: prefill_body 수신 (비어있지 않음)
3. Step 2: 민감정보 필터링 (없음, no-op)
4. Step 2.5: URL 검사 (없음, no-op)
5. Step 3: 키워드 "기능", "원합니다" → feature 감지
6. Step 4: Feature 휴리스틱 적용
   - `goal`: "작성 권한 요청 기능"
   - `core_features`: "1) 요청 양식 2) 승인 워크플로우 3) 알림"
   - `technical_constraints`: "기존 권한 모델과 호환"
   - `security`: "요청 로그 보존"
7. Step 5: init-feature.md 라우팅. YAML 페이로드 전달
8. init-feature.md line 16-31 pre-fill check가 자동 스킵 처리
9. start-new.md Step 2.6 (Target Version) 정상 진행
10. SPEC.md 작성 시 헤더에 `**Source Conversation**: prefill` 포함
11. SPEC.md "Notes" 섹션에 redaction disclosure 미포함 (no redaction)

**기대 결과**: Goal/Core Features/Technical Constraints/Security 4개 step이 자동 스킵되고, 나머지 step (additional_features, performance, out_of_scope)은 사용자에게 정상 질문됨.

### Integrated Scenario B: Full bugfix flow with URL + sensitive data

**입력**:
```
/dotclaude:start-new https://github.com/U-lis/dotclaude/issues/13 --prefill "Login API의 토큰 갱신이 실패합니다. 재현: 1) 로그인 2) 5분 대기 3) GET /api/me 호출. 결과: 401 에러. 디버그 로그에 'Bearer eyJhbGciOiJIUzI1NiJ9.fake.signature'가 노출되어 있습니다. 담당자: dev@team.com"
```

**검증 절차**:
1. start-new.md Step 0 "URL + --prefill 동시" 분기
2. init-prefill 호출 (url_reference 전달)
3. Step 1: prefill_body 수신
4. Step 2: 민감정보 필터링 적용
   - JWT 매칭 → `[REDACTED:JWT]`
   - Bearer 매칭 → `Bearer [REDACTED]` (또는 적용 순서에 따라)
   - Email 매칭 → `[REDACTED:EMAIL]`
   - filtered_prefill_body 산출, 3 redactions 기록
5. Step 2.5: URL 처리 (Scenario A — url_reference 존재)
   - gh issue view 호출 → url_fetch_result
   - AskUserQuestion 4-옵션 (default Merge)
   - 사용자가 "Merge" 선택 가정
   - URL 본문에 대해 init-github-issue.md Step 4 적용 → url_pre_filled
   - prefill_body에서 추출한 pre_filled와 병합 (prefill 우선)
6. Step 3: 키워드 "실패", "에러" → bugfix 감지
7. Step 4: Bugfix 휴리스틱 적용
   - `symptoms`: "Login API의 토큰 갱신이 실패"
   - `reproduction_steps`: "1) 로그인 2) 5분 대기 3) GET /api/me 호출"
8. Step 5: init-bugfix.md 라우팅
9. SPEC.md 헤더: `**Source Conversation**: prefill`, `**Source Issue**: https://github.com/U-lis/dotclaude/issues/13`
10. SPEC.md "Notes" 섹션:
    ```
    The prefill content was filtered for sensitive data before extraction:
    - JWT tokens: 1 redaction
    - Email addresses: 1 redaction
    ```
    (Bearer는 JWT 매칭 후 이미 redacted된 부분이므로 별도 카운트 없거나 처리 정책에 따름)

**기대 결과**: 모든 통합 흐름이 끊김 없이 동작. 민감정보 비노출. URL 병합 결과 반영.

### Integrated Scenario C: Cancel option in URL flow

**입력**: Integrated Scenario B와 동일하나, AskUserQuestion에서 "Cancel" 선택

**검증 절차**:
1. ~Step 2.5 까지는 Scenario B와 동일
2. AskUserQuestion → "Cancel"
3. init-prefill halt
4. start-new.md Step 1 (Work Type Selection)으로 폴백
5. 사용자가 일반 init flow로 진행 가능

**기대 결과**: prefill 전체 폐기, 일반 init flow로 매끄럽게 폴백

---

## Regression Checks

### From All Previous Phases

- [x] Phase 1 Scenario 1.1 (빈 인자) — 통합 후에도 동작 — **검증 인계** (런타임)
- [x] Phase 1 Scenario 1.2 (URL only) — 통합 후에도 동작 — **검증 인계**
- [x] Phase 2 Scenario 1 (--prefill only feature) — 통합 후에도 동작 — **검증 인계**
- [x] Phase 2 Scenario 1-Edge (빈 prefill) — 통합 후에도 동작 — **검증 인계**
- [x] Phase 2 Scenario 1-Bugfix, 1-Refactor, 1-Ambiguous — 통합 후에도 동작 — **검증 인계**
- [x] Phase 3 Scenario 2 sub-scenarios 1~4 — 통합 후에도 동작 — **검증 인계**
- [x] Phase 3 Scenario 3 + edges — 통합 후에도 동작 — **검증 인계**
- [x] Phase 4 Scenario 4 + edges — 통합 후에도 동작 — **검증 인계**

### File Unchanged

- [x] `commands/init-feature.md` unchanged (line 단위 diff = 0) — **PASS**
- [x] `commands/init-bugfix.md` unchanged — **PASS**
- [x] `commands/init-refactor.md` unchanged — **PASS**
- [x] `commands/_init-common.md` unchanged — **PASS**
- [x] `commands/init-github-issue.md` unchanged — **PASS**

---

## Notes / Observations

- 본 phase는 검증 중심이므로 산출물 자체보다 검증 절차의 완결성이 핵심
- 발견된 불일치는 우선 fix-up commit으로 해결 시도. 광범위하면 후속 issue로 분리.
- plugin manifest 등록은 dotclaude plugin 컨벤션에 따름. 자동 인식이면 불필요.
- 통합 시나리오 A, B, C는 사용자 상호작용 (AskUserQuestion 등)을 포함하므로 수동 클릭 검증 필요.
- code-validator가 본 phase의 PLAN과 TEST를 함께 읽어 통합 검증을 수행할 수 있도록 구성됨.

### Validation Result (2026-04-30)

- **정적 일관성 검증**: 모든 항목 PASS
  - Task 5.1 (라우팅 분기 정합성): PASS
  - Task 5.2 (pre_filled YAML 스키마, 3 work_types): PASS
  - Task 5.3 (FR/NFR Traceability, FR-1~9 + NFR-1~2): PASS (FR-7 Deferred 명시)
  - Task 5.4 (plugin manifest): Case B 채택 — 자동 스캔 컨벤션 확인, 등록 불필요. 코드 변경 없음
  - Task 5.6 (회귀): init-feature/bugfix/refactor.md, init-github-issue.md, _init-common.md 모두 unchanged 확인
  - Task 5.7 (inter-link): 모든 reference 정확
- **런타임 시나리오 검증 인계**: Manual Test Scenarios A/B/C 및 Task 5.5 통합 시나리오 4종은 사용자 상호작용(AskUserQuestion 등)을 포함하므로 PR 머지 후 사용자 직접 수행으로 인계
- **불일치 0건**: 후속 issue 등록 불필요
