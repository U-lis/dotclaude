# dotclaude Auto-Update Feature - Design Document

## Overview

Implementation of `/dotclaude:version` and `/dotclaude:update` skills for managing dotclaude framework updates from U-lis/dotclaude repository.

## Architecture Decisions

### 1. Skill Namespace Pattern

**Decision**: Use `dotclaude` namespace with colon syntax for skills.

```
.claude/skills/dotclaude/
├── version/
│   └── SKILL.md       # /dotclaude:version
└── update/
    └── SKILL.md       # /dotclaude:update
```

**Rationale**:
- Groups related dotclaude management skills together
- Follows existing skill structure (one SKILL.md per skill directory)
- Colon syntax matches Claude Code's skill namespacing convention

### 2. Manifest Location

**Decision**: Store manifest at `.dotclaude-manifest.json` in repository root.

**Rationale**:
- Visible at repo root for easy inspection
- Prefixed with dot to indicate system file
- Separate from `.claude/` to avoid self-referential updates

### 3. Version Tracking

**Decision**: Use manifest file for version tracking, not CHANGELOG.md.

**Format**:
```json
{
  "version": "0.0.9",
  "managed_files": [
    ".claude/agents/orchestrator.md",
    ".claude/skills/start-new/SKILL.md",
    ...
  ]
}
```

**Rationale**:
- Single source of truth for installed version
- CHANGELOG.md may have user modifications
- Enables file-level tracking for smart updates

### 4. GitHub Data Access Pattern

**Decision**: Use `gh api` for fetching release/tag data, `gh release download` for file content.

**Commands**:
```bash
# Get latest tag
gh api repos/U-lis/dotclaude/tags --jq '.[0].name'

# Get manifest from specific tag
gh api repos/U-lis/dotclaude/contents/.dotclaude-manifest.json?ref=v0.1.0 --jq '.content' | base64 -d

# Download file from release
gh api repos/U-lis/dotclaude/contents/{path}?ref={tag} --jq '.content' | base64 -d
```

**Rationale**:
- `gh` CLI is already available in Claude Code environment
- Direct API access avoids clone/checkout overhead
- Base64 decoding handles binary-safe content transfer

### 5. settings.json Merge Strategy

**Decision**: Additive-only merge using `jq` for JSON manipulation.

**Algorithm**:
```
1. Read upstream settings.json
2. Read local settings.json
3. For each top-level key in upstream:
   - If key not in local → add to local
   - If key exists in local → skip (preserve user value)
4. Write merged result
```

**Rationale**:
- `jq` is commonly available and handles JSON robustly
- Additive-only prevents user customization loss
- Top-level key comparison is sufficient for settings structure

### 6. Rollback Mechanism

**Decision**: Backup manifest and modified files before update, restore on failure.

**Pattern**:
```
1. Copy .dotclaude-manifest.json → .dotclaude-manifest.json.backup
2. Create temp directory for file backups
3. Before updating each file, copy to backup
4. On failure: restore from backup, delete temp
5. On success: delete backup
```

**Rationale**:
- Minimal disk overhead (only backing up changed files)
- Atomic rollback capability
- No external dependencies

## Phase Structure

| Phase | Focus | Files Modified |
|-------|-------|----------------|
| 1 | Manifest Generation | `.dotclaude-manifest.json`, build script |
| 2 | Version Skill | `.claude/skills/dotclaude/version/SKILL.md` |
| 3 | Update Skill | `.claude/skills/dotclaude/update/SKILL.md` |

## Phase Dependencies

```
Phase 1 (Manifest) ──┬──→ Phase 2 (Version)
                     │
                     └──→ Phase 3 (Update)
```

- Phase 2 and Phase 3 depend on Phase 1 (manifest structure)
- Phase 2 and Phase 3 are independent of each other
- However, both are skills in same namespace, so sequential development is clearer

## File Dependency Analysis

### Phase 1
**Creates**:
- `.dotclaude-manifest.json`

**Modifies**: None

### Phase 2
**Creates**:
- `.claude/skills/dotclaude/version/SKILL.md`

**Reads**:
- `.dotclaude-manifest.json`

### Phase 3
**Creates**:
- `.claude/skills/dotclaude/update/SKILL.md`

**Reads**:
- `.dotclaude-manifest.json`
- `.claude/settings.json`

**Note**: Phase 2 and 3 do not modify the same files, but:
- They share the namespace directory
- Update skill references version checking logic
- Sequential execution ensures consistency

## Technical Specifications

### Manifest Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["version", "managed_files"],
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$"
    },
    "managed_files": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  }
}
```

### Version Comparison Logic

```
Semver comparison:
1. Parse X.Y.Z from both versions
2. Compare major → minor → patch
3. Return: -1 (older), 0 (same), 1 (newer)
```

### Update Workflow

```
1. Check prerequisites (gh CLI, network)
2. Fetch latest tag from upstream
3. Compare with local manifest version
4. Fetch upstream manifest for target version
5. Compute file diff (add/update/remove)
6. Show preview and get user confirmation
7. Create backup
8. Update files one by one
9. Smart merge settings.json
10. Update local manifest
11. Cleanup backup (or rollback on failure)
12. Report summary
```

## Error Handling

| Error | Handling |
|-------|----------|
| No network | Fail gracefully with message |
| gh not authenticated | Show auth instructions |
| File download fails | Rollback, report specific file |
| JSON parse error | Skip merge, warn user |
| Permission denied | Report, suggest sudo or permissions |

## Out of Scope (per SPEC)

- Automatic scheduling
- Update notifications
- Downgrade support
- Windows compatibility
- Migration scripts
