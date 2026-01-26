# Phase 3: Internal Path Reference Updates

## Objective

Update all internal path references within skill documentation files that point to agent definitions.

## Prerequisites

- Phase 1 completed (directories moved to new locations)
- Phase 2 completed (configuration files updated)

## Files Affected

| File | References to Update |
|------|---------------------|
| `skills/start-new/SKILL.md` | 4 agent path references |
| `skills/update-docs/SKILL.md` | 1 agent path reference |

## Instructions

### Step 1: Update skills/start-new/SKILL.md

**File**: `skills/start-new/SKILL.md`

This file contains 4 references to agent paths that need updating:

#### Reference 1: TechnicalWriter (Line 328)

**Before**:
```markdown
    You are TechnicalWriter. Read .claude/agents/technical-writer.md for your role.
```

**After**:
```markdown
    You are TechnicalWriter. Read agents/technical-writer.md for your role.
```

#### Reference 2: Designer (Line 342)

**Before**:
```markdown
    You are Designer. Read .claude/agents/designer.md for your role.
```

**After**:
```markdown
    You are Designer. Read agents/designer.md for your role.
```

#### Reference 3: Coder (Line 356)

**Before**:
```markdown
    You are Coder. Read .claude/agents/coders/{language}.md for your role.
```

**After**:
```markdown
    You are Coder. Read agents/coders/{language}.md for your role.
```

#### Reference 4: code-validator (Line 371)

**Before**:
```markdown
    You are code-validator. Read .claude/agents/code-validator.md for your role.
```

**After**:
```markdown
    You are code-validator. Read agents/code-validator.md for your role.
```

### Step 2: Update skills/update-docs/SKILL.md

**File**: `skills/update-docs/SKILL.md`

This file contains 1 reference to an agent path:

#### Reference 1: TechnicalWriter (Line 50)

**Before**:
```markdown
    You are TechnicalWriter in DOCS_UPDATE role. Read .claude/agents/technical-writer.md.
```

**After**:
```markdown
    You are TechnicalWriter in DOCS_UPDATE role. Read agents/technical-writer.md.
```

## Summary of Changes

| File | Line | Old Path | New Path |
|------|------|----------|----------|
| `skills/start-new/SKILL.md` | 328 | `.claude/agents/technical-writer.md` | `agents/technical-writer.md` |
| `skills/start-new/SKILL.md` | 342 | `.claude/agents/designer.md` | `agents/designer.md` |
| `skills/start-new/SKILL.md` | 356 | `.claude/agents/coders/{language}.md` | `agents/coders/{language}.md` |
| `skills/start-new/SKILL.md` | 371 | `.claude/agents/code-validator.md` | `agents/code-validator.md` |
| `skills/update-docs/SKILL.md` | 50 | `.claude/agents/technical-writer.md` | `agents/technical-writer.md` |

**Total**: 5 path references updated across 2 files

## Completion Checklist

- [ ] `skills/start-new/SKILL.md`: TechnicalWriter agent path updated
- [ ] `skills/start-new/SKILL.md`: Designer agent path updated
- [ ] `skills/start-new/SKILL.md`: Coder agent path updated
- [ ] `skills/start-new/SKILL.md`: code-validator agent path updated
- [ ] `skills/update-docs/SKILL.md`: TechnicalWriter agent path updated
- [ ] No other files contain `.claude/agents/` references
- [ ] All paths now use `agents/` prefix (without `.claude/`)

## Validation Criteria

1. **No Legacy Paths**: Grep for `.claude/agents/` should return no matches in `skills/` directory:
   ```bash
   grep -r "\.claude/agents/" skills/
   # Should return empty
   ```

2. **Correct New Paths**: Grep for `agents/` should return 5 matches:
   ```bash
   grep -r "Read agents/" skills/
   # Should return 5 lines
   ```

3. **File Integrity**: Verify SKILL.md files are still valid markdown and maintain proper structure

## Notes

- These are documentation references used by Claude Code when invoking subagents
- The paths are relative to the plugin root directory
- Line numbers may shift if Phase 1 or 2 modified file lengths (verify actual line numbers before editing)
- Do NOT commit at this phase; proceed to Phase 4 for cleanup and final commit
