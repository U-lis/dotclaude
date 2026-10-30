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

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | {description} | Not Started | - |
| 2 | {description} | Not Started | Phase 1 |
| 3A | {description} | Not Started | Phase 2 |
| 3B | {description} | Not Started | Phase 2 |
| 3.5 | Merge parallel branches | Not Started | Phase 3A, 3B |
| 4 | {description} | Not Started | Phase 3.5 |

**Status values**: `Not Started`, `In Progress`, `Complete`, `Skipped` (validation failed after the attempt limit in `_contract.md`; see the phase's validator report), `Blocked` (waiting on a user decision or an external dependency; the reason is in the phase's PLAN Notes).

---

## Phase Dependencies

```
Phase 1 ──→ Phase 2 ──→ Phase 3A ──┐
                    └→ Phase 3B ──┼→ Phase 3.5 ──→ Phase 4
                    └→ Phase 3C ──┘
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
