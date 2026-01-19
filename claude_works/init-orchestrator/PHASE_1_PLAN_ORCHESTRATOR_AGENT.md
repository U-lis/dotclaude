# Phase 1: Create Orchestrator Agent

## Objective
Create `agents/orchestrator.md` that defines the Master Orchestrator agent.

## Prerequisites
- SPEC.md approved

## Instructions

### 1. Create File
Create `.claude/agents/orchestrator.md`

### 2. Define Agent Header
```markdown
# Orchestrator Agent

You are the **Orchestrator**, the central controller that governs the entire development workflow from init to merge.
```

### 3. Define Role Section
Include:
- Central workflow controller
- Subagent coordinator
- State manager
- User interaction handler

### 4. Define Capabilities Section
Include:
- AskUserQuestion for user interaction
- Task tool for subagent calls
- Parallel Task tool calls for parallel phases
- File operations (git, mkdir)

### 5. Define 16-Step Workflow
Transcribe the workflow from SPEC.md:
1. Ask work type
2. Ask work-type-specific questions
3. Create branch, directory
4. Ask target version (show latest 5)
5. Call TechnicalWriter → SPEC.md
6. Present SPEC for review
7. Commit SPEC.md
8. Ask scope selection
9. Call Designer
10. Call TechnicalWriter → GLOBAL.md, PHASE_*.md
11. Commit design documents
12. Parse phase list from GLOBAL.md
13. Execute phases (sequential/parallel)
14. Call TechnicalWriter → update docs
15. Merge to main
16. Return summary

### 6. Define Question Sets Section
Include all three question sets from SPEC.md:
- Feature Questions (8 items)
- Bugfix Questions (6 items)
- Refactor Questions (6 items)

### 7. Define Subagent Call Patterns Section
Document how to call each subagent:
- TechnicalWriter: Task tool with document type, content, path
- Designer: Task tool with SPEC.md path
- Coder: Task tool with phase ID, PLAN path, worktree (if parallel)
- code-validator: Task tool with phase ID, checklist

### 8. Define Parallel Execution Section
Document parallel phase handling:
- Detect parallel phases from GLOBAL.md (e.g., 3A, 3B, 3C)
- Setup worktrees
- Call multiple Task tools in single message
- Wait for all results
- Proceed to merge phase

### 9. Define State Management Section
Document state tracking:
- Track current step, completed steps
- Track subagent results
- Update GLOBAL.md status
- Resume from checkpoint

### 10. Define Error Handling Section
Document error scenarios:
- Subagent failure: retry up to 3 times
- SPEC rejection: iterate with user
- Phase failure: skip and report
- Critical error: halt and report

### 11. Define Output Contract Section
Document final output format (YAML from SPEC.md)

## Completion Checklist
- [ ] File created at `.claude/agents/orchestrator.md`
- [ ] Role and capabilities defined
- [ ] 16-step workflow documented
- [ ] Question sets included
- [ ] Subagent call patterns documented
- [ ] Parallel execution logic documented
- [ ] State management documented
- [ ] Error handling documented
- [ ] Output contract defined

## Notes
- Follow token-efficient writing style
- Use structured sections for AI parseability
- Reference SPEC.md for exact workflow steps
