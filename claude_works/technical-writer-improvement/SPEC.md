# Technical Writer Improvement - Specification

## Overview

Improve TechnicalWriter agent with SOT awareness and mandatory document commit workflow.

### Problem

1. SPEC.md is the Source of Truth (SOT), but TechnicalWriter may omit requirements or use ambiguous expressions
2. Documents created by TechnicalWriter are not committed before proceeding to next workflow step

### Solution

1. Add explicit SOT awareness rules to TechnicalWriter agent
2. Add mandatory git commit step after document creation in all init-* and design workflows

## Functional Requirements

- [ ] FR-1: TechnicalWriter recognizes SPEC.md as SOT
- [ ] FR-2: TechnicalWriter captures ALL discussed requirements without omission
- [ ] FR-3: TechnicalWriter uses precise, unambiguous language
- [ ] FR-4: TechnicalWriter flags uncertain requirements in "Open Questions" section
- [ ] FR-5: init-feature workflow commits SPEC.md after creation
- [ ] FR-6: init-bugfix workflow commits SPEC.md after creation
- [ ] FR-7: init-refactor workflow commits SPEC.md after creation
- [ ] FR-8: design workflow commits all documents after creation

## Non-Functional Requirements

- [ ] NFR-1: SKILL.md files remain concise to minimize token consumption
- [ ] NFR-2: No duplicate instructions with CLAUDE.md

## Constraints

- Keep SKILL.md files concise and clear
- Maintain existing formatting style
- Follow existing workflow patterns

## Out of Scope

- Changes to other agents
- Changes to code execution workflows
- Changes to finalize workflow (already has commit step)

## Open Questions

None.
