---
description: Sensitive data filtering rules for prefill content. Internal reference used by init-prefill.md.
user-invocable: false
---
# _prefill-filters Reference

Regex-based sensitive data filtering patterns applied to prefill content before any extraction (NFR-1).

This file is an internal reference, not a user-invocable command. It is referenced from `commands/init-prefill.md` Step 2 (Sensitive Data Filtering).

## Overview

`init-prefill.md` Step 2 is the single point of application for these patterns. The patterns target free-form `--prefill` body content authored by the user and run **before** any downstream extraction (URL detection, work-type detection, context extraction). The output, `filtered_prefill_body`, is the only body value consumed by Step 2.5 onward — the unfiltered `prefill_body` is NOT preserved in working documents, SPEC.md, or git commits.

The conventions here mirror `commands/_init-common.md`: an underscore-prefixed internal reference file with `user-invocable: false` (per AD-5).

---

## Filter Patterns

The following regex patterns are applied to the prefill body. Matches are replaced with `[REDACTED]` markers (or the category-specific marker noted in the table).

| # | Category | Pattern (regex) | Replacement | Notes |
|---|----------|-----------------|-------------|-------|
| 1 | API Key (sk- prefix) | `\bsk-[A-Za-z0-9_\-]{20,}\b` | `[REDACTED:API_KEY]` | Matches OpenAI / Anthropic / Stripe-style keys with `sk-` prefix and 20+ alphanumeric chars |
| 2 | Bearer Token | `\bBearer\s+[A-Za-z0-9\-_\.=]+\b` | `Bearer [REDACTED]` | Authorization header pattern. Preserve `Bearer` prefix for context. |
| 3 | JWT Token | `\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\b` | `[REDACTED:JWT]` | Three base64url segments separated by `.`, starting with `eyJ` (JSON header `{"alg`...) |
| 4 | Password Assignment | `(?i)\b(password\|passwd\|pwd)\s*[=:]\s*\S+` | `\1=[REDACTED]` | Case-insensitive. Captures `password=`, `passwd:`, `pwd =`, etc. Replacement preserves the key name. |
| 5 | Credit Card Number | `\b(?:\d{4}[- ]?){3}\d{4}\b` | `[REDACTED:CC]` | 16-digit numbers in 4-4-4-4 grouping with optional `-` or space separators |
| 6 | Email Address | `(?i)\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b` | `[REDACTED:EMAIL]` | Case-insensitive. Standard RFC-ish email pattern. False-positive prone — see notes below. |
| 7 | Phone Number (KR) | `\b(?:\+?82[- ]?)?0?1[0-9][- ]?\d{3,4}[- ]?\d{4}\b` | `[REDACTED:PHONE]` | Korean mobile number formats with optional `+82` country code |

---

## Application Order

Patterns are applied in the following order. Order matters because earlier matches consume substring boundaries that later patterns might re-match (longer / more-specific patterns must run first to avoid double-redaction or false matches).

1. **JWT Token** (#3) — most specific (3-segment structure with `eyJ` prefix). Runs first so a JWT inside an `Authorization: Bearer ...` header is redacted as `[REDACTED:JWT]` and the surrounding `Bearer` keyword is later collapsed by pattern #2.
2. **API Key (sk-)** (#1) — specific prefix; specific enough to run before generic patterns.
3. **Bearer Token** (#2) — runs after JWT/API-key so it captures only Bearer tokens that did not already match a more specific pattern. After step 1, the residual will look like `Bearer [REDACTED:JWT]`; this step rewrites it to `Bearer [REDACTED]`.
4. **Credit Card Number** (#5) — strict 16-digit 4-4-4-4 pattern. Runs before generic phone/email so 16-digit sequences are not partial-matched by phone.
5. **Phone Number (KR)** (#7) — narrower than email but broader than credit-card. Runs before email because phone digits should never be matched as email local parts.
6. **Email Address** (#6) — generic pattern. Runs after phone/JWT so embedded base64url segments and number sequences are already redacted.
7. **Password Assignment** (#4) — runs last so that any `password=<jwt-or-secret>` form has already had its value-side redacted by earlier steps when applicable; this final pass catches free-form `password=literal` cases.

**Rationale**: Specific (longer / structurally unique) patterns are matched first to avoid false positives from generic patterns. For example, a JWT contains `.`-separated base64url segments that could partially match an email or phone regex if applied later. Running JWT first guarantees the JWT body is collapsed to `[REDACTED:JWT]` before any later pattern inspects it.

**Already-redacted text protection**: Once a substring is replaced with `[REDACTED:*]`, later patterns operate on the redacted text. The redaction marker contains characters (`[`, `:`, `]`) that none of the seven patterns match, so re-redaction does not occur.

---

## False Positive Notes

The patterns above are intentionally conservative — they prioritize coverage over precision. Known false-positive cases:

- **Email pattern (#6)**: `john.doe@company.local` IS matched (`local` qualifies as a TLD-like suffix). Acceptable since `*.local` could legitimately leak internal domain info. Explicit example addresses such as `user@example.com` are also redacted, by design.
- **Phone pattern (#7)**: Matches sequences like `010-1234-5678` even in non-phone contexts (e.g., a numeric ID, an API response code, a URL path fragment). Acceptable for v0.5.0 — refinement deferred. Manual SPEC.md review is the user's compensating control.
- **API Key (#1)**: Strictly requires `sk-` prefix and 20+ alphanumeric chars. Will NOT match shorter keys (e.g., `sk-abc123`) or differently-prefixed keys (e.g., `pk-...`, `xoxb-...`, AWS access keys, GitHub tokens). Future iterations may add more prefixes.
- **Password Assignment (#4)**: Matches `password = "literal"` AND `password = variable`. The literal-vs-reference distinction is not made — even a placeholder like `password=PLACEHOLDER` is masked. The captured value (whether real, placeholder, or variable name) is replaced with `[REDACTED]`.
- **Code-example placeholders**: A documentation snippet like `password=foo` inside a quoted code example is redacted. This is intended conservative behavior; users see the redaction in SPEC.md and can confirm.

**User responsibility**: Since the user authored the `--prefill` body themselves, they retain primary responsibility for not including secrets. The filter is a safety net, not a primary defense.

**Final validation gate**: SPEC.md review (`start-new.md` Step 3) is the final user-facing checkpoint. Users review the SPEC.md before commit and can verify that no leaked secrets remain and that any unintended redactions are acceptable.

---

## Invocation from init-prefill.md

`commands/init-prefill.md` Step 2 invokes this filter set in the following manner:

1. Read `prefill_body` (received from Step 1).
2. Apply all 7 patterns in the order specified in **Application Order** above. After each pattern, the body is mutated in-place.
3. Store the filtered result as `filtered_prefill_body`. This value is used by Step 2.5 (URL detection), Step 3 (work-type detection), Step 4 (context extraction), and Step 5 (route).
4. If any redaction occurred, record the categories matched and their per-category counts. Forward this metadata to the downstream init-xxx so the SPEC.md "Notes" subsection can disclose categories and counts (counts only, not the masked content).

**No-redaction case**: If no pattern matched, `filtered_prefill_body == prefill_body` and the SPEC.md "Notes" disclosure subsection is OMITTED.

**No-preservation guarantee**: The original unfiltered `prefill_body` is NOT preserved anywhere in working documents, SPEC.md, or git commits. Only `filtered_prefill_body` flows downstream.

---

## Usage Examples

### Example 1: Multi-category redaction

**Input** (`prefill_body`):

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
Contact: john.doe@company.com / 010-1234-5678
Direct key: sk-abcdefghijklmnopqrstuvwxyz123456
password=mySecret123
Card: 4111-1111-1111-1111
```

**Output** (`filtered_prefill_body`) after applying patterns in order:

```
Authorization: Bearer [REDACTED]
Contact: [REDACTED:EMAIL] / [REDACTED:PHONE]
Direct key: [REDACTED:API_KEY]
password=[REDACTED]
Card: [REDACTED:CC]
```

Redaction metadata forwarded to downstream init-xxx:

```
{
  "JWT": 1,
  "Bearer": 1,
  "API_KEY": 1,
  "EMAIL": 1,
  "PHONE": 1,
  "PASSWORD": 1,
  "CC": 1
}
```

(Note: the JWT inside the `Authorization` header is redacted by pattern #3 first; pattern #2 then collapses the surrounding `Bearer [REDACTED:JWT]` token to `Bearer [REDACTED]`. Disclosure counts both JWT and Bearer events; the user can confirm in SPEC.md "Notes".)

### Example 2: No-op (clean body)

**Input**:

```
사용자가 작성 권한 요청 기능을 원합니다.
```

**Output** (no pattern matches):

```
사용자가 작성 권한 요청 기능을 원합니다.
```

`filtered_prefill_body == prefill_body`. No SPEC.md "Notes" disclosure is added.
