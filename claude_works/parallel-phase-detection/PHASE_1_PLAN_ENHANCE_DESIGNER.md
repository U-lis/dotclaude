# Phase 1: Enhance Designer Agent Instructions

## Objective

Modify `.claude/agents/designer.md` to include explicit parallel phase detection methodology with dependency analysis, parallelization criteria, and conflict prediction.

## Target File

`.claude/agents/designer.md`

## Changes

### Change 1: Add Dependency Analysis Section

**Location**: After "#### Parallel Phase Identification" section (line 49-52), before "### 3. Checklist Creation"

**Add new subsection**:

```markdown
#### Dependency Analysis (Required Before Parallelization)

Before identifying parallel phases, analyze dependencies at three levels:

**File-Level**
- List all files each potential phase will modify
- Mark phases with overlapping files as SEQUENTIAL

**Module-Level**
- Identify import/export relationships between affected modules
- If Phase B imports from files Phase A creates/modifies → SEQUENTIAL

**Test-Level**
- Check for shared test fixtures or mock data
- Shared test dependencies → coordinate in merge phase or make SEQUENTIAL
```

### Change 2: Replace Parallel Phase Identification Content

**Location**: Lines 49-52 (current "#### Parallel Phase Identification" section)

**Replace with**:

```markdown
#### Parallel Phase Identification

Phases qualify as parallel ONLY when ALL conditions met:

| Criterion | Check |
|-----------|-------|
| No shared files | File-level analysis shows zero overlap |
| No runtime dependency | Phase B doesn't require Phase A's output |
| Independently testable | Each phase's tests can run in isolation |

When parallel phases identified:
- Use naming: `PHASE_{k}A`, `PHASE_{k}B`, `PHASE_{k}C`
- MUST create `PHASE_{k}.5_PLAN_MERGE.md`
- Document predicted conflicts (see below)
```

### Change 3: Add Conflict Prediction Section

**Location**: After the updated "Parallel Phase Identification" section

**Add new subsection**:

```markdown
#### Conflict Prediction (Required for Parallel Phases)

For each parallel phase group, document:

| Category | What to Predict |
|----------|-----------------|
| Merge conflicts | Files likely to conflict (shared imports, configs) |
| Integration points | Interfaces between parallel work requiring coordination |
| Test coordination | Shared test utilities, fixtures, or CI resources |
```

### Change 4: Update Handoff Section

**Location**: Lines 60-66 ("### 4. Handoff to TechnicalWriter" section)

**Replace with**:

```markdown
### 4. Handoff to TechnicalWriter

Pass structured design results including:
- Overall architecture
- Phase breakdown with explicit dependency analysis
- Per-phase requirements and checklists
- For parallel phases:
  - Dependency matrix (file/module/test levels)
  - Parallelization criteria verification
  - Conflict predictions (merge/integration/test)
```

## Checklist

- [ ] Add "#### Dependency Analysis" section with three levels
- [ ] Update "#### Parallel Phase Identification" with explicit criteria table
- [ ] Add "#### Conflict Prediction" section with category table
- [ ] Update "### 4. Handoff to TechnicalWriter" with parallel phase requirements
- [ ] Verify no redundant prose (token efficiency)
- [ ] Verify existing naming conventions preserved
