# Purge Command - Design Document

## Feature Overview

**Purpose**: Create a `/dotclaude:purge` command that cleans up merged-and-deployed branches (local and remote) and associated git worktrees.

**Problem**: After merging feature branches and tagging releases, stale branches and worktrees accumulate. Manual cleanup is tedious and error-prone.

**Solution**: A single markdown command file (`commands/purge.md`) that orchestrates a 13-step cleanup workflow with safety guards, tag-deployment filtering, and user confirmation.

**Complexity**: SIMPLE -- single phase, single file creation.

---

## Architecture Decisions

### AD-1: Single Markdown Command File

Follow the existing dotclaude command convention. The command is a self-contained markdown instruction document at `commands/purge.md` with YAML frontmatter containing a `description` field. This matches the pattern used by `merge-main.md`, `tagging.md`, and `configure.md`.

### AD-2: 13-Step Sequential Workflow

The workflow is expressed as a numbered step sequence in a code block, matching the `tagging.md` and `merge-main.md` patterns. Each step maps directly to a SPEC workflow step.

### AD-3: AskUserQuestion for All Confirmations

All user decision points use `AskUserQuestion` with explicit options, following the `configure.md` pattern. This ensures a clickable UI for faster user responses.

### AD-4: Config Chain Resolution Inline

`base_branch` resolution follows the 3-tier config chain (SPEC.md metadata > config file > default `main`). This logic is documented inline in the command file as a prerequisite section, not as a separate utility.

### AD-5: Remote-Unreachable as First-Class Path

Graceful degradation when the remote is unreachable is not an afterthought. It is a distinct conditional path at Step 2 that gates all subsequent remote operations. When the remote is unreachable, the command skips: `git fetch --prune`, remote branch detection, remote branch deletion, and remote tag querying.

### AD-6: Tag Deployment Filter as Distinct Step

The tag deployment check (Step 6 in SPEC) is a separate workflow step, not embedded inside merged branch detection. This makes the logic auditable: first find merged branches, then filter by deployment status.

---

## File Structure

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/purge.md` | CREATE | New purge command with full workflow instructions |

No other files are created or modified.

---

## Implementation Instructions

Create the file `commands/purge.md` following the structure below. Do NOT write the full file content here -- instead, follow these construction instructions.

### 1. YAML Frontmatter

Add YAML frontmatter with a `description` field. Pattern reference: `merge-main.md` line 1-3.

```yaml
---
description: Clean up merged-and-deployed branches and associated worktrees
---
```

### 2. Title

```markdown
# /dotclaude:purge
```

One-line summary beneath the title:

```
Clean up merged branches, remote tracking branches, and orphaned worktrees after releases.
```

### 3. Prerequisites Section

Document the `base_branch` config chain resolution. This section instructs the executing agent to resolve the base branch before starting the workflow.

**Instructions**: Write a "Prerequisites" section with the following content:
- Describe the config chain: SPEC.md metadata field `base_branch` > local config `.claude/dotclaude-config.json` > global config `~/.claude/dotclaude-config.json` > default `main`
- Instruct the agent to resolve this value first and store it as `{base_branch}` for use throughout the workflow
- Instruct the agent to determine the current branch name via `git branch --show-current` and store it as `{current_branch}`

### 4. Workflow Section

Write a `## Workflow` section containing a numbered code block with 13 steps. Each step maps to the SPEC workflow (SPEC.md lines 155-192). The steps are:

**Step 1 -- Resolve config**:
- Read `base_branch` from config chain as described in Prerequisites
- Store resolved value

**Step 2 -- Fetch remote state**:
- Execute `git fetch --prune`
- If the command fails (non-zero exit), set a flag `REMOTE_REACHABLE=false`
- Warn: "Remote unreachable, proceeding with local-only cleanup"
- If `REMOTE_REACHABLE=false`, all subsequent steps that involve remote operations are skipped

**Step 3 -- Determine latest deployed tag**:
- Query remote tags: `git ls-remote --tags origin` (skip if `REMOTE_REACHABLE=false`)
- Determine latest local tag: `git describe --tags --abbrev=0`
- Compare: find the latest tag that exists on the remote
- If no remote tags found: warn user, set `NO_TAGS=true` (treat all merged branches as safe)
- If no local tags found: set `NO_TAGS=true`
- Store result as `{latest_remote_tag}`

**Step 4 -- List worktrees**:
- Execute `git worktree list`
- Parse output to get worktree paths and associated branch names
- The main worktree (bare path) is never a candidate for removal

**Step 5 -- Identify merged branches**:
- Local: `git branch --merged {base_branch}`
- Remote: `git branch -r --merged {base_branch}` (skip if `REMOTE_REACHABLE=false`)
- Filter out: `{current_branch}`, `{base_branch}`, any `origin/HEAD` pointer
- Parse `origin/` prefix from remote branch names

**Step 6 -- Tag deployment filter**:
- Skip entirely if `NO_TAGS=true` (all merged branches treated as safe)
- For each merged branch, check: `git merge-base --is-ancestor {branch_tip} {latest_remote_tag}`
- If the branch tip IS an ancestor of the latest remote tag: branch is deployed, eligible for deletion
- If the branch tip is NOT an ancestor: branch is merged but not yet deployed, exclude from deletion
- Collect excluded branches into a separate "Merged but not yet deployed" list

**Step 7 -- Identify unmerged branches**:
- Local: `git branch --no-merged {base_branch}`
- Remote: `git branch -r --no-merged {base_branch}` (skip if `REMOTE_REACHABLE=false`)
- For each unmerged branch, gather: last commit date, last commit message (use `git log -1 --format="%ai %s" {branch}`)

**Step 8 -- Classify worktrees**:
- For each non-main worktree:
  - If its branch is in the merged-and-deployed set: mark as "merged-and-deployed worktree"
  - If its branch no longer exists (orphaned): mark as "orphaned worktree"
  - Otherwise: leave it alone
- For each eligible worktree, check for uncommitted changes: `git -C {worktree_path} status --porcelain`
  - If output is non-empty: mark as "has uncommitted changes", skip deletion, warn user

**Step 9 -- Display preview report**:
- Display all categories clearly separated:
  - Worktrees to remove (with uncommitted-changes status)
  - Local branches to delete (merged AND deployed)
  - Remote branches to delete (merged AND deployed)
  - Merged but not yet deployed branches (INFO -- protected until tag is pushed)
  - Unmerged branches (WARNING -- with last commit date and message)
- If no merged branches and no eligible worktrees: display "No merged branches to clean up" and skip to unmerged branch warnings, then end

**Step 10 -- User confirmation**:
- Use AskUserQuestion with 3 options:
  - "Proceed with all"
  - "Select individually"
  - "Cancel"
- If "Cancel": abort, display "No changes made", end workflow
- If "Select individually": proceed to Step 10a

**Step 10a -- Individual selection** (only if "Select individually"):
- Ask per-category yes/no using AskUserQuestion:
  - "Remove eligible worktrees?" (yes/no)
  - "Delete merged local branches?" (yes/no)
  - "Delete merged remote branches?" (yes/no) -- skip if `REMOTE_REACHABLE=false`

**Step 11 -- Execute cleanup**:
- For each confirmed worktree: `git worktree remove {path}`
  - If removal fails: report failure, continue with next
- Run `git worktree prune` to clean stale metadata
- For each confirmed local branch: `git branch -d {branch}`
  - If deletion fails: report failure reason, continue with next
- For each confirmed remote branch: `git push origin --delete {branch}` (skip if `REMOTE_REACHABLE=false`)
  - If deletion fails: report failure reason, continue with next
- Track counts: deleted, skipped, failed -- per category

**Step 12 -- Display result report**:
- Summary with counts per category:
  - Worktrees removed: N (skipped: M, failed: F)
  - Local branches deleted: N (skipped: M, failed: F)
  - Remote branches deleted: N (skipped: M, failed: F)
- List skipped items with reasons
- Repeat unmerged branches warning if any exist

### 5. Safety Section

Write a `## Safety` section listing all 5 safety constraints from SPEC (lines 118-122):

- Never delete the current branch (`{current_branch}`)
- Never delete the configured base branch (`{base_branch}`)
- Never delete branches with uncommitted worktree changes
- Never use force-delete (`git branch -D`) -- only safe delete (`git branch -d`)
- Never force push or perform any force operations

### 6. Edge Cases Section

Write a `## Edge Cases` section documenting handling for all 12 edge cases from SPEC (EC-1 through EC-12). For each edge case, state the condition and the expected behavior. These are instructions to the executing agent on how to handle each situation:

| ID | Condition | Handling |
|----|-----------|----------|
| EC-1 | No merged branches found | Display "No merged branches to clean up", skip to unmerged warnings |
| EC-2 | No worktrees exist (only main working tree) | Skip worktree cleanup section entirely |
| EC-3 | Remote unreachable | Set `REMOTE_REACHABLE=false`, skip fetch/remote detection/remote deletion, warn user |
| EC-4 | All branches are unmerged | Display only warnings, no cleanup actions |
| EC-5 | Worktree has uncommitted changes | Skip that worktree, report reason in summary |
| EC-6 | `git branch -d` fails | Report failure, continue with next branch |
| EC-7 | Remote branch deletion fails | Report failure, continue with next branch |
| EC-8 | User cancels at confirmation | Abort all cleanup, display "No changes made" |
| EC-9 | Current branch is a merged branch | Exclude from deletion candidates |
| EC-10 | Worktree path no longer exists on disk | `git worktree prune` handles this |
| EC-11 | Latest local tag not pushed to remote | Branches merged after previous remote tag are protected as "not yet deployed" |
| EC-12 | No tags exist at all | Skip tag deployment check, treat all merged as safe, warn user |

### 7. Output Section

Write an `## Output` section showing the result report template, similar to the pattern in `merge-main.md` (lines 53-62) and `tagging.md` (lines 48-55).

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

---

## Completion Checklist

Map to Designer's 20-item checklist. The executor MUST verify all items after implementation.

- [ ] 1. YAML frontmatter with `description` field present
- [ ] 2. Title is `# /dotclaude:purge`
- [ ] 3. Config resolution section documents `base_branch` 3-tier chain (SPEC.md metadata > config file > default `main`)
- [ ] 4. Step 2: `git fetch --prune` with remote-unreachable fallback sets `REMOTE_REACHABLE=false`
- [ ] 5. Step 3: Remote and local tag comparison with no-tags handling (`NO_TAGS=true`)
- [ ] 6. Step 4: `git worktree list` with output parsing
- [ ] 7. Step 5: Merged branch detection (local + remote), filtering protected branches
- [ ] 8. Step 6: Tag deployment filter using `git merge-base --is-ancestor` per branch
- [ ] 9. Step 7: Unmerged branch detection with last commit info (`git log -1`)
- [ ] 10. Step 8: Worktree classification (merged-and-deployed or orphaned) with uncommitted change check
- [ ] 11. Step 9: Preview report displays all categories
- [ ] 12. Step 10: AskUserQuestion with 3 options ("Proceed with all", "Select individually", "Cancel")
- [ ] 13. Step 10a: "Select individually" flow asks per-category yes/no
- [ ] 14. Step 11: Execution with per-item failure handling (report and continue)
- [ ] 15. Step 12: Result report with counts per category
- [ ] 16. Safety section lists all 5 constraints from SPEC
- [ ] 17. Edge cases EC-1 through EC-12 are all addressed in the document
- [ ] 18. Remote-unreachable path correctly skips ALL remote operations (fetch, remote branch detection, remote branch deletion, remote tag query)
- [ ] 19. Protected branches (`{current_branch}` and `{base_branch}`) excluded everywhere in the workflow
- [ ] 20. Entire command file is written in English

---

## SPEC Cross-Reference

| SPEC Requirement | Design Coverage |
|------------------|-----------------|
| FR-1 (Merged Branch Detection) | Steps 2, 5, 6 |
| FR-2 (Unmerged Branch Alert) | Step 7, Step 9 (warnings section) |
| FR-3 (Worktree Cleanup) | Steps 4, 8, 11 |
| FR-4 (Local Branch Cleanup) | Steps 5, 6, 10, 11 |
| FR-5 (Remote Branch Cleanup) | Steps 5, 6, 10, 11 |
| FR-6 (User Confirmation Flow) | Steps 9, 10, 10a |
| FR-7 (Result Report) | Step 12 |
| NFR-1 (YAML frontmatter) | Section 1 |
| NFR-2 (User-invocable) | Default behavior, no `user-invocable: false` |
| NFR-3 (AskUserQuestion) | Steps 10, 10a |
| NFR-4 (Safety patterns) | Safety section |
| NFR-5 (English content) | Checklist item 20 |
| NFR-6 (Graceful degradation) | Step 2 `REMOTE_REACHABLE` flag, propagated throughout |
| EC-1 through EC-12 | Edge Cases section |
| Safety Constraints (5) | Safety section |

---

## Notes

- The command file does NOT contain executable code. It is a markdown instruction document that Claude reads and follows.
- Do NOT include sample code blocks for git commands beyond what is needed to specify the exact command and its arguments. The executing agent knows how to run git commands.
- The `configure.md` reference is used for the AskUserQuestion pattern. Follow its style of presenting `question`, `options`, and `context` fields.
- The `merge-main.md` reference is used for the Safety section pattern and the Output template pattern.
- The `tagging.md` reference is used for tag-related git commands and the sequential workflow code block pattern.
