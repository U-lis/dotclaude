# Phase 4: Cleanup and Verification

## Objective

Remove empty directories, verify the migration is complete, and create the final atomic commit.

## Prerequisites

- Phase 1 completed (directories moved)
- Phase 2 completed (configuration files updated)
- Phase 3 completed (internal path references updated)

## Files Affected

| Item | Action |
|------|--------|
| `.claude/hooks/` | Remove empty directory |
| `.claude/skills/` | Verify removed by git mv |
| `.claude/agents/` | Verify removed by git mv |
| `.claude/templates/` | Verify removed by git mv |

## Instructions

### Step 1: Remove Empty .claude/hooks Directory

After moving the hook scripts in Phase 1, the `.claude/hooks/` directory should be empty.

```bash
rmdir .claude/hooks
```

If the directory is not empty, investigate what files remain before removing.

### Step 2: Verify Directory Structure

Verify the final directory structure matches expectations:

```bash
# Verify new directories exist with correct content
ls -la skills/
ls -la agents/
ls -la templates/
ls -la hooks/

# Verify .claude/ only contains settings files
ls -la .claude/
# Expected: only settings.json and settings.local.json
```

### Step 3: Verify No Legacy Paths Remain

```bash
# Check for any remaining .claude/skills references
grep -r "\.claude/skills" . --include="*.json" --include="*.md" 2>/dev/null

# Check for any remaining .claude/agents references
grep -r "\.claude/agents" . --include="*.json" --include="*.md" 2>/dev/null

# Check for any remaining .claude/templates references
grep -r "\.claude/templates" . --include="*.json" --include="*.md" 2>/dev/null

# Check for any remaining .claude/hooks references (except in .claude/settings.json which is expected)
grep -r "\.claude/hooks" . --include="*.json" --include="*.md" 2>/dev/null
```

All greps should return empty (no matches).

### Step 4: Verify JSON Files Valid

```bash
# Validate all modified JSON files
jq . .claude-plugin/plugin.json > /dev/null && echo "plugin.json: valid"
jq . hooks/hooks.json > /dev/null && echo "hooks.json: valid"
jq . .claude/settings.json > /dev/null && echo "settings.json: valid"
jq . .dotclaude-manifest.json > /dev/null && echo "manifest.json: valid"
```

### Step 5: Verify Hook Scripts Executable

```bash
# Ensure hook scripts are executable
ls -la hooks/*.sh
# Both should show executable permission (x)

# If not executable, fix:
chmod +x hooks/check-update.sh
chmod +x hooks/check-validation-complete.sh
```

### Step 6: Stage All Changes

```bash
# Review all staged changes
git status

# Stage any remaining unstaged changes (config file edits)
git add .claude-plugin/plugin.json
git add hooks/hooks.json
git add .claude/settings.json
git add .dotclaude-manifest.json
git add skills/start-new/SKILL.md
git add skills/update-docs/SKILL.md
```

### Step 7: Final Review

```bash
# Review all changes before commit
git diff --cached --stat

# Expected output should show:
# - Renames for all moved files (showing as rename percentage)
# - Modifications for config files
# - Modifications for SKILL.md files
```

### Step 8: Create Atomic Commit

```bash
git commit -m "fix: migrate plugin directories to root level

Move skills, agents, templates, and hooks from .claude/ prefix
to root level for cleaner plugin structure.

- Move .claude/skills/ to skills/
- Move .claude/agents/ to agents/
- Move .claude/templates/ to templates/
- Move .claude/hooks/*.sh to hooks/
- Update all path references in config files
- Remove redundant skills field from plugin.json
- Bump version to 0.1.1"
```

## Expected Final Structure

```
dotclaude/
├── .claude/
│   ├── settings.json        # Only hook path updated
│   └── settings.local.json  # Unchanged
├── .claude-plugin/
│   ├── marketplace.json     # Unchanged
│   └── plugin.json          # skills field removed, version 0.1.1
├── agents/                  # NEW location
│   ├── code-validator.md
│   ├── designer.md
│   ├── spec-validator.md
│   ├── technical-writer.md
│   └── coders/
│       └── [5 language files]
├── hooks/
│   ├── hooks.json           # Paths updated
│   ├── check-update.sh      # Moved from .claude/hooks/
│   └── check-validation-complete.sh  # Moved from .claude/hooks/
├── skills/                  # NEW location
│   ├── [7 skill directories/files]
│   └── start-new/
│       └── SKILL.md         # Agent paths updated
├── templates/               # NEW location
│   └── [5 template files]
└── .dotclaude-manifest.json # All paths updated, version 0.1.1
```

## Completion Checklist

- [ ] `.claude/hooks/` directory removed (was empty after moves)
- [ ] `.claude/skills/`, `.claude/agents/`, `.claude/templates/` no longer exist
- [ ] `.claude/` contains only `settings.json` and `settings.local.json`
- [ ] All JSON files pass validation
- [ ] No legacy paths remain in codebase (grep returns empty)
- [ ] Hook scripts are executable
- [ ] All changes staged
- [ ] Atomic commit created with descriptive message
- [ ] Git log shows single commit for all migration changes

## Validation Criteria

### 1. Directory Structure Verification

```bash
# These should exist and contain files
test -d skills && echo "skills/ exists"
test -d agents && echo "agents/ exists"
test -d templates && echo "templates/ exists"
test -d hooks && echo "hooks/ exists"

# These should NOT exist
test -d .claude/skills && echo "ERROR: .claude/skills still exists" || echo ".claude/skills removed"
test -d .claude/agents && echo "ERROR: .claude/agents still exists" || echo ".claude/agents removed"
test -d .claude/templates && echo "ERROR: .claude/templates still exists" || echo ".claude/templates removed"
test -d .claude/hooks && echo "ERROR: .claude/hooks still exists" || echo ".claude/hooks removed"
```

### 2. File Count Verification

```bash
# Verify file counts match expected
find skills -type f | wc -l    # Expected: 11
find agents -type f | wc -l    # Expected: 10
find templates -type f | wc -l # Expected: 5
find hooks -type f | wc -l     # Expected: 3
```

### 3. Version Consistency

```bash
# Both should show 0.1.1
jq -r .version .claude-plugin/plugin.json
jq -r .version .dotclaude-manifest.json
```

### 4. Functional Verification (Post-Commit)

After committing, verify the plugin still works:

1. Start a new Claude Code session in a test project with this plugin
2. Verify skills are discovered (`/dc:start-new` appears in skill list)
3. Verify hooks execute (SessionStart hook runs on startup)
4. Invoke a skill and verify agent references resolve correctly

## Notes

- This is the final phase; commit should be created at the end
- If any verification fails, investigate and fix before committing
- The commit should show all changes as a single atomic unit
- After commit, the feature branch is ready for PR or merge to main
