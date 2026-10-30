# {Subject} - Global Documentation

## Feature Overview

**Purpose**: {What this feature does}

**Problem**: {What problem it solves}

**Solution**: {High-level technical approach}

---

## Architecture Decision

### {Decision 1 Title}
**Options Considered**:
1. Option A: {description}
2. Option B: {description}

**Decision**: Option {X}

**Rationale**: {Why this option was chosen}

### {Decision 2 Title}
...

---

## Data Model

### {Entity 1}
```
{schema or structure definition}
```

### {Entity 2}
```
{schema or structure definition}
```

### Relationships
```
{Entity diagram or description}
```

---

## API Design (if applicable)

### Endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/... | ... |
| POST | /api/... | ... |

---

## File Structure

### Files to Create
```
{project}/
├── {file1}    # {description}
├── {file2}    # {description}
└── {dir}/
    └── {file3} # {description}
```

### Files to Modify
```
{file1}  # {what changes}
{file2}  # {what changes}
```

---

## Phase Overview

| Phase | Description | Requirements | Status | Dependencies |
|-------|-------------|--------------|--------|--------------|
| 1 | {description} | FR-{n} | Not Started | - |
| 2 | {description} | FR-{n}, NFR-{n} | Not Started | Phase 1 |

{Parallel groups appear only when the designer proposed them (`parallel_phases: true` or the user asked): rows `{k}A`, `{k}B`, and a merge row `{k}.5` that lists the group's phases as dependencies and no requirements.}

**Status values**: `Not Started`, `In Progress`, `Complete`, `Skipped` (validation failed after the attempt limit in `_contract.md`; see the phase's validator report), `Blocked` (waiting on a user decision or an external dependency; the reason is in the phase's PLAN Notes).

---

## Phase Dependencies

```
Phase 1 ──→ Phase 2
```

---

## Risk Mitigation

### Risk 1: {Title}
**Impact**: High/Medium/Low
**Mitigation**: {How to mitigate}

### Risk 2: {Title}
...

---

## Completion Criteria

Overall feature is complete when:
- [ ] All phases marked Complete
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Code reviewed

---

## Next Steps

1. ⏳ {Current/Next action}
2. {Following action}
3. {Following action}
