# GitHub Issue Fetch - Global Documentation

## Feature Overview

**Purpose**: Enable automatic workflow initialization from GitHub issues

**Problem**: Redundant manual input when issue details already exist in GitHub

**Solution**: Add GitHub issue URL input at Step 1, parse metadata, auto-route to appropriate init workflow

---

## Architecture Decision

### Integration Strategy: Router Pattern

`init-github-issue.md` acts as a **router** that parses GitHub issues and delegates to existing init-xxx workflows.

**Data Flow**:
```
User selects "GitHub Issue" at Step 1
    ↓
Load init-github-issue.md
    ↓
Parse issue via `gh issue view`
    ↓
Detect work type (labels → body analysis fallback)
    ↓
Route to appropriate init-{type}.md
    ↓
Continue normal workflow with pre-populated context
```

### Work Type Detection Algorithm

**Priority Order**:
1. **Label-based** (primary): Exact match on known labels
2. **Body analysis** (fallback): Keyword extraction when labels missing/ambiguous

**Label Mapping**:
| Label | Work Type | Init File |
|-------|-----------|-----------|
| `bug` | bugfix | init-bugfix.md |
| `enhancement` | feature | init-feature.md |
| `refactor` | refactor | init-refactor.md |

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | SKILL.md Update - Add GitHub Issue option | Pending | None |
| 2 | init-github-issue.md Creation | Pending | Phase 1 |

---

## File Structure

### Files to Modify
| File | Change |
|------|--------|
| `.claude/skills/start-new/SKILL.md` | Add "GitHub Issue" option to Step 1 |

### Files to Create
| File | Purpose |
|------|---------|
| `.claude/skills/start-new/init-github-issue.md` | Issue parsing + routing |
