# Nickname Change - Specification

## Overview

Signed-in users can change their nickname. Nicknames are validated and unique.

## Functional Requirements

### Core Features
- [ ] FR-1: A signed-in user changes their nickname with `PATCH /me/nickname`.
- [ ] FR-2: A nickname is 3 to 20 characters from `[a-z0-9_]`.
- [ ] FR-3: Nicknames are unique, compared case-insensitively.

## Analysis Results

### Edge Cases

| # | FR | Partition | Case | Expected behavior |
|---|----|-----------|------|-------------------|
| 1 | FR-1 | normal | Valid new nickname | 200, nickname stored |
| 2 | FR-1 | permission | No session | 401, nothing stored |
| 3 | FR-2 | boundary | Lengths 2, 3, 20, 21 | 3 and 20 accepted; 2 and 21 rejected with 422 |
| 4 | FR-2 | invalid | Space or uppercase letter | 422 |
| 5 | FR-3 | invalid | Nickname taken in a different case | 409 |
| 6 | FR-3 | concurrency | Two requests claim the same free nickname at once | one 200, the other 409 |

## Out of Scope

- Nickname history.
