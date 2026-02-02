---
description: Initialize work from GitHub issue URL or number with auto-parsing.
user-invocable: false
---
# init-github-issue Instructions

Instructions for initializing work from GitHub issue URL or number.

**Requirements**: `gh` CLI must be installed and authenticated.

## Step-by-Step Process

### Step 1: Issue Input

Use AskUserQuestion tool:
```
Question: "Please enter GitHub issue URL or number"
Header: "GitHub Issue"
Options:
  - label: "URL format"
    description: "https://github.com/owner/repo/issues/123"
  - label: "Number format"
    description: "#123 (Based on current repository)"
> Free text via "Other"
```

**Input Parsing**:
- Full URL: Extract owner, repo, number from `https://github.com/{owner}/{repo}/issues/{number}`
- Number only: `#123` or `123` -> use current repository context

---

### Step 2: Issue Parsing

**Execute Command**:
```bash
# For full URL (external repo)
gh issue view {number} --repo {owner}/{repo} --json title,body,labels,milestone

# For issue number only (current repo)
gh issue view {number} --json title,body,labels,milestone
```

**Error Handling**:

| Error | Detection | Message |
|-------|-----------|---------|
| gh not installed | `command not found` | "gh CLI is not installed. Please install from https://cli.github.com/" |
| Not authenticated | `gh auth` error | "Please authenticate with gh auth login command" |
| Issue not found | GraphQL error / 404 | "Issue #{number} not found" |
| No access | 403 / permission error | "No access permission to issue" |
| Invalid URL | Regex mismatch | "Not a valid GitHub issue URL" |

**On Error**: Return to Step 1 of /dotclaude:start-new (work type selection)

---

### Step 3: Work Type Detection

**Algorithm**:

1. Extract label names from JSON response
2. Check for known labels (case-insensitive):

| Label | Work Type |
|-------|-----------|
| `bug` | bugfix |
| `enhancement` | feature |
| `refactor` | refactor |

3. If no label match found, analyze issue body for keywords:

**Body Analysis Keywords** (case-insensitive):

| Keywords | Work Type |
|----------|-----------|
| fix, bug, error, broken, crash, issue, problem | bugfix |
| add, new, feature, implement, support, enable | feature |
| refactor, clean, improve code, restructure, reorganize | refactor |

4. If still ambiguous (multiple matches or no match), ask user via AskUserQuestion:
```
Question: "Based on issue analysis, please confirm work type: {issue_title}"
Header: "Work Type Confirmation"
Options:
  - { label: "Add/Modify Feature", description: "New feature development or improve existing feature" }
  - { label: "Bug Fix", description: "Fix discovered bugs or errors" }
  - { label: "Refactoring", description: "Improve code structure without changing functionality" }
multiSelect: false
```

**Work Type Mapping from User Confirmation**:
- "Add/Modify Feature" -> feature
- "Bug Fix" -> bugfix
- "Refactoring" -> refactor

---

### Step 4: Context Extraction

From parsed issue, extract:

| Field | Variable | Usage |
|-------|----------|-------|
| Issue URL | `issue_url` | Reference in SPEC.md |
| Issue number | `issue_number` | Branch naming, PR linking |
| Issue title | `issue_title` | Branch keyword generation |
| Issue body | `issue_body` | Goal/problem description |
| Milestone title | `target_version` | Skip version question if present |
| Work type | `work_type` | Route to init file |

**Branch Keyword Generation**:
- Extract keywords from issue title (remove common words, special chars)
- Format: `{work_type}/{keyword}`
- Example: Issue #4 "fetch github issue and work" -> `feature/github-issue-fetch`

**Target Version Extraction**:
- If milestone exists: Extract version from milestone.title
- Handle formats: "v0.0.12", "0.0.12", "Release 0.0.12"
- If no milestone: `target_version = null` (will ask later)

**Deep Body Analysis**:

Beyond extracting `goal` and `problem`, analyze the full `issue_body` text to extract structured data for ALL init-xxx question fields applicable to the detected work type. This enables the downstream init file to auto-skip questions where confident extractions are available, reducing redundant user interaction.

General extraction rule: For each field below, scan the issue body for the described patterns. If a confident extraction is found, include the field in `pre_filled`. If not found or ambiguous, OMIT the field entirely (do not set to empty string).

**Feature heuristic table**:

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `goal` | Step 1: Goal | Issue title |
| `problem` | Step 2: Problem | First paragraph of issue body |
| `core_features` | Step 3: Core Features | Bulleted lists, "requirements", "must have", "core" sections |
| `additional_features` | Step 4: Additional Features | "Nice to have", "optional", "bonus" sections |
| `technical_constraints` | Step 5: Technical Constraints | "Constraints", "must use", "required stack" mentions |
| `performance` | Step 6: Performance | "Performance", "latency", "throughput", "SLA" mentions |
| `security` | Step 7: Security | "Security", "auth", "encryption", "validation" mentions |
| `out_of_scope` | Step 8: Out of Scope | "Out of scope", "not included", "excluded" sections |

**Bugfix heuristic table**:

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `symptoms` | Step 1: Symptoms | Issue title + first paragraph of body |
| `reproduction_steps` | Step 2: Reproduction Steps | "Steps to reproduce", numbered lists, "how to reproduce" sections |
| `expected_cause` | Step 3: Expected Cause | "Cause", "root cause", "suspect", "because" mentions |
| `severity` | Step 4: Severity | "Critical", "major", "minor", "trivial" keywords; label-based severity |
| `related_files` | Step 5: Related Files | File paths (e.g., `src/...`, `*.ts`), code blocks with filenames |
| `impact_scope` | Step 6: Impact Scope | "Affects", "impact", "related features" mentions |

**Refactor heuristic table**:

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `target` | Step 1: Target | Issue title, "target", "refactor" subject |
| `problems` | Step 2: Problems | "Problem", "issue", "code smell", DRY/SRP/coupling mentions |
| `goal_state` | Step 3: Goal State | "Goal", "expected result", "after refactoring" sections |
| `behavior_change` | Step 4: Behavior Change | "Breaking change", "preserve behavior", "no functional change" mentions |
| `test_status` | Step 5: Test Status | "Test", "coverage", "tested", "untested" mentions |
| `dependencies` | Step 6: Dependencies | "Depends on", "used by", "dependency", module references |

---

### Step 5: Route to Init File

Based on detected work_type, route to:

| Work Type | Init File | Branch Prefix |
|-----------|-----------|---------------|
| feature | `init-feature.md` | `feature/` |
| bugfix | `init-bugfix.md` | `bugfix/` |
| refactor | `init-refactor.md` | `refactor/` |

**Pre-populated Context**:

Pass the following to the init file. The `pre_filled` block varies by detected work type. Fields set to `null` are omitted from the actual context passed to the init file.

**Feature** (`init-feature.md`):
```yaml
github_issue:
  url: "{issue_url}"
  number: {issue_number}
  title: "{issue_title}"
  body: "{issue_body}"

pre_filled:
  goal: "{extracted or null}"
  problem: "{extracted or null}"
  core_features: "{extracted or null}"
  additional_features: "{extracted or null}"
  technical_constraints: "{extracted or null}"
  performance: "{extracted or null}"
  security: "{extracted or null}"
  out_of_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

**Bugfix** (`init-bugfix.md`):
```yaml
github_issue:
  url: "{issue_url}"
  number: {issue_number}
  title: "{issue_title}"
  body: "{issue_body}"

pre_filled:
  symptoms: "{extracted or null}"
  reproduction_steps: "{extracted or null}"
  expected_cause: "{extracted or null}"
  severity: "{extracted or null}"
  related_files: "{extracted or null}"
  impact_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

**Refactor** (`init-refactor.md`):
```yaml
github_issue:
  url: "{issue_url}"
  number: {issue_number}
  title: "{issue_title}"
  body: "{issue_body}"

pre_filled:
  target: "{extracted or null}"
  problems: "{extracted or null}"
  goal_state: "{extracted or null}"
  behavior_change: "{extracted or null}"
  test_status: "{extracted or null}"
  dependencies: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

**Init File Behavior with Pre-filled Context**:

1. **Branch Creation**: Use pre-filled `branch_keyword`, follow branch creation steps in the `_init-common` command (keyword is pre-filled, not auto-generated)

2. **Questions**: SKIP questions where `pre_filled` data is available
   - If a `pre_filled` key exists and is non-empty for a question, that question is auto-skipped
   - The pre-filled value is used directly without user confirmation
   - SPEC.md review (Step 3 of start-new.md) serves as the validation checkpoint

3. **Target Version**: If `target_version` is set
   - Skip Step 2.6 (version question)
   - Use milestone version directly

4. **SPEC.md**: Include issue reference
   - Add `**Source Issue**: {issue_url}` in header

**Field Mapping per Work Type**:

The following tables define which `pre_filled` keys map to which step in each init file.

**Feature** (`init-feature.md`):

| Pre-filled Key | Init File Step |
|----------------|----------------|
| `goal` | Step 1 |
| `problem` | Step 2 |
| `core_features` | Step 3 |
| `additional_features` | Step 4 |
| `technical_constraints` | Step 5 |
| `performance` | Step 6 |
| `security` | Step 7 |
| `out_of_scope` | Step 8 |

**Bugfix** (`init-bugfix.md`):

| Pre-filled Key | Init File Step |
|----------------|----------------|
| `symptoms` | Step 1 |
| `reproduction_steps` | Step 2 |
| `expected_cause` | Step 3 |
| `severity` | Step 4 |
| `related_files` | Step 5 |
| `impact_scope` | Step 6 |

**Refactor** (`init-refactor.md`):

| Pre-filled Key | Init File Step |
|----------------|----------------|
| `target` | Step 1 |
| `problems` | Step 2 |
| `goal_state` | Step 3 |
| `behavior_change` | Step 4 |
| `test_status` | Step 5 |
| `dependencies` | Step 6 |

---

## Analysis Phase

After context extraction, proceed to analysis phase as defined in init-{type}.md.

**Note**: The analysis phase should still run to verify requirements against codebase, but can reference issue_body for context.

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD when context is needed
- **Clarification Required**: If unclear parts or decisions needed, report and wait for user confirmation

---

## Output

1. Parsed GitHub issue data
2. Detected work type (feature/bugfix/refactor)
3. Pre-populated context for init workflow
4. Worktree created at `../{project_name}-{work_type}-{branch_keyword}` with branch `{work_type}/{branch_keyword}`
5. Route to appropriate init-xxx.md
6. Continue normal init workflow from there (with pre-filled values)

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
