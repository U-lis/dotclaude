# Phase 4: Test Cases - Cleanup and Final Verification

## Test Coverage Target

100% - Complete migration verification.

## Test Cases

### TC-4-01: skills/ directory deleted

- [ ] `skills/` directory does not exist
- [ ] `ls skills/` returns "No such file or directory"

### TC-4-02: All expected command files present

- [ ] `commands/start-new.md` exists
- [ ] `commands/configure.md` exists
- [ ] `commands/code.md` exists
- [ ] `commands/design.md` exists
- [ ] `commands/update-docs.md` exists
- [ ] `commands/validate-spec.md` exists
- [ ] `commands/merge-main.md` exists
- [ ] `commands/tagging.md` exists
- [ ] `commands/init-feature.md` exists
- [ ] `commands/init-bugfix.md` exists
- [ ] `commands/init-refactor.md` exists
- [ ] `commands/init-github-issue.md` exists
- [ ] `commands/_analysis.md` exists
- [ ] Total: 13 files in commands/

### TC-4-03: All expected agent files present with frontmatter

- [ ] `agents/designer.md` exists and has frontmatter
- [ ] `agents/technical-writer.md` exists and has frontmatter
- [ ] `agents/code-validator.md` exists and has frontmatter
- [ ] `agents/spec-validator.md` exists and has frontmatter
- [ ] `agents/coders/_base.md` exists and has frontmatter
- [ ] `agents/coders/javascript.md` exists and has frontmatter
- [ ] `agents/coders/python.md` exists and has frontmatter
- [ ] `agents/coders/rust.md` exists and has frontmatter
- [ ] `agents/coders/sql.md` exists and has frontmatter
- [ ] `agents/coders/svelte.md` exists and has frontmatter

### TC-4-04: No dangling references in active source files

- [ ] `grep -r "skills/" commands/ agents/` returns no matches
- [ ] `grep -r "from this skill directory" commands/` returns no matches
- [ ] `grep -r "Read skills/" commands/` returns no matches

### TC-4-05: No general-purpose invocation patterns remain

- [ ] `grep -r "general-purpose" commands/` returns no matches
- [ ] `grep -r "Read agents/" commands/` returns no matches (no agent self-read instructions)

### TC-4-06: Plugin structure integrity

- [ ] `.claude-plugin/plugin.json` unchanged
- [ ] `.claude-plugin/marketplace.json` unchanged
- [ ] `CLAUDE.md` unchanged (docs update is separate)
- [ ] `.claude/CLAUDE.md` unchanged

### TC-4-07: Git status clean for expected changes

- [ ] `git status` shows:
  - Modified: 7 command files (inlined) + 2 command files (invocation patterns)
  - New: 5 internal command files
  - Deleted: all files under skills/
  - Modified: 10 agent files (frontmatter added)
- [ ] No unexpected file changes

### TC-4-08: End-to-end acceptance criteria

From SPEC.md acceptance criteria:
- [ ] AC-1: All 8 user-invocable command files contain their complete skill content
- [ ] AC-2: 5 internal commands created with `user-invocable: false` frontmatter
- [ ] AC-3: Internal commands are not shown in autocomplete (user-invocable: false)
- [ ] AC-4: skills/ directory completely removed
- [ ] AC-5: All 10 agent files have proper frontmatter with name, description
- [ ] AC-6: Agent invocations in commands use `dotclaude:{agent-name}` pattern
- [ ] AC-7: Plugin works correctly when installed in any project directory (no relative path references to skills/)
- [ ] AC-8: No behavior changes from user perspective

## Verification Commands

```bash
# Verify skills/ gone
ls skills/ 2>&1 | grep "No such file"

# Count command files
ls commands/*.md | wc -l
# Expected: 13

# Check agent frontmatter
for f in agents/designer.md agents/technical-writer.md agents/code-validator.md agents/spec-validator.md agents/coders/_base.md agents/coders/javascript.md agents/coders/python.md agents/coders/rust.md agents/coders/sql.md agents/coders/svelte.md; do
  head -1 "$f"
done
# Expected: all show "---"

# Full scan for dangling references
grep -rn "skills/" commands/ agents/
# Expected: no output

grep -rn "general-purpose" commands/
# Expected: no output

# Verify plugin config untouched
cat .claude-plugin/plugin.json
# Expected: version still 0.2.0
```
