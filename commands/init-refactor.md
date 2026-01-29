---
description: Initialize refactoring work through target analysis and dependency mapping.
user-invocable: false
---
# init-refactor Instructions

Instructions for initializing refactoring work through target analysis and dependency mapping.

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: Target
```
Question: "What is the refactoring target?"
Header: "Refactoring Target"
> Free text (file, module, class, function, etc.)
```

### Step 2: Problems
```
Question: "What problems exist in the current code?"
Header: "Problems"
Options:
  - label: "Duplicate code (DRY violation)"
    description: "Same logic repeated in multiple places"
  - label: "Long method/class (SRP violation)"
    description: "One unit has too many responsibilities"
  - label: "Complex conditionals"
    description: "if/switch statements are deeply nested"
  - label: "High coupling"
    description: "Dependencies between modules are too high"
  - label: "Testing difficulty"
    description: "Difficult to write unit tests"
multiSelect: true
```

### Step 3: Goal State
```
Question: "What is the expected state after refactoring?"
Header: "Goal"
> Free text (target architecture, patterns, etc.)
```

### Step 4: Behavior Change
```
Question: "Is it okay if the existing behavior changes?"
Header: "Behavior Change"
Options:
  - label: "Preserve behavior (required)"
    description: "Pure refactoring, no functional changes"
  - label: "Some changes allowed"
    description: "Allow behavior changes for improvement"
multiSelect: false
```

### Step 5: Test Status
```
Question: "Are there related tests?"
Header: "Tests"
Options:
  - label: "Yes"
    description: "Test coverage is secured"
  - label: "Partial"
    description: "Tests exist partially"
  - label: "No"
    description: "Tests need to be written first"
multiSelect: false
```

### Step 6: Dependencies
```
Question: "Are there other modules that use this code?"
Header: "Dependencies"
Options:
  - label: "None/Unknown"
    description: "Not used by other modules or needs investigation"
> Or free text via "Other"
```

---

## Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-6), execute analysis phases.

Follow the `_analysis` command for the common analysis workflow (Steps A-E). Claude will auto-load the command content.

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

#### Step C: Conflict Detection (Refactor Focus)

For refactoring, detect conflicts between:

1. **Refactoring vs Callers**
   - Will signature changes break callers?
   - Are there external dependencies (other packages, APIs)?

2. **Refactoring vs Behavior Preservation**
   - If "Preserve behavior (required)" selected: verify behavior can be preserved
   - Identify behavioral changes that would require user approval

3. **Refactoring vs Parallel Work**
   - Check for other branches modifying same files
   - Run: `git log --all --oneline -- {target_file}`

Document all conflicts and get user resolution via AskUserQuestion.

#### Step D: Edge Case Generation (Refactor Focus)

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

---

## Refactoring Safety Notes

- If test coverage is low: recommend writing tests BEFORE refactoring
- If dependency graph is complex: suggest incremental refactoring phases
- If behavior preservation is critical: require approval for any behavioral change

---

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core target from answers (Step 1)
- Format: `refactor/{keyword}`
- Examples:
  - refactor/user-service
  - refactor/extract-api-client
  - refactor/simplify-auth-flow

---

## SPEC.md Content

Create SPEC.md with refactor-specific format:

- **Target** (from Step 1)
- **Current Problems** (from Step 2)
- **Goal State** (from Step 3)
- **Behavior Change Policy** (from Step 4)
- **Test Coverage** (from Step 5)
- **Dependencies** (from Step 6)
- **XP Principle Reference** (auto-added based on problems)
- **Analysis Results**:
  - Related Code (dependency map)
  - Conflicts Identified (with resolutions)
  - Edge Cases (behavioral equivalence, new pattern, regression)
  - Test Coverage Assessment

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD (Domain-Driven Design) when context is needed.
- **Clarification Required**: If there are unclear parts or decisions needed, report them and wait for user confirmation.

---

## Output

1. Refactor branch `refactor/{keyword}` created and checked out
2. Directory `{working_directory}/{subject}/` created
3. `{working_directory}/{subject}/SPEC.md` created with all sections above
