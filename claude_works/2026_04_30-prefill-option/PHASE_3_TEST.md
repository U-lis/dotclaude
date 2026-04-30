# PHASE 3 TEST

## Test Status

- **Status**: Pending
- **Last Run**: -
- **Result**: -

---

## Test Items

### Step 2.5 Content Checks

- [ ] init-prefill.md Step 2.5의 `TBD: Phase 3` 마커가 제거되었다
- [ ] URL regex `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`가 명시되어 있다
- [ ] 정규식이 SPEC.md FR-9 line 50과 동일하다
- [ ] 정규식이 start-new.md Step 0의 GitHub URL 감지 정규식과 동일하다 (Phase 1 산출물)

### Scenario A & B Branches

- [ ] Scenario A (Positional URL Argument) 섹션이 존재한다
- [ ] Scenario A 분기 조건: `url_reference` non-null
- [ ] Scenario B (URL Embedded in Prefill Body) 섹션이 존재한다
- [ ] Scenario B 분기 조건: `url_reference` null AND prefill_body에 URL 정규식 매칭
- [ ] Multiple matches 처리: 첫 번째 매칭 사용 + additional URL 보존

### URL Fetch

- [ ] gh issue view / gh pr view 분기가 명시되어 있다
- [ ] `--repo {owner}/{repo}` 인자 사용이 명시되어 있다 (cross-repo URL 처리)
- [ ] `--json title,body,labels,milestone` 출력 포맷이 init-github-issue.md Step 2 line 44, 47과 일치한다
- [ ] fetch 결과가 `url_fetch_result`에 저장된다

### Fetch Failure Handling

- [ ] Fetch 실패 시 사용자 알림 메시지가 명시되어 있다
- [ ] 1회 시도, 즉시 폴백 정책이 명시되어 있다 (AD-6)
- [ ] `url_fetch_result = null`, `url_resolution = "fallback_no_fetch"` 설정이 명시되어 있다
- [ ] AskUserQuestion 단계 skip이 명시되어 있다
- [ ] URL이 plain reference로 SPEC.md에 보존됨이 명시되어 있다
- [ ] 재시도 정책 정교화는 후속 이슈로 분리됨이 명시되어 있다

### AskUserQuestion 4-Options

- [ ] AskUserQuestion 호출이 명시되어 있다
- [ ] question, header 필드가 명확하다
- [ ] 4개 options 모두 존재한다:
  - [ ] "Merge (recommended)"
  - [ ] "URL Override"
  - [ ] "URL Ignore"
  - [ ] "Cancel"
- [ ] Default가 "Merge (recommended)"로 명시되어 있다 (AD-4)
- [ ] multiSelect: false 명시

### Option Handling Table

- [ ] 4개 `url_resolution` 값에 대한 처리 표가 존재한다:
  - [ ] `merge_prefill_priority` (prefill 우선)
  - [ ] `merge_url_priority` (URL 우선)
  - [ ] `ignore_url`
  - [ ] `cancel_prefill`
- [ ] Merge 옵션 시 init-github-issue.md Step 4 (Deep Body Analysis)를 url_fetch_result.body에 적용함이 명시되어 있다
- [ ] Cancel 옵션 시 start-new.md Step 1로 폴백함이 명시되어 있다

### SPEC.md Header Update Guide

- [ ] `url_resolution` 5가지 케이스에 대한 SPEC.md 헤더 표기 가이드가 존재한다:
  - [ ] (no URL): `**Source Conversation**: prefill`
  - [ ] `merge_prefill_priority`: + `**Source Issue**: {url}`
  - [ ] `merge_url_priority`: + `**Source Issue**: {url}`
  - [ ] `ignore_url`: + `**Source Issue**: {url} (reference only)`
  - [ ] `fallback_no_fetch`: + `**Source Issue**: {url} (fetch failed)`

### start-new.md Step 0 Update

- [ ] "URL + --prefill 동시" row description이 정밀화되었다
- [ ] init-prefill 위임 + url_reference 전달이 명시되어 있다
- [ ] 다른 3-row (URL only, --prefill only, neither)는 unchanged

### Edge Cases

- [ ] Edge case 노트 섹션이 존재한다
- [ ] Multiple URLs 처리 명시 (첫 번째 사용, 나머지는 plain link)
- [ ] URL in code block / quoted text 명시 (현 정책: 정규식 그대로 매칭)
- [ ] /pull/ vs /pulls/ 명시 (정규식 `(issues|pull)`은 `/pull/` 매칭, gh pr view 호출)
- [ ] Cross-repo URL 명시 (URL의 owner/repo 사용)

---

## Manual Test Scenarios

### Scenario 2: --prefill + GitHub URL (Scenario A — 명시적 동시 사용)

**입력**:
```
/dotclaude:start-new https://github.com/U-lis/dotclaude/issues/13 --prefill "사용자가 작성 권한 요청을 보낼 수 있는 기능이 필요합니다. 이슈에 추가 컨텍스트가 있습니다."
```

**검증 절차**:
1. start-new.md Step 0가 "URL + --prefill 동시" row로 분기
2. init-prefill 호출 시 `url_reference = https://github.com/U-lis/dotclaude/issues/13` 전달
3. init-prefill Step 2.5 Scenario A 분기 동작
4. gh issue view 호출 → `url_fetch_result` 저장
5. AskUserQuestion 4-옵션 제시
6. **Sub-scenario 2.1**: 사용자가 "Merge (recommended)" 선택
   - init-github-issue.md Step 4를 url_fetch_result.body에 적용 → url_pre_filled
   - prefill_body에서 추출한 pre_filled와 병합 (prefill 우선)
   - SPEC.md 헤더에 `**Source Conversation**: prefill` + `**Source Issue**: <url>` 추가
7. **Sub-scenario 2.2**: 사용자가 "URL Override" 선택
   - 동일 병합. URL 우선
8. **Sub-scenario 2.3**: 사용자가 "URL Ignore" 선택
   - URL 무시. SPEC.md에 `**Source Issue**: <url> (reference only)` 추가
9. **Sub-scenario 2.4**: 사용자가 "Cancel" 선택
   - init-prefill halt. start-new.md Step 1 (Work Type Selection)으로 폴백

**기대 결과**: 4개 sub-scenario 모두 명시된 동작 수행

### Scenario 3: --prefill 본문에 URL 포함 (Scenario B — 정규식 매칭)

**입력**:
```
/dotclaude:start-new --prefill "이전 이슈 https://github.com/U-lis/dotclaude/issues/13 와 관련하여, prefill 옵션을 추가하는 작업이 필요합니다. 본문 자체는 일반 대화 형태입니다."
```

**검증 절차**:
1. start-new.md Step 0가 "--prefill only" row로 분기 (위치 인자에 URL 없음)
2. init-prefill 호출 시 `url_reference = null` 전달
3. init-prefill Step 2.5 Scenario B 분기 동작
4. prefill_body 정규식 스캔 → 매칭된 URL을 `url_reference`에 저장
5. gh issue view 호출 → `url_fetch_result` 저장
6. AskUserQuestion 4-옵션 제시 → 사용자 선택별 동작 (Scenario 2와 동일)

**기대 결과**: Scenario 2와 동일한 4-옵션 흐름이 본문 매칭 케이스에서도 동작

### Scenario 3-Edge: Fetch 실패 (gh CLI 미인증)

**전제**: 테스트 환경에서 `gh auth logout`으로 인증 해제

**입력**: Scenario 2와 동일

**검증 절차**:
1. gh issue view 호출 → 인증 에러 반환
2. 사용자 알림 출력 ("GitHub URL fetch failed: ...")
3. AskUserQuestion 단계 skip
4. `url_resolution = "fallback_no_fetch"` 설정
5. Step 3 (Work Type Detection)으로 진행 (prefill_body만으로)
6. SPEC.md 헤더에 `**Source Issue**: <url> (fetch failed)` 추가

**기대 결과**: 실패 알림 + prefill 단독 폴백, 무한 대기 없음

### Scenario 3-Edge: Multiple URLs in body

**입력**:
```
/dotclaude:start-new --prefill "https://github.com/U-lis/dotclaude/issues/13 과 https://github.com/U-lis/dotclaude/pull/61 두 항목을 함께 다룹니다."
```

**검증 절차**:
1. Step 2.5 Scenario B 정규식 스캔이 2개 매칭 발견
2. 첫 번째 매칭 (`issues/13`) 사용 → `url_reference`
3. 두 번째 매칭 (`pull/61`)은 plain link로 보존 (fetch 안 함)
4. AskUserQuestion 4-옵션은 첫 번째 URL에 대해서만 제시

**기대 결과**: 첫 번째 URL만 fetch, 추가 URL은 본문에 그대로 보존

### Scenario 3-Edge: Pull request URL

**입력**: `/dotclaude:start-new --prefill "https://github.com/U-lis/dotclaude/pull/61 의 후속 작업..."`

**검증 절차**:
1. 정규식 `(issues|pull)`이 `/pull/` 매칭
2. URL type 감지 → "pull"
3. `gh pr view 61 --repo U-lis/dotclaude --json ...` 호출

**기대 결과**: gh pr view가 정상 호출 (gh issue view 아님)

---

## Regression Checks

### From Phase 1, 2

- [ ] Phase 1 Scenario 1.1 (빈 인자) 여전히 동작
- [ ] Phase 1 Scenario 1.2 (URL only) 여전히 동작 (init-github-issue 라우팅)
- [ ] Phase 2 Scenario 1 (--prefill only feature) 여전히 동작 (URL 없으므로 Step 2.5는 no-op 진행)
- [ ] Phase 2 Scenario 1-Edge (빈 prefill) 여전히 동작
- [ ] Phase 2 Scenario 1-Bugfix, 1-Refactor, 1-Ambiguous 여전히 동작

### init-github-issue.md Compatibility

- [ ] init-prefill.md Step 2.5에서 init-github-issue.md Step 4 (Deep Body Analysis)를 reuse하는 호출이 init-github-issue.md를 변경하지 않는다
- [ ] gh CLI 호출 형식이 init-github-issue.md Step 2와 일치 (--json 출력 키 동일)

---

## Notes / Observations

- AskUserQuestion 분기는 사용자 상호작용이므로 자동화 어려움. 수동 시나리오 4개 sub-scenario를 모두 검증할 것.
- gh CLI 인증 상태는 환경 의존적. 가능하면 인증/미인증 두 환경에서 검증.
- Scenario 3-Edge "Multiple URLs"의 동작은 v0.5.0에서 보수적으로 처리 (첫 번째 사용). 추후 사용자 선택 UI 추가 검토.
- Edge Case "URL in code block"은 정규식 그대로 매칭. v0.5.0에서는 의도적 미세조정 보류.
