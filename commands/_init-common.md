---
description: Common init workflow - branch creation, analysis phases, and shared utilities for all init commands.
user-invocable: false
---
# Init Common Workflow

Shared workflow steps for all init commands (`init-feature`, `init-bugfix`, `init-refactor`, `init-github-issue`).

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

---

## Branch Creation -- MANDATORY

After gathering requirements (or using pre-filled values from GitHub issue), create the work branch using `git worktree add`. This step is MANDATORY.

**MUST**: Use `git worktree add` as shown below. **NEVER** use `git checkout -b`, `git switch -c`, or any other branch creation method as a substitute.

### Steps

1. Auto-generate branch keyword from the work description
2. Update base branch: `git checkout {base_branch} && git pull origin {base_branch}`
3. Create work branch via worktree: `git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}`
   - `{project_name}`: name of the current git repository root directory
   - `{type}`: work type prefix (`feature`, `bugfix`, `refactor`)
   - Worktree naming rule: `{project_name}-{type}-{keyword}` (e.g., `dotclaude-feature-user-auth`)
4. **Verify worktree creation**: Run `ls ../{project_name}-{type}-{keyword}` and confirm the directory exists. If the directory does not exist, the worktree creation failed -- report the error immediately. Do NOT silently fall back to `git checkout -b`.
5. Change into worktree directory: `cd ../{project_name}-{type}-{keyword}`
6. Create project directory: `mkdir -p {working_directory}/{subject}`

### Naming Examples

| Work Type | Branch Name | Worktree Path |
|-----------|-------------|---------------|
| Feature | `feature/user-auth` | `../dotclaude-feature-user-auth` |
| Bugfix | `bugfix/login-crash` | `../dotclaude-bugfix-login-crash` |
| Refactor | `refactor/api-cleanup` | `../dotclaude-refactor-api-cleanup` |

---

## Analysis Phases

Execute after gathering requirements and creating the work branch, before creating SPEC.md.

### Iteration Limits

| Limit Type | Maximum |
|------------|---------|
| Input clarification | 5 questions per category |
| Clarification loop | 3 iterations |
| Codebase search | 10 file reads |

---

### Step A: Input Analysis

Analyze collected user answers for completeness and clarity.

#### Detection Targets

| Issue Type | Examples | Action |
|------------|----------|--------|
| Vague descriptions | "improve", "better", "fix", "enhance" | Ask for specific metrics/criteria |
| Missing scope | No clear boundaries defined | Ask what's explicitly excluded |
| Implicit assumptions | Assumed tech stack, user type | Ask to confirm assumptions |
| Conflicting statements | A contradicts B in answers | Ask user to clarify |

#### Process

1. Review all collected answers from question phase
2. For each issue found, generate clarifying question
3. Batch related questions (max 5 per category)
4. Use AskUserQuestion:

```
Question: "Please clarify the following: {issue_description}"
Header: "Additional Information Required"
Options:
  - label: "{specific_option_1}"
    description: "{description_1}"
  - label: "{specific_option_2}"
    description: "{description_2}"
  - label: "Other"
    description: "Enter manually"
```

---

### Step B: Codebase Investigation

Search codebase for related code. Work-type-specific details in each init file.

#### Common Process

1. Extract keywords from user requirements
2. Use Grep tool to search for related code
3. Use Read tool to examine relevant files (max 10 reads)
4. Document findings

#### Output Format

```markdown
### Related Code
| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | path/to/file.ts | 42 | Similar functionality exists |
| 2 | path/to/other.ts | 100 | Will need modification |
```

#### Work-Type Specifics

- **Feature**: See init-feature.md - focus on similar functionality, patterns
- **Bugfix**: See init-bugfix.md - focus on root cause, affected code
- **Refactor**: See init-refactor.md - focus on dependencies, test coverage

---

### Step C: Conflict Detection

Compare requirements against existing implementation.

#### Conflict Types

| Type | Check For |
|------|-----------|
| API signature | New API conflicts with existing signatures |
| Data model | Schema changes affect existing data |
| Behavioral | New behavior contradicts current behavior |

#### Process

For each potential conflict:
1. Document existing behavior
2. Document required behavior
3. Present to user via AskUserQuestion:

```
Question: "A conflict with existing behavior was found. How should we handle this?"
Header: "Conflict Resolution"
Options:
  - label: "Prioritize new behavior"
    description: "Existing: {existing}. Change to new requirement"
  - label: "Preserve existing"
    description: "Keep existing behavior and modify requirement"
  - label: "Support both"
    description: "Support both behaviors for compatibility"
```

#### Output Format

```markdown
### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | Returns null on error | Should throw exception | Throw exception (user decision) |
```

---

### Step D: Edge Case Generation

Generate boundary conditions and error scenarios.

#### Case Categories

| Category | Examples |
|----------|----------|
| Boundary | Empty input, max size, min value |
| Error | Operation fails, network timeout, invalid input |
| Null/Empty | Null parameters, empty collections |
| Concurrent | Race conditions, parallel access (if applicable) |

#### Process

1. Based on requirements, generate 5-10 edge cases
2. Present to user via AskUserQuestion:

```
Question: "Please review the following edge cases."
Header: "Edge Case Review"
Options:
  - label: "Approve All"
    description: "Include all listed cases"
  - label: "Need Additions"
    description: "Need to add or modify cases (enter details)"
```

#### Output Format

```markdown
### Edge Cases
| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Empty input | Return empty result |
| 2 | Input exceeds max size | Throw validation error |
| 3 | Concurrent modification | Last write wins / Queue updates |
```

---

### Step E: Summary + Clarification

Present complete analysis summary and allow user refinement.

#### Summary Components

1. **Collected Requirements**: Brief recap of user's answers
2. **Analysis Findings**: Related code found
3. **Conflicts + Resolutions**: Documented decisions
4. **Edge Cases**: Confirmed test scenarios

#### Process

```
iteration = 0
while iteration < 3:
    present_summary()

    AskUserQuestion:
      question: "Is there anything to add or modify?"
      header: "Final Confirmation"
      options:
        - label: "None - Proceed with SPEC generation"
          description: "Analysis is complete"
        - label: "Yes - Needs revision"
          description: "Please enter your revisions"

    if user_selects("None"):
        break
    else:
        collect_feedback()
        update_analysis()
        iteration += 1

if iteration == 3:
    proceed_to_spec_with_current_analysis()
```

---

## Analysis Results Template

Include in SPEC.md after executing all analysis phases:

```markdown
## Analysis Results

### Related Code
| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | path/to/file.ts | 42 | Contains similar functionality |

### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | API returns X | User expects Y | Use Y, deprecate X |

### Edge Cases
| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Empty input | Return empty result |
| 2 | Max size exceeded | Throw ValidationError |
```

---

## Skip Conditions

Analysis phases can be partially skipped if:

| Condition | Skip |
|-----------|------|
| User explicitly says "skip analysis" | All phases |
| No codebase exists (new project) | Step B only |
| Simple change (< 10 lines estimate) | Step D can be minimal |

When skipping, document in SPEC.md: "Analysis skipped: {reason}"
