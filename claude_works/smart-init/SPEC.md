# Smart Init - Intelligent Requirements Analysis

## Overview

### Goal
Enhance init-xxx skills (init-feature, init-bugfix, init-refactor) to perform intelligent requirements analysis, codebase investigation, and iterative clarification before creating SPEC.md.

### Problem Statement
Current init-xxx skills:
- Follow a fixed question flow without adaptive analysis
- Do not analyze codebase for related code, conflicts, or dependencies
- Do not clarify ambiguous or incomplete user inputs
- Do not generate test cases or edge cases
- Produce incomplete SPEC.md that fails as Source of Truth

Exception: init-bugfix has Codebase Analysis section but init-feature and init-refactor do not.

### Target State
Init skills that:
1. Analyze user input for gaps and ambiguities
2. Investigate codebase for related code and potential conflicts
3. Clarify requirements through iterative questions
4. Generate edge cases and test scenarios
5. Produce comprehensive SPEC.md as reliable Source of Truth

## Functional Requirements

### FR-1: User Input Analysis
- [ ] After gathering initial requirements, analyze for:
  - Missing information (incomplete descriptions)
  - Ambiguous terms (multiple interpretations possible)
  - Conflicting statements within user input
- [ ] Generate clarifying questions for each identified issue
- [ ] Use AskUserQuestion to resolve each issue

### FR-2: Codebase Investigation
- [ ] For init-feature:
  - Search for existing similar functionality
  - Identify code locations that need modification
  - Find patterns/conventions to follow
- [ ] For init-refactor:
  - Analyze target code structure
  - Identify all usages and dependencies
  - Map affected modules
- [ ] For init-bugfix (enhance existing):
  - Current analysis already exists
  - Add conflict detection with recent changes

### FR-3: Conflict Detection
- [ ] Compare requirements against existing implementation:
  - API signature conflicts
  - Data model conflicts
  - Behavioral conflicts
- [ ] Report conflicts to user via AskUserQuestion
- [ ] Document user's decision on each conflict

### FR-4: Edge Case Generation
- [ ] Based on requirements, generate:
  - Boundary conditions
  - Error scenarios
  - Null/empty cases
  - Concurrent access cases (if applicable)
- [ ] Present generated cases to user for confirmation
- [ ] Allow user to add additional cases

### FR-5: Iterative Clarification Loop
- [ ] After analysis, present summary to user
- [ ] Allow user to refine or add requirements
- [ ] Continue until user confirms completeness
- [ ] Maximum 3 iterations to prevent infinite loop

## Workflow Design

### Enhanced Init Flow

```
[Current: Fixed Questions]
Step 1-N: Fixed questions
→ Create SPEC.md
→ Done

[New: Smart Analysis]
Step 1-N: Fixed questions (same as current)
→ Step A: Input Analysis (gaps, ambiguities)
→ Step B: Codebase Investigation
→ Step C: Conflict Detection
→ Step D: Edge Case Generation
→ Step E: Summary + Clarification Loop
→ Create SPEC.md
→ Done
```

### Analysis Phase Detail

#### Step A: Input Analysis
```
1. Parse all collected answers
2. Identify:
   - Vague descriptions ("improve", "better", "fix")
   - Missing scope boundaries
   - Implicit assumptions
3. Generate clarifying questions
4. AskUserQuestion for each (or batch if related)
```

#### Step B: Codebase Investigation
```
Feature:
  1. Grep for similar functionality keywords
  2. Read potentially affected files
  3. Identify modification points

Bugfix:
  1. (existing analysis)
  2. Add: Check git log for recent changes to affected files

Refactor:
  1. Read target code
  2. Grep for usages
  3. Build dependency graph
```

#### Step C: Conflict Detection
```
1. Compare new requirements vs existing code behavior
2. For each conflict:
   - Describe existing behavior
   - Describe required behavior
   - Ask user for resolution
3. Document all decisions
```

#### Step D: Edge Case Generation
```
1. Based on requirements, generate cases:
   - What if input is empty?
   - What if input is maximum size?
   - What if operation fails?
   - What if concurrent access?
2. Present to user
3. User confirms/adds/removes cases
```

#### Step E: Summary + Clarification
```
1. Present complete summary:
   - Collected requirements
   - Analysis findings
   - Identified conflicts + resolutions
   - Edge cases
2. Ask: "추가하거나 수정할 내용이 있나요?"
3. If yes: iterate forever until get "no"
4. If no: proceed to SPEC.md creation
```

## SPEC.md Enhanced Structure

### For All Types

Add new sections:
```markdown
## Analysis Results

### Related Code
- [file:line] - Description of relationship

### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|

### Edge Cases
| # | Case | Expected Behavior |
|---|------|-------------------|
```

### Token-Efficient Format
- Use tables for structured data
- Avoid prose where lists suffice
- Reference file paths, not content

## Non-Functional Requirements

### NFR-1: Token Efficiency
- Analysis prompts: concise, no filler
- Codebase investigation: targeted searches only
- Avoid reading entire files when grep suffices

### NFR-2: Clear Language
- Questions: direct, unambiguous
- Skill files: no unnecessary explanation
- Use Korean for user questions, English for technical terms

### NFR-3: Iteration Limits
- Input clarification: max 5 questions per category
- Clarification loop: max 3 iterations
- Codebase search: max 10 file reads

## Constraints

- Must work with AskUserQuestion tool (min 2 options requirement)
- Cannot block user indefinitely (iteration limits)
- Analysis must complete in reasonable time

## Out of Scope

- Modifying design or code phases
- Adding new subagents
- Changing SPEC.md file format fundamentally
- Automated requirement validation (beyond conflict detection)

## Success Criteria

1. init-feature performs codebase investigation before SPEC creation
2. init-refactor analyzes target code and dependencies before SPEC creation
3. init-bugfix enhanced with conflict detection
4. All init-xxx skills generate edge cases
5. All init-xxx skills have iterative clarification loop
6. SPEC.md includes Analysis Results section
7. Token-efficient: analysis adds <2000 tokens to prompt

## Affected Files

| File | Change Type |
|------|-------------|
| .claude/skills/init-feature/SKILL.md | Modify - add analysis phases |
| .claude/skills/init-bugfix/SKILL.md | Modify - enhance existing analysis |
| .claude/skills/init-refactor/SKILL.md | Modify - add analysis phases |
| .claude/skills/_shared/init-workflow.md | Modify - add analysis workflow |
