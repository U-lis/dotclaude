# Dotclaude Skill Prefix - Global Documentation

**Target Version**: 0.0.9

## Feature Overview

### Purpose
Add `dc:` namespace prefix to all dotclaude skill command names for clear identification and improved discoverability.

### Problem
- Difficult to distinguish dotclaude-specific commands from general commands
- No naming convention for command structure
- Scalability issues when adding new commands

### Solution
Prefix all 7 dotclaude skills with `dc:` namespace:
- `/start-new` -> `/dc:start-new`
- `/code` -> `/dc:code`
- `/design` -> `/dc:design`
- `/validate-spec` -> `/dc:validate-spec`
- `/tagging` -> `/dc:tagging`
- `/merge-main` -> `/dc:merge-main`
- `/update-docs` -> `/dc:update-docs`

## Architecture Decision

### Single Phase Approach

**Decision**: Implement all changes in a single atomic phase.

**Rationale**:
- All changes are semantically equivalent (add prefix)
- No dependencies between file modifications
- Changes should be committed together for consistency
- Risk is minimal (pure refactoring, no functional changes)

### No Parallel Phases Needed

**Reason**: Each file modification is independent and small. Sequential execution within single phase is sufficient and simpler than parallel worktree setup.

## Files Affected

| # | File Path | Change Type |
|---|-----------|-------------|
| 1 | `.claude/skills/update-docs/SKILL.md` | Add frontmatter + change name |
| 2 | `.claude/skills/tagging/SKILL.md` | Change name field |
| 3 | `.claude/skills/merge-main/SKILL.md` | Change name field |
| 4 | `.claude/skills/validate-spec/SKILL.md` | Change name + update refs |
| 5 | `.claude/skills/design/SKILL.md` | Change name + update refs |
| 6 | `.claude/skills/code/SKILL.md` | Change name + update refs |
| 7 | `.claude/skills/start-new/SKILL.md` | Change name + update ref + add target version question |
| 8 | `README.md` | Update command documentation |

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | PREFIX - Add dc: prefix to all skills | Complete | None |

## Success Criteria

1. All 7 SKILL.md files have `name: dc:{skill}` in frontmatter
2. All internal skill cross-references use `dc:` prefix
3. README.md shows all commands with `dc:` prefix
4. No functional behavior changes
5. Historical documents (CHANGELOG, claude_works/) preserved unchanged
