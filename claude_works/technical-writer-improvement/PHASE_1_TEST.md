# Phase 1: Test Cases

## Test Coverage Target

N/A - Documentation changes only, no code tests.

## Manual Verification

### technical-writer.md

- [ ] "Critical Rules" section exists after "Role" section
- [ ] SOT awareness rules are complete (5 bullet points)

### design/SKILL.md

- [ ] Workflow has 5 steps (was 4)
- [ ] Step 4 is "Commit Documents"
- [ ] Step 5 is "Review with User"

### init-feature/SKILL.md

- [ ] Workflow has 8 steps (was 7)
- [ ] Step 6 is "Commit SPEC.md"
- [ ] "Steps 5-8 are MANDATORY" (was 5-7)
- [ ] Correct Execution Order has 9 items (was 8)

### init-bugfix/SKILL.md

- [ ] Same structure as init-feature

### init-refactor/SKILL.md

- [ ] Same structure as init-feature

## Workflow Verification

Test by running `/init-feature` and verifying:
1. SPEC.md is committed before review step
2. Commit message follows format: "docs: add SPEC.md for {subject}"
