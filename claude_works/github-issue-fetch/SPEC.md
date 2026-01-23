# GitHub Issue Fetch - Specification

**Target Version**: 0.0.12
**Source Issue**: https://github.com/U-lis/dotclaude/issues/4

---

## Overview

**Purpose**: Enable automatic workflow initialization from GitHub issues, eliminating redundant manual input when issue details are already documented.

**Problem**: Currently, users must manually re-enter information that already exists in GitHub issues when starting work through `/dc:start-new`. This creates duplication and potential inconsistencies.

**Solution**: Add GitHub issue URL input option at Step 1 of `/dc:start-new` workflow. Parse issue metadata (title, body, labels, milestone) and automatically route to appropriate init workflow with pre-populated information.

---

## Functional Requirements

### Core Features
- [ ] FR-1: Accept GitHub issue URL at Step 1 work type selection (via "Other" option)
- [ ] FR-2: Parse GitHub issue using `gh` CLI (title, body, labels, milestone)
- [ ] FR-3: Auto-select init-xxx based on issue labels:
  - `bug` → init-bugfix
  - `enhancement` → init-feature
  - `refactor` → init-refactor
- [ ] FR-4: Analyze issue body to determine work type when labels are missing or ambiguous
- [ ] FR-5: Auto-set target_version from milestone if present
- [ ] FR-6: Pre-populate init questions from parsed issue content

### Secondary Features (Nice-to-have)
- [ ] FR-7: GitHub issue template for dotclaude-compatible issues
- [ ] FR-8: Auto-create PR after workflow completion (closes #N)

---

## Non-Functional Requirements

### Performance
- [ ] NFR-1: Issue parsing should complete within 5 seconds

### Reliability
- [ ] NFR-2: Graceful fallback to manual workflow on parsing errors
- [ ] NFR-3: Support both issue URLs and issue number format (#N)

---

## Constraints

### Technical Constraints
- Requires `gh` CLI installed and authenticated
- Issue must be accessible (public or authenticated private repo)

### Compatibility
- Must not break existing manual workflow path
- Existing init-xxx question flows remain functional

---

## Out of Scope

The following are explicitly NOT part of this work:
- Fetching issues from GitLab, Jira, or other platforms
- Creating issues from within Claude Code
- Batch processing multiple issues

---

## Assumptions

- User has `gh` CLI installed and configured
- Issue body contains sufficient information for requirements gathering
- Labels follow standard naming (bug, enhancement, refactor)

---

## Analysis Results

### Implementation Plan

| # | File | Action |
|---|------|--------|
| 1 | `.claude/skills/start-new/SKILL.md` | Add "GitHub Issue" option to Step 1 work type selection |
| 2 | `.claude/skills/start-new/init-github-issue.md` | **NEW FILE** - Issue parsing, work type detection, auto-routing logic |

### Related Code

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | `.claude/skills/start-new/SKILL.md` | 36-45 | Step 1 work type selection - needs modification |
| 2 | `.claude/skills/start-new/init-feature.md` | 1-177 | Feature init template - target for auto-routing |
| 3 | `.claude/skills/start-new/init-bugfix.md` | 1-217 | Bugfix init template - target for auto-routing |
| 4 | `.claude/skills/start-new/init-refactor.md` | 1-200 | Refactor init template - target for auto-routing |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| - | No conflicts identified | - | - |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Invalid GitHub URL | Show error message, fall back to manual selection |
| 2 | Issue without label | Analyze issue body to infer work type |
| 3 | Multiple conflicting labels | Analyze body to determine best match, confirm with user if ambiguous |
| 4 | Issue without milestone | Ask target version question manually |
| 5 | Private repo without auth | Show gh CLI authentication error |
| 6 | Cross-repo issue (full URL) | Support via full URL parsing |
| 7 | Issue number only (#N) | Use current repo context to fetch |

---

## Open Questions

- [x] Should labels be primary or secondary to body analysis? → Body analysis as fallback/supplement

---

## References

- https://github.com/U-lis/dotclaude/issues/4
- [gh CLI documentation](https://cli.github.com/manual/)
