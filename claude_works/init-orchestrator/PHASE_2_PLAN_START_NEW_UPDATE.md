# Phase 2: Update start-new Skill

## Objective
Update `skills/start-new/SKILL.md` to become minimal entry point that calls orchestrator.

## Prerequisites
- Phase 1 completed (orchestrator.md exists)

## Instructions

### 1. Read Current File
Read `.claude/skills/start-new/SKILL.md` to understand current structure.

### 2. Update Description
Change skill description in YAML frontmatter:
```yaml
description: Entry point for starting new work. Calls orchestrator agent to manage entire workflow.
```

### 3. Simplify Workflow Section
Replace current workflow with minimal version:
```
User: /start-new
         ↓
Task tool → Orchestrator Agent
         ↓
Orchestrator manages entire workflow
         ↓
Display final summary to user
```

### 4. Remove Routing Logic
Remove the "Routing" section that routes to init-xxx skills.
Orchestrator handles work type selection internally.

### 5. Update Trigger Section
Keep trigger description but simplify:
```
User invokes `/start-new` to begin any new work.
```

### 6. Add Orchestrator Call Section
Add new section explaining orchestrator call:
```markdown
## Orchestrator Call

Invoke orchestrator agent via Task tool:
- subagent_type: use appropriate type for orchestrator
- prompt: "Execute full development workflow"

Orchestrator handles:
- Work type selection
- Requirements gathering
- SPEC.md creation
- Scope selection
- Design, code, docs, merge
```

### 7. Update Next Steps Section
Replace with:
```markdown
## Next Steps

Orchestrator returns final summary including:
- Status (SUCCESS/PARTIAL/FAILED)
- Phases completed
- Issues encountered
- Recommended next steps

Display summary to user.
```

### 8. Remove Question Section
Remove the "Question" section (work type question).
Orchestrator asks this.

### 9. Keep Manual Override Note
Add note about manual skill invocation:
```markdown
## Manual Mode

Individual skills remain invocable for debugging:
- `/init-feature` - direct feature init
- `/init-bugfix` - direct bugfix init
- `/init-refactor` - direct refactor init
- `/design` - direct design
- `/code [phase]` - direct code execution
```

## Completion Checklist
- [ ] YAML frontmatter description updated
- [ ] Workflow simplified to orchestrator call
- [ ] Routing logic removed
- [ ] Orchestrator call section added
- [ ] Question section removed
- [ ] Next steps section updated
- [ ] Manual override note added
- [ ] File saved

## Notes
- Preserve YAML frontmatter structure
- Keep skill name and user-invocable flag
- Ensure minimal, focused content
