# Phase 1D: Translate init-refactor.md

## Objective

Translate all Korean text in `skills/start-new/init-refactor.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- Step headers (Step 1: 대상, etc.)
- AskUserQuestion parameters (Question, Header, Options)
- Free text descriptions and response indicators
- Option labels and descriptions

### Out of Scope
- Code blocks (already English)
- Section headers in English
- Technical terms (DRY, SRP, etc.)

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| 대상 | Target |
| 리팩토링 대상 | Refactoring Target |
| 리팩토링 대상은 무엇인가요? | What is the refactoring target? |
| 파일, 모듈, 클래스, 함수 등 | File, module, class, function, etc. |
| 문제점 | Issues |
| 현재 어떤 문제가 있나요? | What problems currently exist? |
| 중복 코드 (DRY 위반) | Duplicate code (DRY violation) |
| 같은 로직이 여러 곳에 반복됨 | Same logic repeated in multiple places |
| 긴 메서드/클래스 (SRP 위반) | Long method/class (SRP violation) |
| 하나의 단위가 너무 많은 책임을 가짐 | Single unit has too many responsibilities |
| 복잡한 조건문 | Complex conditionals |
| if/switch 문이 복잡하게 중첩됨 | Nested if/switch statements |
| 강한 결합도 | Tight coupling |
| 모듈간 의존성이 높음 | High dependency between modules |
| 테스트 어려움 | Difficult to test |
| 유닛 테스트 작성이 어려움 | Unit testing is difficult |
| 목표 상태 | Target State |
| 목표 | Goal |
| 리팩토링 후 기대하는 상태는? | What is the expected state after refactoring? |
| 목표 아키텍처, 패턴 등 | Target architecture, patterns, etc. |
| 동작 변경 | Behavior Change |
| 기존 동작이 변경되어도 괜찮나요? | Is it okay to change existing behavior? |
| 동작 유지 필수 | Behavior preservation required |
| 순수 리팩토링, 기능 변경 없음 | Pure refactoring, no functionality change |
| 일부 변경 가능 | Partial changes allowed |
| 개선을 위해 동작 변경 허용 | Behavior changes allowed for improvement |
| 테스트 현황 | Test Status |
| 테스트 | Tests |
| 관련된 테스트가 있나요? | Are there related tests? |
| 있음 | Yes |
| 테스트 커버리지 확보됨 | Test coverage established |
| 일부 있음 | Partially exists |
| 부분적으로 테스트 존재 | Tests partially exist |
| 없음 | None |
| 테스트 먼저 작성 필요 | Tests need to be written first |
| 의존 모듈 | Dependent Modules |
| 의존성 | Dependencies |
| 이 코드를 사용하는 다른 모듈이 있나요? | Are there other modules using this code? |
| 없음/모름 | None/Unknown |
| 다른 모듈에서 사용 안함 또는 파악 필요 | Not used by other modules or investigation needed |

---

## Instructions

### Step 1: Read Current init-refactor.md

**Files**: `skills/start-new/init-refactor.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step 1 - Target (대상)

**Location**: Lines 9-14

**Action**: Translate:
- Header: `### Step 1: 대상` → `### Step 1: Target`
- Question: `리팩토링 대상은 무엇인가요?` → `What is the refactoring target?`
- Header in code block: `리팩토링 대상` → `Refactoring Target`
- Response indicator: `→ Free text (파일, 모듈, 클래스, 함수 등)` → `→ Free text (file, module, class, function, etc.)`

### Step 3: Translate Step 2 - Issues (문제점)

**Location**: Lines 16-32

**Action**: Translate:
- Header: `### Step 2: 문제점` → `### Step 2: Issues`
- Question: `현재 어떤 문제가 있나요?` → `What problems currently exist?`
- Header in code block: `문제점` → `Issues`
- Options:
  - `중복 코드 (DRY 위반)` → `Duplicate code (DRY violation)`
  - `같은 로직이 여러 곳에 반복됨` → `Same logic repeated in multiple places`
  - `긴 메서드/클래스 (SRP 위반)` → `Long method/class (SRP violation)`
  - `하나의 단위가 너무 많은 책임을 가짐` → `Single unit has too many responsibilities`
  - `복잡한 조건문` → `Complex conditionals`
  - `if/switch 문이 복잡하게 중첩됨` → `Nested if/switch statements`
  - `강한 결합도` → `Tight coupling`
  - `모듈간 의존성이 높음` → `High dependency between modules`
  - `테스트 어려움` → `Difficult to test`
  - `유닛 테스트 작성이 어려움` → `Unit testing is difficult`

### Step 4: Translate Step 3 - Target State (목표 상태)

**Location**: Lines 34-39

**Action**: Translate:
- Header: `### Step 3: 목표 상태` → `### Step 3: Target State`
- Question: `리팩토링 후 기대하는 상태는?` → `What is the expected state after refactoring?`
- Header in code block: `목표` → `Goal`
- Response indicator: `→ Free text (목표 아키텍처, 패턴 등)` → `→ Free text (target architecture, patterns, etc.)`

### Step 5: Translate Step 4 - Behavior Change (동작 변경)

**Location**: Lines 41-51

**Action**: Translate:
- Header: `### Step 4: 동작 변경` → `### Step 4: Behavior Change`
- Question: `기존 동작이 변경되어도 괜찮나요?` → `Is it okay to change existing behavior?`
- Header in code block: `동작 변경` → `Behavior Change`
- Options:
  - `동작 유지 필수` → `Behavior preservation required`
  - `순수 리팩토링, 기능 변경 없음` → `Pure refactoring, no functionality change`
  - `일부 변경 가능` → `Partial changes allowed`
  - `개선을 위해 동작 변경 허용` → `Behavior changes allowed for improvement`

### Step 6: Translate Step 5 - Test Status (테스트 현황)

**Location**: Lines 53-65

**Action**: Translate:
- Header: `### Step 5: 테스트 현황` → `### Step 5: Test Status`
- Question: `관련된 테스트가 있나요?` → `Are there related tests?`
- Header in code block: `테스트` → `Tests`
- Options:
  - `있음` → `Yes`
  - `테스트 커버리지 확보됨` → `Test coverage established`
  - `일부 있음` → `Partially exists`
  - `부분적으로 테스트 존재` → `Tests partially exist`
  - `없음` → `None`
  - `테스트 먼저 작성 필요` → `Tests need to be written first`

### Step 7: Translate Step 6 - Dependent Modules (의존 모듈)

**Location**: Lines 67-75

**Action**: Translate:
- Header: `### Step 6: 의존 모듈` → `### Step 6: Dependent Modules`
- Question: `이 코드를 사용하는 다른 모듈이 있나요?` → `Are there other modules using this code?`
- Header in code block: `의존성` → `Dependencies`
- Options:
  - `없음/모름` → `None/Unknown`
  - `다른 모듈에서 사용 안함 또는 파악 필요` → `Not used by other modules or investigation needed`

### Step 8: Translate Refactor-Specific Analysis References

**Location**: Lines in "Refactoring vs Behavior Preservation" section

**Action**: Translate:
- `동작 유지 필수` reference → Keep as marker/reference (used for condition checking)

---

## Implementation Notes

### Preserve Structure
- Keep all code block markers (```) unchanged
- Maintain proper indentation in option lists
- Preserve all `→` arrows in response type indicators
- Keep technical terms (DRY, SRP) in English

### Special Cases
- DRY (Don't Repeat Yourself) and SRP (Single Responsibility Principle) are kept in English
- If "동작 유지 필수" appears in code logic checking, keep it as a comment reference

---

## Completion Checklist

- [ ] Step 1 Target section translated
- [ ] Step 2 Issues section translated
- [ ] Step 3 Target State section translated
- [ ] Step 4 Behavior Change section translated
- [ ] Step 5 Test Status section translated
- [ ] Step 6 Dependent Modules section translated
- [ ] Analysis section references updated
- [ ] No Korean characters remain in user-facing text
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters
grep -n '[가-힣]' skills/start-new/init-refactor.md
```

### Expected Output
```
# Only lines with Korean references in condition checks (if any) should appear
# No user-facing Korean text should remain
```

---

## Notes

- This file has approximately 45% Korean content
- All 6 steps contain Korean AskUserQuestion parameters
- Keep technical acronyms (DRY, SRP) unchanged
- Focus on maintaining consistent translations with other init files

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
