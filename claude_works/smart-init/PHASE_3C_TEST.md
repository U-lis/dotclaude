# Phase 3C: Test Cases

## Test Coverage Target
100% of modified sections verified

## File Location Test
- [ ] File modified: `.claude/skills/init-refactor/SKILL.md`

## Section Tests

### Analysis Phase Section
- [ ] "Analysis Phase" header exists after Step 6
- [ ] "MANDATORY" keyword present
- [ ] Reference to `_shared/analysis-phases.md` exists

### Refactor-Specific Analysis
- [ ] "Refactor-Specific Analysis" subsection exists
- [ ] "Step B: Codebase Investigation (Refactor Focus)" subsection exists
- [ ] Analysis components present:
  - [ ] Target Code Analysis
  - [ ] Usage Analysis with dependency graph mention
  - [ ] Test Coverage Check
  - [ ] Pattern Analysis

### Step C: Conflict Detection
- [ ] Section exists: "Step C: Conflict Detection (Refactor Focus)"
- [ ] Conflict type 1: Refactoring vs Callers
- [ ] Conflict type 2: Refactoring vs Behavior Preservation
- [ ] Conflict type 3: Refactoring vs Parallel Work
- [ ] git log command mentioned
- [ ] AskUserQuestion for resolution mentioned

### Step D: Edge Case Generation
- [ ] Section exists: "Step D: Edge Case Generation (Refactor Focus)"
- [ ] Behavioral Equivalence Cases mentioned
- [ ] New Pattern Cases mentioned
- [ ] Regression Cases mentioned

### Output Section
- [ ] Contains original 7 SPEC.md components:
  - [ ] Target
  - [ ] Current Problems
  - [ ] Goal State
  - [ ] Behavior Change Policy
  - [ ] Test Coverage
  - [ ] Dependencies
  - [ ] XP Principle Reference
- [ ] Contains new "Analysis Results" component:
  - [ ] Related Code (dependency map)
  - [ ] Conflicts Identified
  - [ ] Edge Cases (3 types)
  - [ ] Test Coverage Assessment

### Workflow Integration
- [ ] Section exists at end of file
- [ ] References to init-workflow.md present
- [ ] Refactoring Safety Notes subsection present:
  - [ ] Low test coverage warning
  - [ ] Complex dependency warning
  - [ ] Behavior preservation note

## Cross-Reference Tests
- [ ] `_shared/analysis-phases.md` reference is relative path
- [ ] `_shared/init-workflow.md` reference is relative path

## Backwards Compatibility
- [ ] Steps 1-6 (question steps) unchanged
- [ ] Existing YAML frontmatter unchanged
- [ ] Trigger section unchanged
- [ ] Branch Keyword section unchanged
