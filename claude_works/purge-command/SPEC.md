<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Purge Command - Specification

## Context

- **GitHub Issue**: https://github.com/U-lis/dotclaude/issues/28
- **Issue Title**: /dotclaude:purge
- **Issue Label**: enhancement
- **Milestone**: 0.3.0
- **Target Version**: 0.3.0

## Overview

**Purpose**: Add a `/dotclaude:purge` command that cleans up merged branches (local and remote) and associated git worktrees, keeping the repository tidy after releases or feature merges.

**Problem**: After merging feature branches and tagging releases, stale branches accumulate in both local and remote repositories. Git worktrees tied to deleted or merged branches also remain on disk. Manual cleanup is tedious and error-prone -- users risk deleting unmerged branches or forgetting to clean up worktrees.

**Solution**: A single `/dotclaude:purge` command that:
1. Identifies all branches safely merged into the configured base branch (`{base_branch}`)
2. Detects and cleans up orphaned or merged-branch worktrees
3. Deletes merged local and remote branches with user confirmation
4. Alerts the user about unmerged branches that are NOT safe to delete

**Core Principle**: Merge-safety checking is the primary concern, but branches are only deletable if the release containing them has been deployed (tag pushed to remote). A branch must be (1) fully merged into the base branch AND (2) included in a release whose tag exists on the remote before it is considered safe to delete.

---

## Functional Requirements

### FR-1: Merged Branch Detection

| ID | Requirement |
|----|-------------|
| FR-1.1 | Fetch latest remote state before analysis (`git fetch --prune`) |
| FR-1.2 | Identify all LOCAL branches fully merged into the base branch using `git branch --merged {base_branch}` |
| FR-1.3 | Identify all REMOTE branches fully merged into the base branch using `git branch -r --merged {base_branch}` |
| FR-1.4 | Exclude protected branches from deletion candidates: the current branch, `{base_branch}` (the configured base branch is always protected, whether it is main, master, develop, or any other name) |
| FR-1.5 | Read `base_branch` from SPEC.md metadata or fall back to config file, then to default `main` |
| FR-1.6 | After identifying merged branches, determine the latest version tag on the remote using `git ls-remote --tags origin` and compare with the latest local tag. Only branches merged at or before the latest remote tag are safe to delete. Branches merged after the latest remote tag (i.e., part of an undeployed release cycle) MUST be excluded from deletion candidates. |

### FR-2: Unmerged Branch Alert

| ID | Requirement |
|----|-------------|
| FR-2.1 | Identify all LOCAL branches NOT merged into the base branch using `git branch --no-merged {base_branch}` |
| FR-2.2 | Identify all REMOTE branches NOT merged into the base branch using `git branch -r --no-merged {base_branch}` |
| FR-2.3 | Display unmerged branches as a WARNING list with clear indication that they are NOT safe to delete |
| FR-2.4 | For each unmerged branch, show the last commit date and message to help the user assess whether the branch is still needed |

### FR-3: Worktree Cleanup

| ID | Requirement |
|----|-------------|
| FR-3.1 | List all git worktrees using `git worktree list` |
| FR-3.2 | Identify worktrees linked to branches that are in the merged-and-deletable set |
| FR-3.3 | Identify worktrees linked to branches that no longer exist (orphaned worktrees) |
| FR-3.4 | Before deleting a worktree, verify it has no uncommitted changes (`git -C {worktree_path} status --porcelain`) |
| FR-3.5 | If a worktree has uncommitted changes, SKIP deletion and warn the user |
| FR-3.6 | Remove eligible worktrees using `git worktree remove {path}` |
| FR-3.7 | Run `git worktree prune` to clean up stale worktree metadata |

### FR-4: Local Branch Cleanup

| ID | Requirement |
|----|-------------|
| FR-4.1 | Present the list of merged local branches to the user before deletion |
| FR-4.2 | Ask user confirmation via AskUserQuestion before deleting any local branches |
| FR-4.3 | Delete confirmed local branches using `git branch -d {branch}` (safe delete, not force) |
| FR-4.4 | If `git branch -d` fails for any branch, report the failure and continue with the next branch |

### FR-5: Remote Branch Cleanup

| ID | Requirement |
|----|-------------|
| FR-5.1 | Present the list of merged remote branches to the user before deletion |
| FR-5.2 | Ask user confirmation via AskUserQuestion before deleting any remote branches |
| FR-5.3 | Delete confirmed remote branches using `git push origin --delete {branch}` |
| FR-5.4 | If remote deletion fails for any branch, report the failure and continue with the next branch |

### FR-6: User Confirmation Flow

| ID | Requirement |
|----|-------------|
| FR-6.1 | Display a preview report BEFORE any destructive action, showing: worktrees to remove, local branches to delete, remote branches to delete |
| FR-6.2 | Use AskUserQuestion with options: "Proceed with all", "Select individually", "Cancel" |
| FR-6.3 | If "Select individually": ask per-category (worktrees, local branches, remote branches) with yes/no per category |
| FR-6.4 | NEVER perform destructive actions without explicit user confirmation |

### FR-7: Result Report

| ID | Requirement |
|----|-------------|
| FR-7.1 | After cleanup, display a summary report containing: deleted worktrees count, deleted local branches count, deleted remote branches count, skipped items with reasons, unmerged branches warning |
| FR-7.2 | Report format must clearly separate "Cleaned" items from "Skipped" items from "Warnings" |

---

## Non-Functional Requirements

- [ ] NFR-1: Command file follows existing dotclaude command format with YAML frontmatter containing a `description` field
- [ ] NFR-2: Command is user-invocable (appears in slash menu, which is the default behavior)
- [ ] NFR-3: Uses AskUserQuestion for all user interaction points requiring decisions
- [ ] NFR-4: Follows safety patterns established in `commands/merge-main.md` and `commands/tagging.md` (confirmation before destructive actions, no force operations)
- [ ] NFR-5: Command file content is written in English; user-facing messages follow system language setting
- [ ] NFR-6: Graceful degradation when remote is unreachable (skip remote operations, warn user, continue with local cleanup)

---

## Constraints

### Safety Constraints

- MUST NOT delete the current branch (the branch currently checked out)
- MUST NOT delete the configured `{base_branch}` (regardless of its name -- main, master, develop, etc.)
- MUST NOT delete branches with uncommitted worktree changes
- MUST NOT use force-delete (`git branch -D`) -- only safe delete (`git branch -d`)
- MUST NOT force push or perform any force operations

### Technical Constraints

- Must handle remote tracking branches properly (parse `origin/` prefix from `git branch -r` output)
- Must work even when the remote is unreachable (graceful degradation: skip fetch and remote operations, proceed with local-only cleanup)
- Must read `base_branch` from config chain: SPEC.md metadata -> `.claude/dotclaude-config.json` -> default `main`
- Command file is a markdown instruction document in `commands/` directory

### Project Constraints

- Working directory: `claude_works`
- Single command file to create: `commands/purge.md`
- Follow existing command patterns and frontmatter format

---

## Out of Scope

- Automatic merging of unmerged branches
- Workspace directory cleanup (`claude_works/` contents or `.dc_workspace/` contents)
- Tag management or tag cleanup
- Force-deleting unmerged branches
- Interactive branch selection (individual branch-by-branch yes/no)
- Stash management or cleanup
- Repository garbage collection (`git gc`)

---

## Workflow

The command executes the following steps in order:

```
1. Read base_branch from config (SPEC.md metadata -> config file -> default "main")
2. Attempt: git fetch --prune
   -> If fails: warn "Remote unreachable, proceeding with local-only cleanup"
3. Determine latest deployed tag:
   -> Query remote tags: git ls-remote --tags origin
   -> Determine latest local tag: git describe --tags --abbrev=0
   -> Compare: find the latest tag that exists on the remote
   -> If no remote tags found: warn user, treat ALL merged branches as safe
4. List all git worktrees (git worktree list)
5. Identify merged branches:
   -> Local:  git branch --merged {base_branch}
   -> Remote: git branch -r --merged {base_branch}
   -> Filter out: current branch, {base_branch}
6. Tag deployment filter:
   -> For each merged branch, check if it was merged at or before the latest remote tag
   -> Use: git merge-base --is-ancestor {branch} {latest_remote_tag}
   -> Branches merged AFTER the latest remote tag are excluded (undeployed release)
   -> Excluded branches are reported separately as "Merged but not yet deployed"
7. Identify unmerged branches:
   -> Local:  git branch --no-merged {base_branch}
   -> Remote: git branch -r --no-merged {base_branch}
8. Identify worktrees linked to merged-and-deployed branches or orphaned
9. Check worktrees for uncommitted changes
10. Display preview report:
    -> Worktrees to remove (with status)
    -> Local branches to delete (merged AND deployed)
    -> Remote branches to delete (merged AND deployed)
    -> Merged but not yet deployed branches (INFO -- protected until tag is pushed)
    -> Unmerged branches (WARNING)
11. Ask user confirmation (Proceed all / Select individually / Cancel)
12. Execute cleanup:
    -> Remove eligible worktrees
    -> git worktree prune
    -> Delete local merged-and-deployed branches
    -> Delete remote merged-and-deployed branches (if remote reachable)
13. Display result report
```

---

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/purge.md` | Create | New purge command file with full workflow instructions |

---

## Edge Cases

- [ ] EC-1: No merged branches found -- Display "No merged branches to clean up" and skip to unmerged branch warnings
- [ ] EC-2: No worktrees exist (only the main working tree) -- Skip worktree cleanup section entirely
- [ ] EC-3: Remote unreachable -- Skip `git fetch`, skip remote branch detection and deletion, warn user, proceed with local-only cleanup
- [ ] EC-4: All branches are unmerged -- Display only warnings, no cleanup actions needed
- [ ] EC-5: Worktree has uncommitted changes -- Skip that worktree, report reason in summary
- [ ] EC-6: `git branch -d` fails (branch not fully merged despite `--merged` listing) -- Report failure, continue with next branch
- [ ] EC-7: Remote branch deletion fails (permission denied, branch protected) -- Report failure, continue with next branch
- [ ] EC-8: User cancels at confirmation step -- Abort all cleanup, display "No changes made"
- [ ] EC-9: Current branch is a merged branch -- Exclude from deletion candidates (cannot delete checked-out branch)
- [ ] EC-10: Worktree path no longer exists on disk -- `git worktree prune` handles this; include in cleanup
- [ ] EC-11: Latest local tag has NOT been pushed to remote -- All branches merged after the previous remote tag are protected; report them as "Merged but not yet deployed"
- [ ] EC-12: No tags exist at all (local or remote) -- Skip tag deployment check, treat all merged branches as safe to delete, warn user that no tags were found

---

## Open Questions

None.
