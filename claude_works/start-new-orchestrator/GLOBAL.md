# Orchestrator Integration - Global Documentation

## Feature Overview

### Purpose
Integrate orchestrator agent directly into /start-new skill to enable AskUserQuestion tool usage throughout the main workflow.

### Problem
- Task tool spawns subagents in isolated context
- Subagents cannot use AskUserQuestion tool (main-agent-only capability)
- Current architecture: skill -> Task -> orchestrator -> Task -> init-xxx
- AskUserQuestion needed at Steps 1, 3, 5 fails in subagent context

### Solution
- Convert orchestrator from agent to skill instructions
- Merge orchestrator + init-workflow content into /start-new/SKILL.md
- Move init-xxx agents into skill directory as conditional instruction files
- Main agent executes orchestrator role directly

## Architecture Decision

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| Merge orchestrator into SKILL.md | AskUserQuestion requires main agent context |
| Keep init-xxx as separate files | Conditional loading reduces token usage |
| Move analysis-phases to _analysis.md | Shared reference, loaded only when needed |
| Inline hook validation in SKILL.md | Step 6 checkpoint before design phase |
| Delete individual init-xxx skills | No longer needed - internal instructions only |

### File Structure (After)

```
.claude/skills/start-new/
├── SKILL.md          # Orchestrator 13-step workflow + init-workflow rules (~400 lines)
├── _analysis.md      # Common analysis phases A-E (~140 lines)
├── init-feature.md   # Feature questions + feature-specific analysis (~150 lines)
├── init-bugfix.md    # Bugfix questions + bugfix-specific analysis (~180 lines)
└── init-refactor.md  # Refactor questions + refactor-specific analysis (~160 lines)
```

Total: 1,372 lines (24% reduction from 1,815 lines)

## Data Model

### No Data Model Changes
- SPEC.md output format unchanged
- Branch naming convention unchanged
- Output contract unchanged

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Create new file structure (5 files) | Complete | None |
| 2 | Update references to deleted paths | Complete | Phase 1 |
| 3 | Delete old files (6 agents, 3 skills, 1 hook) | Complete | Phase 2 |
| 4 | End-to-end validation | Complete | Phase 3 |

## File Operations Summary

### Phase 1: Create Files

| File | Source | Estimated Lines |
|------|--------|-----------------|
| skills/start-new/SKILL.md | orchestrator.md + init-workflow.md | ~400 |
| skills/start-new/_analysis.md | analysis-phases.md | ~140 |
| skills/start-new/init-feature.md | agents/init-feature.md | ~150 |
| skills/start-new/init-bugfix.md | agents/init-bugfix.md | ~180 |
| skills/start-new/init-refactor.md | agents/init-refactor.md | ~160 |

### Phase 3: Delete Files

| Category | Files |
|----------|-------|
| Agents | orchestrator.md, init-feature.md, init-bugfix.md, init-refactor.md |
| Shared | _shared/init-workflow.md, _shared/analysis-phases.md |
| Skills | init-feature/, init-bugfix/, init-refactor/ directories |
| Hooks | check-init-complete.sh |

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Conditional loading may not work | Test file reference pattern before full implementation |
| AskUserQuestion may still fail | Verify tool availability in skill context |
| Workflow regression | Phase 4 comprehensive testing with all 3 work types |

## Success Metrics

1. `/start-new` executes full 13-step workflow
2. AskUserQuestion works at Steps 1, 3, 5
3. All three work types produce valid SPEC.md
4. Line count reduced by ~43%
5. No regression in other skills (design, code, etc.)
