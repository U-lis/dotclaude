---
description: Transform SPEC into detailed implementation plan using Designer agent. Use after SPEC.md is approved or when user invokes /dc:design.
---

# /dc:design

Transform SPEC into detailed implementation plan using Designer agent.

## Configuration Loading

Before executing any operations, load the working directory from configuration:

1. **Default**: `working_directory = ".dc_workspace"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved `{working_directory}` value is used for all document and file paths in this skill.

## Trigger

User invokes `/dc:design` after SPEC.md is ready.

## Prerequisites

- `{working_directory}/{subject}/SPEC.md` exists and is approved

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Read SPEC.md                                         │
│    - Understand requirements                            │
│    - Identify technical challenges                      │
├─────────────────────────────────────────────────────────┤
│ 2. Invoke Designer Agent                                │
│    - Analyze architecture options                       │
│    - Make technical decisions                           │
│    - Decompose into phases                              │
│    - Identify parallel opportunities                    │
├─────────────────────────────────────────────────────────┤
│ 3. Pass Results to TechnicalWriter                      │
│    - Create GLOBAL.md                                   │
│    - Create PHASE_{k}_PLAN_{keyword}.md for each phase  │
│    - Create PHASE_{k}_TEST.md for each phase            │
│    - Create PHASE_{k}.5_PLAN_MERGE.md if parallel phases│
├─────────────────────────────────────────────────────────┤
│ 4. Commit Documents                                     │
│    - git add {working_directory}/{subject}/*.md                │
│    - git commit -m "docs: add design documents"         │
├─────────────────────────────────────────────────────────┤
│ 5. Review with User                                     │
│    - Present design and phase breakdown                 │
│    - Iterate based on feedback                          │
└─────────────────────────────────────────────────────────┘
```

## Designer Agent Responsibilities

### Architecture Decisions
- Module organization
- API design
- Data models
- Technology choices

### Phase Decomposition
- Break work into manageable phases
- Define clear boundaries
- Identify dependencies

### Parallel Phase Identification
When phases can run independently:
- Name as PHASE_{k}A, {k}B, {k}C
- Plan git worktree strategy
- Create PHASE_{k}.5 merge plan

## Output Documents

### Simple Tasks (1-2 phases)
```
{working_directory}/{SUBJECT}.md
```

### Complex Tasks (3+ phases)
```
{working_directory}/{subject}/
├── SPEC.md                         (already exists)
├── GLOBAL.md                       (new)
├── PHASE_1_PLAN_{keyword}.md       (new)
├── PHASE_1_TEST.md                 (new)
├── PHASE_2_PLAN_{keyword}.md       (new)
├── PHASE_2_TEST.md                 (new)
...
```

### With Parallel Phases
```
├── PHASE_3A_PLAN_{keyword}.md
├── PHASE_3A_TEST.md
├── PHASE_3B_PLAN_{keyword}.md
├── PHASE_3B_TEST.md
├── PHASE_3.5_PLAN_MERGE.md         (required)
```

## Next Steps

After design is approved:
1. Proceed to `/dc:validate-spec` to verify document consistency
2. Then `/dc:code [phase]` to start implementation
