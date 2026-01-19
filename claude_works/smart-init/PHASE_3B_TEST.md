# Phase 3B: Test Cases

## Test Coverage Target
100% of modified sections verified

## File Location Test
- [ ] File modified: `.claude/skills/init-bugfix/SKILL.md`

## Section Tests

### Analysis Phase Header
- [ ] Header changed to "Analysis Phase (MANDATORY)"
- [ ] Reference to `_shared/analysis-phases.md` exists
- [ ] "CRITICAL" keyword preserved

### Step B: Codebase Investigation
- [ ] Section title: "Step B: Codebase Investigation (Bugfix - Enhanced)"
- [ ] Case 1 (user specified files) preserved:
  - [ ] Read tool usage
  - [ ] Pattern matching
  - [ ] Code identification
- [ ] Case 2 (unknown files) preserved:
  - [ ] Task tool with Explore agent
  - [ ] Search pattern list
- [ ] New "Recent Change Analysis" subsection:
  - [ ] git log command mentioned
  - [ ] Regression source documentation

### Step C: Conflict Detection
- [ ] Section exists: "Step C: Conflict Detection (Bugfix Focus)"
- [ ] Conflict type 1: Proposed fix vs other code paths
- [ ] Conflict type 2: Proposed fix vs recent changes
- [ ] AskUserQuestion for resolution mentioned

### Step D: Edge Case Generation
- [ ] Section exists: "Step D: Edge Case Generation (Bugfix Focus)"
- [ ] Reproduction variations mentioned
- [ ] Boundary conditions mentioned
- [ ] Regression prevention cases mentioned

### Required Analysis Outputs
- [ ] Original items preserved:
  - [ ] Root Cause
  - [ ] Affected Code Locations
  - [ ] Fix Strategy
- [ ] New items added:
  - [ ] Conflict Analysis
  - [ ] Edge Cases

### Output Section
- [ ] AI Analysis Results section updated
- [ ] Contains "Recent change correlation"
- [ ] Contains "Conflict Analysis"
- [ ] Contains "Edge Cases"

## Backwards Compatibility
- [ ] Steps 1-6 (question steps) unchanged
- [ ] YAML frontmatter unchanged
- [ ] Trigger section unchanged
- [ ] Branch Keyword section unchanged

## Integration Tests
- [ ] Inconclusive Analysis Handling section still present
- [ ] Workflow Summary section still present
