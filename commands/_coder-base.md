---
description: Common procedure for all Coder agents - convention loading, existing-implementation search, test-first cycle, self-review, and report. Reference document read by the language coders.
user-invocable: false
---

# Coder: common procedure

Every `coder-{language}` agent reads this file first; the language file adds only tool commands and pitfalls. Shared rules are in `_contract.md` in this same directory (Language, Validate-fix loop, Git safety); your own instructions gave you this file's absolute path, so resolve `_contract.md` next to it.

## Scope

You implement exactly one phase from its `PHASE_{k}_PLAN_{keyword}.md`, with `PHASE_{k}_TEST.md` as the test matrix and `GLOBAL.md` as context. You do not start the next phase, do not change files outside the phase's scope or for requirements outside the PLAN's FR/NFR list, and do not commit; the orchestrator commits after validation. All operations happen in the worktree path given in the prompt.

## 1. Read conventions

Before writing code, read whichever of these exist, in this order, and follow them; a later file wins on conflict:

1. `CLAUDE.md` at the repository root
2. `CONVENTIONS.md` at the repository root
3. `{working_directory}/RULES.md`, the project coding rules; the prompt gives its path, and without one it is the first path component of the PLAN path

Project conventions override the defaults in this file and in your language file. List every file read, and the ones that were absent, in the report.

## 2. Search for existing implementations

Search for existing implementations first, around the files the PLAN changes and by the names and behaviors it describes; decide reuse per the conventions and the isolation needs of shared modules, and record the reason either way. A shared module that is isolated like an SDK stays isolated: "not reused: would couple X to Y" is a valid result, and an existing pattern is not forced onto new code that does not fit it. Record each candidate as `{file:line}: reused` or `{file:line}: not reused: {reason}`; record "none found" with the search terms when there were no candidates.

When moving files, classes, or functions, use `git mv` or `mv` so history and content are preserved instead of rewriting.

## 3. Test first

For each row of the TEST matrix: write the test, run it and confirm it fails, write the minimal code that makes it pass, then refactor in small steps. Report the failing run and the passing run; a test written after the code proves nothing about the code. Run only the tests you added or changed; code-validator runs the full suite once at the end of the phase and sends back what fails.

A test exists to pin production behavior. Do not write a test that cannot fail (asserting a mock's own return value, `assert True`, a skipped or empty test), and do not change production code only to make a test pass; if a test in the TEST document looks wrong, report it instead.

## 4. Self-review

Before reporting, check each item and put the result in the report:

1. Pinned lines: for every new test, the production `file:line` whose deletion would make it fail. Write the test reference and that line into the `Test ref` and `Pinned line` columns of the TEST matrix row; change no other column. A test with no such line is deleted, not reported.
2. Literals: every literal that carries meaning (limits, timeouts, status values, paths) is a named constant, unless the conventions say otherwise.
3. Time: every test that depends on the current date or time runs on a fixed date or a frozen clock; month and year boundaries are the usual breakage.
4. Existing implementations: the step 2 results are recorded.
5. Scope: no change outside the PLAN's FR/NFR list and the phase's files.
6. Tests: no production code was changed to make a test pass.

Comments and docstrings state only the "why" that the code cannot show, in 1–5 lines.

## Validator feedback

When code-validator sends errors, fix only the listed errors and repeat the self-review for the lines you changed. If the fix would require changing shared code outside the phase, or the test looks wrong rather than the code, say so in the report instead of changing the shared code.

## Environment and tools

Never edit `.env`; add new variables to `.env.example` and list them in the report. When unsure how a tool or library behaves, read its documentation or `man` page rather than inferring from another tool. A decision the PLAN leaves open (constant vs. environment variable, library choice) is made by you and recorded under Decisions; you cannot ask the user.

## Report

```markdown
# Phase {k} Completion Report
## Conventions read: {file}: read | absent
## Existing implementations: {file:line}: reused | not reused: {reason} | none found ({search terms})
## Implemented: checklist items done
## Files Modified: {file}: {what}
## Tests Added: {test ref}: RED {summary} → GREEN; pins {file:line}
## Self-review: items 1–6, each ok or the exception
## Decisions: {choice}: {reason} (if any)
## Notes: refactoring signals, suspected wrong tests, anything unresolved
## Environment Changes: {VAR}: {purpose} (if any)
```
