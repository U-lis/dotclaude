# Phase 2: Test Cases

## Test Coverage Target
100% of analysis phases documented

## File Structure Tests
- [ ] File exists at `.claude/skills/_shared/analysis-phases.md`
- [ ] File has proper markdown structure with headers

## Content Tests

### Header Section
- [ ] Document title present
- [ ] Iteration limits documented:
  - [ ] Input clarification: max 5
  - [ ] Clarification loop: max 3
  - [ ] Codebase search: max 10

### Step A: Input Analysis
- [ ] Section header exists
- [ ] Vague description detection explained
- [ ] Missing scope boundary detection explained
- [ ] Implicit assumption detection explained
- [ ] AskUserQuestion usage with min 2 options

### Step B: Codebase Investigation
- [ ] Section header exists
- [ ] Feature-specific instructions present
- [ ] Bugfix-specific instructions present
- [ ] Refactor-specific instructions present
- [ ] Max 10 file reads limit mentioned
- [ ] Output format documented

### Step C: Conflict Detection
- [ ] Section header exists
- [ ] Conflict types listed (API, data model, behavioral)
- [ ] Resolution workflow explained
- [ ] AskUserQuestion usage with min 2 options
- [ ] Output table format documented

### Step D: Edge Case Generation
- [ ] Section header exists
- [ ] Case types listed:
  - [ ] Boundary conditions
  - [ ] Error scenarios
  - [ ] Null/empty cases
  - [ ] Concurrent access
- [ ] User confirmation workflow
- [ ] Output table format documented

### Step E: Summary + Clarification
- [ ] Section header exists
- [ ] Summary components listed
- [ ] Question text: "추가하거나 수정할 내용이 있나요?"
- [ ] Options include "없음" and "있음"
- [ ] Iteration limit (max 3) enforced

### Analysis Results Template
- [ ] Related Code table template
- [ ] Conflicts Identified table template
- [ ] Edge Cases table template

## AskUserQuestion Compliance
- [ ] All AskUserQuestion examples have at least 2 options
- [ ] Options have label and description fields
