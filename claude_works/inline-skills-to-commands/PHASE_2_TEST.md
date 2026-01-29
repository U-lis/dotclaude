# Phase 2: Test Cases - Start-New Inlining and Sub-file Migration

## Test Coverage Target

100% - All 6 files involved must be verified.

## Test Cases

### TC-2-01: All 5 internal commands created

- [ ] `commands/init-feature.md` exists
- [ ] `commands/init-bugfix.md` exists
- [ ] `commands/init-refactor.md` exists
- [ ] `commands/init-github-issue.md` exists
- [ ] `commands/_analysis.md` exists

### TC-2-02: Internal command frontmatter correct

For each internal command:
- [ ] `commands/init-feature.md` has `user-invocable: false` in frontmatter
- [ ] `commands/init-bugfix.md` has `user-invocable: false` in frontmatter
- [ ] `commands/init-refactor.md` has `user-invocable: false` in frontmatter
- [ ] `commands/init-github-issue.md` has `user-invocable: false` in frontmatter
- [ ] `commands/_analysis.md` has `user-invocable: false` in frontmatter
- [ ] Each has a `description:` field
- [ ] Each starts with `---` and has closing `---`

### TC-2-03: Internal command content preserved

- [ ] `commands/init-feature.md` contains "# init-feature Instructions"
- [ ] `commands/init-bugfix.md` contains "# init-bugfix Instructions"
- [ ] `commands/init-refactor.md` contains "# init-refactor Instructions"
- [ ] `commands/init-github-issue.md` contains "# init-github-issue Instructions"
- [ ] `commands/_analysis.md` contains "# Analysis Phases"

### TC-2-04: start-new.md inlined correctly

- [ ] `commands/start-new.md` is more than 900 lines (was 6 lines)
- [ ] Contains "# /dc:start-new"
- [ ] Contains "## 13-Step Workflow"
- [ ] Does NOT contain "Base directory for this skill"
- [ ] Does NOT contain "Read skills/start-new/SKILL.md"
- [ ] Frontmatter `description` preserved from original command

### TC-2-05: Cross-references updated in start-new.md

- [ ] No "from this skill directory" text remains
- [ ] No "from this directory" text remains
- [ ] Init file table uses command references (e.g., "Follow the `init-feature` command")
- [ ] Analysis reference uses command reference (not "read `_analysis.md`")

### TC-2-06: Cross-references updated in init sub-files

- [ ] `commands/init-feature.md` references `_analysis` command (not "Read `_analysis.md`")
- [ ] `commands/init-bugfix.md` references `_analysis` command (not "Read `_analysis.md`")
- [ ] `commands/init-refactor.md` references `_analysis` command (not "Read `_analysis.md`")

### TC-2-07: SKILL.md frontmatter not duplicated

- [ ] `commands/start-new.md` does NOT contain `name: start-new` in frontmatter
- [ ] `commands/start-new.md` does NOT contain `user-invocable: true` in frontmatter
- [ ] Only one `---` pair at top of file (command frontmatter only)

### TC-2-08: Total command file count

- [ ] `commands/` directory contains exactly 13 .md files

## Verification Commands

```bash
# Check all internal commands exist
ls commands/init-feature.md commands/init-bugfix.md commands/init-refactor.md commands/init-github-issue.md commands/_analysis.md

# Check user-invocable: false
grep "user-invocable: false" commands/init-feature.md commands/init-bugfix.md commands/init-refactor.md commands/init-github-issue.md commands/_analysis.md

# Check cross-references removed
grep -r "from this skill directory" commands/
grep -r "Read \`_analysis.md\`" commands/

# Count total command files
ls commands/*.md | wc -l

# Check start-new.md size
wc -l commands/start-new.md
```
