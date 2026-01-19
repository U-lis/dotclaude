# Phase 2: Create Shared Analysis Utilities

## Objective
Create `_shared/analysis-phases.md` with detailed instructions for analysis phases A-E.

## Prerequisites
- Phase 1 completed (workflow references this file)

## Instructions

### Step 1: Create File
Create new file at `.claude/skills/_shared/analysis-phases.md`

### Step 2: Write File Header
```markdown
# Analysis Phases

Common analysis workflow for init-xxx skills. Execute after gathering requirements, before creating SPEC.md.

**Iteration Limits**:
- Input clarification: max 5 questions per category
- Clarification loop: max 3 iterations
- Codebase search: max 10 file reads
```

### Step 3: Write Step A - Input Analysis
Content should include:
- Parse all collected answers from question phase
- Identify: vague descriptions ("improve", "better", "fix"), missing scope boundaries, implicit assumptions
- Generate clarifying questions for each identified issue
- Use AskUserQuestion for batch-related questions (min 2 options requirement)
- Example question format with options

### Step 4: Write Step B - Codebase Investigation
Content should include:
- Work-type-specific instructions:
  - **Feature**: Grep for similar functionality keywords, read potentially affected files, identify modification points, find patterns/conventions
  - **Bugfix**: Existing analysis (reference init-bugfix), add git log check for recent changes
  - **Refactor**: Read target code, grep for usages, build dependency graph
- Max 10 file reads limit
- Output format: list of related files with descriptions

### Step 5: Write Step C - Conflict Detection
Content should include:
- Compare new requirements vs existing code behavior
- Conflict types: API signature, data model, behavioral
- For each conflict: describe existing behavior, describe required behavior, ask user for resolution via AskUserQuestion
- Document all decisions
- Output format: conflict table

### Step 6: Write Step D - Edge Case Generation
Content should include:
- Based on requirements, generate cases:
  - Boundary conditions (empty input, max size)
  - Error scenarios (what if operation fails)
  - Null/empty cases
  - Concurrent access (if applicable)
- Present to user via AskUserQuestion with "Accept all" and "Add more" options
- Output format: edge case table

### Step 7: Write Step E - Summary + Clarification
Content should include:
- Present complete summary: collected requirements, analysis findings, conflicts + resolutions, edge cases
- Ask: "추가하거나 수정할 내용이 있나요?" with options: "없음 - SPEC 생성 진행" and "있음 - 수정 필요"
- If "있음": gather feedback and iterate (max 3 iterations)
- If "없음": proceed to SPEC.md creation
- Iteration counter tracking

### Step 8: Write Analysis Results Template
Add SPEC.md template section for Analysis Results:
```markdown
## Analysis Results Template (for SPEC.md)

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
```

## Completion Checklist
- [ ] File created at `.claude/skills/_shared/analysis-phases.md`
- [ ] Header with iteration limits documented
- [ ] Step A: Input Analysis with question generation logic
- [ ] Step B: Codebase Investigation with work-type-specific instructions
- [ ] Step C: Conflict Detection with resolution workflow
- [ ] Step D: Edge Case Generation with user confirmation
- [ ] Step E: Summary + Clarification with iteration limit
- [ ] Analysis Results template for SPEC.md inclusion
- [ ] All AskUserQuestion usages have min 2 options

## Notes
- This file is referenced by init-workflow.md (Phase 1)
- Each init skill will reference specific sections based on work type
- Keep language token-efficient for AI parsing
