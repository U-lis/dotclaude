# Phase 1: Test Cases - Relocate Language Sections

## Test Coverage Target

>= 70% of verification criteria covered

## Verification Strategy

Since this is a text relocation task in Markdown files (not code), testing consists of structural verification rather than unit tests. Each file is verified by checking:
1. Language section is present near the top (within first 15 lines of content after frontmatter)
2. Language section does NOT appear at the bottom of the file
3. Language section content matches the standard block exactly
4. No other content was accidentally modified (git diff shows only section movement)

## Per-File Verification Tests

### Test 1: init-feature.md

- [ ] T1.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T1.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T1.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T1.4: No `## Language` heading exists after line 20
- [ ] T1.5: `git diff` shows only the Language section was moved -- no other changes to question text, logic, or structure

### Test 2: init-bugfix.md

- [ ] T2.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T2.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T2.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T2.4: No `## Language` heading exists after line 20
- [ ] T2.5: `git diff` shows only the Language section was moved -- no other changes

### Test 3: init-refactor.md

- [ ] T3.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T3.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T3.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T3.4: No `## Language` heading exists after line 20
- [ ] T3.5: `git diff` shows only the Language section was moved -- no other changes

### Test 4: init-github-issue.md

- [ ] T4.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T4.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T4.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T4.4: No `## Language` heading exists after line 20
- [ ] T4.5: `git diff` shows only the Language section was moved -- no other changes

### Test 5: _init-common.md

- [ ] T5.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T5.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T5.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T5.4: No `## Language` heading exists after line 20
- [ ] T5.5: `git diff` shows only the Language section was moved -- no other changes

### Test 6: configure.md (Special Case)

- [ ] T6.1: `## Language` heading appears within the first 15 lines of the file
- [ ] T6.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T6.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T6.4: No `## Language` heading exists after line 20
- [ ] T6.5: The three checklist items that were interleaved after the old Language section still exist in the file:
  - `- [ ] Configuration saved with correct JSON format`
  - `- [ ] Boolean values saved as true/false (not "true"/"false")`
  - `- [ ] Changes take effect immediately`
- [ ] T6.6: These checklist items are now contiguous with the preceding checklist (no orphaned `## Language` heading between them)
- [ ] T6.7: `git diff` shows only the Language section was moved and no checklist items were deleted

### Test 7: merge.md

- [ ] T7.1: `## Language` heading appears within the first 12 lines of the file
- [ ] T7.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T7.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T7.4: No `## Language` heading exists after line 15
- [ ] T7.5: `git diff` shows only the Language section was moved -- no other changes

### Test 8: purge.md (New Section Added)

- [ ] T8.1: `## Language` heading appears within the first 12 lines of the file
- [ ] T8.2: The line immediately after `## Language` (with blank line) contains `The SessionStart hook outputs the configured language`
- [ ] T8.3: Two bullet points follow: one starting with `- All user-facing communication` and one with `- If no language was provided`
- [ ] T8.4: `git diff` shows only the Language section was added -- no other changes
- [ ] T8.5: Total line count increased by exactly 6 lines (heading + blank + description + blank + bullet 1 + bullet 2) compared to original 249 lines

### Test 9: start-new.md (Verify Only)

- [ ] T9.1: `## Language` heading exists at line 35 (unchanged)
- [ ] T9.2: Language section appears BEFORE `## Role` section
- [ ] T9.3: Language section content matches the standard block
- [ ] T9.4: `git diff` shows NO changes to this file

## Cross-File Verification

- [ ] T10.1: Run `grep -n "## Language" commands/*.md` and verify every match is within the first 15 content lines (after frontmatter) of each file
- [ ] T10.2: Run `grep -c "## Language" commands/*.md` and verify each file has exactly ONE `## Language` heading (no duplicates)
- [ ] T10.3: Verify all 9 files listed in the Affected Files table have a `## Language` section (including purge.md which previously lacked one)
- [ ] T10.4: Run full `git diff --stat` and verify only 8 files were modified (start-new.md should show no changes)

## Edge Cases

- [ ] E1: No trailing whitespace introduced after Language section insertion
- [ ] E2: Blank lines around the Language section are consistent (one blank line before `## Language`, one blank line after the last bullet point)
- [ ] E3: configure.md checklist items not orphaned or duplicated
- [ ] E4: No accidental double `## Language` sections in any file

## Verification Commands

Run these commands from the worktree root (`/home/ulismoon/Documents/dotclaude-bugfix-config-language/`) after all edits are complete:

```bash
# 1. Check Language section positions (should all be within first 15 lines)
grep -n "## Language" commands/init-feature.md commands/init-bugfix.md commands/init-refactor.md commands/init-github-issue.md commands/_init-common.md commands/configure.md commands/merge.md commands/purge.md commands/start-new.md

# 2. Check no duplicate Language sections
grep -c "## Language" commands/init-feature.md commands/init-bugfix.md commands/init-refactor.md commands/init-github-issue.md commands/_init-common.md commands/configure.md commands/merge.md commands/purge.md commands/start-new.md

# 3. Check diff summary (should show 8 files changed, start-new.md unchanged)
git diff --stat commands/

# 4. Check configure.md checklist items preserved
grep -n "Configuration saved with correct JSON format" commands/configure.md
grep -n "Boolean values saved as true/false" commands/configure.md
grep -n "Changes take effect immediately" commands/configure.md

# 5. Check purge.md now has Language section
grep -c "## Language" commands/purge.md
```
