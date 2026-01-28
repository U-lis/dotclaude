# Phase 1F: Translate _analysis.md

## Objective

Translate all Korean text in `skills/start-new/_analysis.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- AskUserQuestion parameters (Question, Header, Options)
- Clarification prompts and descriptions
- Edge case review prompts
- Summary and confirmation prompts

### Out of Scope
- Code blocks (already English)
- Section headers in English
- Technical terms
- Pseudocode logic

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| 다음 내용을 명확히 해주세요 | Please clarify the following |
| 추가 정보 필요 | Additional Information Required |
| 기타 | Other |
| 직접 입력 | Enter manually |
| 기존 동작과 충돌이 발견되었습니다. 어떻게 처리할까요? | A conflict with existing behavior was found. How should we proceed? |
| 충돌 해결 | Conflict Resolution |
| 새 동작 우선 | Prioritize new behavior |
| 기존 | Existing |
| 새로운 요구사항대로 변경 | Change according to new requirements |
| 기존 유지 | Keep existing |
| 기존 동작을 유지하고 요구사항 수정 | Maintain existing behavior and modify requirements |
| 둘 다 지원 | Support both |
| 호환성을 위해 두 동작 모두 지원 | Support both behaviors for compatibility |
| 다음 엣지 케이스들을 검토해주세요 | Please review the following edge cases |
| 엣지 케이스 확인 | Edge Case Review |
| 모두 승인 | Approve all |
| 나열된 모든 케이스 포함 | Include all listed cases |
| 추가 필요 | Additions needed |
| 케이스 추가 또는 수정 필요 (상세 입력) | Cases need to be added or modified (enter details) |
| 추가하거나 수정할 내용이 있나요? | Is there anything to add or modify? |
| 최종 확인 | Final Confirmation |
| 없음 - SPEC 생성 진행 | None - proceed with SPEC creation |
| 분석 내용이 완전합니다 | Analysis is complete |
| 있음 - 수정 필요 | Yes - revisions needed |
| 수정사항을 입력해주세요 | Please enter the revisions |

---

## Instructions

### Step 1: Read Current _analysis.md

**Files**: `skills/start-new/_analysis.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step A - Input Analysis AskUserQuestion

**Location**: Lines 33-45

**Action**: Translate:
- Question: `다음 내용을 명확히 해주세요: {issue_description}` → `Please clarify the following: {issue_description}`
- Header: `추가 정보 필요` → `Additional Information Required`
- Options:
  - `기타` → `Other`
  - `직접 입력` → `Enter manually`

### Step 3: Translate Step C - Conflict Detection AskUserQuestion

**Location**: Lines 95-107

**Action**: Translate:
- Question: `기존 동작과 충돌이 발견되었습니다. 어떻게 처리할까요?` → `A conflict with existing behavior was found. How should we proceed?`
- Header: `충돌 해결` → `Conflict Resolution`
- Options:
  - `새 동작 우선` → `Prioritize new behavior`
  - Description template: `기존: {existing}. 새로운 요구사항대로 변경` → `Existing: {existing}. Change according to new requirements`
  - `기존 유지` → `Keep existing`
  - `기존 동작을 유지하고 요구사항 수정` → `Maintain existing behavior and modify requirements`
  - `둘 다 지원` → `Support both`
  - `호환성을 위해 두 동작 모두 지원` → `Support both behaviors for compatibility`

### Step 4: Translate Step D - Edge Case Generation AskUserQuestion

**Location**: Lines 140-146

**Action**: Translate:
- Question: `다음 엣지 케이스들을 검토해주세요.` → `Please review the following edge cases.`
- Header: `엣지 케이스 확인` → `Edge Case Review`
- Options:
  - `모두 승인` → `Approve all`
  - `나열된 모든 케이스 포함` → `Include all listed cases`
  - `추가 필요` → `Additions needed`
  - `케이스 추가 또는 수정 필요 (상세 입력)` → `Cases need to be added or modified (enter details)`

### Step 5: Translate Step E - Summary + Clarification AskUserQuestion

**Location**: Lines 175-187

**Action**: Translate:
- Question: `추가하거나 수정할 내용이 있나요?` → `Is there anything to add or modify?`
- Header: `최종 확인` → `Final Confirmation`
- Options:
  - `없음 - SPEC 생성 진행` → `None - proceed with SPEC creation`
  - `분석 내용이 완전합니다` → `Analysis is complete`
  - `있음 - 수정 필요` → `Yes - revisions needed`
  - `수정사항을 입력해주세요` → `Please enter the revisions`

---

## Implementation Notes

### Preserve Structure
- Keep all code block markers (```) unchanged
- Maintain pseudocode structure exactly
- Preserve variable placeholders ({issue_description}, {existing}, etc.)
- Keep conditional logic keywords (if, while, else) unchanged

### Special Cases
- Pseudocode sections contain mixed English and Korean
- Only translate Korean strings within the pseudocode
- Keep function names and logic structure in English

---

## Completion Checklist

- [ ] Step A Input Analysis AskUserQuestion translated
- [ ] Step C Conflict Detection AskUserQuestion translated
- [ ] Step D Edge Case Generation AskUserQuestion translated
- [ ] Step E Summary Clarification AskUserQuestion translated
- [ ] All pseudocode Korean strings translated
- [ ] No Korean characters remain in user-facing text
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters
grep -n '[가-힣]' skills/start-new/_analysis.md
```

### Expected Output
```
# Empty - no Korean characters should remain
```

---

## Notes

- This file has approximately 30% Korean content
- All AskUserQuestion calls contain Korean parameters
- Pseudocode structure must be preserved exactly
- Focus on maintaining consistent translations with other init files

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
