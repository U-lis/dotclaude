<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Update Dev Flow - Specification

**Target Version**: 0.3.0
**Source Issue**: https://github.com/U-lis/dotclaude/issues/20

## Overview

**Purpose**: Restructure the development workflow's merge and PR creation steps to give users explicit control over how completed work is integrated into the base branch.

**Problem**: The current workflow couples merge behavior into the scope selection (Step 5) via the "Design -> Code -> Docs -> Merge" option. The `/merge-main` command asks whether to create a PR or merge directly, adding unnecessary friction. There is no dedicated PR creation command.

**Solution**: Decouple merge/PR behavior from scope selection. Rename and simplify `/merge-main` to `/merge` (direct merge only). Add a post-completion question asking users to choose between direct merge and PR creation. Create a new `/pr` command for GitHub PR creation.

---

## Functional Requirements

### Core Features

- [ ] FR-1: Rename `/dotclaude:merge-main` command to `/dotclaude:merge`
  - Rename file `commands/merge-main.md` to `commands/merge.md`
  - Update frontmatter description accordingly
  - Update all internal references to the old command name

- [ ] FR-2: `/merge` directly merges current branch to `base_branch` (from config, default "main") without asking PR vs merge
  - Remove the "PR Option" section from the merge command
  - Read `base_branch` from SPEC.md metadata or fall back to config file, then to default "main"
  - Workflow: save branch name -> checkout base_branch -> pull -> merge -> cleanup

- [ ] FR-3: `/merge` analyzes conflicts and recommends strategy on conflict, waits for user confirmation before resolving
  - When merge conflict occurs: list conflicted files, analyze conflict content, recommend merge direction/strategy
  - Do NOT auto-resolve; present recommendation and wait for explicit user confirmation
  - After user confirms: apply resolution strategy, then continue merge workflow

- [ ] FR-4: Remove "Design -> Code -> Docs -> Merge" from Step 5 scope selection in `start-new.md`
  - Remove the 4th option from AskUserQuestion call in Step 5
  - Remaining options: "Design", "Design -> Code", "Design -> Code -> Docs"

- [ ] FR-5: Add post-completion question after code or docs phase completes
  - When the last step of the selected scope finishes (Step 10 for code, Step 11 for docs), ask user via AskUserQuestion:
    - question: "How would you like to integrate this work?"
    - options: "Direct Merge" (invoke /merge behavior), "Create PR" (invoke /pr behavior, see Issue #9)
  - This question is asked ONLY when scope includes code or docs (not design-only)
  - Note: `/dotclaude:pr` command implementation is handled by Issue #9 (out of scope for this work)

---

## Non-Functional Requirements

### Consistency

- [ ] NFR-1: Follow existing command file structure and frontmatter format
  - New `pr.md` and modified `merge.md` must use the same frontmatter pattern as other commands in `commands/`

### Backward Compatibility

- [ ] NFR-2: Maintain backward compatibility with existing workflow steps 1-10
  - Steps 1-10 of the 13-step workflow must continue to function unchanged
  - Only Steps 5 (scope selection), 11 (docs), and 12 (merge) are modified

### User Interaction

- [ ] NFR-3: Use AskUserQuestion tool for the merge/PR choice (not text tables)
  - Consistent with the existing UX pattern in the workflow

---

## Constraints

### Technical Constraints

- Must use `gh` CLI for PR creation (GitHub CLI)
- Must read `base_branch` from config chain: SPEC.md metadata -> `.claude/dotclaude-config.json` -> default "main"
- Command files are written in English (content language)
- Language config `ko_KR` applies to user-facing workflow interactions, not command file content

### Project Constraints

- Working directory: `claude_works`
- All changes scoped to `commands/` directory (merge-main.md rename, start-new.md modification)

---

## Out of Scope

The following are explicitly NOT part of this work:

- `/dotclaude:pr` command implementation (handled by Issue #9: https://github.com/U-lis/dotclaude/issues/9)
- PR review/approval workflow (no auto-review or approval automation)
- CI/CD integration (no pipeline triggers or status checks)
- PR template customization (no `.github/PULL_REQUEST_TEMPLATE.md` changes)
- Auto-closing issues via PR (no "Closes #N" automation)
- Changes to Steps 1-4 (init phase) or Steps 6-9 (design/code execution)
- Tagging or release workflow changes

---

## Assumptions

- `gh` CLI is installed and authenticated in the user's environment
- The repository has a configured remote named `origin`
- SPEC.md metadata block is present and parseable when `/merge` or `/pr` is invoked post-workflow
- The user has push access to the remote repository

---

## Impact Analysis

### Files to Modify

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/merge-main.md` | Rename + Modify | Rename to `commands/merge.md`, remove PR option, add conflict analysis |
| `commands/start-new.md` | Modify | Remove 4th scope option (Step 5), replace Step 12 with post-completion question, update routing table |
| `commands/pr.md` | Out of Scope | Handled by Issue #9 |

### Affected Sections in start-new.md

| Section | Line Range | Change |
|---------|------------|--------|
| Step 5: Scope Selection | ~151-161 | Remove "Design -> Code -> Docs -> Merge" option |
| Routing table | ~714-720 | Remove "Design -> Code -> Docs -> Merge" row, add post-completion logic |
| Step 12: Merge to Main | ~281-287 | Replace with post-completion question flow |
| Output Contract | ~846-880 | Update `merge` section to reflect optional merge/PR |

---

## Open Questions

- FR-5 references `/dotclaude:pr` which is implemented in Issue #9. If Issue #9 is not yet merged, the "Create PR" option in the post-completion question will reference a command that doesn't exist yet.

---

## References

- Source Issue: https://github.com/U-lis/dotclaude/issues/20
- Current merge command: `commands/merge-main.md`
- Orchestrator: `commands/start-new.md`
- Config file: `.claude/dotclaude-config.json`
