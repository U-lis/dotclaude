---
name: init-feature
description: Initialize a new feature by gathering requirements and creating SPEC document. Use when starting a new feature, project initialization, or when user invokes /init-feature.
user-invocable: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: ".claude/hooks/check-init-complete.sh"
---

# /init-feature

Initialize a new feature by gathering requirements through step-by-step questions.

## Trigger

User invokes `/init-feature` or is routed from `/start-new`.

## Workflow

```
User: /init-feature
         |
Task tool -> init-feature Agent
         |
Agent handles:
  - Step-by-step questions
  - Codebase analysis
  - Branch/directory creation
  - SPEC.md creation
         |
Return result to user
```

## Agent Call

Invoke init-feature agent via Task tool:

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are the init-feature agent. Read .claude/agents/init-feature.md for your role.

    Execute the init-feature workflow:
    1. Gather requirements via AskUserQuestion
    2. Execute analysis phases A-E
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
