---
description: Validate consistency across all planning documents using spec-validator agent. Use after design documents are created or when user invokes /dotclaude:validate-spec.
---

# /dotclaude:validate-spec

Validate consistency across all planning documents using spec-validator agent.

## Configuration Loading

Before executing any operations, load the working directory from configuration:

1. **Default**: `working_directory = ".dc_workspace"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved `{working_directory}` value is used for all document and file paths in this skill.

## Trigger

User invokes `/dotclaude:validate-spec` after design documents are created.

## Prerequisites

- `{working_directory}/{subject}/SPEC.md` exists
- `{working_directory}/{subject}/GLOBAL.md` exists
- At least one `PHASE_{k}_PLAN_{keyword}.md` exists
- Corresponding `PHASE_{k}_TEST.md` files exist

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Read All Documents                                   │
│    - SPEC.md                                           │
│    - GLOBAL.md                                         │
│    - All PHASE_*_PLAN_*.md files                       │
│    - All PHASE_*_TEST.md files                         │
│    - PHASE_*.5_PLAN_MERGE.md (if exists)               │
├─────────────────────────────────────────────────────────┤
│ 2. Invoke spec-validator Agent                          │
│    - Cross-reference all documents                      │
│    - Check requirements coverage                        │
│    - Verify test case completeness                      │
│    - Validate phase dependencies                        │
├─────────────────────────────────────────────────────────┤
│ 3. If Issues Found                                      │
│    - Report to TechnicalWriter for fixes                │
│    - Wait for document updates                          │
│    - Re-validate                                        │
├─────────────────────────────────────────────────────────┤
│ 4. Validation Complete                                  │
│    - Report success to user                             │
│    - Ready for implementation                           │
└─────────────────────────────────────────────────────────┘
```

## Validation Checklist

### Requirements Coverage
- [ ] All SPEC requirements → GLOBAL phase overview
- [ ] All phase requirements → PLAN documents
- [ ] No orphaned requirements

### Plan-Test Alignment
- [ ] Each PLAN has corresponding TEST
- [ ] All checklist items have test cases
- [ ] Coverage target achievable (≥ 70%)

### Completeness
- [ ] No missing edge cases
- [ ] Error handling covered
- [ ] Boundary conditions addressed

### Consistency
- [ ] No contradictions
- [ ] Consistent terminology
- [ ] Accurate file references

### Dependencies
- [ ] Dependencies explicitly stated
- [ ] Logical order
- [ ] Parallel phases truly independent

### Parallel Phase Validation
- [ ] PHASE_{k}.5_PLAN_MERGE.md exists
- [ ] Conflict areas identified
- [ ] Merge order defined

## Output

### Validation Report
```markdown
# Spec Validation Report

## Status: PASSED / FAILED

## Issues Found (if any)
- Issue 1: ...
- Issue 2: ...

## Validation Passed
- [x] Requirements coverage
- [x] Plan-Test alignment
- [x] No contradictions
- [x] Dependencies correct
```

## Iteration Loop

```
validate → issues found → TW fixes → re-validate → repeat until PASSED
```

## Next Steps

After validation passes:
1. Proceed to `/dotclaude:code [phase]` to start implementation
