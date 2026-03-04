# Phase 1: Test Cases - Core Variable Introduction and Path Updates

## Test Coverage Target

>= 70%

This phase modifies markdown instruction files (not executable code), so "tests" are manual verification checks rather than automated unit tests.

## Verification Method

All verifications are performed via shell commands (grep, diff, manual inspection). Each test case includes the verification command to run.

---

## Unit Tests

### Variable Generation (`_init-common.md`)

- [ ] TC-1.1: `_init-common.md` contains a step that generates `{doc_dir}` using `date +%Y_%m_%d`
  - Verify: `grep -n 'date +%Y_%m_%d' commands/_init-common.md` returns at least 1 match
- [ ] TC-1.2: `_init-common.md` `mkdir` step uses `{doc_dir}` instead of `{subject}`
  - Verify: `grep -n 'mkdir.*{doc_dir}' commands/_init-common.md` returns at least 1 match
- [ ] TC-1.3: `_init-common.md` does NOT have `mkdir.*{subject}` anymore
  - Verify: `grep -n 'mkdir.*{subject}' commands/_init-common.md` returns 0 matches
- [ ] TC-1.4: The `{doc_dir}` generation step appears BEFORE the `mkdir` step
  - Verify: The line number of `date +%Y_%m_%d` is less than the line number of `mkdir.*{doc_dir}`

### Metadata Block (`start-new.md`)

- [ ] TC-2.1: SPEC.md metadata block template contains `doc_dir:` field
  - Verify: `grep -n 'doc_dir:' commands/start-new.md` returns at least 1 match in the metadata template section
- [ ] TC-2.2: Downstream commands description mentions `{doc_dir}` in metadata explanation
  - Verify: `grep -n 'doc_dir' commands/start-new.md` returns matches in the documentation paragraph

### Path References - Commands

- [ ] TC-3.1: `start-new.md` has zero occurrences of `{working_directory}/{subject}/` in directory path contexts
  - Verify: Grep for `{working_directory}/{subject}/` -- remaining matches should ONLY be in commit message strings (e.g., `git commit -m "..."`)
- [ ] TC-3.2: `start-new.md` has zero occurrences of `claude_works/{subject}/` in example paths
  - Verify: `grep -n 'claude_works/{subject}/' commands/start-new.md` returns 0 matches (all replaced with `claude_works/{doc_dir}/`)
- [ ] TC-3.3: `design.md` has zero occurrences of `{working_directory}/{subject}/`
  - Verify: `grep -n '{working_directory}/{subject}/' commands/design.md` returns 0 matches
- [ ] TC-3.4: `design.md` has at least 3 occurrences of `{working_directory}/{doc_dir}/` or `{doc_dir}`
  - Verify: `grep -cn '{doc_dir}' commands/design.md` returns count >= 3
- [ ] TC-3.5: `code.md` has zero occurrences of `{working_directory}/{subject}/` in directory path contexts
  - Verify: Grep and manually confirm no directory path contexts remain with `{subject}`
- [ ] TC-3.6: `code.md` contains `{doc_dir}` references
  - Verify: `grep -cn '{doc_dir}' commands/code.md` returns count >= 3
- [ ] TC-3.7: `validate-spec.md` prerequisites use `{doc_dir}`
  - Verify: `grep -n '{doc_dir}' commands/validate-spec.md` returns matches at prerequisite lines
- [ ] TC-3.8: `update-docs.md` SPEC reference path uses `{doc_dir}`
  - Verify: `grep -n '{doc_dir}' commands/update-docs.md` returns at least 1 match

### Path References - Init Commands

- [ ] TC-4.1: `init-feature.md` Output section uses `{doc_dir}` for directory and SPEC paths
  - Verify: `grep -n '{doc_dir}' commands/init-feature.md` returns at least 2 matches in Output section
- [ ] TC-4.2: `init-bugfix.md` Output section uses `{doc_dir}` for directory and SPEC paths
  - Verify: `grep -n '{doc_dir}' commands/init-bugfix.md` returns at least 2 matches in Output section
- [ ] TC-4.3: `init-refactor.md` Output section uses `{doc_dir}` for directory and SPEC paths
  - Verify: `grep -n '{doc_dir}' commands/init-refactor.md` returns at least 2 matches in Output section

### Path References - Agents

- [ ] TC-5.1: `agents/designer.md` Input section uses `{doc_dir}`
  - Verify: `grep -n '{doc_dir}' agents/designer.md` returns at least 1 match
- [ ] TC-5.2: `agents/spec-validator.md` uses `{doc_dir}` for validation target and process
  - Verify: `grep -n '{doc_dir}' agents/spec-validator.md` returns at least 2 matches

### README Update

- [ ] TC-6.1: `README.md` Document Types section uses `{doc_dir}` in directory structure example
  - Verify: `grep -n '{doc_dir}' README.md` returns at least 1 match in the Complex Tasks subsection

---

## Integration Tests

### Cross-File Consistency

- [ ] IT-1: All 12 modified files use `{doc_dir}` consistently for directory paths
  - Verify: Run `grep -rn '{working_directory}/{subject}/' commands/ agents/` and confirm ALL remaining matches are in commit message contexts only
- [ ] IT-2: No file uses `{doc_dir}` in branch name contexts
  - Verify: `grep -rn 'feature/{doc_dir}' commands/ agents/ templates/` returns 0 matches
- [ ] IT-3: No file uses `{doc_dir}` in commit message contexts
  - Verify: `grep -rn 'git commit.*{doc_dir}' commands/ agents/` returns 0 matches
- [ ] IT-4: SPEC.md metadata block template is consistent between `start-new.md` and downstream command expectations

---

## Edge Cases

### Preservation Checks

- [ ] EC-1: `templates/PHASE_MERGE.md` is NOT modified
  - Verify: `git diff templates/PHASE_MERGE.md` shows no changes
- [ ] EC-2: All `git commit -m` patterns still use `{subject}`, not `{doc_dir}`
  - Verify: `grep -rn 'git commit -m' commands/` -- every match with `{subject}` in the message is correct; no match contains `{doc_dir}` in the message
- [ ] EC-3: Branch name patterns (`feature/{keyword}`, `bugfix/{keyword}`, `refactor/{keyword}`) are unchanged
  - Verify: `grep -rn 'feature/{subject}' templates/PHASE_MERGE.md` still returns matches
- [ ] EC-4: Worktree naming patterns are unchanged (still use `{keyword}` or `{subject}`, not `{doc_dir}`)
  - Verify: `grep -rn 'worktree add' commands/` -- no match contains `{doc_dir}`
- [ ] EC-5: The `{subject}` variable is NOT removed or renamed in any file
  - Verify: `grep -rn '{subject}' commands/ agents/ templates/` returns many matches (variable still widely used for non-directory purposes)
