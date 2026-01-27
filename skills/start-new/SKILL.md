---
name: start-new
description: Entry point for starting new work. Executes full 13-step orchestrator workflow with AskUserQuestion support.
user-invocable: true
---

# /dc:start-new

Central workflow controller for the full 13-step development process from init to merge.

## Configuration Loading

Before executing any operations, load the working directory from configuration:

1. **Default**: `working_directory = ".dc_workspace"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved `{working_directory}` value is used for all document and file paths in this skill.

## Role

- **Central workflow controller**: Manage all 13 steps from init to merge
- **Direct user interaction**: Use AskUserQuestion for all user interactions (Steps 1, 3, 5)
- **Subagent coordinator**: Call TechnicalWriter, Designer, Coder, code-validator via Task tool
- **State manager**: Track workflow progress, enable resume from failure

## Capabilities

**IMPORTANT**: All these tools ARE available to you. Do NOT assume any tool is missing.

- **AskUserQuestion**: Direct user interaction for questions and confirmations. YOU HAVE THIS TOOL. USE IT.
- **Task tool**: Invoke subagents (TechnicalWriter, Designer, Coder, code-validator)
- **Parallel Task calls**: Execute multiple subagents simultaneously for parallel phases
- **Bash tool**: Git operations, directory creation
- **Read/Write tools**: File operations

**NEVER** output text tables and ask users to type numbers. ALWAYS use AskUserQuestion tool.

---

## 13-Step Workflow

### INIT PHASE

**Step 1: Work Type Selection**

Call AskUserQuestion tool with these exact parameters:
- question: "어떤 작업을 시작하려고 하나요?"
- header: "작업 유형"
- options:
  - { label: "기능 추가/수정", description: "새로운 기능 개발 또는 기존 기능 개선" }
  - { label: "버그 수정", description: "발견된 버그나 오류 수정" }
  - { label: "리팩토링", description: "기능 변경 없이 코드 구조 개선" }
  - { label: "GitHub Issue", description: "GitHub 이슈 URL로 자동 초기화" }
- multiSelect: false

**Step 2: Load Init Instructions**

Based on Step 1 response, read and follow the corresponding init file from this directory:

| User Selection | Init File to Read |
|----------------|-------------------|
| 기능 추가/수정 | Read `init-feature.md` from this skill directory |
| 버그 수정 | Read `init-bugfix.md` from this skill directory |
| 리팩토링 | Read `init-refactor.md` from this skill directory |
| GitHub Issue | Read `init-github-issue.md` from this skill directory |

Execute ALL steps defined in the loaded init file:
1. Step-by-step questions (using AskUserQuestion)
2. Auto-generate branch keyword
3. Create work branch: `git checkout -b {type}/{keyword}`
4. Create project directory: `mkdir -p {working_directory}/{subject}`
5. Analysis phase (read `_analysis.md` for details)
6. **Target Version Question** (see below)
7. Draft SPEC.md via TechnicalWriter (include target_version in SPEC)
8. Commit SPEC.md

**Step 2.6: Target Version Question**

After analysis, before drafting SPEC.md:

1. **Read CHANGELOG.md** to gather version context:
   ```
   Read CHANGELOG.md → Extract recent 3 versions (including unreleased if exists)
   For each version: version number, date, key changes (1-2 lines summary)
   ```

2. **Present version history** to user before asking:
   ```markdown
   ## 최근 버전 히스토리

   | 버전 | 날짜 | 주요 변경사항 |
   |------|------|--------------|
   | 0.0.9 | 2026-01-21 | dc: prefix 추가, target version 질문 추가 |
   | 0.0.8 | 2026-01-19 | Orchestrator 추가, 16단계 워크플로우 |
   | 0.0.7 | 2026-01-19 | init-bugfix 분석 단계 추가 |
   ```

3. **Call AskUserQuestion** with context-aware options:
   - question: "이 작업의 목표 버전은 무엇인가요?"
   - header: "목표 버전"
   - options (dynamically generated based on current version):
     - { label: "{current}.{+1} (패치)", description: "버그 수정, 작은 변경" }
     - { label: "{current+minor}.0 (마이너)", description: "새 기능 추가, 하위 호환" }
     - { label: "{current+major}.0.0 (메이저)", description: "Breaking changes 포함" }
   - multiSelect: false

   Example if current is 0.0.9:
   - { label: "0.0.10 (패치)", description: "버그 수정, 작은 변경" }
   - { label: "0.1.0 (마이너)", description: "새 기능 추가, 하위 호환" }
   - { label: "1.0.0 (메이저)", description: "Breaking changes 포함" }

User can also enter specific version via "Other" option.

Store the target_version for:
- Include in SPEC.md header
- Pass to TechnicalWriter for CHANGELOG updates (Step 11)

**Step 3: SPEC Review**

Present SPEC.md summary to user, then call AskUserQuestion tool:
- question: "SPEC.md를 검토해주세요. 수정이 필요하면 말씀해주세요."
- header: "SPEC 검토"
- options:
  - { label: "승인", description: "SPEC.md 내용이 정확합니다" }
  - { label: "수정 필요", description: "수정이 필요합니다 (상세 내용 입력)" }
- multiSelect: false

If revision needed: iterate with TechnicalWriter via Task tool

**Step 4: Commit SPEC.md**
```bash
git add {working_directory}/{subject}/SPEC.md
git commit -m "docs: add SPEC.md for {subject}"
```

**Step 5: Scope Selection**

Call AskUserQuestion tool:
- question: "어디까지 진행할까요?"
- header: "진행 범위"
- options:
  - { label: "Design", description: "설계 문서만 작성" }
  - { label: "Design → Code", description: "설계 + 코드 구현" }
  - { label: "Design → Code → Docs", description: "설계 + 코드 + 문서 업데이트" }
  - { label: "Design → Code → Docs → Merge", description: "전체 워크플로우 실행" }
- multiSelect: false

---

### Step 6 Checkpoint (Before Design)

**MANDATORY**: Before calling Designer agent, validate:

1. **Branch Check**:
   - Current branch must NOT be main/master
   - Must be feature/, bugfix/, or refactor/ branch
   - If on main: HALT and report "Work branch not created. Create branch before proceeding."

2. **SPEC.md Check**:
   - File `{working_directory}/{subject}/SPEC.md` must exist
   - If missing: HALT and report "SPEC.md not found. Create SPEC.md before design phase."

3. **SPEC.md Committed Check**:
   - SPEC.md must be committed (not just staged)
   - Run: `git log --oneline -1 -- {working_directory}/{subject}/SPEC.md`
   - If no commit found: HALT and report "SPEC.md not committed. Commit SPEC.md before design phase."

If any check fails: halt workflow and report error to user.

---

### EXECUTION PHASE

**Step 6: Design - Call Designer**
```
Task tool → Designer
  Input:
    spec_path: "{working_directory}/{subject}/SPEC.md"
  Output: architecture decisions, phase breakdown
```

**Step 7: Design - Create Documents**
```
Task tool → TechnicalWriter
  Input:
    document_type: "DESIGN"
    designer_output: {Designer results}
    target_dir: "{working_directory}/{subject}/"
  Output: GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md
```

**Step 8: Commit Design Documents**
```bash
git add {working_directory}/{subject}/*.md
git commit -m "docs: add design documents for {subject}"
```

**Step 9: Parse Phase List**
```
Read GLOBAL.md → extract Phase Overview table
Build execution order:
  - Sequential phases: execute in order
  - Parallel phases (e.g., 3A, 3B, 3C): group together
  - Merge phase (e.g., 3.5): after parallel phases
```

**Step 10: Execute Phases**

For sequential phase:
```
Task tool → Coder
  Input:
    phase_id: "{k}"
    plan_path: "{working_directory}/{subject}/PHASE_{k}_PLAN_*.md"
  Output: implementation, files changed

Task tool → code-validator
  Input:
    phase_id: "{k}"
    checklist: [items from PLAN]
  Output: validation result

If passed: commit
If failed: retry (max 3), then skip
```

For parallel phases (e.g., 3A, 3B, 3C):
```bash
# Setup worktrees
git worktree add ../{subject}-3A -b feature/{subject}-3A
git worktree add ../{subject}-3B -b feature/{subject}-3B
git worktree add ../{subject}-3C -b feature/{subject}-3C

# Single message with multiple Task tool calls (parallel execution)
Task tool → Coder (phase=3A, worktree=../{subject}-3A)
Task tool → Coder (phase=3B, worktree=../{subject}-3B)
Task tool → Coder (phase=3C, worktree=../{subject}-3C)

# Wait for all results

# Merge phase (3.5)
git merge feature/{subject}-3A --no-edit
git merge feature/{subject}-3B --no-edit
git merge feature/{subject}-3C --no-edit

# Cleanup
git worktree remove ../{subject}-3A
git worktree remove ../{subject}-3B
git worktree remove ../{subject}-3C
```

**Step 11: Update Documentation**
```
Task tool → TechnicalWriter (DOCS_UPDATE role)
  Input:
    role: "DOCS_UPDATE"
    commits: git log since last tag
    target_version: from init phase
  Output: CHANGELOG.md, README.md updates

Then commit:
  git add CHANGELOG.md README.md
  git commit -m "docs: update CHANGELOG and README for {version}"
```

**Step 12: Merge to Main**
```bash
git checkout main
git pull origin main
git merge {branch} --no-edit
git branch -d {branch}
```

**Step 13: Return Summary**
Return structured output (see "Output Contract" section)

---

## Init Phase Rules

### Plan Mode Policy

**CRITICAL**: Init phase MUST NOT use plan mode (EnterPlanMode).

Reasons:
- Plan mode is for implementation planning, not requirements gathering
- ExitPlanMode can cause workflow interruption
- User approval happens at SPEC.md review stage, not plan approval

Instead:
- Use AskUserQuestion for sequential requirements gathering
- Proceed directly through workflow steps
- User reviews and approves at Step 3 (SPEC.md review)

### Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of permission settings.

Steps 2-4 are MANDATORY and CANNOT be skipped:
- Step 2: Execute init instructions (questions + analysis + SPEC.md creation)
- Step 3: Present SPEC.md for user review
- Step 4: Commit SPEC.md after approval

### Prohibited Actions

NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Skip Analysis Phase
- Bypass SPEC.md file creation
- Start coding without user explicitly selecting a scope that includes "Code"

### Iteration Limits

| Limit Type | Maximum |
|------------|---------|
| Input clarification | 5 questions per category |
| SPEC revision loop | 3 iterations |
| Codebase search | 10 file reads |

### Response Quality Rules

**CRITICAL**: These rules ensure response quality.

- **Evidence-Based Responses**: Never agree or praise without verification. Always provide evidence-based responses.
- **Completion Reporting**: Report summary upon completion and wait for user review/additional commands.

---

## Subagent Call Patterns

### TechnicalWriter
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are TechnicalWriter. Read agents/technical-writer.md for your role.

    Create {document_type} document:
    - Input: {content_data}
    - Output path: {target_path}

    Follow the template structure from your agent definition.
```

### Designer
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are Designer. Read agents/designer.md for your role.

    Analyze SPEC and create design:
    - SPEC path: {spec_path}
    - Output: architecture decisions, phase breakdown

    Follow the instructions in your agent definition.
```

### Coder
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are Coder. Read agents/coders/{language}.md for your role.

    Implement phase:
    - Phase: {phase_id}
    - PLAN path: {plan_path}
    - Worktree: {worktree_path} (if parallel)

    Follow TDD and complete all checklist items.
```

### code-validator
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are code-validator. Read agents/code-validator.md for your role.

    Validate phase implementation:
    - Phase: {phase_id}
    - Checklist: {items}

    Run quality checks and report results.
```

---

## Routing

After user selects scope (Step 5), execute steps directly:

| Selection | Execution |
|-----------|-----------|
| Design | Steps 6-8 (Designer + TechnicalWriter + commit) → STOP |
| Design → Code | Steps 6-10 (Design + Code phases) → STOP |
| Design → Code → Docs | Steps 6-11 (Design + Code + TechnicalWriter DOCS_UPDATE) → STOP |
| Design → Code → Docs → Merge | Steps 6-12 (Full workflow) → STOP |

**Execution Method**: All steps executed directly via Task tool (for agents) or Bash tool (for git operations).

---

## Non-Stop Execution

When user selects a scope with multiple steps (e.g., "Design → Code"), execute all steps automatically without stopping.

### Execution Rules

1. **DO NOT** ask "What's next?" between chained steps
2. **DO NOT** wait for user input between steps
3. **MUST** proceed immediately to next step in chain
4. **MUST** halt chain on error and report to user

### CLAUDE.md Rule Overrides

During non-stop execution, these CLAUDE.md rules are suspended:

- **"Do NOT proceed to next phase without user instruction"**
  → User's scope selection IS the instruction to proceed

- **"Report summary upon completion and wait for user review"**
  → Report only at final STOP point, not between steps

### On Error

If any step fails during chain:
1. STOP the chain immediately
2. Report error to user
3. Suggest manual resolution
4. User can resume by re-selecting scope

---

## Parallel Execution

### Detection
Parse GLOBAL.md Phase Overview table:
- Look for phases like "3A", "3B", "3C"
- These execute in parallel with worktree isolation

### Execution Pattern
```
# Single message with multiple Task tool calls
# All execute simultaneously

<Task tool call 1>
  subagent_type: "general-purpose"
  prompt: "Execute PHASE_3A in worktree ../{subject}-3A"
</Task tool call 1>

<Task tool call 2>
  subagent_type: "general-purpose"
  prompt: "Execute PHASE_3B in worktree ../{subject}-3B"
</Task tool call 2>
```

### Post-Parallel
1. Collect all results
2. Execute merge phase (PHASE_{k}.5)
3. Clean up worktrees

---

## State Management

### State Tracking
Track during execution:
- current_step: 1-13
- completed_steps: []
- pending_steps: []
- subagent_results: {}
- errors: []
- retry_counts: {}

### Checkpoint via GLOBAL.md
Update Phase Overview status column:
- "Pending" → "In Progress" → "Complete" / "Skipped"

### Resume Capability
On re-invocation:
1. Read GLOBAL.md Phase Overview
2. Find last completed phase
3. Resume from next pending phase

---

## Error Handling

### Subagent Failure
```
attempt = 0
while attempt < 3:
  result = call_subagent()
  if result.success:
    break
  attempt += 1
if not result.success:
  mark_phase_skipped()
  record_error()
  continue_to_next_phase()
```

### SPEC Rejection
```
while not approved:
  present_spec()
  feedback = ask_user()
  if feedback.approved:
    break
  call_technical_writer(revisions=feedback)
```

### Critical Error
```
if critical_error:
  halt_workflow()
  report_to_user(error_details)
  suggest_manual_resolution()
```

---

## Output Contract

```yaml
status: "SUCCESS" | "PARTIAL" | "FAILED"
work_type: "feature" | "bugfix" | "refactor"
subject: "{keyword}"
branch: "{type}/{keyword}"
scope_executed: "Design → Code → Docs → Merge"
init:
  spec_path: "{working_directory}/{subject}/SPEC.md"
  spec_approved: true
  target_version: "X.Y.Z"
design:
  global_path: "{working_directory}/{subject}/GLOBAL.md"
  phases: ["1", "2", "3A", "3B", "3C", "3.5", "4"]
code:
  phases:
    - phase: "1"
      status: "SUCCESS"
      commit: "abc123"
    - phase: "3B"
      status: "SKIPPED"
      error: "Error message"
docs:
  updated:
    - "CHANGELOG.md"
    - "README.md"
merge:
  merged_to: "main"
  branch_deleted: true
issues:
  - "Description of issue"
next_steps:
  - "Recommended action"
```

---

## Final Summary Report

After all steps in the chain complete, display summary:

```markdown
# Workflow Complete

## Scope: {selected scope}

## Results

| Step | Description | Status |
|------|-------------|--------|
| 1 | Design | SUCCESS |
| 2 | Code | SUCCESS |
| 3 | Documentation | SUCCESS |
| 4 | Merge | SUCCESS |

## Files Changed
- {working_directory}/{subject}/*.md
- [implementation files...]
- CHANGELOG.md

## Next Steps
1. Review changes: `git log --oneline -10`
2. Push to remote: `git push origin main`
3. (Optional) Create tag: `/dc:tagging`
```

This summary appears ONLY at the final STOP point, not between steps.

---

## Progress Reporting

### Step Progress

Display progress at each major step:

```
═══════════════════════════════════════════════════════════
[Step {N}/13] {Step description}
Current: {Current action}
═══════════════════════════════════════════════════════════
```

### Chain Progress

During multi-step execution (non-stop mode), display:

```
═══════════════════════════════════════════════════════════
[Step {M}/{Total}] {Step description}
Current: Executing {step name}
═══════════════════════════════════════════════════════════
```

Example for "Design → Code → Docs → Merge":
- [Step 1/4] Design phase - Creating architecture
- [Step 2/4] Code implementation - Executing phases
- [Step 3/4] Documentation update - Updating CHANGELOG
- [Step 4/4] Merge to main - Completing workflow
