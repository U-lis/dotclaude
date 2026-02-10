# Phase 2: Align code.md

## Objective

Update `commands/code.md` to mirror the patterns established in Phase 1. After this phase, the standalone `/dotclaude:code` command uses the same corrected coder namespace, validator-managed loop, worktree context passing, and expanded commit scope as the orchestrator (`start-new.md`).

## Prerequisites

- Phase 1 completed (code-validator.md rewritten, start-new.md updated)
- Access to `commands/code.md` source file
- Understanding of the validator-managed loop contract established in Phase 1

## Instructions

### C1. Fix Coder Namespace in Coder Selection Table (around line 153-159)

The "## Coder Selection" table currently lists agent file paths but does not show the Task tool namespace. The table itself does not contain namespace strings, but the surrounding invocation patterns do.

Search the entire file for any occurrence of `dotclaude:coder-` (without `coders:` prefix) and replace with `dotclaude:coders:coder-`. Specifically:

- Any Task tool invocation pattern referencing `subagent_type="dotclaude:coder-{language}"` must be corrected to `subagent_type="dotclaude:coders:coder-{language}"`
- The Coder Selection table itself (lines 153-159) uses file paths (`coders/python.md` etc.) which are correct. However, add a note above the table: "Task tool namespace: `dotclaude:coders:coder-{language}` (maps to `agents/coders/{language}.md`)"

### C2. Update Validation Loop Diagram (lines 82-98)

Replace the current "### Validation Loop" diagram (lines 82-98) in the "## Mandatory Validation" section with an updated diagram that reflects the validator-managed loop:

```
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
```

### C3. Update Mandatory Validation Section (lines 68-98)

In the "## Mandatory Validation (CRITICAL)" section, update the "### Validation Requirements" subsection (lines 74-78) to reflect the single-invocation pattern:

Replace:
```
After Coder completes implementation:

1. **MUST** invoke code-validator agent
2. **MUST** wait for validation result
3. **MUST** ensure checklist updates are complete before commit
```

With:
```
After Coder completes implementation:

1. **MUST** invoke code-validator agent with full context (worktree path, coder namespace, document paths)
2. **MUST** wait for final validation result (validator manages retries internally)
3. **MUST** ensure validator has updated PLAN checklist, GLOBAL status, and TEST results before commit
4. **MUST** include updated documents in the commit (not just code files)
```

### C4. Update Pre-Commit Checklist (lines 100-109)

Expand the "### Pre-Commit Checklist" to include document files. Replace the current checklist:

```
Before `git add` and `git commit`:

- [ ] code-validator invoked and completed
- [ ] All items in PHASE_{k}_PLAN.md checked off
- [ ] GLOBAL.md phase status updated to "Complete"
- [ ] Quality checks passed (linter, type check, tests)
```

With:

```
Before `git add` and `git commit`:

- [ ] code-validator invoked with full context and completed (final result received)
- [ ] All items in PHASE_{k}_PLAN.md checked off (by validator)
- [ ] GLOBAL.md phase status updated to "Complete" (by validator)
- [ ] Quality checks passed or marked N/A (by validator, auto-detected per project)
- [ ] git add includes: changed code files
- [ ] git add includes: {working_directory}/{subject}/PHASE_{k}_PLAN_{keyword}.md
- [ ] git add includes: {working_directory}/{subject}/GLOBAL.md
- [ ] git add includes: {working_directory}/{subject}/PHASE_{k}_TEST.md (if modified)
```

### C5. Add Worktree Context to Validator Invocation

In the "## Workflow" section (lines 34-66), Step 5 ("Invoke code-validator Agent") currently does not mention worktree context. Update the workflow step description to include worktree context passing:

Replace Step 5 content:
```
│ 5. Invoke code-validator Agent                          │
│    - Check PLAN checklist                               │
│    - Verify TEST implementation                         │
│    - Run quality checks (ruff/ty/pytest etc.)           │
```

With:
```
│ 5. Invoke code-validator Agent (single invocation)      │
│    - Pass: worktree_path, coder namespace, phase_id     │
│    - Pass: PLAN path, TEST path, GLOBAL path            │
│    - Validator manages validate-fix loop internally     │
│    - Validator returns final PASS/FAIL result           │
```

Also update Step 6 ("Validation Loop") to reflect the new pattern:

Replace:
```
│ 6. Validation Loop                                      │
│    - If fail: Coder fixes (max 3 attempts)              │
│    - If still fail: skip and report                     │
```

With:
```
│ 6. Process Validator Result                             │
│    - PASS: proceed to commit (code + documents)         │
│    - FAIL: phase already marked SKIPPED by validator    │
```

### C6. Update "code all" Mode

In the "`/dotclaude:code all` - Automatic Full Execution" section (lines 197-350), verify and update:

**Step 6 (Error Handling, lines 236-239)**:
The current text "On phase failure after 3 retries: mark SKIPPED" is correct in spirit but should clarify that retries happen inside the validator:

Replace:
```
│ 6. Error Handling                                           │
│    - On phase failure after 3 retries: mark SKIPPED         │
│    - Continue to next phase (do NOT halt)                   │
│    - Record all issues for final report                     │
```

With:
```
│ 6. Error Handling                                           │
│    - Validator handles retries internally (max 3)           │
│    - On validator FAIL: phase already marked SKIPPED        │
│    - Continue to next phase (do NOT halt)                   │
│    - Record validator report for final summary              │
```

**Step 7 (Auto-Commit, lines 241-243)**:
Expand to include document files:

Replace:
```
│ 7. Auto-Commit                                              │
│    - Commit after each successful phase                     │
│    - Message: feat({subject}): complete PHASE_{k}           │
```

With:
```
│ 7. Auto-Commit                                              │
│    - Commit after each successful phase                     │
│    - Include: code files + PLAN + GLOBAL + TEST documents   │
│    - Message: feat({subject}): complete PHASE_{k}           │
```

### C7. Update Commit Pattern in Output Section

In the "## Workflow" section, Step 7 ("On Success", lines 62-65):

Replace:
```
│ 7. On Success                                           │
│    - git add, commit (with user permission)             │
│    - Report completion                                  │
```

With:
```
│ 7. On Success                                           │
│    - git add (code files + PLAN + GLOBAL + TEST docs)   │
│    - git commit (with user permission)                  │
│    - Report completion                                  │
```

## Completion Checklist

- [ ] C1: All coder namespace references in code.md use `dotclaude:coders:coder-{language}`
- [ ] C1: Note added above Coder Selection table explaining Task tool namespace
- [ ] C2: Validation Loop diagram updated to show validator-managed loop with single invocation
- [ ] C3: Validation Requirements updated to include full context passing and document update verification
- [ ] C4: Pre-Commit Checklist expanded to include PLAN, GLOBAL, TEST document files
- [ ] C5: Workflow Step 5 updated with worktree context and coder namespace passing
- [ ] C5: Workflow Step 6 updated to "Process Validator Result"
- [ ] C6: "code all" error handling updated to reflect validator-internal retries
- [ ] C6: "code all" auto-commit updated to include document files
- [ ] C7: Workflow Step 7 updated to include document files in git add
- [ ] No remaining references to orchestrator-managed retry loop in code.md
- [ ] No remaining references to old coder namespace (dotclaude:coder-{lang} without coders:)

## Notes

- `code.md` is the standalone command (`/dotclaude:code`). It must be consistent with the orchestrator flow in `start-new.md` but is invoked independently.
- The "code all" mode follows the same patterns as single-phase execution but iterates automatically.
- Line numbers reference the current (unmodified) `code.md`. Use surrounding context to locate sections if lines have shifted.
- The Coder Selection table (lines 153-159) uses file paths, not namespaces. The namespace note is added above the table for clarity.
