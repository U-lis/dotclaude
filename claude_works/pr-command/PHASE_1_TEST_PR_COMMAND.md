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

## Content Validation: Issue Linking (FR-6)

- [ ] T-37: PR Body section mentions `Resolves #N` or `GitHub Issue Number`
- [ ] T-38: Workflow or PR Body section describes reading `GitHub Issue Number` from SPEC.md metadata
- [ ] T-39: Edge cases table covers scenario when SPEC.md has no `GitHub Issue Number` (skip, no error)

## Content Validation: Milestone Assignment (FR-7)

- [ ] T-40: File contains a `## Milestone` section or equivalent milestone documentation
- [ ] T-41: Milestone section describes reading `Target Version` from SPEC.md
- [ ] T-42: Milestone section includes `gh api` command for checking existing milestones
- [ ] T-43: Milestone section includes `gh api` command for creating a new milestone
- [ ] T-44: Milestone section specifies graceful degradation on failure (warn, continue)
- [ ] T-45: Workflow includes `--milestone` flag in `gh pr create`

## Content Validation: Label Assignment (FR-8)

- [ ] T-46: File contains a `## Label` section or equivalent label documentation
- [ ] T-47: Label section documents branch prefix mapping: `feature/` → `enhancement`
- [ ] T-48: Label section documents branch prefix mapping: `bugfix/` → `bug`
- [ ] T-49: Label section documents branch prefix mapping: `refactor/` → `refactoring`
- [ ] T-50: Label section includes `gh label list` or `gh label create` command
- [ ] T-51: Label section specifies graceful degradation on failure (warn, continue)
- [ ] T-52: Workflow includes `--label` flag in `gh pr create`

## Content Validation: Edge Cases

- [ ] T-53: Edge cases table contains at least 11 rows
- [ ] T-54: Edge case 1 covers running on main/master/base_branch
- [ ] T-55: Edge case 2 covers no remote configured
- [ ] T-56: Edge case 3 covers push failure
- [ ] T-57: Edge case 4 covers PR already exists
- [ ] T-58: Edge case 5 covers gh CLI not installed
- [ ] T-59: Edge case 6 covers gh not authenticated
- [ ] T-60: Edge case 7 covers SPEC.md missing GitHub Issue Number
- [ ] T-61: Edge case 8 covers SPEC.md missing Target Version
- [ ] T-62: Edge case 9 covers milestone creation failure
- [ ] T-63: Edge case 10 covers label creation failure
- [ ] T-64: Edge case 11 covers unknown branch prefix

## Content Validation: Safety

- [ ] T-65: Safety section prohibits force push (`--force` or `-f`)
- [ ] T-66: Safety section mentions read-only validation (no state modification during checks)

## Content Validation: Output

- [ ] T-67: Output section contains a code block with PR creation result format
- [ ] T-68: Output format includes Branch, Target, Title, Label, Milestone, Issue, and URL fields
- [ ] T-69: Output section contains a variant for "PR already exists" scenario
- [ ] T-70: Output style is consistent with `commands/merge-main.md` output format (heading + bullet list + next step)

## Integration Validation: README.md

### Prerequisites Documentation

- [ ] T-71: README.md contains a reference to GitHub CLI (`gh`) as a prerequisite
- [ ] T-72: README.md includes the installation URL `https://cli.github.com/` or equivalent link
- [ ] T-73: README.md mentions `gh auth login` for authentication setup

### Skills Table

- [ ] T-74: README.md Skills table contains a row for `/dotclaude:pr`
- [ ] T-75: The `/dotclaude:pr` row has a description mentioning PR creation
- [ ] T-76: The `/dotclaude:pr` row is positioned near other git-related commands (`merge-main`, `tagging`)

### Directory Structure

- [ ] T-77: README.md directory structure listing includes `pr.md` under `commands/`
- [ ] T-78: The `pr.md` entry includes a comment referencing `/dotclaude:pr`

## Negative Validation: No Unintended Changes

- [ ] T-79: `plugin.json` version field is unchanged from before implementation
- [ ] T-80: `marketplace.json` version field is unchanged from before implementation
- [ ] T-81: No files outside `commands/pr.md` and `README.md` were created or modified

## Pattern Consistency Validation

- [ ] T-82: `commands/pr.md` frontmatter format matches `commands/merge-main.md` frontmatter format (only `description` field)
- [ ] T-83: Output block style in `commands/pr.md` matches the style used in `commands/merge-main.md` and `commands/tagging.md`
- [ ] T-84: Safety section phrasing follows conventions from `commands/merge-main.md`
- [ ] T-85: Config loading documentation references the same sources as `commands/start-new.md` (SPEC.md metadata, dotclaude-config.json, defaults)

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
grep -q "Resolves" commands/pr.md && echo "PASS: Issue linking" || echo "FAIL: Issue linking"
grep -q "milestone" commands/pr.md && echo "PASS: Milestone" || echo "FAIL: Milestone"
grep -q "label" commands/pr.md && echo "PASS: Label" || echo "FAIL: Label"
grep -q "gh label" commands/pr.md && echo "PASS: Label create" || echo "FAIL: Label create"
grep -q "gh api.*milestones" commands/pr.md && echo "PASS: Milestone API" || echo "FAIL: Milestone API"
```

### Step 5: README Integration
```bash
grep -q "dotclaude:pr" README.md && echo "PASS" || echo "FAIL"
grep -q "gh" README.md && echo "PASS" || echo "FAIL"
grep -q "pr.md" README.md && echo "PASS" || echo "FAIL"
```

### Step 6: FR-6/7/8 Content Checks
```bash
# Issue linking
grep -c "Resolves #" commands/pr.md
# Expected: at least 1 mention

# Milestone
grep -c "## Milestone" commands/pr.md
# Expected: 1

# Label
grep -c "## Label" commands/pr.md
# Expected: 1

# Edge cases count
grep -c "^| [0-9]" commands/pr.md
# Expected: 11
```

### Step 7: No Unintended Changes
```bash
git diff --name-only
# Expected output should ONLY contain:
#   commands/pr.md (modified)
#   README.md (modified)
# No other files should appear (version files untouched)
```
