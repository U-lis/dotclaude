# Analysis Phases

Common analysis workflow for init-xxx skills. Execute after gathering requirements, before creating SPEC.md.

## Iteration Limits

| Limit Type | Maximum |
|------------|---------|
| Input clarification | 5 questions per category |
| Clarification loop | 3 iterations |
| Codebase search | 10 file reads |

---

## Step A: Input Analysis

Analyze collected user answers for completeness and clarity.

### Detection Targets

| Issue Type | Examples | Action |
|------------|----------|--------|
| Vague descriptions | "improve", "better", "fix", "enhance" | Ask for specific metrics/criteria |
| Missing scope | No clear boundaries defined | Ask what's explicitly excluded |
| Implicit assumptions | Assumed tech stack, user type | Ask to confirm assumptions |
| Conflicting statements | A contradicts B in answers | Ask user to clarify |

### Process

1. Review all collected answers from question phase
2. For each issue found, generate clarifying question
3. Batch related questions (max 5 per category)
4. Use AskUserQuestion:

```
Question: "다음 내용을 명확히 해주세요: {issue_description}"
Header: "추가 정보 필요"
Options:
  - label: "{specific_option_1}"
    description: "{description_1}"
  - label: "{specific_option_2}"
    description: "{description_2}"
  - label: "기타"
    description: "직접 입력"
```

---

## Step B: Codebase Investigation

Search codebase for related code. Work-type-specific details in each init skill.

### Common Process

1. Extract keywords from user requirements
2. Use Grep tool to search for related code
3. Use Read tool to examine relevant files (max 10 reads)
4. Document findings

### Output Format

```markdown
### Related Code
| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | path/to/file.ts | 42 | Similar functionality exists |
| 2 | path/to/other.ts | 100 | Will need modification |
```

### Work-Type Specifics

- **Feature**: See init-feature/SKILL.md - focus on similar functionality, patterns
- **Bugfix**: See init-bugfix/SKILL.md - focus on root cause, affected code
- **Refactor**: See init-refactor/SKILL.md - focus on dependencies, test coverage

---

## Step C: Conflict Detection

Compare requirements against existing implementation.

### Conflict Types

| Type | Check For |
|------|-----------|
| API signature | New API conflicts with existing signatures |
| Data model | Schema changes affect existing data |
| Behavioral | New behavior contradicts current behavior |

### Process

For each potential conflict:
1. Document existing behavior
2. Document required behavior
3. Present to user via AskUserQuestion:

```
Question: "기존 동작과 충돌이 발견되었습니다. 어떻게 처리할까요?"
Header: "충돌 해결"
Options:
  - label: "새 동작 우선"
    description: "기존: {existing}. 새로운 요구사항대로 변경"
  - label: "기존 유지"
    description: "기존 동작을 유지하고 요구사항 수정"
  - label: "둘 다 지원"
    description: "호환성을 위해 두 동작 모두 지원"
```

### Output Format

```markdown
### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | Returns null on error | Should throw exception | Throw exception (user decision) |
```

---

## Step D: Edge Case Generation

Generate boundary conditions and error scenarios.

### Case Categories

| Category | Examples |
|----------|----------|
| Boundary | Empty input, max size, min value |
| Error | Operation fails, network timeout, invalid input |
| Null/Empty | Null parameters, empty collections |
| Concurrent | Race conditions, parallel access (if applicable) |

### Process

1. Based on requirements, generate 5-10 edge cases
2. Present to user via AskUserQuestion:

```
Question: "다음 엣지 케이스들을 검토해주세요."
Header: "엣지 케이스 확인"
Options:
  - label: "모두 승인"
    description: "나열된 모든 케이스 포함"
  - label: "추가 필요"
    description: "케이스 추가 또는 수정 필요 (상세 입력)"
```

### Output Format

```markdown
### Edge Cases
| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Empty input | Return empty result |
| 2 | Input exceeds max size | Throw validation error |
| 3 | Concurrent modification | Last write wins / Queue updates |
```

---

## Step E: Summary + Clarification

Present complete analysis summary and allow user refinement.

### Summary Components

1. **Collected Requirements**: Brief recap of user's answers
2. **Analysis Findings**: Related code found
3. **Conflicts + Resolutions**: Documented decisions
4. **Edge Cases**: Confirmed test scenarios

### Process

```
iteration = 0
while iteration < 3:
    present_summary()

    AskUserQuestion:
      question: "추가하거나 수정할 내용이 있나요?"
      header: "최종 확인"
      options:
        - label: "없음 - SPEC 생성 진행"
          description: "분석 내용이 완전합니다"
        - label: "있음 - 수정 필요"
          description: "수정사항을 입력해주세요"

    if user_selects("없음"):
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
