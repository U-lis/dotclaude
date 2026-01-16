# PHASE 1: Test Cases

## Test 1: Section Presence

**Objective**: Verify "Mandatory Workflow Rules" section exists in all files

**Steps**:
1. Read `.claude/skills/init-feature/SKILL.md`
2. Confirm `## Mandatory Workflow Rules` header exists
3. Repeat for init-bugfix and init-refactor

**Expected**: Section present in all 3 files

## Test 2: Section Position

**Objective**: Verify section is positioned after Workflow diagram

**Steps**:
1. In each file, find `## Workflow` section
2. Confirm `## Mandatory Workflow Rules` appears immediately after Workflow's closing ```
3. Confirm it appears before `## Step-by-Step Questions`

**Expected**: Correct position in all 3 files

## Test 3: Content Consistency

**Objective**: Verify all 3 files have identical section content

**Steps**:
1. Extract "Mandatory Workflow Rules" section from each file
2. Compare content between files
3. Verify no differences

**Expected**: Identical content in all 3 files

## Test 4: Manual Workflow Test

**Objective**: Verify workflow is enforced in practice

**Steps**:
1. Start a new session
2. Run `/init-bugfix`
3. Answer all questions
4. Observe Claude's behavior after questions

**Expected**:
- Claude creates SPEC.md (does not skip)
- Claude presents SPEC.md for review
- Claude asks "다음으로 진행할 작업은?" question
- Claude does NOT jump directly to implementation
