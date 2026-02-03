# Phase 1: Relocate Language Sections

## Objective

Move the `## Language` section from the bottom of each affected command file to immediately after the frontmatter/title. This ensures Claude reads the language instruction before encountering any AskUserQuestion templates with hardcoded English text. For `purge.md`, add a new Language section (currently missing).

## Prerequisites

- SPEC.md reviewed and understood
- Access to worktree at `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/`

## Standard Language Section Block

All files use this identical text (insert with a blank line before and after):

```markdown
## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
```

## Instructions

### File 1: init-feature.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-feature.md`

1. Remove the `## Language` section at lines 223-228 (the heading, blank line, description paragraph, blank line, two bullet points, trailing blank line)
2. Insert the standard Language section block after line 7 (`Instructions for initializing new feature work through requirements gathering and SPEC creation.`) and before line 9 (`## Pre-filled Data Handling`)
3. Verify no other content was changed

### File 2: init-bugfix.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-bugfix.md`

1. Remove the `## Language` section at lines 255-260 (same structure as init-feature.md)
2. Insert the standard Language section block after line 7 (`Instructions for initializing bug fix work through bug detail gathering and root cause analysis.`) and before line 9 (`## Pre-filled Data Handling`)
3. Verify no other content was changed

### File 3: init-refactor.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-refactor.md`

1. Remove the `## Language` section at lines 238-243 (same structure)
2. Insert the standard Language section block after line 7 (`Instructions for initializing refactoring work through target analysis and dependency mapping.`) and before line 9 (`## Pre-filled Data Handling`)
3. Verify no other content was changed

### File 4: init-github-issue.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-github-issue.md`

1. Remove the `## Language` section at lines 319-324 (same structure)
2. Insert the standard Language section block after line 7 (`Instructions for initializing work from GitHub issue URL or number.`) and before line 9 (`**Requirements**: \`gh\` CLI must be installed and authenticated.`)
3. Verify no other content was changed

### File 5: _init-common.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/_init-common.md`

1. Remove the `## Language` section at lines 273-278 (same structure)
2. Insert the standard Language section block after line 9 (`---` separator after file description) and before line 11 (`## Branch Creation`)
3. Verify no other content was changed

### File 6: configure.md (SPECIAL HANDLING REQUIRED)

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/configure.md`

**CAUTION:** The Language section at line 505 has testing checklist items interleaved after it. Only extract the Language section; leave the checklist items in place.

1. Remove ONLY the Language section at lines 505-510:
   - Line 505: `## Language`
   - Line 506: (blank)
   - Line 507: `The SessionStart hook outputs the configured language (e.g., \`[dotclaude] language: ko_KR\`).`
   - Line 508: (blank)
   - Line 509: `- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.`
   - Line 510: `- If no language was provided at session start, default to English (en_US).`
2. Do NOT remove lines 511-513 (checklist items that follow):
   - `- [ ] Configuration saved with correct JSON format`
   - `- [ ] Boolean values saved as true/false (not "true"/"false")`
   - `- [ ] Changes take effect immediately`
   These checklist items belong to the preceding testing section. After removing the Language section heading and content, these items will naturally rejoin the checklist above them (lines 498-502).
3. Insert the standard Language section block after line 6 (`Interactive configuration manager for dotclaude plugin settings.`) and before line 8 (`## Role`)
4. Verify no other content was changed and the remaining checklist is intact

### File 7: merge.md

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/merge.md`

1. Remove the `## Language` section at lines 74-79 (same structure)
2. Insert the standard Language section block after line 5 (`# /dotclaude:merge [branch]`) and before line 7 (`Merge current branch to base branch, analyze conflicts, cleanup.`)
3. Verify no other content was changed

### File 8: purge.md (ADD NEW SECTION)

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/purge.md`

1. There is NO existing Language section to remove
2. Insert the standard Language section block after line 5 (`# /dotclaude:purge`) and before line 7 (`Clean up merged branches, remote tracking branches, and orphaned worktrees after releases.`)
3. Verify no other content was changed

### File 9: start-new.md (VERIFY ONLY)

**Path:** `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/start-new.md`

1. Verify the `## Language` section exists at line 35
2. Verify it appears BEFORE the `## Role` section (line 42) and BEFORE any AskUserQuestion templates
3. Verify the Language section content matches the standard block
4. No modification needed -- this file is already correct

## Completion Checklist

- [x] `init-feature.md`: Language section removed from line 223, inserted after line 7. Verified at line 9 in init-feature.md.
- [x] `init-bugfix.md`: Language section removed from line 255, inserted after line 7. Verified at line 9 in init-bugfix.md.
- [x] `init-refactor.md`: Language section removed from line 238, inserted after line 7. Verified at line 9 in init-refactor.md.
- [x] `init-github-issue.md`: Language section removed from line 319, inserted after line 7. Verified at line 9 in init-github-issue.md.
- [x] `_init-common.md`: Language section removed from line 273, inserted after line 9. Verified at line 9 in _init-common.md.
- [x] `configure.md`: Language section (only) removed from lines 505-510, checklist items at 511-513 preserved, Language inserted after line 6. Verified at line 9 in configure.md; checklist items at lines 511-513.
- [x] `merge.md`: Language section removed from line 74, inserted after line 5. Verified at line 7 in merge.md.
- [x] `purge.md`: New Language section added after line 5. Verified at line 7 in purge.md.
- [x] `start-new.md`: Verified Language section already at line 35 (no changes needed).
- [x] All files: No other content changed (question text, logic, structure intact).
- [x] All files: Language section content matches the standard block exactly.

## Notes

- Line numbers reference the ORIGINAL file state before any edits. After the first edit within a file, line numbers shift. Process the removal and insertion within each file as a single atomic operation.
- The Language section always needs a blank line before and after it to maintain proper Markdown formatting.
- For `configure.md`, pay special attention to not accidentally removing the checklist items that follow the Language section.
