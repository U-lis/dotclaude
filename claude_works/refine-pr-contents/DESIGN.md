# Refine PR Contents - Design Document

## Overview

Refine the `/dotclaude:pr` command to generate structured, context-rich PR body content by extracting information from design documents (SPEC.md, GLOBAL.md, PHASE_*_TEST.md, PHASE_*_PLAN.md) with graceful fallback to git-based generation. Single file modification: `commands/pr.md`.

## Architecture Decisions

### AD-1: Layered Template with Graceful Fallback

- **Decision**: Use a 2-tier data extraction strategy (design docs -> git-based fallback)
- **Rationale**: Projects using the dotclaude workflow get rich PR content from SPEC/GLOBAL/PHASE docs; projects without get a structured but git-derived PR body. No breaking changes for existing users.

### AD-2: Match Existing Merged PR Pattern

- **Decision**: Align template with the pattern already established in merged PRs #34-#38 (Summary -> Resolves -> Changes -> Test plan -> Attribution)
- **Rationale**: Consistency with existing repository convention. Reviewers already expect this structure.

### AD-3: Document Discovery via Working Directory

- **Decision**: Discover design documents by resolving `working_directory` from SPEC.md metadata or config, then scanning for GLOBAL.md and PHASE_*_TEST/PLAN files
- **Rationale**: Reuses the existing config resolution chain already implemented in pr.md for `base_branch`

### AD-4: Summary Generation Strategy

- **Decision**: Extract Overview from SPEC.md, supplement with GLOBAL.md Feature Overview if available, fall back to commit message summarization
- **Rationale**: SPEC.md Overview is the most concise source; GLOBAL.md adds architectural context; commits are always available

### AD-5: Changes Section Strategy

- **Decision**: Generate file-level change descriptions using commit messages grouped by file path, enriched with PHASE_*_PLAN context when available
- **Rationale**: Provides meaningful per-file descriptions rather than raw diff stats

### AD-6: Test Plan Generation

- **Decision**: Extract test checklists from PHASE_*_TEST.md files when available, otherwise generate minimal test items from commit scope
- **Rationale**: The design workflow already produces test plans; reuse them instead of inventing new ones

## File Structure

| Action | File | Details |
|--------|------|---------|
| MODIFY | `commands/pr.md` | Primary and only file to change |

### Sections to Modify in `commands/pr.md`

| Section | Current Lines | Change Type |
|---------|---------------|-------------|
| Workflow step 9 | Lines 53-56 | Update: add document detection and extraction substeps (9a-9g) |
| PR Body | Lines 78-101 | Replace: new structured template with fallback chain |
| (new section) | After Configuration | Add: "Document Detection" section |
| Edge Cases | Lines 131-145 | Update: add new edge cases for document detection |

## Document Detection

Add a new section to `commands/pr.md` after the "Configuration" section (after line 28) describing how to find and read design documents.

### Detection Logic

1. Resolve `working_directory` using the same priority chain as `base_branch`:
   - SPEC.md metadata block: `working_directory: {value}`
   - `dotclaude-config.json` (local, then global)
   - Default: `.dc_workspace`
2. Scan `{working_directory}/` for SPEC.md
3. If SPEC.md found, scan the same directory for:
   - GLOBAL.md
   - PHASE_*_TEST.md (glob pattern)
   - PHASE_*_PLAN.md (glob pattern)
4. Each document is optional. Missing documents trigger the fallback path for their respective PR body section.

### Section Content

The new "Document Detection" section in `commands/pr.md` must instruct the agent to:

- Resolve the working directory path from config (same chain as `base_branch`)
- Check if SPEC.md exists at `{working_directory}/SPEC.md` (relative to project root)
- If SPEC.md exists, also check for GLOBAL.md, PHASE_*_TEST.md, and PHASE_*_PLAN.md in the same directory
- Store which documents are available for use in PR body generation
- If no documents exist, proceed with git-based fallback for all sections

## Workflow Step 9 Update

Replace current step 9 (lines 53-56) with expanded substeps:

```
9. Generate PR body:
   a. Detect design documents (see Document Detection section)
   b. Generate Summary:
      - If SPEC.md exists: extract Overview section content as bullet points
      - If GLOBAL.md exists: supplement with Feature Overview (Purpose/Problem/Solution)
      - Fallback: summarize commit messages from git log {base_branch}..HEAD --oneline, grouped by type/area
   c. Generate issue link:
      - If SPEC.md has GitHub Issue Number: prepare "Resolves #N" line
   d. Generate Changes:
      - Run git diff --stat {base_branch}...HEAD to get list of changed files
      - For each changed file, generate a description:
        - If PHASE_*_PLAN.md exists: derive description from plan instructions mentioning the file
        - Fallback: derive description from commit messages that touch the file (git log {base_branch}..HEAD -- {file_path} --oneline)
      - Format as markdown list: - `{file_path}`: {description}
   e. Generate Test plan:
      - If PHASE_*_TEST.md files exist: extract checkbox items from Unit Tests, Integration Tests, Edge Cases sections
      - If multiple PHASE_*_TEST.md files exist: aggregate items from all files
      - Fallback: generate minimal test items:
        - "Verify {primary change} works correctly"
        - "Verify no regressions in {affected area}"
   f. Append attribution footer
   g. Assemble final PR body from sections (Summary -> Resolves -> Changes -> Test plan -> Attribution)
```

## PR Body Template

### Primary Template (design docs available)

Replace the PR Body section (lines 78-101) with this structured template:

```markdown
## Summary
- {bullet point from SPEC.md Overview}
- {bullet point from SPEC.md Overview}
- {supplementary point from GLOBAL.md Feature Overview, if available}

Resolves #{N}

## Changes
- `{file_path_1}`: {description derived from PHASE_*_PLAN or commit messages}
- `{file_path_2}`: {description derived from PHASE_*_PLAN or commit messages}

## Test plan
- [ ] {test item from PHASE_*_TEST.md}
- [ ] {test item from PHASE_*_TEST.md}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Fallback Template (no design docs)

When no SPEC.md, GLOBAL.md, or PHASE_* documents exist:

```markdown
## Summary
- {summarized from commit messages, grouped by type/area}

Resolves #{N}

## Changes
- `{file_path}`: {derived from commit messages touching this file}

## Test plan
- [ ] Verify {primary change works}
- [ ] Verify no regressions in {affected area}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Template Rules

- `Resolves #N` line: include ONLY when SPEC.md contains `GitHub Issue Number` metadata. Omit entirely otherwise.
- Summary: limit to 1-5 bullet points. If source material is longer, condense.
- Changes: list only files that appear in `git diff --stat`. Do not list files that were not modified.
- Test plan: minimum 2 items, maximum 10 items. Prioritize most important test cases if source has more.
- Attribution footer: always present, always the last line.

## Data Extraction Details

### From SPEC.md

| Field | Location | Used In |
|-------|----------|---------|
| Overview | `## Overview` section body text | Summary section |
| GitHub Issue Number | Metadata block (`GitHub Issue Number: #N`) | Resolves line |
| working_directory | Config comment block | Document discovery path |

### From GLOBAL.md

| Field | Location | Used In |
|-------|----------|---------|
| Feature Overview | `## Feature Overview` section (Purpose, Problem, Solution) | Summary section (supplementary) |
| Architecture Decisions | `## Architecture Decision` section | Not directly used in PR body (available for future enhancement) |

### From PHASE_*_PLAN.md

| Field | Location | Used In |
|-------|----------|---------|
| Instructions | `## Instructions` section | Changes section (file-level descriptions) |
| Objective | `## Objective` section | Changes section (context for descriptions) |

### From PHASE_*_TEST.md

| Field | Location | Used In |
|-------|----------|---------|
| Unit Tests | `## Unit Tests` section checkboxes | Test plan section |
| Integration Tests | `## Integration Tests` section checkboxes | Test plan section |
| Edge Cases | `## Edge Cases` section checkboxes | Test plan section |

## Edge Cases

All existing edge cases in pr.md (cases 1-11) remain unchanged. Add the following edge cases to the table:

| # | Case | Expected Behavior |
|---|------|-------------------|
| 12 | No SPEC.md exists (manual PR outside dotclaude workflow) | Fall back to git log-based Summary and Changes; skip Test plan or generate minimal plan |
| 13 | No GLOBAL.md exists (design step skipped) | Skip supplementary context in Summary; use SPEC.md or commits only |
| 14 | No PHASE_*_TEST.md exists | Generate minimal Test plan from implementation scope (2 generic items) |
| 15 | SPEC.md exists but has no Overview section | Fall back to git log for Summary |
| 16 | Multiple PHASE_*_TEST.md files exist | Aggregate test items from all test files, deduplicate |
| 17 | Empty commit log (no commits ahead of base) | Show "No changes detected" in Summary; empty Changes table |
| 18 | Very long commit history (50+ commits) | Summarize by grouping related changes; limit Summary to 5 bullet points |
| 19 | SPEC.md has working_directory but directory does not exist | Treat as no design docs; use git-based fallback |

## Backward Compatibility

The following behaviors MUST remain unchanged:

- PR Title generation logic (lines 68-75)
- Label assignment logic (lines 116-129)
- Milestone assignment logic (lines 102-112)
- Safety rules (lines 149-151)
- Output format (lines 153-178)
- Prerequisites and branch validation
- Configuration resolution for `base_branch`

The only user-visible change is the PR body content structure.

## Completion Checklist

- [ ] Add "Document Detection" section to pr.md describing how to find and read SPEC.md, GLOBAL.md, PHASE_*_TEST.md, PHASE_*_PLAN.md
- [ ] Update workflow step 9 to include document discovery substeps (9a through 9g)
- [ ] Replace PR Body section template with structured format: Summary -> Resolves -> Changes -> Test plan -> Attribution
- [ ] Define Summary generation logic with fallback chain: SPEC.md Overview -> GLOBAL.md Feature Overview -> commit-based summary
- [ ] Define Changes generation logic with fallback: file-level descriptions from commits + PHASE_*_PLAN context -> commit-grouped descriptions
- [ ] Define Test plan generation logic with fallback: PHASE_*_TEST.md extraction -> minimal scope-based items
- [ ] Add attribution footer line to template
- [ ] Add edge cases 12-19 to Edge Cases table
- [ ] Verify backward compatibility: PR body generates correctly without any design documents
- [ ] Update the markdown template example in PR Body section to show the new structure
- [ ] Verify Resolves #N position is after Summary (matching existing PR pattern from #34-#38)
- [ ] Verify no changes to PR Title, Label, Milestone, or Safety sections
