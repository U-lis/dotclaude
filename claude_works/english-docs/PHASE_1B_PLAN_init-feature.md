# Phase 1B: Translate init-feature.md

## Objective

Translate all Korean text in `skills/start-new/init-feature.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- Step headers (Step 1: 목표, etc.)
- AskUserQuestion parameters (Question, Header, Options)
- Free text descriptions
- Option labels and descriptions

### Out of Scope
- Code blocks (already English)
- Section headers in English
- Technical terms

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| 목표 | Goal |
| 이 기능의 주요 목표는 무엇인가요? | What is the main goal of this feature? |
| 문제 | Problem |
| 어떤 문제를 해결하려고 하나요? | What problem are you trying to solve? |
| 핵심 기능 | Core Features |
| 반드시 있어야 하는 핵심 기능은 무엇인가요? | What core features must be included? |
| 부가 기능 | Additional Features |
| 있으면 좋지만 필수는 아닌 기능이 있나요? | Are there any nice-to-have but non-essential features? |
| 없음 | None |
| 필수 기능만 구현 | Implement only required features |
| 기술 제약 | Technical Constraints |
| 기술적 제약이 있나요? | Are there any technical constraints? |
| 언어/프레임워크 지정 | Specific language/framework required |
| 특정 기술 스택 사용 필요 | Requires specific tech stack |
| 기존 패턴 따르기 | Follow existing patterns |
| 코드베이스의 기존 패턴 준수 | Follow codebase conventions |
| 제약 없음 | No constraints |
| 자유롭게 구현 가능 | Free to implement |
| 성능 요구 | Performance Requirements |
| 성능 요구사항이 있나요? | Are there any performance requirements? |
| 있음 | Yes |
| 상세 내용을 입력해주세요 | Please enter details |
| 특별한 성능 요구사항 없음 | No specific performance requirements |
| 보안 고려 | Security Considerations |
| 보안 고려사항이 있나요? | Are there any security considerations? |
| 인증/인가 필요 | Authentication/Authorization required |
| 사용자 인증 또는 권한 검증 필요 | Requires user authentication or permission verification |
| 데이터 암호화 | Data encryption |
| 민감 데이터 암호화 필요 | Requires sensitive data encryption |
| 입력 검증 | Input validation |
| 사용자 입력 검증 필요 | Requires user input validation |
| 특별한 보안 요구사항 없음 | No specific security requirements |
| 범위 제외 | Out of Scope |
| 명시적으로 범위에서 제외할 것은? | What should be explicitly excluded from scope? |
| 제외할 항목 없음 | No items to exclude |

---

## Instructions

### Step 1: Read Current init-feature.md

**Files**: `skills/start-new/init-feature.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step 1 - Goal (목표)

**Location**: Lines 9-14

**Action**: Translate:
- Header: `### Step 1: 목표` → `### Step 1: Goal`
- Question: `이 기능의 주요 목표는 무엇인가요?` → `What is the main goal of this feature?`
- Header in code block: `목표` → `Goal`

### Step 3: Translate Step 2 - Problem (문제)

**Location**: Lines 16-21

**Action**: Translate:
- Header: `### Step 2: 문제` → `### Step 2: Problem`
- Question: `어떤 문제를 해결하려고 하나요?` → `What problem are you trying to solve?`
- Header in code block: `문제` → `Problem`

### Step 4: Translate Step 3 - Core Features (핵심 기능)

**Location**: Lines 23-28

**Action**: Translate:
- Header: `### Step 3: 핵심 기능` → `### Step 3: Core Features`
- Question: `반드시 있어야 하는 핵심 기능은 무엇인가요?` → `What core features must be included?`
- Header in code block: `핵심 기능` → `Core Features`

### Step 5: Translate Step 4 - Additional Features (부가 기능)

**Location**: Lines 30-39

**Action**: Translate:
- Header: `### Step 4: 부가 기능` → `### Step 4: Additional Features`
- Question: `있으면 좋지만 필수는 아닌 기능이 있나요?` → `Are there any nice-to-have but non-essential features?`
- Header in code block: `부가 기능` → `Additional Features`
- Option label: `없음` → `None`
- Option description: `필수 기능만 구현` → `Implement only required features`

### Step 6: Translate Step 5 - Technical Constraints (기술 제약)

**Location**: Lines 41-52

**Action**: Translate:
- Header: `### Step 5: 기술 제약` → `### Step 5: Technical Constraints`
- Question: `기술적 제약이 있나요?` → `Are there any technical constraints?`
- Header in code block: `기술 제약` → `Technical Constraints`
- Options:
  - `언어/프레임워크 지정` → `Specific language/framework required`
  - `특정 기술 스택 사용 필요` → `Requires specific tech stack`
  - `기존 패턴 따르기` → `Follow existing patterns`
  - `코드베이스의 기존 패턴 준수` → `Follow codebase conventions`
  - `제약 없음` → `No constraints`
  - `자유롭게 구현 가능` → `Free to implement`

### Step 7: Translate Step 6 - Performance Requirements (성능 요구)

**Location**: Lines 54-65

**Action**: Translate:
- Header: `### Step 6: 성능 요구` → `### Step 6: Performance Requirements`
- Question: `성능 요구사항이 있나요?` → `Are there any performance requirements?`
- Header in code block: `성능` → `Performance`
- Options:
  - `있음` → `Yes`
  - `상세 내용을 입력해주세요` → `Please enter details`
  - `없음` → `None`
  - `특별한 성능 요구사항 없음` → `No specific performance requirements`

### Step 8: Translate Step 7 - Security Considerations (보안 고려)

**Location**: Lines 67-80

**Action**: Translate:
- Header: `### Step 7: 보안 고려` → `### Step 7: Security Considerations`
- Question: `보안 고려사항이 있나요?` → `Are there any security considerations?`
- Header in code block: `보안` → `Security`
- Options:
  - `인증/인가 필요` → `Authentication/Authorization required`
  - `사용자 인증 또는 권한 검증 필요` → `Requires user authentication or permission verification`
  - `데이터 암호화` → `Data encryption`
  - `민감 데이터 암호화 필요` → `Requires sensitive data encryption`
  - `입력 검증` → `Input validation`
  - `사용자 입력 검증 필요` → `Requires user input validation`
  - `없음` → `None`
  - `특별한 보안 요구사항 없음` → `No specific security requirements`

### Step 9: Translate Step 8 - Out of Scope (범위 제외)

**Location**: Lines 82-90

**Action**: Translate:
- Header: `### Step 8: 범위 제외` → `### Step 8: Out of Scope`
- Question: `명시적으로 범위에서 제외할 것은?` → `What should be explicitly excluded from scope?`
- Header in code block: `범위 제외` → `Out of Scope`
- Option: `없음` → `None`
- Option description: `제외할 항목 없음` → `No items to exclude`

---

## Implementation Notes

### Preserve Structure
- Keep all code block markers (```) unchanged
- Maintain proper indentation in option lists
- Preserve all `→` arrows in response type indicators

### Special Cases
- `→ Free text response` lines should remain unchanged (already English)
- `→ Or free text via "Other"` lines should remain unchanged

---

## Completion Checklist

- [ ] Step 1 Goal section translated
- [ ] Step 2 Problem section translated
- [ ] Step 3 Core Features section translated
- [ ] Step 4 Additional Features section translated
- [ ] Step 5 Technical Constraints section translated
- [ ] Step 6 Performance Requirements section translated
- [ ] Step 7 Security Considerations section translated
- [ ] Step 8 Out of Scope section translated
- [ ] No Korean characters remain in init-feature.md
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters
grep -n '[가-힣]' skills/start-new/init-feature.md
```

### Expected Output
```
# Empty - no Korean characters should remain
```

---

## Notes

- This file has approximately 40% Korean content
- All 8 steps contain Korean AskUserQuestion parameters
- Focus on maintaining consistent translations with other init files

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
