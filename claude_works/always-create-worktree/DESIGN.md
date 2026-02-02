# Always Create Worktree - Design Document

## Feature Overview

**Purpose**: Replace `git checkout -b` with `git worktree add` in the dotclaude init workflow so that every new work item (feature, bugfix, refactor, github-issue) creates a dedicated git worktree instead of switching the current working directory's branch.

**Problem**: The current workflow uses `git checkout -b` which switches the branch in-place, preventing parallel work and risking uncommitted changes in the current directory.

**Solution**: Use `git worktree add ../{subject} -b {type}/{keyword} {base_branch}` to create an isolated worktree for each work item. Track the worktree path via a new `worktree_path` metadata field in SPEC.md.

---

## Architecture Decisions

### AD-1: Worktree creation command

**Decision**: Replace `git checkout -b {type}/{keyword}` with `git worktree add ../{subject} -b {type}/{keyword} {base_branch}`.

**Rationale**: `git worktree add` creates a separate working directory with its own branch, allowing concurrent work on multiple tasks without branch switching conflicts. The `../{subject}` path places the worktree as a sibling directory to the repository root.

### AD-2: SPEC.md metadata field

**Decision**: Add `worktree_path: ../{subject}` to the SPEC.md configuration metadata block, placed after the `language` field.

**Rationale**: Downstream commands (`/dotclaude:code`, `/dotclaude:design`, etc.) read SPEC.md metadata to resolve configuration. Adding `worktree_path` there makes the worktree location discoverable without re-running detection logic. Commands that do not find this field fall back to `.` (current directory), preserving backward compatibility.

### AD-3: Backward compatibility

**Decision**: When `worktree_path` is absent from SPEC.md metadata, all commands fall back to `.` (current directory).

**Rationale**: Existing SPEC.md files created before this change will not have the field. Falling back to `.` ensures old workflows continue to function without modification.

### AD-4: Parallel phase base branch

**Decision**: Parallel phase worktrees (e.g., `../{subject}-3A`) branch from the feature worktree branch (not `main`).

**Rationale**: Parallel phases build on top of completed sequential phases. Branching from `main` would lose prior phase work. The feature branch contains all preceding phase commits and is the correct base.

### AD-5: Worktree cleanup at merge step

**Decision**: Add `git worktree remove ../{subject}` to Step 12 (Merge to Main) after the branch merge and deletion.

**Rationale**: After merging the feature branch into main and deleting the branch, the worktree directory is no longer needed. Cleaning it up prevents directory accumulation.

### AD-6: Uniform init file updates

**Decision**: Update all four init command files (`init-feature.md`, `init-bugfix.md`, `init-refactor.md`, `init-github-issue.md`) with consistent worktree creation language.

**Rationale**: All work types follow the same worktree creation pattern. Uniform updates prevent behavioral divergence between work types and keep documentation consistent.

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Central Orchestrator and Metadata Changes | Complete | None |
| 2 | Init Command Files Alignment | Complete | Phase 1 |

---

## Phase 1: Central Orchestrator and Metadata Changes

### Objective

Modify `commands/start-new.md` and `commands/code.md` to use git worktree instead of branch checkout, add worktree metadata to SPEC.md, and update parallel phase and merge step instructions accordingly.

### Prerequisites

- Repository cloned and accessible
- SPEC.md approved and committed

### Instructions

#### 1. Add `worktree_path` to SPEC.md metadata template

**File**: `commands/start-new.md`

In the "SPEC.md Configuration Metadata" section (around lines 24-30), add `worktree_path: ../{subject}` after the `language` line in the metadata template block:

```html
<!-- dotclaude-config
working_directory: {resolved_value}
base_branch: {resolved_value}
language: {resolved_value}
worktree_path: ../{subject}
-->
```

Also update the paragraph that describes what downstream commands read from this metadata to mention `worktree_path`.

#### 2. Change branch creation to worktree creation

**File**: `commands/start-new.md`

At line 85, replace:
```
3. Create work branch: `git checkout -b {type}/{keyword}`
```
with:
```
3. Create work branch via worktree: `git worktree add ../{subject} -b {type}/{keyword} {base_branch}`
```

#### 3. Update project directory reference

**File**: `commands/start-new.md`

At Step 2 item 4 (line 86), update the project directory instruction to reference the worktree path. The working directory creation (`mkdir -p {working_directory}/{subject}`) should now operate inside the worktree at `../{subject}/{working_directory}/{subject}/`, or clarify that the worktree root replaces the need for a separate project directory.

#### 4. Update parallel phase worktree commands

**File**: `commands/start-new.md`

In Step 10 (around lines 244-265), update the parallel phase worktree commands so that:
- Paths are relative to the feature worktree (`../{subject}`) rather than the main repository root
- The base branch for parallel worktrees is the feature branch (e.g., `feature/{keyword}`), not `main`

Modify the worktree add commands from:
```bash
git worktree add ../{subject}-3A -b feature/{subject}-3A
```
to:
```bash
git worktree add ../{subject}-3A -b feature/{subject}-3A feature/{keyword}
```

Apply the same pattern to all parallel worktree add commands in that section.

#### 5. Update Step 12 (Merge) with worktree cleanup

**File**: `commands/start-new.md`

In Step 12 (around lines 281-287), add worktree removal after the branch deletion:

```bash
git checkout main
git pull origin main
git merge {branch} --no-edit
git branch -d {branch}
git worktree remove ../{subject}
```

#### 6. Update Step 6 Checkpoint

**File**: `commands/start-new.md`

In the Step 6 Checkpoint section (around lines 166-183), add a verification that the worktree directory exists:

Add a new check item:
```
4. **Worktree Check**:
   - Directory `../{subject}` must exist as a valid git worktree
   - Run: `git worktree list | grep {subject}`
   - If not found: HALT and report "Worktree not found. Create worktree before design phase."
```

#### 7. Add worktree_path reference in code.md

**File**: `commands/code.md`

In the Configuration section (around lines 10-12), add instruction to also read `worktree_path` from SPEC.md metadata:

```
The `{working_directory}` and `{worktree_path}` values are read from SPEC.md metadata (written by `/dotclaude:start-new`).
If SPEC.md is not found, fall back to defaults: `{working_directory}` = `.dc_workspace`, `{worktree_path}` = `.` (current directory).
```

#### 8. Update parallel phase paths in code.md

**File**: `commands/code.md`

In the Parallel Phase Handling section (around lines 111-129) and the parallel phase execution section (around lines 282-302), update worktree paths to be relative to the feature worktree rather than the main repository root.

Update the setup commands to branch from the feature branch:
```bash
# For PHASE_3A
git worktree add ../{subject}-3A -b feature/{subject}-3A feature/{keyword}
```

#### 9. Add worktree cleanup note in code.md

**File**: `commands/code.md`

In the "Next Steps" section (around lines 187-191), add a note that the feature worktree is cleaned up at Step 12 of the start-new workflow, not by the code command:

```
**Note**: The feature worktree (`../{subject}`) is cleaned up during Step 12 (Merge to Main) of the `/dotclaude:start-new` workflow.
```

### Completion Checklist

- [x] `worktree_path` field added to SPEC.md metadata template in `start-new.md` (line 29)
- [x] `git checkout -b` replaced with `git worktree add` in `start-new.md` Step 2 item 3 (line 86)
- [x] Step 2 item 4 (project directory) updated for worktree context in `start-new.md` (line 87)
- [x] Parallel phase worktree commands updated with feature branch base in `start-new.md` Step 10 (lines 251-253, 581-583)
- [x] `git worktree remove ../{subject}` added to `start-new.md` Step 12 (line 293)
- [x] Worktree existence check added to `start-new.md` Step 6 Checkpoint (lines 184-188)
- [x] `worktree_path` metadata reading added to `code.md` Configuration section (lines 11-12)
- [x] Parallel phase paths updated in `code.md` to be relative to feature worktree (lines 115-116, 286-288)
- [x] Worktree cleanup note added to `code.md` Next Steps section (line 192)

### Notes

- The `{base_branch}` in the worktree add command comes from the resolved config (default: `main`). It must match the branch from which the feature work should diverge.
- The `{subject}` placeholder is the work item keyword used throughout the workflow (e.g., `always-create-worktree`).
- All changes are to markdown instruction files, not executable code. The instructions guide the AI agent's behavior during workflow execution.

---

## Phase 2: Init Command Files Alignment

### Objective

Update all four init command files to reflect that branch creation now produces a worktree instead of a checkout, ensuring consistent documentation across all work types.

### Prerequisites

- Phase 1 completed (central orchestrator changes in place)

### Instructions

#### 1. Update init-feature.md Output section

**File**: `commands/init-feature.md`

In the Output section (around lines 177-181), change item 1 from:
```
1. Feature branch `feature/{keyword}` created and checked out
```
to:
```
1. Feature worktree created at `../{subject}` with branch `feature/{keyword}`
```

#### 2. Update init-bugfix.md Output section

**File**: `commands/init-bugfix.md`

In the Output section (around lines 218-221), change item 1 from:
```
1. Bugfix branch `bugfix/{keyword}` created and checked out
```
to:
```
1. Bugfix worktree created at `../{subject}` with branch `bugfix/{keyword}`
```

#### 3. Update init-refactor.md Output section

**File**: `commands/init-refactor.md`

In the Output section (around lines 199-204), change item 1 from:
```
1. Refactor branch `refactor/{keyword}` created and checked out
```
to:
```
1. Refactor worktree created at `../{subject}` with branch `refactor/{keyword}`
```

#### 4. Update init-github-issue.md branch creation

**File**: `commands/init-github-issue.md`

In Step 5 (around lines 125-163), update the branch creation instruction. Change:
```
1. **Branch Creation**: Use pre-filled `branch_keyword`
   - Create: `git checkout -b {work_type}/{branch_keyword}`
```
to:
```
1. **Branch Creation**: Use pre-filled `branch_keyword`
   - Create: `git worktree add ../{subject} -b {work_type}/{branch_keyword} {base_branch}`
```

#### 5. Update init-github-issue.md Output section

**File**: `commands/init-github-issue.md`

In the Output section (around lines 186-192), add worktree creation mention. Update the list to include:
```
1. Parsed GitHub issue data
2. Detected work type (feature/bugfix/refactor)
3. Pre-populated context for init workflow
4. Worktree created at `../{subject}` with branch `{work_type}/{branch_keyword}`
5. Route to appropriate init-xxx.md
6. Continue normal init workflow from there (with pre-filled values)
```

### Completion Checklist

- [x] `init-feature.md` Output section updated with worktree creation language
- [x] `init-bugfix.md` Output section updated with worktree creation language
- [x] `init-refactor.md` Output section updated with worktree creation language
- [x] `init-github-issue.md` Step 5 branch creation changed to `git worktree add`
- [x] `init-github-issue.md` Output section includes worktree creation mention

### Notes

- All four init files must use consistent wording for the worktree creation output line: `{Type} worktree created at ../{subject} with branch {type}/{keyword}`.
- The `init-github-issue.md` file has two update points (Step 5 and Output), unlike the other three which only need Output section updates. This is because `init-github-issue.md` contains its own branch creation command at Step 5, while the other init files delegate branch creation to `start-new.md` Step 2 item 3.
- No changes are needed to the question/analysis sections of any init file. Only the branch creation commands and output descriptions change.
