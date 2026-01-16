# Phase 1: Test Cases

## Verification Commands

```bash
# Check section exists
grep "## Mandatory Validation" .claude/skills/code/SKILL.md

# Check MUST rules
grep -c "MUST" .claude/skills/code/SKILL.md

# Check Pre-Commit Checklist
grep "Pre-Commit Checklist" .claude/skills/code/SKILL.md

# Check DO NOT warning
grep "DO NOT commit" .claude/skills/code/SKILL.md
```

## Expected Results

- "## Mandatory Validation (CRITICAL)" found
- At least 3 MUST occurrences (new additions)
- "Pre-Commit Checklist" found
- "DO NOT commit" warning found
