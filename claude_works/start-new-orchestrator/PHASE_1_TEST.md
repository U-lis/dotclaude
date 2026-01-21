# Phase 1: Test Cases

## Test Coverage Target

100% file creation verification (structural validation)

## Structural Tests

### SKILL.md Validation

- [ ] File exists at `.claude/skills/start-new/SKILL.md`
- [ ] File contains valid YAML frontmatter
- [ ] Frontmatter includes `name: start-new`
- [ ] Frontmatter includes `user-invocable: true`
- [ ] Frontmatter does NOT include `hooks:` section
- [ ] File contains "## 13-Step Workflow" section
- [ ] File contains "## Step 1: Work Type Selection" with AskUserQuestion
- [ ] File contains "## Step 2: Load Init Instructions" with conditional loading
- [ ] File contains "## Step 6 Checkpoint" with validation logic
- [ ] File contains "## Init Phase Rules" from init-workflow.md
- [ ] File does NOT reference "Task tool -> orchestrator"
- [ ] File does NOT reference "Task tool -> init-xxx agent"
- [ ] Estimated line count: 350-450 lines

### _analysis.md Validation

- [ ] File exists at `.claude/skills/start-new/_analysis.md`
- [ ] File contains "## Iteration Limits" section
- [ ] File contains "## Step A: Input Analysis" section
- [ ] File contains "## Step B: Codebase Investigation" section
- [ ] File contains "## Step C: Conflict Detection" section
- [ ] File contains "## Step D: Edge Case Generation" section
- [ ] File contains "## Step E: Summary + Clarification" section
- [ ] File contains "## Analysis Results Template" section
- [ ] File does NOT contain work-type-specific details (moved to init-xxx.md)
- [ ] Estimated line count: 120-160 lines

### init-feature.md Validation

- [ ] File exists at `.claude/skills/start-new/init-feature.md`
- [ ] File does NOT contain "## Role" section
- [ ] File does NOT contain "## Capabilities" section
- [ ] File does NOT contain "## Output Contract" section
- [ ] File contains 8 step-by-step questions (Steps 1-8)
- [ ] File contains "### Step 1: 목표" section
- [ ] File contains "### Step 8: 범위 제외" section
- [ ] File contains "### Feature-Specific Analysis" section
- [ ] File contains "## Branch Keyword" section
- [ ] File references "_analysis.md" for common workflow
- [ ] Estimated line count: 130-170 lines

### init-bugfix.md Validation

- [ ] File exists at `.claude/skills/start-new/init-bugfix.md`
- [ ] File does NOT contain "## Role" section
- [ ] File does NOT contain "## Capabilities" section
- [ ] File does NOT contain "## Output Contract" section
- [ ] File contains 6 step-by-step questions (Steps 1-6)
- [ ] File contains "### Step 1: 증상" section
- [ ] File contains "### Step 6: 영향 범위" section
- [ ] File contains "### Bugfix-Specific Analysis" section
- [ ] File contains "### Required Analysis Outputs" section
- [ ] File contains "### Inconclusive Analysis Handling" section
- [ ] File references "_analysis.md" for common workflow
- [ ] Estimated line count: 160-200 lines

### init-refactor.md Validation

- [ ] File exists at `.claude/skills/start-new/init-refactor.md`
- [ ] File does NOT contain "## Role" section
- [ ] File does NOT contain "## Capabilities" section
- [ ] File does NOT contain "## Output Contract" section
- [ ] File contains 6 step-by-step questions (Steps 1-6)
- [ ] File contains "### Step 1: 대상" section
- [ ] File contains "### Step 6: 의존 모듈" section
- [ ] File contains "### Refactor-Specific Analysis" section
- [ ] File contains "### Refactoring Safety Notes" section
- [ ] File references "_analysis.md" for common workflow
- [ ] Estimated line count: 140-180 lines

## Content Preservation Tests

### AskUserQuestion Parameters

- [ ] Work type selection in SKILL.md has exact Korean labels
- [ ] SPEC review in SKILL.md has exact options
- [ ] Scope selection in SKILL.md has exact 4 options
- [ ] Feature questions (8) have exact Korean text
- [ ] Bugfix questions (6) have exact Korean text
- [ ] Refactor questions (6) have exact Korean text

### Workflow Completeness

- [ ] All 13 steps documented in SKILL.md
- [ ] Steps 1, 3, 5 use AskUserQuestion (not text tables)
- [ ] Step 2 has conditional loading (not Task tool)
- [ ] Step 6 has checkpoint validation
- [ ] Steps 6-13 execution phase documented

### Analysis Phase Coverage

- [ ] _analysis.md contains all 5 analysis steps (A-E)
- [ ] Each init-xxx.md has work-type-specific analysis
- [ ] Iteration limits preserved (5 questions, 3 iterations, 10 file reads)

## Line Count Verification

| File | Expected | Tolerance |
|------|----------|-----------|
| SKILL.md | ~400 | 350-450 |
| _analysis.md | ~140 | 120-160 |
| init-feature.md | ~150 | 130-170 |
| init-bugfix.md | ~180 | 160-200 |
| init-refactor.md | ~160 | 140-180 |
| **Total** | **~1,030** | 900-1,160 |

## Verification Commands

```bash
# Check all files exist
ls -la .claude/skills/start-new/*.md

# Count lines per file
wc -l .claude/skills/start-new/*.md

# Check SKILL.md frontmatter
head -10 .claude/skills/start-new/SKILL.md

# Verify no Task tool -> init-xxx references
grep -c "Task tool.*init-" .claude/skills/start-new/SKILL.md
# Expected: 0

# Verify AskUserQuestion present
grep -c "AskUserQuestion" .claude/skills/start-new/SKILL.md
# Expected: 3+ (Steps 1, 3, 5)
```

## Edge Cases

- [ ] SKILL.md handles case where user cancels at Step 1
- [ ] init-xxx.md files handle missing/empty user responses
- [ ] _analysis.md skip conditions documented
