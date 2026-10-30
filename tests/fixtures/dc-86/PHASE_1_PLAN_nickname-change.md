# Phase 1: nickname-change

## Objective

Add the nickname change endpoint with validation and case-insensitive uniqueness.

## Requirements

- FR-1
- FR-2
- FR-3

---

## Prerequisites

- Users table exists with a `nickname` column.

---

## Scope

### In Scope
- Endpoint, validator, unique index.

### Out of Scope
- Nickname history.

---

## Instructions

### Step 1: Validator

**Files**: `app/users/nickname.py`

**Action**: Add `validate_nickname(value)` enforcing length 3 to 20 and `[a-z0-9_]`.

### Step 2: Unique index

**Files**: `migrations/0042_nickname_unique.py`

**Action**: Add a unique index on `lower(nickname)`.

### Step 3: Endpoint

**Files**: `app/users/routes.py`

**Action**: Add `PATCH /me/nickname`; require a session; map the validator error to 422 and the unique violation to 409.

---

## Completion Checklist

- [ ] `validate_nickname` rejects lengths outside 3 to 20 and characters outside `[a-z0-9_]`: `app/users/nickname.py`
- [ ] Unique index on `lower(nickname)`: `migrations/0042_nickname_unique.py`
- [ ] `PATCH /me/nickname` returns 401 without a session, 422 on validation error, 409 on conflict: `app/users/routes.py`
