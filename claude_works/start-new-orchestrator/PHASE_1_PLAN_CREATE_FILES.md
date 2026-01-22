# Phase 1: Create New File Structure

## Objective

Create 5 new files in `.claude/skills/start-new/` directory that merge and reorganize content from existing agent files.

## Prerequisites

- None (first phase)
- SPEC.md reviewed and approved

## Instructions

### 1A: Create SKILL.md (~400 lines)

**Target**: `.claude/skills/start-new/SKILL.md`

**Source files**:
- `.claude/agents/orchestrator.md` (497 lines)
- `.claude/agents/_shared/init-workflow.md` (144 lines)
- `.claude/skills/start-new/SKILL.md` (current - 92 lines, will be replaced)

**Content structure**:

```markdown
---
name: start-new
description: Entry point for starting new work. Calls orchestrator agent to manage entire workflow.
user-invocable: true
---

# /start-new

## Role
- Central workflow controller for 13-step development process
- Direct user interaction via AskUserQuestion
- Subagent coordinator for TechnicalWriter, Designer, Coder, code-validator

## Capabilities
- AskUserQuestion: Direct user interaction (Steps 1, 3, 5)
- Task tool: Invoke subagents (NOT init-xxx, NOT orchestrator)
- Bash/Read/Write: File and git operations

## 13-Step Workflow
[Merge from orchestrator.md - Steps 1-13]

## Step 1: Work Type Selection
[From orchestrator.md - AskUserQuestion call]

## Step 2: Load Init Instructions
[NEW - conditional loading pattern]
Based on Step 1 response, read corresponding init file:
- "기능 추가/수정" -> Read init-feature.md from this directory
- "버그 수정" -> Read init-bugfix.md from this directory
- "리팩토링" -> Read init-refactor.md from this directory

Execute all steps defined in the loaded init file.

## Step 3-5: (Inline from orchestrator.md)
[SPEC Review, Commit, Scope Selection]

## Step 6: Checkpoint Before Design
[NEW - inline hook logic from check-init-complete.sh]
Before calling Designer, validate:
- [ ] Work branch exists (not on main/master)
- [ ] SPEC.md exists in claude_works/{subject}/
If validation fails: halt and report error

## Steps 6-13: Execution Phase
[From orchestrator.md - Design through Merge]

## Init Phase Rules (from init-workflow.md)
- Plan Mode Policy
- Mandatory Workflow Rules
- Iteration Limits

## Subagent Call Patterns
[From orchestrator.md - TechnicalWriter, Designer, Coder, code-validator only]
[REMOVE init-xxx patterns]

## Non-Stop Execution
[From orchestrator.md]

## Error Handling
[From orchestrator.md]

## Output Contract
[From orchestrator.md]
```

**Key changes from source**:
- [ ] Remove "Task tool -> orchestrator" pattern (now inline)
- [ ] Remove "Task tool -> init-xxx" pattern (now conditional read)
- [ ] Add Step 2 conditional loading logic
- [ ] Add Step 6 checkpoint logic (from hook script)
- [ ] Merge init-workflow.md rules into relevant sections
- [ ] Keep frontmatter with user-invocable: true
- [ ] Remove hooks section (no longer needed)

---

### 1B: Create _analysis.md (~140 lines)

**Target**: `.claude/skills/start-new/_analysis.md`

**Source**: `.claude/agents/_shared/analysis-phases.md` (237 lines)

**Content transformation**:
- [ ] Copy entire analysis-phases.md content
- [ ] Remove work-type-specific sections (moved to init-xxx.md files)
- [ ] Keep: Iteration Limits, Steps A-E common process, Output formats
- [ ] Keep: Analysis Results Template
- [ ] Keep: Skip Conditions

**Sections to remove** (will be in init-xxx.md):
- "Work-Type Specifics" subsection in Step B
- References to specific init skill files

**Estimated reduction**: 237 -> ~140 lines

---

### 1C: Create init-feature.md (~150 lines)

**Target**: `.claude/skills/start-new/init-feature.md`

**Source**: `.claude/agents/init-feature.md` (191 lines)

**Content transformation**:
- [ ] Remove Role section (SKILL.md defines role)
- [ ] Remove Capabilities section (SKILL.md defines capabilities)
- [ ] Remove Reference section (now in same directory)
- [ ] Remove Plan Mode Policy (in SKILL.md)
- [ ] Remove Output Contract (in SKILL.md)
- [ ] Keep: Step-by-Step Questions (Steps 1-8)
- [ ] Keep: Feature-Specific Analysis (Steps B, C, D specifics)
- [ ] Keep: Branch Keyword generation
- [ ] Keep: Output format (what SPEC.md contains)

**Structure**:
```markdown
# init-feature Instructions

## Step-by-Step Questions
[Steps 1-8 with AskUserQuestion calls]

## Analysis Phase
Reference: Read _analysis.md for common analysis workflow.

### Feature-Specific Analysis
[Step B, C, D feature-specific details]

## Branch Keyword
[Auto-generation rules]

## SPEC.md Content
[What goes into SPEC.md for features]
```

---

### 1D: Create init-bugfix.md (~180 lines)

**Target**: `.claude/skills/start-new/init-bugfix.md`

**Source**: `.claude/agents/init-bugfix.md` (236 lines)

**Content transformation**:
- [ ] Remove Role, Capabilities, Reference, Plan Mode Policy, Output Contract sections
- [ ] Keep: Step-by-Step Questions (Steps 1-6)
- [ ] Keep: Bugfix-Specific Analysis (enhanced Step B with recent change analysis)
- [ ] Keep: Required Analysis Outputs
- [ ] Keep: Inconclusive Analysis Handling
- [ ] Keep: Branch Keyword generation
- [ ] Keep: SPEC.md output format (User-Reported + AI Analysis sections)

**Structure**:
```markdown
# init-bugfix Instructions

## Step-by-Step Questions
[Steps 1-6 with AskUserQuestion calls]

## Analysis Phase
Reference: Read _analysis.md for common analysis workflow.

### Bugfix-Specific Analysis
[Step B enhanced with recent change analysis]
[Step C, D bugfix-specific details]

### Required Analysis Outputs
[Root Cause, Affected Code, Fix Strategy, Conflicts, Edge Cases]

### Inconclusive Analysis Handling
[What to do if root cause not found]

## Branch Keyword
[Auto-generation rules]

## SPEC.md Content
[User-Reported Information + AI Analysis Results sections]
```

---

### 1E: Create init-refactor.md (~160 lines)

**Target**: `.claude/skills/start-new/init-refactor.md`

**Source**: `.claude/agents/init-refactor.md` (212 lines)

**Content transformation**:
- [ ] Remove Role, Capabilities, Reference, Plan Mode Policy, Output Contract sections
- [ ] Keep: Step-by-Step Questions (Steps 1-6)
- [ ] Keep: Refactor-Specific Analysis (dependency mapping, test coverage)
- [ ] Keep: Refactoring Safety Notes
- [ ] Keep: Branch Keyword generation
- [ ] Keep: SPEC.md output format

**Structure**:
```markdown
# init-refactor Instructions

## Step-by-Step Questions
[Steps 1-6 with AskUserQuestion calls]

## Analysis Phase
Reference: Read _analysis.md for common analysis workflow.

### Refactor-Specific Analysis
[Step B: Target Code, Usage, Test Coverage, Pattern Analysis]
[Step C, D refactor-specific details]

### Refactoring Safety Notes
[Test coverage warnings, dependency warnings]

## Branch Keyword
[Auto-generation rules]

## SPEC.md Content
[Target, Problems, Goal, XP Principle Reference, Analysis Results]
```

---

### 1F: Add Step 6 Checkpoint Logic

**Location**: Within SKILL.md Step 6 section

**Logic from check-init-complete.sh**:

```markdown
## Step 6 Checkpoint (Before Design)

Before calling Designer agent, validate:

1. **Branch Check**:
   - Current branch must NOT be main/master
   - Must be feature/, bugfix/, or refactor/ branch
   - If on main: "Work branch not created. Create branch before proceeding."

2. **SPEC.md Check**:
   - File claude_works/{subject}/SPEC.md must exist
   - If missing: "SPEC.md not found. Create SPEC.md before design phase."

3. **SPEC.md Committed Check**:
   - SPEC.md must be committed (not just staged)
   - If uncommitted: "SPEC.md not committed. Commit SPEC.md before design phase."

If any check fails: halt workflow and report error to user.
```

## Completion Checklist

- [ ] SKILL.md created with merged orchestrator + init-workflow content
- [ ] _analysis.md created with common analysis phases
- [ ] init-feature.md created with feature questions + analysis
- [ ] init-bugfix.md created with bugfix questions + analysis
- [ ] init-refactor.md created with refactor questions + analysis
- [ ] Step 6 checkpoint logic included in SKILL.md
- [ ] All files follow markdown format
- [ ] No duplicate content between files
- [ ] Conditional loading pattern documented in SKILL.md Step 2

## Notes

### Conditional Loading Pattern

SKILL.md Step 2 should use this pattern:
```
Based on user selection:
- If "기능 추가/수정": Read and follow init-feature.md instructions
- If "버그 수정": Read and follow init-bugfix.md instructions
- If "리팩토링": Read and follow init-refactor.md instructions
```

This relies on Claude's ability to read files from the same skill directory.

### Content Preservation

- All 8 feature questions preserved
- All 6 bugfix questions preserved
- All 6 refactor questions preserved
- All analysis phase details preserved (just reorganized)
- All AskUserQuestion parameters preserved exactly
