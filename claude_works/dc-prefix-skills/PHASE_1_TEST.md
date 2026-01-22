# Phase 1: Test Cases

## Test Coverage Target

N/A - Skill/Agent files are prompt-based configuration, not executable code with automated test coverage.

## Validation Method

Manual verification through file inspection. All tests are pass/fail based on exact string matching.

---

## Validation Criteria

### SKILL.md Frontmatter Verification

For each SKILL.md file, verify the `name` field in YAML frontmatter contains correct prefixed value.

| # | File | Expected `name` Value | Status |
|---|------|----------------------|--------|
| 1 | `.claude/skills/update-docs/SKILL.md` | `dc:update-docs` | [ ] |
| 2 | `.claude/skills/tagging/SKILL.md` | `dc:tagging` | [ ] |
| 3 | `.claude/skills/merge-main/SKILL.md` | `dc:merge-main` | [ ] |
| 4 | `.claude/skills/validate-spec/SKILL.md` | `dc:validate-spec` | [ ] |
| 5 | `.claude/skills/design/SKILL.md` | `dc:design` | [ ] |
| 6 | `.claude/skills/code/SKILL.md` | `dc:code` | [ ] |
| 7 | `.claude/skills/start-new/SKILL.md` | `dc:start-new` | [ ] |

**Verification command**:
```bash
grep -n "^name:" .claude/skills/*/SKILL.md
```

**Expected output** (all should show dc: prefix):
```
.claude/skills/code/SKILL.md:2:name: dc:code
.claude/skills/design/SKILL.md:2:name: dc:design
.claude/skills/merge-main/SKILL.md:2:name: dc:merge-main
.claude/skills/start-new/SKILL.md:2:name: dc:start-new
.claude/skills/tagging/SKILL.md:2:name: dc:tagging
.claude/skills/update-docs/SKILL.md:2:name: dc:update-docs
.claude/skills/validate-spec/SKILL.md:2:name: dc:validate-spec
```

---

### Internal Reference Verification

Verify all skill cross-references use dc: prefix.

| # | File | Reference | Expected Value | Status |
|---|------|-----------|----------------|--------|
| 1 | validate-spec/SKILL.md | Next Steps | `/dc:code [phase]` | [ ] |
| 2 | design/SKILL.md | Next Steps | `/dc:validate-spec` | [ ] |
| 3 | design/SKILL.md | Next Steps | `/dc:code [phase]` | [ ] |
| 4 | code/SKILL.md | Next Steps | `/dc:code [next-phase]` | [ ] |
| 5 | code/SKILL.md | Next Steps | `/dc:code {k}.5` | [ ] |
| 6 | code/SKILL.md | Next Steps | `/dc:merge-main` | [ ] |
| 7 | code/SKILL.md | Next Steps | `/dc:tagging` | [ ] |
| 8 | start-new/SKILL.md | Final Summary | `/dc:tagging` | [ ] |

**Verification command** (should return 0 matches for unprefixed commands in Next Steps/Summary sections):
```bash
grep -E "'/[^d][^c][^:](code|design|validate-spec|merge-main|tagging)'" .claude/skills/*/SKILL.md
```

---

### README.md Verification

Verify all command references in README.md use dc: prefix.

**Skills table verification**:
```bash
grep -E "^\| \`/dc:" README.md | wc -l
```
Expected: At least 10 lines (all commands in table)

**Usage section verification**:
```bash
grep "/dc:start-new" README.md
grep "/dc:tagging" README.md
```
Expected: Both commands found in Usage section

**Manual Execution section verification**:
```bash
grep -E "^/dc:" README.md | wc -l
```
Expected: At least 9 lines (all manual commands)

---

### Negative Tests

Verify NO unprefixed skill commands remain (except in historical context or documentation explaining the change).

**Check for remaining unprefixed commands**:
```bash
# Should return NO matches in SKILL.md files (outside frontmatter)
grep -E "'/start-new'|'/code'|'/design'|'/validate-spec'|'/tagging'|'/merge-main'|'/update-docs'" .claude/skills/*/SKILL.md
```

**Check README for unprefixed commands**:
```bash
# Should return NO matches in command table or usage sections
grep -E "^\| \`/[^d]|^/[^d]" README.md | grep -E "(start-new|code|design|validate-spec|tagging|merge-main|update-docs)"
```

---

## Edge Case Verification

| # | Case | Verification Method | Status |
|---|------|---------------------|--------|
| 1 | update-docs has frontmatter | Check file starts with `---` | [ ] |
| 2 | Directory names unchanged | `ls .claude/skills/` shows original names | [ ] |
| 3 | CHANGELOG preserved | No changes to CHANGELOG.md | [ ] |
| 4 | claude_works archives preserved | No changes to existing claude_works/ docs | [ ] |

---

## Summary Checklist

- [ ] All 7 SKILL.md files have correct `name: dc:{skill}` frontmatter
- [ ] All internal skill cross-references use dc: prefix
- [ ] README.md Skills table shows all commands with dc: prefix
- [ ] README.md Usage section shows commands with dc: prefix
- [ ] README.md Manual Execution section shows commands with dc: prefix
- [ ] No unprefixed skill commands remain in active documentation
- [ ] Directory names unchanged
- [ ] Historical documents unchanged
