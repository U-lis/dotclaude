---
description: Merge current branch to base branch with conflict analysis and branch cleanup
---

# /dotclaude:merge [branch]

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

Merge current branch to base branch, analyze conflicts, cleanup.

## Arguments

| Arg | Description | Default |
|-----|-------------|---------|
| branch | Feature branch to merge | Current branch |

## base_branch Resolution

Resolve the target base branch using this priority chain:

1. **SPEC.md metadata** (highest priority): Look for SPEC.md in the current `{working_directory}` tree. Parse the HTML comment metadata block (`<!-- dotclaude-config ... base_branch: {value} -->`). Extract `base_branch` value if present.
2. **Config file**: Read `.claude/dotclaude-config.json`. Extract `base_branch` field if present.
3. **Default**: `"main"` (lowest priority).

Store the resolved value as `{base_branch}` for use throughout the workflow.

## Workflow

```
1. Save current branch name as {feature_branch}
2. git checkout {base_branch} && git pull origin {base_branch}
3. git merge {feature_branch}
   - If conflict: execute enhanced conflict resolution (see below)
4. Run tests (if configured)
5. git branch -d {feature_branch}
6. Report summary
```

## Conflict Resolution

If merge conflict occurs:

1. **List conflicted files**: Run `git diff --name-only --diff-filter=U` to enumerate all files with conflicts.
2. **Analyze conflict content**: For each conflicted file, read the file and parse conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`). Identify what each branch changed.
3. **Recommend strategy**: For each file, recommend one of:
   - "Accept current ({base_branch})": Use the base branch version
   - "Accept incoming ({feature_branch})": Use the feature branch version
   - "Manual merge required": Conflicts are too complex for automatic recommendation
4. **Present recommendation to user**: Display the analysis and recommendations. Use AskUserQuestion to confirm the strategy for each file or group of files.
5. **Wait for user confirmation**: Do NOT auto-resolve. Explicitly wait for user to approve the recommended strategy or provide alternative instructions.
6. **Execute resolution**: After confirmation, apply the chosen strategy:
   - Accept current: `git checkout --ours {file} && git add {file}`
   - Accept incoming: `git checkout --theirs {file} && git add {file}`
   - Manual: User edits the file, then signals completion
7. After all conflicts resolved: `git commit`

## Safety

- Never force push
- Never commit directly to {base_branch} (only merge)
- Confirm before branch deletion

## Output

```
# Merge Complete

- Feature: {branch}
- Merged to: {base_branch}
- Conflicts: {resolved/none}
- Branch deleted: yes/no

Next: git push origin {base_branch}
```
