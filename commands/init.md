---
description: Initialize a unit of work from free text, a GitHub issue or PR, a Jira key, or a prefill body. Infers the work type, analyzes the codebase, and produces SPEC.md in a new worktree. Called by start-new.
user-invocable: false
---
# Init

Turn whatever the user gave `/dotclaude:start-new` into an approved-ready `SPEC.md` in a fresh worktree, asking at most two questions. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; prompt templates in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`.

## 1. Intake

Build one **intake text** from the input. Keep the source reference for the SPEC metadata.

| Input | How |
|-------|-----|
| GitHub issue or PR URL, or `#N` | `gh issue view N --repo owner/repo --json title,body,labels,milestone` (or `gh pr view … --json title,body,labels,milestone,files`). Intake = title + body. Keep `github_issue: N` and the milestone title. If `gh` is missing or fails, tell the user and ask them to paste the text. |
| Jira key (`[A-Z][A-Z0-9]+-\d+`) | Use a Jira MCP tool if one is available in this session; otherwise ask the user to paste the ticket text. Keep the key for the branch keyword. |
| `--prefill` body | Apply `${CLAUDE_PLUGIN_ROOT}/commands/_prefill-filters.md` first; the filtered text is the intake and the unfiltered body is never written anywhere. A URL inside the body is fetched as above and appended as context; the body stays primary. |
| Free text, or nothing | The text is the intake. With nothing, ask one open question: "What do you want to work on?" (free text). |

## 2. Work type

Infer `feature`, `bugfix`, or `refactor` from the intake: a defect description, error, or "expected X but got Y" is a bugfix; "restructure / extract / rename / clean up without changing behavior" is a refactor; otherwise feature. GitHub labels `bug`/`enhancement`/`refactoring` and Jira issue type override the guess.

Confirm with one AskUserQuestion whose first option is the inferred type marked "(recommended)" and the other two types follow. Skip the question when the source carried an explicit type label or config `default_work_type` is set.

## 3. Branch and worktree

Derive `{keyword}`: a short kebab-case slug from the intake, or the issue/Jira key when there is one. Then, from the primary checkout:

```bash
git checkout {base_branch} && git pull origin {base_branch}
git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}
test -d ../{project_name}-{type}-{keyword} || { echo "worktree not created"; exit 1; }
cd ../{project_name}-{type}-{keyword}
mkdir -p {working_directory}/$(date +%Y_%m_%d)-{keyword}
```

`git checkout -b` is not a fallback (Contract: Worktree). Everything after this step happens in the worktree.

## 4. Analysis

Read-only. Use the Explore agent for wide searches and read the files that matter yourself (Contract: Limits). Record findings as the tables in section 6.

**Investigation by type**

- *feature*: existing code with similar function (reuse candidates), the files and integration points that will change, the patterns to follow.
- *bugfix*: reproduce from the intake if possible; find the root cause as `file:line` with a code-level explanation; `git log -20 --oneline -- <file>` on affected files to spot a regression; list every caller that depends on the current behavior. If the cause cannot be pinned, record what was searched, the candidates with confidence, and mark the SPEC root cause "requires further investigation".
- *refactor*: current structure and its problems, every dependent module and call site, test coverage of the target (which behaviors are protected, which are not), and whether behavior may change at all.

**Conflicts**: requirements versus existing API signatures, data model, and behavior. Each conflict becomes a Decisions Required row (prioritize new, preserve existing, support both) unless the intake already settles it.

**Requirements**: draft the `FR-n`/`NFR-n` list from the intake and the investigation, in the user's words where possible. Anything the intake does not settle and the code does not decide becomes a question, not an assumption.

**Edge cases**: map each case to a pair `(FR-n, partition)` with partition in `normal, boundary, invalid, error, concurrency, permission, data-migration`. A second case for the same pair needs one line saying how its failure path differs from the first. A case that maps to no FR is not written into the SPEC; it is reported once as "out-of-scope finding". Bugfix cases include the reproduction, its variations, and the neighboring inputs that must keep working.

## 5. One question for what is missing

Collect everything still undecided: ambiguous requirement wording, conflicts, scope boundaries, and the target version. Ask them together in a single multi-question AskUserQuestion. Rules:

- Every question has at least two options. When only one natural option exists, the second is "Decide for me (recommended: …)".
- Include the edge-case list verbatim in the question text when asking the user to confirm it, so they can see what they approve.
- Target version is one of the questions only when `CHANGELOG.md` exists or `version_files` is set, and only when the GitHub milestone did not already give it. Options are the computed patch/minor/major.
- Nothing is asked that the intake or the code already answers.

If nothing is missing, ask nothing.

## 6. SPEC.md

Call technical-writer (template `${CLAUDE_PLUGIN_ROOT}/templates/SPEC.md`, configured language) with the intake summary, requirements, decisions taken, the analysis tables, and the metadata values (`stage: spec_review`, `github_issue`, `target_version` when known). The SPEC includes:

```markdown
## Analysis Results
### Related Code        | # | File | Line | Relationship |
### Conflicts           | # | Existing | Required | Resolution |
### Edge Cases          | # | FR | Partition | Case | Expected behavior |
### Out-of-scope findings (not requirements)
```

Bugfix SPECs add Root Cause (`file:line`, explanation) and Fix Strategy; refactor SPECs add Behavior Preservation (what must not change, which tests prove it) and Dependents.

Return to start-new with the SPEC path. start-new Step 3 runs the review.
