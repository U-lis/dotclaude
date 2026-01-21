# dotclaude Auto-Update Feature - Specification

## Overview

**Purpose**: Provide CLI commands to check and update the dotclaude framework to the latest released version from the U-lis/dotclaude repository.

**Problem**: Users need to manually track and apply updates from the dotclaude repository to keep their `.claude` directory in sync with the latest features, agents, and skills.

**Solution**: Implement two new skills (`/dotclaude:update` and `/dotclaude:version`) that fetch the latest release tag from U-lis/dotclaude and intelligently merge only dotclaude-managed files while preserving user customizations.

---

## Functional Requirements

### Core Features
- [ ] FR-1: `/dotclaude:version` command displays current installed version and latest available version
- [ ] FR-2: `/dotclaude:update` command updates `.claude` directory to the latest release tag
- [ ] FR-3: `/dotclaude:update <version>` command updates to a specific version tag (e.g., `/dotclaude:update v0.1.0`)
- [ ] FR-4: Update only dotclaude-managed files (preserve user's custom settings and additions)

### Secondary Features
- [ ] FR-5: Display changelog summary for new version before updating
- [ ] FR-6: Require user confirmation before applying update
- [ ] FR-7: Rollback capability if update fails mid-process

---

## Non-Functional Requirements

### Performance
- [ ] NFR-1: Version check completes within 5 seconds (network dependent)
- [ ] NFR-2: Update process completes within 30 seconds for typical releases

### Security
- [ ] NFR-3: Verify update source is from official U-lis/dotclaude repository
- [ ] NFR-4: No execution of downloaded scripts without explicit user consent

### Reliability
- [ ] NFR-5: Graceful handling of network failures with clear error messages
- [ ] NFR-6: Safe failure mode - never leave `.claude` in inconsistent state

---

## Constraints

### Technical Constraints
- Tools: `gh` CLI for GitHub API interaction (already available in Claude Code environment)
- Source Repository: U-lis/dotclaude
- Version Format: Semver tags (e.g., v0.0.9, v0.1.0)
- File System: Linux/macOS compatible (standard POSIX)

### Business Constraints
- None

---

## Out of Scope

The following are explicitly NOT part of this work:
- Automatic update scheduling (cron-based updates)
- Update notification system (proactive alerts)
- Downgrade to older versions (only current or newer)
- Windows-specific compatibility
- Migration scripts for breaking changes between versions

---

## Assumptions

- User has `gh` CLI installed and authenticated
- User has network access to GitHub
- dotclaude repository uses standard GitHub releases with semver tags
- Current version is tracked in CHANGELOG.md using Keep a Changelog format
- `.claude` directory structure follows standard dotclaude layout

---

## Managed Files Specification

### Critical Rule: File-Level Updates Only

**NEVER delete folders and replace them entirely.** Users may have added their own custom agents, skills, hooks, or templates. The update process must:

1. Identify specific files managed by dotclaude (via manifest)
2. Update only those specific files
3. Leave user-added files completely untouched

### Manifest-Based File Management

A `.dotclaude-manifest.json` file will track which files are managed by dotclaude:

```json
{
  "version": "0.0.9",
  "managed_files": [
    ".claude/agents/orchestrator.md",
    ".claude/agents/designer.md",
    ".claude/agents/init-feature.md",
    ".claude/skills/start-new/SKILL.md",
    ".claude/hooks/check-init-complete.sh",
    ...
  ]
}
```

### Update Process

1. **Fetch upstream manifest**: Get list of managed files from new version
2. **Compare with local**: Identify files to add, update, or remove
3. **File-by-file update**:
   - New files → Add
   - Existing managed files → Update (overwrite)
   - Removed from upstream → Ask user before deleting
   - User's custom files → Never touch
4. **Update local manifest**: Record new version and file list

### File Categories

**Managed files (update/add based on manifest):**
```
.claude/
├── agents/*.md         # Only files listed in manifest
├── skills/*/SKILL.md   # Only files listed in manifest
├── hooks/*.sh          # Only files listed in manifest
└── templates/*.md      # Only files listed in manifest
```

**Smart merge files:**
```
.claude/
└── settings.json       # Merge new keys, preserve user values
```

**Never touched (user-owned):**
```
.claude/
├── settings.local.json     # User's local settings
├── agents/my-custom.md     # User-added (not in manifest)
├── skills/my-skill/        # User-added (not in manifest)
└── (any file not in manifest)

claude_works/               # User's work directory
```

### settings.json Merge Strategy

1. **Read both files**: upstream settings.json and local settings.json
2. **Deep comparison**: Identify keys that exist only in upstream (new features)
3. **Preserve user values**: Never overwrite existing user configurations
4. **Add new keys only**: Only add keys/sections that don't exist locally
5. **Report changes**: Show user what will be added before applying
6. **User confirmation**: Require explicit approval for settings changes

---

## Open Questions

- [x] Should settings.json be merged or replaced? → **Merge** (preserve user customizations)
- [ ] How to handle version conflicts in settings.json merge?
- [ ] Should we create a `.dotclaude-version` file to track installed version separately from CHANGELOG.md?

---

## References

- U-lis/dotclaude repository: https://github.com/U-lis/dotclaude
- Keep a Changelog format: https://keepachangelog.com
- Existing /tagging skill: `.claude/skills/tagging/SKILL.md`
