# Phase 1: Start-New Router

## Objective

Create /start-new skill as entry point that routes to appropriate init-* skill based on work type.

---

## Prerequisites

- [x] SPEC.md approved
- [x] GLOBAL.md created

---

## Scope

### In Scope
- Create .claude/skills/start-new/SKILL.md
- Define work type question using AskUserQuestion
- Define routing logic to init-* skills

### Out of Scope
- Actual init-* skill modifications (Phase 2A/2B/2C)

---

## Instructions

### Step 1: Create skill directory

**Files**: `.claude/skills/start-new/`

**Action**: Create directory for start-new skill

### Step 2: Create SKILL.md

**Files**: `.claude/skills/start-new/SKILL.md`

**Action**: Create skill file with:
- YAML frontmatter (name, description, user-invocable: true)
- Workflow diagram
- Question definition for work type selection
- Routing logic to invoke appropriate skill

### Step 3: Define question format

**Action**: In SKILL.md, define AskUserQuestion with:
- Question: "어떤 작업을 시작하려고 하나요?"
- Header: "작업 유형"
- Options:
  - 기능 추가/수정 → /init-feature
  - 버그 수정 → /init-bugfix
  - 리팩토링 → /init-refactor
- multiSelect: false

---

## Completion Checklist

- [ ] .claude/skills/start-new/ directory exists
- [ ] SKILL.md has valid YAML frontmatter
- [ ] Work type question defined with 3 options
- [ ] Routing logic documented for each option
- [ ] Skill follows existing pattern from other skills

---

## Verification

### Manual Verification
```bash
# Check file exists
ls -la .claude/skills/start-new/SKILL.md

# Check YAML frontmatter
head -10 .claude/skills/start-new/SKILL.md
```

### Expected Output
- File exists
- Contains `name: start-new`
- Contains `user-invocable: true`
