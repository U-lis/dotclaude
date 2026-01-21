# Orchestrator Integration into /start-new - Specification

## Overview

**Purpose**: Integrate orchestrator agent directly into /start-new skill to enable AskUserQuestion tool usage in the main workflow.

**Problem**:
- Current architecture uses Task tool to call orchestrator agent as subprocess
- Subagents spawned via Task tool cannot use AskUserQuestion tool
- This breaks the designed 13-step workflow where orchestrator must interact with users at Steps 1, 3, and 5

**Solution**:
- Convert orchestrator from agent to skill instructions (integrate into /start-new/SKILL.md)
- Move init-xxx agent content into skills/start-new/ directory as conditionally-loaded files
- Main agent executes orchestrator role directly, enabling AskUserQuestion

---

## Refactoring Rationale

### XP Principle: Simplicity (Do The Simplest Thing That Could Possibly Work)

**Current State (Code Smell)**:
- 10 files with 1,795 total lines
- Double indirection: skill wrapper -> Task tool -> agent -> Task tool -> sub-agent
- AskUserQuestion tool unavailable in subagent context
- Orchestrator context lost when Task tool completes

**Proposed State**:
- 5 files with ~1,030 total lines (~43% reduction)
- Single level: skill -> conditionally loaded init-xxx
- AskUserQuestion tool available directly
- Orchestrator context maintained throughout workflow

### Clean Architecture Principle: Dependency Rule Violation

**Current Issue**:
- Skill files (UI layer) depend on agents (application layer) through Task tool indirection
- The skill wrapper files are pure boilerplate, adding no value
- Each init-xxx skill is a trivial 62-line wrapper that calls its agent via Task tool

**Resolution**:
- Merge agent content into skill layer
- Remove unnecessary indirection layer
- Skill becomes the single source of truth for workflow

---

## Functional Requirements

### Core Features

- [ ] FR-1: Main agent executes orchestrator 13-step workflow directly (no Task tool for orchestrator)
- [ ] FR-2: AskUserQuestion tool works at Steps 1, 3, and 5 (work type selection, SPEC review, scope selection)
- [ ] FR-3: Conditional loading of init-xxx content based on work type selection
- [ ] FR-4: Analysis phases A-E remain available via _analysis.md reference
- [ ] FR-5: Init-xxx content preserves all step-by-step questions and work-type-specific analysis

### Behavioral Preservation

- [ ] FR-6: 13-step workflow sequence unchanged (Steps 1-13 remain in same order)
- [ ] FR-7: TechnicalWriter, Designer, Coder, code-validator still invoked via Task tool
- [ ] FR-8: Parallel phase execution with worktrees still supported
- [ ] FR-9: Non-stop execution mode after scope selection unchanged
- [ ] FR-10: Error handling and retry logic (max 3 attempts per phase) preserved

### Skill Invocation

- [ ] FR-11: `/start-new` command triggers orchestrator workflow (same as current)
- [ ] FR-12: `/init-feature`, `/init-bugfix`, `/init-refactor` remain as direct bypass options
- [ ] FR-13: Hooks on init skills (check-init-complete.sh) preserved if still needed

---

## Non-Functional Requirements

### Token Efficiency

- [ ] NFR-1: Reduce total file size from 1,795 to ~1,030 lines (~43% reduction)
- [ ] NFR-2: Conditional loading: only load init-{type}.md matching user selection
- [ ] NFR-3: Remove duplicate content between init-workflow.md and each init-xxx agent

### Maintainability

- [ ] NFR-4: Single location for orchestrator workflow logic (no skill + agent duplication)
- [ ] NFR-5: Clear separation: SKILL.md (orchestrator + workflow), init-{type}.md (questions + type-specific analysis)
- [ ] NFR-6: _analysis.md remains as shared reference for common analysis phases

### Backward Compatibility

- [ ] NFR-7: User-facing commands unchanged (`/start-new`, `/init-feature`, etc.)
- [ ] NFR-8: Output contract (branch, subject, spec_path, status) unchanged
- [ ] NFR-9: SPEC.md format unchanged (includes Analysis Results section)

---

## File Transformation Plan

### Files to Create

| Target File | Source | Content |
|-------------|--------|---------|
| `skills/start-new/SKILL.md` | `agents/orchestrator.md` + `agents/_shared/init-workflow.md` | Orchestrator 13-step workflow + init workflow rules |
| `skills/start-new/_analysis.md` | `agents/_shared/analysis-phases.md` | Common analysis phases A-E (unchanged) |
| `skills/start-new/init-feature.md` | `agents/init-feature.md` | Feature questions + feature-specific analysis (Steps 1-8, B-D specifics) |
| `skills/start-new/init-bugfix.md` | `agents/init-bugfix.md` | Bugfix questions + bugfix-specific analysis (Steps 1-6, B-D specifics) |
| `skills/start-new/init-refactor.md` | `agents/init-refactor.md` | Refactor questions + refactor-specific analysis (Steps 1-6, B-D specifics) |

### Files to Delete

| File | Reason |
|------|--------|
| `agents/orchestrator.md` | Merged into skills/start-new/SKILL.md |
| `agents/init-feature.md` | Moved to skills/start-new/init-feature.md |
| `agents/init-bugfix.md` | Moved to skills/start-new/init-bugfix.md |
| `agents/init-refactor.md` | Moved to skills/start-new/init-refactor.md |
| `agents/_shared/init-workflow.md` | Merged into skills/start-new/SKILL.md |
| `agents/_shared/analysis-phases.md` | Moved to skills/start-new/_analysis.md |
| `skills/init-feature/SKILL.md` | Wrapper no longer needed |
| `skills/init-bugfix/SKILL.md` | Wrapper no longer needed |
| `skills/init-refactor/SKILL.md` | Wrapper no longer needed |

### Line Count Comparison

| Current | Lines | Proposed | Lines |
|---------|-------|----------|-------|
| agents/orchestrator.md | 497 | skills/start-new/SKILL.md | ~400 |
| agents/init-feature.md | 191 | skills/start-new/init-feature.md | ~150 |
| agents/init-bugfix.md | 236 | skills/start-new/init-bugfix.md | ~180 |
| agents/init-refactor.md | 212 | skills/start-new/init-refactor.md | ~160 |
| agents/_shared/init-workflow.md | 144 | (merged into SKILL.md) | 0 |
| agents/_shared/analysis-phases.md | 237 | skills/start-new/_analysis.md | ~140 |
| skills/init-feature/SKILL.md | 62 | (deleted) | 0 |
| skills/init-bugfix/SKILL.md | 62 | (deleted) | 0 |
| skills/init-refactor/SKILL.md | 62 | (deleted) | 0 |
| skills/start-new/SKILL.md | 92 | (replaced) | 0 |
| **Total** | **1,795** | **Total** | **~1,030** |

---

## Constraints

### Technical Constraints

- Platform: Claude Code skills framework
- File format: Markdown with YAML frontmatter
- Skill loader: Must follow `.claude/skills/{name}/SKILL.md` convention
- Conditional loading: Reference other .md files using "Read {file}" instruction pattern

### Behavioral Constraints

- MUST preserve all 13 steps of orchestrator workflow
- MUST NOT change user-facing command invocations
- MUST NOT modify other agents (TechnicalWriter, Designer, Coder, code-validator)
- MUST preserve hooks configuration for init skills if applicable

---

## Out of Scope

The following are explicitly NOT part of this work:

- Modifying Designer, TechnicalWriter, Coder, or code-validator agents
- Changing the 13-step workflow sequence
- Adding new features to orchestrator
- Modifying the parallel phase execution mechanism
- Changing SPEC.md output format

---

## Assumptions

- Claude Code skill loader supports reading referenced .md files within skill directory
- Conditional loading pattern (e.g., "Read init-feature.md if work type is feature") works correctly
- Main agent has access to AskUserQuestion tool when executing skill instructions directly

---

## Open Questions

- [ ] Should `/init-feature`, `/init-bugfix`, `/init-refactor` remain as separate skills or be deprecated?
  - Recommendation: Keep as aliases that load specific init-xxx.md content for debugging/bypass use
- [ ] Should hooks (check-init-complete.sh) be moved to /start-new or kept on individual init skills?
  - Recommendation: Keep on /start-new only, since init-xxx skills become internal components

---

## Migration Strategy

### Phase 1: Create New Structure

1. Create `skills/start-new/SKILL.md` with merged orchestrator + init-workflow content
2. Create `skills/start-new/_analysis.md` from analysis-phases.md
3. Create `skills/start-new/init-{feature,bugfix,refactor}.md` from agent files

### Phase 2: Update References

1. Update any references to old agent paths
2. Ensure /init-feature, /init-bugfix, /init-refactor skills reference new location

### Phase 3: Delete Old Files

1. Delete `agents/orchestrator.md`
2. Delete `agents/init-{feature,bugfix,refactor}.md`
3. Delete `agents/_shared/init-workflow.md`
4. Delete `agents/_shared/analysis-phases.md`
5. Delete `skills/init-{feature,bugfix,refactor}/SKILL.md`

### Phase 4: Validation

1. Test `/start-new` flow end-to-end
2. Verify AskUserQuestion works at Steps 1, 3, 5
3. Test each work type (feature, bugfix, refactor)
4. Verify direct init skill invocation still works

---

## Success Criteria

1. `/start-new` executes full 13-step workflow with AskUserQuestion working
2. All three work types (feature, bugfix, refactor) produce valid SPEC.md
3. Token usage reduced (verify ~43% line count reduction)
4. No regression in existing functionality

---

## References

- Current orchestrator: `.claude/agents/orchestrator.md` (497 lines)
- Current init-workflow: `.claude/agents/_shared/init-workflow.md` (144 lines)
- Current analysis-phases: `.claude/agents/_shared/analysis-phases.md` (237 lines)
- Current init-feature: `.claude/agents/init-feature.md` (191 lines)
- Current init-bugfix: `.claude/agents/init-bugfix.md` (236 lines)
- Current init-refactor: `.claude/agents/init-refactor.md` (212 lines)
- CLAUDE.md: Global rules and work planning guidelines
