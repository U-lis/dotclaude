# Phase 1: Manifest Generation

## Objective

Create the `.dotclaude-manifest.json` file that tracks all dotclaude-managed files and the current version.

## Prerequisites

- None (first phase)

## Deliverables

1. `.dotclaude-manifest.json` - Manifest file with version and file list

## Implementation Checklist

### 1. Analyze Existing File Structure

- [ ] List all files under `.claude/agents/` (including subdirectories)
- [ ] List all files under `.claude/skills/` (only SKILL.md files)
- [ ] List all files under `.claude/hooks/`
- [ ] List all files under `.claude/templates/`
- [ ] Identify `.claude/settings.json` as special merge file

### 2. Determine Version

- [ ] Parse `CHANGELOG.md` to extract latest version (pattern: `## [X.Y.Z]`)
- [ ] Use this version for manifest

### 3. Create Manifest File

Create `.dotclaude-manifest.json` at repository root:

```json
{
  "version": "{VERSION}",
  "managed_files": [
    // All agent files
    ".claude/agents/orchestrator.md",
    ".claude/agents/designer.md",
    ".claude/agents/technical-writer.md",
    ".claude/agents/spec-validator.md",
    ".claude/agents/code-validator.md",
    ".claude/agents/init-feature.md",
    ".claude/agents/init-bugfix.md",
    ".claude/agents/init-refactor.md",
    ".claude/agents/_shared/init-workflow.md",
    ".claude/agents/_shared/analysis-phases.md",
    ".claude/agents/coders/_base.md",
    ".claude/agents/coders/python.md",
    ".claude/agents/coders/javascript.md",
    ".claude/agents/coders/svelte.md",
    ".claude/agents/coders/rust.md",
    ".claude/agents/coders/sql.md",

    // All skill files
    ".claude/skills/start-new/SKILL.md",
    ".claude/skills/init-feature/SKILL.md",
    ".claude/skills/init-bugfix/SKILL.md",
    ".claude/skills/init-refactor/SKILL.md",
    ".claude/skills/design/SKILL.md",
    ".claude/skills/validate-spec/SKILL.md",
    ".claude/skills/code/SKILL.md",
    ".claude/skills/update-docs/SKILL.md",
    ".claude/skills/merge-main/SKILL.md",
    ".claude/skills/tagging/SKILL.md",

    // Hook files
    ".claude/hooks/check-init-complete.sh",
    ".claude/hooks/check-validation-complete.sh",

    // Template files
    ".claude/templates/SPEC.md",
    ".claude/templates/GLOBAL.md",
    ".claude/templates/PHASE_PLAN.md",
    ".claude/templates/PHASE_TEST.md",
    ".claude/templates/PHASE_MERGE.md",

    // Settings (special: merge, not replace)
    ".claude/settings.json"
  ],
  "merge_files": [
    ".claude/settings.json"
  ]
}
```

### 4. Validation

- [ ] Verify all listed files exist in the repository
- [ ] Verify JSON is valid (parse with jq or similar)
- [ ] Verify version matches CHANGELOG.md latest entry

## File Structure After Phase 1

```
.
├── .dotclaude-manifest.json    # NEW
├── .claude/
│   └── (unchanged)
└── CHANGELOG.md                # (read only)
```

## Notes

- `managed_files` array lists ALL files that dotclaude manages
- `merge_files` array lists files that should be merged, not replaced
- Files not in `managed_files` are user-owned and never touched during updates
- This manifest will be included in future dotclaude releases
- Users should NOT manually edit this file

## Completion Criteria

- [ ] `.dotclaude-manifest.json` exists at repository root
- [ ] File contains valid JSON
- [ ] `version` matches CHANGELOG.md latest version
- [ ] All files in `managed_files` exist in repository
- [ ] No files are missed (compare with glob of `.claude/**/*`)
