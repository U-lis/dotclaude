# Mandatory Validation

## Overview

### Goal
Enforce code-validator execution and checklist updates as mandatory steps in /code workflow, with Stop hook as safety net.

### Problem
Current /code skill has code-validator invocation documented but not enforced:
- Agent may skip validation step
- PHASE_*_PLAN.md checklists remain unchecked after implementation
- GLOBAL.md phase status not updated
- No mechanism to detect incomplete validation before session end

### Target State
1. /code skill explicitly mandates code-validator invocation
2. code-validator MUST update PHASE_*_PLAN.md checklists
3. code-validator MUST update GLOBAL.md phase status
4. Stop hook warns if unchecked items exist with code changes

## Functional Requirements

### Core (Must Have)

#### 1. /code Skill Enhancement
- Add "Mandatory Validation" section with explicit enforcement language
- Define validation loop: Coder → code-validator → fix → repeat (max 3)
- Require checklist updates before commit

#### 2. code-validator Agent Enhancement
- Clarify checklist update is MANDATORY, not optional
- Define exact update format for PHASE_*_PLAN.md
- Define exact update format for GLOBAL.md Phase Overview table

#### 3. Stop Hook Implementation
- Create `check-validation-complete.sh`
- Detect: uncommitted code changes + unchecked PHASE_*_PLAN.md items
- Output: block with reason if validation incomplete
- Allow: if on main branch or no code changes or all items checked

### Optional (Nice to Have)
- Validation retry logic (max 3 attempts, then skip with report)

## Non-Functional Requirements

### Performance
- Stop hook must complete within 5 seconds

### Security
- None specified

## Constraints

### Technical
- Use existing hook infrastructure (settings.json + shell script)
- Follow existing check-init-complete.sh pattern
- MD instruction changes only (no code implementation)

## Out of Scope
- PostToolUse hook approach (poor usability due to per-file execution)
- Automatic code fixing by hook
- Integration with external CI/CD
