# /init-project

Initialize a new project by gathering requirements and creating initial SPEC document.

## Trigger

User invokes `/init-project` or requests to start a new feature/project.

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Requirements                                  │
│    - Ask about project purpose                          │
│    - Identify core features                             │
│    - Clarify constraints and non-functional requirements│
├─────────────────────────────────────────────────────────┤
│ 2. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 3. Draft SPEC.md                                        │
│    - Use TechnicalWriter agent                          │
│    - Write initial specification                        │
├─────────────────────────────────────────────────────────┤
│ 4. Review with User                                     │
│    - Present SPEC draft                                 │
│    - Iterate based on feedback                          │
└─────────────────────────────────────────────────────────┘
```

## Questions to Ask

### Project Purpose
- What is the main goal of this feature/project?
- What problem does it solve?

### Core Features
- What are the must-have features?
- What are nice-to-have features?

### Constraints
- Are there any technical constraints? (language, framework, etc.)
- Are there performance requirements?
- Are there security considerations?

### Scope
- What is explicitly out of scope?
- What are the boundaries of this work?

## Output

Create `claude_works/{subject}/SPEC.md` with:
- Overview
- Functional Requirements (as checklist)
- Non-Functional Requirements
- Constraints
- Out of Scope

## Next Steps

After SPEC is approved:
1. Proceed to `/design` to create detailed implementation plan
2. Or manually refine SPEC further if needed
