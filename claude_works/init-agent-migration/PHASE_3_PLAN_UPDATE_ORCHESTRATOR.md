# Phase 3: Update Orchestrator References

## Objective

Update orchestrator.md to call init-xxx agents via Task tool instead of Skill tool.

---

## Prerequisites

- [ ] Phase 0 completed (_shared/ files moved)
- [ ] Phase 1 completed (init-xxx agents created)
- [ ] Phase 2 completed (skills converted to thin wrappers)
- [ ] Agent files verified working

---

## Scope

### In Scope
- Modify orchestrator.md lines 8, 15, 40-44, 203-225
- Change Skill tool calls to Task tool calls for init-xxx

### Out of Scope
- Other orchestrator functionality
- Other agent/skill interactions

---

## Instructions

### Step 1: Update Role Section (Line 8)

**File**: `.claude/agents/orchestrator.md`
**Location**: Line 8

**Current**:
```markdown
- **Subagent coordinator**: Call init skills via Skill tool; TechnicalWriter, Designer, Coder, code-validator via Task tool
```

**Change to**:
```markdown
- **Subagent coordinator**: Call init agents, TechnicalWriter, Designer, Coder, code-validator via Task tool
```

### Step 2: Update Capabilities Section (Line 15)

**File**: `.claude/agents/orchestrator.md`
**Location**: Line 15

**Current**:
```markdown
- Skill tool: Invoke init skills (init-feature, init-bugfix, init-refactor)
```

**Change to**:
```markdown
- Task tool: Invoke init agents (init-feature, init-bugfix, init-refactor)
```

### Step 3: Update Step 2 Call Pattern (Lines 40-44)

**File**: `.claude/agents/orchestrator.md`
**Location**: Lines 40-44

**Current**:
```markdown
**Step 2: Call Init Skill**
Based on work type selected, invoke corresponding init skill via Skill tool:
- 기능 추가/수정 → `Skill tool: init-feature`
- 버그 수정 → `Skill tool: init-bugfix`
- 리팩토링 → `Skill tool: init-refactor`
```

**Change to**:
```markdown
**Step 2: Call Init Agent**
Based on work type selected, invoke corresponding init agent via Task tool:
- 기능 추가/수정 → `Task tool → init-feature agent`
- 버그 수정 → `Task tool → init-bugfix agent`
- 리팩토링 → `Task tool → init-refactor agent`
```

### Step 4: Update Subagent Call Patterns Section (Lines 203-225)

**File**: `.claude/agents/orchestrator.md`
**Location**: Lines 203-225

**Current**:
```markdown
### Init Skills (Step 2)
```
Skill tool:
  skill: "init-feature" | "init-bugfix" | "init-refactor"

Selection based on Step 1 response:
- "기능 추가/수정" → skill: "init-feature"
- "버그 수정" → skill: "init-bugfix"
- "리팩토링" → skill: "init-refactor"

Init skill handles:
- Step-by-step questions
- Codebase analysis
- Branch/directory creation
- Target version selection
- SPEC.md creation

Returns:
- branch: created branch name
- subject: work subject/keyword
- spec_path: path to SPEC.md
- target_version: selected version
```
```

**Change to**:
```markdown
### Init Agents (Step 2)
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are the init-{type} agent. Read .claude/agents/init-{type}.md for your role.

    Execute the init workflow:
    1. Gather requirements via AskUserQuestion
    2. Execute analysis phases A-E
    3. Create branch and directory
    4. Create SPEC.md via TechnicalWriter
    5. Commit and present for review

    Return structured output with branch, subject, spec_path.

Selection based on Step 1 response:
- "기능 추가/수정" → init-feature agent
- "버그 수정" → init-bugfix agent
- "리팩토링" → init-refactor agent

Init agent handles:
- Step-by-step questions
- Codebase analysis
- Branch/directory creation
- SPEC.md creation

Returns:
- branch: created branch name
- subject: work subject/keyword
- spec_path: path to SPEC.md
- status: SUCCESS or FAILED
```
```

---

## Implementation Notes

### Change Summary

| Location | Before | After |
|----------|--------|-------|
| Line 8 | "Call init skills via Skill tool" | "Call init agents... via Task tool" |
| Line 15 | "Skill tool: Invoke init skills" | "Task tool: Invoke init agents" |
| Lines 40-44 | "Skill tool: init-xxx" | "Task tool → init-xxx agent" |
| Lines 203-225 | Skill tool pattern | Task tool pattern |

### Consistency Check
After changes, orchestrator should consistently use:
- Task tool for ALL subagent calls
- No remaining Skill tool references for init-xxx

### Return Value Changes
- Remove `target_version` from returns (not part of init agent output)
- Add `status` field to returns

---

## Completion Checklist

- [ ] Line 8 updated: Role section mentions Task tool for init agents
- [ ] Line 15 updated: Capabilities section shows Task tool for init agents
- [ ] Lines 40-44 updated: Step 2 uses Task tool pattern
- [ ] Lines 203-225 updated: Subagent call patterns use Task tool
- [ ] No remaining "Skill tool" references for init-xxx
- [ ] Return value contract updated (status field added)
- [ ] File compiles/parses correctly (markdown valid)

---

## Verification

### Manual Verification
```bash
# Search for remaining Skill tool references to init-xxx
grep -n "Skill tool.*init-" .claude/agents/orchestrator.md
# Expected: No matches

# Verify Task tool references exist for init-xxx
grep -n "Task tool.*init-" .claude/agents/orchestrator.md
# Expected: Multiple matches

# Verify "Init Agents" section exists
grep -n "### Init Agents" .claude/agents/orchestrator.md
# Expected: Match around line 203
```

### Expected Output
```
No "Skill tool" + "init-" matches
Multiple "Task tool" + "init-" matches
"### Init Agents" section exists
```

---

## Notes

- This is the final phase of the migration
- After this phase, orchestrator is consistent with all agents via Task tool
- Direct `/init-xxx` invocation still works via thin wrapper skills
- No behavioral changes - only invocation mechanism changes

---

## Completion Date

{Date when phase was completed - filled by code-validator}

## Completed By

{Agent that completed the phase}
