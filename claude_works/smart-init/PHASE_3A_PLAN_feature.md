# Phase 3A: Enhance Init-Feature with Analysis

## Objective
Modify `.claude/skills/init-feature/SKILL.md` to include analysis phases and generate comprehensive SPEC.md.

## Prerequisites
- Phase 1 completed (workflow updated)
- Phase 2 completed (analysis-phases.md exists)

## Instructions

### Step 1: Add Analysis Reference
After "Step 8: 범위 제외" section, add:

```markdown
## Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-8), execute analysis phases.

See `_shared/analysis-phases.md` for detailed instructions.

### Feature-Specific Analysis

#### Step B: Codebase Investigation (Feature Focus)
For new features, focus on:
1. **Similar Functionality Search**
   - Grep for keywords from user's goal (Step 1)
   - Look for existing implementations that overlap

2. **Modification Points**
   - Identify files that need modification
   - Find integration points (APIs, events, hooks)

3. **Pattern Discovery**
   - Find existing patterns to follow (naming conventions, file structure)
   - Identify shared utilities to reuse
```

### Step 2: Update Branch Keyword Section
Move "Branch Keyword" section after Analysis Phase section.

### Step 3: Update Output Section
Modify the Output section to include Analysis Results:

```markdown
## Output

1. Feature branch `feature/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with:
   - Overview (from Steps 1-2)
   - Functional Requirements (from Steps 3-4)
   - Non-Functional Requirements (from Steps 6-7)
   - Constraints (from Step 5)
   - Out of Scope (from Step 8)
   - **Analysis Results** (from Analysis Phase):
     - Related Code (existing similar functionality)
     - Conflicts Identified (with resolutions)
     - Edge Cases (confirmed by user)
```

### Step 4: Add Workflow Integration Note
Add at the end:

```markdown
## Workflow Integration

After Analysis Phase completes:
1. Analysis results are included in SPEC.md
2. SPEC.md is committed (Step 6 in init-workflow)
3. User reviews SPEC.md (Step 7)
4. Next Step Selection (Step 8)

See `_shared/init-workflow.md` for complete workflow.
```

## Completion Checklist
- [ ] Analysis Phase section added after Step 8
- [ ] Feature-specific analysis instructions included
- [ ] Reference to `_shared/analysis-phases.md` present
- [ ] Branch Keyword section repositioned
- [ ] Output section updated with Analysis Results
- [ ] Workflow Integration section added

## Notes
- init-feature currently has NO codebase analysis
- This phase adds full analysis capability
- Feature analysis focuses on finding similar functionality and patterns
