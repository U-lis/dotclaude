# SPEC: Parallel Phase Detection Enhancement

## Overview

### Goal
Upgrade `/design` skill's parallel phase detection to accurately identify work that can run simultaneously in separate worktrees.

### Problem
Current designer agent assigns sequential phases to work that could run in parallel via git worktrees, missing opportunities for faster execution.

## Functional Requirements

### FR-1: Dependency Analysis
Designer agent MUST analyze dependencies between potential phases:
- File-level: Which files each phase modifies
- Module-level: Cross-module dependencies
- Test-level: Shared test fixtures or data

### FR-2: Parallelization Criteria
Designer agent MUST identify parallel-eligible phases when ALL conditions met:
- No shared file modifications
- No runtime dependencies (Phase B doesn't need Phase A's output)
- Independently testable

### FR-3: Explicit Phase Assignment
Designer agent MUST:
- Assign `PHASE_{k}A`, `PHASE_{k}B` naming for parallel phases
- Create `PHASE_{k}.5_PLAN_MERGE.md` for every parallel group
- Document potential merge conflicts in advance

### FR-4: Conflict Prediction
For parallel phases, designer agent MUST predict:
- Files likely to conflict during merge
- Integration points requiring attention
- Test coordination needs

## Non-Functional Requirements

### NFR-1: Token Efficiency
- No redundant instructions in documents
- No unnecessary prose or embellishments
- Clear, unambiguous phrasing

## Constraints

- Maintain existing document structure (`GLOBAL.md`, `PHASE_*_PLAN_*.md`, etc.)
- Follow current naming conventions
- Compatible with existing `/code` skill

## Out of Scope

- None specified
