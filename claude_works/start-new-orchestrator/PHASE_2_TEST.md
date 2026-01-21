# Phase 2: Test Cases

## Test Coverage Target

100% reference verification (no broken references)

## Reference Search Tests

### Deleted Agent References

- [ ] `grep -r "agents/orchestrator\.md" .claude/` returns empty
- [ ] `grep -r "agents/init-feature\.md" .claude/` returns empty
- [ ] `grep -r "agents/init-bugfix\.md" .claude/` returns empty
- [ ] `grep -r "agents/init-refactor\.md" .claude/` returns empty

### Deleted Shared File References

- [ ] `grep -r "_shared/init-workflow" .claude/` returns empty
- [ ] `grep -r "_shared/analysis-phases" .claude/` returns empty

### Deleted Skill References

- [ ] `grep -r "skills/init-feature" .claude/` returns empty
- [ ] `grep -r "skills/init-bugfix" .claude/` returns empty
- [ ] `grep -r "skills/init-refactor" .claude/` returns empty

### Deleted Hook References

- [ ] `grep -r "check-init-complete" .claude/` returns empty
- [ ] No SKILL.md files reference hooks/check-init-complete.sh

## Cross-Reference Validation

### SKILL.md Internal References

- [ ] SKILL.md references `init-feature.md` (not `agents/init-feature.md`)
- [ ] SKILL.md references `init-bugfix.md` (not `agents/init-bugfix.md`)
- [ ] SKILL.md references `init-refactor.md` (not `agents/init-refactor.md`)
- [ ] SKILL.md does NOT contain `Task tool -> init-`

### init-xxx.md References

- [ ] init-feature.md references `_analysis.md` (not `_shared/analysis-phases.md`)
- [ ] init-bugfix.md references `_analysis.md` (not `_shared/analysis-phases.md`)
- [ ] init-refactor.md references `_analysis.md` (not `_shared/analysis-phases.md`)

### _analysis.md References

- [ ] _analysis.md does NOT reference specific agent paths
- [ ] _analysis.md is self-contained or uses relative references

## Settings Validation

### settings.json (if exists)

- [ ] No entry for `init-feature` skill
- [ ] No entry for `init-bugfix` skill
- [ ] No entry for `init-refactor` skill
- [ ] Entry for `start-new` skill preserved (if was present)

## Documentation Validation

### CLAUDE.md

- [ ] No references to deleted agent paths
- [ ] Workflow description updated if references orchestrator

### README.md

- [ ] Skill list updated (no /init-feature, /init-bugfix, /init-refactor)
- [ ] Or no changes needed if skills not listed

## Verification Commands

```bash
# Comprehensive search for any remaining old references
grep -rE "(orchestrator|init-feature|init-bugfix|init-refactor)" .claude/ \
  | grep -v "skills/start-new" \
  | grep -v "Binary"

# Should return:
# - Only matches within skills/start-new/ (the new files)
# - No matches in agents/ directory
# - No matches in other skills/ directories

# Check settings.json specifically
cat .claude/settings.json 2>/dev/null | grep -E "init-(feature|bugfix|refactor)"
# Expected: no output (empty)
```

## Edge Cases

### Expected Matches (Not Errors)

The following matches are EXPECTED and NOT errors:

| Location | Content | Reason |
|----------|---------|--------|
| skills/start-new/SKILL.md | "init-feature.md" | Intentional reference to new file |
| skills/start-new/SKILL.md | "init-bugfix.md" | Intentional reference to new file |
| skills/start-new/SKILL.md | "init-refactor.md" | Intentional reference to new file |
| skills/start-new/*.md | Work type labels in Korean | UI strings, not path references |

### Unexpected Matches (Errors)

Any match outside of `skills/start-new/` directory is an error:

- [ ] No matches in `agents/` directory (except files being deleted in Phase 3)
- [ ] No matches in `skills/design/`, `skills/code/`, etc.
- [ ] No matches in `hooks/` directory

## Test Sequence

1. Run all grep searches
2. Filter results to exclude skills/start-new/
3. Filter results to exclude files being deleted in Phase 3
4. Verify remaining results are empty
5. Manually verify cross-references in new files are correct

## Pass Criteria

- All grep searches for deleted paths return empty (outside deleted files)
- settings.json has no init-xxx skill entries
- New files use correct relative references
- No broken links in documentation
