---
description: Merge current branch to base branch with conflict analysis and branch cleanup
---
# /dotclaude:merge [branch]

Merge a work branch into `base_branch`, resolve conflicts with the user, and clean up. `base_branch` is resolved as in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md` (Configuration, Language). The branch argument defaults to the current branch.

1. Record `{feature_branch}`. If it equals `base_branch`, stop.
2. In the primary checkout: `git checkout {base_branch} && git pull origin {base_branch}`.
3. `git merge {feature_branch}`.
4. On conflict: list the files (`git diff --name-only --diff-filter=U`), read each file's conflict markers, and recommend per file: keep `{base_branch}` (`git checkout --ours`), keep `{feature_branch}` (`git checkout --theirs`), or manual merge. Present the recommendations with AskUserQuestion and wait for the user's choice before touching any file. Apply the chosen strategy, `git add` the files, and let the user edit the manual ones before committing the merge.
5. Run the project's test suite if one is detectable (same detection as code-validator); report the result.
6. Ask before cleaning up, then `git worktree remove ../{project_name}-{type}-{keyword}` first and `git branch -d {feature_branch}` second; git refuses to delete a branch that is still checked out in a worktree. Removing the worktree deletes nothing that is committed; uncommitted files there are reported first and block removal.
7. Report: branch, target, conflicts resolved, branch and worktree removed, and the next step (`git push origin {base_branch}`, then `/dotclaude:tagging`).

Never force-push, and never commit to `base_branch` other than the merge commit itself (Contract: Git safety).
