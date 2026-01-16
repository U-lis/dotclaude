# Phase 1: Modify Files

## Objective

Add SOT awareness to TechnicalWriter and commit steps to workflows.

## Prerequisites

None.

## Instructions

### 1. Modify `.claude/agents/technical-writer.md`

Add after "## Role" section:

```markdown
## Critical Rules

### SPEC.md is Source of Truth (SOT)
SPEC.md defines the authoritative requirements. When writing SPEC.md:
- Capture ALL discussed requirements without omission
- Use precise, unambiguous language
- Avoid expressions that could be misinterpreted
- Cross-check against original discussion before finalizing
- If uncertain about any requirement, flag it in "Open Questions" section
```

### 2. Modify `.claude/skills/design/SKILL.md`

Add Step 4 (Commit Documents) between current Steps 3 and 4 in workflow diagram:

```
│ 4. Commit Documents                                     │
│    - git add claude_works/{subject}/*.md                │
│    - git commit -m "docs: add design documents"         │
```

Renumber Step 4 → Step 5.

### 3. Modify `.claude/skills/init-feature/SKILL.md`

Add Step 6 (Commit SPEC.md) between current Steps 5 and 6:

```
│ 6. Commit SPEC.md                                       │
│    - git add claude_works/{subject}/SPEC.md             │
│    - git commit -m "docs: add SPEC.md for {subject}"    │
```

Update:
- Renumber Steps 6→7, 7→8
- "Steps 5-7 are MANDATORY" → "Steps 5-8 are MANDATORY"
- Add Step 6 description to mandatory list
- Update "Correct Execution Order" to include Step 6

### 4. Modify `.claude/skills/init-bugfix/SKILL.md`

Same changes as init-feature.

### 5. Modify `.claude/skills/init-refactor/SKILL.md`

Same changes as init-feature.

## Completion Checklist

- [x] technical-writer.md modified
- [x] design/SKILL.md modified
- [x] init-feature/SKILL.md modified
- [x] init-bugfix/SKILL.md modified
- [x] init-refactor/SKILL.md modified

## Notes

All changes already implemented in current branch.
