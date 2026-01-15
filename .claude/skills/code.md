---
name: code
description: Execute coding work for a specific phase. Use when implementing a phase like /code 1, /code 2, /code 3A, or /code 3.5 for merge phases.
user-invocable: true
---

# /code [phase]

Execute coding work for a specific phase.

## Trigger

User invokes `/code [phase]` where phase is like `1`, `2`, `3A`, `3.5`, etc.

## Prerequisites

- Planning documents exist and are validated
- Previous phases completed (if dependencies exist)
- For parallel phases: worktree set up

## Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| phase | Phase identifier | `1`, `2`, `3A`, `3.5` |

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Read Phase Documents                                 │
│    - PHASE_{k}_PLAN_{keyword}.md                       │
│    - PHASE_{k}_TEST.md                                 │
│    - GLOBAL.md (for context)                           │
├─────────────────────────────────────────────────────────┤
│ 2. Setup (for parallel phases)                          │
│    - Create worktree if PHASE_{k}A/B/C                 │
│    - git worktree add ../subject-{k}X feature/subject-{k}X │
├─────────────────────────────────────────────────────────┤
│ 3. Invoke Appropriate Coder Agent                       │
│    - Determine language from PLAN                       │
│    - python / javascript / svelte / rust / sql          │
├─────────────────────────────────────────────────────────┤
│ 4. Coder Implements Phase                               │
│    - Follow TDD                                         │
│    - Implement checklist items                          │
│    - Create test cases                                  │
├─────────────────────────────────────────────────────────┤
│ 5. Invoke code-validator Agent                          │
│    - Check PLAN checklist                               │
│    - Verify TEST implementation                         │
│    - Run quality checks (ruff/ty/pytest etc.)           │
├─────────────────────────────────────────────────────────┤
│ 6. Validation Loop                                      │
│    - If fail: Coder fixes (max 3 attempts)              │
│    - If still fail: skip and report                     │
├─────────────────────────────────────────────────────────┤
│ 7. On Success                                           │
│    - git add, commit (with user permission)             │
│    - Report completion                                  │
└─────────────────────────────────────────────────────────┘
```

## Parallel Phase Handling

### Setup Worktree
```bash
# For PHASE_3A
git checkout feature/subject
git worktree add ../subject-3A -b feature/subject-3A

# Coder works in ../subject-3A/
cd ../subject-3A
```

### After Completion
```bash
# Return to main worktree
cd ../project

# Worktree stays until PHASE_3.5 merge
```

## Merge Phase (PHASE_{k}.5)

For merge phases:
1. Read PHASE_{k}.5_PLAN_MERGE.md
2. Merge branches in specified order
3. Resolve conflicts
4. Run full test suite
5. Clean up worktrees

```bash
git merge feature/subject-3A
git merge feature/subject-3B  # resolve conflicts
git merge feature/subject-3C  # resolve conflicts

# After successful merge
git worktree remove ../subject-3A
git worktree remove ../subject-3B
git worktree remove ../subject-3C
```

## Coder Selection

| Language/Framework | Agent |
|-------------------|-------|
| Python | coders/python.md |
| JavaScript/TypeScript | coders/javascript.md |
| Svelte | coders/svelte.md |
| Rust | coders/rust.md |
| SQL/Database | coders/sql.md |

## Output

### Phase Completion Report
```markdown
# Phase {k} Complete

## Status: SUCCESS / PARTIAL

## Implemented
- [x] Item 1
- [x] Item 2

## Files Changed
- file1.py: description
- file2.py: description

## Validation
- Linter: PASSED
- Type Check: PASSED
- Tests: 15 passed

## Commit
{commit hash}: {commit message}
```

## Next Steps

After phase completion:
1. If more phases: `/code [next-phase]`
2. If parallel phases done: `/code {k}.5` for merge
3. If all phases done: `/finalize`
