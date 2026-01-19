# Phase 1: Enhance orchestrator.md

## Objective

Add workflow control sections from init-workflow.md to orchestrator.md, establishing orchestrator as the single source of truth for routing, non-stop execution, and progress reporting.

## Prerequisites

- Read current orchestrator.md structure
- Read sections to migrate from init-workflow.md

## Checklist

### 1.1 Add Routing Section

**Location**: After "## Subagent Call Patterns" section (around line 279)

**Action**: Add new section

```markdown
## Routing

After user selects scope (Step 5), route to appropriate skills:

| Selection | Action |
|-----------|--------|
| Design | Invoke `/design` → STOP |
| Design → Code | `/design` → `/code all` → STOP |
| Design → Code → Docs | `/design` → `/code all` → CHANGELOG → STOP |
| Design → Code → Docs → Merge | `/design` → `/code all` → CHANGELOG → `/merge-main` → STOP |
```

### 1.2 Add Non-Stop Execution Section

**Location**: After new "## Routing" section

**Action**: Add new section

```markdown
## Non-Stop Execution

When user selects a scope with multiple steps (e.g., "Design → Code"), execute all steps automatically without stopping.

### Execution Rules

1. **DO NOT** ask "What's next?" between chained skills
2. **DO NOT** wait for user input between steps
3. **MUST** proceed immediately to next skill in chain
4. **MUST** halt chain on error and report to user

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

### 1.3 Enhance Progress Reporting Section

**Location**: Existing "## Progress Reporting" section (around line 405)

**Action**: Replace existing content with enhanced version

**Current content**:
```markdown
## Progress Reporting

Display progress at each major step:
```
═══════════════════════════════════════════════════════════
[Step {N}/13] {Step description}
Current: {Current action}
═══════════════════════════════════════════════════════════
```
```

**New content**:
```markdown
## Progress Reporting

### Step Progress

Display progress at each major step:

```
═══════════════════════════════════════════════════════════
[Step {N}/13] {Step description}
Current: {Current action}
═══════════════════════════════════════════════════════════
```

### Skill Chain Progress

During multi-skill execution (non-stop mode), display:

```
═══════════════════════════════════════════════════════════
[Step {M}/{Total}] {Skill description}
Current: Executing {skill name}
═══════════════════════════════════════════════════════════
```

Example for "Design → Code → Docs → Merge":
- [Step 1/4] Design phase - Executing /design
- [Step 2/4] Code implementation - Executing /code all
- [Step 3/4] Documentation update - Updating CHANGELOG
- [Step 4/4] Merge to main - Executing /merge-main
```

### 1.4 Add Final Summary Report Section

**Location**: Before "## Progress Reporting" section

**Action**: Add new section

```markdown
## Final Summary Report

After all skills in the chain complete, display summary:

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

This summary appears ONLY at the final STOP point, not between skills.
```

## File Modifications Summary

| Section | Action | Location |
|---------|--------|----------|
| Routing | ADD | After Subagent Call Patterns |
| Non-Stop Execution | ADD | After Routing |
| Final Summary Report | ADD | Before Progress Reporting |
| Progress Reporting | ENHANCE | Existing section |

## Completion Criteria

- [ ] Routing section added with scope-to-skill mapping table
- [ ] Non-Stop Execution section added with rules and CLAUDE.md overrides
- [ ] Final Summary Report section added with template
- [ ] Progress Reporting section enhanced with skill chain progress format
- [ ] All new sections use consistent markdown formatting
