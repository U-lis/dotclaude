# Phase 4: End-to-End Validation

## Objective

Validate the refactored /start-new skill works correctly with all three work types and verify no regression in other skills.

## Prerequisites

- Phase 1 completed (new files created)
- Phase 2 completed (references updated)
- Phase 3 completed (old files deleted)

## Instructions

### 4A: Structural Validation

Verify file structure matches expected layout.

**Commands**:
```bash
# List all files in start-new skill directory
ls -la .claude/skills/start-new/

# Expected output:
# SKILL.md
# _analysis.md
# init-feature.md
# init-bugfix.md
# init-refactor.md

# Verify file sizes are reasonable
wc -l .claude/skills/start-new/*.md
```

**Checklist**:
- [ ] 5 files exist in start-new directory
- [ ] Total line count ~1,030 (900-1,160 range)
- [ ] SKILL.md is largest (~400 lines)
- [ ] No other unexpected files

---

### 4B: Syntax Validation

Verify YAML frontmatter and markdown structure.

**SKILL.md Frontmatter Check**:
```bash
head -10 .claude/skills/start-new/SKILL.md
```

Expected:
```yaml
---
name: start-new
description: ...
user-invocable: true
---
```

- [ ] Valid YAML frontmatter
- [ ] name: start-new
- [ ] user-invocable: true
- [ ] No hooks section (removed)

**Markdown Structure Check**:
- [ ] All files have valid markdown headers
- [ ] No broken markdown syntax
- [ ] Code blocks properly closed

---

### 4C: Functional Validation - Feature Flow

Test `/start-new` with feature work type.

**Test Steps**:

1. Invoke `/start-new`
2. At Step 1 (Work Type Selection):
   - Verify AskUserQuestion tool is called (not text table)
   - Select "기능 추가/수정"
3. Verify conditional loading:
   - init-feature.md content is loaded
   - 8 feature questions are asked sequentially
4. Complete questions with test answers
5. Verify analysis phase executes:
   - Input Analysis (Step A)
   - Codebase Investigation (Step B)
   - Conflict Detection (Step C)
   - Edge Case Generation (Step D)
   - Summary + Clarification (Step E)
6. Verify branch created: `feature/{keyword}`
7. Verify SPEC.md created in `claude_works/{subject}/`
8. At Step 3 (SPEC Review):
   - Verify AskUserQuestion tool is called
   - Approve SPEC
9. Verify SPEC.md committed
10. At Step 5 (Scope Selection):
    - Verify AskUserQuestion tool is called
    - Select "Design" to stop early
11. Verify Step 6 checkpoint passes
12. Verify workflow completes or proceeds to design

**Expected Outputs**:
- [ ] AskUserQuestion called at Steps 1, 3, 5
- [ ] Branch `feature/{keyword}` created
- [ ] SPEC.md exists with Analysis Results section
- [ ] SPEC.md committed before design phase

---

### 4D: Functional Validation - Bugfix Flow

Test `/start-new` with bugfix work type.

**Test Steps**:

1. Invoke `/start-new`
2. Select "버그 수정" at Step 1
3. Verify init-bugfix.md loaded:
   - 6 bugfix questions asked
   - Enhanced Step B (recent change analysis)
   - Required Analysis Outputs generated
4. Complete questions with test answers
5. Verify branch: `bugfix/{keyword}`
6. Verify SPEC.md format:
   - User-Reported Information section
   - AI Analysis Results section (Root Cause, etc.)
7. Approve and commit SPEC
8. Select scope and verify checkpoint

**Expected Outputs**:
- [ ] 6 bugfix-specific questions asked
- [ ] Branch `bugfix/{keyword}` created
- [ ] SPEC.md has bugfix-specific sections
- [ ] Root cause analysis included

---

### 4E: Functional Validation - Refactor Flow

Test `/start-new` with refactor work type.

**Test Steps**:

1. Invoke `/start-new`
2. Select "리팩토링" at Step 1
3. Verify init-refactor.md loaded:
   - 6 refactor questions asked
   - Dependency mapping in Step B
   - Safety notes considered
4. Complete questions with test answers
5. Verify branch: `refactor/{keyword}`
6. Verify SPEC.md format:
   - XP Principle Reference
   - Dependency map
   - Test coverage assessment
7. Approve and commit SPEC
8. Select scope and verify checkpoint

**Expected Outputs**:
- [ ] 6 refactor-specific questions asked
- [ ] Branch `refactor/{keyword}` created
- [ ] SPEC.md has refactor-specific sections
- [ ] Refactoring safety notes included

---

### 4F: Regression Testing

Verify other skills still work correctly.

**Skills to Test**:

| Skill | Test Method |
|-------|-------------|
| /design | Invoke with existing SPEC.md |
| /code | Invoke with existing PLAN.md |
| /validate-spec | Invoke with existing documents |
| /merge-main | Invoke (dry-run if possible) |
| /tagging | Invoke to create tag |

**Checklist**:
- [ ] /design skill works (reads SPEC, calls Designer agent)
- [ ] /code skill works (reads PLAN, calls Coder agent)
- [ ] /validate-spec skill works
- [ ] /merge-main skill works
- [ ] /tagging skill works

---

### 4G: Deleted Skill Verification

Verify old skills are no longer invocable.

**Commands to test**:
- `/init-feature` - should fail or not be recognized
- `/init-bugfix` - should fail or not be recognized
- `/init-refactor` - should fail or not be recognized

**Expected**:
- [ ] `/init-feature` command not found or fails gracefully
- [ ] `/init-bugfix` command not found or fails gracefully
- [ ] `/init-refactor` command not found or fails gracefully

---

### 4H: Step 6 Checkpoint Validation

Verify Step 6 checkpoint logic works.

**Test Cases**:

1. **On main branch without SPEC**:
   - Checkpoint should block
   - Error: "Work branch not created"

2. **On work branch without SPEC.md**:
   - Checkpoint should block
   - Error: "SPEC.md not found"

3. **On work branch with uncommitted SPEC.md**:
   - Checkpoint should block
   - Error: "SPEC.md not committed"

4. **On work branch with committed SPEC.md**:
   - Checkpoint should pass
   - Proceed to Designer call

**Checklist**:
- [ ] Checkpoint blocks on main branch
- [ ] Checkpoint blocks without SPEC.md
- [ ] Checkpoint blocks with uncommitted SPEC.md
- [ ] Checkpoint passes with committed SPEC.md

## Completion Checklist

- [ ] Structural validation passed
- [ ] Syntax validation passed
- [ ] Feature flow tested and working
- [ ] Bugfix flow tested and working
- [ ] Refactor flow tested and working
- [ ] Regression tests passed for other skills
- [ ] Deleted skills no longer invocable
- [ ] Step 6 checkpoint works correctly

## Notes

### Test Environment

For functional tests:
- Use a test branch (not production)
- Clean up test branches after validation
- Document any unexpected behavior

### Partial Testing

If full end-to-end test not possible:
- At minimum, verify AskUserQuestion is called
- Verify conditional loading pattern works
- Verify Step 6 checkpoint logic executes

### Known Limitations

- Subagent calls (Designer, TechnicalWriter, Coder) not changed
- Those should work as before (Task tool patterns preserved)
