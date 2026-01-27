# Phase 1A: Translate SKILL.md

## Objective

Translate all Korean text in `skills/start-new/SKILL.md` to English while preserving document structure and formatting.

---

## Prerequisites

- [ ] SPEC.md reviewed and approved
- [ ] Translation reference table available (see GLOBAL.md)

---

## Scope

### In Scope
- AskUserQuestion prompts (question, header, options)
- User-facing messages and labels
- Version history section headers

### Out of Scope
- Code blocks (already English)
- Technical terms (AskUserQuestion, SPEC.md, etc.)
- Markdown structure

---

## Translation Reference Table

| Korean | English |
|--------|---------|
| 어떤 작업을 시작하려고 하나요? | What type of work do you want to start? |
| 작업 유형 | Work Type |
| 기능 추가/수정 | Add/Modify Feature |
| 새로운 기능 개발 또는 기존 기능 개선 | Develop new feature or improve existing feature |
| 버그 수정 | Bug Fix |
| 발견된 버그나 오류 수정 | Fix discovered bugs or errors |
| 리팩토링 | Refactoring |
| 기능 변경 없이 코드 구조 개선 | Improve code structure without changing functionality |
| GitHub Issue | GitHub Issue |
| GitHub 이슈 URL로 자동 초기화 | Auto-initialize from GitHub issue URL |
| 최근 버전 히스토리 | Recent Version History |
| 버전 | Version |
| 날짜 | Date |
| 주요 변경사항 | Key Changes |
| 이 작업의 목표 버전은 무엇인가요? | What is the target version for this work? |
| 목표 버전 | Target Version |
| 패치 | Patch |
| 버그 수정, 작은 변경 | Bug fixes, small changes |
| 마이너 | Minor |
| 새 기능 추가, 하위 호환 | New feature addition, backward compatible |
| 메이저 | Major |
| Breaking changes 포함 | Includes breaking changes |
| SPEC.md를 검토해주세요. 수정이 필요하면 말씀해주세요. | Please review SPEC.md. Let me know if revisions are needed. |
| SPEC 검토 | SPEC Review |
| 승인 | Approve |
| SPEC.md 내용이 정확합니다 | SPEC.md content is accurate |
| 수정 필요 | Needs Revision |
| 수정이 필요합니다 (상세 내용 입력) | Revisions needed (enter details) |
| 어디까지 진행할까요? | How far should we proceed? |
| 진행 범위 | Execution Scope |
| 설계 문서만 작성 | Create design documents only |
| 설계 + 코드 구현 | Design + code implementation |
| 설계 + 코드 + 문서 업데이트 | Design + code + documentation update |
| 전체 워크플로우 실행 | Execute full workflow |

---

## Instructions

### Step 1: Read Current SKILL.md

**Files**: `skills/start-new/SKILL.md`

**Action**: Read the file to identify all Korean text locations

### Step 2: Translate Step 1 - Work Type Selection

**Location**: Lines 37-47 (AskUserQuestion parameters)

**Action**: Translate the following Korean strings to English:
- `question: "어떤 작업을 시작하려고 하나요?"` → `question: "What type of work do you want to start?"`
- `header: "작업 유형"` → `header: "Work Type"`
- Option labels and descriptions:
  - `기능 추가/수정` → `Add/Modify Feature`
  - `새로운 기능 개발 또는 기존 기능 개선` → `Develop new feature or improve existing feature`
  - `버그 수정` → `Bug Fix`
  - `발견된 버그나 오류 수정` → `Fix discovered bugs or errors`
  - `리팩토링` → `Refactoring`
  - `기능 변경 없이 코드 구조 개선` → `Improve code structure without changing functionality`
  - `GitHub 이슈 URL로 자동 초기화` → `Auto-initialize from GitHub issue URL`

### Step 3: Translate Step 2 - User Selection Mapping Table

**Location**: Lines 52-57 (User Selection column in table)

**Action**: Translate the mapping table entries:
- `기능 추가/수정` → `Add/Modify Feature`
- `버그 수정` → `Bug Fix`
- `리팩토링` → `Refactoring`

### Step 4: Translate Step 2.6 - Target Version Section

**Location**: Lines 73-108 (Version history and version question)

**Action**: Translate:
- Section header: `## 최근 버전 히스토리` → `## Recent Version History`
- Table headers: `버전`, `날짜`, `주요 변경사항` → `Version`, `Date`, `Key Changes`
- Question: `이 작업의 목표 버전은 무엇인가요?` → `What is the target version for this work?`
- Header: `목표 버전` → `Target Version`
- Option labels: `패치`, `마이너`, `메이저` → `Patch`, `Minor`, `Major`
- Option descriptions:
  - `버그 수정, 작은 변경` → `Bug fixes, small changes`
  - `새 기능 추가, 하위 호환` → `New feature addition, backward compatible`
  - `Breaking changes 포함` → `Includes breaking changes`

### Step 5: Translate Step 3 - SPEC Review

**Location**: Lines 110-119 (SPEC review AskUserQuestion)

**Action**: Translate:
- Question: `SPEC.md를 검토해주세요. 수정이 필요하면 말씀해주세요.` → `Please review SPEC.md. Let me know if revisions are needed.`
- Header: `SPEC 검토` → `SPEC Review`
- Options:
  - `승인` → `Approve`
  - `SPEC.md 내용이 정확합니다` → `SPEC.md content is accurate`
  - `수정 필요` → `Needs Revision`
  - `수정이 필요합니다 (상세 내용 입력)` → `Revisions needed (enter details)`

### Step 6: Translate Step 5 - Scope Selection

**Location**: Lines 129-138 (Scope selection AskUserQuestion)

**Action**: Translate:
- Question: `어디까지 진행할까요?` → `How far should we proceed?`
- Header: `진행 범위` → `Execution Scope`
- Option descriptions:
  - `설계 문서만 작성` → `Create design documents only`
  - `설계 + 코드 구현` → `Design + code implementation`
  - `설계 + 코드 + 문서 업데이트` → `Design + code + documentation update`
  - `전체 워크플로우 실행` → `Execute full workflow`

---

## Implementation Notes

### Preserve Structure
- Keep all line breaks and indentation exactly as-is
- Keep all code block markers (```) unchanged
- Keep YAML structure for options intact

### Special Cases
- The markdown table format must be preserved
- Option arrays must maintain proper YAML formatting
- Descriptions inside curly braces must stay properly quoted

---

## Completion Checklist

- [ ] Step 1 Work Type Selection translated
- [ ] Step 2 User Selection mapping table translated
- [ ] Step 2.6 Target Version section translated
- [ ] Step 3 SPEC Review translated
- [ ] Step 5 Scope Selection translated
- [ ] No Korean characters remain in SKILL.md (except in comments explaining Korean keywords)
- [ ] All formatting preserved
- [ ] File syntax valid (no broken markdown)

---

## Verification

### Manual Verification
```bash
# Check for remaining Korean characters (excluding comments)
grep -n '[가-힣]' skills/start-new/SKILL.md
```

### Expected Output
```
# Only lines with Korean keywords in comments (e.g., explaining detection patterns) should appear
# No user-facing Korean text should remain
```

---

## Notes

- This file has approximately 30% Korean content
- Focus on AskUserQuestion parameters as these are user-facing
- Keep technical terms in English (SPEC.md, AskUserQuestion, etc.)

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
