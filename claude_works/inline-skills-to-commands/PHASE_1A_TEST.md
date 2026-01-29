# Phase 1A: Test Cases - Agent Frontmatter

## Test Coverage Target

100% - All 10 agent files must be verified.

## Test Cases

### TC-1A-01: All agent files have YAML frontmatter

For each of the 10 agent files:
- [ ] File starts with `---` on line 1
- [ ] Contains `name:` field
- [ ] Contains `description:` field
- [ ] Closes frontmatter with `---` on its own line
- [ ] A blank line separates the closing `---` from the heading

Files to check:
1. `agents/designer.md`
2. `agents/technical-writer.md`
3. `agents/code-validator.md`
4. `agents/spec-validator.md`
5. `agents/coders/_base.md`
6. `agents/coders/javascript.md`
7. `agents/coders/python.md`
8. `agents/coders/rust.md`
9. `agents/coders/sql.md`
10. `agents/coders/svelte.md`

### TC-1A-02: Name values match expected mapping

- [ ] `agents/designer.md` -> `name: designer`
- [ ] `agents/technical-writer.md` -> `name: technical-writer`
- [ ] `agents/code-validator.md` -> `name: code-validator`
- [ ] `agents/spec-validator.md` -> `name: spec-validator`
- [ ] `agents/coders/_base.md` -> `name: coder-base`
- [ ] `agents/coders/javascript.md` -> `name: coder-javascript`
- [ ] `agents/coders/python.md` -> `name: coder-python`
- [ ] `agents/coders/rust.md` -> `name: coder-rust`
- [ ] `agents/coders/sql.md` -> `name: coder-sql`
- [ ] `agents/coders/svelte.md` -> `name: coder-svelte`

### TC-1A-03: Original content preserved

- [ ] Each file's original first line (e.g., `# Designer Agent`) still exists after the frontmatter
- [ ] No content removed from the body of any agent file
- [ ] Frontmatter does NOT contain `model:` or `tools:` fields
- [ ] Frontmatter does NOT contain `user-invocable:` field (agents are not commands)

### TC-1A-04: No unintended side effects

- [ ] No files outside `agents/` directory modified
- [ ] No new files created (only existing files modified)
- [ ] `agents/coders/` subdirectory structure unchanged

## Verification Commands

```bash
# Check all agent files have frontmatter
for f in agents/designer.md agents/technical-writer.md agents/code-validator.md agents/spec-validator.md agents/coders/_base.md agents/coders/javascript.md agents/coders/python.md agents/coders/rust.md agents/coders/sql.md agents/coders/svelte.md; do
  echo "=== $f ==="
  head -5 "$f"
  echo ""
done

# Check name values
grep "^name:" agents/*.md agents/coders/*.md
```
