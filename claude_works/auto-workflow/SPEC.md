# Auto Workflow

## Overview

### Goal
Implement user-controlled automation workflow that executes multiple phases without human intervention after SPEC.md approval.

### Problem
Current workflow requires manual confirmation at each step:
- User approves SPEC.md
- Agent asks "What's next? /design?"
- User responds
- Agent completes design
- Agent asks "What's next? /code?"
- (repeats for each phase)

### Target State
After SPEC.md approval:
1. Agent asks once: "이제 개발 계획 작성 및 개발이 가능합니다. 어느 단계까지 진행할까요?"
2. User selects target phase
3. Agent executes all phases up to target without interruption

## Functional Requirements

### Core (Must Have)
- Single selection UI for target phase after SPEC.md approval
- Phase options:
  - design only
  - code + validation
  - main merge
  - tagging
- Non-stop execution from current phase to selected target phase

### Optional (Nice to Have)
- Progress indicator: current phase (k/N)
- Progress percentage display
- Final summary report after all phases complete
  - Console output for user to review completed work

## Non-Functional Requirements

### Performance
- None specified

### Security
- None specified

## Constraints

### Technical
- MD files must be token-efficient: no redundant instructions, no filler text
- Clear, unambiguous language only

## Out of Scope
- None specified
