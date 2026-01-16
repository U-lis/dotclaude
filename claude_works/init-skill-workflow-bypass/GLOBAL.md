# GLOBAL: Fix init-xxx skill workflow bypass

## Architecture Overview

This is a simple bug fix that adds explicit instructions to existing SKILL.md files. No architectural changes required.

## Technical Decisions

### Approach: Text Addition
- Add "Mandatory Workflow Rules" section to 3 SKILL.md files
- Insert after `## Workflow` section (around line 45)
- Identical content for all 3 files

### Content Structure
```markdown
## Mandatory Workflow Rules

**CRITICAL**: Rules that MUST be followed regardless of plan mode or permission settings.

### Steps 5-7 are MANDATORY
- Step 5: Create SPEC.md file
- Step 6: Present for user review
- Step 7: Ask Next Step Selection question

### Prohibited Actions
- Skip to implementation after gathering info
- Bypass SPEC.md creation
- Skip Next Step Selection question
- Start coding without explicit user selection

### Correct Execution Order
(8-step checklist with mandatory markers)
```

## Phase Overview

| Phase | Name | Description | Status |
|-------|------|-------------|--------|
| 1 | Add Mandatory Rules | Add section to all 3 SKILL.md files | Pending |

## Dependencies

None. All 3 file edits are independent and can be done in sequence.

## Testing Strategy

Manual verification:
1. Read each modified SKILL.md to confirm section added correctly
2. Test by running `/init-bugfix` and verifying workflow enforced
