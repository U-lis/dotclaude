---
name: dotclaude:update
description: Update .claude directory to the latest release tag from U-lis/dotclaude
user-invocable: true
---

# /dotclaude:update [version]

Update dotclaude framework to latest or specified version while preserving user customizations.

## Arguments

| Arg | Description | Default |
|-----|-------------|---------|
| version | Target version (e.g., v0.1.0) | Latest tag |

## Workflow Overview

```
1. Check prerequisites
2. Determine target version
3. Clone upstream repository (shallow)
4. Compare file lists
5. Show update preview (with changelog)
6. Get user confirmation (AskUserQuestion)
7. Create backup
8. Update files
9. Merge settings.json
10. Update local manifest
11. Cleanup or rollback
12. Report summary
```

## Execution Steps

### Step 1: Check Prerequisites

Verify requirements before proceeding:

```bash
# Check manifest exists
[ -f .dotclaude-manifest.json ] || echo "ERROR: Manifest not found"

# Check git CLI
which git || echo "ERROR: git not installed"

# Check network (test GitHub access)
git ls-remote https://github.com/U-lis/dotclaude.git HEAD || echo "ERROR: Cannot reach GitHub"
```

If any check fails, report error and stop.

### Step 2: Determine Target Version

**If version argument provided:**
```bash
# Validate tag exists
git ls-remote --tags https://github.com/U-lis/dotclaude.git | grep -q "refs/tags/v{version}"
```

**If no argument:**
```bash
# Get latest tag
LATEST=$(git ls-remote --tags --sort=-v:refname https://github.com/U-lis/dotclaude.git | head -1 | sed 's/.*refs\/tags\/v//')
```

**Compare with current:**
```bash
CURRENT=$(jq -r '.version' .dotclaude-manifest.json)
```

- If same version → "Already up to date" and stop
- If target is older → "Downgrade not supported" and stop
- If target is newer → proceed

### Step 3: Clone Upstream Repository

Shallow clone the target version:

```bash
UPSTREAM_DIR="/tmp/dotclaude-upstream-$$"
git clone --depth 1 --branch "v{target_version}" \
  https://github.com/U-lis/dotclaude.git "$UPSTREAM_DIR"
```

All upstream files are now available at `$UPSTREAM_DIR/`.

### Step 4: Compare File Lists

Read manifests and compute diff:

```bash
# Read upstream manifest
UPSTREAM_MANIFEST="$UPSTREAM_DIR/.dotclaude-manifest.json"

# Read local manifest
LOCAL_MANIFEST=".dotclaude-manifest.json"
```

Compute diff between local and upstream manifest:

| Category | Condition | Action |
|----------|-----------|--------|
| **Add** | In upstream, not in local | Add new file |
| **Update** | In both manifests | Overwrite with upstream |
| **Remove** | In local, not in upstream | Ask user before delete |
| **Merge** | In `merge_files` | Smart merge (add keys only) |

### Step 5: Show Update Preview

**Extract changelog for target version:**

Read `$UPSTREAM_DIR/CHANGELOG.md` and extract the section for target version:
- Find line starting with `## [{target_version}]` or `## [v{target_version}]`
- Collect all lines until next `## [` header or end of file

**Display preview to user:**

```markdown
## dotclaude Update Preview

| | Version |
|--|---------|
| Current | {current} |
| Target | {target} |

### What's New in {target}

{extracted changelog section - Added, Changed, Fixed, etc.}

---

### Files to Add ({count})
- .claude/agents/new-agent.md
- .claude/skills/new-skill/SKILL.md

### Files to Update ({count})
- .claude/agents/orchestrator.md
- .claude/skills/start-new/SKILL.md
- ...

### Files to Remove ({count})
- .claude/skills/old-skill/SKILL.md

### Files to Merge ({count})
- .claude/settings.json (new keys will be added, existing preserved)
```

**If changelog parse fails:** Continue without changelog (show file list only, warn user).

### Step 6: Get User Confirmation

Use AskUserQuestion tool:
- question: "Proceed with dotclaude update?"
- options:
  - "Yes, update" → proceed
  - "No, cancel" → report "Update cancelled" and stop

**This step is MANDATORY. Never skip user confirmation.**

### Step 7: Create Backup

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=".dotclaude-backup-${TIMESTAMP}"

# Backup manifest
cp .dotclaude-manifest.json .dotclaude-manifest.json.backup

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Backup files that will be modified
for file in {files_to_update}; do
  mkdir -p "${BACKUP_DIR}/$(dirname $file)"
  cp "$file" "${BACKUP_DIR}/$file"
done
```

### Step 8: Update Files

**Add files:**
```bash
mkdir -p $(dirname {file_path})
cp "$UPSTREAM_DIR/{file_path}" "{file_path}"
```

**Update files:**
```bash
cp "$UPSTREAM_DIR/{file_path}" "{file_path}"
```

**Remove files (only if user confirmed in Step 6):**
```bash
rm {file_path}
rmdir --ignore-fail-on-non-empty $(dirname {file_path})
```

If any operation fails → go to Step 11 (rollback)

### Step 9: Merge settings.json

For files in `merge_files` (additive-only merge):

```bash
# Merge: add new keys from upstream, preserve all local values
# Local values always take precedence
jq -s '.[0] as $upstream | .[1] as $local |
  $upstream * $local' \
  "$UPSTREAM_DIR/.claude/settings.json" .claude/settings.json > /tmp/merged-settings.json

mv /tmp/merged-settings.json .claude/settings.json
```

**Merge logic:**
1. Start with upstream settings as base
2. Overlay local settings (local values win on conflicts)
3. Result: new upstream keys added, all local keys preserved

### Step 10: Update Local Manifest

Replace local manifest with upstream:

```bash
cp "$UPSTREAM_DIR/.dotclaude-manifest.json" .dotclaude-manifest.json
```

### Step 11: Cleanup or Rollback

**On success:**
```bash
rm -f .dotclaude-manifest.json.backup
rm -rf "${BACKUP_DIR}"
rm -rf "$UPSTREAM_DIR"
```

**On failure:**
```bash
# Restore manifest
mv .dotclaude-manifest.json.backup .dotclaude-manifest.json

# Restore modified files
cp -r "${BACKUP_DIR}/"* .

# Cleanup
rm -rf "${BACKUP_DIR}"
rm -rf "$UPSTREAM_DIR"

# Report
echo "Update failed. Restored from backup."
```

### Step 12: Report Summary

```markdown
## dotclaude Update Complete

| | Version |
|--|---------|
| Previous | {old_version} |
| Current | {new_version} |

### Summary
- Files added: {count}
- Files updated: {count}
- Files removed: {count}
- Settings merged: Yes/No

### Next Steps
1. Review changes: `git diff`
2. Commit if satisfied: `git add -A && git commit -m "chore: update dotclaude to {version}"`
```

## Error Handling

| Error | Message |
|-------|---------|
| Manifest not found | "dotclaude not installed. Copy .claude from U-lis/dotclaude first." |
| Network failure | "Cannot reach GitHub. Check network and try again." |
| Clone failed | "Failed to clone repository. Check network and permissions." |
| Tag not found | "Version {tag} not found. Run `/dotclaude:version` to see latest." |
| File copy failed | Rollback and report specific file that failed |
| JSON parse error | Skip settings merge, warn user to merge manually |
| Permission denied | Report file path, suggest checking permissions |

## Safety Rules

- **NEVER** delete user files (files not in manifest)
- **ALWAYS** backup before modifying any file
- **ALWAYS** rollback completely on any failure
- **ALWAYS** cleanup temporary clone directory
- **REQUIRE** user confirmation before making changes (Step 6)
- **NO** auto-commit - user controls their git workflow
- **PRESERVE** all local values during settings.json merge

## Output

Summary of update actions. User must manually commit changes if satisfied.
