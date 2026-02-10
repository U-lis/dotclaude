# Phase 2: Test Cases

## Test Coverage Target

>= 70%

These test cases verify the correctness of changes to `commands/code.md`. Since all changes are to markdown instruction files, testing means structural verification and content correctness through inspection.

## Unit Tests

### code.md: Coder Namespace Correction

- [ ] TC-1.1: No occurrences of `dotclaude:coder-` (without `coders:`) remain in code.md
- [ ] TC-1.2: All Task tool coder invocations use `dotclaude:coders:coder-{language}`
- [ ] TC-1.3: Note above Coder Selection table explains Task tool namespace mapping: `dotclaude:coders:coder-{language}` maps to `agents/coders/{language}.md`
- [ ] TC-1.4: Coder Selection table still lists correct file paths (coders/python.md, coders/javascript.md, etc.)

### code.md: Validation Loop Diagram

- [ ] TC-2.1: Validation Loop diagram shows single invocation of code-validator
- [ ] TC-2.2: Diagram shows validator passing worktree_path, coder namespace, phase_id, document paths
- [ ] TC-2.3: Diagram shows validator-internal loop (validate -> fail -> invoke coder -> re-validate, max 3)
- [ ] TC-2.4: Diagram shows two final outcomes: PASS (documents updated) or FAIL (phase SKIPPED)
- [ ] TC-2.5: Diagram shows orchestrator receiving final result and committing or skipping
- [ ] TC-2.6: No references to orchestrator-managed retry logic remain in the diagram

### code.md: Mandatory Validation Section

- [ ] TC-3.1: Validation Requirements include "invoke code-validator agent with full context"
- [ ] TC-3.2: Validation Requirements state validator manages retries internally
- [ ] TC-3.3: Validation Requirements include ensuring validator has updated documents before commit
- [ ] TC-3.4: Validation Requirements include "include updated documents in the commit"

### code.md: Pre-Commit Checklist

- [ ] TC-4.1: Checklist includes `{working_directory}/{subject}/PHASE_{k}_PLAN_{keyword}.md` in git add
- [ ] TC-4.2: Checklist includes `{working_directory}/{subject}/GLOBAL.md` in git add
- [ ] TC-4.3: Checklist includes `{working_directory}/{subject}/PHASE_{k}_TEST.md` in git add
- [ ] TC-4.4: Checklist still includes changed code files in git add
- [ ] TC-4.5: Checklist mentions quality checks are auto-detected per project (not hardcoded)

### code.md: Workflow Steps Update

- [ ] TC-5.1: Step 5 in workflow describes single invocation with full context
- [ ] TC-5.2: Step 5 mentions passing worktree_path, coder namespace, document paths
- [ ] TC-5.3: Step 6 renamed/updated to "Process Validator Result" (not "Validation Loop")
- [ ] TC-5.4: Step 6 describes PASS (commit with documents) and FAIL (already SKIPPED) outcomes
- [ ] TC-5.5: Step 7 includes document files in git add alongside code files

### code.md: "code all" Mode Updates

- [ ] TC-6.1: Error handling step clarifies retries happen inside the validator
- [ ] TC-6.2: Error handling states "phase already marked SKIPPED" (by validator, not orchestrator)
- [ ] TC-6.3: Auto-commit step includes document files (PLAN + GLOBAL + TEST)
- [ ] TC-6.4: Auto-commit step still includes code files

## Integration Tests

- [ ] IT-1: Validator invocation pattern in code.md matches the contract defined in code-validator.md Phase 1 (same parameters: worktree_path, coder_namespace, phase_id, plan_path, test_path, global_path)
- [ ] IT-2: Coder namespace in code.md matches the corrected namespace in start-new.md (`dotclaude:coders:coder-{detected_language}`)
- [ ] IT-3: Commit scope in code.md matches the commit scope in start-new.md (code + PLAN + GLOBAL + TEST)
- [ ] IT-4: Validation loop pattern in code.md is consistent with the pattern in start-new.md (single-invocation, no orchestrator retry loop)
- [ ] IT-5: "code all" mode validation pattern is consistent with single-phase execution pattern

## Edge Cases

- [ ] EC-1: Verify code.md handles the case where PHASE_{k}_TEST.md does not exist (git add should use conditional add or check existence)
- [ ] EC-2: Verify "code all" mode documentation correctly describes behavior when a phase is SKIPPED (continues to next phase)
- [ ] EC-3: Verify parallel phase execution in code.md passes worktree context to each phase's validator invocation
- [ ] EC-4: Verify merge phase (PHASE_{k}.5) documentation is unaffected by these changes (merge phases do not use the validate-fix loop)
