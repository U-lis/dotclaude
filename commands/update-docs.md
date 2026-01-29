---
description: Update project documentation (README, CHANGELOG) after code implementation is complete.
---

# /dc:update-docs

Update project documentation (README, CHANGELOG) after code implementation is complete.

## Configuration Loading

Before executing any operations, load the working directory from configuration:

1. **Default**: `working_directory = ".dc_workspace"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved `{working_directory}` value is used for all document and file paths in this skill.

## Trigger

- User invokes `/dc:update-docs` directly
- Orchestrator calls after all phases complete (Step 11)

## Prerequisites

- All implementation phases complete
- Code validated by code-validator

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Context                                       │
│    - Get latest tag: git describe --tags --abbrev=0    │
│    - Get commits since tag: git log {tag}..HEAD        │
│    - Read {working_directory}/{subject}/SPEC.md for context   │
├─────────────────────────────────────────────────────────┤
│ 2. Call TechnicalWriter (DOCS_UPDATE role)             │
│    - Input: commits, SPEC summary, target version      │
│    - Task: Update CHANGELOG.md and README.md           │
├─────────────────────────────────────────────────────────┤
│ 3. Commit Documentation                                 │
│    - git add CHANGELOG.md README.md                    │
│    - git commit -m "docs: update for vX.Y.Z"           │
├─────────────────────────────────────────────────────────┤
│ 4. Report Summary                                       │
│    - List updated files                                 │
│    - Show CHANGELOG entry preview                       │
└─────────────────────────────────────────────────────────┘
```

## TechnicalWriter Invocation

```
Task tool:
  subagent_type: "dotclaude:technical-writer"
  prompt: |
    You are in DOCS_UPDATE role.

    ## Task: Update Project Documentation

    ### Input
    - Latest tag: {tag}
    - Commits since tag:
      {commit_list}
    - SPEC summary: {spec_summary}
    - Target version: {target_version}

    ### CHANGELOG.md Update

    1. Review commits and filter meaningful changes (exclude merge, typo, wip)
    2. Classify by type following Keep a Changelog format:
       - Added: new features
       - Changed: changes in existing functionality
       - Deprecated: soon-to-be removed features
       - Removed: removed features
       - Fixed: bug fixes
       - Security: vulnerability fixes
    3. Add new version entry at the top of file (after header)
    4. Format:
       ## [X.Y.Z] - YYYY-MM-DD

       ### Added
       - Item 1
       - Item 2

       ### Changed
       - Item 1

    ### README.md Update

    Review if any of the following need updates:
    - Feature list
    - Usage examples
    - Configuration options
    - Workflow diagrams

    Only update if the implementation introduced visible changes.

    ### Output
    - Write updated CHANGELOG.md
    - Write updated README.md (if needed)
```

## CHANGELOG Rules

- Version follows semver (X.Y.Z)
- Each version is individual entry (no grouping)
- Date format: YYYY-MM-DD
- Content in English
- Latest version at top of file

## Output

```
# Documentation Updated

## CHANGELOG.md
- Added version: X.Y.Z
- Sections: Added (3), Changed (2), Fixed (1)

## README.md
- Updated: [Yes/No]
- Changes: [list if updated]

## Commit
- Hash: {commit_hash}
- Message: docs: update for vX.Y.Z
```

## Invocation Behavior

| Context | Behavior |
|---------|----------|
| Direct (`/dc:update-docs`) | Complete docs update, return control to user |
| Via orchestrator | Complete docs update, return to orchestrator for continued workflow |
