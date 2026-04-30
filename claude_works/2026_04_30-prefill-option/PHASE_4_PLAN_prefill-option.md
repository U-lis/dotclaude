# PHASE 4: NFR-1 민감정보 필터링 규칙

## Phase Metadata

- **Status**: Pending
- **Type**: sequential
- **Dependencies**: 2
- **Effort**: medium

---

## Objective

`commands/_prefill-filters.md`를 신규 작성하여 prefill 본문에서 추출 단계 이전에 마스킹할 민감정보 정규식 패턴을 명세한다 (NFR-1). 그리고 Phase 2에서 placeholder로 작성한 `init-prefill.md` Step 2 (Sensitive Data Filtering)를 실제 reference 호출로 변환한다.

`_init-common.md`처럼 underscore-prefixed internal reference 파일 컨벤션을 따른다 (AD-5).

---

## Files to Create

| Path | Purpose |
|------|---------|
| `commands/_prefill-filters.md` | 민감정보 필터링 정규식 패턴 명세 (internal reference, `user-invocable: false`) |

## Files to Modify

| Path | Change |
|------|--------|
| `commands/init-prefill.md` | Step 2 placeholder를 `_prefill-filters.md` reference로 변환 |

---

## Detailed Tasks

### Task 4.1: `_prefill-filters.md` frontmatter 작성

`commands/_prefill-filters.md` 파일 최상단에 frontmatter:

```markdown
---
description: Sensitive data filtering rules for prefill content. Internal reference used by init-prefill.md.
user-invocable: false
---
# _prefill-filters Reference

Regex-based sensitive data filtering patterns applied to prefill content before any extraction (NFR-1).

This file is an internal reference, not a user-invocable command. It is referenced from `commands/init-prefill.md` Step 2 (Sensitive Data Filtering).
```

- [ ] frontmatter 컨벤션은 `_init-common.md`와 일치
- [ ] `user-invocable: false`로 마크

### Task 4.2: 7-row 정규식 패턴 표 작성

`_prefill-filters.md`에 다음 표 작성:

```markdown
## Filter Patterns

The following regex patterns are applied to the prefill body. Matches are replaced with `[REDACTED]` (or category-specific marker as noted).

| # | Category | Pattern (regex) | Replacement | Notes |
|---|----------|-----------------|-------------|-------|
| 1 | API Key (sk- prefix) | `\bsk-[A-Za-z0-9_\-]{20,}\b` | `[REDACTED:API_KEY]` | Matches OpenAI / Anthropic / Stripe-style keys with `sk-` prefix and 20+ alphanumeric chars |
| 2 | Bearer Token | `\bBearer\s+[A-Za-z0-9\-_\.=]+\b` | `Bearer [REDACTED]` | Authorization header pattern. Preserve `Bearer` prefix for context. |
| 3 | JWT Token | `\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\b` | `[REDACTED:JWT]` | Three base64url segments separated by `.`, starting with `eyJ` (JSON header `{"alg`...) |
| 4 | Password Assignment | `(?i)\b(password\|passwd\|pwd)\s*[=:]\s*\S+` | `\1=[REDACTED]` | Case-insensitive. Captures `password=`, `passwd:`, `pwd =`, etc. Replacement preserves the key name. |
| 5 | Credit Card Number | `\b(?:\d{4}[- ]?){3}\d{4}\b` | `[REDACTED:CC]` | 16-digit numbers in 4-4-4-4 grouping with optional `-` or space separators |
| 6 | Email Address | `\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b` | `[REDACTED:EMAIL]` | Standard RFC-ish email pattern. False-positive prone — see notes below. |
| 7 | Phone Number (KR) | `\b(?:\+?82[- ]?)?0?1[0-9][- ]?\d{3,4}[- ]?\d{4}\b` | `[REDACTED:PHONE]` | Korean mobile number formats with optional `+82` country code |
```

- [ ] 7개 카테고리 모두 포함 (SPEC.md NFR-1 line 65에 나열된 항목 + 추가)
- [ ] 각 row의 정규식이 정확하고 escape가 올바름
- [ ] Replacement 가이드가 명확

### Task 4.3: 적용 순서 명시 (긴 패턴 우선)

`_prefill-filters.md`에 적용 순서 섹션:

```markdown
## Application Order

Patterns are applied in the following order. Order matters because earlier matches consume substring boundaries that later patterns might re-match.

1. **JWT Token** (#3) — most specific (3-segment structure with `eyJ` prefix)
2. **Bearer Token** (#2) — preserves `Bearer` prefix; runs before generic JWT to avoid double-replacement
3. **API Key (sk-)** (#1) — specific prefix
4. **Password Assignment** (#4) — captures key=value; runs before generic email/phone
5. **Credit Card Number** (#5) — strict 16-digit pattern
6. **Email Address** (#6) — generic pattern
7. **Phone Number (KR)** (#7) — generic pattern

Rationale: Specific (longer / structurally unique) patterns are matched first to avoid false positives from generic patterns. For example, a JWT token contains `.`-separated segments that could partially match a generic password regex if applied later.
```

- [ ] 적용 순서 7-step 명시
- [ ] 순서 결정 근거 (긴 패턴 우선) 명시

### Task 4.4: False Positive 노트 섹션 작성

`_prefill-filters.md`에 false-positive 노트 섹션:

```markdown
## False Positive Notes

The patterns above are intentionally conservative — they prioritize coverage over precision. Known false-positive cases:

- **Email pattern (#6)**: Matches strings like `dev@local` (missing TLD) — actually requires `\.[A-Za-z]{2,}` so `dev@local` is NOT matched. However, `john.doe@company.local` IS matched (valid TLD-like). Acceptable since `local` could legitimately leak internal info.
- **Phone pattern (#7)**: Matches sequences like `010-1234-5678` even in non-phone contexts (e.g., a URL path or numeric ID). Acceptable for v0.5.0 — refinement deferred.
- **API Key (#1)**: Strictly requires `sk-` prefix and 20+ alphanumeric chars. Will NOT match shorter keys (e.g., `sk-abc123`) or differently-prefixed keys (e.g., `pk-...`, `xoxb-...`). Future iterations may add more prefixes.
- **Password Assignment (#4)**: Matches `password = "literal"` AND `password = variable`. The literal-vs-reference distinction is not made. The captured value (whether literal or reference) is replaced with `[REDACTED]`.

**User responsibility**: Since the user authored the `--prefill` body themselves, they retain primary responsibility for not including secrets. The filter is a safety net, not a primary defense.

**Final validation gate**: SPEC.md review (start-new.md Step 3) is the final user-facing checkpoint. Users review the SPEC.md before commit and can verify that no leaked secrets remain.
```

- [ ] 4개 카테고리에 대한 false positive 케이스 명시
- [ ] 사용자 책임 + SPEC.md 검토 게이트 명시

### Task 4.5: Filtering Invocation Guide 작성

`_prefill-filters.md`에 호출 가이드 섹션:

```markdown
## Invocation from init-prefill.md

`commands/init-prefill.md` Step 2 invokes this filter set in the following manner:

1. Read `prefill_body` (received from Step 1).
2. Apply all 7 patterns in the order specified above. After each pattern, the body is mutated in-place.
3. Store the filtered result as `filtered_prefill_body`. This value is used by Step 2.5 (URL detection), Step 3 (work type detection), Step 4 (context extraction), and Step 5 (route).
4. If any redaction occurred, append a notice to the SPEC.md "Notes" section (downstream init-xxx) listing the categories that were redacted (counts only, not the masked content).

The original unfiltered body is NOT preserved anywhere in working documents or git commits.
```

- [ ] 4-step 호출 흐름 명시
- [ ] 원본 본문 미보존 명시 (보안)

### Task 4.6: init-prefill.md Step 2 placeholder → 실제 reference로 변환

Phase 2에서 작성한 init-prefill.md Step 2의 `TBD: Phase 4` placeholder를 다음 내용으로 치환:

```markdown
### Step 2: Sensitive Data Filtering

Apply the regex pattern set defined in `commands/_prefill-filters.md` to `prefill_body` before any extraction (per NFR-1).

**Procedure**:
1. Reference `commands/_prefill-filters.md` for the pattern table and application order.
2. Apply each pattern in order. Replace matches with the category-specific marker (e.g., `[REDACTED:API_KEY]`).
3. Store the result as `filtered_prefill_body`.
4. From this point onward, all downstream steps (Step 2.5, Step 3, Step 4, Step 5) operate on `filtered_prefill_body`, NOT `prefill_body`.

**Redaction Notice**:
If any pattern matched (i.e., redaction occurred), record the categories and counts. Pass this metadata to the downstream init-xxx so that the SPEC.md "Notes" section can include a brief disclosure (e.g., "Note: 2 email addresses, 1 API key were redacted from prefill content"). The original (unfiltered) body is NOT preserved in working documents or git commits.

**No-redaction case**:
If no pattern matched, `filtered_prefill_body == prefill_body`. No notice is added.
```

- [ ] `TBD: Phase 4` 마커 제거
- [ ] `_prefill-filters.md` reference 명시
- [ ] `filtered_prefill_body` 변수 명명 일관
- [ ] Redaction notice 메타데이터 흐름 명시
- [ ] 원본 본문 미보존 명시

### Task 4.7: 다운스트림 step의 변수 참조 갱신

- [ ] init-prefill.md Step 2.5, Step 3, Step 4, Step 5 본문에서 `prefill_body` 참조를 `filtered_prefill_body`로 변경
- [ ] Step 5 YAML 페이로드의 `conversation.body` 값도 `{filtered_prefill_body}`로 명시 (Phase 2에서 이미 그렇게 작성됨, 검증)

### Task 4.8: SPEC.md Notes 섹션 가이드 작성

- [ ] init-prefill.md Step 5 본문에 redaction 발생 시 SPEC.md Notes 섹션 표기 가이드 추가:

```markdown
**Redaction Disclosure (per NFR-1)**:

If Step 2 redacted any content, the downstream init-xxx must include a "Notes" subsection in SPEC.md disclosing the categories and counts:

```markdown
## Notes

The prefill content was filtered for sensitive data before extraction:
- API keys: 1 redaction
- Email addresses: 2 redactions
- (etc.)

The original unfiltered content is not preserved.
```

If no redaction occurred, this subsection is OMITTED.
```

---

## Implementation Notes

### Reference: AD-5
> NFR-1 민감정보 필터링 정규식 패턴은 신규 `commands/_prefill-filters.md`에 별도로 명세하고, `init-prefill.md` Step 2에서 reference한다. `_init-common.md`처럼 underscore-prefixed internal reference 파일 컨벤션을 따른다.

### 정규식 검증
각 정규식은 다음 테스트 케이스로 수동 검증:

| Pattern | Positive case | Negative case |
|---------|---------------|---------------|
| API Key | `sk-abc123def456ghi789jkl012` | `sk-short`, `pk-...` |
| Bearer | `Authorization: Bearer eyJabc.def.ghi` | `not-a-token` |
| JWT | `eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwR...` | `eyJ.` (incomplete) |
| Password | `password=secret123`, `pwd: mypass` | `the password is...` (no `=` or `:` next to `password`) |
| CC | `4111-1111-1111-1111`, `4111 1111 1111 1111` | `12345-67890` (not 16) |
| Email | `john@example.com` | `notanemail`, `@nodomain` |
| Phone (KR) | `010-1234-5678`, `+82-10-1234-5678` | `1-2-3-4-5` |

### 우선순위 결정 근거
- JWT는 `eyJ`로 시작하는 매우 specific한 구조 → 1번
- Bearer는 prefix가 있어 매칭이 길어짐 → 2번
- sk- API key는 specific prefix → 3번
- Password assignment는 key=value 구조 → 4번
- Credit card는 4-4-4-4 strict → 5번
- Email은 generic → 6번
- Phone은 generic → 7번

### 참조 파일/라인
- `commands/_init-common.md` — underscore-prefixed internal reference 컨벤션 reference
- `commands/init-prefill.md` Step 2 placeholder (Phase 2 산출물)
- SPEC.md NFR-1 line 64-66 (필터링 명세)

---

## Completion Checklist

- [ ] `commands/_prefill-filters.md` 파일이 존재한다
- [ ] frontmatter (`description`, `user-invocable: false`)가 정확하다
- [ ] 7-row 정규식 패턴 표가 모든 카테고리를 커버한다 (API key, Bearer, JWT, Password, CC, Email, Phone-KR)
- [ ] Application Order 섹션이 7-step 순서를 명시한다
- [ ] False Positive Notes 섹션이 4개 카테고리에 대한 케이스를 명시한다
- [ ] Invocation Guide 섹션이 init-prefill.md에서의 호출 흐름을 명시한다
- [ ] init-prefill.md Step 2의 `TBD: Phase 4` 마커가 제거되었다
- [ ] init-prefill.md Step 2가 `_prefill-filters.md`를 reference한다
- [ ] init-prefill.md 다운스트림 step (2.5, 3, 4, 5)에서 `filtered_prefill_body` 변수를 사용한다
- [ ] SPEC.md Notes 섹션 redaction disclosure 가이드가 init-prefill.md Step 5에 포함된다
- [ ] 원본 본문 미보존 (no-preservation) 명시가 두 곳 (`_prefill-filters.md`, `init-prefill.md` Step 2)에 모두 존재한다

---

## Acceptance Criteria

1. **AC-1**: Scenario 4 수동 검증 통과 — `--prefill` 본문에 API key, 이메일 등 포함 시 추출 전 필터링이 적용되고 `[REDACTED:*]` 마커가 본문에 반영된다.
2. **AC-2**: 필터링이 SPEC.md 작성 단계 이전에 적용되어 SPEC.md에 민감정보가 그대로 노출되지 않는다.
3. **AC-3**: Redaction 발생 시 SPEC.md "Notes" 섹션에 카테고리와 카운트가 disclosure된다.
4. **AC-4**: 7개 정규식이 자체 테스트 케이스 (Implementation Notes의 표)에서 positive/negative 모두 정확히 동작한다.
5. **AC-5**: `_prefill-filters.md`가 `_init-common.md`와 동일한 internal reference 컨벤션을 따른다 (`user-invocable: false`, underscore-prefixed name).
