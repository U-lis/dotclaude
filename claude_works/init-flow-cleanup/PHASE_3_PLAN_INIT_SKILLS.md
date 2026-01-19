# Phase 3: Update init-xxx SKILL.md Files

## Objective

Update all three init-xxx SKILL.md files to clarify invocation behavior and remove Step 9 references.

## Prerequisites

- Phase 2 complete (init-workflow.md updated)

## Target Files

1. `.claude/skills/init-feature/SKILL.md`
2. `.claude/skills/init-bugfix/SKILL.md`
3. `.claude/skills/init-refactor/SKILL.md`

## Common Changes (Apply to ALL three files)

### 3.1 Add Invocation Behavior Section

**Location**: After "## Trigger" section

**Action**: Add new section (same content for all three, adjust skill name)

For init-feature:
```markdown
## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/init-feature`) | Complete init phase (Steps 1-8), return control to user |
| Via orchestrator (`/start-new`) | Complete init phase, return to orchestrator for workflow continuation |

When called directly, this skill completes after SPEC review (Step 8). User must manually invoke subsequent skills if needed.
```

For init-bugfix:
```markdown
## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/init-bugfix`) | Complete init phase (Steps 1-8), return control to user |
| Via orchestrator (`/start-new`) | Complete init phase, return to orchestrator for workflow continuation |

When called directly, this skill completes after SPEC review (Step 8). User must manually invoke subsequent skills if needed.
```

For init-refactor:
```markdown
## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/init-refactor`) | Complete init phase (Steps 1-8), return control to user |
| Via orchestrator (`/start-new`) | Complete init phase, return to orchestrator for workflow continuation |

When called directly, this skill completes after SPEC review (Step 8). User must manually invoke subsequent skills if needed.
```

### 3.2 Update Output Section

**Location**: "## Output" section

**Action**: Add clarification note at end of section

**Add after existing output list**:
```markdown

**Note**: Scope selection and subsequent workflow handled by orchestrator when invoked via `/start-new`.
```

### 3.3 Update Workflow Integration Section

**Location**: "## Workflow Integration" section

**Action**: Replace entire section

**Current content (similar in all three)**:
```markdown
## Workflow Integration

After Analysis Phase completes:
1. Analysis results are included in SPEC.md
2. SPEC.md is committed (Step 7 in init-workflow)
3. User reviews SPEC.md (Step 8)
4. Next Step Selection (Step 9)

See `_shared/init-workflow.md` for complete workflow.
```

**New content**:
```markdown
## Workflow Integration

This skill handles Steps 1-8 of the init phase:
1. Requirements gathering (skill-specific questions)
2. Branch keyword generation
3. Branch and directory creation
4. Analysis Phase (A-E)
5. SPEC.md creation
6. SPEC.md commit
7. User review

See `_shared/init-workflow.md` for init phase details.
See `orchestrator.md` for full workflow (when invoked via /start-new).
```

## File-Specific Notes

### init-feature/SKILL.md

No additional changes beyond common changes.

### init-bugfix/SKILL.md

No additional changes beyond common changes.

### init-refactor/SKILL.md

Has additional "### Refactoring Safety Notes" subsection after Workflow Integration. Keep this subsection.

## Execution Order

1. Update init-feature/SKILL.md
2. Update init-bugfix/SKILL.md
3. Update init-refactor/SKILL.md

(Sequential to ensure consistency)

## Completion Criteria

For EACH of the three files:

- [ ] Invocation Behavior section added after Trigger section
- [ ] Invocation Behavior table has correct skill name
- [ ] Output section has clarification note about orchestrator
- [ ] Workflow Integration section updated (7 steps, no Step 9)
- [ ] Reference to orchestrator.md added
- [ ] No "Step 9" or "Next Step Selection" text remains

## Modification Summary

| File | Changes |
|------|---------|
| init-feature/SKILL.md | +Invocation Behavior, +Output note, =Workflow Integration |
| init-bugfix/SKILL.md | +Invocation Behavior, +Output note, =Workflow Integration |
| init-refactor/SKILL.md | +Invocation Behavior, +Output note, =Workflow Integration |
