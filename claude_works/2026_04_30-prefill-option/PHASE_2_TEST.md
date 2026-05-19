# PHASE 2 TEST

## Test Status

- **Status**: Passed
- **Last Run**: 2026-04-30
- **Result**: All structural checks pass. init-prefill.md created with all required sections; start-new.md Phase 1 placeholder replaced with Delegation Contract; pre_filled YAML keys verified 1:1 against init-feature/bugfix/refactor.md line 22-31; init-feature/bugfix/refactor.md / init-github-issue.md / _init-common.md unchanged (regression clean). Manual scenarios validated by document trace; runtime execution deferred to Phase 5 integration.

---

## Test Items

### File Existence & Structure

- [ ] `commands/init-prefill.md` 파일이 존재한다
- [ ] frontmatter (`---` 블록)이 파일 최상단에 위치한다
- [ ] frontmatter에 `description` 필드와 `user-invocable: false` 필드가 모두 존재한다
- [ ] `# init-prefill Instructions` 헤딩이 frontmatter 직후 위치한다

### Language Section

- [ ] `## Language` 섹션이 존재한다
- [ ] 문구가 `init-github-issue.md` line 9-14와 동일하다 (문자 단위 일치)

### Step 1: Prefill Input Reception

- [ ] `### Step 1: Prefill Input Reception` 섹션이 존재한다
- [ ] 빈 본문 검사 로직이 명시되어 있다 (trimmed result empty → fall back to start-new.md Step 1)
- [ ] `prefill_body` 변수 명명 명확
- [ ] FR-9 Scenario A를 위한 `url_reference` 변수 보존이 명시되어 있다

### Step 2: Sensitive Data Filtering (placeholder)

- [ ] `### Step 2: Sensitive Data Filtering` 섹션이 존재한다
- [ ] `TBD: Phase 4` 마커가 명시되어 있다
- [ ] `commands/_prefill-filters.md`에 대한 reference가 언급되어 있다
- [ ] Phase 2 시점에서는 no-op placeholder임이 명확히 표기되어 있다

### Step 2.5: GitHub URL Detection & Resolution (placeholder)

- [ ] `### Step 2.5: GitHub URL Detection & Resolution` 섹션이 존재한다
- [ ] `TBD: Phase 3` 마커가 명시되어 있다
- [ ] Phase 3에서 채워질 항목 (regex / 2 scenarios / gh fetch / AskUserQuestion 4-options / fallback)이 모두 나열되어 있다
- [ ] Phase 2 시점에서는 no-op placeholder임이 명확히 표기되어 있다

### Step 3: Work Type Detection

- [ ] `### Step 3: Work Type Detection` 섹션이 존재한다
- [ ] Body Analysis Keywords 표가 init-github-issue.md line 80-87과 동일한 키워드 셋이다
- [ ] 모호 시 AskUserQuestion 분기가 init-github-issue.md line 88-97과 동일 패턴이다
- [ ] Work Type Mapping (Add/Modify Feature → feature 등) 3-row가 init-github-issue.md line 99-102와 일치한다

### Step 4: Context Extraction

- [ ] `### Step 4: Context Extraction` 섹션이 존재한다
- [ ] Feature heuristic 표가 8-row이며 각 row의 Pre-filled Key가 다음과 일치:
  - [ ] `goal`, `problem`, `core_features`, `additional_features`, `technical_constraints`, `performance`, `security`, `out_of_scope`
- [ ] Bugfix heuristic 표가 6-row이며 각 row의 Pre-filled Key가 다음과 일치:
  - [ ] `symptoms`, `reproduction_steps`, `expected_cause`, `severity`, `related_files`, `impact_scope`
- [ ] Refactor heuristic 표가 6-row이며 각 row의 Pre-filled Key가 다음과 일치:
  - [ ] `target`, `problems`, `goal_state`, `behavior_change`, `test_status`, `dependencies`
- [ ] Branch Keyword Generation 가이드가 명시되어 있다
- [ ] Target Version: prefill에서는 OMIT임이 명시되어 있다

### Step 5: Route to Init File

- [ ] `### Step 5: Route to Init File` 섹션이 존재한다
- [ ] 라우팅 표가 3-row (feature/bugfix/refactor)이며 init-github-issue.md line 174-180과 일치
- [ ] `github_issue` 블록 대신 `conversation` 블록이 사용된다 (3개 work_type 모두)
- [ ] `conversation` 블록의 키: `source`, `body`, `url_reference`
- [ ] `source: "prefill"` 고정값
- [ ] Feature 페이로드의 `pre_filled` 키가 init-feature.md line 22-31의 표 키와 1:1 일치
- [ ] Bugfix 페이로드의 `pre_filled` 키가 init-bugfix.md line 16-31의 표 키와 1:1 일치
- [ ] Refactor 페이로드의 `pre_filled` 키가 init-refactor.md line 16-31의 표 키와 1:1 일치
- [ ] SPEC.md 헤더 작성 가이드 (`**Source Conversation**: prefill`) 명시
- [ ] URL이 함께 입력되었고 사용자가 "URL Ignore"를 선택하지 않은 경우 `**Source Issue**: {url}` 추가 표기 가이드 명시

### start-new.md Modification

- [ ] Phase 1에서 작성한 init-prefill.md 미존재 placeholder가 제거되었다
- [ ] "--prefill only" row의 Action이 실제 `Skill("dotclaude:init-prefill")` 호출로 치환되었다
- [ ] "URL + --prefill 동시" row의 Action이 init-prefill 위임 + URL 인자 전달 형태로 치환되었다
- [ ] 4-row 분기 매트릭스 자체는 unchanged

---

## Manual Test Scenarios

### Scenario 1: --prefill only with feature-style text (핵심 검증)

**입력**:
```
/dotclaude:start-new --prefill "사용자가 작성 권한이 필요한 작업을 시도할 때, 권한 요청을 보낼 수 있는 기능이 필요합니다. 권한 부여 결과는 사용자에게 알림으로 전달되어야 합니다."
```

**검증 절차**:
1. `start-new.md` Step 0가 "--prefill only" row로 분기 → `Skill("dotclaude:init-prefill")` 호출 확인
2. init-prefill Step 1: prefill_body 수신, 비어있지 않음 확인
3. init-prefill Step 2: placeholder 동작 (no-op, Phase 4까지)
4. init-prefill Step 2.5: placeholder 동작 (no-op, URL 없음, Phase 3까지)
5. init-prefill Step 3: 키워드 "필요합니다", "기능" → feature 감지
6. init-prefill Step 4 Feature 휴리스틱 적용:
   - `goal`: "권한 요청을 보낼 수 있는 기능"
   - `problem`: "사용자가 작성 권한이 필요한 작업을 시도할 때..."
   - `core_features`: 추출 시도. 명시적 bullet이 없으면 omit
7. init-prefill Step 5: init-feature.md로 라우팅. YAML 페이로드 전달
8. init-feature.md line 16-31 pre_filled check가 동작하여 Step 1 (goal), Step 2 (problem)이 자동 스킵

**기대 결과**:
- SPEC.md가 생성되고 헤더에 `**Source Conversation**: prefill` 포함
- 자동 스킵된 step에 대한 사용자 입력 없음

### Scenario 1-Edge: 빈 prefill 본문

**입력**: `/dotclaude:start-new --prefill ""`

**검증 절차**:
1. init-prefill Step 1이 빈 본문을 감지 → 폴백 동작
2. start-new.md Step 1 (Work Type Selection)으로 흐름 전환

**기대 결과**: 일반 init flow로 폴백, 무한 루프나 unhandled error 없음

### Scenario 1-Bugfix: bugfix-style text

**입력**:
```
/dotclaude:start-new --prefill "현재 로그인 시 토큰 갱신이 5분 후에 자동으로 실패하는 버그가 있습니다. 재현: 1) 로그인 → 2) 5분 대기 → 3) 어떤 API 호출이든 시도. 원인은 token expiry 핸들러로 추정됩니다."
```

**검증 절차**:
1. Step 3에서 키워드 "버그", "실패" → bugfix 감지
2. Step 4 Bugfix 휴리스틱:
   - `symptoms`: "로그인 시 토큰 갱신이 5분 후에 자동으로 실패"
   - `reproduction_steps`: "1) 로그인 → 2) 5분 대기 → 3) ..."
   - `expected_cause`: "token expiry 핸들러로 추정"
3. Step 5: init-bugfix.md로 라우팅. YAML 페이로드 전달

**기대 결과**: init-bugfix Step 1, 2, 3이 자동 스킵

### Scenario 1-Refactor: refactor-style text

**입력**:
```
/dotclaude:start-new --prefill "src/auth/AuthManager.ts 모듈을 리팩터링하고 싶습니다. 현재 단일 클래스에 인증/인가/세션 관리가 모두 섞여 있어 SRP 위반입니다. 동작은 변경하지 않고 책임을 분리하는 것이 목표입니다."
```

**검증 절차**:
1. Step 3에서 키워드 "리팩터링", "SRP" → refactor 감지
2. Step 4 Refactor 휴리스틱:
   - `target`: "src/auth/AuthManager.ts"
   - `problems`: "단일 클래스에 인증/인가/세션 관리가 모두 섞여 있어 SRP 위반"
   - `behavior_change`: "동작은 변경하지 않고"
   - `goal_state`: "책임을 분리"
3. Step 5: init-refactor.md로 라우팅. YAML 페이로드 전달

**기대 결과**: init-refactor 해당 step이 자동 스킵

### Scenario 1-Ambiguous: 모호한 work_type

**입력**:
```
/dotclaude:start-new --prefill "auth 모듈을 개선하고 싶습니다."
```

**검증 절차**:
1. Step 3 키워드 분석에서 모호 (single match or no match)
2. AskUserQuestion 호출 → 사용자가 "Add/Modify Feature" 선택
3. Step 4: feature 휴리스틱 적용 (대부분 omit, 사용자 추가 입력 필요)
4. Step 5: init-feature.md로 라우팅

**기대 결과**: AskUserQuestion이 정상적으로 호출되고 사용자 선택 후 흐름 진행

---

## Regression Checks

### From Phase 1

- [ ] Scenario 1.1 (빈 인자 호출) 여전히 동작
- [ ] Scenario 1.2 (URL only 호출) 여전히 동작 (init-github-issue로 라우팅)

### init-feature/bugfix/refactor 무변경 검증

- [ ] init-feature.md line 16-31 pre-fill check 표가 unchanged
- [ ] init-bugfix.md line 16-31 pre-fill check 표가 unchanged
- [ ] init-refactor.md line 16-31 pre-fill check 표가 unchanged
- [ ] 직접 init-feature/bugfix/refactor 호출 (pre_filled 없이) 시 모든 질문이 정상 진행

### _init-common 무변경 검증

- [ ] _init-common.md unchanged
- [ ] branch/worktree 생성 흐름 unchanged

---

## Notes / Observations

- 본 phase의 핵심은 init-github-issue.md를 모델로 한 평행 구조의 정확한 복제와 차이점(conversation 블록, label 검사 제거)의 명확한 적용
- pre_filled YAML 키 집합 정합성 검증은 Phase 5에서도 한 번 더 수행
- Step 2/2.5는 placeholder 상태이므로 본 phase의 수동 시나리오에서는 필터링/URL 처리 없이 진행
