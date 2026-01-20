# Phase 1: Create init-xxx Agents

## Objective

Create three agent files containing full init workflow logic extracted from current skill files.

---

## Prerequisites

- [ ] Phase 0 completed (_shared/ files moved to agents/_shared/)
- [ ] Files exist at `agents/_shared/init-workflow.md` and `agents/_shared/analysis-phases.md`

---

## Scope

### In Scope
- Create `agents/init-feature.md` (~200 lines)
- Create `agents/init-bugfix.md` (~200 lines)
- Create `agents/init-refactor.md` (~200 lines)
- Update internal references to `_shared/` path

### Out of Scope
- Modifying skill files (handled in Phase 2)
- Modifying orchestrator (handled in Phase 3)

---

## Instructions

### Step 1: Create init-feature.md Agent

**File**: `.claude/agents/init-feature.md`

**Action**: Create new agent file with the following structure:

```markdown
# init-feature Agent

You are the **init-feature agent**, responsible for initializing new feature work through requirements gathering and SPEC creation.

## Role

- Gather feature requirements through step-by-step questions
- Execute codebase analysis (related code, conflicts, edge cases)
- Create branch and project directory
- Draft SPEC.md via TechnicalWriter

## Reference

- Read `_shared/init-workflow.md` for common init workflow
- Read `_shared/analysis-phases.md` for analysis phase details

## [REST OF CONTENT FROM skills/init-feature/SKILL.md]
```

**Content Source**: Copy lines 12-201 from `.claude/skills/init-feature/SKILL.md`

**Modifications Required**:
1. Replace frontmatter+trigger section with agent header (Role, Reference)
2. Update `_shared/` references from relative to agent context path
3. Remove "Workflow Integration" section (handled by thin wrapper)
4. Keep all step-by-step questions, analysis phase, branch keyword, output sections

### Step 2: Create init-bugfix.md Agent

**File**: `.claude/agents/init-bugfix.md`

**Action**: Create new agent file with the following structure:

```markdown
# init-bugfix Agent

You are the **init-bugfix agent**, responsible for initializing bug fix work through bug detail gathering and root cause analysis.

## Role

- Gather bug details through step-by-step questions
- Execute codebase analysis (root cause, affected code, conflicts)
- Create branch and project directory
- Draft SPEC.md via TechnicalWriter

## Reference

- Read `_shared/init-workflow.md` for common init workflow
- Read `_shared/analysis-phases.md` for analysis phase details

## [REST OF CONTENT FROM skills/init-bugfix/SKILL.md]
```

**Content Source**: Copy lines 12-246 from `.claude/skills/init-bugfix/SKILL.md`

**Modifications Required**:
1. Replace frontmatter+trigger section with agent header (Role, Reference)
2. Update `_shared/` references from relative to agent context path
3. Remove "Workflow Integration" section (handled by thin wrapper)
4. Keep all step-by-step questions, analysis phase (bugfix-specific), branch keyword, output sections

### Step 3: Create init-refactor.md Agent

**File**: `.claude/agents/init-refactor.md`

**Action**: Create new agent file with the following structure:

```markdown
# init-refactor Agent

You are the **init-refactor agent**, responsible for initializing refactoring work through target analysis and dependency mapping.

## Role

- Gather refactor details through step-by-step questions
- Execute codebase analysis (dependencies, test coverage, conflicts)
- Create branch and project directory
- Draft SPEC.md via TechnicalWriter

## Reference

- Read `_shared/init-workflow.md` for common init workflow
- Read `_shared/analysis-phases.md` for analysis phase details

## [REST OF CONTENT FROM skills/init-refactor/SKILL.md]
```

**Content Source**: Copy lines 12-222 from `.claude/skills/init-refactor/SKILL.md`

**Modifications Required**:
1. Replace frontmatter+trigger section with agent header (Role, Reference)
2. Update `_shared/` references from relative to agent context path
3. Remove "Workflow Integration" section (handled by thin wrapper)
4. Keep all step-by-step questions, analysis phase (refactor-specific), branch keyword, output sections

### Step 4: Update _shared/ References in Agent Files

**Files**: All three newly created agent files

**Action**: Update internal references to _shared/ files

Find and replace in each agent file:
- `_shared/init-workflow.md` stays as is (relative to agent location)
- `_shared/analysis-phases.md` stays as is (relative to agent location)

Note: The path `_shared/` is now relative to `agents/` directory where the agents reside.

### Step 5: Add Output Contract Section

**Action**: Add output contract to each agent file (end of file)

```markdown
## Output Contract

Return structured result when init phase completes:

```yaml
branch: "{type}/{keyword}"
subject: "{keyword}"
spec_path: "claude_works/{subject}/SPEC.md"
status: "SUCCESS" | "FAILED"
error: "{error message if FAILED}"
```
```

---

## Implementation Notes

### Agent File Structure
Each agent file should have:
1. Agent header (name, role description)
2. Role section (what the agent does)
3. Reference section (links to _shared/ files)
4. Step-by-step questions (copied from skill)
5. Analysis phase section (work-type specific)
6. Branch keyword section
7. Output section
8. Output contract (for orchestrator integration)

### Content Preservation
- Copy logic verbatim from skills to agents
- No behavioral changes - pure structural migration
- Work-type specific analysis details must be preserved

### Reference Path Convention
- Agent files reference `_shared/` relative to their location in `agents/`
- Example: `agents/init-feature.md` references `_shared/init-workflow.md`
- This resolves to `agents/_shared/init-workflow.md`

---

## Completion Checklist

- [ ] `agents/init-feature.md` created (~200 lines)
- [ ] `agents/init-bugfix.md` created (~200 lines)
- [ ] `agents/init-refactor.md` created (~200 lines)
- [ ] All agents have Role section
- [ ] All agents have Reference section pointing to `_shared/`
- [ ] All agents have step-by-step questions preserved
- [ ] All agents have analysis phase details preserved
- [ ] All agents have output contract section
- [ ] No behavior changes from original skill logic

---

## Verification

### Manual Verification
```bash
# Verify files created
ls -la .claude/agents/init-*.md

# Verify line counts (approximate)
wc -l .claude/agents/init-feature.md  # ~200 lines
wc -l .claude/agents/init-bugfix.md   # ~220 lines
wc -l .claude/agents/init-refactor.md # ~200 lines

# Verify _shared/ references
grep -n "_shared/" .claude/agents/init-*.md
```

### Expected Output
```
.claude/agents/init-feature.md   (~200 lines)
.claude/agents/init-bugfix.md    (~220 lines)
.claude/agents/init-refactor.md  (~200 lines)

Each file should contain references to:
- _shared/init-workflow.md
- _shared/analysis-phases.md
```

---

## Notes

- Agent files do NOT have YAML frontmatter (that stays in skill wrappers)
- Agent files do NOT have hooks (hooks stay in skill wrappers)
- Agent files focus on execution logic, not invocation metadata
- Skills will delegate to these agents in Phase 2

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
