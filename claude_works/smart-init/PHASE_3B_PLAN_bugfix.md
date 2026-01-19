# Phase 3B: Enhance Init-Bugfix with Analysis

## Objective
Modify `.claude/skills/init-bugfix/SKILL.md` to enhance existing analysis with conflict detection and edge case generation.

## Prerequisites
- Phase 1 completed (workflow updated)
- Phase 2 completed (analysis-phases.md exists)

## Instructions

### Step 1: Update Codebase Analysis Section Header
Change "Codebase Analysis (MANDATORY)" to integrate with new analysis framework:

```markdown
## Analysis Phase (MANDATORY)

**CRITICAL**: After gathering user input (Steps 1-6), execute analysis phases.

See `_shared/analysis-phases.md` for detailed instructions. Bugfix has additional requirements below.
```

### Step 2: Keep Existing Analysis Flow
Preserve the existing "Analysis Flow" subsection content but restructure:

```markdown
### Step B: Codebase Investigation (Bugfix - Enhanced)

#### Case 1: User specified related files (Step 5)
1. Use Read tool to analyze the specified files
2. Search for code patterns matching described symptoms
3. Identify the exact code causing the bug

#### Case 2: User said "모름" (unknown files)
1. Use Task tool with Explore agent to search codebase
2. Search patterns based on:
   - Error messages from Step 1
   - Keywords from symptom description
   - Function/class names if mentioned
3. Narrow down to relevant files

#### Additional: Recent Change Analysis
- Run `git log -20 --oneline` for affected files
- Check if bug correlates with recent commits
- Document potential regression sources
```

### Step 3: Add Conflict Detection
Add new subsection after Codebase Investigation:

```markdown
### Step C: Conflict Detection (Bugfix Focus)

For bugfixes, detect conflicts between:
1. **Proposed fix vs other code paths**
   - Will fixing this break other functionality?
   - Are there callers depending on current (buggy) behavior?

2. **Proposed fix vs recent changes**
   - Does fix conflict with recent refactoring?
   - Are parallel bug fixes in progress?

Document all conflicts and get user resolution via AskUserQuestion.
```

### Step 4: Add Edge Case Generation
Add new subsection:

```markdown
### Step D: Edge Case Generation (Bugfix Focus)

Generate edge cases specifically for the bug:
1. Variations of the reproduction steps
2. Boundary conditions that might trigger same bug
3. Related scenarios that should NOT trigger the bug (regression prevention)

Present to user for confirmation.
```

### Step 5: Update Required Analysis Outputs
Modify "Required Analysis Outputs" to include new outputs:

```markdown
### Required Analysis Outputs

Document the following (all required):

1. **Root Cause**:
   - Exact code location (file:line)
   - Why the bug occurs (code-level explanation)
   - Difference from user's expected cause (if any)

2. **Affected Code Locations**:
   - List of files requiring modification
   - Specific functions/methods to change

3. **Fix Strategy**:
   - Concrete modification plan
   - Expected behavior after fix

4. **Conflict Analysis** (NEW):
   - Conflicts with existing code paths
   - Conflicts with recent changes
   - User resolutions for each conflict

5. **Edge Cases** (NEW):
   - Reproduction variations
   - Boundary conditions
   - Regression prevention cases
```

### Step 6: Update Output Section
Modify output section to include enhanced analysis:

```markdown
### AI Analysis Results
- Root Cause Analysis (from codebase investigation)
  - Exact code location (file:line)
  - Why the bug occurs
  - Recent change correlation (if any)
- Affected Code Locations (files and functions to modify)
- Fix Strategy (concrete modification plan)
- **Conflict Analysis** (conflicts and resolutions)
- **Edge Cases** (for test coverage)
```

## Completion Checklist
- [ ] Analysis Phase header updated with reference to shared file
- [ ] Existing Case 1/Case 2 analysis preserved
- [ ] Recent Change Analysis added (git log check)
- [ ] Step C: Conflict Detection section added
- [ ] Step D: Edge Case Generation section added
- [ ] Required Analysis Outputs updated with 2 new items
- [ ] Output section updated with Conflict Analysis and Edge Cases
- [ ] Reference to `_shared/analysis-phases.md` present

## Notes
- init-bugfix already has codebase analysis; this phase ENHANCES it
- Must preserve existing analysis logic while adding new capabilities
- Bugfix analysis is more focused on root cause and regression prevention
