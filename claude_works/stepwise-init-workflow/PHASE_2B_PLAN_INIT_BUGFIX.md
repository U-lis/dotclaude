# Phase 2B: Init-Bugfix Creation

## Objective

Create /init-bugfix skill with step-by-step questions for bug fix work.

---

## Prerequisites

- [ ] Phase 1 completed (/start-new created)

---

## Scope

### In Scope
- Create .claude/skills/init-bugfix/SKILL.md
- Define 6 step-by-step questions
- Add auto-generate branch keyword
- Add next step selection

### Out of Scope
- Other init skills (Phase 2A/2C)

---

## Instructions

### Step 1: Create skill directory

**Files**: `.claude/skills/init-bugfix/`

**Action**: Create directory for init-bugfix skill

### Step 2: Create SKILL.md with frontmatter

**Files**: `.claude/skills/init-bugfix/SKILL.md`

**Action**: Create file with YAML frontmatter:
- name: init-bugfix
- description: Initialize bug fix work with step-by-step requirements gathering
- user-invocable: true

### Step 3: Define workflow

**Action**: Add workflow diagram showing:
1. Gather bug info (6 steps)
2. Create bugfix branch
3. Create claude_works directory
4. Draft SPEC.md with bug template
5. Review with user
6. Next step selection

### Step 4: Define step-by-step questions

**Action**: Add 6 questions:
```
Step 1: "어떤 버그/문제가 발생하고 있나요?" → Free text
Step 2: "버그가 발생하는 조건이나 재현 단계가 있나요?" → Free text
Step 3: "예상되는 원인이 있나요?" → Options (특정 코드 의심, 외부 의존성, 설정 오류, 모르겠음)
Step 4: "버그의 심각도는 어느 정도인가요?" → Options (Critical, Major, Minor, Trivial)
Step 5: "관련된 파일이나 모듈을 알고 있나요?" → Free text or "모름"
Step 6: "이 버그가 영향을 주는 다른 기능이 있나요?" → Free text or "없음/모름"
```

### Step 5: Add auto-generate branch keyword

**Action**: Document branch keyword auto-generation:
- Format: bugfix/{keyword}
- Examples: bugfix/wrong-script-path, bugfix/null-pointer

### Step 6: Add next step selection

**Action**: Same as init-feature:
- Question: "다음으로 진행할 작업은?"
- Options: Design, 기능 개발, main merge, CHANGELOG, 새 버전 태깅
- Phase selection if "기능 개발" chosen

---

## Completion Checklist

- [ ] .claude/skills/init-bugfix/ directory exists
- [ ] SKILL.md has valid YAML frontmatter
- [ ] Workflow diagram included
- [ ] 6 step-by-step questions defined
- [ ] Branch keyword auto-generation documented
- [ ] Next step selection included
- [ ] Bug-specific SPEC template referenced

---

## Verification

### Manual Verification
```bash
ls -la .claude/skills/init-bugfix/SKILL.md
grep "name: init-bugfix" .claude/skills/init-bugfix/SKILL.md
grep -c "Step [0-9]:" .claude/skills/init-bugfix/SKILL.md
```

### Expected Output
- File exists
- Name is init-bugfix
- 6 steps found
