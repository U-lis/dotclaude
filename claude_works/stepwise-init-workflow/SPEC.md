# Stepwise Init Workflow - Specification

## Overview

**Purpose**: Restructure init workflow to use step-by-step questioning and add work type routing

**Problem**: Current /init-feature asks all questions at once, which is overwhelming and doesn't support different work types (bugfix, refactor)

**Solution**:
1. Add /start-new as entry point that routes to appropriate init skill
2. Convert all init-* skills to one-by-one step questions
3. Add next action selection after SPEC approval

---

## Functional Requirements

### Core Features
- [ ] FR-1: Create /start-new skill as router for work type selection
- [ ] FR-2: Update /init-feature with step-by-step questions (8 steps)
- [ ] FR-3: Create /init-bugfix skill with step-by-step questions (6 steps)
- [ ] FR-4: Create /init-refactor skill with step-by-step questions (6 steps)
- [ ] FR-5: Add "Next Step Selection" to all init-* skills after SPEC approval
- [ ] FR-6: Auto-generate branch keyword from conversation context (no user question)

### Secondary Features
- [ ] FR-7: Phase selection uses "Phase X까지" format (single select, includes all previous phases)
- [ ] FR-8: "전부 다" option appears at top of phase selection list

---

## Non-Functional Requirements

### Usability
- [ ] NFR-1: Questions use Korean for user-facing text
- [ ] NFR-2: Each question provides clear options where applicable
- [ ] NFR-3: Free text allowed via "직접입력" or "Other" option

### Consistency
- [ ] NFR-4: All init-* skills follow same step-by-step pattern
- [ ] NFR-5: Branch naming follows convention: feature/{keyword}, bugfix/{keyword}, refactor/{keyword}

---

## Constraints

### Technical Constraints
- File format: Markdown with YAML frontmatter (SKILL.md)
- Location: .claude/skills/{skill-name}/SKILL.md
- Tool: Must use AskUserQuestion tool for step-by-step questions

### Design Constraints
- Follow existing skill structure pattern in codebase
- Maintain compatibility with existing /design, /code, /finalize workflow

---

## Out of Scope

The following are explicitly NOT part of this work:
- Hook-based implementation (decided to use skill-internal approach)
- Changes to /design, /code, /finalize skills
- Changes to agent definitions (.claude/agents/)
- Changes to templates (.claude/templates/)

---

## Assumptions

- AskUserQuestion tool supports both single-select and multi-select options
- Skill tool can invoke other skills by name
- User will follow /start-new → init-* → /design → /code workflow

---

## Open Questions

- [x] Hook vs Skill-internal for next step selection → Decided: Skill-internal
- [x] Branch keyword: ask user vs auto-generate → Decided: Auto-generate
- [x] Phase selection: checkbox vs radio → Decided: Radio ("Phase X까지")

---

## References

- Plan file: ~/.claude/plans/vast-wibbling-starlight.md
- Existing skills: .claude/skills/init-feature/SKILL.md
- Templates: .claude/templates/SPEC.md
