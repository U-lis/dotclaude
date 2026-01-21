# Phase 3: Delete Old Files

## Objective

Delete all old agent files, skill directories, and hook script that have been superseded by the new structure.

## Prerequisites

- Phase 1 completed (new files created and verified)
- Phase 2 completed (all references updated)

## Instructions

### 3A: Delete Agent Files

**Files to delete** (6 files):

| File | Lines | Reason |
|------|-------|--------|
| `.claude/agents/orchestrator.md` | 497 | Merged into skills/start-new/SKILL.md |
| `.claude/agents/init-feature.md` | 191 | Moved to skills/start-new/init-feature.md |
| `.claude/agents/init-bugfix.md` | 236 | Moved to skills/start-new/init-bugfix.md |
| `.claude/agents/init-refactor.md` | 212 | Moved to skills/start-new/init-refactor.md |
| `.claude/agents/_shared/init-workflow.md` | 144 | Merged into skills/start-new/SKILL.md |
| `.claude/agents/_shared/analysis-phases.md` | 237 | Moved to skills/start-new/_analysis.md |

**Commands**:
```bash
# Delete orchestrator agent
rm .claude/agents/orchestrator.md

# Delete init agents
rm .claude/agents/init-feature.md
rm .claude/agents/init-bugfix.md
rm .claude/agents/init-refactor.md

# Delete shared files
rm .claude/agents/_shared/init-workflow.md
rm .claude/agents/_shared/analysis-phases.md
```

- [ ] Delete orchestrator.md
- [ ] Delete init-feature.md
- [ ] Delete init-bugfix.md
- [ ] Delete init-refactor.md
- [ ] Delete init-workflow.md
- [ ] Delete analysis-phases.md

---

### 3B: Delete Skill Directories

**Directories to delete** (3 directories):

| Directory | Contents | Reason |
|-----------|----------|--------|
| `.claude/skills/init-feature/` | SKILL.md (62 lines) | Skill no longer needed |
| `.claude/skills/init-bugfix/` | SKILL.md (62 lines) | Skill no longer needed |
| `.claude/skills/init-refactor/` | SKILL.md (62 lines) | Skill no longer needed |

**Commands**:
```bash
# Delete skill directories
rm -r .claude/skills/init-feature/
rm -r .claude/skills/init-bugfix/
rm -r .claude/skills/init-refactor/
```

- [ ] Delete init-feature skill directory
- [ ] Delete init-bugfix skill directory
- [ ] Delete init-refactor skill directory

---

### 3C: Delete Hook Script

**File to delete**:

| File | Lines | Reason |
|------|-------|--------|
| `.claude/hooks/check-init-complete.sh` | 32 | Logic moved to SKILL.md Step 6 checkpoint |

**Command**:
```bash
rm .claude/hooks/check-init-complete.sh
```

- [ ] Delete check-init-complete.sh

**Note**: Keep `check-validation-complete.sh` - it is for a different purpose.

---

### 3D: Clean Up Empty Directories

After deletions, check if `_shared` directory is empty:

```bash
# Check if _shared is empty
ls .claude/agents/_shared/

# If empty, remove the directory
rmdir .claude/agents/_shared/
```

- [ ] Check _shared directory contents
- [ ] If empty, delete _shared directory
- [ ] If not empty, document remaining files

---

### 3E: Verify Deletions

**Verification commands**:
```bash
# Verify agent files deleted
ls .claude/agents/orchestrator.md 2>/dev/null || echo "orchestrator.md: deleted"
ls .claude/agents/init-feature.md 2>/dev/null || echo "init-feature.md: deleted"
ls .claude/agents/init-bugfix.md 2>/dev/null || echo "init-bugfix.md: deleted"
ls .claude/agents/init-refactor.md 2>/dev/null || echo "init-refactor.md: deleted"

# Verify shared files deleted
ls .claude/agents/_shared/init-workflow.md 2>/dev/null || echo "init-workflow.md: deleted"
ls .claude/agents/_shared/analysis-phases.md 2>/dev/null || echo "analysis-phases.md: deleted"

# Verify skill directories deleted
ls -d .claude/skills/init-feature 2>/dev/null || echo "init-feature/: deleted"
ls -d .claude/skills/init-bugfix 2>/dev/null || echo "init-bugfix/: deleted"
ls -d .claude/skills/init-refactor 2>/dev/null || echo "init-refactor/: deleted"

# Verify hook deleted
ls .claude/hooks/check-init-complete.sh 2>/dev/null || echo "check-init-complete.sh: deleted"
```

- [ ] All ls commands return "deleted" message

## Completion Checklist

- [ ] 6 agent files deleted
- [ ] 3 skill directories deleted
- [ ] 1 hook script deleted
- [ ] _shared directory cleaned up (if empty)
- [ ] All deletions verified
- [ ] No accidental deletions (check-validation-complete.sh preserved)

## Deletion Summary

| Category | Count | Total Lines Removed |
|----------|-------|---------------------|
| Agents | 4 | 1,136 |
| Shared | 2 | 381 |
| Skills | 3 | 186 |
| Hooks | 1 | 32 |
| **Total** | **10** | **~1,735** |

**Net change**: Removed ~1,735 lines, added ~1,030 lines = ~705 lines reduction (39% reduction)

## Notes

### Safe Deletion Order

1. Delete files first, then directories
2. Use `rm -r` for directories to handle any hidden files
3. Verify each deletion before proceeding

### Recovery

If any file is deleted by mistake:
- Use `git checkout -- {file_path}` to restore from last commit
- Or check git reflog for recovery

### Backup Not Required

All content is either:
- Preserved in new files (Phase 1)
- Available in git history
- Intentionally removed (duplicate/boilerplate)
