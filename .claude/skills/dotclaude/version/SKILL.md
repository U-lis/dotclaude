---
name: dotclaude:version
description: Display current installed version and latest available version of dotclaude framework
user-invocable: true
---

# /dotclaude:version

Display dotclaude framework version information.

## Workflow

1. Read local manifest for installed version
2. Fetch latest tag from U-lis/dotclaude
3. Compare versions
4. Display result

## Execution Steps

### Step 1: Read Local Version

Read `.dotclaude-manifest.json` from repository root.

```bash
cat .dotclaude-manifest.json | jq -r '.version'
```

- Extract `version` field
- If file not found → report "dotclaude manifest not found"

### Step 2: Fetch Latest Upstream Version

```bash
gh api repos/U-lis/dotclaude/tags --jq '.[0].name' | sed 's/^v//'
```

- Returns latest tag name, strips "v" prefix
- Handle network errors gracefully

### Step 3: Compare and Display

Compare installed vs latest version and display result.

**If up to date:**
```
## dotclaude Version

| | Version |
|--|---------|
| Installed | 0.1.0 |
| Latest | 0.1.0 |

**Status**: Up to date
```

**If update available:**
```
## dotclaude Version

| | Version |
|--|---------|
| Installed | 0.0.9 |
| Latest | 0.1.0 |

**Status**: Update available

Run `/dotclaude:update` to upgrade.
```

**If ahead of upstream (development):**
```
## dotclaude Version

| | Version |
|--|---------|
| Installed | 0.2.0 |
| Latest | 0.1.0 |

**Status**: Development version (ahead of upstream)
```

## Error Handling

| Error | Message |
|-------|---------|
| Manifest not found | "dotclaude manifest not found. Run in a dotclaude-enabled repository." |
| Network failure | "Cannot reach GitHub. Check network connection." |
| gh not authenticated | "GitHub CLI not authenticated. Run: `gh auth login`" |

## Output

Version information displayed to user. No files modified.
