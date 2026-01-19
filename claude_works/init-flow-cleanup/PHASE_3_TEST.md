# Phase 3: Validation - init-xxx SKILL.md Updates

## Validation Checklist

### 1. Invocation Behavior Section Verification

```bash
# All three should have Invocation Behavior section
grep -n "## Invocation Behavior" .claude/skills/init-feature/SKILL.md
grep -n "## Invocation Behavior" .claude/skills/init-bugfix/SKILL.md
grep -n "## Invocation Behavior" .claude/skills/init-refactor/SKILL.md
```

- [ ] init-feature/SKILL.md has Invocation Behavior section
- [ ] init-bugfix/SKILL.md has Invocation Behavior section
- [ ] init-refactor/SKILL.md has Invocation Behavior section

### 2. Invocation Behavior Content Verification

```bash
# Verify table content
grep "Direct.*init-feature" .claude/skills/init-feature/SKILL.md
grep "Direct.*init-bugfix" .claude/skills/init-bugfix/SKILL.md
grep "Direct.*init-refactor" .claude/skills/init-refactor/SKILL.md
```

- [ ] Each file has correct skill name in the invocation table

```bash
# Verify "Steps 1-8" mentioned
grep "Steps 1-8" .claude/skills/init-feature/SKILL.md
grep "Steps 1-8" .claude/skills/init-bugfix/SKILL.md
grep "Steps 1-8" .claude/skills/init-refactor/SKILL.md
```

- [ ] All three mention "Steps 1-8"

### 3. Output Section Note Verification

```bash
# Verify clarification note added
grep "Scope selection and subsequent workflow" .claude/skills/init-feature/SKILL.md
grep "Scope selection and subsequent workflow" .claude/skills/init-bugfix/SKILL.md
grep "Scope selection and subsequent workflow" .claude/skills/init-refactor/SKILL.md
```

- [ ] init-feature/SKILL.md has orchestrator note
- [ ] init-bugfix/SKILL.md has orchestrator note
- [ ] init-refactor/SKILL.md has orchestrator note

### 4. Workflow Integration Section Verification

```bash
# Verify updated structure (7 steps listed)
grep -A10 "## Workflow Integration" .claude/skills/init-feature/SKILL.md | head -15
grep -A10 "## Workflow Integration" .claude/skills/init-bugfix/SKILL.md | head -15
grep -A10 "## Workflow Integration" .claude/skills/init-refactor/SKILL.md | head -15
```

- [ ] Each file lists 7 steps (not 4 with Step 9)

```bash
# Verify orchestrator.md reference added
grep "orchestrator.md" .claude/skills/init-feature/SKILL.md
grep "orchestrator.md" .claude/skills/init-bugfix/SKILL.md
grep "orchestrator.md" .claude/skills/init-refactor/SKILL.md
```

- [ ] All three reference orchestrator.md

### 5. Step 9 Removal Verification

```bash
# Should return NO results
grep "Step 9" .claude/skills/init-feature/SKILL.md
grep "Step 9" .claude/skills/init-bugfix/SKILL.md
grep "Step 9" .claude/skills/init-refactor/SKILL.md
grep "Next Step Selection" .claude/skills/init-feature/SKILL.md
grep "Next Step Selection" .claude/skills/init-bugfix/SKILL.md
grep "Next Step Selection" .claude/skills/init-refactor/SKILL.md
```

- [ ] No "Step 9" in any file
- [ ] No "Next Step Selection" in any file

### 6. Preserved Content Verification

```bash
# Verify essential sections preserved
grep "## Trigger" .claude/skills/init-feature/SKILL.md
grep "## Step-by-Step Questions" .claude/skills/init-feature/SKILL.md
grep "## Analysis Phase" .claude/skills/init-feature/SKILL.md
grep "## Branch Keyword" .claude/skills/init-feature/SKILL.md
grep "## Output" .claude/skills/init-feature/SKILL.md
```

- [ ] Trigger section preserved
- [ ] Step-by-Step Questions preserved
- [ ] Analysis Phase preserved
- [ ] Branch Keyword preserved
- [ ] Output section preserved

```bash
# Verify init-refactor specific content preserved
grep "Refactoring Safety Notes" .claude/skills/init-refactor/SKILL.md
```

- [ ] Refactoring Safety Notes preserved in init-refactor

### 7. Section Order Verification

Expected section order (all three files):
1. YAML frontmatter
2. # /init-xxx
3. ## Trigger
4. ## Invocation Behavior (NEW)
5. ## Step-by-Step Questions
6. ## Analysis Phase
7. ## Branch Keyword
8. ## Output
9. ## Workflow Integration

```bash
grep -n "^## " .claude/skills/init-feature/SKILL.md
```

- [ ] Invocation Behavior appears after Trigger
- [ ] Invocation Behavior appears before Step-by-Step Questions

### 8. Cross-File Consistency

```bash
# Compare Invocation Behavior section structure
diff <(grep -A5 "## Invocation Behavior" .claude/skills/init-feature/SKILL.md | tail -4) \
     <(grep -A5 "## Invocation Behavior" .claude/skills/init-bugfix/SKILL.md | tail -4)
```

- [ ] Invocation Behavior tables have same structure (only skill name differs)

### 9. Global DRY Compliance

```bash
# "Next Step Selection" should not appear anywhere in init skills
grep -r "Next Step Selection" .claude/skills/init-*
```

- [ ] Returns empty (no matches)

## Expected grep Results Summary

| Check | init-feature | init-bugfix | init-refactor |
|-------|-------------|-------------|---------------|
| Invocation Behavior | FOUND | FOUND | FOUND |
| Steps 1-8 | FOUND | FOUND | FOUND |
| orchestrator.md ref | FOUND | FOUND | FOUND |
| Step 9 | NOT FOUND | NOT FOUND | NOT FOUND |
| Next Step Selection | NOT FOUND | NOT FOUND | NOT FOUND |
