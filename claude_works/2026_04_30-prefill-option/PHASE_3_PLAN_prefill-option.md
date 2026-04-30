# PHASE 3: FR-9 GitHub URL Detection & Resolution flow

## Phase Metadata

- **Status**: Pending
- **Type**: sequential
- **Dependencies**: 2
- **Effort**: medium

---

## Objective

Phase 2에서 placeholder로 작성한 `init-prefill.md`의 "Step 2.5: GitHub URL Detection & Resolution" 섹션을 실제 동작 사양으로 채운다. SPEC.md FR-9 (Scenario A: 명시적 동시 사용 / Scenario B: 본문 내 URL 정규식 매칭)를 모두 커버하며, AD-4 결정에 따라 default 옵션은 "병합(Merge), prefill 우선"으로 설정한다.

또한 `start-new.md` Step 0 분기 표의 "URL + --prefill 동시" row description을 "init-prefill로 위임 (Step 2.5에서 4-옵션 처리)"로 정밀화한다.

---

## Files to Create

(없음)

## Files to Modify

| Path | Change |
|------|--------|
| `commands/init-prefill.md` | Step 2.5 placeholder를 실제 동작 사양으로 교체 |
| `commands/start-new.md` | Step 0 분기 표 "URL + --prefill 동시" row description 정밀화 |

---

## Detailed Tasks

### Task 3.1: URL 정규식 명시

- [ ] init-prefill.md Step 2.5 섹션 도입부에 정규식 명시:
  ```
  GitHub Issue/PR URL regex: `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`
  ```
- [ ] SPEC.md FR-9 line 50과 동일한 정규식 사용 (정합성)
- [ ] Phase 1에서 `start-new.md` Step 0가 사용한 정규식과도 동일

### Task 3.2: Scenario A - Positional URL Argument 분기 작성

- [ ] init-prefill.md Step 2.5에 Scenario A 처리 작성:

```markdown
**Scenario A: Positional URL Argument**

If `url_reference` is non-null (passed from `start-new.md` Step 0 when both URL and --prefill were provided):
1. Skip the regex scan (Scenario B). Proceed directly to URL fetch (Task 3.4).
2. The URL is treated as the primary external context source for resolution.
```

### Task 3.3: Scenario B - URL Embedded in Prefill Body 분기 작성

- [ ] init-prefill.md Step 2.5에 Scenario B 처리 작성:

```markdown
**Scenario B: URL Embedded in Prefill Body**

If `url_reference` is null:
1. Scan `prefill_body` (after Step 2 filtering) for the URL regex.
2. If a match is found, set `url_reference = <matched URL>`. Proceed to URL fetch (Task 3.4).
3. If no match, skip Step 2.5 entirely and proceed to Step 3.
4. If multiple matches are found, use the first match. Note the additional matches as "additional_url_references" (preserved as plain links in the body, not fetched).
```

### Task 3.4: URL Fetch 작성 (init-github-issue.md Step 2 패턴 reference)

- [ ] init-prefill.md Step 2.5에 fetch 동작 작성:

```markdown
**URL Fetch**:

Use `gh` CLI to fetch URL content (same pattern as `init-github-issue.md` Step 2, line 42-49):

```bash
# Detect URL type from regex group: "issues" or "pull"
# Extract owner, repo, number from regex captures.

# For issues:
gh issue view {number} --repo {owner}/{repo} --json title,body,labels,milestone

# For pull requests:
gh pr view {number} --repo {owner}/{repo} --json title,body,labels,milestone
```

Store the JSON result as `url_fetch_result`.
```

### Task 3.5: Fetch 실패 처리 작성 (AD-6 준수)

- [ ] init-prefill.md Step 2.5에 fetch 실패 처리 작성:

```markdown
**Fetch Failure Handling** (per SPEC.md FR-9 last clause and AD-6):

If the `gh` CLI fetch fails (any reason: not installed, not authenticated, 404, 403, network error):
1. Notify the user: "GitHub URL fetch failed: {error_summary}. Proceeding with prefill content only; the URL is preserved as a plain reference in SPEC.md."
2. Set `url_fetch_result = null`.
3. Skip the AskUserQuestion step (Task 3.6) entirely.
4. Set `url_resolution = "fallback_no_fetch"` (URL preserved in `conversation.url_reference` for SPEC.md header, but no merge of URL-extracted fields).
5. Proceed to Step 3.

**Retry Policy**: Single attempt, immediate fallback on failure (per AD-6). Retry policy refinement is deferred to a follow-up issue.
```

### Task 3.6: AskUserQuestion 4-옵션 작성 (AD-4 default = Merge)

- [ ] init-prefill.md Step 2.5에 사용자 옵션 제시 작성:

```markdown
**User Resolution Choice**:

If `url_fetch_result` is non-null, ask the user how to combine the URL-derived context with the prefill body using AskUserQuestion:

- question: "GitHub URL detected ({url_reference}). How should it be combined with the prefill content?"
- header: "URL Resolution"
- options:
  - { label: "Merge (recommended)", description: "Combine URL extraction with prefill. On key conflict, prefill wins." }
  - { label: "URL Override", description: "Use URL extraction; on key conflict, URL wins (overrides prefill)." }
  - { label: "URL Ignore", description: "Use prefill only; preserve URL as a plain reference link in SPEC.md." }
  - { label: "Cancel", description: "Discard prefill entirely and fall back to the normal init flow." }
- multiSelect: false

**Default**: "Merge (recommended)" (per AD-4 — same as the SPEC.md FR-9 default).
```

### Task 3.7: 옵션별 후속 처리 의사코드 작성

- [ ] init-prefill.md Step 2.5에 옵션별 처리 작성:

```markdown
**Option Handling**:

| User Selection | `url_resolution` | Behavior |
|----------------|------------------|----------|
| Merge (recommended) | `merge_prefill_priority` | Run `init-github-issue.md` Step 4 (Context Extraction) on `url_fetch_result.body` to produce `url_pre_filled`. Merge into the prefill-derived `pre_filled` (Step 4 output) with **prefill keys taking priority on conflict**. |
| URL Override | `merge_url_priority` | Same as above, but **URL keys take priority on conflict**. |
| URL Ignore | `ignore_url` | Discard `url_fetch_result`. Preserve `url_reference` as a plain link in `conversation.url_reference` for SPEC.md header. |
| Cancel | `cancel_prefill` | Halt init-prefill. Fall back to `start-new.md` Step 1 (Work Type Selection). |

After the option is applied, set `url_resolution` and proceed to Step 3 (Work Type Detection) with the resolved context. Note: when `url_resolution` is `merge_*`, Step 3 keyword analysis runs on `prefill_body + url_fetch_result.body` concatenated for higher accuracy.
```

### Task 3.8: SPEC.md 헤더 표기 가이드 갱신

- [ ] init-prefill.md Step 5 본문에 URL 처리 결과별 SPEC.md 헤더 표기 가이드 갱신:

```markdown
**SPEC.md Header (per FR-6 and FR-9)**:

The downstream init-xxx writes the SPEC.md header. Include the following based on `url_resolution`:

| `url_resolution` | SPEC.md Header Lines |
|------------------|----------------------|
| (no URL) | `**Source Conversation**: prefill` |
| `merge_prefill_priority` / `merge_url_priority` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference}` |
| `ignore_url` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference} (reference only)` |
| `fallback_no_fetch` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference} (fetch failed)` |
| `cancel_prefill` | (init-prefill halted; this case does not reach Step 5) |
```

### Task 3.9: start-new.md Step 0 분기 표 description 정밀화

- [ ] Phase 1에서 작성한 4-row 분기 매트릭스 표의 "URL + --prefill 동시" row를 다음과 같이 정밀화:

| ARGUMENTS Form | Detection Rule | Action |
|----------------|----------------|--------|
| URL + `--prefill` 동시 | 위치 인자에 URL 정규식 매칭 AND `--prefill` 플래그 존재 | `Skill("dotclaude:init-prefill")` 호출 (URL을 `url_reference` 컨텍스트 변수로 함께 전달). FR-9 Scenario A는 init-prefill.md Step 2.5에서 처리하며, 사용자에게 4-옵션(병합/URL 우선/URL 무시/취소)을 제시한다. |

- [ ] 다른 3-row는 unchanged

### Task 3.10: Edge Case 보강

- [ ] init-prefill.md Step 2.5 끝부분에 edge case 노트 추가:

```markdown
**Edge Cases**:

- **Multiple URLs in body**: Use the first match. Additional URLs are preserved in body text as plain links (no fetch).
- **URL in code block / quoted text**: The regex still matches inside code blocks. This is acceptable for v0.5.0 — refinement is deferred.
- **Pull request URL with `/pull/` instead of `/pulls/`**: The regex `(issues|pull)` correctly matches `/pull/`. `gh pr view` is invoked.
- **URL is in a different repo than the current worktree**: The URL fetch uses `--repo {owner}/{repo}` from the URL itself (not the current repo context). This matches `init-github-issue.md` Step 2 line 44.
```

---

## Implementation Notes

### Reference: AD-3, AD-4, AD-6
- AD-3: FR-9 처리는 `init-prefill.md` 내부 Step 2.5에서 일관되게 처리
- AD-4: default 옵션 = "병합(Merge), prefill 우선"
- AD-6: URL fetch 실패 시 1회 시도 후 즉시 폴백. 재시도 정책 정교화는 후속 이슈

### Reference 모델: init-github-issue.md
- Step 2 (line 42-62): URL fetch + 에러 처리 패턴
- Step 4 (line 106-168): Context extraction (URL 본문 분석에도 동일 적용)

### URL extraction 재사용
- AskUserQuestion에서 "Merge" 또는 "URL Override"가 선택되면, `url_fetch_result.body`에 대해 `init-github-issue.md` Step 4의 Deep Body Analysis (line 129-168)를 그대로 호출하여 `url_pre_filled`를 산출
- 그 후 prefill_body로부터 산출한 `pre_filled`와 병합. 병합 우선순위는 `url_resolution`에 따름

### 병합 알고리즘 (의사코드)
```
def merge_prefilled(prefill_pre_filled, url_pre_filled, url_resolution):
    result = {}
    all_keys = set(prefill_pre_filled.keys()) | set(url_pre_filled.keys())
    for key in all_keys:
        if url_resolution == "merge_prefill_priority":
            result[key] = prefill_pre_filled.get(key) or url_pre_filled.get(key)
        elif url_resolution == "merge_url_priority":
            result[key] = url_pre_filled.get(key) or prefill_pre_filled.get(key)
    # Drop None / empty values
    return {k: v for k, v in result.items() if v}
```

본 의사코드는 init-prefill.md 본문에 명시할 필요는 없으나, 본 PLAN의 implementation note로 보존하여 작성자가 참조할 수 있도록 한다.

### 참조 파일/라인
- `commands/init-prefill.md` Step 2.5 placeholder (Phase 2 산출물)
- `commands/init-github-issue.md` line 42-62 (URL fetch 패턴)
- `commands/init-github-issue.md` line 106-168 (Context extraction)
- `commands/start-new.md` Step 0 (Phase 1 산출물)
- SPEC.md line 47-56 (FR-9 명세)
- SPEC.md line 117-119 (Conflict #2)
- SPEC.md line 128, 132 (Edge Case #5, #9)

---

## Completion Checklist

- [ ] init-prefill.md Step 2.5의 `TBD: Phase 3` 마커가 제거되었다
- [ ] URL regex `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`가 명시되어 있다
- [ ] Scenario A (positional URL arg) 분기가 작성되어 있다
- [ ] Scenario B (URL in body) 분기가 작성되어 있다
- [ ] gh CLI fetch 호출 패턴이 init-github-issue.md Step 2 line 42-49와 일치한다 (issues / pull 분기 포함)
- [ ] Fetch 실패 처리가 명시되어 있다 (1회 시도, 즉시 폴백, 사용자 알림)
- [ ] AskUserQuestion이 4-옵션을 제공한다 (Merge / URL Override / URL Ignore / Cancel)
- [ ] Default 옵션이 "Merge (recommended)"로 명시되어 있다 (AD-4)
- [ ] 옵션별 후속 처리 (`url_resolution` 값별 동작)가 표로 명시되어 있다
- [ ] SPEC.md 헤더 표기 가이드가 `url_resolution` 5가지 케이스를 모두 커버한다
- [ ] start-new.md Step 0 분기 표 "URL + --prefill 동시" row description이 정밀화되었다
- [ ] Edge case 노트가 포함되어 있다 (multiple URLs, code block, /pull/ vs /pulls/, cross-repo)

---

## Acceptance Criteria

1. **AC-1**: Scenario 2 수동 검증 통과 — `--prefill <text>` + `<github-url>` 입력 시 URL fetch + 4-옵션 제시 + 선택별 동작이 모두 정상.
2. **AC-2**: Scenario 3 수동 검증 통과 — `--prefill "<text containing URL>"` 입력 시 정규식 매칭 + URL fetch + 4-옵션 제시가 정상.
3. **AC-3**: Fetch 실패 시 사용자 알림 + prefill만으로 폴백이 동작 (자동화는 어렵지만 gh CLI 미설치 환경에서 수동 검증).
4. **AC-4**: SPEC.md 헤더의 `**Source Issue**` 표기가 `url_resolution` 값에 따라 정확히 다르게 출력된다.
5. **AC-5**: Phase 4가 본 phase 결과를 변경 없이 받아들일 수 있도록 Step 2.5의 출력 (`url_resolution`, `url_fetch_result`)이 후속 step에 명확히 전달된다.
