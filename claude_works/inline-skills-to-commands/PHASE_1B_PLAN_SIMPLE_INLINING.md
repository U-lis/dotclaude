# Phase 1B: Inline SKILL.md into 7 Simple Command Files

## Objective

Replace the 7 simple command files (all except start-new) with self-contained versions that include the full SKILL.md content instead of a redirect.

## Prerequisites

- None (this phase has no dependencies)

## Parallel Phase Note

This phase runs in parallel with Phase 1A. They modify completely disjoint file sets:
- Phase 1A: `agents/**/*.md` (10 files)
- Phase 1B: `commands/*.md` (7 files)

No file overlap. No module-level dependency. Independently verifiable.

## Instructions

### Transformation Pattern

Each command file currently contains a thin wrapper that redirects to a SKILL.md file. Replace the redirect body with the actual SKILL.md content.

**Current command structure** (all 7 files identical pattern):
```yaml
---
description: {description text}
---
Base directory for this skill: skills/{name}

Read skills/{name}/SKILL.md and follow its instructions.
```

**Target command structure**:
```yaml
---
description: {description text}
---

{Content from SKILL.md, starting AFTER the SKILL.md's own frontmatter closing ---}
```

### Key Rules

1. **Keep the command's existing `description`** from its frontmatter. Do NOT use the SKILL.md's frontmatter description.
2. **Strip the SKILL.md frontmatter**: The SKILL.md files have their own `---` frontmatter block with `name`, `description`, `user-invocable` fields. Do NOT include this in the command file. Start copying from the content AFTER the SKILL.md's closing `---`.
3. **Remove the redirect lines**: Delete the "Base directory for this skill" and "Read skills/..." lines entirely.
4. **Preserve all SKILL.md body content** exactly as-is.

### File-by-File Specifications

#### 1. `commands/configure.md`
- **Source**: `skills/configure/SKILL.md`
- **Keep description**: `Interactive configuration management for dotclaude settings`
- **SKILL.md body starts at**: Line 7 (`# /dotclaude:configure`)
- **No cross-references to update** (self-contained)
- **Estimated result**: ~510 lines

#### 2. `commands/code.md`
- **Source**: `skills/code/SKILL.md`
- **Keep description**: `Execute coding work for a specific phase. Use when implementing a phase like /dc:code 1, /dc:code 2, /dc:code 3A, /dc:code 3.5 for merge phases, or /dc:code all for fully automatic execution of all phases.`
- **SKILL.md body starts at**: Line 7 (`# /dc:code [phase]`)
- **No cross-references to update** (references to agents use orchestrator patterns, handled in Phase 3)
- **Estimated result**: ~360 lines

#### 3. `commands/design.md`
- **Source**: `skills/design/SKILL.md`
- **Keep description**: `Transform SPEC into detailed implementation plan using Designer agent. Use after SPEC.md is approved or when user invokes /dc:design.`
- **SKILL.md body starts at**: Line 7 (`# /dc:design`)
- **No cross-references to update**
- **Estimated result**: ~115 lines

#### 4. `commands/update-docs.md`
- **Source**: `skills/update-docs/SKILL.md`
- **Keep description**: `Update project documentation (README, CHANGELOG) after code implementation is complete.`
- **SKILL.md body starts at**: Line 7 (`# /dc:update-docs`)
- **Contains agent invocation patterns** (will be updated in Phase 3)
- **Estimated result**: ~140 lines

#### 5. `commands/validate-spec.md`
- **Source**: `skills/validate-spec/SKILL.md`
- **Keep description**: `Validate consistency across all planning documents using spec-validator agent. Use after design documents are created or when user invokes /dc:validate-spec.`
- **SKILL.md body starts at**: Line 7 (`# /dc:validate-spec`)
- **No cross-references to update**
- **Estimated result**: ~125 lines

#### 6. `commands/merge-main.md`
- **Source**: `skills/merge-main/SKILL.md`
- **Keep description**: `Merge feature branch to main with conflict resolution and branch cleanup`
- **SKILL.md body starts at**: Line 7 (`# /dc:merge-main [branch]`)
- **No cross-references to update**
- **Estimated result**: ~65 lines

#### 7. `commands/tagging.md`
- **Source**: `skills/tagging/SKILL.md`
- **Keep description**: `Create version tag based on CHANGELOG`
- **SKILL.md body starts at**: Line 7 (`# /dc:tagging`)
- **No cross-references to update**
- **Estimated result**: ~65 lines

### Important Notes

- Do NOT inline `commands/start-new.md` in this phase. It requires special handling (sub-file moves, cross-reference updates) and is done in Phase 2.
- Do NOT update agent invocation patterns (`general-purpose` -> `dotclaude:*`) in this phase. That is Phase 3.
- The SKILL.md files already have their own frontmatter that duplicates the command frontmatter. Only the command's frontmatter is kept.

## Completion Checklist

- [ ] `commands/configure.md` contains full configure SKILL.md body (not just redirect)
- [ ] `commands/code.md` contains full code SKILL.md body
- [ ] `commands/design.md` contains full design SKILL.md body
- [ ] `commands/update-docs.md` contains full update-docs SKILL.md body
- [ ] `commands/validate-spec.md` contains full validate-spec SKILL.md body
- [ ] `commands/merge-main.md` contains full merge-main SKILL.md body
- [ ] `commands/tagging.md` contains full tagging SKILL.md body
- [ ] All 7 files have valid frontmatter with original `description` preserved
- [ ] No files contain "Base directory for this skill" text
- [ ] No files contain "Read skills/" redirect text
- [ ] No SKILL.md frontmatter (`name:`, `user-invocable:`) leaked into command files
- [ ] `commands/start-new.md` is NOT modified in this phase

## Verification

For each command file:
1. First line is `---`
2. Contains only `description:` in frontmatter (no `name:`, no `user-invocable:`)
3. Body matches SKILL.md body content exactly
4. No "skills/" path references remain in the inlined content
