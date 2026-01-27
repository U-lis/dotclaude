# Phase 2: README Handling

## Objective

Convert README.md to English as the primary language and create README_ko.md for Korean speakers.

---

## Prerequisites

- [ ] Phase 1.5 (Merge Verification) completed
- [ ] All skills/start-new/ translations verified

---

## Scope

### In Scope
- README.md conversion to English (if any Korean content exists)
- Creation of README_ko.md with Korean content
- Verify README.md structure is maintained

### Out of Scope
- Changes to README content beyond translation
- Adding new sections or features
- Modifying code examples

---

## Instructions

### Step 1: Analyze Current README.md

**Files**: `README.md`

**Action**:
1. Read the current README.md
2. Identify if any Korean content exists
3. Document current structure and sections

**Current State Analysis**:
Based on SPEC analysis, README.md is already in English. This phase will:
- Verify README.md is fully English
- Create README_ko.md by translating English content to Korean

### Step 2: Verify README.md is English

**Action**: Check for any Korean characters in README.md

```bash
grep -n '[가-힣]' README.md
```

**Expected Result**: No Korean characters (file is already English)

### Step 3: Create README_ko.md

**Action**: Create Korean version of README.md

**Translation Sections**:

| Section | English | Korean |
|---------|---------|--------|
| Title | "dotclaude" | "dotclaude" (keep as-is) |
| Subtitle | "A multi-agent development workflow system for Claude Code." | "Claude Code를 위한 멀티 에이전트 개발 워크플로우 시스템." |
| Overview header | "## Overview" | "## 개요" |
| Structure header | "## Structure" | "## 구조" |
| Workflow header | "## Workflow" | "## 워크플로우" |
| Orchestrator header | "## Orchestrator" | "## 오케스트레이터" |
| Skills header | "## Skills (Commands)" | "## 스킬 (명령어)" |
| Agents header | "## Agents" | "## 에이전트" |
| Document Types header | "## Document Types" | "## 문서 유형" |
| Phase Naming header | "## Phase Naming Convention" | "## 단계 명명 규칙" |
| Installation header | "## Installation" | "## 설치" |
| Usage header | "## Usage" | "## 사용법" |
| License header | "## License" | "## 라이선스" |

**Key Phrases**:

| English | Korean |
|---------|--------|
| Systematic project planning and specification | 체계적인 프로젝트 계획 및 명세 |
| Parallel development with git worktrees | git worktree를 활용한 병렬 개발 |
| Automated code validation | 자동화된 코드 검증 |
| Language-specific coding standards | 언어별 코딩 표준 |
| Orchestrator-managed workflow from init to merge | init부터 merge까지 오케스트레이터 관리 워크플로우 |
| Plugin marketplace | 플러그인 마켓플레이스 |
| Manual Installation | 수동 설치 |
| Start New Work | 새 작업 시작 |
| Update dotclaude | dotclaude 업데이트 |
| Manual Execution (Bypass Orchestrator) | 수동 실행 (오케스트레이터 우회) |

### Step 4: Add Language Navigation

**Action**: Add language navigation links to both README files

**README.md** (add at top):
```markdown
[English](README.md) | [한국어](README_ko.md)
```

**README_ko.md** (add at top):
```markdown
[English](README.md) | [한국어](README_ko.md)
```

### Step 5: Verify Both Files

**Action**: Verify both README files are complete and consistent

```bash
# Check README.md has no Korean
grep -n '[가-힣]' README.md

# Check README_ko.md exists and has Korean content
grep -n '[가-힣]' README_ko.md | head -5
```

---

## Implementation Notes

### Preserve Structure
- Keep all code blocks exactly as-is (no translation)
- Keep all command examples unchanged
- Keep file paths unchanged
- Keep technical terms (git, worktree, etc.) in English

### Special Cases
- Table headers and cell alignments must be preserved
- Code fence languages (```bash, ```markdown) must remain
- URLs and links must remain unchanged

### Translation Style
- Use formal Korean (습니다체)
- Keep technical terms in English where appropriate
- Maintain consistency with existing Korean documentation style

---

## File Locations

| File | Language | Status |
|------|----------|--------|
| `README.md` | English | Existing (verify) |
| `README_ko.md` | Korean | To be created |

---

## Completion Checklist

- [ ] README.md verified as English-only
- [ ] README_ko.md created with Korean translation
- [ ] Language navigation added to both files
- [ ] Code blocks preserved (not translated)
- [ ] Command examples preserved
- [ ] Links and URLs preserved
- [ ] Table structure preserved
- [ ] Both files verified complete

---

## Verification

### Manual Verification
```bash
# Verify README.md is English
grep -c '[가-힣]' README.md
# Expected: 0

# Verify README_ko.md has Korean
grep -c '[가-힣]' README_ko.md
# Expected: > 0

# Verify both files exist
ls -la README.md README_ko.md

# Verify language links
head -2 README.md
head -2 README_ko.md
```

### Expected Output
```
# README.md has 0 Korean characters
# README_ko.md has Korean characters
# Both files exist with appropriate sizes
# Both files have language navigation links at top
```

---

## Notes

- README.md is already English (no conversion needed, just verification)
- README_ko.md is a new file (translation from English to Korean)
- This is the reverse direction of other phases (English → Korean instead of Korean → English)
- Keep all technical content identical, only translate descriptive text

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
