# Configurable Version Files - Global Design Document

## Complexity

**SIMPLE** (2 sequential phases)

## Summary

Replace hardcoded 3-file version consistency check with a configurable `version_files` system. The change touches 3 markdown files with zero new files created. All files are markdown instruction files (no compiled code).

## Architecture Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Store `version_files` in existing `dotclaude-config.json` | SPEC constraint: no new config files. Reuses existing merge order (defaults < global < local). |
| 2 | Auto-detection runs at tagging time | SPEC FR-2 requirement. Ensures detection reflects current project state, not stale config-time snapshot. |
| 3 | CHANGELOG.md is always mandatory | SPEC constraint. Auto-appended if missing from explicit config. Cannot be removed via configure. |
| 4 | CLAUDE.md references tagging command instead of duplicating logic | DRY principle. Prevents future drift between docs and implementation. |
| 5 | Setting 6 appended after existing settings | Minimal diff. Follows established pattern in configure.md. |
| 6 | Empty array `[]` means auto-detect | Distinguishes "not configured" from "explicitly configured with specific files". Matches SPEC FR-2 semantics. |

## Phase Structure

```
PHASE_1 (Core Mechanism)
  └─ commands/tagging.md
       └─ Dynamic version_files resolution + consistency check

PHASE_2 (User Surface) [depends on PHASE_1]
  ├─ commands/configure.md
  │    └─ Setting 6: version_files management
  └─ CLAUDE.md
       └─ Updated version management documentation
```

## Dependency Analysis

### File-Level

| File | PHASE_1 | PHASE_2 | Overlap |
|------|---------|---------|---------|
| `commands/tagging.md` | MODIFY | -- | None |
| `commands/configure.md` | -- | MODIFY | None |
| `CLAUDE.md` | -- | MODIFY | None |

Zero file overlap. However, PHASE_2 logically depends on PHASE_1 because configure.md and CLAUDE.md must reference the exact schema and auto-detection behavior defined in tagging.md.

### Module-Level

- `configure.md` references the `version_files` schema shape defined in PHASE_1
- `CLAUDE.md` references the tagging behavior defined in PHASE_1
- Therefore: PHASE_2 is SEQUENTIAL after PHASE_1

### Parallelization Assessment

| Criterion | Result |
|-----------|--------|
| No shared files | PASS (zero overlap) |
| No runtime dependency | FAIL (PHASE_2 references PHASE_1 schema) |
| Independently testable | FAIL (configure Setting 6 validates against schema from PHASE_1) |

**Conclusion:** Sequential execution required. No parallel phases.

## Files Modified

| File | Phase | Change Type | Lines Affected (approx) |
|------|-------|-------------|------------------------|
| `commands/tagging.md` | 1 | Major rewrite of version check sections | ~60 lines |
| `commands/configure.md` | 2 | Add Setting 6 + schema update | ~80 lines added |
| `CLAUDE.md` | 2 | Replace version management sections | ~30 lines |

## Key Schema Reference

```json
{
  "version_files": [
    { "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" },
    { "path": "package.json", "pattern": "\"version\":\\s*\"([^\"]+)\"" }
  ]
}
```

- `path`: Relative path from project root. Required.
- `pattern`: Regex with exactly one capture group. Required.
- Empty array or absent: triggers auto-detection at tagging time.

## Backward Compatibility

For the dotclaude project itself (which has no `version_files` config), auto-detection will find:
1. `CHANGELOG.md` (always)
2. `.claude-plugin/plugin.json` (exists in project)
3. `.claude-plugin/marketplace.json` (exists in project)

This produces the same 3-file check as the current hardcoded behavior. Zero behavioral change for existing workflows.
