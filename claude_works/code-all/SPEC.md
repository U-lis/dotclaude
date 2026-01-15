# /code all - Feature Specification

## Overview

**Purpose**: Add `/code all` option to automatically execute all phases without user intervention.

**Problem**: Currently `/code [phase]` requires manual invocation for each phase. For projects with many phases, this is tedious and interrupts automation workflows.

**Solution**: Add `all` argument that orchestrates automatic execution of all phases in dependency order.

---

## Functional Requirements

### Core Features

- [ ] Detect all phases from GLOBAL.md Phase Overview table
- [ ] Fallback: detect phases from PHASE_*_PLAN_*.md files
- [ ] Build dependency graph from Dependencies column
- [ ] Execute phases in topological order (layers)
- [ ] Support parallel phases (3A, 3B, 3C) with git worktrees
- [ ] Execute merge phases (3.5) after parallel phases complete
- [ ] Auto-commit after each successful phase
- [ ] Generate comprehensive final report

### Error Handling

- [ ] Per-phase: 3 retry attempts (existing pattern)
- [ ] On failure: mark SKIPPED, continue to next phase
- [ ] Aggregate all issues for final report
- [ ] Report unresolved issues with file/line information

### Output

- [ ] Summary: total phases, successful, skipped counts
- [ ] Per-phase results table with status and commit hash
- [ ] Issues requiring manual review section
- [ ] Next steps recommendations

---

## Non-Functional Requirements

- Must work with existing skill system architecture
- Must not break existing `/code [phase]` behavior
- Must follow existing commit message format
- Must respect CLAUDE.md rules (with documented exceptions)

---

## Constraints

- Single-agent execution (no true parallelism)
- Parallel phases execute sequentially but in isolated worktrees
- Requires GLOBAL.md or PHASE_*_PLAN_*.md files to exist

---

## Out of Scope

- True parallel execution (background tasks)
- Resume capability (`/code all --resume`)
- Interactive confirmation mode (`/code all --confirm`)
- Phase-orchestrator agent (optional, not required for MVP)
