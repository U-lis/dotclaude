# SPEC: init-xxx Skill → Agent Migration

## Overview

Migrate init-xxx skills to hybrid pattern: create init-xxx agents containing complex logic, keep thin wrapper skills for user invocation.

**Pattern Reference**: Same as existing `/start-new skill → orchestrator agent`

## Target

| Component | Action |
|-----------|--------|
| `.claude/skills/init-feature/SKILL.md` | Reduce to thin wrapper (~30 lines) |
| `.claude/skills/init-bugfix/SKILL.md` | Reduce to thin wrapper (~30 lines) |
| `.claude/skills/init-refactor/SKILL.md` | Reduce to thin wrapper (~30 lines) |
| `.claude/agents/init-feature.md` | CREATE (~200 lines, moved logic) |
| `.claude/agents/init-bugfix.md` | CREATE (~200 lines, moved logic) |
| `.claude/agents/init-refactor.md` | CREATE (~200 lines, moved logic) |
| `.claude/skills/_shared/` | MOVE to `.claude/agents/_shared/` |
| `.claude/agents/orchestrator.md` | MODIFY (Skill tool → Task tool) |

## Current Problems

- orchestrator manages all workflows but calls init-xxx via Skill tool
- init-xxx performs agent-like work (codebase analysis, multi-step workflow) but exists as skills
- Structural inconsistency with `/start-new → orchestrator` pattern

## Goal State

```
CURRENT:
/init-feature (skill, ~200 lines of logic)
     ↓ (direct execution)
  8-step workflow + analysis

TARGET:
/init-feature (thin skill, ~30 lines)
     ↓ Task tool
init-feature agent (~200 lines of logic)
     ↓
  8-step workflow + analysis
```

**Consistency**: orchestrator calls init-xxx agents via Task tool (same pattern as Designer, TechnicalWriter, Coder)

## Behavior Change Policy

| Aspect | Policy |
|--------|--------|
| Orchestrator init-xxx call pattern | CHANGE: Skill tool → Task tool |
| Direct `/init-feature` invocation | PRESERVE: Same user experience |
| Workflow steps 1-8 | PRESERVE: Identical execution |
| Hook execution | PRESERVE: Stop hook on thin wrapper skill |

## Test Coverage

No existing tests found. Manual verification required:
1. Direct invocation: `/init-feature` works same as before
2. Orchestrator flow: `/start-new` → init agent → returns correctly
3. Hook execution: Stop hook blocks exit if SPEC not committed

## Dependencies

| Dependent | Impact |
|-----------|--------|
| `orchestrator.md` | Lines 8, 15, 40-44, 203-225 need modification |
| `settings.json` | No change needed (skill registration unchanged) |
| Other workflows | No impact (init-xxx interface preserved) |

## XP Principle Reference

- **Single Responsibility Principle**: Skills handle user invocation, Agents handle complex logic
- **Consistency**: All agent-like work done by agents (orchestrator pattern)
- **DRY**: Shared workflow files centralized in `agents/_shared/`

---

## Analysis Results

### Related Code

| # | File | Lines | Relationship |
|---|------|-------|--------------|
| 1 | `.claude/skills/init-feature/SKILL.md` | 201 | Refactor target: move to agent |
| 2 | `.claude/skills/init-bugfix/SKILL.md` | 246 | Refactor target: move to agent |
| 3 | `.claude/skills/init-refactor/SKILL.md` | 222 | Refactor target: move to agent |
| 4 | `.claude/skills/_shared/init-workflow.md` | 145 | Move to agents/_shared/ |
| 5 | `.claude/skills/_shared/analysis-phases.md` | 237 | Move to agents/_shared/ |
| 6 | `.claude/agents/orchestrator.md` | 508 | Modify: Skill→Task tool |
| 7 | `.claude/skills/start-new/SKILL.md` | 94 | Pattern reference: thin wrapper |

### Dependency Map

```
orchestrator.md
  └─→ init-feature (Skill tool) → Task tool
  └─→ init-bugfix (Skill tool) → Task tool
  └─→ init-refactor (Skill tool) → Task tool

init-xxx/SKILL.md (each)
  └─→ _shared/init-workflow.md
  └─→ _shared/analysis-phases.md
```

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | orchestrator uses `Skill tool: init-feature` | `Task tool → init-feature agent` | Modify orchestrator.md (4 locations) |
| 2 | init-xxx skills contain full logic (~200 lines) | thin wrapper (~30 lines) + agent (~200 lines) | Create agents, reduce skills |
| 3 | `_shared/` under skills/ directory | `_shared/` under agents/ directory | Move files, update internal references |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | `/init-feature` direct invocation | Delegate to agent, execute identical workflow |
| 2 | `/start-new` → orchestrator → init-feature agent | Task tool calls agent, returns structured output |
| 3 | Verify branch/SPEC.md after init agent completes | orchestrator verifies branch checkout state, SPEC.md exists |
| 4 | `_shared/` reference path change | Correctly reference `agents/_shared/` path |
| 5 | Hook execution on thin wrapper | Stop hook executes normally on skill exit |

### Test Coverage Assessment

- **Existing tests**: None found
- **Required verification**:
  - Direct invocation test (manual)
  - Orchestrator integration test (manual)
  - Hook execution test (manual)
