# Phase 2: Inline start-new + Move Sub-files + Update Cross-References

## Objective

Handle the complex start-new skill inlining:
1. Move 5 sub-files from `skills/start-new/` to `commands/` as internal commands
2. Inline `skills/start-new/SKILL.md` into `commands/start-new.md`
3. Update all cross-references (file path references become command references)

## Prerequisites

- Phase 1.5 complete (merge of 1A + 1B)
- Phase 1B specifically: the 7 simple commands are already inlined (confirms the pattern works)

## Instructions

### Step 1: Move Sub-files to commands/ as Internal Commands

Move the following 5 files from `skills/start-new/` to `commands/`, adding `user-invocable: false` frontmatter to each.

#### 1a. `commands/init-feature.md`

**Source**: `skills/start-new/init-feature.md` (188 lines)

Add frontmatter at top:
```yaml
---
description: Initialize new feature work through requirements gathering and SPEC creation.
user-invocable: false
---
```

Then append the full content of `skills/start-new/init-feature.md` starting from line 1.

**Cross-reference update within this file**:
- Line 110: `Read _analysis.md for the common analysis workflow (Steps A-E).`
  - Change to: `Follow the _analysis command for the common analysis workflow (Steps A-E). Claude will auto-load the command content.`

#### 1b. `commands/init-bugfix.md`

**Source**: `skills/start-new/init-bugfix.md` (228 lines)

Add frontmatter at top:
```yaml
---
description: Initialize bug fix work through bug detail gathering and root cause analysis.
user-invocable: false
---
```

Then append the full content of `skills/start-new/init-bugfix.md` starting from line 1.

**Cross-reference update within this file**:
- Line 93: `Read _analysis.md for the common analysis workflow (Steps A-E).`
  - Change to: `Follow the _analysis command for the common analysis workflow (Steps A-E). Claude will auto-load the command content.`

#### 1c. `commands/init-refactor.md`

**Source**: `skills/start-new/init-refactor.md` (211 lines)

Add frontmatter at top:
```yaml
---
description: Initialize refactoring work through target analysis and dependency mapping.
user-invocable: false
---
```

Then append the full content of `skills/start-new/init-refactor.md` starting from line 1.

**Cross-reference update within this file**:
- Line 95: `Read _analysis.md for the common analysis workflow (Steps A-E).`
  - Change to: `Follow the _analysis command for the common analysis workflow (Steps A-E). Claude will auto-load the command content.`

#### 1d. `commands/init-github-issue.md`

**Source**: `skills/start-new/init-github-issue.md` (187 lines)

Add frontmatter at top:
```yaml
---
description: Initialize work from GitHub issue URL or number with auto-parsing.
user-invocable: false
---
```

Then append the full content of `skills/start-new/init-github-issue.md` starting from line 1.

**Cross-reference update**: None needed (init-github-issue.md does not reference _analysis.md directly; the analysis step is triggered by the orchestrator in start-new.md).

#### 1e. `commands/_analysis.md`

**Source**: `skills/start-new/_analysis.md` (237 lines)

Add frontmatter at top:
```yaml
---
description: Common analysis workflow for init phase - input analysis, codebase analysis, and DDD context mapping.
user-invocable: false
---
```

Then append the full content of `skills/start-new/_analysis.md` starting from line 1.

**Cross-reference update**: None needed (self-contained).

### Step 2: Inline start-new SKILL.md into commands/start-new.md

**Source**: `skills/start-new/SKILL.md` (952 lines)

Replace the current thin wrapper content of `commands/start-new.md` with the full SKILL.md body.

**Keep the existing command description**:
```yaml
---
description: Entry point for starting new work. Executes full 13-step orchestrator workflow with AskUserQuestion support.
---
```

**Strip the SKILL.md frontmatter** (lines 1-5 of SKILL.md):
```yaml
---
name: start-new
description: Entry point for starting new work...
user-invocable: true
---
```

Copy everything from SKILL.md line 7 onward (`# /dc:start-new`).

### Step 3: Update Cross-References in start-new.md

After inlining, update these references within `commands/start-new.md`:

#### 3a. Step 2 Init File Table (around original SKILL.md line 64-69)

**Before**:
```markdown
Based on Step 1 response, read and follow the corresponding init file from this directory:

| User Selection | Init File to Read |
|----------------|-------------------|
| Add/Modify Feature | Read `init-feature.md` from this skill directory |
| Bug Fix | Read `init-bugfix.md` from this skill directory |
| Refactoring | Read `init-refactor.md` from this skill directory |
| GitHub Issue | Read `init-github-issue.md` from this skill directory |
```

**After**:
```markdown
Based on Step 1 response, follow the corresponding init command (Claude auto-loads command content):

| User Selection | Init Command |
|----------------|--------------|
| Add/Modify Feature | Follow the `init-feature` command |
| Bug Fix | Follow the `init-bugfix` command |
| Refactoring | Follow the `init-refactor` command |
| GitHub Issue | Follow the `init-github-issue` command |
```

#### 3b. Analysis Phase Reference (around original SKILL.md line 76)

**Before**:
```markdown
5. Analysis phase (read `_analysis.md` for details)
```

**After**:
```markdown
5. Analysis phase (follow the `_analysis` command for details)
```

## Important Notes

- Do NOT update agent invocation patterns (`general-purpose` -> `dotclaude:*`) in this phase. That is Phase 3.
- The 5 internal command files should have both `description` and `user-invocable: false` in their frontmatter.
- The sub-files' original content is preserved as-is, except for the `_analysis.md` cross-reference updates.
- init-github-issue.md does NOT have a direct reference to `_analysis.md` (the analysis phase is triggered by the orchestrator), so no cross-reference update is needed in that file.

## Completion Checklist

- [ ] `commands/init-feature.md` created with frontmatter (`user-invocable: false`) and full content
- [ ] `commands/init-bugfix.md` created with frontmatter and full content
- [ ] `commands/init-refactor.md` created with frontmatter and full content
- [ ] `commands/init-github-issue.md` created with frontmatter and full content
- [ ] `commands/_analysis.md` created with frontmatter and full content
- [ ] `commands/start-new.md` contains full SKILL.md body (not redirect)
- [ ] start-new.md: Init file table updated (no "from this skill directory" references)
- [ ] start-new.md: Analysis phase reference updated (no "read _analysis.md" reference)
- [ ] init-feature.md: `_analysis.md` reference updated to command reference
- [ ] init-bugfix.md: `_analysis.md` reference updated to command reference
- [ ] init-refactor.md: `_analysis.md` reference updated to command reference
- [ ] No file references "from this skill directory" or "from this directory"
- [ ] All 5 internal commands have `user-invocable: false` in frontmatter
- [ ] SKILL.md frontmatter NOT duplicated into start-new.md

## Verification

1. `grep -r "from this skill directory" commands/` returns empty
2. `grep -r "from this directory" commands/` returns empty
3. `grep -r "Read \`_analysis.md\`" commands/` returns empty (old pattern gone)
4. All 5 new command files exist in `commands/`
5. `commands/start-new.md` is > 900 lines (full content, not 6-line redirect)
