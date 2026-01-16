# Workflow: Merge-Main & Tagging Skills

## Overview

Add `/merge-main` and `/tagging` slash commands to complete the workflow pipeline. Remove deprecated `/finalize` skill.

### Problem

Current workflow lacks:
1. Proper feature-to-main merge with branch cleanup
2. Version tagging automation based on CHANGELOG

### Goal

- `/merge-main {branch}`: Merge feature branch to main, resolve conflicts, cleanup branch
- `/tagging`: Verify/update version, create git tag based on CHANGELOG

## Functional Requirements

### FR-1: `/merge-main` Command

| ID | Requirement |
|----|-------------|
| FR-1.1 | Accept optional branch argument (default: current branch) |
| FR-1.2 | Checkout main, pull latest |
| FR-1.3 | Merge feature branch with conflict resolution guidance |
| FR-1.4 | Run test suite after merge |
| FR-1.5 | Delete merged feature branch (local) |
| FR-1.6 | (Optional) Offer PR creation instead of direct merge |

### FR-2: `/tagging` Command

| ID | Requirement |
|----|-------------|
| FR-2.1 | Parse CHANGELOG.md to find latest version |
| FR-2.2 | Compare with latest git tag |
| FR-2.3 | If version mismatch, prompt for version bump commit |
| FR-2.4 | Create annotated git tag |
| FR-2.5 | Display tag summary and next steps (manual push) |

### FR-3: Remove `/finalize`

| ID | Requirement |
|----|-------------|
| FR-3.1 | Delete .claude/skills/finalize/ directory |
| FR-3.2 | Remove /finalize references from other skill files |
| FR-3.3 | Update /code SKILL.md to reference /merge-main instead |

## Non-Functional Requirements

### NFR-1: Token Efficiency

- Keep SKILL.md files concise
- No redundant instructions or verbose descriptions
- Reference shared docs instead of duplicating

### NFR-2: Safety

- Prevent direct commits to main branch
- No force push operations
- Require user confirmation for destructive actions

## Constraints

- Follow existing skill file structure pattern
- Maintain consistency with current workflow (init → design → code → merge-main → tagging)
- No automatic remote push (user must push manually)

## Out of Scope

- Automatic remote push after merge/tagging
- CI/CD integration
- Multi-repo support
