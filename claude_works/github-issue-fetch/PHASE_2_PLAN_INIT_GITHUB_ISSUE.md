# Phase 2: init-github-issue.md Creation

## Objective

Create new init file that parses GitHub issues and routes to appropriate workflow.

## Prerequisites

- Phase 1 completed (SKILL.md has "GitHub Issue" option)

## Instructions

### Create File

Create `.claude/skills/start-new/init-github-issue.md` with the following structure:

### File Content Structure

```markdown
# init-github-issue Instructions

Instructions for initializing work from GitHub issue URL or number.

## Step-by-Step Process

### Step 1: Issue Input

Use AskUserQuestion tool:
- question: "GitHub 이슈 URL 또는 번호를 입력해주세요"
- header: "GitHub Issue"
- options:
  - label: "URL 형식"
    description: "https://github.com/owner/repo/issues/123"
  - label: "번호 형식"
    description: "#123 (현재 저장소 기준)"
→ Free text via "Other"

**Input Parsing**:
- Full URL: Extract owner, repo, number from `https://github.com/{owner}/{repo}/issues/{number}`
- Number only: `#123` or `123` → use current repository context

### Step 2: Issue Parsing

**Command Execution**:
```bash
# For full URL
gh issue view {number} --repo {owner}/{repo} --json title,body,labels,milestone

# For issue number only (current repo)
gh issue view {number} --json title,body,labels,milestone
```

**Error Handling**:
| Error | Detection | Action |
|-------|-----------|--------|
| gh not installed | Command not found | Show "gh CLI가 설치되어 있지 않습니다. https://cli.github.com/ 에서 설치해주세요" |
| Not authenticated | Auth error in output | Show "gh auth login 명령으로 인증해주세요" |
| Issue not found | 404 in output | Show "이슈 #{number}를 찾을 수 없습니다" |
| No access | 403 in output | Show "이슈에 접근 권한이 없습니다" |
| Invalid URL | Regex mismatch | Show "유효한 GitHub 이슈 URL이 아닙니다" |

On any error: Return to Step 1 of /dc:start-new (work type selection)

### Step 3: Work Type Detection

**Algorithm**:
1. Extract label names from JSON response
2. Check for known labels (case-insensitive):
   - `bug` → work_type = "bugfix"
   - `enhancement` → work_type = "feature"
   - `refactor` → work_type = "refactor"
3. If no match found, analyze issue body for keywords:

**Body Analysis Keywords**:
| Keywords (case-insensitive) | Work Type |
|-----------------------------|-----------|
| fix, bug, error, broken, crash, issue, problem, 수정, 버그, 오류 | bugfix |
| add, new, feature, implement, support, enable, 추가, 기능, 구현 | feature |
| refactor, clean, improve code, restructure, reorganize, 리팩, 정리, 개선 | refactor |

4. If still ambiguous (multiple matches or no match), use AskUserQuestion:
   - question: "이슈 분석 결과, 작업 유형을 확인해주세요: {issue_title}"
   - header: "작업 유형 확인"
   - options:
     - { label: "기능 추가/수정", description: "새로운 기능 개발 또는 기존 기능 개선" }
     - { label: "버그 수정", description: "발견된 버그나 오류 수정" }
     - { label: "리팩토링", description: "기능 변경 없이 코드 구조 개선" }

### Step 4: Context Extraction

From parsed issue, extract:
- `issue_url`: Full URL to issue
- `issue_number`: Issue number
- `issue_title`: Issue title
- `issue_body`: Issue body content
- `target_version`: From milestone.title (if exists), null otherwise
- `work_type`: Detected work type

**Branch Keyword Generation**:
- Extract keywords from issue title
- Format: `{work_type}/{keyword}` (e.g., `feature/github-issue-fetch`)

### Step 5: Route to Init File

Based on detected work_type, read and execute:
- work_type = "feature" → Read `init-feature.md`
- work_type = "bugfix" → Read `init-bugfix.md`
- work_type = "refactor" → Read `init-refactor.md`

**Pre-populated Context**:
Pass the following context to the init file for question pre-filling:
- Goal/Purpose → from issue_title
- Problem description → from issue_body (first paragraph)
- target_version → from milestone (skip version question if present)

**Question Handling in Init Files**:
- If context provides answer, show as default: "[Pre-filled from issue] {value}"
- User can modify if needed
- If context doesn't have answer, ask normally

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD when context is needed
- **Clarification Required**: If unclear parts or decisions needed, report and wait for user confirmation

---

## Output

1. Parsed GitHub issue data
2. Detected work type
3. Route to appropriate init-xxx.md with pre-populated context
4. Continue normal init workflow from there
```

## Completion Checklist

- [ ] Create init-github-issue.md file in `.claude/skills/start-new/`
- [ ] Implement Step 1: Issue URL/number input via AskUserQuestion
- [ ] Implement Step 2: gh CLI issue parsing with Bash tool
- [ ] Implement error handling for all scenarios (not found, auth, invalid URL)
- [ ] Implement Step 3: Label-based work type detection
- [ ] Implement Step 3: Body keyword analysis fallback
- [ ] Implement Step 3: User confirmation for ambiguous cases
- [ ] Implement Step 4: Context extraction from parsed issue
- [ ] Implement Step 5: Routing to appropriate init-xxx file
- [ ] Document gh CLI requirement at top of file

## Notes

- The file should follow the same structure as existing init-xxx files
- Use AskUserQuestion for all user interactions
- All errors should gracefully fall back to Step 1 of /dc:start-new
- Korean language for user-facing messages (matching existing style)
