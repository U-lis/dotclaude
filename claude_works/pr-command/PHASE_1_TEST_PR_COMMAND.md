# Phase 1: Test Cases

## Test Coverage Target

>= 70%

Since `commands/pr.md` is a markdown command definition (not executable code), validation is structural and behavioral rather than unit-test-based. The test cases below verify file structure, content completeness, and README integration.

## Structural Validation: `commands/pr.md`

### Frontmatter

- [ ] T-1: File starts with `---` YAML frontmatter delimiter
- [ ] T-2: Frontmatter contains `description` field with non-empty string value
- [ ] T-3: Frontmatter does NOT contain `user-invocable: false` (command must be user-invocable)
- [ ] T-4: Frontmatter closes with `---` delimiter
- [ ] T-5: No extra frontmatter fields beyond `description`

### Required Sections

- [ ] T-6: File contains `# /dotclaude:pr` as the top-level heading (after frontmatter)
- [ ] T-7: File contains `## Prerequisites` section
- [ ] T-8: File contains `## Configuration` section
- [ ] T-9: File contains `## Branch Validation` section
- [ ] T-10: File contains `## Workflow` section
- [ ] T-11: File contains `## PR Title Generation` section (or equivalent subsection within Workflow)
- [ ] T-12: File contains `## PR Body` section (or equivalent subsection within Workflow)
- [ ] T-13: File contains `## Edge Cases` section
- [ ] T-14: File contains `## Safety` section
- [ ] T-15: File contains `## Output` section

## Content Validation: Prerequisites

- [ ] T-16: Prerequisites section mentions `gh --version` or `which gh` for installation check
- [ ] T-17: Prerequisites section mentions `gh auth status` for authentication check
- [ ] T-18: Prerequisites section includes installation URL: `https://cli.github.com/`
- [ ] T-19: Prerequisites section includes instruction to run `gh auth login` if not authenticated
- [ ] T-20: Prerequisites checks are ordered BEFORE any git operations in the workflow

## Content Validation: Configuration

- [ ] T-21: Configuration section documents SPEC.md metadata as the first priority source
- [ ] T-22: Configuration section documents `dotclaude-config.json` as fallback
- [ ] T-23: Configuration section documents `main` as the final default value
- [ ] T-24: Configuration section includes the `<!-- dotclaude-config -->` metadata block format

## Content Validation: Branch Validation

- [ ] T-25: Branch validation lists `main` as a rejected branch
- [ ] T-26: Branch validation lists `master` as a rejected branch
- [ ] T-27: Branch validation lists the configured `base_branch` as a rejected branch
- [ ] T-28: Branch validation specifies an error message for rejected branches

## Content Validation: Workflow

- [ ] T-29: Workflow contains numbered steps (at least 6 steps)
- [ ] T-30: Workflow includes `git branch --show-current` or equivalent to get current branch
- [ ] T-31: Workflow includes `git remote -v` or equivalent to check remote exists
- [ ] T-32: Workflow includes `git push -u origin {branch}` for pushing
- [ ] T-33: Workflow includes `gh pr view --json url` (or similar) for existing PR detection
- [ ] T-34: Workflow includes `gh pr create` with `--base`, `--title`, and `--body` flags
- [ ] T-35: Workflow includes `git log` command for commit history
- [ ] T-36: Workflow includes `git diff --stat` command for file change summary

## Content Validation: Edge Cases

- [ ] T-37: Edge cases table contains at least 6 rows
- [ ] T-38: Edge case 1 covers running on main/master/base_branch
- [ ] T-39: Edge case 2 covers no remote configured
- [ ] T-40: Edge case 3 covers push failure
- [ ] T-41: Edge case 4 covers PR already exists
- [ ] T-42: Edge case 5 covers gh CLI not installed
- [ ] T-43: Edge case 6 covers gh not authenticated

## Content Validation: Safety

- [ ] T-44: Safety section prohibits force push (`--force` or `-f`)
- [ ] T-45: Safety section mentions read-only validation (no state modification during checks)

## Content Validation: Output

- [ ] T-46: Output section contains a code block with PR creation result format
- [ ] T-47: Output format includes Branch, Target, Title, and URL fields
- [ ] T-48: Output section contains a variant for "PR already exists" scenario
- [ ] T-49: Output style is consistent with `commands/merge-main.md` output format (heading + bullet list + next step)

## Integration Validation: README.md

### Prerequisites Documentation

- [ ] T-50: README.md contains a reference to GitHub CLI (`gh`) as a prerequisite
- [ ] T-51: README.md includes the installation URL `https://cli.github.com/` or equivalent link
- [ ] T-52: README.md mentions `gh auth login` for authentication setup

### Skills Table

- [ ] T-53: README.md Skills table contains a row for `/dotclaude:pr`
- [ ] T-54: The `/dotclaude:pr` row has a description mentioning PR creation
- [ ] T-55: The `/dotclaude:pr` row is positioned near other git-related commands (`merge-main`, `tagging`)

### Directory Structure

- [ ] T-56: README.md directory structure listing includes `pr.md` under `commands/`
- [ ] T-57: The `pr.md` entry includes a comment referencing `/dotclaude:pr`

## Negative Validation: No Unintended Changes

- [ ] T-58: `plugin.json` version field is unchanged from before implementation
- [ ] T-59: `marketplace.json` version field is unchanged from before implementation
- [ ] T-60: `CHANGELOG.md` has no new entries added during this phase
- [ ] T-61: No files outside `commands/pr.md` and `README.md` were created or modified

## Pattern Consistency Validation

- [ ] T-62: `commands/pr.md` frontmatter format matches `commands/merge-main.md` frontmatter format (only `description` field)
- [ ] T-63: Output block style in `commands/pr.md` matches the style used in `commands/merge-main.md` and `commands/tagging.md`
- [ ] T-64: Safety section phrasing follows conventions from `commands/merge-main.md`
- [ ] T-65: Config loading documentation references the same sources as `commands/start-new.md` (SPEC.md metadata, dotclaude-config.json, defaults)

## Validation Procedure

To validate Phase 1 completion, run the following checks in order:

### Step 1: File Existence
```bash
test -f commands/pr.md && echo "PASS: pr.md exists" || echo "FAIL: pr.md missing"
```

### Step 2: Frontmatter Check
```bash
head -4 commands/pr.md
# Expected: --- / description: ... / ---
```

### Step 3: Section Check
```bash
grep -c "^## " commands/pr.md
# Expected: at least 7 sections (Prerequisites, Configuration, Branch Validation, Workflow, Edge Cases, Safety, Output)
```

### Step 4: Key Commands Present
```bash
grep -q "gh auth status" commands/pr.md && echo "PASS" || echo "FAIL"
grep -q "gh pr view" commands/pr.md && echo "PASS" || echo "FAIL"
grep -q "gh pr create" commands/pr.md && echo "PASS" || echo "FAIL"
grep -q "git push" commands/pr.md && echo "PASS" || echo "FAIL"
grep -q "git log" commands/pr.md && echo "PASS" || echo "FAIL"
grep -q "git diff --stat" commands/pr.md && echo "PASS" || echo "FAIL"
```

### Step 5: README Integration
```bash
grep -q "dotclaude:pr" README.md && echo "PASS" || echo "FAIL"
grep -q "gh" README.md && echo "PASS" || echo "FAIL"
grep -q "pr.md" README.md && echo "PASS" || echo "FAIL"
```

### Step 6: No Unintended Changes
```bash
git diff --name-only
# Expected output should ONLY contain:
#   commands/pr.md (new file)
#   README.md (modified)
# No other files should appear
```
