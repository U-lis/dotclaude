# Phase 2: Convert Skills to Thin Wrappers

## Objective

Reduce init-xxx skill files from ~200 lines to ~30 lines thin wrappers that delegate to corresponding agents.

---

## Prerequisites

- [ ] Phase 0 completed (_shared/ files moved)
- [ ] Phase 1 completed (init-xxx agents created)
- [ ] Agent files exist at:
  - `agents/init-feature.md`
  - `agents/init-bugfix.md`
  - `agents/init-refactor.md`

---

## Scope

### In Scope
- Reduce `skills/init-feature/SKILL.md` to thin wrapper
- Reduce `skills/init-bugfix/SKILL.md` to thin wrapper
- Reduce `skills/init-refactor/SKILL.md` to thin wrapper

### Out of Scope
- Modifying agent files (done in Phase 1)
- Modifying orchestrator (done in Phase 3)

---

## Instructions

### Step 1: Convert init-feature/SKILL.md

**File**: `.claude/skills/init-feature/SKILL.md`

**Action**: Replace entire file content with thin wrapper (~30 lines)

**New Content**:

```markdown
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
         ↓
Task tool → init-feature Agent
         ↓
Agent handles:
  - Step-by-step questions
  - Codebase analysis
  - Branch/directory creation
  - SPEC.md creation
         ↓
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
```

### Step 2: Convert init-bugfix/SKILL.md

**File**: `.claude/skills/init-bugfix/SKILL.md`

**Action**: Replace entire file content with thin wrapper (~30 lines)

**New Content**:

```markdown
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
         ↓
Task tool → init-bugfix Agent
         ↓
Agent handles:
  - Step-by-step questions
  - Root cause analysis
  - Branch/directory creation
  - SPEC.md creation
         ↓
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
```

### Step 3: Convert init-refactor/SKILL.md

**File**: `.claude/skills/init-refactor/SKILL.md`

**Action**: Replace entire file content with thin wrapper (~30 lines)

**New Content**:

```markdown
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
         ↓
Task tool → init-refactor Agent
         ↓
Agent handles:
  - Step-by-step questions
  - Dependency analysis
  - Branch/directory creation
  - SPEC.md creation
         ↓
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
```

---

## Implementation Notes

### Thin Wrapper Pattern
Each thin wrapper skill file contains:
1. YAML frontmatter (name, description, user-invocable, hooks)
2. Title and brief description
3. Trigger section
4. Workflow diagram (skill → agent)
5. Agent call specification
6. Output description

### Preserved Elements
- YAML frontmatter: Unchanged (hooks, name, description)
- user-invocable: true (direct command invocation)
- Stop hook: Preserved for SPEC commit validation

### Removed Elements
- Step-by-step questions (moved to agent)
- Analysis phase details (moved to agent)
- Branch keyword logic (moved to agent)
- Output format details (moved to agent)

### Reference Pattern
Pattern follows existing `/start-new → orchestrator`:
```
/start-new (skill, ~94 lines)
    ↓ Task tool
orchestrator agent (~508 lines)
```

Applied to:
```
/init-feature (skill, ~30 lines)
    ↓ Task tool
init-feature agent (~200 lines)
```

---

## Completion Checklist

- [ ] `skills/init-feature/SKILL.md` reduced to ~30 lines
- [ ] `skills/init-bugfix/SKILL.md` reduced to ~30 lines
- [ ] `skills/init-refactor/SKILL.md` reduced to ~30 lines
- [ ] All skills retain YAML frontmatter with hooks
- [ ] All skills have Task tool call to corresponding agent
- [ ] All skills describe workflow diagram
- [ ] All skills list output contract

---

## Verification

### Manual Verification
```bash
# Verify line counts reduced
wc -l .claude/skills/init-feature/SKILL.md  # ~30-40 lines
wc -l .claude/skills/init-bugfix/SKILL.md   # ~30-40 lines
wc -l .claude/skills/init-refactor/SKILL.md # ~30-40 lines

# Verify frontmatter preserved
head -20 .claude/skills/init-feature/SKILL.md | grep -E "(name:|hooks:|Stop:)"

# Verify Task tool reference to agent
grep -A5 "Task tool" .claude/skills/init-*/SKILL.md
```

### Expected Output
```
skills/init-feature/SKILL.md: ~30-40 lines
skills/init-bugfix/SKILL.md: ~30-40 lines
skills/init-refactor/SKILL.md: ~30-40 lines

Frontmatter contains:
- name: init-xxx
- hooks: Stop hook preserved

Task tool calls reference:
- .claude/agents/init-feature.md
- .claude/agents/init-bugfix.md
- .claude/agents/init-refactor.md
```

---

## Notes

- Line count is approximate (~30-40 lines acceptable)
- YAML frontmatter format must remain valid
- Hook command path unchanged: `.claude/hooks/check-init-complete.sh`
- Skill description unchanged (affects settings.json display)

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
