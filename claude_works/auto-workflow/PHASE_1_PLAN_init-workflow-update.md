# Phase 1: init-workflow-update

## Objective

Enhance `.claude/skills/_shared/init-workflow.md` to add non-stop execution instructions that chain skills automatically based on user's selected scope.

---

## Prerequisites

- [x] SPEC.md approved
- [x] GLOBAL.md created

---

## Scope

### In Scope
- Add "Non-Stop Execution" section to init-workflow.md
- Define execution flow for each scope option
- Add CLAUDE.md rule overrides for chained execution
- Add optional progress indicator format
- Add optional final summary report format

### Out of Scope
- Modifying individual skill files (design, code, merge-main, tagging)
- Creating new skill files

---

## Instructions

### Step 1: Add Non-Stop Execution Section

**File**: `.claude/skills/_shared/init-workflow.md`

**Action**: After the "## Routing" section, add new section:

```markdown
## Non-Stop Execution

When user selects a scope with multiple steps (e.g., "Design → Code"), execute all steps automatically without stopping.

### Execution Rules

1. **DO NOT** ask "What's next?" between chained skills
2. **DO NOT** wait for user input between steps
3. **MUST** proceed immediately to next skill in chain
4. **MUST** halt chain on error and report to user

### Scope-to-Skill Chain Mapping

| User Selection | Skill Chain |
|----------------|-------------|
| Design | `/design` → STOP |
| Design → Code | `/design` → `/code all` → STOP |
| Design → Code → CHANGELOG | `/design` → `/code all` → CHANGELOG → STOP |
| Design → Code → CHANGELOG → Merge | `/design` → `/code all` → CHANGELOG → `/merge-main` → STOP |

### CLAUDE.md Rule Overrides

During non-stop execution, these CLAUDE.md rules are suspended:

- **"Do NOT proceed to next phase without user instruction"**
  → User's scope selection IS the instruction to proceed

- **"Report summary upon completion and wait for user review"**
  → Report only at final STOP point, not between skills

### On Error

If any skill fails during chain:
1. STOP the chain immediately
2. Report error to user
3. Suggest manual resolution
4. User can resume by re-selecting scope
```

### Step 2: Add Progress Indicator Format (Optional)

**Action**: Add subsection within "Non-Stop Execution":

```markdown
### Progress Indicator

During multi-skill execution, display progress:

```
═══════════════════════════════════════════════════════════
[Step 2/4] Code implementation
Current: Executing /code all
═══════════════════════════════════════════════════════════
```
```

### Step 3: Add Final Summary Report Format (Optional)

**Action**: Add subsection within "Non-Stop Execution":

```markdown
### Final Summary Report

After all skills complete, display:

```markdown
# Workflow Complete

## Scope: {selected scope}

## Results

| Step | Skill | Status |
|------|-------|--------|
| 1 | /design | SUCCESS |
| 2 | /code all | SUCCESS |
| 3 | CHANGELOG | SUCCESS |
| 4 | /merge-main | SUCCESS |

## Files Changed
- claude_works/{subject}/*.md
- [implementation files...]
- CHANGELOG.md

## Next Steps
1. Review changes: `git log --oneline -10`
2. Push to remote: `git push origin main`
3. (Optional) Create tag: `/tagging`
```
```

---

## Completion Checklist

- [ ] "Non-Stop Execution" section header exists
- [ ] Execution Rules subsection with 4 rules
- [ ] Scope-to-Skill Chain Mapping table with 4 rows
- [ ] CLAUDE.md Rule Overrides subsection with 2 overrides
- [ ] On Error subsection with 4 steps
- [ ] Progress Indicator subsection (optional)
- [ ] Final Summary Report subsection (optional)
