# Phase 1: Branching Strategy

## Objective

Replace hardcoded `main` references in git commands with the configurable `{base_branch}` value, and insert an explicit checkout+pull of `{base_branch}` before every new branch creation across all three affected command files.

## Prerequisites

- SPEC.md approved and committed
- DESIGN.md created
- Access to the three target files: `commands/start-new.md`, `commands/merge-main.md`, `commands/init-github-issue.md`

## Instructions

### File 1: `commands/start-new.md`

#### Change 1A: Insert base_branch checkout+pull before branch creation

**Location**: Line ~85, inside the "Execute ALL steps defined in the loaded init file" numbered list.

**Current content** (items 2-4):
```
2. Auto-generate branch keyword
3. Create work branch: `git checkout -b {type}/{keyword}`
4. Create project directory: `mkdir -p {working_directory}/{subject}`
```

**Required change**: Insert a new step 3 for checking out and pulling the base branch. Renumber subsequent items (old 3 becomes 4, old 4 becomes 5, and so on through old 8 which becomes 9).

**New content** (items 2-5):
```
2. Auto-generate branch keyword
3. Checkout and update base branch: `git checkout {base_branch} && git pull origin {base_branch}`
4. Create work branch: `git checkout -b {type}/{keyword}`
5. Create project directory: `mkdir -p {working_directory}/{subject}`
```

All subsequent items in the same numbered list must be incremented by 1.

#### Change 1B: Replace hardcoded `main` in merge step

**Location**: Lines ~283-284, inside the "Step 12: Merge to Main" code block.

**Current content**:
```bash
git checkout main
git pull origin main
```

**Required change**: Replace both occurrences of `main` with `{base_branch}`.

**New content**:
```bash
git checkout {base_branch}
git pull origin {base_branch}
```

---

### File 2: `commands/merge-main.md`

#### Change 2A: Replace `main` in checkout+pull workflow step

**Location**: Line ~19, inside the Workflow code block, step 2.

**Current content**:
```
2. git checkout main && git pull origin main
```

**Required change**: Replace both occurrences of `main` with `{base_branch}`.

**New content**:
```
2. git checkout {base_branch} && git pull origin {base_branch}
```

#### Change 2B: Replace `main` in safety instruction

**Location**: Line ~47, inside the Safety section.

**Current content**:
```
- Never commit directly to main (only merge)
```

**Required change**: Replace `main` with `{base_branch}`.

**New content**:
```
- Never commit directly to {base_branch} (only merge)
```

#### Change 2C: Replace `main` in output template

**Location**: Line ~57, inside the Output code block.

**Current content**:
```
- Merged to: main
```

**Required change**: Replace `main` with `{base_branch}`.

**New content**:
```
- Merged to: {base_branch}
```

#### Change 2D: Replace `main` in git push command

**Location**: Line ~62, inside the Output code block.

**Current content**:
```
Next: git push origin main
```

**Required change**: Replace `main` with `{base_branch}`.

**New content**:
```
Next: git push origin {base_branch}
```

---

### File 3: `commands/init-github-issue.md`

#### Change 3A: Insert base_branch checkout+pull before branch creation

**Location**: Line ~155, inside the "Init File Behavior with Pre-filled Context" section, item 1 "Branch Creation".

**Current content**:
```
1. **Branch Creation**: Use pre-filled `branch_keyword`
   - Create: `git checkout -b {work_type}/{branch_keyword}`
```

**Required change**: Insert a checkout+pull step before the branch creation command.

**New content**:
```
1. **Branch Creation**: Use pre-filled `branch_keyword`
   - Update base branch: `git checkout {base_branch} && git pull origin {base_branch}`
   - Create: `git checkout -b {work_type}/{branch_keyword}`
```

---

### Verification Step

After all edits, scan all three files for any remaining hardcoded `main` in git commands that should use `{base_branch}`. The following occurrences of `main` are EXPECTED to remain (they are descriptive prose or branch-type references, not executable git commands):

- `commands/start-new.md`: "Current branch must NOT be main/master" (checkpoint validation prose)
- `commands/merge-main.md`: "Never force push" (general safety guideline, no branch reference)

Any other `main` inside backtick-quoted git commands (`git checkout main`, `git pull origin main`, `git push origin main`, `git merge ... main`) must be replaced with `{base_branch}`.

## Completion Checklist

- [ ] CL-1: `commands/start-new.md` -- Inserted `git checkout {base_branch} && git pull origin {base_branch}` step before branch creation (line ~85 area); renumbered subsequent steps (items 4-8 became 5-9)
- [ ] CL-2: `commands/start-new.md` -- Replaced hardcoded `main` with `{base_branch}` in merge step (lines ~283-284)
- [ ] CL-3: `commands/merge-main.md` -- Replaced `main` with `{base_branch}` in checkout+pull command (line ~19)
- [ ] CL-4: `commands/merge-main.md` -- Replaced `main` with `{base_branch}` in safety instruction (line ~47), output template (line ~57), and git push command (line ~62)
- [ ] CL-5: `commands/init-github-issue.md` -- Inserted `git checkout {base_branch} && git pull origin {base_branch}` before branch creation (line ~155)
- [ ] CL-6: Verified no other hardcoded `main` remains in git commands across all three files (prose references to main/master are acceptable)
- [ ] CL-7: Verified markdown formatting is preserved (no broken code blocks, lists, or tables)

## Notes

- The `{base_branch}` placeholder is resolved at runtime from the SPEC.md metadata block or dotclaude-config.json. The default value is `"main"`, so existing workflows that do not override `base_branch` will continue to behave identically.
- Edge-case handling (dirty working tree, offline pull failure, missing local branch) is NOT added as inline instructions. Claude handles these git errors at runtime through standard error handling. See AD-4 in DESIGN.md.
- The `commands/merge-main.md` filename itself is NOT renamed. The filename is a command identifier, not a branch reference. Renaming it would break plugin routing.
