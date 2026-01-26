# Phase 1: Directory Migration

## Objective

Move all plugin resource directories from `.claude/` prefix to root level using `git mv` to preserve git history.

## Prerequisites

- Clean working tree (no uncommitted changes)
- On feature branch (not main/master)

## Files Affected

### Directories to Move

| Source | Destination | Files Count |
|--------|-------------|-------------|
| `.claude/skills/` | `skills/` | 11 files |
| `.claude/agents/` | `agents/` | 10 files |
| `.claude/templates/` | `templates/` | 5 files |

### Individual Files to Move

| Source | Destination |
|--------|-------------|
| `.claude/hooks/check-update.sh` | `hooks/check-update.sh` |
| `.claude/hooks/check-validation-complete.sh` | `hooks/check-validation-complete.sh` |

Note: `hooks/hooks.json` already exists at destination; only shell scripts need moving.

## Instructions

### Step 1: Verify Clean State

```bash
git status
# Ensure working tree is clean
```

### Step 2: Move Skills Directory

```bash
git mv .claude/skills skills
```

Expected result: Entire `.claude/skills/` directory moved to `skills/` with all subdirectories preserved.

### Step 3: Move Agents Directory

```bash
git mv .claude/agents agents
```

Expected result: Entire `.claude/agents/` directory moved to `agents/` with `coders/` subdirectory preserved.

### Step 4: Move Templates Directory

```bash
git mv .claude/templates templates
```

Expected result: Entire `.claude/templates/` directory moved to `templates/`.

### Step 5: Move Hook Scripts

```bash
git mv .claude/hooks/check-update.sh hooks/check-update.sh
git mv .claude/hooks/check-validation-complete.sh hooks/check-validation-complete.sh
```

Expected result: Both shell scripts moved to `hooks/` directory alongside existing `hooks.json`.

### Step 6: Verify Moves

```bash
# Verify new locations exist
ls -la skills/
ls -la agents/
ls -la templates/
ls -la hooks/

# Verify old locations empty (except .claude/settings.json and .claude/settings.local.json)
ls -la .claude/
```

## Specific Changes

### Before

```
.claude/
├── skills/
│   ├── code/SKILL.md
│   ├── design/SKILL.md
│   ├── merge-main/SKILL.md
│   ├── start-new/
│   │   ├── SKILL.md
│   │   ├── _analysis.md
│   │   ├── init-bugfix.md
│   │   ├── init-feature.md
│   │   ├── init-refactor.md
│   │   └── init-github-issue.md
│   ├── tagging/SKILL.md
│   ├── update-docs/SKILL.md
│   └── validate-spec/SKILL.md
├── agents/
│   ├── code-validator.md
│   ├── designer.md
│   ├── spec-validator.md
│   ├── technical-writer.md
│   └── coders/
│       ├── _base.md
│       ├── javascript.md
│       ├── python.md
│       ├── rust.md
│       ├── sql.md
│       └── svelte.md
├── templates/
│   ├── GLOBAL.md
│   ├── PHASE_MERGE.md
│   ├── PHASE_PLAN.md
│   ├── PHASE_TEST.md
│   └── SPEC.md
├── hooks/
│   ├── check-update.sh
│   └── check-validation-complete.sh
├── settings.json
└── settings.local.json
```

### After

```
.claude/
├── settings.json
└── settings.local.json

skills/
├── code/SKILL.md
├── design/SKILL.md
├── merge-main/SKILL.md
├── start-new/
│   ├── SKILL.md
│   ├── _analysis.md
│   ├── init-bugfix.md
│   ├── init-feature.md
│   ├── init-refactor.md
│   └── init-github-issue.md
├── tagging/SKILL.md
├── update-docs/SKILL.md
└── validate-spec/SKILL.md

agents/
├── code-validator.md
├── designer.md
├── spec-validator.md
├── technical-writer.md
└── coders/
    ├── _base.md
    ├── javascript.md
    ├── python.md
    ├── rust.md
    ├── sql.md
    └── svelte.md

templates/
├── GLOBAL.md
├── PHASE_MERGE.md
├── PHASE_PLAN.md
├── PHASE_TEST.md
└── SPEC.md

hooks/
├── hooks.json
├── check-update.sh
└── check-validation-complete.sh
```

## Completion Checklist

- [ ] Clean working tree before starting
- [ ] `.claude/skills/` moved to `skills/`
- [ ] `.claude/agents/` moved to `agents/`
- [ ] `.claude/templates/` moved to `templates/`
- [ ] `.claude/hooks/check-update.sh` moved to `hooks/check-update.sh`
- [ ] `.claude/hooks/check-validation-complete.sh` moved to `hooks/check-validation-complete.sh`
- [ ] All moves staged with `git mv`
- [ ] `.claude/` directory contains only `settings.json` and `settings.local.json`
- [ ] No files lost during migration

## Validation Criteria

1. **File Count Verification**:
   - `skills/`: 11 files (across subdirectories)
   - `agents/`: 10 files (including `coders/` subdirectory)
   - `templates/`: 5 files
   - `hooks/`: 3 files (2 .sh + 1 .json)

2. **Git Status Check**:
   - All moves show as "renamed" in `git status`
   - No untracked files in old locations
   - No deleted files (moves, not deletes)

3. **Directory Structure**:
   - `.claude/hooks/` directory should be empty and can be removed
   - `.claude/` should only contain settings files

## Notes

- Do NOT commit at this phase; wait until all phases complete
- Hook scripts must remain executable after move
- The `.claude/hooks/` directory will be cleaned up in Phase 4
