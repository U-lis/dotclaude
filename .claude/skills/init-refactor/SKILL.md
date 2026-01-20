---
name: init-refactor
description: Initialize refactoring work by gathering refactor details through step-by-step questions. Use when starting refactoring work or when routed from /start-new.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-refactor

Initialize refactoring work by gathering refactor details through step-by-step questions.

## Trigger

User invokes `/init-refactor` or is routed from `/start-new` (리팩토링 selected).

## Workflow

```
User: /init-refactor
         |
Task tool -> init-refactor Agent
         |
Agent handles:
  - Step-by-step questions
  - Dependency analysis
  - Branch/directory creation
  - SPEC.md creation
         |
Return result to user
```

## Agent Call

Invoke init-refactor agent via Task tool:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are the init-refactor agent. Read .claude/agents/init-refactor.md for your role.

    Execute the init-refactor workflow:
    1. Gather refactor details via AskUserQuestion
    2. Execute analysis phases A-E (with dependency focus)
    3. Create branch and directory
    4. Create SPEC.md via TechnicalWriter
    5. Commit and present for review

    Return structured output with branch, subject, spec_path.
```

## Output

Agent returns:
- branch: created branch name
- subject: work subject/keyword
- spec_path: path to SPEC.md
- status: SUCCESS or FAILED
