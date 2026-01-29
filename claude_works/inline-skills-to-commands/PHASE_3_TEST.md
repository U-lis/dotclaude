# Phase 3: Test Cases - Invocation Pattern Updates

## Test Coverage Target

100% - All invocation sites in both affected files must be verified.

## Test Cases

### TC-3-01: No general-purpose references in commands/

- [ ] `grep -r "general-purpose" commands/` returns no matches
- [ ] This confirms ALL invocation patterns have been updated

### TC-3-02: No "Read agents/" instructions in command prompts

- [ ] `grep -r "Read agents/" commands/` returns no matches
- [ ] This confirms all agent self-read instructions removed

### TC-3-03: start-new.md has correct invocation patterns

- [ ] Contains `dotclaude:technical-writer` (TechnicalWriter invocations)
- [ ] Contains `dotclaude:designer` (Designer invocation)
- [ ] Contains `dotclaude:coder-` (Coder invocations, template form)
- [ ] Contains `dotclaude:code-validator` (code-validator invocation)
- [ ] Does NOT contain `subagent_type="general-purpose"`
- [ ] Does NOT contain `subagent_type: "general-purpose"`

### TC-3-04: update-docs.md has correct invocation pattern

- [ ] Contains `dotclaude:technical-writer`
- [ ] Does NOT contain `general-purpose`
- [ ] Does NOT contain `Read agents/technical-writer.md`
- [ ] DOCS_UPDATE role context preserved in prompt

### TC-3-05: Delegation enforcement section updated

- [ ] start-new.md Delegation Enforcement section references `dotclaude:{agent-name}` pattern
- [ ] No "general-purpose" in the MUST DO rules
- [ ] Verification patterns show `dotclaude:technical-writer` (not general-purpose)

### TC-3-06: Task-specific instructions preserved

- [ ] TechnicalWriter prompts still contain task descriptions (SPEC creation, DOCS_UPDATE, etc.)
- [ ] Designer prompt still contains "Analyze SPEC and Create Design" instructions
- [ ] Coder prompts still contain "Implement Phase" instructions
- [ ] code-validator prompt still contains "Validate Phase" instructions

### TC-3-07: Parallel execution patterns updated

- [ ] Parallel execution section uses `dotclaude:coder-{detected_language}` pattern
- [ ] No `general-purpose` in parallel Task tool call examples

### TC-3-08: No other command files affected

- [ ] `commands/configure.md` unchanged from Phase 1B result
- [ ] `commands/code.md` unchanged from Phase 1B result
- [ ] `commands/design.md` unchanged from Phase 1B result
- [ ] `commands/validate-spec.md` unchanged from Phase 1B result
- [ ] `commands/merge-main.md` unchanged from Phase 1B result
- [ ] `commands/tagging.md` unchanged from Phase 1B result
- [ ] Internal commands (init-*.md, _analysis.md) unchanged from Phase 2 result

## Verification Commands

```bash
# Zero general-purpose references in commands
grep -r "general-purpose" commands/

# Zero "Read agents/" in commands
grep -r "Read agents/" commands/

# Verify new patterns present
grep -r "dotclaude:technical-writer" commands/
grep -r "dotclaude:designer" commands/
grep -r "dotclaude:code-validator" commands/
grep -r "dotclaude:coder-" commands/

# Verify DOCS_UPDATE role preserved
grep "DOCS_UPDATE" commands/update-docs.md
```
