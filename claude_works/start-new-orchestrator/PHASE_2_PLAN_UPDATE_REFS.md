# Phase 2: Update References

## Objective

Search for and update all references to deleted file paths. Ensure no broken references remain in the codebase.

## Prerequisites

- Phase 1 completed (new files created)
- All 5 new files verified

## Instructions

### 2A: Search for References to Deleted Paths

**Search patterns** (grep in `.claude/` directory):

| Deleted Path | Search Pattern |
|--------------|----------------|
| agents/orchestrator.md | `orchestrator\.md` |
| agents/init-feature.md | `agents/init-feature` |
| agents/init-bugfix.md | `agents/init-bugfix` |
| agents/init-refactor.md | `agents/init-refactor` |
| agents/_shared/init-workflow.md | `init-workflow\.md` |
| agents/_shared/analysis-phases.md | `analysis-phases\.md` |
| skills/init-feature/ | `skills/init-feature` |
| skills/init-bugfix/ | `skills/init-bugfix` |
| skills/init-refactor/ | `skills/init-refactor` |
| hooks/check-init-complete.sh | `check-init-complete` |

**Commands**:
```bash
# Search for all potentially affected references
grep -r "orchestrator\.md" .claude/
grep -r "agents/init-feature" .claude/
grep -r "agents/init-bugfix" .claude/
grep -r "agents/init-refactor" .claude/
grep -r "init-workflow\.md" .claude/
grep -r "analysis-phases\.md" .claude/
grep -r "skills/init-feature" .claude/
grep -r "skills/init-bugfix" .claude/
grep -r "skills/init-refactor" .claude/
grep -r "check-init-complete" .claude/
```

- [ ] Execute all search commands
- [ ] Document all files containing references

---

### 2B: Update Found References

For each file containing references:

#### Case 1: Reference in remaining agent files

If agents like `designer.md`, `technical-writer.md`, or `code-validator.md` reference deleted files:

- [ ] Update path references to new locations
- [ ] Example: `agents/orchestrator.md` -> remove reference (orchestrator is now in SKILL.md)
- [ ] Example: `agents/init-feature.md` -> remove reference (no longer an agent)

#### Case 2: Reference in settings.json

Check `.claude/settings.json` for skill registrations:

- [ ] Search for init-feature, init-bugfix, init-refactor skill entries
- [ ] Remove skill entries for deleted init-xxx skills
- [ ] Keep start-new skill entry

**Expected settings.json changes**:
```json
// REMOVE these if present:
"init-feature": { ... }
"init-bugfix": { ... }
"init-refactor": { ... }
```

#### Case 3: Reference in CLAUDE.md or README

- [ ] Check CLAUDE.md for references to old paths
- [ ] Check README.md for references to old paths
- [ ] Update or remove outdated references

#### Case 4: Reference in other skill SKILL.md files

- [ ] Check design skill for references
- [ ] Check code skill for references
- [ ] Check merge-main skill for references
- [ ] Update any "routed from /init-xxx" references

---

### 2C: Verify No Broken References

After updates, verify:

```bash
# Re-run all searches - should return empty
grep -r "agents/orchestrator\.md" .claude/
grep -r "agents/init-feature" .claude/
grep -r "agents/init-bugfix" .claude/
grep -r "agents/init-refactor" .claude/
grep -r "_shared/init-workflow" .claude/
grep -r "_shared/analysis-phases" .claude/

# Check for any remaining "init-xxx" agent references
grep -r "init-feature agent" .claude/
grep -r "init-bugfix agent" .claude/
grep -r "init-refactor agent" .claude/
```

- [ ] All searches return empty (no matches)
- [ ] Or matches are in new SKILL.md (intentional references)

---

### 2D: Update Cross-References Within New Files

Ensure new files reference each other correctly:

**In SKILL.md**:
- [ ] Step 2 references `init-feature.md`, `init-bugfix.md`, `init-refactor.md` (same directory)
- [ ] No references to `agents/` directory

**In init-xxx.md files**:
- [ ] Reference `_analysis.md` (not `_shared/analysis-phases.md`)
- [ ] No references to `agents/` directory

**In _analysis.md**:
- [ ] No references to specific init skill files
- [ ] Generic "see init-{type}.md" pattern if needed

## Completion Checklist

- [ ] All grep searches executed
- [ ] All found references documented
- [ ] All references updated or removed
- [ ] settings.json updated (if applicable)
- [ ] Verification searches return empty
- [ ] New files cross-reference correctly

## Expected Findings

Based on codebase analysis, likely references:

| File | Reference | Action |
|------|-----------|--------|
| CLAUDE.md | May reference orchestrator | Update or remove |
| README.md | May list skills | Update skill list |
| designer.md | May reference orchestrator | Remove reference |
| settings.json | May have init-xxx entries | Remove entries |

## Notes

### Minimal Changes Expected

Most references should be within the files being deleted. The new SKILL.md is self-contained and does not reference external agent files for init workflow.

### settings.json Caution

If settings.json does not have init-xxx skill entries (skills auto-discovered from SKILL.md), no changes needed. Only modify if explicit entries exist.
