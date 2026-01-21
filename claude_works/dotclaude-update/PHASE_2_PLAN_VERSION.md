# Phase 2: Version Skill

## Objective

Create `/dotclaude:version` skill that displays current installed version and latest available version from upstream.

## Prerequisites

- Phase 1 complete (`.dotclaude-manifest.json` exists)

## Deliverables

1. `.claude/skills/dotclaude/version/SKILL.md` - Version checking skill

## Implementation Checklist

### 1. Create Skill Directory

- [ ] Create directory: `.claude/skills/dotclaude/`
- [ ] Create directory: `.claude/skills/dotclaude/version/`

### 2. Implement SKILL.md

Create `.claude/skills/dotclaude/version/SKILL.md`:

```markdown
---
name: dotclaude:version
description: Display current installed version and latest available version
user-invocable: true
---

# /dotclaude:version

Display dotclaude framework version information.

## Workflow

1. Read local manifest
2. Fetch latest tag from upstream
3. Compare versions
4. Display result

## Execution Steps

### Step 1: Read Local Version

Read `.dotclaude-manifest.json` from repository root:
- Extract `version` field
- If file not found → report "dotclaude manifest not found"

### Step 2: Fetch Latest Upstream Version

```bash
gh api repos/U-lis/dotclaude/tags --jq '.[0].name'
```

- Returns tag name (e.g., "v0.1.0")
- Strip "v" prefix for comparison
- Handle network errors gracefully

### Step 3: Compare Versions

Compare semver: current vs latest
- Parse X.Y.Z from both
- Determine if update available

### Step 4: Display Result

Format output:

**If up to date:**
```
# dotclaude Version

Installed: 0.1.0
Latest:    0.1.0

Status: Up to date
```

**If update available:**
```
# dotclaude Version

Installed: 0.0.9
Latest:    0.1.0

Status: Update available

Run /dotclaude:update to upgrade
```

**If ahead of upstream (development):**
```
# dotclaude Version

Installed: 0.2.0
Latest:    0.1.0

Status: Development version (ahead of upstream)
```

## Error Handling

| Error | Message |
|-------|---------|
| Manifest not found | "dotclaude manifest not found. Run in a dotclaude-enabled repository." |
| Network failure | "Cannot reach GitHub. Check network connection." |
| gh not authenticated | "GitHub CLI not authenticated. Run: gh auth login" |

## Output

Version information displayed to user. No files modified.
```

### 3. Add Manifest Entry

- [ ] Update `.dotclaude-manifest.json` to include new skill file

### 4. Validation

- [ ] Skill file has valid YAML frontmatter
- [ ] Skill follows existing SKILL.md patterns
- [ ] Workflow steps are clear and actionable

## File Structure After Phase 2

```
.
├── .dotclaude-manifest.json    # Updated with new file
└── .claude/
    └── skills/
        └── dotclaude/          # NEW directory
            └── version/        # NEW directory
                └── SKILL.md    # NEW file
```

## Notes

- Version comparison must handle semver correctly
- Network errors should not crash the skill
- Output format should be clean and readable
- No confirmation needed (read-only operation)

## Completion Criteria

- [ ] `.claude/skills/dotclaude/version/SKILL.md` exists
- [ ] File has valid YAML frontmatter with name and description
- [ ] Workflow clearly documents version checking process
- [ ] Error handling covers network and file system failures
- [ ] `.dotclaude-manifest.json` updated with new file
