# Phase 0: Move _shared/ Directory

## Objective

Move shared workflow files from `skills/_shared/` to `agents/_shared/` to consolidate agent-related resources.

---

## Prerequisites

- [ ] Working on `refactor/init-agent-migration` branch
- [ ] No uncommitted changes in repository

---

## Scope

### In Scope
- Move `skills/_shared/init-workflow.md` to `agents/_shared/`
- Move `skills/_shared/analysis-phases.md` to `agents/_shared/`
- Delete empty `skills/_shared/` directory after move

### Out of Scope
- Modifying content of moved files (handled in Phase 1 if needed)
- Updating references in skill files (handled in Phase 2)

---

## Instructions

### Step 1: Create Target Directory

**Action**: Create `agents/_shared/` directory if not exists

```bash
mkdir -p .claude/agents/_shared
```

### Step 2: Move init-workflow.md

**Files**:
- Source: `.claude/skills/_shared/init-workflow.md`
- Target: `.claude/agents/_shared/init-workflow.md`

**Action**: Use `mv` command to preserve file

```bash
mv .claude/skills/_shared/init-workflow.md .claude/agents/_shared/init-workflow.md
```

### Step 3: Move analysis-phases.md

**Files**:
- Source: `.claude/skills/_shared/analysis-phases.md`
- Target: `.claude/agents/_shared/analysis-phases.md`

**Action**: Use `mv` command to preserve file

```bash
mv .claude/skills/_shared/analysis-phases.md .claude/agents/_shared/analysis-phases.md
```

### Step 4: Remove Empty Source Directory

**Action**: Remove `skills/_shared/` directory after verifying it is empty

```bash
rmdir .claude/skills/_shared
```

### Step 5: Verify Move

**Action**: Confirm files exist at new location

```bash
ls -la .claude/agents/_shared/
```

Expected output:
- `init-workflow.md` (145 lines)
- `analysis-phases.md` (237 lines)

---

## Implementation Notes

### File Preservation
- Use `mv` command instead of copy-delete to preserve git history
- Git will track as rename rather than delete+add

### Directory Structure
After this phase:
```
.claude/
├── agents/
│   ├── _shared/
│   │   ├── init-workflow.md    # NEW location
│   │   └── analysis-phases.md  # NEW location
│   ├── orchestrator.md
│   ├── designer.md
│   └── ... (other agents)
├── skills/
│   ├── init-feature/
│   │   └── SKILL.md
│   ├── init-bugfix/
│   │   └── SKILL.md
│   ├── init-refactor/
│   │   └── SKILL.md
│   └── ... (other skills)
│   # _shared/ directory REMOVED
```

---

## Completion Checklist

- [ ] `agents/_shared/` directory created
- [ ] `init-workflow.md` moved to `agents/_shared/`
- [ ] `analysis-phases.md` moved to `agents/_shared/`
- [ ] `skills/_shared/` directory removed
- [ ] Files accessible at new paths

---

## Verification

### Manual Verification
```bash
# Verify files exist at new location
ls -la .claude/agents/_shared/

# Verify old directory removed
ls .claude/skills/_shared/ 2>&1 | grep -q "No such file" && echo "SUCCESS: Old directory removed"

# Verify file content preserved (line counts)
wc -l .claude/agents/_shared/*.md
```

### Expected Output
```
.claude/agents/_shared/init-workflow.md     (145 lines)
.claude/agents/_shared/analysis-phases.md   (237 lines)
skills/_shared/ does not exist
```

---

## Notes

- This phase does NOT update any references to the moved files
- Reference updates happen in Phase 1 (agents) and Phase 2 (skills)
- Files are moved as-is without content modification

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
