<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-config-language
-->

# Language Configuration Not Applied to AskUserQuestion Text in init-xxx and start-new Commands - Specification

## GitHub Issue

- Issue: https://github.com/U-lis/dotclaude/issues/41
- Target Version: 0.3.1

## Overview

The `language` config setting (e.g., `ko_KR`) is correctly loaded and output by the SessionStart hook, and each command file contains a `## Language` section instructing Claude to use the configured language for all user-facing communication. However, all AskUserQuestion calls in init-xxx and start-new commands contain hardcoded English text for question, header, label, and description fields. Claude follows the template text literally instead of translating it to the configured language.

### Root Cause

The `## Language` section is positioned at the **bottom** of each command file, after all AskUserQuestion template blocks that contain hardcoded English text. When Claude reads the command file, it interprets the literal English text in AskUserQuestion templates as the exact parameters to use, because:

1. The English template text appears first and establishes a strong literal pattern.
2. The language instruction appears too late in the document to override the already-established pattern.
3. The language instruction wording is not explicit enough to direct Claude to translate the AskUserQuestion parameters.

### Reproduction Steps

1. Set `language: "ko_KR"` in `.claude/dotclaude-config.json`.
2. Run `/dotclaude:start-new` and select any work type (e.g., feature).
3. Observe that the init-xxx questions are displayed in English (e.g., "What is the main goal of this feature?").
4. Note that status messages like progress reports may appear in Korean correctly, but the AskUserQuestion tool parameters remain in English.

### Severity

Minor - core functionality works correctly, but user experience is degraded for non-English language configurations.

## Functional Requirements

- [ ] FR-1: All AskUserQuestion parameters (question, header, label, description) MUST be translated to the configured language before tool invocation
- [ ] FR-2: The Language instruction MUST be positioned at the top of the file (after frontmatter, before any question templates) so Claude processes it before encountering English template text
- [ ] FR-3: Status messages, progress reports, and error messages MUST also use the configured language (already partially working; ensure consistency)
- [ ] FR-4: When language is `en_US` (default), behavior MUST remain unchanged -- English text used as-is from templates

## Non-Functional Requirements

- [ ] NFR-1: No structural changes to question logic or workflow flow -- only the language application mechanism changes
- [ ] NFR-2: No new files or dependencies required -- fix is contained within existing `.md` command files
- [ ] NFR-3: Fix MUST be applied consistently across ALL affected command files (see Affected Files below)

## Affected Files

The following files contain AskUserQuestion calls and require the fix:

| File | AskUserQuestion Count | Has Language Section |
|------|----------------------|---------------------|
| `commands/start-new.md` | 12 | Yes |
| `commands/_init-common.md` | 5 | Yes |
| `commands/init-feature.md` | 2 | Yes |
| `commands/init-bugfix.md` | 3 | Yes |
| `commands/init-refactor.md` | 3 | Yes |
| `commands/init-github-issue.md` | 3 | Yes |
| `commands/configure.md` | 4 | Yes |
| `commands/merge.md` | 2 | Yes |
| `commands/purge.md` | 2 | No |

Total: 9 files, 36 AskUserQuestion call sites.

## Fix Strategy

**Fix Strategy: Relocate Language section to the top of each file**

The current `## Language` instruction wording is already sufficient -- it explicitly mentions AskUserQuestion labels, descriptions, status messages, etc. The issue is purely about **position**: the Language section appears at the bottom of each file, after Claude has already processed all English AskUserQuestion templates as literal text to use.

Fix approach for each affected command file:
1. **Remove** the `## Language` section from its current position (typically at the bottom of the file).
2. **Add** the same Language section immediately after the frontmatter block (before any content or question templates), so Claude reads the language instruction first.
3. For `commands/purge.md` which currently lacks a Language section, **add** the standard Language section after the frontmatter.

No changes to the Language section wording are needed. The existing text is clear enough:
```
The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
```

This is a position-only fix -- no wording strengthening, no per-question reminders, no structural changes.

## Constraints

- MUST only modify `.md` command files in the `commands/` directory
- MUST NOT change the question content or meaning -- only how language instruction is applied
- MUST maintain backward compatibility with `en_US` default
- MUST NOT introduce separate translation files or an i18n framework
- MUST NOT modify agent definition files in `agents/` directory

## Out of Scope

- Creating separate translation files or i18n framework
- Translating document templates (SPEC.md, GLOBAL.md, PHASE_*_PLAN.md) -- these remain in English per the TechnicalWriter agent rules
- Translating agent definition files in `agents/`
- Adding new language codes or language code validation logic
- Changing the SessionStart hook behavior
- Modifying non-command files outside the `commands/` directory
