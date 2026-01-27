# Phase 1E: Translate init-github-issue.md

## Objective

Translate all Korean text in `skills/start-new/init-github-issue.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- AskUserQuestion parameters (Question, Header, Options)
- Error messages in the error handling table
- Work type detection keywords (Korean keywords in detection table)
- User confirmation prompts

### Out of Scope
- Code blocks (already English)
- Technical terms (gh, GraphQL, etc.)
- URL patterns and bash commands

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| GitHub 이슈 URL 또는 번호를 입력해주세요 | Please enter the GitHub issue URL or number |
| URL 형식 | URL format |
| 번호 형식 | Number format |
| 현재 저장소 기준 | Based on current repository |
| gh CLI가 설치되어 있지 않습니다 | gh CLI is not installed |
| 에서 설치해주세요 | Please install from |
| gh auth login 명령으로 인증해주세요 | Please authenticate using gh auth login command |
| 이슈를 찾을 수 없습니다 | Issue not found |
| 이슈에 접근 권한이 없습니다 | No access permission for this issue |
| 유효한 GitHub 이슈 URL이 아닙니다 | Invalid GitHub issue URL |
| 수정 | fix |
| 버그 | bug |
| 오류 | error |
| 추가 | add |
| 기능 | feature |
| 구현 | implement |
| 리팩 | refactor |
| 정리 | cleanup |
| 개선 | improve |
| 이슈 분석 결과, 작업 유형을 확인해주세요 | Based on issue analysis, please confirm the work type |
| 작업 유형 확인 | Work Type Confirmation |
| 기능 추가/수정 | Add/Modify Feature |
| 새로운 기능 개발 또는 기존 기능 개선 | Develop new feature or improve existing feature |
| 버그 수정 | Bug Fix |
| 발견된 버그나 오류 수정 | Fix discovered bugs or errors |
| 리팩토링 | Refactoring |
| 기능 변경 없이 코드 구조 개선 | Improve code structure without changing functionality |
| GitHub Issue에서 추출됨 | Extracted from GitHub Issue |

---

## Instructions

### Step 1: Read Current init-github-issue.md

**Files**: `skills/start-new/init-github-issue.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step 1 - Issue Input Section

**Location**: Lines 11-21

**Action**: Translate:
- Question: `GitHub 이슈 URL 또는 번호를 입력해주세요` → `Please enter the GitHub issue URL or number`
- Header: `GitHub Issue` (already English, keep as-is)
- Options:
  - `URL 형식` → `URL format`
  - `번호 형식` → `Number format`
  - `현재 저장소 기준` → `Based on current repository`

### Step 3: Translate Step 2 - Error Handling Table

**Location**: Lines 42-49 (Error handling table - Message column)

**Action**: Translate error messages:
- `gh CLI가 설치되어 있지 않습니다. https://cli.github.com/ 에서 설치해주세요` → `gh CLI is not installed. Please install from https://cli.github.com/`
- `gh auth login 명령으로 인증해주세요` → `Please authenticate using gh auth login command`
- `이슈 #{number}를 찾을 수 없습니다` → `Issue #{number} not found`
- `이슈에 접근 권한이 없습니다` → `No access permission for this issue`
- `유효한 GitHub 이슈 URL이 아닙니다` → `Invalid GitHub issue URL`

### Step 4: Translate Step 3 - Work Type Detection Keywords

**Location**: Lines 70-76 (Body Analysis Keywords table)

**Action**: Translate the Korean keywords in the Keywords column:
- `수정, 버그, 오류` → Keep these as detection keywords (code logic)
- `추가, 기능, 구현` → Keep these as detection keywords (code logic)
- `리팩, 정리, 개선` → Keep these as detection keywords (code logic)

**Note**: These Korean keywords are used for pattern matching in issue body analysis. They should remain in the table as they detect Korean content in GitHub issues. Add English equivalents if not already present.

### Step 5: Translate Step 3 - Work Type Confirmation AskUserQuestion

**Location**: Lines 78-86

**Action**: Translate:
- Question: `이슈 분석 결과, 작업 유형을 확인해주세요: {issue_title}` → `Based on issue analysis, please confirm the work type: {issue_title}`
- Header: `작업 유형 확인` → `Work Type Confirmation`
- Options:
  - `기능 추가/수정` → `Add/Modify Feature`
  - `새로운 기능 개발 또는 기존 기능 개선` → `Develop new feature or improve existing feature`
  - `버그 수정` → `Bug Fix`
  - `발견된 버그나 오류 수정` → `Fix discovered bugs or errors`
  - `리팩토링` → `Refactoring`
  - `기능 변경 없이 코드 구조 개선` → `Improve code structure without changing functionality`

### Step 6: Translate Work Type Mapping Table

**Location**: Lines 88-92

**Action**: Translate:
- `기능 추가/수정` → `Add/Modify Feature`
- `버그 수정` → `Bug Fix`
- `리팩토링` → `Refactoring`

### Step 7: Translate Pre-filled Context Format

**Location**: Lines 154-155

**Action**: Translate:
- `[GitHub Issue에서 추출됨] {value}` → `[Extracted from GitHub Issue] {value}`

---

## Implementation Notes

### Preserve Structure
- Keep all code block markers (```) unchanged
- Maintain table formatting exactly
- Preserve bash command syntax
- Keep URL patterns and variable placeholders ({number}, {owner}, etc.)

### Special Cases
- Korean keywords in Body Analysis Keywords table are used for pattern matching
- These should remain in the table but with clear comments explaining their purpose
- Consider adding equivalent English keywords for better coverage

### Work Type Detection Logic
The Korean keywords in the detection table are used to analyze GitHub issue bodies that may contain Korean text. The detection logic should:
1. Keep Korean keywords for detecting Korean content
2. Already include English keywords (fix, bug, add, feature, refactor, etc.)

---

## Completion Checklist

- [ ] Step 1 Issue Input AskUserQuestion translated
- [ ] Step 2 Error handling messages translated
- [ ] Step 3 Work type detection keywords documented (Korean keywords kept for detection)
- [ ] Step 3 Work type confirmation AskUserQuestion translated
- [ ] Work type mapping table translated
- [ ] Pre-filled context format translated
- [ ] No user-facing Korean text remains
- [ ] Korean detection keywords properly documented
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters
grep -n '[가-힣]' skills/start-new/init-github-issue.md
```

### Expected Output
```
# Only lines with Korean keywords in the detection table should appear
# These are intentionally kept for detecting Korean content in GitHub issues
# No user-facing prompts or messages should contain Korean
```

---

## Notes

- This file has approximately 40% Korean content
- Error messages are user-facing and must be translated
- Korean keywords in detection table serve a functional purpose (pattern matching)
- Focus on maintaining consistent translations with other init files

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
