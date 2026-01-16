# PHASE 1: Add Mandatory Workflow Rules

## Objective

Add "Mandatory Workflow Rules" section to all three init-xxx SKILL.md files to prevent workflow bypass.

## Prerequisites

- None

## Scope

### Files to Modify
1. `.claude/skills/init-feature/SKILL.md`
2. `.claude/skills/init-bugfix/SKILL.md`
3. `.claude/skills/init-refactor/SKILL.md`

### Section to Add

Insert the following section after `## Workflow` section (after line 45 in each file):

```markdown
## Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of plan mode or permission settings.

### Steps 5-7 are MANDATORY
These steps CANNOT be skipped under any circumstances:
- Step 5: Create SPEC.md file in `claude_works/{subject}/`
- Step 6: Present SPEC.md to user and get approval
- Step 7: Ask "다음으로 진행할 작업은?" question

### Prohibited Actions
NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Bypass SPEC.md file creation
- Skip the Next Step Selection question
- Start coding without user explicitly selecting "기능 개발"
- Assume permission bypass means skipping workflow steps

### Correct Execution Order
Even with permission bypass, follow this exact order:
1. Gather requirements (Step-by-Step Questions)
2. Auto-generate branch keyword
3. Create branch: `git checkout -b {type}/{keyword}`
4. Create directory: `mkdir -p claude_works/{subject}`
5. **Create SPEC.md file** (MANDATORY)
6. **Present SPEC.md for user review** (MANDATORY)
7. **Ask Next Step Selection question** (MANDATORY)
8. Route based on user's explicit choice
```

## Implementation Notes

- Insert after Workflow diagram (after the closing ```)
- Maintain consistent indentation
- All 3 files get identical content

## Completion Checklist

- [ ] Modified init-feature/SKILL.md
- [ ] Modified init-bugfix/SKILL.md
- [ ] Modified init-refactor/SKILL.md
- [ ] Verified section appears after Workflow in each file
- [ ] Verified content is identical in all 3 files
