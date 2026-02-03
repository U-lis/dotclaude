# Config Language Fix - Global Documentation

## Feature Overview

**Purpose:** Fix the Language configuration not being applied to AskUserQuestion text in init-xxx and start-new commands.

**Problem:** The `## Language` section is positioned at the bottom of each command file, after all AskUserQuestion template blocks containing hardcoded English text. Claude interprets the literal English text first and uses it as-is, because the language override instruction arrives too late in the document to take effect.

**Solution:** Relocate the `## Language` section from the bottom of each affected command file to immediately after the frontmatter/title, so Claude reads the language instruction before encountering any AskUserQuestion templates. For `purge.md`, which lacks a Language section entirely, add one. No wording changes needed -- the existing Language section text is sufficient.

## Architecture Decision

This is a **position-only fix**. The Language section content remains identical across all files. The fix works because LLMs process instruction documents top-to-bottom, and placing the language directive early establishes the translation requirement before any English template text is encountered.

Key decisions:
- No per-question language reminders needed
- No i18n framework or translation files
- No structural changes to question logic or workflow
- Identical Language section content for all files (standardized)

## Standard Language Section Content

All files use this exact text block:

```markdown
## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
```

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Relocate Language Sections | Pending | None |

## Affected Files

All files are located in the worktree at `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/`.

| # | File | Total Lines | Current Language Section Line | Frontmatter Ends At | Action |
|---|------|-------------|-------------------------------|----------------------|--------|
| 1 | `init-feature.md` | 228 | Line 223 (bottom) | Line 4 (`---`) | Move to after line 7 |
| 2 | `init-bugfix.md` | 260 | Line 255 (bottom) | Line 4 (`---`) | Move to after line 7 |
| 3 | `init-refactor.md` | 243 | Line 238 (bottom) | Line 4 (`---`) | Move to after line 7 |
| 4 | `init-github-issue.md` | 324 | Line 319 (bottom) | Line 4 (`---`) | Move to after line 7 |
| 5 | `_init-common.md` | 278 | Line 273 (bottom) | Line 4 (`---`) | Move to after line 9 |
| 6 | `configure.md` | 513 | Line 505 (bottom, interleaved) | Line 3 (`---`) | Move to after line 6; extract from checklist |
| 7 | `merge.md` | 79 | Line 74 (bottom) | Line 3 (`---`) | Move to after line 5 |
| 8 | `purge.md` | 249 | None (missing) | Line 3 (`---`) | Add new section after line 5 |
| 9 | `start-new.md` | 982 | Line 35 (already near top) | Line 3 (`---`) | Already correct -- verify only |

## File Structure

No new files are created or deleted. Only existing `.md` files in `commands/` are modified in-place.

### Files to Modify
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-feature.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-bugfix.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-refactor.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/init-github-issue.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/_init-common.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/configure.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/merge.md`
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/purge.md`

### Files to Verify Only (No Changes Expected)
- `/home/ulismoon/Documents/dotclaude-bugfix-config-language/commands/start-new.md`

## Special Cases

### configure.md - Interleaved Content

The Language section at line 505 in `configure.md` has testing checklist items mixed in after it:

```
505: ## Language
506: (blank)
507: The SessionStart hook outputs the configured language...
508: (blank)
509: - All user-facing communication...
510: - If no language was provided at session start...
511: - [ ] Configuration saved with correct JSON format       <-- NOT part of Language section
512: - [ ] Boolean values saved as true/false (not "true"/"false")  <-- NOT part of Language section
513: - [ ] Changes take effect immediately                    <-- NOT part of Language section
```

The executor MUST extract only lines 505-510 (the Language heading and its two bullet points). Lines 511-513 are checklist items that belong to the preceding testing/validation section and must remain in place at the bottom.

### start-new.md - Already Correct

The `start-new.md` file already has the Language section at line 35, positioned after the Configuration Loading section (lines 8-33) and before the Role section (line 42). This is a valid early position -- the Language instruction appears before any AskUserQuestion templates. No modification needed; verify only.

### purge.md - Missing Section

The `purge.md` file has no Language section at all. The standard Language section block must be added after the title line (line 5: `# /dotclaude:purge`) and before the description paragraph (line 7: `Clean up merged branches...`).
