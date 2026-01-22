# Phase 4: Test Cases

## Test Coverage Target

End-to-end functional validation for all work types

## Structural Tests

### File Existence

- [ ] `.claude/skills/start-new/SKILL.md` exists
- [ ] `.claude/skills/start-new/_analysis.md` exists
- [ ] `.claude/skills/start-new/init-feature.md` exists
- [ ] `.claude/skills/start-new/init-bugfix.md` exists
- [ ] `.claude/skills/start-new/init-refactor.md` exists

### File Absence (Deleted)

- [ ] `.claude/agents/orchestrator.md` does NOT exist
- [ ] `.claude/agents/init-feature.md` does NOT exist
- [ ] `.claude/agents/init-bugfix.md` does NOT exist
- [ ] `.claude/agents/init-refactor.md` does NOT exist
- [ ] `.claude/skills/init-feature/` does NOT exist
- [ ] `.claude/skills/init-bugfix/` does NOT exist
- [ ] `.claude/skills/init-refactor/` does NOT exist

### Line Count

| File | Expected | Min | Max |
|------|----------|-----|-----|
| SKILL.md | ~400 | 350 | 450 |
| _analysis.md | ~140 | 120 | 160 |
| init-feature.md | ~150 | 130 | 170 |
| init-bugfix.md | ~180 | 160 | 200 |
| init-refactor.md | ~160 | 140 | 180 |
| **Total** | **~1,030** | **900** | **1,160** |

## Functional Tests - Feature

### Step 1: Work Type Selection

- [ ] `/start-new` invocation successful
- [ ] AskUserQuestion tool called (not text table)
- [ ] Options include "기능 추가/수정"
- [ ] Selection "기능 추가/수정" proceeds to Step 2

### Step 2: Init Instructions Loading

- [ ] init-feature.md content loaded
- [ ] 8 questions asked sequentially:
  - [ ] Step 1: 목표
  - [ ] Step 2: 문제
  - [ ] Step 3: 핵심 기능
  - [ ] Step 4: 부가 기능
  - [ ] Step 5: 기술 제약
  - [ ] Step 6: 성능 요구
  - [ ] Step 7: 보안 고려
  - [ ] Step 8: 범위 제외

### Analysis Phase

- [ ] _analysis.md referenced
- [ ] Step A: Input Analysis executed
- [ ] Step B: Codebase Investigation executed (feature-specific)
- [ ] Step C: Conflict Detection executed
- [ ] Step D: Edge Case Generation executed
- [ ] Step E: Summary + Clarification executed

### Branch and SPEC

- [ ] Branch `feature/{keyword}` created
- [ ] Directory `claude_works/{subject}/` created
- [ ] SPEC.md created with:
  - [ ] Overview section
  - [ ] Functional Requirements section
  - [ ] Analysis Results section

### Step 3: SPEC Review

- [ ] AskUserQuestion tool called
- [ ] Options include "승인" and "수정 필요"
- [ ] Approval proceeds to Step 4

### Step 4: Commit

- [ ] SPEC.md committed
- [ ] Commit message follows format

### Step 5: Scope Selection

- [ ] AskUserQuestion tool called
- [ ] 4 scope options presented
- [ ] Selection determines workflow continuation

### Step 6: Checkpoint

- [ ] Validation executed before Design
- [ ] Checkpoint passes if SPEC.md committed on work branch

## Functional Tests - Bugfix

### Questions

- [ ] 6 bugfix questions asked:
  - [ ] Step 1: 증상
  - [ ] Step 2: 재현 조건
  - [ ] Step 3: 예상 원인
  - [ ] Step 4: 심각도
  - [ ] Step 5: 관련 파일
  - [ ] Step 6: 영향 범위

### Bugfix-Specific Analysis

- [ ] Recent change analysis in Step B
- [ ] Root cause identification
- [ ] Affected code locations documented

### SPEC.md Format

- [ ] User-Reported Information section present
- [ ] AI Analysis Results section present
- [ ] Root Cause Analysis included
- [ ] Fix Strategy included

### Branch

- [ ] Branch `bugfix/{keyword}` created

## Functional Tests - Refactor

### Questions

- [ ] 6 refactor questions asked:
  - [ ] Step 1: 대상
  - [ ] Step 2: 문제점
  - [ ] Step 3: 목표 상태
  - [ ] Step 4: 동작 변경
  - [ ] Step 5: 테스트 현황
  - [ ] Step 6: 의존 모듈

### Refactor-Specific Analysis

- [ ] Dependency mapping in Step B
- [ ] Test coverage check
- [ ] Pattern analysis

### SPEC.md Format

- [ ] XP Principle Reference included
- [ ] Dependency map included
- [ ] Safety notes considered

### Branch

- [ ] Branch `refactor/{keyword}` created

## Regression Tests

### Other Skills Working

- [ ] `/design` skill invocable
- [ ] `/code` skill invocable
- [ ] `/validate-spec` skill invocable
- [ ] `/merge-main` skill invocable
- [ ] `/tagging` skill invocable

### Deleted Skills Not Working

- [ ] `/init-feature` not recognized or fails
- [ ] `/init-bugfix` not recognized or fails
- [ ] `/init-refactor` not recognized or fails

## Step 6 Checkpoint Tests

### Blocking Conditions

- [ ] On main branch: blocks with "Work branch not created"
- [ ] On work branch without SPEC.md: blocks with "SPEC.md not found"
- [ ] On work branch with uncommitted SPEC.md: blocks with "SPEC.md not committed"

### Passing Condition

- [ ] On work branch with committed SPEC.md: passes and proceeds to Designer

## Integration Tests

### Full Workflow (Feature)

- [ ] `/start-new` -> feature -> complete questions -> approve SPEC -> select "Design" -> Designer called

### Full Workflow (Bugfix)

- [ ] `/start-new` -> bugfix -> complete questions -> approve SPEC -> select "Design" -> Designer called

### Full Workflow (Refactor)

- [ ] `/start-new` -> refactor -> complete questions -> approve SPEC -> select "Design" -> Designer called

## Verification Commands

```bash
# Quick structural check
ls -la .claude/skills/start-new/
wc -l .claude/skills/start-new/*.md

# Check for deleted files
ls .claude/agents/orchestrator.md 2>/dev/null && echo "ERROR: orchestrator.md exists" || echo "OK"
ls .claude/skills/init-feature/SKILL.md 2>/dev/null && echo "ERROR: init-feature exists" || echo "OK"

# Check SKILL.md content
grep -c "AskUserQuestion" .claude/skills/start-new/SKILL.md  # Expected: 3+
grep -c "Step 6 Checkpoint" .claude/skills/start-new/SKILL.md  # Expected: 1+
grep -c "init-feature.md" .claude/skills/start-new/SKILL.md  # Expected: 1+
```

## Pass Criteria

- [ ] All structural tests pass
- [ ] Feature flow functional test passes
- [ ] Bugfix flow functional test passes
- [ ] Refactor flow functional test passes
- [ ] All regression tests pass
- [ ] Step 6 checkpoint tests pass
- [ ] No broken references or errors

## Test Report Template

```markdown
## Phase 4 Validation Report

### Date: YYYY-MM-DD

### Structural Validation
- Files exist: [PASS/FAIL]
- Line count in range: [PASS/FAIL]

### Feature Flow
- AskUserQuestion at Step 1: [PASS/FAIL]
- Questions loaded: [PASS/FAIL]
- SPEC created: [PASS/FAIL]
- Checkpoint passed: [PASS/FAIL]

### Bugfix Flow
- Questions loaded: [PASS/FAIL]
- Root cause analysis: [PASS/FAIL]
- SPEC format correct: [PASS/FAIL]

### Refactor Flow
- Questions loaded: [PASS/FAIL]
- Dependency mapping: [PASS/FAIL]
- Safety notes included: [PASS/FAIL]

### Regression
- Other skills working: [PASS/FAIL]
- Deleted skills removed: [PASS/FAIL]

### Overall: [PASS/FAIL]

### Issues Found:
- (list any issues)
```
