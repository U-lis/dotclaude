---
description: Common init workflow - branch creation, analysis phases, and shared utilities for all init commands.
user-invocable: false
---
# Init: common workflow

Shared steps for `init-feature`, `init-bugfix`, `init-refactor`, and `init-github-issue`. Naming, the worktree rule, and the limits are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`.

## Branch and worktree

After the questions (or the pre-filled answers), derive `{keyword}` from the work description, then:

```bash
git checkout {base_branch} && git pull origin {base_branch}
git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}
ls ../{project_name}-{type}-{keyword}          # must exist; otherwise report the failure and stop
cd ../{project_name}-{type}-{keyword}
mkdir -p {working_directory}/$(date +%Y_%m_%d)-{keyword}
```

`git checkout -b` is not a fallback (Contract: Worktree).

## Analysis

Runs after the worktree exists and before the SPEC draft. Each step's work-type focus is in the init file that loaded this one.

**A. Input analysis.** Look for vague wording ("improve", "fix", "better"), missing scope boundaries, unstated assumptions (stack, user type), and contradictions between answers. Batch the clarifying questions per category and ask them with AskUserQuestion, offering concrete options plus Other.

**B. Codebase investigation.** Extract keywords from the requirements, Grep for them, and read the relevant files (Contract: Limits). Record a table of file, line, and relationship (similar functionality, will need modification, pattern to follow).

**C. Conflict detection.** Compare the requirements with what exists: API signatures, data model, behavior. For each conflict, ask the user to choose: prioritize the new behavior, preserve the existing one, or support both. Record existing behavior, required behavior, and the resolution.

**D. Edge cases.** Propose 5 to 10 boundary, error, null/empty, and concurrency cases that are real for this work, and ask the user to approve the list or add to it. Record case and expected behavior.

**E. Summary.** Present requirements, findings, conflicts with resolutions, and edge cases, and ask whether anything should change. Repeat on feedback, at most 3 rounds; after that proceed with the current analysis.

The user may say "skip analysis" to skip all of it; a repository with no code skips B; a change estimated under ten lines may keep D minimal. Record any skip in SPEC.md as "Analysis skipped: {reason}".

## Analysis results in SPEC.md

technical-writer appends these tables to SPEC.md:

```markdown
## Analysis Results
### Related Code
| # | File | Line | Relationship |
### Conflicts Identified
| # | Existing Behavior | Required Behavior | Resolution |
### Edge Cases
| # | Case | Expected Behavior |
```
