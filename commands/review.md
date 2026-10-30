---
description: Review the current diff on five axes with the reviewer agent, or triage the review comments on a pull request (including CodeRabbit), fix the accepted ones, reply, and resolve.
---

# /dotclaude:review [PR URL | #N]

Without an argument, review the current branch against `base_branch` and print the reviewer's table. With a pull request, review its diff, triage its existing review comments, and act on the rows the user approves. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; the reviewer prompt is in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md` (reviewer).

## Configuration

`base_branch`, `working_directory`, `worktree_path`, and `doc_dir` resolve as in Contract: Configuration (SPEC.md via `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh find`). The reviewer reports in English; show its table in the configured language, translating only the Finding and Notes prose and keeping paths, line numbers, axes, results, and severities as they are (Contract: Language).

## Argument resolution

| Argument | Target |
|----------|--------|
| None | The current branch: committed changes `{base_branch}...HEAD` plus uncommitted and untracked files. No changes → print "Nothing to review." and stop |
| GitHub PR URL, or `#N` | Pull request `N`. `#N` that resolves to an issue (`gh api repos/{owner}/{repo}/issues/N --jq 'has("pull_request")'` is `false`) → report "#N is an issue, not a pull request" and stop |
| Anything else | Report the error and stop; never guess |

The PR mode needs `gh` installed and authenticated (as in `/dotclaude:pr` Prerequisites).

## No argument: review the current diff

Call `dotclaude:reviewer` with scope "the full branch diff", the worktree, `base_branch`, and the SPEC, RULES, and PLAN paths (each may be absent). Print the table and the `BLOCKERS: n` line. Nothing else happens; this mode changes no files.

## PR mode

1. **Read.** `gh pr view N --json number,headRefName,baseRefName,url,state`. Get the diff with `gh pr diff N`. Read the comments:
   - inline review comments: `gh api --paginate repos/{owner}/{repo}/pulls/N/comments` (`id`, `path`, `line`, `body`, `user.login`, `in_reply_to_id`);
   - reviews: `gh api --paginate repos/{owner}/{repo}/pulls/N/reviews` (`id`, `state`, `body`, `user.login`);
   - thread state: `gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{id isResolved comments(first:1){nodes{databaseId}}}}}}}' -F o={owner} -F r={repo} -F n=N`, which maps each top-level comment id to its thread id and resolved flag.
   Skip threads already resolved and comments that are replies (`in_reply_to_id` set). CodeRabbit comments (`user.login` `coderabbitai[bot]`) are treated like any reviewer's; their collapsed "nitpick" and "outside diff range" items inside a review body count as separate rows.
2. **Review.** If the PR branch is checked out in a worktree of this repository, call the reviewer on it with `Base: {baseRefName}`; otherwise call it with `Diff source: gh pr diff N`. The reviewer's table is your own second opinion, not a list of comments to answer.
3. **Triage.** For each open comment, check it against the code at the PR head and decide:

   | # | Comment | Author | Location | Decision | Reason |
   |---|---------|--------|----------|----------|--------|
   | 1 | one-line gist | login | `file:line` | accept / rebut / ignore | evidence: `file:line`, SPEC FR, RULES.md line, or reviewer row |

   - `accept`: the comment is correct and in scope for this PR.
   - `rebut`: the comment is wrong or out of scope; the reason is the reply you would post, with evidence.
   - `ignore`: no action and no reply (duplicates of another row, bot status messages, praise).
   Decide from evidence, not from the comment's tone or its author (Contract: Who does what). Reviewer rows with Blocker severity that no comment covers are listed below the table as extra `accept` candidates.
4. **Ask.** Show both tables, then ask with AskUserQuestion, in one call: which rows to act on (multi-select, default the `accept` and `rebut` rows), and which of the acted-on threads to resolve after replying (multi-select). The user can change any decision. Nothing is changed before this answer.
5. **Fix.** When no `accept` row was approved, skip to step 8. For the approved `accept` rows, work in the worktree that has the PR branch checked out; if none exists, stop and tell the user to create one (Contract: Worktree), because the primary checkout stays on `base_branch`. Pick the coder from the changed files' language as in `${CLAUDE_PLUGIN_ROOT}/commands/code.md` (One phase, step 2), and call it with the accepted rows (location, comment text, decision reason) and the instruction to fix only those. Then call code-validator once for the phase whose PLAN lists the fixed files (the same validate-fix loop as `/dotclaude:code`; Contract: Validate-fix loop). Without design documents, run the project's lint and test commands instead and report their result. On validator FAIL, report the unresolved issues, post no replies, and stop.
6. **Commit.** Commit the fix on the PR branch with `fix({keyword}): address review comments on #N (phase {k})`, naming the phase validated in step 5 so the commit guard finds its marker (Contract: Commits). Without design documents the message is `fix: address review comments on #N`.
7. **Push.** Ask whether to push now (AskUserQuestion); push only on a yes, with `git -C {worktree} push origin {headRefName}` (Contract: Git safety: never force). When the user declines, the `accept` replies are not posted, because they would name a commit GitHub does not have; `rebut` replies are still posted. The report says which replies are pending.
8. **Reply.** For each acted-on inline comment: `gh api -X POST repos/{owner}/{repo}/pulls/N/comments/{id}/replies -f body='...'`. For rows from a review body or a CodeRabbit summary (no inline comment id), post one `gh pr comment N --body '...'` that lists them. An `accept` reply names the fix commit sha and what changed; a `rebut` reply states the reason with its evidence. Replies are in the configured language unless the comment is in another language, in which case reply in the comment's language.
9. **Resolve.** Only for threads the user approved in step 4 and whose reply was posted: `gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -F id={thread_id}`.

## Edge cases

| # | Case | Behavior |
|---|------|----------|
| 1 | No argument, no changes | "Nothing to review." No agent call |
| 2 | PR has no open review comments | Show only the reviewer table; offer to post it with `gh pr comment` (AskUserQuestion), nothing else |
| 3 | PR is closed or merged | Show the tables; do not fix, reply, resolve, or push |
| 4 | PR head is a fork the user cannot push to | Triage and reply only; report that fixes need the fork owner |
| 5 | A comment's line is outside the current diff (outdated) | Check it against the current code; usually `ignore` with reason "already changed" |
| 6 | User approves no rows | Stop after step 4; nothing changed |
| 7 | `resolveReviewThread` fails (permissions) | Warn and continue; list the unresolved thread ids in the report |

## Output

```
# Review: {current diff | PR #N}

{reviewer table}
BLOCKERS: {n}

{PR mode: triage table}
{PR mode, after acting: fixed {rows} in {sha}; replied {rows}; resolved {thread count}; pushed: yes | no (reason)}
```
