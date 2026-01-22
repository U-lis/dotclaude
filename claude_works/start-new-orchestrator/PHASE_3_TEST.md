# Phase 3: Test Cases

## Test Coverage Target

100% deletion verification

## File Deletion Tests

### Agent Files

- [ ] `.claude/agents/orchestrator.md` does NOT exist
- [ ] `.claude/agents/init-feature.md` does NOT exist
- [ ] `.claude/agents/init-bugfix.md` does NOT exist
- [ ] `.claude/agents/init-refactor.md` does NOT exist

### Shared Files

- [ ] `.claude/agents/_shared/init-workflow.md` does NOT exist
- [ ] `.claude/agents/_shared/analysis-phases.md` does NOT exist

### Skill Directories

- [ ] `.claude/skills/init-feature/` directory does NOT exist
- [ ] `.claude/skills/init-bugfix/` directory does NOT exist
- [ ] `.claude/skills/init-refactor/` directory does NOT exist

### Hook Script

- [ ] `.claude/hooks/check-init-complete.sh` does NOT exist

## Preservation Tests

### Files That MUST Still Exist

**Agents (should NOT be deleted)**:
- [ ] `.claude/agents/designer.md` exists
- [ ] `.claude/agents/technical-writer.md` exists
- [ ] `.claude/agents/code-validator.md` exists
- [ ] `.claude/agents/coders/` directory exists

**Skills (should NOT be deleted)**:
- [ ] `.claude/skills/start-new/` directory exists with new files
- [ ] `.claude/skills/design/` directory exists
- [ ] `.claude/skills/code/` directory exists
- [ ] `.claude/skills/merge-main/` directory exists

**Hooks (should NOT be deleted)**:
- [ ] `.claude/hooks/check-validation-complete.sh` exists

**New Files (created in Phase 1)**:
- [ ] `.claude/skills/start-new/SKILL.md` exists
- [ ] `.claude/skills/start-new/_analysis.md` exists
- [ ] `.claude/skills/start-new/init-feature.md` exists
- [ ] `.claude/skills/start-new/init-bugfix.md` exists
- [ ] `.claude/skills/start-new/init-refactor.md` exists

## Directory Structure Tests

### _shared Directory

- [ ] If `.claude/agents/_shared/` is empty after deletion: directory removed
- [ ] If `.claude/agents/_shared/` has other files: directory preserved with remaining files

### Agents Directory Structure

Expected after Phase 3:
```
.claude/agents/
├── designer.md
├── technical-writer.md
├── code-validator.md
├── spec-validator.md (if exists)
├── coders/
│   └── (language-specific files)
└── _shared/ (only if has other content)
```

- [ ] agents/ directory exists
- [ ] No init-xxx files in agents/

### Skills Directory Structure

Expected after Phase 3:
```
.claude/skills/
├── start-new/
│   ├── SKILL.md
│   ├── _analysis.md
│   ├── init-feature.md
│   ├── init-bugfix.md
│   └── init-refactor.md
├── design/
├── code/
├── merge-main/
├── tagging/
└── validate-spec/
```

- [ ] No init-feature/, init-bugfix/, init-refactor/ directories
- [ ] start-new/ has 5 files

## Verification Commands

```bash
# Check deleted files don't exist
for file in \
  .claude/agents/orchestrator.md \
  .claude/agents/init-feature.md \
  .claude/agents/init-bugfix.md \
  .claude/agents/init-refactor.md \
  .claude/agents/_shared/init-workflow.md \
  .claude/agents/_shared/analysis-phases.md \
  .claude/hooks/check-init-complete.sh; do
  if [ -f "$file" ]; then
    echo "ERROR: $file still exists"
  else
    echo "OK: $file deleted"
  fi
done

# Check deleted directories don't exist
for dir in \
  .claude/skills/init-feature \
  .claude/skills/init-bugfix \
  .claude/skills/init-refactor; do
  if [ -d "$dir" ]; then
    echo "ERROR: $dir still exists"
  else
    echo "OK: $dir deleted"
  fi
done

# Check preserved files still exist
for file in \
  .claude/agents/designer.md \
  .claude/agents/technical-writer.md \
  .claude/hooks/check-validation-complete.sh \
  .claude/skills/start-new/SKILL.md; do
  if [ -f "$file" ]; then
    echo "OK: $file preserved"
  else
    echo "ERROR: $file missing"
  fi
done
```

## File Count Verification

### Before Phase 3

| Location | File Count |
|----------|------------|
| agents/ (init-related) | 4 |
| agents/_shared/ (init-related) | 2 |
| skills/init-xxx/ | 3 directories |
| hooks/ (init-related) | 1 |

### After Phase 3

| Location | File Count |
|----------|------------|
| agents/ (init-related) | 0 |
| agents/_shared/ (init-related) | 0 |
| skills/init-xxx/ | 0 directories |
| hooks/ (init-related) | 0 |
| skills/start-new/ | 5 files |

## Line Count Verification

```bash
# Count total lines in new structure
wc -l .claude/skills/start-new/*.md

# Expected total: ~1,030 lines (900-1,160 tolerance)
```

## Pass Criteria

- [ ] All 10 deletions verified (6 agents, 3 skill dirs, 1 hook)
- [ ] All preserved files verified (agents, skills, hooks)
- [ ] Directory structure matches expected layout
- [ ] No orphaned empty directories
- [ ] New files from Phase 1 intact
