# init-xxx Skill to Agent Migration - Global Documentation

## Feature Overview

**Purpose**: Migrate init-xxx skills to hybrid agent pattern for architectural consistency.

**Problem**:
- orchestrator calls init-xxx via Skill tool while calling other agents via Task tool
- init-xxx skills contain agent-like logic (~200 lines) but exist in skills/ directory
- Inconsistent with established `/start-new → orchestrator` pattern

**Solution**:
- Create init-xxx agents in `agents/` directory with full logic
- Reduce init-xxx skills to thin wrappers (~30 lines) that delegate to agents
- Update orchestrator to call init-xxx agents via Task tool
- Move shared workflow files from `skills/_shared/` to `agents/_shared/`

---

## Architecture Decision

### Pattern Selection
**Options Considered**:
1. Option A: Full agent migration (remove skills entirely)
2. Option B: Hybrid pattern (thin skill wrapper + full agent)

**Decision**: Option B (Hybrid pattern)

**Rationale**:
- Preserves direct user invocability via `/init-xxx`
- Maintains hook execution on skill exit (Stop hook for SPEC commit check)
- Consistent with `/start-new → orchestrator` pattern already in use
- Clean separation: skills handle invocation, agents handle logic

### Shared File Location
**Options Considered**:
1. Keep in `skills/_shared/`
2. Move to `agents/_shared/`

**Decision**: Move to `agents/_shared/`

**Rationale**:
- Shared files (init-workflow.md, analysis-phases.md) contain agent instructions
- After migration, agents are primary consumers of these files
- Maintains logical grouping of agent-related content

---

## File Structure

### Files to Create
```
.claude/agents/
├── _shared/
│   ├── init-workflow.md      # Moved from skills/_shared/
│   └── analysis-phases.md    # Moved from skills/_shared/
├── init-feature.md           # ~200 lines, full init-feature logic
├── init-bugfix.md            # ~200 lines, full init-bugfix logic
└── init-refactor.md          # ~200 lines, full init-refactor logic
```

### Files to Modify
```
.claude/skills/init-feature/SKILL.md   # Reduce to ~30 lines thin wrapper
.claude/skills/init-bugfix/SKILL.md    # Reduce to ~30 lines thin wrapper
.claude/skills/init-refactor/SKILL.md  # Reduce to ~30 lines thin wrapper
.claude/agents/orchestrator.md         # Lines 8, 15, 40-44, 203-225: Skill→Task tool
```

### Files to Delete
```
.claude/skills/_shared/init-workflow.md    # After move to agents/_shared/
.claude/skills/_shared/analysis-phases.md  # After move to agents/_shared/
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 0 | Move _shared/ directory | Pending | - |
| 1 | Create init-xxx agents | Pending | Phase 0 |
| 2 | Convert skills to thin wrappers | Pending | Phase 1 |
| 3 | Update orchestrator references | Pending | Phase 2 |

**Status Legend**:
- Pending: Not started
- In Progress: Currently executing
- Complete: Finished successfully
- Skipped: Bypassed due to error

---

## Phase Dependencies

```
Phase 0 (Move _shared/)
    ↓
Phase 1 (Create agents)
    ↓
Phase 2 (Convert skills)
    ↓
Phase 3 (Update orchestrator)
```

All phases are SEQUENTIAL. Each phase depends on the previous phase completion.

---

## Risk Mitigation

### Risk 1: Path Reference Breakage
**Impact**: Medium
**Mitigation**:
- Update all internal references to _shared/ files in Phase 1
- Verify paths compile/resolve correctly before proceeding

### Risk 2: Hook Execution Loss
**Impact**: High
**Mitigation**:
- Keep hooks in skill YAML frontmatter (thin wrapper)
- Verify Stop hook executes on skill exit

### Risk 3: Behavior Divergence
**Impact**: High
**Mitigation**:
- Copy logic verbatim from skills to agents
- No behavior changes - pure structural refactoring
- Manual verification after each phase

---

## Completion Criteria

Overall migration is complete when:
- [ ] All phases marked Complete
- [ ] `/init-feature` direct invocation works identically
- [ ] `/start-new` → orchestrator → init agent flow works
- [ ] Stop hook executes on skill exit
- [ ] No orphaned files in `skills/_shared/`

---

## Version

Target version: 0.0.9
