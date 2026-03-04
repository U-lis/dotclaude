---
description: Execute coding work for a specific phase. Use when implementing a phase like /dotclaude:code 1, /dotclaude:code 2, /dotclaude:code 3A, /dotclaude:code 3.5 for merge phases, or /dotclaude:code all for fully automatic execution of all phases.
---

# /dotclaude:code [phase]

Execute coding work for a specific phase.

## Configuration

The `{working_directory}` and `{worktree_path}` values are read from SPEC.md metadata (written by `/dotclaude:start-new`).
If SPEC.md is not found, fall back to defaults: `{working_directory}` = `.dc_workspace`, `{worktree_path}` = `.` (current directory).

## Trigger

User invokes `/dotclaude:code [phase]` where phase is like `1`, `2`, `3A`, `3.5`, etc.

## Prerequisites

- Planning documents exist and are validated
- Previous phases completed (if dependencies exist)
- For parallel phases: worktree set up

## Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| phase | Phase identifier | `1`, `2`, `3A`, `3.5` |
| all | Execute all phases automatically | `all` |

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
│ 5. Invoke code-validator Agent (single invocation)      │
│    - Pass: worktree_path, coder namespace, phase_id     │
│    - Pass: PLAN path, TEST path, GLOBAL path            │
│    - Validator manages validate-fix loop internally     │
│    - Validator returns final PASS/FAIL result           │
├─────────────────────────────────────────────────────────┤
│ 6. Process Validator Result                             │
│    - PASS: proceed to commit (code + documents)         │
│    - FAIL: phase already marked SKIPPED by validator    │
├─────────────────────────────────────────────────────────┤
│ 7. On Success                                           │
│    - git add (code files + PLAN + GLOBAL + TEST docs)   │
│    - git commit (with user permission)                  │
│    - Report completion                                  │
└─────────────────────────────────────────────────────────┘
```

## Mandatory Validation (CRITICAL)

**This section is NON-NEGOTIABLE. Validation MUST occur before commit.**

### Validation Requirements

After Coder completes implementation:

1. **MUST** invoke code-validator agent with full context (worktree path, coder namespace, document paths)
2. **MUST** wait for final validation result (validator manages retries internally)
3. **MUST** ensure validator has updated PLAN checklist, GLOBAL status, and TEST results before commit
4. **MUST** include updated documents in the commit (not just code files)

### Validation Loop

The code-validator manages the entire validate-fix cycle internally.
The orchestrator (this command) invokes the validator ONCE and receives the final result.

```
┌─────────────────────────────────────────────────────────┐
│ Coder completes implementation                          │
│         ↓                                               │
│ Invoke code-validator (SINGLE invocation)               │
│   - Passes: worktree_path, coder namespace,             │
│     phase_id, document paths                            │
│         ↓                                               │
│ code-validator internally:                              │
│   ┌──────────────────────────────────────────────┐      │
│   │ Validate → FAIL? → Invoke coder for fix      │      │
│   │     ↑                    ↓                   │      │
│   │     └──── Re-validate ←──┘ (max 3 attempts)  │      │
│   └──────────────────────────────────────────────┘      │
│         ↓                                               │
│ code-validator returns final result:                    │
│   - PASS: documents updated (PLAN, GLOBAL, TEST)        │
│   - FAIL: phase marked SKIPPED in GLOBAL                │
│         ↓                                               │
│ Orchestrator commits or skips based on result           │
└─────────────────────────────────────────────────────────┘
```

### Pre-Commit Checklist

Before `git add` and `git commit`:

- [ ] code-validator invoked with full context and completed (final result received)
- [ ] All items in PHASE_{k}_PLAN.md checked off (by validator)
- [ ] GLOBAL.md phase status updated to "Complete" (by validator)
- [ ] Quality checks passed or marked N/A (by validator, auto-detected per project)
- [ ] git add includes: changed code files
- [ ] git add includes: {working_directory}/{subject}/PHASE_{k}_PLAN_{keyword}.md
- [ ] git add includes: {working_directory}/{subject}/GLOBAL.md
- [ ] git add includes: {working_directory}/{subject}/PHASE_{k}_TEST.md (if modified)

**DO NOT commit if any item above is unchecked.**

## Parallel Phase Handling

### Setup Worktree
```bash
# For PHASE_3A (branching from feature branch, not main)
# Worktree naming: {project_name}-{type}-{keyword}-{phase}
git worktree add ../{project_name}-{type}-{keyword}-3A -b feature/{keyword}-3A feature/{keyword}

# Coder works in ../{project_name}-{type}-{keyword}-3A/
cd ../{project_name}-{type}-{keyword}-3A
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

Task tool namespace: `dotclaude:coders:coder-{language}` (maps to `agents/coders/{language}.md`)

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
1. If more phases: `/dotclaude:code [next-phase]`
2. If parallel phases done: `/dotclaude:code {k}.5` for merge
3. If all phases done: `/dotclaude:merge` → `/dotclaude:tagging`

**Note**: The feature worktree (`../{project_name}-{type}-{keyword}`) is cleaned up during Step 12 (Merge to Main) of the `/dotclaude:start-new` workflow.

---

## `/dotclaude:code all` - Automatic Full Execution

Execute all phases without user intervention.

### Prerequisites

- Planning documents exist in `{working_directory}/{doc_dir}/`
- GLOBAL.md contains Phase Overview table (recommended)
- All PHASE_*_PLAN_*.md files present

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Detect and Parse Phases                                  │
│    - Read GLOBAL.md Phase Overview table                    │
│    - Fallback: scan PHASE_*_PLAN_*.md files                 │
│    - Build dependency graph                                 │
├─────────────────────────────────────────────────────────────┤
│ 2. Topological Sort                                         │
│    - Group phases into execution layers                     │
│    - Layer 0: no dependencies (PHASE_1)                     │
│    - Layer N: depends on Layer N-1                          │
├─────────────────────────────────────────────────────────────┤
│ 3. Execute Each Layer                                       │
│    - Sequential phase: execute normally                     │
│    - Parallel phases (3A, 3B, 3C):                          │
│      ├── Setup worktrees for each                           │
│      ├── Execute each in its worktree                       │
│      └── (Sequential execution, worktree isolation)         │
├─────────────────────────────────────────────────────────────┤
│ 4. Handle Merge Phases (PHASE_{k}.5)                        │
│    - Merge all parallel branches                            │
│    - Resolve conflicts                                      │
│    - Run full test suite                                    │
│    - Clean up worktrees                                     │
├─────────────────────────────────────────────────────────────┤
│ 5. Continue Until All Phases Complete                       │
├─────────────────────────────────────────────────────────────┤
│ 6. Error Handling                                           │
│    - Validator handles retries internally (max 3)           │
│    - On validator FAIL: phase already marked SKIPPED        │
│    - Continue to next phase (do NOT halt)                   │
│    - Record validator report for final summary              │
├─────────────────────────────────────────────────────────────┤
│ 7. Auto-Commit                                              │
│    - Commit after each successful phase                     │
│    - Include: code files + PLAN + GLOBAL + TEST documents   │
│    - Message: feat({subject}): complete PHASE_{k}           │
├─────────────────────────────────────────────────────────────┤
│ 8. Generate Comprehensive Report                            │
│    - Aggregate all phase results                            │
│    - List successes, failures, skipped                      │
│    - Recommend next steps                                   │
└─────────────────────────────────────────────────────────────┘
```

### Phase Detection Algorithm

**Primary: Parse GLOBAL.md**

1. Read `{working_directory}/{doc_dir}/GLOBAL.md`
2. Locate "Phase Overview" table (`| Phase |`)
3. Extract each row: phase_id, description, status, dependencies
4. Parse dependencies: `"Phase 1, 2"` → `["1", "2"]`
5. Build dependency graph (DAG)

**Fallback: File System Scan**

1. Glob for `{working_directory}/{doc_dir}/PHASE_*_PLAN_*.md`
2. Extract phase_id from filename: `PHASE_(\d+[A-Z]?)_PLAN_`
3. Infer dependencies:
   - Sequential: `PHASE_X` depends on `PHASE_{X-1}`
   - Parallel: `PHASE_{k}A/B/C` depends on `PHASE_{k-1}`
   - Merge: `PHASE_{k}.5` depends on all `PHASE_{k}[A-Z]`

### Execution Order Example

Given phases: 1, 2, 3A, 3B, 3C, 3.5, 4

```
Layer 0: Execute PHASE_1
Layer 1: Execute PHASE_2
Layer 2: Execute PHASE_3A, 3B, 3C (in worktrees, sequentially)
Layer 3: Execute PHASE_3.5 (merge)
Layer 4: Execute PHASE_4
```

### Parallel Phase Execution

```bash
# Setup worktrees (branching from feature branch, not main)
# Worktree naming: {project_name}-{type}-{keyword}-{phase}
git worktree add ../{project_name}-{type}-{keyword}-3A -b feature/{keyword}-3A feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3B -b feature/{keyword}-3B feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3C -b feature/{keyword}-3C feature/{keyword}

# Execute each phase in its worktree (sequentially)
cd ../{project_name}-{type}-{keyword}-3A && [execute PHASE_3A]
cd ../{project_name}-{type}-{keyword}-3B && [execute PHASE_3B]
cd ../{project_name}-{type}-{keyword}-3C && [execute PHASE_3C]

# Return to main, merge, cleanup
cd ../project
git merge feature/{keyword}-3A --no-edit
git merge feature/{keyword}-3B --no-edit
git merge feature/{keyword}-3C --no-edit
git worktree remove ../{project_name}-{type}-{keyword}-3A
git worktree remove ../{project_name}-{type}-{keyword}-3B
git worktree remove ../{project_name}-{type}-{keyword}-3C
```

### CLAUDE.md Rule Exceptions

For `/dotclaude:code all` mode, these CLAUDE.md rules are overridden:

- **"Do NOT git commit without explicit user instruction"**
  → `/dotclaude:code all` invocation IS the explicit instruction for auto-commit

- **"Do NOT proceed to next phase without user instruction"**
  → `/dotclaude:code all` invocation IS the explicit instruction to proceed automatically

### Output

```markdown
# /dotclaude:code all - Execution Complete

## Summary
- Total Phases: 6
- Successful: 5
- Skipped: 1 (PHASE_3A)
- Commits: 5

## Phase Results

| Phase | Status | Commit | Notes |
|-------|--------|--------|-------|
| 1 | SUCCESS | abc123 | - |
| 2 | SUCCESS | def456 | - |
| 3A | SKIPPED | - | Type errors after 3 retries |
| 3B | SUCCESS | ghi789 | - |
| 3C | SUCCESS | jkl012 | - |
| 3.5 | SUCCESS | mno345 | Merged 3B, 3C (3A excluded) |
| 4 | SUCCESS | pqr678 | - |

## Issues Requiring Manual Review

- PHASE_3A: Type error in `src/moduleA/handler.py:45`
  - Error: `Incompatible return type...`

## Next Steps

1. Manually resolve PHASE_3A issues
2. Run `/dotclaude:code 3A` to retry
3. Run `/dotclaude:merge` → `/dotclaude:tagging`
```
