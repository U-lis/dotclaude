<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-refine-pr-contents
-->

# Refine PR Contents - Specification

**Target Version**: 0.3.1
**Source Issue**: https://github.com/U-lis/dotclaude/issues/43
**GitHub Issue Number**: #43

## Overview

The `/dotclaude:pr` command currently generates PR body content that is a simple enumeration of commit messages and file diff stats. This makes it difficult for reviewers and users to understand the actual work done. The PR body template must be refined to produce structured, context-rich content that enables reviewers to quickly understand the purpose, changes, and testing scope of the PR.

## User-Reported Information

### Bug Description (Symptoms)

- PR body is a simple listing of file change history (commit log + diff stat)
- Reviewers/users cannot grasp the work content from the current PR body
- Need a PR template that enables understanding of what was done

### Reproduction Steps

1. Run `/dotclaude:pr` on any working branch
2. The generated PR body shows only:
   - `## Changes` with commit messages listed
   - `## Files Changed` with git diff --stat output
   - Optional `Resolves #N`
3. Missing: Summary of what was done, why, what changed per file, test plan

### Expected Cause

The `commands/pr.md` file's PR Body section (lines 78-101) defines a minimal template with only commit log, diff stat, and issue link. No mechanism exists to extract contextual information from SPEC.md, GLOBAL.md, or other design documents.

### Severity

Minor - PR creation itself works, but the content quality is insufficient for effective code review.

### Related Files

| # | File | Role | Details |
|---|------|------|---------|
| 1 | `commands/pr.md` | Primary | PR body generation logic, lines 78-101 (PR Body section) and lines 53-56 (workflow step 9) |
| 2 | `commands/start-new.md` | Secondary | Step 12 "Create PR" routing (lines 291-310), invokes `/dotclaude:pr` |

### Impact Scope

- `/dotclaude:pr` command is directly affected
- `start-new.md` Step 12 "Create PR" path is also affected (it invokes `/dotclaude:pr`)

## AI Analysis Results

### Root Cause Analysis

- **Exact location**: `commands/pr.md` lines 78-101 (PR Body section)
- **Why the bug occurs**: The PR body template only uses 3 data sources (`git log`, `git diff --stat`, SPEC.md issue number) while ignoring rich contextual data available in the working directory
- **Available but unused data sources**:
  1. SPEC.md - Overview, Functional Requirements, analysis results
  2. GLOBAL.md - Feature Overview (Purpose/Problem/Solution), Architecture Decisions, Phase Overview
  3. PHASE_*_PLAN.md - Phase objectives, completion checklists
  4. PHASE_*_TEST.md - Test case checklists
  5. Existing repo PR patterns - well-structured Summary, Changes table, Test plan (visible in PRs #34-#38)

### Existing PR Pattern (from merged PRs)

The repository already uses a consistent PR body pattern in merged PRs (#34-#38):

```markdown
## Summary
- Bullet point 1 describing a change
- Bullet point 2 describing another change

Resolves #N

## Changes
- `file1.md`: Description of change
- `file2.md`: Description of change

## Test plan
- [ ] Test item 1
- [ ] Test item 2

(attribution line)
```

The current `commands/pr.md` template does NOT produce this format. It produces a raw commit log and diff stat instead.

### Affected Code Locations

| # | File | Section | Relationship |
|---|------|---------|--------------|
| 1 | `commands/pr.md` | PR Body (lines 78-101) | Primary: template definition needs restructuring |
| 2 | `commands/pr.md` | Workflow step 9 (lines 53-56) | Primary: body generation logic needs updating |
| 3 | `commands/start-new.md` | Step 12 routing (lines 291-310) | Secondary: no change needed if pr.md handles context internally |

### Fix Strategy

1. **Define a structured PR body template** aligned with the pattern already used in merged PRs (#34-#38):
   - `## Summary` - Extract from SPEC.md Overview or GLOBAL.md Feature Overview; present as concise bullet points
   - `Resolves #N` / `Closes #N` - Keep existing issue link behavior, placed after Summary
   - `## Changes` - File-level change descriptions (File | Change description) instead of raw `git diff --stat`; fall back to commit-grouped changes if design docs unavailable
   - `## Test plan` - Extract from PHASE_*_TEST.md checklists or generate from implementation scope
   - Attribution line - Claude Code footer

2. **Add contextual data extraction logic** to pr.md workflow step 9:
   - Detect working_directory from SPEC.md metadata or config
   - If SPEC.md exists: extract Overview section for Summary
   - If GLOBAL.md exists: extract Architecture Decisions for additional context
   - If PHASE_*_TEST.md or PHASE_*_PLAN.md exist: extract test checklist items for Test plan
   - Graceful fallback: if no design docs exist, fall back to current git-based generation with the new template structure

3. **Maintain backward compatibility**:
   - PR body generation must work even without SPEC/GLOBAL/PLAN files
   - Fallback: git log-based Summary + commit-grouped Changes + minimal Test plan

### Conflict Analysis

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | PR body uses raw `git log --oneline` under `## Changes` | PR body uses structured `## Summary` from design docs, `## Changes` as file-level descriptions | Use design docs when available, fall back to git log |
| 2 | `git diff --stat` shown as-is under `## Files Changed` | File changes shown as descriptive list under `## Changes` | Generate descriptions from commits + diff, keep stat as internal reference only |
| 3 | No `## Test plan` section | `## Test plan` section with checkboxes | Extract from PHASE_*_TEST.md or generate minimal plan |
| 4 | No attribution footer | Claude Code attribution line at bottom | Append footer to all generated PR bodies |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | No SPEC.md exists (manual PR) | Fall back to git log-based Summary and Changes |
| 2 | No GLOBAL.md exists (design skipped) | Skip architecture context, use commit messages for Summary |
| 3 | No PHASE_*_TEST.md exists | Skip Test plan section or generate minimal plan from implementation scope |
| 4 | Empty commit log (no commits ahead of base) | Show "No changes detected" message in Summary |
| 5 | Very long commit history (50+ commits) | Summarize commits by grouping related changes |
| 6 | PR created outside dotclaude workflow | Graceful fallback to git-based template with new structure |
| 7 | SPEC.md exists but has no Overview section | Fall back to git log for Summary |
| 8 | Multiple PHASE_*_TEST.md files exist | Aggregate test items from all test files |

## Functional Requirements

- [ ] FR-1: PR body MUST include a `## Summary` section with concise bullet-point description of the work
  - When SPEC.md exists: extract from Overview section
  - When GLOBAL.md exists: supplement with Feature Overview (Purpose/Problem/Solution)
  - Fallback: generate summary from commit messages
- [ ] FR-2: PR body MUST include a `## Changes` section with file-level change descriptions
  - Format: `- \`{file_path}\`: {description of change}`
  - When design docs exist: derive descriptions from PHASE_*_PLAN.md instructions
  - Fallback: derive descriptions from commit messages grouped by file
- [ ] FR-3: PR body MUST include a `## Test plan` section with checkbox items
  - When PHASE_*_TEST.md exists: extract test case checklists
  - Fallback: generate minimal test items from implementation scope
- [ ] FR-4: PR body MUST retain `Resolves #N` / `Closes #N` issue linking behavior
  - Position: after the Summary section (before Changes)
  - Source: SPEC.md `GitHub Issue Number` metadata
- [ ] FR-5: PR body generation MUST gracefully fall back to git-based content when design documents are unavailable
  - All sections (Summary, Changes, Test plan) must have git-based fallback paths
  - No errors or empty sections when design docs are missing
- [ ] FR-6: PR body footer MUST include the Claude Code attribution line
  - Format: `Generated with [Claude Code](https://claude.com/claude-code)` (matching existing repo convention)
- [ ] FR-7: Workflow step 9 in pr.md MUST be updated to include design document detection and extraction logic
- [ ] FR-8: The final PR body template MUST match the structure already used in merged PRs (#34-#38) for consistency

## Non-Functional Requirements

- [ ] NFR-1: PR body generation should not add more than 2 seconds to PR creation time
- [ ] NFR-2: Template must produce readable output regardless of project type or language
- [ ] NFR-3: Generated PR body should be concise - Summary limited to 1-5 bullet points, Changes limited to modified files only

## Constraints

- Must only modify `commands/pr.md` (primary change)
- Must maintain backward compatibility with projects that do not use dotclaude design workflow
- Must not break existing PR creation flow in `start-new.md` Step 12
- Must not modify `commands/start-new.md` unless strictly necessary for context passing
- Must follow the PR body pattern established in existing merged PRs (#34-#38)

## Out of Scope

- PR template customization by users (future feature)
- PR body translation to configured language
- Draft PR support
- Reviewer auto-assignment
- Changes to PR title generation logic
- Changes to label or milestone assignment logic
