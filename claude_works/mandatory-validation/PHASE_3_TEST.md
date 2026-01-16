# Phase 3: Test Cases

## Verification Commands

```bash
# Check script exists and is executable
test -x .claude/hooks/check-validation-complete.sh && echo "OK: executable"

# Check script content
grep "PHASE_\*_PLAN" .claude/hooks/check-validation-complete.sh
grep "decision.*block" .claude/hooks/check-validation-complete.sh

# Check settings.json has Stop hook
grep -A5 '"Stop"' .claude/settings.json
```

## Expected Results

- Script exists and is executable
- Script contains PHASE_*_PLAN pattern check
- Script contains JSON block decision output
- settings.json has Stop hook configuration

## Functional Test

```bash
# Simulate: On feature branch with code changes and unchecked items
# Expected: Block with reason

# Simulate: On feature branch with no code changes
# Expected: Allow (exit 0)

# Simulate: On main branch
# Expected: Allow (exit 0)
```
