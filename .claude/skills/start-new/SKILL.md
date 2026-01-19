---
name: start-new
description: Entry point for starting new work. Calls orchestrator agent to manage entire workflow.
user-invocable: true
---

# /start-new

Entry point for starting any new work. Calls the orchestrator agent to manage the entire development workflow.

## Trigger

User invokes `/start-new` to begin any new work.

## Workflow

```
User: /start-new
         ↓
Task tool → Orchestrator Agent
         ↓
Orchestrator manages entire workflow:
  - Work type selection
  - Requirements gathering
  - SPEC.md creation via TechnicalWriter
  - User review and approval
  - Scope selection
  - Design, code, docs, merge
         ↓
Display final summary to user
```

## Orchestrator Call

Invoke orchestrator agent via Task tool:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are the Orchestrator. Read .claude/agents/orchestrator.md for your role.

    Execute the full development workflow starting from Step 1.

    Follow the 16-step workflow defined in your agent file.
    Use AskUserQuestion for all user interactions.
    Call subagents via Task tool as specified.
```

Orchestrator handles:
- Work type selection (Feature/Bugfix/Refactor)
- Work-type-specific questions
- Target version selection
- SPEC.md creation via TechnicalWriter
- SPEC review and iteration
- Scope selection
- Design phase (Designer + TechnicalWriter)
- Code phase (Coder + code-validator)
- Documentation update (TechnicalWriter)
- Merge to main

## Output

Orchestrator returns final summary including:
- Status (SUCCESS/PARTIAL/FAILED)
- Work type and subject
- Phases completed
- Issues encountered
- Recommended next steps

Display summary to user.

## Manual Mode

Individual skills remain invocable for debugging or partial work:

| Command | Description |
|---------|-------------|
| `/init-feature` | Direct feature initialization (bypasses orchestrator) |
| `/init-bugfix` | Direct bugfix initialization (bypasses orchestrator) |
| `/init-refactor` | Direct refactor initialization (bypasses orchestrator) |
| `/design` | Direct design phase execution |
| `/code [phase]` | Direct phase code execution |
| `/merge-main` | Direct merge to main |

Use manual mode when:
- Debugging workflow issues
- Resuming partial work
- Testing individual components
