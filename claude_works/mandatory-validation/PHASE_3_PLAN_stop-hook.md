# Phase 3: Stop Hook Implementation

## Objective

Create Stop hook to warn about incomplete validation before session end.

---

## Target Files

1. `.claude/hooks/check-validation-complete.sh` (create)
2. `.claude/settings.json` (modify)

---

## Instructions

### Step 1: Create Hook Script

**File**: `.claude/hooks/check-validation-complete.sh`

**Content**:

```bash
#!/bin/bash
# Stop hook: Warn if code changes exist with unchecked PHASE_*_PLAN items
# Part of mandatory-validation feature

BRANCH=$(git branch --show-current 2>/dev/null)

# Only check on feature/bugfix/refactor branches
if [[ ! "$BRANCH" =~ ^(feature|bugfix|refactor)/ ]]; then
  exit 0
fi

# Check for uncommitted code changes (excluding claude_works/)
CODE_CHANGES=$(git status --porcelain | grep -v "claude_works/" | grep -v "\.md$" | head -1)

if [[ -z "$CODE_CHANGES" ]]; then
  # No code changes - allow stop
  exit 0
fi

# Code changes exist - check for unchecked items in PHASE_*_PLAN files
UNCHECKED=$(grep -l '^\- \[ \]' claude_works/*/PHASE_*_PLAN_*.md 2>/dev/null | head -1)

if [[ -n "$UNCHECKED" ]]; then
  cat << 'EOF'
{"decision": "block", "reason": "Code changes detected but PHASE_*_PLAN.md has unchecked items. Run code-validator to update checklists before stopping."}
EOF
  exit 0
fi

# All checks passed
exit 0
```

### Step 2: Make Script Executable

```bash
chmod +x .claude/hooks/check-validation-complete.sh
```

### Step 3: Register in settings.json

**File**: `.claude/settings.json`

**Update**: Add Stop hook configuration

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-validation-complete.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Completion Checklist

- [x] `check-validation-complete.sh` created
- [x] Script is executable (chmod +x)
- [x] Script checks for code changes (excluding claude_works/ and .md)
- [x] Script checks for unchecked PHASE_*_PLAN items
- [x] Script outputs JSON block decision
- [x] settings.json updated with Stop hook
