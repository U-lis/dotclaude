# SPEC: English Documentation Conversion

**Source Issue**: https://github.com/U-lis/dotclaude/issues/10
**Target Version**: 0.2.0
**Work Type**: feature
**Branch**: feature/english-docs

---

## Overview

### Goal
Convert all Korean documents in skills, agents, and templates to English for international accessibility.

### Problem
Korean documentation limits accessibility for international users who cannot read Korean.

---

## Functional Requirements

### Core Features (Must Have)

1. **All Documents English Conversion**
   - Convert all Korean text in skills/, agents/, templates/ directories to English
   - Target: 6 CRITICAL files + 1 HIGH priority file (see Analysis Results)

2. **README Multilingual Support**
   - Convert README.md to English (primary)
   - Create README_ko.md for Korean version

### Secondary Features (Nice to Have)
- None specified

---

## Non-Functional Requirements

### Performance
- No specific performance requirements

### Security
- No specific security requirements

---

## Constraints

### Technical Constraints
- Follow existing codebase patterns
- Maintain document structure and formatting
- Preserve all code references and technical terms

### Translation Rules (CRITICAL)
- **DO NOT** rewrite or restructure documents
- **DO NOT** modify existing English content
- **ONLY** translate Korean text portions to English
- Preserve exact line positions and formatting
- Keep all markdown syntax, code blocks, and technical terms unchanged

---

## Out of Scope

- Language setting integration (#7) - to be handled in separate issue
- Dynamic language conversion based on user settings

---

## Analysis Results

### Files Requiring Translation

#### CRITICAL Priority (User-Facing)

| File | Korean % | Key Content |
|------|----------|-------------|
| `skills/start-new/SKILL.md` | 30% | Work type selection, version question, SPEC review, scope selection |
| `skills/start-new/init-feature.md` | 40% | 8-step requirements gathering questions |
| `skills/start-new/init-bugfix.md` | 45% | 6-step bugfix investigation questions |
| `skills/start-new/init-refactor.md` | 45% | 6-step refactoring questions |
| `skills/start-new/init-github-issue.md` | 40% | GitHub issue input, error messages, work type detection |
| `skills/start-new/_analysis.md` | 30% | Clarification questions, conflict resolution, edge case review |

#### HIGH Priority

| File | Korean % | Key Content |
|------|----------|-------------|
| `skills/start-new/_analysis.md` | 30% | Analysis phase questions |

#### MEDIUM Priority (Internal)

| File | Korean % | Key Content |
|------|----------|-------------|
| `agents/designer.md` | <5% | Minor Korean references |
| `agents/technical-writer.md` | <5% | Minor Korean references |
| Other agent files | <5% | Minimal Korean |

#### NO Translation Needed

- `templates/*.md` - Already all English
- `commands/*.md` - Already all English
- `CLAUDE.md` - Already all English
- `.claude/CLAUDE.md` - Already all English

### Korean Content Categories

1. **AskUserQuestion prompts** - User-facing questions and options
2. **Error messages** - User feedback and guidance
3. **Section headers** - Document organization
4. **Keyword lists** - Pattern matching for work type detection
5. **Field labels** - Data structure documentation

### Translation Examples

| Korean | English |
|--------|---------|
| 어떤 작업을 시작하려고 하나요? | What type of work do you want to start? |
| 기능 추가/수정 | Add/Modify Feature |
| 버그 수정 | Bug Fix |
| 리팩토링 | Refactoring |
| 목표 버전 | Target Version |
| 패치 | Patch |
| 마이너 | Minor |
| 메이저 | Major |

### Conflicts Identified
- None - This is additive work (translation only)

### Edge Cases

1. **Mixed Korean/English documents**: Preserve English portions, translate Korean only
2. **Technical terms**: Keep code terms in English (e.g., `AskUserQuestion`, `SPEC.md`)
3. **Keyword detection**: Update Korean keywords to English in work type detection logic

---

## Deliverables

1. **Translated files** (6 CRITICAL + 1 HIGH priority)
2. **README.md** - English version (primary)
3. **README_ko.md** - Korean version (new file)
4. **Updated CHANGELOG.md** - Document changes
