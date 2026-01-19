# Master Orchestrator Architecture

## Overview

### Goal
Create a Master Orchestrator agent that governs the **entire** workflow from init to merge, coordinates subagents, and enables parallel execution when needed.

### Problem Statement
Current chaining approach (turn-key) has limitations:
- No central controller for entire workflow
- Cannot execute parallel phases truly in parallel
- No cross-phase state management
- Each skill operates independently without holistic view
- Init questions collected directly, not via TechnicalWriter

### Target Architecture

```
User
  ↓
/start-new (skill) ─── minimal entry point
  └── Task tool → Orchestrator Agent 호출
                        ↓
┌─────────────────────────────────────────────────────────────────┐
│                   Orchestrator Agent                            │
│                   (agents/orchestrator.md)                      │
│                                                                 │
│  INIT PHASE (orchestrator manages):                             │
│  ├── 작업 유형 선택 (AskUserQuestion)                            │
│  ├── Work-type-specific questions (AskUserQuestion)             │
│  ├── TechnicalWriter → SPEC.md                                  │
│  ├── User reviews SPEC.md                                       │
│  └── Scope selection (AskUserQuestion)                          │
│                                                                 │
│  EXECUTION PHASE (based on selected scope):                     │
│  ├── Designer → architecture decisions                          │
│  ├── TechnicalWriter → GLOBAL.md, PHASE_*.md                    │
│  ├── Coder(s) → implementation (parallel if needed)             │
│  ├── code-validator → validation                                │
│  ├── TechnicalWriter → CHANGELOG                                │
│  └── Merge handler → merge to main                              │
│                                                                 │
│  FINAL: Return summary to /start-new                            │
└─────────────────────────────────────────────────────────────────┘
```

## Functional Requirements

### FR-1: Orchestrator Agent Definition
- [ ] Create `agents/orchestrator.md`
- [ ] Orchestrator manages entire workflow from init to merge
- [ ] Orchestrator uses AskUserQuestion for user interaction
- [ ] Orchestrator calls subagents via Task tool
- [ ] Define input contract (minimal, from /start-new)
- [ ] Define output contract (final summary)

### FR-2: /start-new Skill Update
- [ ] Update `skills/start-new/SKILL.md`
- [ ] /start-new becomes minimal entry point
- [ ] /start-new only calls orchestrator via Task tool
- [ ] /start-new receives and displays final summary

### FR-3: Init Phase (Orchestrator Manages)
- [ ] Orchestrator asks work type (Feature/Bugfix/Refactor)
- [ ] Orchestrator asks work-type-specific questions
- [ ] Orchestrator reads CHANGELOG.md, shows latest 5 versions
- [ ] Orchestrator asks target version
- [ ] Orchestrator calls TechnicalWriter → SPEC.md (includes target version)
- [ ] Orchestrator presents SPEC.md for user review (before commit)
- [ ] Orchestrator commits SPEC.md (after approval)
- [ ] Orchestrator asks scope selection

### FR-4: Execution Phase
- [ ] Orchestrator calls Designer → architecture decisions
- [ ] Orchestrator calls TechnicalWriter → GLOBAL.md, PHASE_*.md
- [ ] Orchestrator calls spec-validator (optional)
- [ ] Orchestrator executes code phases:
  - Sequential: call Coder → code-validator → commit
  - Parallel: simultaneous Task calls for parallel phases
- [ ] Orchestrator calls TechnicalWriter → update docs (CHANGELOG.md, README.md, etc.)
- [ ] Orchestrator handles merge to main

### FR-5: Parallel Execution Support
- [ ] Orchestrator parses GLOBAL.md for phase structure
- [ ] Orchestrator identifies parallel phases (e.g., 3A, 3B, 3C)
- [ ] Orchestrator calls multiple coders simultaneously
- [ ] Orchestrator waits for all parallel tasks to complete
- [ ] Orchestrator triggers merge phase (3.5)

### FR-6: State Management
- [ ] Orchestrator tracks workflow state
- [ ] State: current step, completed steps, pending steps
- [ ] State: subagent results, errors, retry counts
- [ ] Enable resume from failure (via GLOBAL.md status)

### FR-7: Manual Skill Support
- [ ] Individual skills (/design, /code) remain invocable
- [ ] Manual invocation bypasses orchestrator
- [ ] Useful for partial work or debugging

## Workflow Design

### Entry Flow

```
User: /start-new
         ↓
/start-new skill (minimal):
  └── Task tool → Orchestrator Agent
         ↓
Orchestrator executes entire workflow
         ↓
Orchestrator returns final summary
         ↓
/start-new displays summary to user
```

### Orchestrator Full Flow

```
Orchestrator starts
         ↓
[INIT PHASE]
1. AskUserQuestion: "어떤 작업을 시작하려고 하나요?"
   → Feature / Bugfix / Refactor
         ↓
2. AskUserQuestion: work-type-specific questions
   (Feature: 목표, 문제, 핵심기능, ...)
   (Bugfix: 증상, 재현조건, 예상원인, ...)
   (Refactor: 대상, 문제점, 목표상태, ...)
         ↓
3. Create branch, directory
   git checkout -b {type}/{keyword}
   mkdir -p claude_works/{subject}
         ↓
4. Read CHANGELOG.md → extract latest 5 versions
   AskUserQuestion: "목표 버전을 선택해주세요."
   Display: "최근 버전: v1.2.0, v1.1.0, v1.0.2, v1.0.1, v1.0.0"
   → User selects or inputs target version
         ↓
5. Task tool → TechnicalWriter
   Input: collected requirements, target version
   Output: SPEC.md created
         ↓
6. Present SPEC.md summary to user
   AskUserQuestion: "SPEC.md를 검토해주세요. 수정이 필요하면 말씀해주세요."
   (iteration if needed)
         ↓
7. Commit SPEC.md
         ↓
8. AskUserQuestion: "어디까지 진행할까요?"
   → Design / Design→Code / Design→Code→Docs / Full
         ↓
[EXECUTION PHASE - based on scope]

[Design]
9. Task tool → Designer
   Input: SPEC.md path
   Output: architecture, phase breakdown
         ↓
10. Task tool → TechnicalWriter
    Input: Designer output
    Output: GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md
         ↓
11. Commit design documents
         ↓
[Code]
12. Parse GLOBAL.md → phase list
    e.g., [1, 2, 3A, 3B, 3C, 3.5, 4]
         ↓
13. For each phase:
    Sequential phase:
      Task tool → Coder
      Task tool → code-validator
      Commit

    Parallel phases (3A, 3B, 3C):
      Setup worktrees
      Task tool → Coder-3A ─┐
      Task tool → Coder-3B ─┼── simultaneous
      Task tool → Coder-3C ─┘
      Wait for all results
      Task tool → merge handler (3.5)
         ↓
[Documentation]
14. Task tool → TechnicalWriter
    Input: commit history, changes made
    Output: Update CHANGELOG.md, README.md, and other affected docs
         ↓
[Merge]
15. Merge to main
    Cleanup feature branch
         ↓
[FINAL]
16. Return structured summary to /start-new
```

### Orchestrator Input Contract (from /start-new)

```yaml
# Minimal - orchestrator handles everything
trigger: "start-new"
```

### Orchestrator Output Contract

```yaml
status: "SUCCESS" | "PARTIAL" | "FAILED"
work_type: "feature"
subject: "user-auth"
branch: "feature/user-auth"
scope_executed: "Design → Code → Docs → Merge"
init:
  spec_path: "claude_works/user-auth/SPEC.md"
  spec_approved: true
design:
  global_path: "claude_works/user-auth/GLOBAL.md"
  phases: ["1", "2", "3A", "3B", "3C", "3.5", "4"]
code:
  phases:
    - phase: "1"
      status: "SUCCESS"
      commit: "abc123"
    - phase: "3B"
      status: "SKIPPED"
      error: "Type error after 3 retries"
docs:
  target_version: "1.3.0"
  updated:
    - "CHANGELOG.md"
    - "README.md"
merge:
  merged_to: "main"
  branch_deleted: true
issues:
  - "PHASE_3B: Type error in src/moduleB/handler.py:45"
next_steps:
  - "Manually resolve PHASE_3B issues"
  - "Run /code 3B to retry"
```

## Subagent Contracts

### TechnicalWriter
- Input: document type, content data, target path
- Output: file path created, success/failure
- Used for: SPEC.md, GLOBAL.md, PHASE_*.md, CHANGELOG.md, README.md, other docs

### Designer
- Input: SPEC.md path
- Output: architecture decisions, phase breakdown, dependency analysis

### Coder
- Input: phase ID, PLAN file path, worktree path (if parallel)
- Output: files changed, test results, commit hash

### code-validator
- Input: phase ID, expected checklist
- Output: validation result, issues found

### spec-validator
- Input: all document paths
- Output: consistency check result, issues found

## Question Sets (for Orchestrator)

### Feature Questions
1. 목표 (goal)
2. 문제 (problem)
3. 핵심 기능 (core_features)
4. 부가 기능 (optional_features)
5. 기술 제약 (constraints)
6. 성능 요구 (performance)
7. 보안 고려 (security)
8. 범위 제외 (out_of_scope)

### Bugfix Questions
1. 버그 증상 (symptom)
2. 재현 조건 (reproduction)
3. 예상 원인 (expected_cause)
4. 심각도 (severity)
5. 관련 파일 (related_files)
6. 영향 범위 (impact_scope)

### Refactor Questions
1. 대상 (target)
2. 문제점 (problems)
3. 목표 상태 (goal_state)
4. 동작 변경 여부 (behavior_change)
5. 테스트 현황 (test_status)
6. 의존 모듈 (dependencies)

## Non-Functional Requirements

### NFR-1: Token Efficiency
- Orchestrator passes minimal context to subagents
- Subagents read files directly (paths only in prompt)
- Results are structured YAML, not prose

### NFR-2: Resumability
- Orchestrator can resume from failure point
- GLOBAL.md phase status serves as checkpoint
- Re-invoke with checkpoint parameter

### NFR-3: Observability
- Orchestrator reports progress at each major step
- Progress format: `[Step 3/12] Creating SPEC.md via TechnicalWriter...`

## Constraints

- Must work within Claude Code's Task tool capabilities
- Subagents are stateless Task tool calls
- Parallel execution limited by Task tool's parallel call support
- User interaction via AskUserQuestion (orchestrator can use directly)

## Out of Scope

- UI/visual progress indicators beyond text output
- Persistent state database (use files only)
- Modifying existing agent definitions (designer.md, technical-writer.md, etc.)
- Creating new coder agents

## Success Criteria

1. `agents/orchestrator.md` created with clear role definition
2. `/start-new` becomes minimal entry point (only calls orchestrator)
3. Orchestrator manages init phase (questions, SPEC.md via TechnicalWriter)
4. Orchestrator executes full workflow (init → design → code → docs → merge)
5. Parallel phases execute with simultaneous Task calls
6. State management enables resume from failure
7. Manual skill invocation (/design, /code) still works
