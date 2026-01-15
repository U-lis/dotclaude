# Phase 1: skill-update

## Objective

Update `.claude/skills/code/SKILL.md` to add `/code all` option for automatic full execution of all phases.

---

## Prerequisites

- [x] SPEC.md approved
- [x] GLOBAL.md created

---

## Scope

### In Scope
- Update SKILL.md frontmatter description
- Add `all` argument to Arguments table
- Add `/code all` workflow section

### Out of Scope
- Creating new agents (deferred to future enhancement)
- True parallel execution (deferred)
- Resume capability (deferred)

---

## Instructions

### Step 1: Update Frontmatter

**Files**: `.claude/skills/code/SKILL.md`

**Action**: Modify `description` field in YAML frontmatter to include `/code all` option.

Change from:
```
description: Execute coding work for a specific phase. Use when implementing a phase like /code 1, /code 2, /code 3A, or /code 3.5 for merge phases.
```

To:
```
description: Execute coding work for a specific phase. Use when implementing a phase like /code 1, /code 2, /code 3A, /code 3.5 for merge phases, or /code all for fully automatic execution of all phases.
```

### Step 2: Add `all` Argument

**Files**: `.claude/skills/code/SKILL.md`

**Action**: Add new row to Arguments table after `phase` row.

Add:
```
| all | Execute all phases automatically | `all` |
```

### Step 3: Add `/code all` Section

**Files**: `.claude/skills/code/SKILL.md`

**Action**: Insert new section after "## Next Steps" section with the following subsections:

1. **Section Header**: `## /code all - Automatic Full Execution`
2. **Prerequisites**: List required documents
3. **Workflow**: ASCII diagram showing 8 steps
4. **Phase Detection Algorithm**: Primary (GLOBAL.md) and fallback (file system)
5. **Execution Order Example**: Show layer-based execution
6. **Parallel Phase Execution**: Git worktree commands
7. **CLAUDE.md Rule Exceptions**: Document auto-commit and auto-proceed exceptions
8. **Output**: Comprehensive report format with summary, phase results, issues, next steps

---

## Implementation Notes

### Phase Detection

Primary source is GLOBAL.md "Phase Overview" table. Parse:
- Phase identifier from first column
- Dependencies from last column
- Build DAG and topologically sort into layers

Fallback: Glob `PHASE_*_PLAN_*.md` files and infer dependencies from naming convention.

### Parallel Execution

Not truly parallel (single-agent limitation). Execute sequentially but in isolated worktrees to avoid conflicts. Merge at `PHASE_{k}.5`.

### Error Handling

On validation failure after 3 retries:
- Mark phase as SKIPPED
- Continue to next phase (do NOT halt)
- Record issue for final report

---

## Completion Checklist

- [x] SKILL.md frontmatter contains "or /code all for fully automatic execution"
- [x] Arguments table contains row for `all`
- [x] `/code all` section exists
- [x] Prerequisites subsection exists
- [x] Workflow diagram with 8 steps exists
- [x] Phase Detection Algorithm subsection exists with Primary and Fallback
- [x] Execution Order Example subsection exists
- [x] Parallel Phase Execution subsection exists with git commands
- [x] CLAUDE.md Rule Exceptions subsection exists
- [x] Output subsection exists with report format

---

## Verification

### Manual Verification
```bash
# Check frontmatter
head -10 .claude/skills/code/SKILL.md | grep "code all"

# Check arguments table
grep -A 3 "## Arguments" .claude/skills/code/SKILL.md | grep "all"

# Check /code all section exists
grep "## \`/code all\`" .claude/skills/code/SKILL.md
```

### Expected Output
```
description: ... or /code all for fully automatic execution of all phases.
| all | Execute all phases automatically | `all` |
## `/code all` - Automatic Full Execution
```

---

## Notes

- SKILL.md may already be modified (workflow was violated). Validate against this checklist.
- If all items pass, mark phase complete without re-implementation.
- If items missing, fix discrepancies.

---

## Completion Date

2026-01-15

## Completed By

Claude Opus 4.5
