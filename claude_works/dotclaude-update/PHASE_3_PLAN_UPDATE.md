# Phase 3: Update Skill

## Objective

Create `/dotclaude:update` skill that updates dotclaude framework to latest (or specified) version while preserving user customizations.

## Prerequisites

- Phase 1 complete (`.dotclaude-manifest.json` exists)
- Phase 2 complete (version skill provides pattern reference)

## Deliverables

1. `.claude/skills/dotclaude/update/SKILL.md` - Update skill

## Implementation Checklist

### 1. Create Skill Directory

- [ ] Create directory: `.claude/skills/dotclaude/update/`

### 2. Implement SKILL.md

Create `.claude/skills/dotclaude/update/SKILL.md`:

```markdown
---
name: dotclaude:update
description: Update .claude directory to the latest release tag
user-invocable: true
---

# /dotclaude:update [version]

Update dotclaude framework to latest or specified version.

## Arguments

| Arg | Description | Default |
|-----|-------------|---------|
| version | Target version (e.g., v0.1.0) | Latest tag |

## Workflow

```
1. Check prerequisites
2. Determine target version
3. Fetch upstream manifest
4. Compare file lists
5. Show update preview
6. Get user confirmation
7. Create backup
8. Update files
9. Merge settings.json
10. Update local manifest
11. Cleanup or rollback
12. Report summary
```

## Execution Steps

### Step 1: Check Prerequisites

Verify requirements:
- `.dotclaude-manifest.json` exists → read current version
- `gh` CLI is available → `which gh`
- Network access → `gh api repos/U-lis/dotclaude/tags --jq '.[0].name'`

If any fail, report error and stop.

### Step 2: Determine Target Version

**If version argument provided:**
- Validate format (vX.Y.Z or X.Y.Z)
- Verify tag exists: `gh api repos/U-lis/dotclaude/tags --jq '.[].name' | grep -q {version}`

**If no argument:**
- Fetch latest: `gh api repos/U-lis/dotclaude/tags --jq '.[0].name'`

Compare with current:
- If same version → "Already up to date"
- If target is older → "Downgrade not supported"
- If target is newer → proceed

### Step 3: Fetch Upstream Manifest

Download manifest from target version:
```bash
gh api repos/U-lis/dotclaude/contents/.dotclaude-manifest.json?ref={tag} --jq '.content' | base64 -d
```

Parse JSON to extract:
- `version`: target version string
- `managed_files`: array of file paths
- `merge_files`: array of files to merge (not replace)

### Step 4: Compare File Lists

Compute diff between local and upstream manifest:

| Category | Condition | Action |
|----------|-----------|--------|
| Add | In upstream, not in local | Add new file |
| Update | In both | Overwrite with upstream |
| Remove | In local, not in upstream | Ask user before delete |
| Merge | In `merge_files` | Smart merge |

### Step 5: Show Update Preview

Display to user:

```
# dotclaude Update Preview

Current: 0.0.9
Target:  0.1.0

## Changes

### Files to Add (3)
- .claude/agents/new-agent.md
- .claude/skills/new-skill/SKILL.md
- .claude/hooks/new-hook.sh

### Files to Update (15)
- .claude/agents/orchestrator.md
- .claude/skills/start-new/SKILL.md
- ... (list all)

### Files to Remove (1)
- .claude/skills/old-skill/SKILL.md

### Files to Merge (1)
- .claude/settings.json (new keys will be added)

---
Proceed with update? [y/N]
```

### Step 6: Get User Confirmation

Use AskUserQuestion tool:
- Options: "Yes, update", "No, cancel"
- If cancel → report "Update cancelled" and stop

### Step 7: Create Backup

```bash
# Backup manifest
cp .dotclaude-manifest.json .dotclaude-manifest.json.backup

# Create backup directory
mkdir -p .dotclaude-backup-{timestamp}

# Backup each file that will be modified
for file in {files_to_update}; do
  cp $file .dotclaude-backup-{timestamp}/$file
done
```

### Step 8: Update Files

For each file in update plan:

**Add files:**
```bash
# Create directory if needed
mkdir -p $(dirname {file_path})

# Download and write file
gh api repos/U-lis/dotclaude/contents/{file_path}?ref={tag} --jq '.content' | base64 -d > {file_path}
```

**Update files:**
```bash
gh api repos/U-lis/dotclaude/contents/{file_path}?ref={tag} --jq '.content' | base64 -d > {file_path}
```

**Remove files (if user confirmed):**
```bash
rm {file_path}
# Remove empty parent directories
rmdir --ignore-fail-on-non-empty $(dirname {file_path})
```

If any operation fails → go to Step 11 (rollback)

### Step 9: Merge settings.json

For files in `merge_files`:

```bash
# Download upstream settings
gh api repos/U-lis/dotclaude/contents/.claude/settings.json?ref={tag} --jq '.content' | base64 -d > /tmp/upstream-settings.json

# Merge: add new keys, preserve existing values
jq -s '.[0] * .[1]' /tmp/upstream-settings.json .claude/settings.json > .claude/settings.json.tmp
mv .claude/settings.json.tmp .claude/settings.json
```

Note: `jq -s '.[0] * .[1]'` merges with second object taking precedence for existing keys.

Actually, we want the reverse (preserve local values):
```bash
jq -s '.[0] * .[1]' .claude/settings.json /tmp/upstream-settings.json > /tmp/merged.json
# Wait, this still overwrites...

# Correct approach: only add keys that don't exist
jq -s '.[1] as $upstream | .[0] | . + ($upstream | with_entries(select(.key as $k | $k | IN(.[0] | keys[]) | not)))' .claude/settings.json /tmp/upstream-settings.json
```

Simplified approach without complex jq:
1. Read both JSON files
2. For each key in upstream: if not in local, add it
3. Write result

### Step 10: Update Local Manifest

Write new manifest with:
- `version`: target version
- `managed_files`: from upstream manifest
- `merge_files`: from upstream manifest

### Step 11: Cleanup or Rollback

**On success:**
```bash
rm .dotclaude-manifest.json.backup
rm -rf .dotclaude-backup-{timestamp}
```

**On failure:**
```bash
# Restore manifest
mv .dotclaude-manifest.json.backup .dotclaude-manifest.json

# Restore modified files
cp -r .dotclaude-backup-{timestamp}/* .

# Cleanup
rm -rf .dotclaude-backup-{timestamp}

# Report failure
echo "Update failed. Restored from backup."
```

### Step 12: Report Summary

```
# dotclaude Update Complete

Version: 0.0.9 → 0.1.0

## Summary
- Files added: 3
- Files updated: 15
- Files removed: 1
- Settings merged: Yes

## Next Steps
- Review changes: git diff
- Commit if satisfied: git add -A && git commit -m "chore: update dotclaude to v0.1.0"
```

## Error Handling

| Error | Handling |
|-------|----------|
| Manifest not found | "dotclaude not installed. Copy .claude directory from U-lis/dotclaude first." |
| Network failure | "Cannot reach GitHub. Check network and try again." |
| Tag not found | "Version {tag} not found. Available: {list recent tags}" |
| File download failed | Rollback and report specific file |
| JSON parse error | Skip settings merge, warn user |
| Permission denied | Report, suggest checking file permissions |

## Safety Rules

- NEVER delete user files (not in manifest)
- ALWAYS backup before modifying
- ALWAYS rollback on failure
- REQUIRE user confirmation before any changes
- NO auto-commit (user controls git)

## Output

Summary of update actions. No auto-commit.
```

### 3. Update Manifest

- [ ] Update `.dotclaude-manifest.json` to include new skill file

### 4. Validation

- [ ] Skill file has valid YAML frontmatter
- [ ] Workflow covers all SPEC requirements
- [ ] Error handling is comprehensive
- [ ] Rollback mechanism is clearly documented

## File Structure After Phase 3

```
.
├── .dotclaude-manifest.json    # Updated with new file
└── .claude/
    └── skills/
        └── dotclaude/
            ├── version/
            │   └── SKILL.md
            └── update/         # NEW directory
                └── SKILL.md    # NEW file
```

## Notes

- This is the most complex skill in the implementation
- Rollback capability is critical for safety
- settings.json merge needs careful handling
- User confirmation at Step 6 is mandatory (SPEC FR-6)

## Completion Criteria

- [ ] `.claude/skills/dotclaude/update/SKILL.md` exists
- [ ] File has valid YAML frontmatter with name and description
- [ ] All 12 workflow steps are documented
- [ ] Rollback mechanism is fully specified
- [ ] settings.json merge strategy is clear
- [ ] Error handling covers all edge cases
- [ ] Safety rules are explicitly stated
- [ ] `.dotclaude-manifest.json` updated with new file
