# Phase 1A: Add Frontmatter to Agent Files

## Objective

Add YAML frontmatter with `name` and `description` fields to all 10 agent markdown files so the plugin system can identify and invoke them directly.

## Prerequisites

- None (this phase has no dependencies)

## Parallel Phase Note

This phase runs in parallel with Phase 1B. They modify completely disjoint file sets:
- Phase 1A: `agents/**/*.md` (10 files)
- Phase 1B: `commands/*.md` (7 files)

No file overlap. No module-level dependency. Independently verifiable.

## Instructions

### Transformation Pattern

Each agent file currently starts with a markdown heading (no frontmatter). Add YAML frontmatter block before the existing content.

**Before** (example: `agents/designer.md`):
```markdown
# Designer Agent

You are the **Designer**, the most technically...
```

**After**:
```markdown
---
name: designer
description: Transform SPEC into detailed implementation plans with architecture decisions and phase decomposition.
---

# Designer Agent

You are the **Designer**, the most technically...
```

### File-by-File Specifications

#### 1. `agents/designer.md`
```yaml
---
name: designer
description: Transform SPEC into detailed implementation plans with architecture decisions and phase decomposition.
---
```

#### 2. `agents/technical-writer.md`
```yaml
---
name: technical-writer
description: Create structured documentation (SPEC, GLOBAL, PLAN, TEST, CHANGELOG, README) following strict formats.
---
```

#### 3. `agents/code-validator.md`
```yaml
---
name: code-validator
description: Verify code implementation against plan checklists and run language-specific quality checks.
---
```

#### 4. `agents/spec-validator.md`
```yaml
---
name: spec-validator
description: Validate consistency across all planning documents (SPEC, GLOBAL, PLAN, TEST).
---
```

#### 5. `agents/coders/_base.md`
```yaml
---
name: coder-base
description: Common rules for all Coder agents including TDD principles, phase discipline, and code reuse.
---
```

#### 6. `agents/coders/javascript.md`
```yaml
---
name: coder-javascript
description: JavaScript/TypeScript development specialist with Node.js, ES6+, and async pattern expertise.
---
```

#### 7. `agents/coders/python.md`
```yaml
---
name: coder-python
description: Python development specialist with FastAPI, SQLAlchemy, and async pattern expertise.
---
```

#### 8. `agents/coders/rust.md`
```yaml
---
name: coder-rust
description: Rust systems programming specialist with memory safety, async Rust, and CLI tool expertise.
---
```

#### 9. `agents/coders/sql.md`
```yaml
---
name: coder-sql
description: SQL and database specialist with schema design, query optimization, and migration expertise.
---
```

#### 10. `agents/coders/svelte.md`
```yaml
---
name: coder-svelte
description: Svelte 5 and SvelteKit frontend development specialist with runes syntax and component architecture.
---
```

### Important Notes

- Preserve ALL existing content after the frontmatter block
- Add exactly one blank line between the closing `---` and the first `#` heading
- The `name` value must match the invocation name used in Phase 3 (e.g., `dotclaude:designer` requires `name: designer`)
- Do NOT modify any content within the agent file body
- Do NOT add `model` or `tools` fields (those belong in plugin JSON config)

## Completion Checklist

- [ ] `agents/designer.md` has frontmatter with `name: designer`
- [ ] `agents/technical-writer.md` has frontmatter with `name: technical-writer`
- [ ] `agents/code-validator.md` has frontmatter with `name: code-validator`
- [ ] `agents/spec-validator.md` has frontmatter with `name: spec-validator`
- [ ] `agents/coders/_base.md` has frontmatter with `name: coder-base`
- [ ] `agents/coders/javascript.md` has frontmatter with `name: coder-javascript`
- [ ] `agents/coders/python.md` has frontmatter with `name: coder-python`
- [ ] `agents/coders/rust.md` has frontmatter with `name: coder-rust`
- [ ] `agents/coders/sql.md` has frontmatter with `name: coder-sql`
- [ ] `agents/coders/svelte.md` has frontmatter with `name: coder-svelte`
- [ ] All 10 files have valid YAML frontmatter (opening and closing `---`)
- [ ] All existing file content preserved unchanged after frontmatter
- [ ] One blank line between closing `---` and first heading in each file

## Verification

For each file, verify:
1. File starts with `---` on first line
2. Contains `name:` and `description:` fields
3. Closes with `---` on a line by itself
4. Original content follows unchanged
