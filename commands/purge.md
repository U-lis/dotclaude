---
description: Clean up merged-and-deployed branches and associated worktrees
---

# /dotclaude:purge

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

Clean up merged branches, remote tracking branches, and orphaned worktrees after releases.

## Version Argument

If the user provides an explicit version argument (e.g., `/dotclaude:purge 0.3.0`), use that version tag as the deployment boundary directly.

If no argument is provided, fall back to auto-detection: determine the latest deployed tag via git (see Step 3 in the Workflow).

## Prerequisites

Before starting the workflow, resolve the following values:

### Base Branch Resolution

Resolve `{base_branch}` using the config chain (first match wins):

1. SPEC.md metadata field `base_branch` (from the `dotclaude-config` HTML comment block)
2. Local config file: `<git_root>/.claude/dotclaude-config.json` -> `base_branch` field
3. Global config file: `~/.claude/dotclaude-config.json` -> `base_branch` field
4. Default: `main`

Store the resolved value as `{base_branch}` for use throughout the workflow.

### Current Branch

Determine the current branch name:

```
git branch --show-current
```

Store the result as `{current_branch}`.

## Workflow

```
1. Resolve config
   -> Read {base_branch} from config chain (see Prerequisites)
   -> Read {current_branch} via git branch --show-current

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

   -> If no merged branches and no eligible worktrees:
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

    -> Record user choices per category

11. Execute cleanup
    -> For each confirmed worktree:
       git worktree remove {path}
       - If removal fails: report failure reason, continue with next
    -> Run: git worktree prune
    -> For each confirmed local branch:
       git branch -d {branch}
       - If deletion fails: report failure reason, continue with next
    -> For each confirmed remote branch (skip if REMOTE_REACHABLE=false):
       git push origin --delete {branch}
       - If deletion fails: report failure reason, continue with next
    -> Track counts per category: deleted, skipped, failed

12. Display result report
    -> Display summary:

       # Purge Complete

       - Worktrees removed: {count} (skipped: {count}, failed: {count})
       - Local branches deleted: {count} (skipped: {count}, failed: {count})
       - Remote branches deleted: {count} (skipped: {count}, failed: {count})

       ## Skipped Items
       - {item}: {reason}

       ## Warnings (Unmerged Branches)
       - {branch}: last commit {date} - {message}
```

## Safety

- Never delete the current branch (`{current_branch}`)
- Never delete the configured base branch (`{base_branch}`)
- Never delete branches with uncommitted worktree changes
- Never use force-delete (`git branch -D`) -- only safe delete (`git branch -d`)
- Never force push or perform any force operations

## Edge Cases

| ID | Condition | Handling |
|----|-----------|----------|
| EC-1 | No merged branches found | Display "No merged branches to clean up", skip to unmerged warnings |
| EC-2 | No worktrees exist (only main working tree) | Skip worktree cleanup section entirely |
| EC-3 | Remote unreachable (`git fetch --prune` fails) | Set `REMOTE_REACHABLE=false`, skip fetch, remote branch detection, remote branch deletion, and remote tag query; warn user; proceed with local-only cleanup |
| EC-4 | All branches are unmerged | Display only warnings, no cleanup actions needed |
| EC-5 | Worktree has uncommitted changes | Skip that worktree, report reason in summary |
| EC-6 | `git branch -d` fails (branch not fully merged despite `--merged` listing) | Report failure, continue with next branch |
| EC-7 | Remote branch deletion fails (permission denied, branch protected) | Report failure, continue with next branch |
| EC-8 | User cancels at confirmation step | Abort all cleanup, display "No changes made" |
| EC-9 | Current branch is a merged branch | Exclude from deletion candidates (cannot delete checked-out branch) |
| EC-10 | Worktree path no longer exists on disk | `git worktree prune` handles this; include in cleanup |
| EC-11 | Latest local tag has NOT been pushed to remote | Branches merged after the previous remote tag are protected; report them as "Merged but not yet deployed" |
| EC-12 | No tags exist at all (local or remote) | Set `NO_TAGS=true`, skip tag deployment check, treat all merged branches as safe to delete, warn user |
| EC-13 | Explicit version argument tag does not exist | HALT with error. Do NOT proceed with cleanup. |

## Output

```
# Purge Complete

- Worktrees removed: {count} (skipped: {count}, failed: {count})
- Local branches deleted: {count} (skipped: {count}, failed: {count})
- Remote branches deleted: {count} (skipped: {count}, failed: {count})

## Skipped Items
- {item}: {reason}

## Warnings (Unmerged Branches)
- {branch}: last commit {date} - {message}
```
