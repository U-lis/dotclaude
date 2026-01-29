# Phase 3: Update Agent Invocation Patterns

## Objective

Change all agent invocation patterns in command files from the `general-purpose` workaround to direct `dotclaude:{agent-name}` invocation. This is possible because Phase 1A added frontmatter to all agent files.

## Prerequisites

- Phase 1A complete (agents have frontmatter with `name` field)
- Phase 2 complete (start-new.md and update-docs.md are inlined with full content)

## Instructions

### Affected Files

Only 2 command files contain agent invocation patterns:
1. `commands/start-new.md` (13 invocation sites)
2. `commands/update-docs.md` (1 invocation site)

No other command files contain `general-purpose` or `Read agents/` patterns.

### Transformation Rules

#### Rule 1: Change subagent_type

**Before**: `subagent_type="general-purpose"`
**After**: `subagent_type="dotclaude:{agent-name}"`

Agent name mapping:
| Old Prompt Pattern | New subagent_type |
|-------------------|-------------------|
| "You are TechnicalWriter" | `dotclaude:technical-writer` |
| "You are Designer" | `dotclaude:designer` |
| "You are Coder...coders/{lang}" | `dotclaude:coder-{lang}` (e.g., `dotclaude:coder-python`) |
| "You are code-validator" | `dotclaude:code-validator` |

#### Rule 2: Remove Agent Self-Read Instructions

When using `dotclaude:{agent-name}`, the agent definition is automatically loaded by the plugin system. Remove these lines from prompts:

**Remove these patterns**:
- `You are TechnicalWriter. Read agents/technical-writer.md for your role.`
- `You are Designer. Read agents/designer.md for your role.`
- `You are Coder. Read agents/coders/{detected_language}.md for your role.`
- `You are code-validator. Read agents/code-validator.md for your role.`
- `You are TechnicalWriter in DOCS_UPDATE role. Read agents/technical-writer.md.`

**Replace with** (or just remove the line, keeping the task-specific instructions):
- Keep the task instructions that follow
- If a role qualifier like "in DOCS_UPDATE role" is needed, keep it as context in the prompt

#### Rule 3: Update Delegation Enforcement Section

The start-new.md contains a "Delegation Enforcement" section that documents the `general-purpose` pattern. Update it.

**Before** (Delegation Enforcement section):
```markdown
### MUST DO

The orchestrator MUST:
- Use Task tool with `subagent_type: "general-purpose"` for all agent invocations
- Pass agent role explicitly in prompt: "You are {AgentName}. Read agents/{agent-file}.md for your role."
```

**After**:
```markdown
### MUST DO

The orchestrator MUST:
- Use Task tool with `subagent_type: "dotclaude:{agent-name}"` for all agent invocations
- The agent definition is auto-loaded by the plugin system; no need to read agent files manually
```

**Before** (Verification patterns):
```markdown
**Correct Pattern** (Task tool invocation visible):
\```
Invoke Task tool (subagent_type: general-purpose, prompt: "You are TechnicalWriter...")
  Subagent completed successfully
Output created: claude_works/{subject}/SPEC.md
\```

**Incorrect Pattern** (direct file operations):
\```
Read(agents/technical-writer.md)
Write(claude_works/{subject}/SPEC.md)
\```
```

**After**:
```markdown
**Correct Pattern** (Task tool invocation visible):
\```
Invoke Task tool (subagent_type: dotclaude:technical-writer, prompt: "Create SPEC.md...")
  Subagent completed successfully
Output created: claude_works/{subject}/SPEC.md
\```

**Incorrect Pattern** (direct file operations):
\```
Read(agents/technical-writer.md)
Write(claude_works/{subject}/SPEC.md)
\```
```

### Changes in `commands/start-new.md`

#### TechnicalWriter Invocations (4 sites)

**Site 1: SPEC.md Creation (Step 2 example)**

Before:
```
Task(
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.

Create SPEC.md document at: claude_works/{subject}/SPEC.md
...
```

After:
```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
Create SPEC.md document at: claude_works/{subject}/SPEC.md
...
```

Apply the same transformation to all 4 TechnicalWriter invocation sites (Step 2, Step 7 Example 2, Step 7 Example 3, and the subagent call patterns section).

#### Designer Invocation (1 site)

Before:
```
Task(
  subagent_type="general-purpose",
  prompt="""
You are Designer. Read agents/designer.md for your role.

## Task: Analyze SPEC and Create Design
...
```

After:
```
Task(
  subagent_type="dotclaude:designer",
  prompt="""
## Task: Analyze SPEC and Create Design
...
```

#### Coder Invocations (4 sites)

For sequential phases:

Before:
```
Task(
  subagent_type="general-purpose",
  prompt="""
You are Coder. Read agents/coders/{detected_language}.md for your role.

## Task: Implement Phase {phase_id}
...
```

After:
```
Task(
  subagent_type="dotclaude:coder-{detected_language}",
  prompt="""
## Task: Implement Phase {phase_id}
...
```

Apply to all 4 Coder invocation sites (1 sequential, 3 parallel examples).

#### code-validator Invocation (1 site)

Before:
```
Task(
  subagent_type="general-purpose",
  prompt="""
You are code-validator. Read agents/code-validator.md for your role.

## Task: Validate Phase {phase_id} Implementation
...
```

After:
```
Task(
  subagent_type="dotclaude:code-validator",
  prompt="""
## Task: Validate Phase {phase_id} Implementation
...
```

#### Delegation Enforcement Section (3 references)

Update the rule text and verification patterns as described in Rule 3 above.

#### Parallel Execution Patterns Section (2 references)

Before:
```
<Task tool call 1>
  subagent_type: "general-purpose"
  prompt: "Execute PHASE_3A in worktree ../{subject}-3A"
</Task tool call 1>

<Task tool call 2>
  subagent_type: "general-purpose"
  prompt: "Execute PHASE_3B in worktree ../{subject}-3B"
</Task tool call 2>
```

After:
```
<Task tool call 1>
  subagent_type: "dotclaude:coder-{detected_language}"
  prompt: "Execute PHASE_3A in worktree ../{subject}-3A"
</Task tool call 1>

<Task tool call 2>
  subagent_type: "dotclaude:coder-{detected_language}"
  prompt: "Execute PHASE_3B in worktree ../{subject}-3B"
</Task tool call 2>
```

### Changes in `commands/update-docs.md`

#### TechnicalWriter Invocation (1 site)

Before:
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are TechnicalWriter in DOCS_UPDATE role. Read agents/technical-writer.md.

    ## Task: Update Project Documentation
...
```

After:
```
Task tool:
  subagent_type: "dotclaude:technical-writer"
  prompt: |
    ## Role: DOCS_UPDATE

    ## Task: Update Project Documentation
...
```

Note: The "DOCS_UPDATE role" context is preserved as a role instruction within the prompt since it is task-specific context, not agent identification.

## Important Notes

- Only modify `commands/start-new.md` and `commands/update-docs.md`. No other command files need changes.
- Preserve all task-specific instructions in prompts. Only remove the "You are X. Read agents/X.md" preamble.
- The Coder pattern uses `{detected_language}` which is a runtime variable. Keep it as a template: `dotclaude:coder-{detected_language}`.
- Do NOT modify agent files in this phase. Only command files.

## Completion Checklist

- [ ] `commands/start-new.md`: All `subagent_type="general-purpose"` changed to `dotclaude:{agent-name}`
- [ ] `commands/start-new.md`: All `Read agents/*.md for your role` lines removed from prompts
- [ ] `commands/start-new.md`: Delegation Enforcement section updated
- [ ] `commands/start-new.md`: Verification patterns updated
- [ ] `commands/start-new.md`: Parallel execution patterns updated
- [ ] `commands/update-docs.md`: `subagent_type: "general-purpose"` changed to `dotclaude:technical-writer`
- [ ] `commands/update-docs.md`: `Read agents/technical-writer.md` removed from prompt
- [ ] No remaining `general-purpose` references in commands/ (except potentially in quoted historical context)
- [ ] No remaining `Read agents/` instructions in command prompts
- [ ] All task-specific instructions preserved in prompts

## Verification

1. `grep -r "general-purpose" commands/` returns empty (no remaining old pattern)
2. `grep -r 'Read agents/' commands/` returns empty (no remaining old read instructions)
3. `grep -r "dotclaude:technical-writer" commands/` shows hits in start-new.md and update-docs.md
4. `grep -r "dotclaude:designer" commands/` shows hit in start-new.md
5. `grep -r "dotclaude:code-validator" commands/` shows hit in start-new.md
6. `grep -r "dotclaude:coder-" commands/` shows hits in start-new.md
