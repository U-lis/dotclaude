---
description: Initialize bug fix work through bug detail gathering and root cause analysis.
user-invocable: false
---
# init-bugfix Instructions

Instructions for initializing bug fix work through bug detail gathering and root cause analysis.

## Pre-filled Data Handling

When invoked from `init-github-issue.md`, a `pre_filled` context may be provided containing data extracted from the GitHub issue. For each step below, check whether the corresponding `pre_filled` key exists and is non-empty. If it does, SKIP the step and use the pre-filled value. If it does not exist, or is an empty string, ask the question normally.

When no `pre_filled` context is available (direct init without GitHub issue), all questions are asked normally.

| Pre-filled Key | Step | Question |
|----------------|------|----------|
| `pre_filled.symptoms` | Step 1 | Symptoms |
| `pre_filled.reproduction_steps` | Step 2 | Reproduction Steps |
| `pre_filled.expected_cause` | Step 3 | Expected Cause |
| `pre_filled.severity` | Step 4 | Severity |
| `pre_filled.related_files` | Step 5 | Related Files |
| `pre_filled.impact_scope` | Step 6 | Impact Scope |

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: Symptoms

**Pre-fill Check**: IF `pre_filled.symptoms` exists and is non-empty, SKIP this step and use the pre-filled value as the bug symptom description. Otherwise, proceed with the question below.

```
Question: "What bug/problem is occurring?"
Header: "Bug Symptoms"
> Free text (symptom description)
```

### Step 2: Reproduction Steps

**Pre-fill Check**: IF `pre_filled.reproduction_steps` exists and is non-empty, SKIP this step and use the pre-filled value as the reproduction steps. Otherwise, proceed with the question below.

```
Question: "Are there conditions or steps to reproduce this bug?"
Header: "Reproduction Steps"
> Free text (reproduction steps)
```

### Step 3: Expected Cause

**Pre-fill Check**: IF `pre_filled.expected_cause` exists and is non-empty, SKIP this step and use the pre-filled value as the expected cause. Otherwise, proceed with the question below.

```
Question: "Do you have any expected causes?"
Header: "Expected Cause"
Options:
  - label: "Suspect specific code"
    description: "Suspect specific file or function as the cause"
  - label: "External dependency issue"
    description: "Issue related to library or external service"
  - label: "Configuration error"
    description: "Environment setup or config issue"
  - label: "Unknown"
    description: "Need to investigate the cause"
multiSelect: false
```

### Step 4: Severity

**Pre-fill Check**: IF `pre_filled.severity` exists and is non-empty, SKIP this step and use the pre-filled value as the severity level. Otherwise, proceed with the question below.

```
Question: "How severe is this bug?"
Header: "Severity"
Options:
  - label: "Critical"
    description: "Service unavailable or risk of data loss"
  - label: "Major"
    description: "Core functionality failure"
  - label: "Minor"
    description: "Inconvenient but workaround available"
  - label: "Trivial"
    description: "Minor issue"
multiSelect: false
```

### Step 5: Related Files

**Pre-fill Check**: IF `pre_filled.related_files` exists and is non-empty, SKIP this step and use the pre-filled value as the related files. Otherwise, proceed with the question below.

```
Question: "Do you know any related files or modules?"
Header: "Related Files"
Options:
  - label: "Unknown"
    description: "Investigation needed"
> Or free text via "Other" (enter file path)
```

### Step 6: Impact Scope

**Pre-fill Check**: IF `pre_filled.impact_scope` exists and is non-empty, SKIP this step and use the pre-filled value as the impact scope. Otherwise, proceed with the question below.

```
Question: "Are there other features affected by this bug?"
Header: "Impact Scope"
Options:
  - label: "None/Unknown"
    description: "No effect on other features or investigation needed"
> Or free text via "Other"
```

---

## Analysis Phase

**MANDATORY**: After gathering user input (Steps 1-6), execute analysis phases.

Follow the `_analysis` command for the common analysis workflow (Steps A-E). Claude will auto-load the command content.

### Bugfix-Specific Analysis

#### Step B: Codebase Investigation (Bugfix - Enhanced)

##### Case 1: User specified related files (Step 5)
1. Use Read tool to analyze the specified files
2. Search for code patterns matching described symptoms
3. Identify the exact code causing the bug

##### Case 2: User said "Unknown" (unknown files)
1. Use Task tool with Explore agent to search codebase
2. Search patterns based on:
   - Error messages from Step 1
   - Keywords from symptom description
   - Function/class names if mentioned
3. Narrow down to relevant files

##### Additional: Recent Change Analysis
- Run `git log -20 --oneline -- {affected_file}` for affected files
- Check if bug correlates with recent commits
- Document potential regression sources

#### Step C: Conflict Detection (Bugfix Focus)

For bugfixes, detect conflicts between:

1. **Proposed fix vs other code paths**
   - Will fixing this break other functionality?
   - Are there callers depending on current (buggy) behavior?

2. **Proposed fix vs recent changes**
   - Does fix conflict with recent refactoring?
   - Are parallel bug fixes in progress?

Document all conflicts and get user resolution via AskUserQuestion.

#### Step D: Edge Case Generation (Bugfix Focus)

Generate edge cases specifically for the bug:
1. Variations of the reproduction steps
2. Boundary conditions that might trigger same bug
3. Related scenarios that should NOT trigger the bug (regression prevention)

Present to user for confirmation.

---

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

4. **Conflict Analysis**:
   - Conflicts with existing code paths
   - Conflicts with recent changes
   - User resolutions for each conflict

5. **Edge Cases**:
   - Reproduction variations
   - Boundary conditions
   - Regression prevention cases

---

### Inconclusive Analysis Handling

If analysis cannot identify root cause:
- Document what was searched
- List possible causes with confidence levels
- Recommend further investigation steps
- Mark SPEC.md "Root Cause" as "Requires further investigation"

---

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core issue from answers (Steps 1-2)
- Format: `bugfix/{keyword}`
- Examples:
  - bugfix/wrong-script-path
  - bugfix/null-pointer-exception
  - bugfix/login-timeout

---

## SPEC.md Content

Create SPEC.md with bug-specific format:

### User-Reported Information
- Bug Description (from Step 1)
- Reproduction Steps (from Step 2)
- User's Expected Cause (from Step 3)
- Severity (from Step 4)
- Related Files (from Step 5)
- Impact Scope (from Step 6)

### AI Analysis Results
- Root Cause Analysis (from codebase investigation)
  - Exact code location (file:line)
  - Why the bug occurs
  - Recent change correlation (if any)
- Affected Code Locations (files and functions to modify)
- Fix Strategy (concrete modification plan)
- **Conflict Analysis** (conflicts and resolutions)
- **Edge Cases** (for test coverage)

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD (Domain-Driven Design) when context is needed.
- **Clarification Required**: If there are unclear parts or decisions needed, report them and wait for user confirmation.

---

## Output

1. Bugfix worktree created at `../{project_name}-bugfix-{keyword}` with branch `bugfix/{keyword}`
2. Directory `{working_directory}/{subject}/` created
3. `{working_directory}/{subject}/SPEC.md` created with all sections above

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
