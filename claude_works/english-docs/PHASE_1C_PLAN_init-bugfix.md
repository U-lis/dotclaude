# Phase 1C: Translate init-bugfix.md

## Objective

Translate all Korean text in `skills/start-new/init-bugfix.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- Step headers (Step 1: 증상, etc.)
- AskUserQuestion parameters (Question, Header, Options)
- Free text descriptions and response indicators
- Option labels and descriptions
- Comments in Korean

### Out of Scope
- Code blocks (already English)
- Section headers in English
- Technical terms

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| 증상 | Symptoms |
| 버그 증상 | Bug Symptoms |
| 어떤 버그/문제가 발생하고 있나요? | What bug/problem is occurring? |
| 증상 설명 | Symptom description |
| 재현 조건 | Reproduction Steps |
| 버그가 발생하는 조건이나 재현 단계가 있나요? | Are there conditions or steps to reproduce the bug? |
| 재현 단계 | Reproduction steps |
| 예상 원인 | Expected Cause |
| 예상되는 원인이 있나요? | Do you have a suspected cause? |
| 특정 코드 의심 | Suspect specific code |
| 특정 파일이나 함수가 원인으로 의심됨 | Specific file or function is suspected |
| 외부 의존성 문제 | External dependency issue |
| 라이브러리나 외부 서비스 관련 문제 | Library or external service related issue |
| 설정 오류 | Configuration error |
| 환경 설정이나 config 문제 | Environment or config issue |
| 모르겠음 | Unknown |
| 원인 파악이 필요함 | Root cause analysis needed |
| 심각도 | Severity |
| 버그의 심각도는 어느 정도인가요? | What is the severity of the bug? |
| 서비스 불가 또는 데이터 손실 위험 | Service unavailable or risk of data loss |
| 주요 기능 장애 | Major feature failure |
| 불편함이 있으나 우회 가능 | Inconvenient but workaround exists |
| 미미한 문제 | Trivial issue |
| 관련 파일 | Related Files |
| 관련된 파일이나 모듈을 알고 있나요? | Do you know the related files or modules? |
| 모름 | Unknown |
| 조사가 필요함 | Investigation needed |
| 파일 경로 입력 | Enter file path |
| 영향 범위 | Impact Scope |
| 이 버그가 영향을 주는 다른 기능이 있나요? | Are there other features affected by this bug? |
| 없음/모름 | None/Unknown |
| 다른 기능에 영향 없거나 파악 필요 | No effect on other features or investigation needed |

---

## Instructions

### Step 1: Read Current init-bugfix.md

**Files**: `skills/start-new/init-bugfix.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step 1 - Symptoms (증상)

**Location**: Lines 9-14

**Action**: Translate:
- Header: `### Step 1: 증상` → `### Step 1: Symptoms`
- Question: `어떤 버그/문제가 발생하고 있나요?` → `What bug/problem is occurring?`
- Header in code block: `버그 증상` → `Bug Symptoms`
- Response indicator: `→ Free text (증상 설명)` → `→ Free text (symptom description)`

### Step 3: Translate Step 2 - Reproduction Steps (재현 조건)

**Location**: Lines 16-21

**Action**: Translate:
- Header: `### Step 2: 재현 조건` → `### Step 2: Reproduction Steps`
- Question: `버그가 발생하는 조건이나 재현 단계가 있나요?` → `Are there conditions or steps to reproduce the bug?`
- Header in code block: `재현 조건` → `Reproduction Steps`
- Response indicator: `→ Free text (재현 단계)` → `→ Free text (reproduction steps)`

### Step 4: Translate Step 3 - Expected Cause (예상 원인)

**Location**: Lines 23-37

**Action**: Translate:
- Header: `### Step 3: 예상 원인` → `### Step 3: Expected Cause`
- Question: `예상되는 원인이 있나요?` → `Do you have a suspected cause?`
- Header in code block: `예상 원인` → `Expected Cause`
- Options:
  - `특정 코드 의심` → `Suspect specific code`
  - `특정 파일이나 함수가 원인으로 의심됨` → `Specific file or function is suspected`
  - `외부 의존성 문제` → `External dependency issue`
  - `라이브러리나 외부 서비스 관련 문제` → `Library or external service related issue`
  - `설정 오류` → `Configuration error`
  - `환경 설정이나 config 문제` → `Environment or config issue`
  - `모르겠음` → `Unknown`
  - `원인 파악이 필요함` → `Root cause analysis needed`

### Step 5: Translate Step 4 - Severity (심각도)

**Location**: Lines 39-53

**Action**: Translate:
- Header: `### Step 4: 심각도` → `### Step 4: Severity`
- Question: `버그의 심각도는 어느 정도인가요?` → `What is the severity of the bug?`
- Header in code block: `심각도` → `Severity`
- Options:
  - `서비스 불가 또는 데이터 손실 위험` → `Service unavailable or risk of data loss`
  - `주요 기능 장애` → `Major feature failure`
  - `불편함이 있으나 우회 가능` → `Inconvenient but workaround exists`
  - `미미한 문제` → `Trivial issue`

### Step 6: Translate Step 5 - Related Files (관련 파일)

**Location**: Lines 55-63

**Action**: Translate:
- Header: `### Step 5: 관련 파일` → `### Step 5: Related Files`
- Question: `관련된 파일이나 모듈을 알고 있나요?` → `Do you know the related files or modules?`
- Header in code block: `관련 파일` → `Related Files`
- Options:
  - `모름` → `Unknown`
  - `조사가 필요함` → `Investigation needed`
- Response indicator: `→ Or free text via "Other" (파일 경로 입력)` → `→ Or free text via "Other" (enter file path)`

### Step 7: Translate Step 6 - Impact Scope (영향 범위)

**Location**: Lines 65-73

**Action**: Translate:
- Header: `### Step 6: 영향 범위` → `### Step 6: Impact Scope`
- Question: `이 버그가 영향을 주는 다른 기능이 있나요?` → `Are there other features affected by this bug?`
- Header in code block: `영향 범위` → `Impact Scope`
- Options:
  - `없음/모름` → `None/Unknown`
  - `다른 기능에 영향 없거나 파악 필요` → `No effect on other features or investigation needed`

### Step 8: Translate Bugfix-Specific Analysis Section

**Location**: Lines 83-99 (Case descriptions)

**Action**: Translate:
- `##### Case 2: User said "모름" (unknown files)` → Already English, but note: keep `모름` as a reference since it may appear in user input

---

## Implementation Notes

### Preserve Structure
- Keep all code block markers (```) unchanged
- Maintain proper indentation in option lists
- Preserve all `→` arrows in response type indicators

### Special Cases
- Keep Critical/Major/Minor/Trivial labels as-is (already English)
- In Case 2 comment, keep reference to Korean word `모름` for context

---

## Completion Checklist

- [ ] Step 1 Symptoms section translated
- [ ] Step 2 Reproduction Steps section translated
- [ ] Step 3 Expected Cause section translated
- [ ] Step 4 Severity section translated
- [ ] Step 5 Related Files section translated
- [ ] Step 6 Impact Scope section translated
- [ ] Analysis section Korean references updated
- [ ] No Korean characters remain in user-facing text
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters
grep -n '[가-힣]' skills/start-new/init-bugfix.md
```

### Expected Output
```
# Only line with "모름" reference in Case 2 comment should appear (if kept for context)
# No user-facing Korean text should remain
```

---

## Notes

- This file has approximately 45% Korean content
- All 6 steps contain Korean AskUserQuestion parameters
- Severity options (Critical/Major/Minor/Trivial) are already in English
- Focus on maintaining consistent translations with other init files

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
