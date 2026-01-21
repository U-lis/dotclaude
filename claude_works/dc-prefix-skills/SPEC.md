# Dotclaude Skill Prefix Refactoring - Specification

## Overview

Add `dc:` prefix to all 7 dotclaude skill command names for clear namespace identification and improved discoverability.

## Target

Rename all dotclaude skill commands with `dc:` prefix:
- `/start-new` -> `/dc:start-new`
- `/code` -> `/dc:code`
- `/design` -> `/dc:design`
- `/validate-spec` -> `/dc:validate-spec`
- `/tagging` -> `/dc:tagging`
- `/merge-main` -> `/dc:merge-main`
- `/update-docs` -> `/dc:update-docs`

## Current Problems

| Problem | Description |
|---------|-------------|
| Readability/Identification | Difficult to distinguish dotclaude-specific commands from general commands |
| Inconsistency | No naming convention for command structure |
| Scalability | Structural issues expected when adding new commands in the future |

## Goal State

All dotclaude skills use `dc:` prefix for clear namespace identification:
- `/dc:start-new` - Entry point for new work
- `/dc:code` - Execute coding phases
- `/dc:design` - Transform SPEC into implementation plan
- `/dc:validate-spec` - Validate document consistency
- `/dc:tagging` - Create version tags
- `/dc:merge-main` - Merge feature branch to main
- `/dc:update-docs` - Update documentation

## Functional Requirements

- [ ] FR-1: Change `name:` field in all 7 SKILL.md files to include `dc:` prefix
- [ ] FR-2: Update all internal skill references to use new prefixed names
- [ ] FR-3: Update README.md command documentation to reflect new names

## Non-Functional Requirements

- [ ] NFR-1: Behavior must remain identical - pure refactoring, no functional changes
- [ ] NFR-2: Historical documents (CHANGELOG, claude_works/) must be preserved unchanged

## Constraints

- Behavior Change Policy: **PRESERVE** - Pure refactoring, no functional changes allowed
- Directory names remain unchanged (only `name` field in SKILL.md determines command name)
- No automated test coverage - Skill/Agent files are prompt-based configuration

## Out of Scope

- Changing directory names (`.claude/skills/start-new/` stays as-is)
- Modifying historical documents (CHANGELOG.md, claude_works/ archives)
- Adding new functionality to skills
- Changing CLAUDE.md (no direct command invocations present)

---

## Analysis Results

### Related Code

| # | File | Relationship |
|---|------|--------------|
| 1 | `.claude/skills/start-new/SKILL.md` | name field change required |
| 2 | `.claude/skills/code/SKILL.md` | name field + internal refs to /merge-main, /tagging |
| 3 | `.claude/skills/design/SKILL.md` | name field + internal refs to /validate-spec, /code |
| 4 | `.claude/skills/validate-spec/SKILL.md` | name field + internal ref to /code |
| 5 | `.claude/skills/tagging/SKILL.md` | name field change only |
| 6 | `.claude/skills/merge-main/SKILL.md` | name field change only |
| 7 | `.claude/skills/update-docs/SKILL.md` | name field change only |
| 8 | `README.md` | Command documentation update required |

### Internal Reference Map

| Source Skill | References To |
|-------------|---------------|
| start-new | /design, /code, /tagging (via workflow docs) |
| code | /merge-main, /tagging (Next Steps section) |
| design | /validate-spec, /code (Next Steps section) |
| validate-spec | /code (Next Steps section) |
| tagging | None |
| merge-main | None |
| update-docs | None |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | Historical docs (CHANGELOG, claude_works/) reference old command names | Preserve as-is | Update only new/active docs (user decision) |
| 2 | Directory name vs name field mismatch possible | Directory unchanged, name field updated | name field determines actual command - acceptable |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Old `/start-new` invocation | Will not work - must use `/dc:start-new` |
| 2 | Internal skill cross-references | All updated to dc: prefix |
| 3 | README documentation | Updated with new command names |
| 4 | CHANGELOG history | Preserved unchanged (historical record) |
| 5 | claude_works/ archives | Preserved unchanged (historical record) |

### Test Coverage Assessment

N/A - Skill/Agent files are prompt-based configuration, not executable code with automated test coverage.

---

## Scope of Changes

### Files to Modify (8 files)

1. `.claude/skills/start-new/SKILL.md`
   - Change: `name: start-new` -> `name: dc:start-new`
   - Change: Internal references to other skills

2. `.claude/skills/code/SKILL.md`
   - Change: `name: code` -> `name: dc:code`
   - Change: `/merge-main` -> `/dc:merge-main` (Next Steps)
   - Change: `/tagging` -> `/dc:tagging` (Next Steps)

3. `.claude/skills/design/SKILL.md`
   - Change: `name: design` -> `name: dc:design`
   - Change: `/validate-spec` -> `/dc:validate-spec` (Next Steps)
   - Change: `/code` -> `/dc:code` (Next Steps)

4. `.claude/skills/validate-spec/SKILL.md`
   - Change: `name: validate-spec` -> `name: dc:validate-spec`
   - Change: `/code` -> `/dc:code` (Next Steps)

5. `.claude/skills/tagging/SKILL.md`
   - Change: `name: tagging` -> `name: dc:tagging`

6. `.claude/skills/merge-main/SKILL.md`
   - Change: `name: merge-main` -> `name: dc:merge-main`

7. `.claude/skills/update-docs/SKILL.md`
   - Change: `name: update-docs` -> `name: dc:update-docs`

8. `README.md`
   - Update all command references in Skills table
   - Update Usage examples
   - Update Manual Execution section

### Files to Preserve (No Changes)

- `CHANGELOG.md` - Historical record
- `claude_works/**/*.md` - Previous work documents
- `CLAUDE.md` - No direct command invocations present
- Directory names under `.claude/skills/` - Name field determines command, not directory

---

## XP Principle Reference

| Principle | Application |
|-----------|-------------|
| Naming Conventions | Clear `dc:` namespace identifies dotclaude-specific commands |
| Simple Design | Minimal changes - only name field and references |
| Refactoring | Pure structural improvement without behavior change |
| Single Responsibility | Each change has one purpose: add prefix |

## Implementation Notes

- Single phase work - all changes can be done atomically
- No dependencies between file changes (can be done in any order)
- Recommend committing all changes together for consistency
