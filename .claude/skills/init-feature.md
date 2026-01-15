---
name: init-feature
description: Initialize a new feature by gathering requirements and creating SPEC document. Use when starting a new feature, project initialization, or when user invokes /init-feature.
user-invocable: true
---

# /init-feature

Initialize a new feature by gathering requirements and creating initial SPEC document.

## Trigger

User invokes `/init-feature` or requests to start a new feature/project.

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Gather Requirements                                  │
│    - Ask about project purpose                          │
│    - Identify core features                             │
│    - Clarify constraints and non-functional requirements│
│    - Determine {keyword} for branch naming              │
├─────────────────────────────────────────────────────────┤
│ 2. Create Feature Branch                                │
│    - Confirm {keyword} with user                        │
│    - git checkout -b feature/{keyword}                  │
│    - This becomes base branch for all worktrees         │
├─────────────────────────────────────────────────────────┤
│ 3. Create Project Structure                             │
│    - mkdir -p claude_works/{subject}                    │
├─────────────────────────────────────────────────────────┤
│ 4. Draft SPEC.md                                        │
│    - Use TechnicalWriter agent                          │
│    - Write initial specification                        │
├─────────────────────────────────────────────────────────┤
│ 5. Review with User                                     │
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

### Branch Naming
- Confirm the {keyword} for `feature/{keyword}` branch name

## Output

1. Feature branch `feature/{keyword}` created and checked out
2. Create `claude_works/{subject}/SPEC.md` with:
   - Overview
   - Functional Requirements (as checklist)
   - Non-Functional Requirements
   - Constraints
   - Out of Scope

## Next Steps

After SPEC is approved:
1. Proceed to `/design` to create detailed implementation plan
2. Or manually refine SPEC further if needed
