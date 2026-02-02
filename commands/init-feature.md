---
description: Initialize new feature work through requirements gathering and SPEC creation.
user-invocable: false
---
# init-feature Instructions

Instructions for initializing new feature work through requirements gathering and SPEC creation.

## Pre-filled Data Handling

When invoked from `init-github-issue.md`, a `pre_filled` context may be provided containing data extracted from the GitHub issue. For each step below, check whether the corresponding `pre_filled` key exists and is non-empty. If it does, SKIP the step and use the pre-filled value. If it does not exist, or is an empty string, ask the question normally.

When no `pre_filled` context is available (direct init without GitHub issue), all questions are asked normally.

| Pre-filled Key | Step | Question |
|----------------|------|----------|
| `pre_filled.goal` | Step 1 | Goal |
| `pre_filled.problem` | Step 2 | Problem |
| `pre_filled.core_features` | Step 3 | Core Features |
| `pre_filled.additional_features` | Step 4 | Additional Features |
| `pre_filled.technical_constraints` | Step 5 | Technical Constraints |
| `pre_filled.performance` | Step 6 | Performance |
| `pre_filled.security` | Step 7 | Security |
| `pre_filled.out_of_scope` | Step 8 | Out of Scope |

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: Goal

**Pre-fill Check**: IF `pre_filled.goal` exists and is non-empty, SKIP this step and use the pre-filled value as the goal. Otherwise, proceed with the question below.

```
Question: "What is the main goal of this feature?"
Header: "Goal"
> Free text response
```

### Step 2: Problem

**Pre-fill Check**: IF `pre_filled.problem` exists and is non-empty, SKIP this step and use the pre-filled value as the problem description. Otherwise, proceed with the question below.

```
Question: "What problem are you trying to solve?"
Header: "Problem"
> Free text response
```

### Step 3: Core Features

**Pre-fill Check**: IF `pre_filled.core_features` exists and is non-empty, SKIP this step and use the pre-filled value as the core features list. Otherwise, proceed with the question below.

```
Question: "What core features are required?"
Header: "Core Features"
> Free text (can list multiple)
```

### Step 4: Additional Features

**Pre-fill Check**: IF `pre_filled.additional_features` exists and is non-empty, SKIP this step and use the pre-filled value as the additional features. Otherwise, proceed with the question below.

```
Question: "Are there any nice-to-have but not required features?"
Header: "Additional Features"
Options:
  - label: "None"
    description: "Implement required features only"
> Or free text via "Other"
```

### Step 5: Technical Constraints

**Pre-fill Check**: IF `pre_filled.technical_constraints` exists and is non-empty, SKIP this step and use the pre-filled value as the technical constraints. Otherwise, proceed with the question below.

```
Question: "Are there any technical constraints?"
Header: "Technical Constraints"
Options:
  - label: "Specific language/framework required"
    description: "Specific tech stack required"
  - label: "Follow existing patterns"
    description: "Follow existing codebase patterns"
  - label: "No constraints"
    description: "Free to implement"
multiSelect: false
```

### Step 6: Performance Requirements

**Pre-fill Check**: IF `pre_filled.performance` exists and is non-empty, SKIP this step and use the pre-filled value as the performance requirements. Otherwise, proceed with the question below.

```
Question: "Are there any performance requirements?"
Header: "Performance"
Options:
  - label: "Yes"
    description: "Please enter details"
  - label: "None"
    description: "No specific performance requirements"
multiSelect: false
```

### Step 7: Security Considerations

**Pre-fill Check**: IF `pre_filled.security` exists and is non-empty, SKIP this step and use the pre-filled value as the security considerations. Otherwise, proceed with the question below.

```
Question: "Are there any security considerations?"
Header: "Security"
Options:
  - label: "Authentication/authorization required"
    description: "User authentication or permission verification required"
  - label: "Data encryption"
    description: "Sensitive data encryption required"
  - label: "Input validation"
    description: "User input validation required"
  - label: "None"
    description: "No specific security requirements"
multiSelect: true
```

### Step 8: Out of Scope

**Pre-fill Check**: IF `pre_filled.out_of_scope` exists and is non-empty, SKIP this step and use the pre-filled value as the out-of-scope items. Otherwise, proceed with the question below.

```
Question: "What should be explicitly excluded from scope?"
Header: "Out of Scope"
Options:
  - label: "None"
    description: "No items to exclude"
> Or free text via "Other"
```

---

## Branch Creation & Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-8), execute the common init workflow.

Follow the `_init-common` command for branch creation and analysis phases (Steps A-E). Claude will auto-load the command content.

### Feature-Specific Analysis

#### Step B: Codebase Investigation (Feature Focus)

For new features, focus on:

1. **Similar Functionality Search**
   - Grep for keywords from user's goal (Step 1)
   - Look for existing implementations that overlap
   - Document: "Similar feature found at {file}:{line}"

2. **Modification Points**
   - Identify files that need modification
   - Find integration points (APIs, events, hooks)
   - Document: "Integration required at {file}:{function}"

3. **Pattern Discovery**
   - Find existing patterns to follow (naming conventions, file structure)
   - Identify shared utilities to reuse
   - Document: "Follow pattern from {file}"

#### Step C: Conflict Detection (Feature Focus)

For features, check:
- Does new API conflict with existing API names?
- Does new data model conflict with existing schemas?
- Does new behavior contradict existing feature behavior?

#### Step D: Edge Case Generation (Feature Focus)

Generate cases for:
- New feature with empty/null inputs
- New feature at scale (many items, large data)
- New feature interaction with existing features

---

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core concept from answers (Steps 1-3)
- Format: `feature/{keyword}`
- Examples:
  - feature/external-api
  - feature/user-metrics
  - feature/step-by-step-init

---

## SPEC.md Content

After completing analysis, create SPEC.md with:

1. **Overview** (from Steps 1-2)
2. **Functional Requirements** (from Steps 3-4)
3. **Non-Functional Requirements** (from Steps 6-7)
4. **Constraints** (from Step 5)
5. **Out of Scope** (from Step 8)
6. **Analysis Results**:
   - Related Code (existing similar functionality)
   - Conflicts Identified (with resolutions)
   - Edge Cases (confirmed by user)

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD (Domain-Driven Design) when context is needed.
- **Clarification Required**: If there are unclear parts or decisions needed, report them and wait for user confirmation.

---

## Output

1. Feature worktree created at `../{project_name}-feature-{keyword}` with branch `feature/{keyword}`
2. Directory `{working_directory}/{subject}/` created
3. `{working_directory}/{subject}/SPEC.md` created with all sections above

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
