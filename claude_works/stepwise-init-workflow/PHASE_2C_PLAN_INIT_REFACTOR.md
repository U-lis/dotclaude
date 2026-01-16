# Phase 2C: Init-Refactor Creation

## Objective

Create /init-refactor skill with step-by-step questions for refactoring work.

---

## Prerequisites

- [ ] Phase 1 completed (/start-new created)

---

## Scope

### In Scope
- Create .claude/skills/init-refactor/SKILL.md
- Define 6 step-by-step questions
- Add auto-generate branch keyword
- Add next step selection

### Out of Scope
- Other init skills (Phase 2A/2B)

---

## Instructions

### Step 1: Create skill directory

**Files**: `.claude/skills/init-refactor/`

**Action**: Create directory for init-refactor skill

### Step 2: Create SKILL.md with frontmatter

**Files**: `.claude/skills/init-refactor/SKILL.md`

**Action**: Create file with YAML frontmatter:
- name: init-refactor
- description: Initialize refactoring work with step-by-step requirements gathering
- user-invocable: true

### Step 3: Define workflow

**Action**: Add workflow diagram showing:
1. Gather refactor info (6 steps)
2. Create refactor branch
3. Create claude_works directory
4. Draft SPEC.md with refactor template
5. Review with user
6. Next step selection

### Step 4: Define step-by-step questions

**Action**: Add 6 questions:
```
Step 1: "리팩토링 대상은 무엇인가요?" → Free text (파일, 모듈, 클래스)
Step 2: "현재 어떤 문제가 있나요?" → Options multiSelect (DRY위반, SRP위반, 복잡한 조건문, 강한 결합도, 테스트 어려움)
Step 3: "리팩토링 후 기대하는 상태는?" → Free text
Step 4: "기존 동작이 변경되어도 괜찮나요?" → Options (동작 유지 필수, 일부 변경 가능)
Step 5: "관련된 테스트가 있나요?" → Options (있음, 일부 있음, 없음)
Step 6: "이 코드를 사용하는 다른 모듈이 있나요?" → Free text or "없음/모름"
```

### Step 5: Add auto-generate branch keyword

**Action**: Document branch keyword auto-generation:
- Format: refactor/{keyword}
- Examples: refactor/user-service, refactor/extract-api-client

### Step 6: Add next step selection

**Action**: Same as init-feature:
- Question: "다음으로 진행할 작업은?"
- Options: Design, 기능 개발, main merge, CHANGELOG, 새 버전 태깅
- Phase selection if "기능 개발" chosen

---

## Completion Checklist

- [ ] .claude/skills/init-refactor/ directory exists
- [ ] SKILL.md has valid YAML frontmatter
- [ ] Workflow diagram included
- [ ] 6 step-by-step questions defined
- [ ] Step 2 uses multiSelect for problem types
- [ ] Branch keyword auto-generation documented
- [ ] Next step selection included

---

## Verification

### Manual Verification
```bash
ls -la .claude/skills/init-refactor/SKILL.md
grep "name: init-refactor" .claude/skills/init-refactor/SKILL.md
grep -c "Step [0-9]:" .claude/skills/init-refactor/SKILL.md
```

### Expected Output
- File exists
- Name is init-refactor
- 6 steps found
