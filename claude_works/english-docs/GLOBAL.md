# English Documentation Conversion - Global Documentation

## Feature Overview

**Purpose**: Convert all Korean documentation in the dotclaude project to English for international accessibility.

**Problem**: Korean documentation limits accessibility for international users who cannot read Korean. This creates a barrier for adoption and contribution from the global developer community.

**Solution**: Systematically translate Korean text portions in skills/, agents/, and templates/ directories while preserving all existing English content and document structure. Create multilingual README support (English primary, Korean secondary).

---

## Architecture Decision

### Translation Approach
**Options Considered**:
1. Full document rewrite in English
2. Selective translation of Korean portions only

**Decision**: Option 2 - Selective translation

**Rationale**:
- Preserves existing tested formatting and structure
- Minimizes risk of introducing errors
- Maintains exact line positions for code references
- Less error-prone than full rewrite

### README Strategy
**Options Considered**:
1. Keep Korean README, create English version
2. Convert README to English, create Korean version

**Decision**: Option 2 - English as primary

**Rationale**:
- English is the international standard for technical documentation
- Primary language should be English for broader reach
- Korean maintained as README_ko.md for existing Korean users

---

## Data Model

### Translation Reference Table

Use this table for consistent translations across all documents:

| Korean | English |
|--------|---------|
| 어떤 작업을 시작하려고 하나요? | What type of work do you want to start? |
| 작업 유형 | Work Type |
| 기능 추가/수정 | Add/Modify Feature |
| 버그 수정 | Bug Fix |
| 리팩토링 | Refactoring |
| 목표 | Goal |
| 문제 | Problem |
| 핵심 기능 | Core Features |
| 부가 기능 | Additional Features |
| 기술 제약 | Technical Constraints |
| 성능 요구 | Performance Requirements |
| 보안 고려 | Security Considerations |
| 범위 제외 | Out of Scope |
| 목표 버전 | Target Version |
| 패치 | Patch |
| 마이너 | Minor |
| 메이저 | Major |
| 승인 | Approve |
| 수정 필요 | Needs Revision |
| 진행 범위 | Execution Scope |
| 증상 | Symptoms |
| 재현 조건 | Reproduction Steps |
| 예상 원인 | Expected Cause |
| 심각도 | Severity |
| 관련 파일 | Related Files |
| 영향 범위 | Impact Scope |
| 추가 정보 필요 | Additional Information Required |
| 없음 | None |
| 있음 | Yes |
| 모름 | Unknown |

---

## File Structure

### Files to Modify

```
skills/start-new/
├── SKILL.md             # 30% Korean → Translate AskUserQuestion prompts
├── init-feature.md      # 40% Korean → Translate 8-step questions
├── init-bugfix.md       # 45% Korean → Translate 6-step questions
├── init-refactor.md     # 45% Korean → Translate 6-step questions
├── init-github-issue.md # 40% Korean → Translate error messages, prompts
└── _analysis.md         # 30% Korean → Translate clarification questions
```

### Files to Create

```
README_ko.md             # Korean version of README (copy current content)
```

### Files to Update

```
README.md                # Convert to English (primary language)
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1A | Translate SKILL.md | 🔴 Not Started | - |
| 1B | Translate init-feature.md | 🔴 Not Started | - |
| 1C | Translate init-bugfix.md | 🔴 Not Started | - |
| 1D | Translate init-refactor.md | 🔴 Not Started | - |
| 1E | Translate init-github-issue.md | 🔴 Not Started | - |
| 1F | Translate _analysis.md | 🔴 Not Started | - |
| 1.5 | Merge verification | 🔴 Not Started | Phase 1A-1F |
| 2 | README handling | 🔴 Not Started | Phase 1.5 |

**Status Legend**:
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Complete
- ⚠️ Blocked

---

## Phase Dependencies

```
Phase 1A ──┐
Phase 1B ──┤
Phase 1C ──┼──→ Phase 1.5 ──→ Phase 2
Phase 1D ──┤
Phase 1E ──┤
Phase 1F ──┘
```

**Parallel Execution**: Phases 1A-1F can execute in parallel (no file conflicts)

**Merge Phase (1.5)**: Verification only - no actual git merge needed since files don't overlap

**Sequential Phase (2)**: README handling must wait for all translation phases

---

## Risk Mitigation

### Risk 1: Inconsistent Translations
**Impact**: Medium
**Mitigation**: Use translation reference table consistently; validate against table after each phase

### Risk 2: Breaking Document Structure
**Impact**: High
**Mitigation**: Translate ONLY Korean text; preserve all markdown syntax, code blocks, and English content unchanged

### Risk 3: Missing Translations
**Impact**: Low
**Mitigation**: Each phase plan includes explicit list of Korean strings to translate; validation step checks completeness

---

## Completion Criteria

Overall feature is complete when:
- [ ] All phases marked 🟢 Complete
- [ ] All Korean text translated to English in target files
- [ ] README.md is English (primary)
- [ ] README_ko.md exists with Korean content
- [ ] No Korean characters remain in skills/start-new/ directory (except comments explaining Korean keywords for detection)
- [ ] Document structure and formatting preserved

---

## Next Steps

1. ⏳ Execute Phase 1A-1F in parallel (skills/start-new/ translations)
2. Verify all Phase 1 translations complete (Phase 1.5)
3. Execute Phase 2 (README handling)
4. Final validation and commit
