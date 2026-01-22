# Phase 1: PREFIX

## Objective

Add `dc:` prefix to all dotclaude skill names and update all internal references.

## Prerequisites

- None (first and only phase)

## Instructions

Execute modifications in the following order. Each step describes exact changes needed.

---

### Step 1: update-docs/SKILL.md

**File**: `.claude/skills/update-docs/SKILL.md`

**Issue**: Missing frontmatter section (file starts with `# /update-docs` directly)

**Actions**:
1. Add YAML frontmatter at the beginning of file:
   ```yaml
   ---
   name: dc:update-docs
   description: Update project documentation (README, CHANGELOG) after code implementation is complete.
   user-invocable: true
   ---
   ```
2. Keep all existing content unchanged after frontmatter

---

### Step 2: tagging/SKILL.md

**File**: `.claude/skills/tagging/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: tagging`
   - TO: `name: dc:tagging`

---

### Step 3: merge-main/SKILL.md

**File**: `.claude/skills/merge-main/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: merge-main`
   - TO: `name: dc:merge-main`

---

### Step 4: validate-spec/SKILL.md

**File**: `.claude/skills/validate-spec/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: validate-spec`
   - TO: `name: dc:validate-spec`

2. Update internal reference (line ~110, "Next Steps" section):
   - FROM: `1. Proceed to `/code [phase]` to start implementation`
   - TO: `1. Proceed to `/dc:code [phase]` to start implementation`

---

### Step 5: design/SKILL.md

**File**: `.claude/skills/design/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: design`
   - TO: `name: dc:design`

2. Update internal references (lines ~98-100, "Next Steps" section):
   - FROM: `1. Proceed to `/validate-spec` to verify document consistency`
   - TO: `1. Proceed to `/dc:validate-spec` to verify document consistency`
   - FROM: `2. Then `/code [phase]` to start implementation`
   - TO: `2. Then `/dc:code [phase]` to start implementation`

---

### Step 6: code/SKILL.md

**File**: `.claude/skills/code/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: code`
   - TO: `name: dc:code`

2. Update internal references (line ~188, "Next Steps" section):
   - FROM: `1. If more phases: `/code [next-phase]``
   - TO: `1. If more phases: `/dc:code [next-phase]``
   - FROM: `2. If parallel phases done: `/code {k}.5` for merge`
   - TO: `2. If parallel phases done: `/dc:code {k}.5` for merge`
   - FROM: `3. If all phases done: `/merge-main` → `/tagging``
   - TO: `3. If all phases done: `/dc:merge-main` → `/dc:tagging``

---

### Step 7: start-new/SKILL.md

**File**: `.claude/skills/start-new/SKILL.md`

**Actions**:
1. Change frontmatter `name` field:
   - FROM: `name: start-new`
   - TO: `name: dc:start-new`

2. Update internal reference (line ~531, Final Summary Report section):
   - FROM: `3. (Optional) Create tag: `/tagging``
   - TO: `3. (Optional) Create tag: `/dc:tagging``

3. **NEW**: Add Target Version Question step (Step 2.6) to workflow:
   - After Step 2 item 5 (Analysis phase), before SPEC.md drafting
   - Add AskUserQuestion for target version selection
   - Include target_version in SPEC.md header

---

### Step 8: README.md

**File**: `README.md` (project root)

**Actions**:

1. **Skills (Commands) table** (lines ~100-114):
   Update all command names in the table:
   - `/start-new` -> `/dc:start-new`
   - `/init-feature` -> `/dc:init-feature` (Note: if exists)
   - `/init-bugfix` -> `/dc:init-bugfix` (Note: if exists)
   - `/init-refactor` -> `/dc:init-refactor` (Note: if exists)
   - `/design` -> `/dc:design`
   - `/validate-spec` -> `/dc:validate-spec`
   - `/code [phase]` -> `/dc:code [phase]`
   - `/code all` -> `/dc:code all`
   - `/merge-main` -> `/dc:merge-main`
   - `/tagging` -> `/dc:tagging`

2. **Usage - Start New Work section** (lines ~180-194):
   - FROM: `/start-new`
   - TO: `/dc:start-new`
   - FROM: `/tagging`
   - TO: `/dc:tagging`

3. **Manual Execution section** (lines ~199-210):
   Update all command references:
   - `/init-feature` -> `/dc:init-feature`
   - `/init-bugfix` -> `/dc:init-bugfix`
   - `/init-refactor` -> `/dc:init-refactor`
   - `/design` -> `/dc:design`
   - `/validate-spec` -> `/dc:validate-spec`
   - `/code 1` -> `/dc:code 1`
   - `/code all` -> `/dc:code all`
   - `/merge-main` -> `/dc:merge-main`
   - `/tagging` -> `/dc:tagging`

---

## Completion Checklist

### SKILL.md Files

- [ ] Add frontmatter to `update-docs/SKILL.md` with `name: dc:update-docs`
- [ ] Change `tagging/SKILL.md` name field to `dc:tagging`
- [ ] Change `merge-main/SKILL.md` name field to `dc:merge-main`
- [ ] Change `validate-spec/SKILL.md` name field to `dc:validate-spec`
- [ ] Update `validate-spec/SKILL.md` reference: `/code` -> `/dc:code`
- [ ] Change `design/SKILL.md` name field to `dc:design`
- [ ] Update `design/SKILL.md` references: `/validate-spec`, `/code` -> prefixed versions
- [ ] Change `code/SKILL.md` name field to `dc:code`
- [ ] Update `code/SKILL.md` references: `/code`, `/merge-main`, `/tagging` -> prefixed versions
- [ ] Change `start-new/SKILL.md` name field to `dc:start-new`
- [ ] Update `start-new/SKILL.md` reference: `/tagging` -> `/dc:tagging`

### README.md

- [ ] Update Skills (Commands) table with dc: prefix
- [ ] Update Usage - Start New Work section with dc: prefix
- [ ] Update Manual Execution section with dc: prefix

### Verification

- [ ] All 7 SKILL.md files have `name: dc:{skill}` in frontmatter
- [ ] All internal skill references use dc: prefix

## Notes

- Directory names remain unchanged (e.g., `.claude/skills/start-new/` stays as-is)
- Only the `name` field in SKILL.md frontmatter determines the actual command name
- Historical documents (CHANGELOG.md, claude_works/ archives) are NOT modified
- This is a pure refactoring - no functional behavior changes
