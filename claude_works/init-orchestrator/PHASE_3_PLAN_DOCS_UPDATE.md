# Phase 3: Documentation Update

## Objective
Update README.md and ensure documentation consistency after orchestrator integration.

## Prerequisites
- Phase 1 completed (orchestrator.md created)
- Phase 2 completed (start-new updated)

## Instructions

### 1. Update README.md Workflow Section

Update the workflow diagram to reflect orchestrator:
```
User → /start-new → Orchestrator Agent
                          ↓
              ┌───────────────────────┐
              │ Orchestrator manages: │
              │ - Init (questions)    │
              │ - SPEC.md creation    │
              │ - Design              │
              │ - Code (parallel)     │
              │ - Documentation       │
              │ - Merge               │
              └───────────────────────┘
                          ↓
                   Final Summary
```

### 2. Update README.md Agents Section

Add orchestrator to agents table:
| Agent | Role |
|-------|------|
| Orchestrator | Central workflow controller |
| Designer | Technical architecture and phase decomposition |
| TechnicalWriter | Structured documentation |
| spec-validator | Document consistency validation |
| code-validator | Code quality + plan verification |
| Coders | Language-specific implementation |

### 3. Update README.md Skills Section

Update skills table to reflect new /start-new behavior:
| Command | Description |
|---------|-------------|
| `/start-new` | Entry point - calls orchestrator for full workflow |
| `/init-feature` | Manual: Gather requirements for new features |
| `/init-bugfix` | Manual: Gather bug details for fixes |
| `/init-refactor` | Manual: Gather refactor info |
| ... | ... |

### 4. Update README.md Usage Section

Update "Start New Work" section:
```markdown
### Start New Work

```bash
# In Claude Code session
/start-new

# Orchestrator takes over:
# 1. Asks work type (Feature/Bugfix/Refactor)
# 2. Collects requirements via questions
# 3. Shows latest 5 versions, asks target version
# 4. Creates SPEC.md via TechnicalWriter
# 5. Reviews SPEC with user
# 6. Asks execution scope
# 7. Executes selected scope (Design/Code/Docs/Merge)
# 8. Returns final summary

# Manual mode (bypass orchestrator):
/init-feature  # Direct feature initialization
/design        # Direct design phase
/code 1        # Direct phase execution
```
```

### 5. Add Orchestrator Section to README

Add new section explaining orchestrator:
```markdown
## Orchestrator

The orchestrator agent (`agents/orchestrator.md`) is the central controller that:

- **Manages entire workflow** from init to merge
- **Coordinates subagents** via Task tool
- **Enables parallel execution** for parallel phases
- **Tracks state** for resumability

### Workflow Control

Orchestrator executes 16-step workflow:
1. Work type selection
2. Requirements gathering
3. Branch/directory setup
4. Target version selection
5. SPEC.md creation
6. SPEC review
7. SPEC commit
8. Scope selection
9-16. Execution based on scope
```

### 6. Verify Consistency

Check all README references:
- [ ] Skill names match actual files
- [ ] Agent names match actual files
- [ ] Workflow diagrams accurate
- [ ] No broken links

## Completion Checklist
- [ ] README.md workflow section updated
- [ ] README.md agents table updated with orchestrator
- [ ] README.md skills table updated
- [ ] README.md usage section updated
- [ ] New Orchestrator section added
- [ ] All references verified

## Notes
- Keep README concise
- Focus on user-facing documentation
- Ensure examples are accurate
