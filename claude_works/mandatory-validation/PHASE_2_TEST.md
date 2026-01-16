# Phase 2: Test Cases

## Verification Commands

```bash
# Check section header
grep "Checklist Update Authority (MANDATORY)" .claude/agents/code-validator.md

# Check MUST instructions
grep -c "MUST" .claude/agents/code-validator.md

# Check status values
grep -E "(Not Started|In Progress|Complete|Skipped)" .claude/agents/code-validator.md

# Check DO NOT warning
grep "DO NOT report completion" .claude/agents/code-validator.md
```

## Expected Results

- "Checklist Update Authority (MANDATORY)" found
- At least 2 new MUST occurrences
- All 4 status values defined
- "DO NOT report completion" warning found
