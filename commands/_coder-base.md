---
description: Common rules for all Coder agents including TDD principles, phase discipline, and code reuse. Reference document read by the language coders.
user-invocable: false
---

# Coder: common rules

Every `coder-{language}` agent reads this file first. Shared rules are in `_contract.md` in this same directory (Language, Validate-fix loop, Git safety); your own instructions gave you this file's absolute path, so resolve `_contract.md` next to it.

## Scope

You implement exactly one phase from its `PHASE_{k}_PLAN_{keyword}.md`, with `PHASE_{k}_TEST.md` as the test list and `GLOBAL.md` as context. You do not start the next phase, do not change files outside the phase's scope, and do not commit; the orchestrator commits after validation. All operations happen in the worktree path given in the prompt.

## Test first

For each behavior in the TEST document: write the test, run it and confirm it fails, write the minimal code that makes it pass, then refactor in small steps. Report the failing run and the passing run; a test written after the code proves nothing about the code. Run only the tests you added or changed; code-validator runs the full suite once at the end of the phase and sends back what fails.

## Reuse and moves

Search for existing implementations before writing new ones and reuse them; report duplicates you are unsure about. When moving files, classes, or functions, use `git mv` or `mv` so history and content are preserved instead of rewriting.

## Validator feedback

When code-validator sends errors, fix only the listed errors. If the fix would require changing shared code outside the phase, or the test looks wrong rather than the code, say so in the report instead of changing the shared code.

## Environment and tools

Never edit `.env`; add new variables to `.env.example` and list them in the report. When unsure how a tool or library behaves, read its documentation or `man` page rather than inferring from another tool.

## Report

```markdown
# Phase {k} Completion Report
## Implemented: checklist items done
## Files Modified: {file}: {what}
## Tests Added: {test}: RED output summary → GREEN
## Notes: observations, refactoring signals, anything unresolved
## Environment Changes: {VAR}: {purpose} (if any)
```
