# mandatory-validation - Global Documentation

## Feature Overview

**Purpose**: Enforce code-validator execution and checklist updates in /code workflow.

**Solution**:
1. Add mandatory validation instructions to /code skill
2. Strengthen code-validator agent's checklist update authority
3. Add Stop hook to detect incomplete validation

---

## Architecture Decision

### Approach: Instruction + Stop Hook

**Rationale**:
- Instruction-based: Agent has full context for intelligent validation
- Stop hook: Safety net to catch missed validations before session end
- No PostToolUse hook: Avoids per-file execution overhead

---

## File Structure

### Files to Modify
```
.claude/skills/code/SKILL.md       # Add Mandatory Validation section
.claude/agents/code-validator.md   # Strengthen checklist update instructions
.claude/settings.json              # Register Stop hook
```

### Files to Create
```
.claude/hooks/check-validation-complete.sh   # Stop hook script
```

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Add Mandatory Validation section to /code skill | Not Started | - |
| 2 | Strengthen code-validator checklist instructions | Not Started | - |
| 3 | Create and register Stop hook | Not Started | - |

---

## Completion Criteria

- [ ] /code skill has "Mandatory Validation" section with enforcement language
- [ ] code-validator has explicit MUST instructions for checklist updates
- [ ] Stop hook detects code changes + unchecked items
- [ ] Stop hook registered in settings.json
