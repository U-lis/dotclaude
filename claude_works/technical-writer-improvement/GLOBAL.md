# Technical Writer Improvement - Global Documentation

## Feature Overview

### Purpose
Improve TechnicalWriter agent reliability and workflow traceability.

### Problem
1. SPEC.md content may not accurately reflect discussed requirements
2. Documents not tracked in git before proceeding to next step

### Solution
1. Add SOT awareness rules to TechnicalWriter agent
2. Add mandatory commit step to init-* and design workflows

## Architecture Decision

### Approach
Direct modification of existing markdown files:
- Agent definition: `.claude/agents/technical-writer.md`
- Skill definitions: `.claude/skills/*/SKILL.md`

No new files or structural changes required.

## File Structure

### Files to Modify

| File | Change |
|------|--------|
| `.claude/agents/technical-writer.md` | Add "Critical Rules" section with SOT awareness |
| `.claude/skills/design/SKILL.md` | Add Step 4 (Commit Documents) |
| `.claude/skills/init-feature/SKILL.md` | Add Step 6 (Commit SPEC.md) |
| `.claude/skills/init-bugfix/SKILL.md` | Add Step 6 (Commit SPEC.md) |
| `.claude/skills/init-refactor/SKILL.md` | Add Step 6 (Commit SPEC.md) |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Modify all 5 files | 🟢 Complete | None |

## Completion Criteria

- [ ] All 5 files modified
- [ ] Changes committed
- [ ] Merged to main
