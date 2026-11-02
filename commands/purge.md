---
description: Clean up merged-and-deployed branches and associated worktrees
---

# /dotclaude:purge

## Version Argument

If the user provides an explicit version argument (e.g., `/dotclaude:purge 0.3.0`), use that version tag as the deployment boundary directly.

If no argument is provided, fall back to auto-detection: determine the latest deployed tag via git (see Step 3 in the Workflow).

## Prerequisites

Resolve `{base_branch}` as in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md` (Configuration, Language) and `{current_branch}` with `git branch --show-current`.

## Workflow

```
1. Resolve config
   -> Read {base_branch} from config chain (see Prerequisites)
   -> Read {current_branch} via git branch --show-current
   -> Compute {date} once with date +%Y_%m_%d; every workspace-archive.sh files and preserve call below gets --date {date}

2. Fetch remote state
   -> Execute: git fetch --prune
   -> If the command fails (non-zero exit):
      - Set REMOTE_REACHABLE=false
      - Warn: "Remote unreachable, proceeding with local-only cleanup"
      - All subsequent steps that involve remote operations are SKIPPED
   -> If the command succeeds:
      - Set REMOTE_REACHABLE=true

3. Determine deployment boundary tag
   -> If explicit version argument provided:
      - Use "v{argument}" as {latest_remote_tag} (e.g., argument "0.3.0" -> tag "v0.3.0")
      - Verify tag exists: git tag -l v{argument}
      - If tag does NOT exist: HALT with error "Tag v{argument} not found."
   -> If no argument provided, auto-detect:
      -> If REMOTE_REACHABLE=true:
         - Query remote tags: git ls-remote --tags origin
         - Determine latest local tag: git describe --tags --abbrev=0
         - Compare: find the latest tag that exists on the remote
         - Store as {latest_remote_tag}
      -> If REMOTE_REACHABLE=false:
         - Determine latest local tag only: git describe --tags --abbrev=0
         - Store as {latest_remote_tag} (local only, no remote verification)
      -> If no tags found at all (local or remote):
         - Set NO_TAGS=true
         - Warn: "No tags found. All merged branches will be treated as safe to delete."

4. List worktrees
   -> Execute: git worktree list
   -> Parse output to get worktree paths and associated branch names
   -> The main worktree (first entry) is NEVER a candidate for removal

5. Identify merged branches
   -> If gh works and a remote exists, for each candidate branch first run:
      gh pr list --state merged --head {branch} --json number,mergedAt
      A branch with a merged PR counts as merged even if git branch --merged disagrees (squash merges)
   -> If gh is unavailable or there is no remote, use git branch --merged as the only signal
   -> Local: git branch --merged {base_branch}
   -> Remote (skip if REMOTE_REACHABLE=false): git branch -r --merged {base_branch}
   -> Filter out from both lists:
      - {current_branch}
      - {base_branch}
      - origin/HEAD pointer
      - origin/{base_branch}
   -> Parse origin/ prefix from remote branch names for display

6. Tag deployment filter
   -> If NO_TAGS=true: skip this step entirely (all merged branches treated as safe)
   -> For each merged branch, check:
      git merge-base --is-ancestor {branch_tip} {latest_remote_tag}
   -> If the branch tip IS an ancestor of {latest_remote_tag}:
      - Branch is deployed, eligible for deletion
      - Add to "safe to delete" list
   -> If the branch tip is NOT an ancestor:
      - Branch is merged but not yet deployed
      - Exclude from deletion candidates
      - Add to "Merged but not yet deployed" list

7. Identify unmerged branches
   -> Local: git branch --no-merged {base_branch}
   -> Remote (skip if REMOTE_REACHABLE=false): git branch -r --no-merged {base_branch}
   -> For each unmerged branch, gather last commit info:
      git log -1 --format="%ai %s" {branch}

8. Classify worktrees
   -> For each non-main worktree:
      - If its branch is in the merged-and-deployed set: mark as "merged-and-deployed worktree"
      - If its branch no longer exists (orphaned): mark as "orphaned worktree"
      - Otherwise: leave it alone (not a candidate for removal)
   -> For each eligible worktree (merged-and-deployed or orphaned), check for uncommitted changes:
      git -C {worktree_path} status --porcelain
      - If output is non-empty: mark as "has uncommitted changes", SKIP deletion, warn user
      - If output is empty: eligible for removal

8a. Plan workspace compaction (see Compact workspace) and dependency cleanup (see Dependency directories)
   -> Plan with the eligible worktrees; nothing is confirmed yet
   -> Collect the candidates and their sizes (du -sh) without changing anything

9. Display preview report
   -> Display all categories clearly separated:

      ## Purge Preview

      ### Worktrees to Remove
      - {path} ({branch}) [merged-and-deployed | orphaned]
      - {path} ({branch}) -- SKIPPED: has uncommitted changes

      ### Local Branches to Delete (merged AND deployed)
      - {branch}

      ### Remote Branches to Delete (merged AND deployed)
      - origin/{branch}

      ### Merged but Not Yet Deployed (protected)
      - {branch} -- merged into {base_branch} but not included in latest remote tag

      ### Unmerged Branches (WARNING)
      - {branch}: last commit {date} - {message}

      ### Workspace Compaction ({total size})
      - {doc_dir}: gzip {n} files {size}, move {n} files {size} -> {workspace_archive_dir}/{repo}/{doc_dir}/
      - Left alone: {n} recent or open, {n} in flight, {n} ignored

      ### Dependency Directories ({total size})
      - {worktree}/{name} ({size}) -- delete[, then symlink to primary]

   -> If no merged branches, no eligible worktrees, no compaction candidates and no dependency directories:
      Display "No merged branches to clean up."
      Skip to unmerged branch warnings, then end workflow.

10. User confirmation
    -> Use AskUserQuestion:
       question: "How would you like to proceed with the cleanup?"
       options:
         - "Proceed with all"
         - "Select individually"
         - "Cancel"
       context: |
         Review the preview report above.
         "Proceed with all" will execute all listed deletions.
         "Select individually" will let you choose per category.
         "Cancel" will abort without making any changes.

    -> If "Cancel": display "No changes made.", end workflow
    -> If "Proceed with all": proceed to Step 11 with all categories confirmed
    -> If "Select individually": proceed to Step 10a

10a. Individual selection (only if "Select individually" chosen)
    -> Ask per-category yes/no using AskUserQuestion:

       question: "Remove eligible worktrees?"
       options:
         - "Yes"
         - "No"

       question: "Delete merged local branches?"
       options:
         - "Yes"
         - "No"

       question: "Delete merged remote branches?"
       options:
         - "Yes"
         - "No"
       (skip this question if REMOTE_REACHABLE=false)

       question: "Move workspace files to {workspace_archive_dir} and delete the originals?"
       options:
         - "Yes"
         - "No"
       (skip if there are no compaction candidates)

       question: "Delete non-symlink virtualenv directories in the remaining worktrees?"
       options:
         - "Yes"
         - "No"
       (skip if there are none)

    -> Record user choices per category

11. Execute cleanup
    -> Any non-zero exit of files apply or preserve in this step ends the workflow: see Stop on archive failure
    -> For each confirmed worktree:
       Compact workspace (below) if confirmed, then Preserve documents (below), then
       git worktree remove {path}
       - If removal fails: report failure reason, continue with next; the worktree counts as staying
    -> Remove dangling symlinks left by worktree.share_from_base: for each of .venv venv node_modules target vendor in the primary checkout, delete it if it is a symlink whose target no longer exists
    -> Run: git worktree prune
    -> For each confirmed local branch:
       git branch -d {branch}
       - If deletion fails: report failure reason, continue with next
    -> For each confirmed remote branch (skip if REMOTE_REACHABLE=false):
       git push origin --delete {branch}
       - If deletion fails: report failure reason, continue with next
    -> If confirmed: Compact workspace (below) on the primary, after all worktree removals so preserved documents are included
    -> If confirmed: Dependency directories (below)
    -> Track counts per category: deleted, skipped, failed

12. Display result report
    -> Display summary:

       # Purge Complete

       - Worktrees removed: {count} (skipped: {count}, failed: {count})
       - Local branches deleted: {count} (skipped: {count}, failed: {count})
       - Remote branches deleted: {count} (skipped: {count}, failed: {count})
       - Workspace files archived: {count}, {size} freed (under {workspace_archive_dir}/{repo}/)
       - Dependency directories deleted: {count}, {size} freed

       ## Skipped Items
       - {item}: {reason}

       ## Warnings (Unmerged Branches)
       - {branch}: last commit {date} - {message}
```

## Stop on archive failure

Any non-zero exit of `preserve` (1, 2, 3, 126, 127, anything) or of a confirmed `files apply`, on a worktree or on the primary, stops the purge at that point. Do not remove that worktree, do not process further worktrees, and do not run the primary pass, `deps`, or any local or remote branch deletion that has not run yet. End the workflow with this report instead of step 12:

```
# Purge Stopped

- Failed: {command}, exit {code}
- Output: {output}
- Done before the stop: {worktrees removed, branches deleted, files archived, documents copied}
- Did not run: {worktrees, branches, primary pass, dependency directories}
```

Nothing already done is rolled back. Re-running purge after the cause is fixed is safe: `files` finds no archived original again and completes a file whose copy already sits at the destination, and `preserve` is silent on files it already copied. A failed copy leaves nothing at its destination. On a later day a new `{date}` makes an undated doc dir arrive a second time under the new date, next to the first copy; nothing is overwritten or lost.

If the Compact category was not confirmed, or was skipped because no location was given, `files` did not run and that is not a failure. `git worktree remove` failing is a different case and keeps report-and-continue.

## Preserve documents

Before a worktree is removed (by purge, and by `/dotclaude:merge` step 6), run `${CLAUDE_PLUGIN_ROOT}/hooks/workspace-archive.sh preserve apply {worktree} --date {date}` (`{date}` as in step 1; outside purge, compute it once with `date +%Y_%m_%d`). A file present in the worktree and absent in the primary is copied to the primary's `{working_directory}`, except under a nested `.git`, `.venv`, `venv` or `node_modules` directory, which is not archived. Each row it prints goes in the report: `copy`, `skip-dep` for such a directory (informational; the worktree's copy goes with the removal), or `conflict` when the destination holds different content and git does not hold the source (a tracked, clean source is skipped silently, and so are the top-level `.hook.log` and `__pycache__` contents). A doc dir whose name has no date prefix lands as `{date}-{name}`, so the record shows when the work was handled; dated names and names the primary already has stay as they are. Nothing in the primary is deleted or overwritten, and the copies are left uncommitted. Exit 1 means a copy failed or a conflict remains. Any non-zero exit stops the purge (Stop on archive failure) or, in `/dotclaude:merge`, stops cleanup at its step 6.

## Compact workspace

`${CLAUDE_PLUGIN_ROOT}/hooks/workspace-archive.sh` does this work; do not reimplement it, and pass only checkout paths (the script resolves `{working_directory}`).

- Plan, for the primary and each eligible worktree: `workspace-archive.sh files plan {path} --removing {wt}... --date {date}`, one `--removing` per eligible worktree. It prints `<action>\t<bytes>\t<path>` and changes nothing. Actions: `gzip` (logs and text data), `move` (images, video, spreadsheets, archives, test output; these do not compress), and `skip-recent`, `skip-open`, `skip-ignored`, `skip-in-flight` (left alone). `__pycache__` contents are neither archived nor deleted. A warning on stderr names a precondition that apply will refuse on, which would stop the purge; show it in the preview.
- `.txt`, `.json`, `.csv`, `.sql`, `.html` and `.xml` can be work records rather than dumps. Name those in the preview and ask; pass the ones to keep as `--exclude '{doc_dir}/{file}'` on every `files` call, and for an undated worktree doc dir also as `--exclude '{date}-{doc_dir}/{file}'`, the name preserve gives it in the primary.
- `workspace_archive_dir` unset or not an absolute path after `~` expands, and there are `gzip` or `move` rows: ask for it in step 10, and write the answer to the global config file (Contract: Configuration). No answer means this category is skipped; never pick a location yourself.
- Apply: `workspace-archive.sh files apply {wt} --date {date} [--exclude ...]` on each confirmed worktree before it is removed, then `workspace-archive.sh files apply {primary} --removing {wt}... --date {date} [--exclude ...]` after all removals, with one `--removing` per worktree actually removed, so a worktree whose `git worktree remove` failed keeps its doc dirs in flight. Exit 1 means some files failed and their originals remain. Exit 2 means the script refused before changing anything (`workspace_size_ignore` unreadable, no `fuser` or `lsof`, no `jq` or `python3`, or a `{working_directory}` outside the repository). Exit 3 is an unset or relative `workspace_archive_dir`. Any non-zero exit stops the purge (Stop on archive failure).

Files land in `{workspace_archive_dir}/{primary checkout name}/{doc_dir}/{relative path}[.gz]`. Each gets a row in `{working_directory}/{doc_dir}/ARCHIVED.md` in the primary (original, location, bytes, sha256, date, method). Originals go only after the copy is verified, then the directories that emptied, up to the doc dir. Doc dirs matching `workspace_size_ignore` stay, and `YYYY_MM_DD-{name}` also matches when `{name}` does.

## Dependency directories

`workspace-archive.sh deps plan {primary} --removing {wt}... --current {session worktree}`, one `--removing` per eligible worktree, lists non-symlink `.venv`/`venv` directories in worktrees that stay; the session's worktree is always skipped, also when `--current` is omitted. On confirmation, plan and apply must act on the same set: just before applying, re-run the same `deps plan` with one `--removing` per worktree actually removed, so it covers exactly the worktrees that stay. When it lists a path the preview did not show, ask before applying; a "no" skips this category. Then the same with `apply` deletes those paths and, when `worktree.share_from_base` is true and the primary has the same directory, leaves the relative symlink init would have made. Report that a worktree with its own dependency versions needs its venv rebuilt.

## Safety

- Never delete the current branch (`{current_branch}`)
- Never delete the configured base branch (`{base_branch}`)
- Never delete branches with uncommitted worktree changes
- Never use force-delete (`git branch -D`) -- only safe delete (`git branch -d`)
- Never force push or perform any force operations
- Never delete a workspace file except through `workspace-archive.sh`, which removes an original only after verifying its copy, leaves tracked files and `.md` files alone, and removes only the directories it emptied

## Edge Cases

| ID | Condition | Handling |
|----|-----------|----------|
| EC-1 | No merged branches found | Display "No merged branches to clean up", skip to unmerged warnings |
| EC-2 | No worktrees exist (only main working tree) | Skip worktree cleanup section entirely |
| EC-3 | Remote unreachable (`git fetch --prune` fails) | Set `REMOTE_REACHABLE=false`, skip remote branch detection, remote branch deletion, and remote tag query; warn user; proceed with local-only cleanup |
| EC-4 | All branches are unmerged | Display only warnings, no cleanup actions needed |
| EC-5 | Worktree has uncommitted changes | Skip that worktree, report reason in summary |
| EC-6 | `git branch -d` fails (branch not fully merged despite `--merged` listing) | Report failure, continue with next branch |
| EC-7 | Remote branch deletion fails (permission denied, branch protected) | Report failure, continue with next branch |
| EC-8 | User cancels at confirmation step | Abort all cleanup, display "No changes made" |
| EC-9 | Current branch is a merged branch | Exclude from deletion candidates (cannot delete checked-out branch) |
| EC-10 | Worktree path no longer exists on disk | `git worktree prune` handles this; include in cleanup |
| EC-11 | Latest local tag has NOT been pushed to remote | Branches merged after the previous remote tag are protected; report them as "Merged but not yet deployed" |
| EC-12 | No tags exist at all (local or remote) | Set `NO_TAGS=true`, skip tag deployment check, treat all merged branches as safe to delete, warn user |
| EC-14 | Branch was squash-merged (`git branch --merged` does not list it) | A merged PR from `gh pr list --state merged --head` counts as merged |
| EC-13 | Explicit version argument tag does not exist | HALT with error. Do NOT proceed with cleanup. |
| EC-15 | A copy fails verification, or a different file already sits at the destination | The script keeps the original and exits 1; stop the purge (Stop on archive failure) |
| EC-16 | `{working_directory}` is tracked (`workspace_tracking: commit`) | Tracked files are not candidates; only untracked files are archived |
| EC-17 | `workspace_archive_dir` unset or relative and no answer | Skip the category; originals stay. `files` did not run, so this is not a failure |
| EC-18 | Preserve finds a different file at the destination and git does not hold the source | Report the `conflict` row, overwrite nothing, stop the purge (Stop on archive failure) |
| EC-19 | The script refuses with exit 2 (`workspace_size_ignore` unreadable, no `fuser` or `lsof`, no `jq` or `python3`, `{working_directory}` outside the repository) | That call changed nothing; stop the purge (Stop on archive failure) |

