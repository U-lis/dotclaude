# Phase 2A: Init-Feature Update

## Objective

Update /init-feature skill with step-by-step questions and next step selection.

---

## Prerequisites

- [ ] Phase 1 completed (/start-new created)

---

## Scope

### In Scope
- Rewrite question flow to step-by-step format (8 steps)
- Add auto-generate branch keyword logic
- Add next step selection after SPEC approval
- Add phase selection for "기능 개발" option

### Out of Scope
- Creating new skills (Phase 2B/2C)

---

## Instructions

### Step 1: Update question flow section

**Files**: `.claude/skills/init-feature/SKILL.md`

**Action**: Replace "Questions to Ask" section with step-by-step format:

```
Step 1: "이 기능의 주요 목표는 무엇인가요?" → Free text
Step 2: "어떤 문제를 해결하려고 하나요?" → Free text
Step 3: "반드시 있어야 하는 핵심 기능은 무엇인가요?" → Free text
Step 4: "있으면 좋지만 필수는 아닌 기능이 있나요?" → Free text or "없음"
Step 5: "기술적 제약이 있나요?" → Options
Step 6: "성능 요구사항이 있나요?" → Options
Step 7: "보안 고려사항이 있나요?" → Options (multiSelect)
Step 8: "명시적으로 범위에서 제외할 것은?" → Free text or "없음"
```

### Step 2: Add auto-generate branch keyword

**Files**: `.claude/skills/init-feature/SKILL.md`

**Action**: Add section explaining:
- Branch keyword auto-generated from conversation context
- No user question for keyword
- Examples: feature/external-api, feature/user-metrics

### Step 3: Add next step selection

**Files**: `.claude/skills/init-feature/SKILL.md`

**Action**: Add "Next Step Selection" section:
- Question: "다음으로 진행할 작업은?"
- Options: Design, 기능 개발, main merge, CHANGELOG, 새 버전 태깅

### Step 4: Add phase selection for development

**Files**: `.claude/skills/init-feature/SKILL.md`

**Action**: Add conditional question when "기능 개발" selected:
- Question: "현재 {N}개 phase가 계획되어 있습니다. 어디까지 진행할까요?"
- Options: 전부 다 (top), Phase 1까지, Phase 2까지, ...
- Note: Single select, each includes all previous phases

---

## Completion Checklist

- [ ] 8 step-by-step questions defined
- [ ] Branch keyword auto-generation documented
- [ ] Next step selection with 5 options
- [ ] Phase selection with "전부 다" at top
- [ ] Phase selection uses "Phase X까지" format

---

## Verification

### Manual Verification
```bash
# Check file updated
grep -c "Step [0-9]:" .claude/skills/init-feature/SKILL.md

# Check next step selection exists
grep "다음으로 진행할 작업" .claude/skills/init-feature/SKILL.md
```

### Expected Output
- 8 steps found
- Next step selection section exists
