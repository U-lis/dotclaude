---
description: Sensitive data filtering rules for prefill content. Internal reference used by init.md.
user-invocable: false
---
# Prefill filters

`init.md` applies these seven patterns to `--prefill` and pasted text before anything else reads it; unfiltered text is never written to disk.

| # | Name | Regex | Replacement |
|---|------|-------|-------------|
| 1 | API key | `\bsk-[A-Za-z0-9_\-]{20,}\b` | `[REDACTED:API_KEY]` |
| 2 | Bearer token | `\bBearer\s+[A-Za-z0-9\-_\.=]+\b` | `Bearer [REDACTED]` |
| 3 | JWT | `\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\b` | `[REDACTED:JWT]` |
| 4 | Password | `(?i)\b(password\|passwd\|pwd)\s*[=:]\s*\S+` | `\1=[REDACTED]` |
| 5 | Credit card | `\b(?:\d{4}[- ]?){3}\d{4}\b` | `[REDACTED:CC]` |
| 6 | Email | `(?i)\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b` | `[REDACTED:EMAIL]` |
| 7 | Phone (KR) | `\b(?:\+?82[- ]?)?0?1[0-9][- ]?\d{3,4}[- ]?\d{4}\b` | `[REDACTED:PHONE]` |

## Order

Apply in this order: 3, 1, 2, 5, 7, 6, 4.

- JWT (3) before Bearer (2), so the Bearer rewrite sees `Bearer [REDACTED:JWT]` and collapses it to `Bearer [REDACTED]` instead of matching raw token text.
- Email (6) late, after the structured patterns have already consumed their text, because it is the most false-positive prone.

Never emit nested markers such as `[REDACTED:[REDACTED:JWT]]`; treat existing `[REDACTED:*]` text as already handled.

## False positives

The filter favors coverage over precision; the user sees redactions in the SPEC review.

- Emails in code examples (`user@example.com`) are redacted.
- 16-digit ids that are not cards match the credit-card pattern.
- Korean phone-like numbers (ids, response codes) match the phone pattern.
