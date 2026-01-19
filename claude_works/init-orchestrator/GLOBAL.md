# Master Orchestrator - Global Documentation

## Feature Overview

### Purpose
Create a Master Orchestrator agent that governs the entire workflow from init to merge.

### Problem
- Current chaining approach lacks central control
- No true parallel execution capability
- No cross-phase state management
- Init questions not processed through TechnicalWriter

### Solution
- New `agents/orchestrator.md` as central controller
- `/start-new` becomes minimal entry point
- Orchestrator manages all phases via Task tool
- Supports parallel execution for parallel phases

## Architecture Decision

### Decision 1: Orchestrator as Agent (not Skill)
**Rationale**: Agent can be invoked via Task tool, enabling:
- Subagent coordination
- State management within single context
- Parallel Task tool calls

### Decision 2: Minimal /start-new
**Rationale**:
- Single entry point for users
- All logic delegated to orchestrator
- Simplifies skill maintenance

### Decision 3: Preserve Manual Skills
**Rationale**:
- /design, /code remain invocable for debugging
- Orchestrator bypass available when needed

## File Structure

### Files to Create
| File | Description |
|------|-------------|
| `.claude/agents/orchestrator.md` | Orchestrator agent definition |

### Files to Modify
| File | Changes |
|------|---------|
| `.claude/skills/start-new/SKILL.md` | Minimal entry, call orchestrator |
| `README.md` | Update workflow description |

### Files Unchanged (Manual Mode)
| File | Reason |
|------|--------|
| `init-feature/SKILL.md` | Manual invocation support |
| `init-bugfix/SKILL.md` | Manual invocation support |
| `init-refactor/SKILL.md` | Manual invocation support |
| `design/SKILL.md` | Manual invocation support |
| `code/SKILL.md` | Manual invocation support |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Create orchestrator.md | Complete | None |
| 2 | Update start-new/SKILL.md | Complete | Phase 1 |
| 3 | Update README.md, cleanup | Pending | Phase 1, 2 |

## Orchestrator Agent Structure

```
agents/orchestrator.md
├── Role definition
├── Capabilities
├── 16-step workflow
├── Question sets (Feature/Bugfix/Refactor)
├── Subagent call instructions
│   ├── TechnicalWriter call pattern
│   ├── Designer call pattern
│   ├── Coder call pattern
│   └── code-validator call pattern
├── Parallel execution logic
├── State management
└── Error handling
```

## Key Implementation Notes

### AskUserQuestion Usage
Orchestrator uses AskUserQuestion directly for:
- Work type selection (step 1)
- Work-type-specific questions (step 2)
- Target version selection (step 4)
- SPEC review (step 6)
- Scope selection (step 8)

### Task Tool Calls
Orchestrator calls subagents via Task tool:
```
Task tool → TechnicalWriter (SPEC.md, GLOBAL.md, PHASE_*.md, docs)
Task tool → Designer (architecture analysis)
Task tool → Coder (implementation)
Task tool → code-validator (validation)
```

### Parallel Execution
For parallel phases (e.g., 3A, 3B, 3C):
```
Single message with multiple Task tool calls:
  Task(coder, phase=3A)
  Task(coder, phase=3B)
  Task(coder, phase=3C)
→ All execute simultaneously
→ Collect all results
→ Proceed to merge phase
```

### State Tracking
State tracked via:
- GLOBAL.md Phase Overview table (status column)
- Orchestrator's internal tracking during execution
- Resume capability by re-reading GLOBAL.md status
