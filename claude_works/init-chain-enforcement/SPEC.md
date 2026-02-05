<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-init-chain-enforcement
-->

# Init Chain Enforcement Bugfix - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/40
**GitHub Issue Number**: 40
**Target Version**: 0.3.1
**Type**: Bugfix

## Overview

When `/dotclaude:start-new` is invoked with a GitHub issue URL argument, the orchestrator bypasses the init delegation chain (`init-github-issue` -> `init-{type}` -> `_init-common`) and executes work inline. This causes the worktree creation step defined in `_init-common.md` to be skipped entirely. Additionally, the Step 6 Checkpoint was overridden with an ad-hoc judgment that worktrees are unnecessary, violating the mandatory HALT condition.

### Expected Init Delegation Chain

```
start-new.md (Step 2)
  -> init-github-issue.md (Steps 1-5)
    -> init-bugfix.md (Branch Creation & Analysis Phase)
      -> _init-common.md (Branch Creation)
        -> git worktree add ../{project_name}-{type}-{keyword} -b {type}/{keyword} {base_branch}
```

### Observed Broken Behavior

```
start-new.md
  -> Directly fetched issue (gh issue view)
  -> Directly ran codebase analysis
  -> Directly created SPEC.md via TechnicalWriter
  -> Used git checkout -b instead of git worktree add
  -> Step 6 Checkpoint: worktree check skipped with justification "simple project"
```

## Root Cause Analysis

Three root causes identified across the delegation chain:

| # | File | Line(s) | Root Cause |
|---|------|---------|------------|
| 1 | `commands/start-new.md` | 79-91 | Step 2 says "follow the corresponding init command" -- the word "follow" is ambiguous and allows the orchestrator to interpret it as "do what the init command would do" rather than "delegate to the init command's steps sequentially" |
| 2 | `commands/start-new.md` | 169-192 | Step 6 Checkpoint worktree check says "If not found: HALT" but does not explicitly state this is UNCONDITIONAL, allowing agents to override with ad-hoc justifications |
| 3 | `commands/start-new.md` | 88 | No post-init verification step exists to confirm that the init chain actually executed correctly (worktree created, branch exists) |
| 4 | `commands/_init-common.md` | 11-23 | Branch Creation section uses descriptive language ("create the work branch") without MANDATORY enforcement, allowing agents to substitute `git checkout -b` for `git worktree add` |

## Constraints

Modify these files only:
- `commands/start-new.md` -- Add post-init verification step + make Step 6 Checkpoint unconditional
- `commands/_init-common.md` -- Add MUST/MANDATORY enforcement to Branch Creation section

Do NOT modify:
- `commands/init-github-issue.md` -- its routing and delegation logic is correct
- `commands/init-feature.md`, `commands/init-bugfix.md`, `commands/init-refactor.md` -- they correctly delegate to `_init-common`

## Fix Strategy

### Fix 1: Strengthen `_init-common.md` Branch Creation (Root Fix)

The Branch Creation section in `_init-common.md` (lines 11-23) uses descriptive language ("create the work branch") without enforcement. Add MUST/MANDATORY language:

- Add `**MANDATORY**` marker to the section header
- Explicitly state: "MUST use `git worktree add`. NEVER use `git checkout -b` or `git switch -c`."
- Add a verification sub-step: after `git worktree add`, verify the worktree directory exists

### Fix 2: Add Post-Init Verification to `start-new.md` (Orchestrator Verification)

After Step 2 (init-xxx delegation) completes, add a verification step BEFORE proceeding to Step 3 (SPEC Review):

1. Run `git worktree list`
2. Verify the expected worktree path `../{project_name}-{type}-{keyword}` exists
3. Verify current branch is `{type}/{keyword}` (not main/master)
4. If verification fails: retry init-xxx (max 3 attempts)
5. If all retries fail: HALT with error

This ensures the orchestrator catches any delegation failure regardless of which init-xxx was called.

### Fix 3: Make Step 6 Checkpoint UNCONDITIONAL in `start-new.md`

Add "**UNCONDITIONAL CHECK -- NO EXCEPTIONS, NO OVERRIDES**" marker to all 4 checks in Step 6. This is a safety net -- Fix 2 should catch issues earlier, but Step 6 provides defense-in-depth.

## Affected Code Locations

| # | File | Location | Change Description |
|---|------|----------|-------------------|
| 1 | `commands/_init-common.md` | Branch Creation section (lines 11-23) | Add MANDATORY marker, MUST language for `git worktree add`, prohibit `git checkout -b` |
| 2 | `commands/start-new.md` | After Step 2, before Step 3 (insert new step) | Add post-init verification with retry loop |
| 3 | `commands/start-new.md` | Step 6 Checkpoint (lines 169-192) | Add UNCONDITIONAL marker to all 4 checks |

## Functional Requirements

- [ ] FR-1: `_init-common.md` Branch Creation section MUST have MANDATORY enforcement language preventing use of `git checkout -b` as alternative to `git worktree add`
- [ ] FR-2: `start-new.md` MUST verify worktree and branch existence after init-xxx completion, BEFORE proceeding to SPEC Review (Step 3)
- [ ] FR-3: `start-new.md` MUST retry init-xxx (max 3 attempts) if post-init verification fails
- [ ] FR-4: Step 6 Checkpoint in `start-new.md` MUST be marked UNCONDITIONAL for all 4 checks -- no agent may bypass HALT conditions
- [ ] FR-5: All changes MUST NOT break existing init flows when `init-feature`, `init-bugfix`, `init-refactor` are called directly

## Non-Functional Requirements

- [ ] NFR-1: All changes are documentation/instruction changes only. No runtime code modifications.
- [ ] NFR-2: Language in modified sections MUST be unambiguous and imperative. Avoid words like "follow", "should", "can" in enforcement contexts.

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Direct init-feature/bugfix/refactor call (not via start-new) | _init-common MUST enforcement applies; worktree always created |
| 2 | Worktree already exists at target path | `git worktree add` fails; report error, do not silently fall back to `git checkout -b` |
| 3 | Post-init verification failure (worktree missing) | Retry init-xxx up to 3 times, then HALT |
| 4 | Step 6 Checkpoint with missing worktree | HALT with clear error (defense-in-depth, should be caught by Fix 2 first) |
| 5 | init-github-issue with invalid URL | Return to Step 1; no partial state left behind |

## Out of Scope

- Runtime enforcement mechanisms (hooks, validators, pre-commit checks)
- Changes to `init-feature.md`, `init-bugfix.md`, `init-refactor.md`
- Changes to `init-github-issue.md` (its routing logic is correct)
- Adding new commands or files
- Version bumps (handled at release time per CLAUDE.md guidelines)
