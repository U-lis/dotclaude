# Phase 3C: Enhance Init-Refactor with Analysis

## Objective
Modify `.claude/skills/init-refactor/SKILL.md` to include comprehensive codebase analysis for refactoring work.

## Prerequisites
- Phase 1 completed (workflow updated)
- Phase 2 completed (analysis-phases.md exists)

## Instructions

### Step 1: Add Analysis Phase Section
After "Step 6: 의존 모듈" section, add:

```markdown
## Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-6), execute analysis phases.

See `_shared/analysis-phases.md` for detailed instructions.

### Refactor-Specific Analysis

#### Step B: Codebase Investigation (Refactor Focus)

1. **Target Code Analysis**
   - Read target files specified in Step 1
   - Analyze current structure and identify code smells
   - Document current behavior for preservation

2. **Usage Analysis**
   - Grep for all usages of target code (functions, classes, modules)
   - Build dependency graph: who calls this? what does this call?
   - Identify all affected modules

3. **Test Coverage Check**
   - Find existing tests for target code
   - Assess coverage level
   - Identify missing test cases needed before refactoring

4. **Pattern Analysis**
   - Identify current patterns in use
   - Compare against codebase conventions
   - Document target patterns for refactoring

Output: Dependency map and coverage assessment
```

### Step 2: Add Conflict Detection
Add new subsection:

```markdown
### Step C: Conflict Detection (Refactor Focus)

For refactoring, detect conflicts between:

1. **Refactoring vs Callers**
   - Will signature changes break callers?
   - Are there external dependencies (other packages, APIs)?

2. **Refactoring vs Behavior Preservation**
   - If "동작 유지 필수" selected: verify behavior can be preserved
   - Identify behavioral changes that would require user approval

3. **Refactoring vs Parallel Work**
   - Check for other branches modifying same files
   - Run: `git log --all --oneline -- {target_file}`

Document all conflicts and get user resolution via AskUserQuestion.
```

### Step 3: Add Edge Case Generation
Add new subsection:

```markdown
### Step D: Edge Case Generation (Refactor Focus)

Generate edge cases for refactored code:

1. **Behavioral Equivalence Cases**
   - Cases that verify old and new behavior match
   - Critical paths that must work identically

2. **New Pattern Cases**
   - Cases that exercise new code structure
   - Cases that validate improved design

3. **Regression Cases**
   - Cases from existing bugs or known issues
   - Cases that ensure old problems don't resurface

Present to user for confirmation.
```

### Step 4: Update Output Section
Add Analysis Results to output:

```markdown
## Output

1. Refactor branch `refactor/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with refactor-specific format:
   - Target (from Step 1)
   - Current Problems (from Step 2)
   - Goal State (from Step 3)
   - Behavior Change Policy (from Step 4)
   - Test Coverage (from Step 5)
   - Dependencies (from Step 6)
   - XP Principle Reference (auto-added based on problems)
   - **Analysis Results**:
     - Related Code (dependency map)
     - Conflicts Identified (with resolutions)
     - Edge Cases (behavioral equivalence, new pattern, regression)
     - Test Coverage Assessment
```

### Step 5: Add Workflow Integration Note
Add at end:

```markdown
## Workflow Integration

After Analysis Phase completes:
1. Analysis results are included in SPEC.md
2. SPEC.md is committed
3. User reviews SPEC.md
4. Next Step Selection

See `_shared/init-workflow.md` for complete workflow.

### Refactoring Safety Notes

- If test coverage is low: recommend writing tests BEFORE refactoring
- If dependency graph is complex: suggest incremental refactoring phases
- If behavior preservation is critical: require approval for any behavioral change
```

## Completion Checklist
- [ ] Analysis Phase section added after Step 6
- [ ] Refactor-specific analysis instructions included:
  - [ ] Target Code Analysis
  - [ ] Usage Analysis (dependency graph)
  - [ ] Test Coverage Check
  - [ ] Pattern Analysis
- [ ] Step C: Conflict Detection section added
- [ ] Step D: Edge Case Generation section added
- [ ] Reference to `_shared/analysis-phases.md` present
- [ ] Output section updated with Analysis Results
- [ ] Workflow Integration section added with safety notes

## Notes
- init-refactor currently has NO codebase analysis
- This phase adds comprehensive dependency and coverage analysis
- Refactor analysis emphasizes safety: test coverage, behavior preservation
