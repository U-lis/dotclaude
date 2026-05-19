# PHASE 3 TEST

## Test Status

- **Status**: Passed (document checks)
- **Last Run**: 2026-04-30 (code-validator)
- **Result**: All static document checks passed. Manual scenarios (Scenario 2/3 + edge variants) require interactive CLI execution and remain to be exercised by the user post-merge.

---

## Test Items

### Step 2.5 Content Checks

- [x] init-prefill.md Step 2.5의 `TBD: Phase 3` 마커가 제거되었다 (commands/init-prefill.md:56-181 grep 결과 부재)
- [x] URL regex `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`가 명시되어 있다 (commands/init-prefill.md:62-64)
- [x] 정규식이 SPEC.md FR-9 line 50과 동일하다 (도입부 명시: "identical across start-new.md Step 0, this step, and SPEC.md FR-9")
- [x] 정규식이 start-new.md Step 0의 GitHub URL 감지 정규식과 동일하다 (commands/start-new.md:71과 일치)

### Scenario A & B Branches

- [x] Scenario A (Positional URL Argument) 섹션이 존재한다 (commands/init-prefill.md:73)
- [x] Scenario A 분기 조건: `url_reference` non-null (commands/init-prefill.md:75)
- [x] Scenario B (URL Embedded in Prefill Body) 섹션이 존재한다 (commands/init-prefill.md:81)
- [x] Scenario B 분기 조건: `url_reference` null AND prefill_body에 URL 정규식 매칭 (commands/init-prefill.md:83-85)
- [x] Multiple matches 처리: 첫 번째 매칭 사용 + additional URL 보존 (commands/init-prefill.md:88)

### URL Fetch

- [x] gh issue view / gh pr view 분기가 명시되어 있다 (commands/init-prefill.md:97-103)
- [x] `--repo {owner}/{repo}` 인자 사용이 명시되어 있다 (commands/init-prefill.md:99, 102, 105)
- [x] `--json title,body,labels,milestone` 출력 포맷이 init-github-issue.md Step 2와 일치 (commands/init-prefill.md:99, 102)
- [x] fetch 결과가 `url_fetch_result`에 저장된다 (commands/init-prefill.md:106)

### Fetch Failure Handling

- [x] Fetch 실패 시 사용자 알림 메시지가 명시되어 있다 (commands/init-prefill.md:114-117)
- [x] 1회 시도, 즉시 폴백 정책이 명시되어 있다 (commands/init-prefill.md:126, AD-6)
- [x] `url_fetch_result = null`, `url_resolution = "fallback_no_fetch"` 설정이 명시되어 있다 (commands/init-prefill.md:120-121)
- [x] AskUserQuestion 단계 skip이 명시되어 있다 (commands/init-prefill.md:123)
- [x] URL이 plain reference로 SPEC.md에 보존됨이 명시되어 있다 (commands/init-prefill.md:122)
- [x] 재시도 정책 정교화는 후속 이슈로 분리됨이 명시되어 있다 (commands/init-prefill.md:126 last clause)

### AskUserQuestion 4-Options

- [x] AskUserQuestion 호출이 명시되어 있다 (commands/init-prefill.md:130)
- [x] question, header 필드가 명확하다 (commands/init-prefill.md:133-134)
- [x] 4개 options 모두 존재한다:
  - [x] "Merge (recommended)" (commands/init-prefill.md:136)
  - [x] "URL Override" (commands/init-prefill.md:138)
  - [x] "URL Ignore" (commands/init-prefill.md:140)
  - [x] "Cancel" (commands/init-prefill.md:142)
- [x] Default가 "Merge (recommended)"로 명시되어 있다 (commands/init-prefill.md:147, AD-4)
- [x] multiSelect: false 명시 (commands/init-prefill.md:144)

### Option Handling Table

- [x] 4개 `url_resolution` 값에 대한 처리 표가 존재한다 (commands/init-prefill.md:153-158):
  - [x] `merge_prefill_priority` (prefill 우선)
  - [x] `merge_url_priority` (URL 우선)
  - [x] `ignore_url`
  - [x] `cancel_prefill`
- [x] Merge 옵션 시 init-github-issue.md Step 4 (Deep Body Analysis)를 url_fetch_result.body에 적용함이 명시되어 있다 (commands/init-prefill.md:155)
- [x] Cancel 옵션 시 start-new.md Step 1로 폴백함이 명시되어 있다 (commands/init-prefill.md:158)

### SPEC.md Header Update Guide

- [x] `url_resolution` 5가지 케이스에 대한 SPEC.md 헤더 표기 가이드가 존재한다 (commands/init-prefill.md:386-393):
  - [x] (no URL): `**Source Conversation**: prefill`
  - [x] `merge_prefill_priority`: + `**Source Issue**: {url}`
  - [x] `merge_url_priority`: + `**Source Issue**: {url}`
  - [x] `ignore_url`: + `**Source Issue**: {url} (reference only)`
  - [x] `fallback_no_fetch`: + `**Source Issue**: {url} (fetch failed)`

### start-new.md Step 0 Update

- [x] "URL + --prefill 동시" row description이 정밀화되었다 (commands/start-new.md:80)
- [x] init-prefill 위임 + url_reference 전달이 명시되어 있다 (commands/start-new.md:80, "Forward the URL as the `url_reference` context variable")
- [x] 다른 3-row (URL only, --prefill only, neither)는 unchanged (git diff 검증: row 1, 2, 4 변경 없음)

### Edge Cases

- [x] Edge case 노트 섹션이 존재한다 (commands/init-prefill.md:173-179)
- [x] Multiple URLs 처리 명시 (commands/init-prefill.md:175)
- [x] URL in code block / quoted text 명시 (commands/init-prefill.md:176)
- [x] /pull/ vs /pulls/ 명시 (commands/init-prefill.md:177)
- [x] Cross-repo URL 명시 (commands/init-prefill.md:178)
- [x] Private repo (403/404) 폴백 명시 (bonus, commands/init-prefill.md:179)

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

- [x] Phase 1 Scenario 1.1 (빈 인자) 여전히 동작 (start-new.md Step 0 row 4 "neither" unchanged: commands/start-new.md:81)
- [x] Phase 1 Scenario 1.2 (URL only) 여전히 동작 (start-new.md Step 0 row 1 unchanged: commands/start-new.md:78)
- [x] Phase 2 Scenario 1 (--prefill only feature) 여전히 동작 (Step 2.5 Scenario B "no match" 분기로 url_resolution=null 후 Step 3 진행: commands/init-prefill.md:86)
- [x] Phase 2 Scenario 1-Edge (빈 prefill) 여전히 동작 (Step 1 empty fallback 변경 없음: commands/init-prefill.md:32-35)
- [x] Phase 2 Scenario 1-Bugfix, 1-Refactor, 1-Ambiguous 여전히 동작 (Step 3-5 본문 변경 없음, Step 5 YAML에 url_resolution 필드만 추가)

### init-github-issue.md Compatibility

- [x] init-prefill.md Step 2.5에서 init-github-issue.md Step 4 (Deep Body Analysis)를 reuse하는 호출이 init-github-issue.md를 변경하지 않는다 (git diff stat: init-github-issue.md = 0 changes)
- [x] gh CLI 호출 형식이 init-github-issue.md Step 2와 일치 (--json title,body,labels,milestone 동일: commands/init-prefill.md:99, 102)

---

## Notes / Observations

- AskUserQuestion 분기는 사용자 상호작용이므로 자동화 어려움. 수동 시나리오 4개 sub-scenario를 모두 검증할 것.
- gh CLI 인증 상태는 환경 의존적. 가능하면 인증/미인증 두 환경에서 검증.
- Scenario 3-Edge "Multiple URLs"의 동작은 v0.5.0에서 보수적으로 처리 (첫 번째 사용). 추후 사용자 선택 UI 추가 검토.
- Edge Case "URL in code block"은 정규식 그대로 매칭. v0.5.0에서는 의도적 미세조정 보류.
