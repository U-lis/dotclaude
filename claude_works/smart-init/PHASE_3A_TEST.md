# Phase 3A: Test Cases

## Test Coverage Target
100% of modified sections verified

## File Location Test
- [ ] File modified: `.claude/skills/init-feature/SKILL.md`

## Section Tests

### Analysis Phase Section
- [ ] "Analysis Phase" header exists after Step 8
- [ ] "MANDATORY" keyword present
- [ ] Reference to `_shared/analysis-phases.md` exists

### Feature-Specific Analysis
- [ ] "Feature-Specific Analysis" subsection exists
- [ ] "Step B: Codebase Investigation (Feature Focus)" subsection exists
- [ ] Similar Functionality Search instructions present
- [ ] Modification Points instructions present
- [ ] Pattern Discovery instructions present

### Branch Keyword Section
- [ ] Section exists after Analysis Phase section
- [ ] Format unchanged: `feature/{keyword}`

### Output Section
- [ ] Contains original 5 SPEC.md components:
  - [ ] Overview
  - [ ] Functional Requirements
  - [ ] Non-Functional Requirements
  - [ ] Constraints
  - [ ] Out of Scope
- [ ] Contains new "Analysis Results" component:
  - [ ] Related Code mentioned
  - [ ] Conflicts Identified mentioned
  - [ ] Edge Cases mentioned

### Workflow Integration
- [ ] Section exists at end of file
- [ ] References to init-workflow.md steps correct
- [ ] Step numbers match updated workflow (6, 7, 8)

## Cross-Reference Tests
- [ ] `_shared/analysis-phases.md` reference is relative path
- [ ] `_shared/init-workflow.md` reference is relative path

## Backwards Compatibility
- [ ] Steps 1-8 (question steps) unchanged
- [ ] Existing YAML frontmatter unchanged
- [ ] Trigger section unchanged
