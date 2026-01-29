# Phase 1B: Test Cases - Simple Command Inlining

## Test Coverage Target

100% - All 7 command files must be verified.

## Test Cases

### TC-1B-01: All 7 command files contain inlined content

For each command file, verify it is no longer a thin redirect:
- [ ] `commands/configure.md` - more than 400 lines
- [ ] `commands/code.md` - more than 300 lines
- [ ] `commands/design.md` - more than 100 lines
- [ ] `commands/update-docs.md` - more than 100 lines
- [ ] `commands/validate-spec.md` - more than 100 lines
- [ ] `commands/merge-main.md` - more than 50 lines
- [ ] `commands/tagging.md` - more than 50 lines

### TC-1B-02: No redirect patterns remain

- [ ] No command file contains "Base directory for this skill"
- [ ] No command file contains "Read skills/"
- [ ] No command file contains "follow its instructions"

### TC-1B-03: Frontmatter preserved correctly

For each command file:
- [ ] Starts with `---` on line 1
- [ ] Contains `description:` field matching original command description
- [ ] Does NOT contain `name:` field (was in SKILL.md frontmatter, not command)
- [ ] Does NOT contain `user-invocable:` field (default is true, no need to state)
- [ ] Closes frontmatter with `---`

### TC-1B-04: SKILL.md content correctly transferred

For each command file, verify key content from the source SKILL.md:
- [ ] `commands/configure.md` contains "# /dotclaude:configure"
- [ ] `commands/code.md` contains "# /dc:code [phase]"
- [ ] `commands/design.md` contains "# /dc:design"
- [ ] `commands/update-docs.md` contains "# /dc:update-docs"
- [ ] `commands/validate-spec.md` contains "# /dc:validate-spec"
- [ ] `commands/merge-main.md` contains "# /dc:merge-main [branch]"
- [ ] `commands/tagging.md` contains "# /dc:tagging"

### TC-1B-05: start-new.md not modified

- [ ] `commands/start-new.md` still contains the thin redirect (6 lines)
- [ ] `commands/start-new.md` still references "skills/start-new/SKILL.md"

### TC-1B-06: No SKILL.md frontmatter leaked

- [ ] No command file has duplicate frontmatter blocks (two `---` pairs at top)
- [ ] No command file contains `name:` in its frontmatter
- [ ] No command file contains `user-invocable: true` in its frontmatter

## Verification Commands

```bash
# Check file sizes (should be much larger than 6 lines)
wc -l commands/configure.md commands/code.md commands/design.md commands/update-docs.md commands/validate-spec.md commands/merge-main.md commands/tagging.md

# Check no redirects remain
grep -l "Read skills/" commands/*.md
# Expected: no output

# Check no "Base directory" lines
grep -l "Base directory" commands/*.md
# Expected: no output

# Verify key headings exist
grep "^# " commands/configure.md commands/code.md commands/design.md commands/update-docs.md commands/validate-spec.md commands/merge-main.md commands/tagging.md
```
