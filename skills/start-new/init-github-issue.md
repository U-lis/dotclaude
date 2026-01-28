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
→ Free text via "Other"
```

**Input Parsing**:
- Full URL: Extract owner, repo, number from `https://github.com/{owner}/{repo}/issues/{number}`
- Number only: `#123` or `123` → use current repository context

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

**On Error**: Return to Step 1 of /dc:start-new (work type selection)

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
- "Add/Modify Feature" → feature
- "Bug Fix" → bugfix
- "Refactoring" → refactor

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
- Example: Issue #4 "fetch github issue and work" → `feature/github-issue-fetch`

**Target Version Extraction**:
- If milestone exists: Extract version from milestone.title
- Handle formats: "v0.0.12", "0.0.12", "Release 0.0.12"
- If no milestone: `target_version = null` (will ask later)

---

### Step 5: Route to Init File

Based on detected work_type, route to:

| Work Type | Init File | Branch Prefix |
|-----------|-----------|---------------|
| feature | `init-feature.md` | `feature/` |
| bugfix | `init-bugfix.md` | `bugfix/` |
| refactor | `init-refactor.md` | `refactor/` |

**Pre-populated Context**:

Pass the following to the init file:

```yaml
github_issue:
  url: "{issue_url}"
  number: {issue_number}
  title: "{issue_title}"
  body: "{issue_body}"

pre_filled:
  goal: "{issue_title}"
  problem: "{first paragraph of issue_body}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

**Init File Behavior with Pre-filled Context**:

1. **Branch Creation**: Use pre-filled `branch_keyword`
   - Create: `git checkout -b {work_type}/{branch_keyword}`

2. **Questions**: Show pre-filled values as defaults
   - Format: "[Extracted from GitHub Issue] {value}"
   - User can modify if needed

3. **Target Version**: If `target_version` is set
   - Skip Step 2.6 (version question)
   - Use milestone version directly

4. **SPEC.md**: Include issue reference
   - Add `**Source Issue**: {issue_url}` in header

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
4. Route to appropriate init-xxx.md
5. Continue normal init workflow from there (with pre-filled values)
