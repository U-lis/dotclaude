# Command Naming - Global Documentation

## Feature Overview

**Purpose**: Remove `dc:` prefix from command filenames to fix duplicate prefix issue

**Problem**: Commands appear as `/dotclaude:dc:start-new` instead of `/dotclaude:start-new`

**Solution**: Rename command files from `dc:*.md` to `*.md`

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Rename command files | Pending | None |

## File Changes

### Renames (Phase 1)

| Before | After |
|--------|-------|
| `commands/dc:start-new.md` | `commands/start-new.md` |
| `commands/dc:design.md` | `commands/design.md` |
| `commands/dc:code.md` | `commands/code.md` |
| `commands/dc:merge-main.md` | `commands/merge-main.md` |
| `commands/dc:tagging.md` | `commands/tagging.md` |
| `commands/dc:update-docs.md` | `commands/update-docs.md` |
| `commands/dc:validate-spec.md` | `commands/validate-spec.md` |

## Verification

1. Reinstall plugin
2. Type `/dotclaude:` - should show 7 commands without `dc:` prefix
3. Test `/dotclaude:start-new` execution
