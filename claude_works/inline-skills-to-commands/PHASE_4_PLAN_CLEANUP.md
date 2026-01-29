# Phase 4: Delete skills/ Directory and Final Verification

## Objective

Delete the entire `skills/` directory now that all content has been inlined into command files or moved to `commands/`. Verify no remaining references to the deleted directory.

## Prerequisites

- Phase 3 complete (all invocation patterns updated)
- All 8 command files contain full inlined content
- All 5 internal commands created in `commands/`

## Instructions

### Step 1: Pre-Deletion Verification

Before deleting, verify all content has been successfully migrated:

```bash
# Verify all 13 command files exist
ls commands/start-new.md
ls commands/configure.md
ls commands/code.md
ls commands/design.md
ls commands/update-docs.md
ls commands/validate-spec.md
ls commands/merge-main.md
ls commands/tagging.md
ls commands/init-feature.md
ls commands/init-bugfix.md
ls commands/init-refactor.md
ls commands/init-github-issue.md
ls commands/_analysis.md

# Verify no command files still contain redirect pattern
grep -r "Read skills/" commands/
# Expected: no output

# Verify no command files reference "this skill directory"
grep -r "from this skill directory" commands/
# Expected: no output
```

### Step 2: Delete skills/ Directory

```bash
rm -rf skills/
```

This deletes:
- `skills/start-new/SKILL.md`
- `skills/start-new/init-feature.md`
- `skills/start-new/init-bugfix.md`
- `skills/start-new/init-refactor.md`
- `skills/start-new/init-github-issue.md`
- `skills/start-new/_analysis.md`
- `skills/configure/SKILL.md`
- `skills/code/SKILL.md`
- `skills/design/SKILL.md`
- `skills/update-docs/SKILL.md`
- `skills/validate-spec/SKILL.md`
- `skills/merge-main/SKILL.md`
- `skills/tagging/SKILL.md`

Total: 13 files in 8 directories.

### Step 3: Verify No Remaining References

Check active source files (not claude_works/ historical docs) for dangling references:

```bash
# Check command files for skills/ references
grep -r "skills/" commands/ agents/ CLAUDE.md .claude/CLAUDE.md
# Expected: no output (or only in historical/documentation context)

# Check for any file path references to skills/
grep -rn "skills/" --include="*.md" . --exclude-dir=claude_works --exclude-dir=.git
# Expected: no output
```

**Note**: References in `claude_works/` (historical planning documents) and `CHANGELOG.md` are acceptable and should NOT be modified. These are historical records.

### Step 4: Verify Directory Structure

```bash
# skills/ should not exist
ls skills/ 2>&1
# Expected: "No such file or directory"

# commands/ should have 13 files
ls commands/
# Expected: 13 .md files (8 user-invocable + 5 internal)

# agents/ should be unchanged structurally
ls agents/
ls agents/coders/
# Expected: same structure as before
```

## Important Notes

- Do NOT modify `CHANGELOG.md` or any `claude_works/` files. They contain historical references to `skills/` which are correct for their time.
- Do NOT modify `CLAUDE.md` or `.claude/CLAUDE.md`. The project instructions reference `skills/` in the Directory Structure section, but this is documentation that should be updated in a separate docs-update phase (Phase 5 / update-docs), not in the cleanup phase.
- The `skills/` deletion is a git-tracked removal. It will show as deleted files in `git status`.

## Completion Checklist

- [ ] Pre-deletion verification passed (all 13 command files exist, no redirect patterns)
- [ ] `skills/` directory completely deleted
- [ ] No dangling `skills/` references in active source files (commands/, agents/)
- [ ] `commands/` contains exactly 13 .md files
- [ ] `agents/` directory structure unchanged
- [ ] No files accidentally deleted outside of `skills/`

## Verification

1. `ls skills/` produces "No such file or directory"
2. `ls commands/*.md | wc -l` returns 13
3. `grep -r "skills/" commands/ agents/` returns empty
4. `git status` shows skills/ files as deleted and commands/ files as new/modified
