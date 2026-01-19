---
name: init-feature
description: Initialize a new feature by gathering requirements and creating SPEC document. Use when starting a new feature, project initialization, or when user invokes /init-feature.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-feature

Initialize a new feature by gathering requirements through step-by-step questions.

**IMPORTANT**: Read `_shared/init-workflow.md` first. This skill follows the common init workflow.

**CRITICAL**: Do NOT use plan mode (EnterPlanMode). Proceed directly through all workflow steps.

## Trigger

User invokes `/init-feature` or is routed from `/start-new`.

## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/init-feature`) | Complete init phase (Steps 1-8), return control to user |
| Via orchestrator (`/start-new`) | Complete init phase, return to orchestrator for workflow continuation |

When called directly, this skill completes after SPEC review (Step 8). User must manually invoke subsequent skills if needed.

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 목표
```
Question: "이 기능의 주요 목표는 무엇인가요?"
Header: "목표"
→ Free text response
```

### Step 2: 문제
```
Question: "어떤 문제를 해결하려고 하나요?"
Header: "문제"
→ Free text response
```

### Step 3: 핵심 기능
```
Question: "반드시 있어야 하는 핵심 기능은 무엇인가요?"
Header: "핵심 기능"
→ Free text (can list multiple)
```

### Step 4: 부가 기능
```
Question: "있으면 좋지만 필수는 아닌 기능이 있나요?"
Header: "부가 기능"
Options:
  - label: "없음"
    description: "필수 기능만 구현"
→ Or free text via "Other"
```

### Step 5: 기술 제약
```
Question: "기술적 제약이 있나요?"
Header: "기술 제약"
Options:
  - label: "언어/프레임워크 지정"
    description: "특정 기술 스택 사용 필요"
  - label: "기존 패턴 따르기"
    description: "코드베이스의 기존 패턴 준수"
  - label: "제약 없음"
    description: "자유롭게 구현 가능"
multiSelect: false
```

### Step 6: 성능 요구
```
Question: "성능 요구사항이 있나요?"
Header: "성능"
Options:
  - label: "있음"
    description: "상세 내용을 입력해주세요"
  - label: "없음"
    description: "특별한 성능 요구사항 없음"
multiSelect: false
```

### Step 7: 보안 고려
```
Question: "보안 고려사항이 있나요?"
Header: "보안"
Options:
  - label: "인증/인가 필요"
    description: "사용자 인증 또는 권한 검증 필요"
  - label: "데이터 암호화"
    description: "민감 데이터 암호화 필요"
  - label: "입력 검증"
    description: "사용자 입력 검증 필요"
  - label: "없음"
    description: "특별한 보안 요구사항 없음"
multiSelect: true
```

### Step 8: 범위 제외
```
Question: "명시적으로 범위에서 제외할 것은?"
Header: "범위 제외"
Options:
  - label: "없음"
    description: "제외할 항목 없음"
→ Or free text via "Other"
```

## Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-8), execute analysis phases.

See `_shared/analysis-phases.md` for detailed instructions.

### Feature-Specific Analysis

#### Step B: Codebase Investigation (Feature Focus)

For new features, focus on:

1. **Similar Functionality Search**
   - Grep for keywords from user's goal (Step 1)
   - Look for existing implementations that overlap
   - Document: "Similar feature found at {file}:{line}"

2. **Modification Points**
   - Identify files that need modification
   - Find integration points (APIs, events, hooks)
   - Document: "Integration required at {file}:{function}"

3. **Pattern Discovery**
   - Find existing patterns to follow (naming conventions, file structure)
   - Identify shared utilities to reuse
   - Document: "Follow pattern from {file}"

#### Step C: Conflict Detection (Feature Focus)

For features, check:
- Does new API conflict with existing API names?
- Does new data model conflict with existing schemas?
- Does new behavior contradict existing feature behavior?

#### Step D: Edge Case Generation (Feature Focus)

Generate cases for:
- New feature with empty/null inputs
- New feature at scale (many items, large data)
- New feature interaction with existing features

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core concept from answers (Steps 1-3)
- Format: `feature/{keyword}`
- Examples:
  - feature/external-api
  - feature/user-metrics
  - feature/step-by-step-init

## Output

1. Feature branch `feature/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` with:
   - Overview (from Steps 1-2)
   - Functional Requirements (from Steps 3-4)
   - Non-Functional Requirements (from Steps 6-7)
   - Constraints (from Step 5)
   - Out of Scope (from Step 8)
   - **Analysis Results** (from Analysis Phase):
     - Related Code (existing similar functionality)
     - Conflicts Identified (with resolutions)
     - Edge Cases (confirmed by user)

**Note**: Scope selection and subsequent workflow handled by orchestrator when invoked via `/start-new`.

## Workflow Integration

This skill handles Steps 1-8 of the init phase:
1. Requirements gathering (skill-specific questions)
2. Branch keyword generation
3. Branch and directory creation
4. Analysis Phase (A-E)
5. SPEC.md creation
6. SPEC.md commit
7. User review

See `_shared/init-workflow.md` for init phase details.
See `orchestrator.md` for full workflow (when invoked via /start-new).
