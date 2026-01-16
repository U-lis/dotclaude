# Phase 1: Test Cases

## Test Type

**Document Verification** - This phase modifies documentation only.

---

## Verification Checklist

### Section Structure

- [ ] Section header exists: `## Non-Stop Execution`
- [ ] Execution Rules subsection exists: `### Execution Rules`
- [ ] Scope-to-Skill Chain Mapping subsection exists
- [ ] CLAUDE.md Rule Overrides subsection exists
- [ ] On Error subsection exists

### Execution Rules Content

- [ ] Rule 1: "DO NOT ask What's next?"
- [ ] Rule 2: "DO NOT wait for user input"
- [ ] Rule 3: "MUST proceed immediately"
- [ ] Rule 4: "MUST halt chain on error"

### Scope-to-Skill Chain Mapping Content

- [ ] Row for "Design" scope
- [ ] Row for "Design → Code" scope
- [ ] Row for "Design → Code → CHANGELOG" scope
- [ ] Row for "Design → Code → CHANGELOG → Merge" scope
- [ ] Each row has clear STOP point

### CLAUDE.md Rule Overrides Content

- [ ] Override for "Do NOT proceed to next phase" rule
- [ ] Override for "Report summary and wait" rule
- [ ] Each override explains why it's suspended

### On Error Content

- [ ] Step 1: STOP chain
- [ ] Step 2: Report error
- [ ] Step 3: Suggest resolution
- [ ] Step 4: User can resume

### Optional Sections

- [ ] Progress Indicator format defined
- [ ] Final Summary Report format defined

---

## Manual Verification Commands

```bash
# 1. Check main section exists
grep "## Non-Stop Execution" .claude/skills/_shared/init-workflow.md

# 2. Check subsections
grep -E "### (Execution Rules|Scope-to-Skill|CLAUDE.md Rule|On Error)" .claude/skills/_shared/init-workflow.md

# 3. Check execution rules
grep -E "(DO NOT|MUST)" .claude/skills/_shared/init-workflow.md | head -10

# 4. Check scope mapping table
grep -A 6 "Scope-to-Skill Chain Mapping" .claude/skills/_shared/init-workflow.md

# 5. Count lines in section
sed -n '/^## Non-Stop Execution/,/^## [^#]/p' .claude/skills/_shared/init-workflow.md | wc -l
```

### Expected Results

1. "## Non-Stop Execution" found
2. All 4 subsections found
3. At least 4 DO NOT/MUST rules found
4. Table with 4 scope rows found
5. Section has 40+ lines

---

## Test Status

| Verification Area | Items | Passed | Failed |
|------------------|-------|--------|--------|
| Section Structure | 5 | 0 | 0 |
| Execution Rules | 4 | 0 | 0 |
| Scope Mapping | 5 | 0 | 0 |
| Rule Overrides | 3 | 0 | 0 |
| Error Handling | 4 | 0 | 0 |
| Optional | 2 | 0 | 0 |
| **Total** | 23 | 0 | 0 |

*Not yet executed*
