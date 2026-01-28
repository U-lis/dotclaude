# init-bugfix Instructions

Instructions for initializing bug fix work through bug detail gathering and root cause analysis.

## Configuration Loading

Before executing any operations, load the working directory from configuration:

1. **Default**: `working_directory = ".dc_workspace"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved `{working_directory}` value is used for all document and file paths in this skill.

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 증상
```
Question: "어떤 버그/문제가 발생하고 있나요?"
Header: "버그 증상"
→ Free text (증상 설명)
```

### Step 2: 재현 조건
```
Question: "버그가 발생하는 조건이나 재현 단계가 있나요?"
Header: "재현 조건"
→ Free text (재현 단계)
```

### Step 3: 예상 원인
```
Question: "예상되는 원인이 있나요?"
Header: "예상 원인"
Options:
  - label: "특정 코드 의심"
    description: "특정 파일이나 함수가 원인으로 의심됨"
  - label: "외부 의존성 문제"
    description: "라이브러리나 외부 서비스 관련 문제"
  - label: "설정 오류"
    description: "환경 설정이나 config 문제"
  - label: "모르겠음"
    description: "원인 파악이 필요함"
multiSelect: false
```

### Step 4: 심각도
```
Question: "버그의 심각도는 어느 정도인가요?"
Header: "심각도"
Options:
  - label: "Critical"
    description: "서비스 불가 또는 데이터 손실 위험"
  - label: "Major"
    description: "주요 기능 장애"
  - label: "Minor"
    description: "불편함이 있으나 우회 가능"
  - label: "Trivial"
    description: "미미한 문제"
multiSelect: false
```

### Step 5: 관련 파일
```
Question: "관련된 파일이나 모듈을 알고 있나요?"
Header: "관련 파일"
Options:
  - label: "모름"
    description: "조사가 필요함"
→ Or free text via "Other" (파일 경로 입력)
```

### Step 6: 영향 범위
```
Question: "이 버그가 영향을 주는 다른 기능이 있나요?"
Header: "영향 범위"
Options:
  - label: "없음/모름"
    description: "다른 기능에 영향 없거나 파악 필요"
→ Or free text via "Other"
```

---

## Analysis Phase

**MANDATORY**: After gathering user input (Steps 1-6), execute analysis phases.

Read `_analysis.md` for the common analysis workflow (Steps A-E).

### Bugfix-Specific Analysis

#### Step B: Codebase Investigation (Bugfix - Enhanced)

##### Case 1: User specified related files (Step 5)
1. Use Read tool to analyze the specified files
2. Search for code patterns matching described symptoms
3. Identify the exact code causing the bug

##### Case 2: User said "모름" (unknown files)
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

1. Bugfix branch `bugfix/{keyword}` created and checked out
2. Directory `{working_directory}/{subject}/` created
3. `{working_directory}/{subject}/SPEC.md` created with all sections above
