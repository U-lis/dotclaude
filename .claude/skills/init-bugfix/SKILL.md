---
name: init-bugfix
description: Initialize bug fix work by gathering bug details through step-by-step questions. Use when starting bug fix work or when routed from /start-new.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-bugfix

Initialize bug fix work by gathering bug details through step-by-step questions.

## Trigger

User invokes `/init-bugfix` or is routed from `/start-new` (버그 수정 selected).

## Workflow

```
User: /init-bugfix
         |
Task tool -> init-bugfix Agent
         |
Agent handles:
  - Step-by-step questions
  - Root cause analysis
  - Branch/directory creation
  - SPEC.md creation
         |
Return result to user
```

## Agent Call

Invoke init-bugfix agent via Task tool:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are the init-bugfix agent. Read .claude/agents/init-bugfix.md for your role.

    Execute the init-bugfix workflow:
    1. Gather bug details via AskUserQuestion
    2. Execute analysis phases A-E (with root cause focus)
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
