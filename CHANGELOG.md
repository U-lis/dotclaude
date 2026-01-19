# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.9] - 2026-01-19

### Added

- Smart Init: Intelligent requirements analysis for all init-xxx skills
- `_shared/analysis-phases.md`: Common analysis workflow with 5 phases (A-E)
- Analysis Phase (Step 5) added to shared init-workflow between structure creation and SPEC drafting
- Input Analysis (Step A): Detect gaps, ambiguities, conflicting statements in user input
- Codebase Investigation (Step B): Search for related code, patterns, and modification points
- Conflict Detection (Step C): Compare requirements vs existing implementation
- Edge Case Generation (Step D): Generate boundary conditions and error scenarios
- Summary + Clarification (Step E): Iterative user confirmation loop (max 3 iterations)
- Iteration limits to prevent infinite loops (5 questions/category, 3 iterations, 10 file reads)
- Analysis Results section in SPEC.md with Related Code, Conflicts, Edge Cases tables

### Changed

- init-feature: Added feature-specific analysis (similar functionality, modification points, patterns)
- init-bugfix: Enhanced existing analysis with recent change correlation, conflict detection, edge cases
- init-refactor: Added refactor-specific analysis (dependency graph, test coverage, behavior preservation)
- init-workflow step numbers updated (5→9 total steps)
- All init skills now reference `_shared/analysis-phases.md` for common analysis

## [0.0.8] - 2026-01-19

### Added

- Master Orchestrator agent (`agents/orchestrator.md`) for central workflow control
- 16-step workflow from init to merge managed by orchestrator
- Target version selection step (shows latest 5 versions from CHANGELOG)
- Parallel execution support via simultaneous Task tool calls
- State management for workflow resumability
- Output contract (YAML) for structured summary

### Changed

- `/start-new` now calls orchestrator agent instead of routing to init-xxx skills
- Workflow diagram in README.md updated for orchestrator pattern
- Agents table in README.md includes Orchestrator
- Skills table updated to show manual mode for init-xxx skills

## [0.0.7] - 2026-01-19

### Fixed

- `/init-bugfix` missing codebase analysis step before SPEC.md creation
- SPEC.md now includes AI analysis results (root cause, affected code, fix strategy)

### Added

- "Codebase Analysis (MANDATORY)" section to `/init-bugfix` skill
- Two-part SPEC.md structure: User-Reported Information + AI Analysis Results
- Workflow Summary section documenting complete execution flow
- Inconclusive analysis handling documentation

## [0.0.6] - 2026-01-16

### Added

- Mandatory Validation section to /code skill with enforcement language
- MUST rules for code-validator checklist updates
- `check-validation-complete.sh` Stop hook for validation enforcement
- Pre-Commit Checklist to /code skill
- Non-Stop Execution feature for init-workflow
- Execution Rules for automatic skill chaining
- Scope-to-Skill Chain Mapping table
- CLAUDE.md Rule Overrides for chained execution
- Progress Indicator format for multi-skill execution
- Final Summary Report format after workflow completion
- Three-level dependency analysis (file/module/test) to Designer agent
- Explicit parallelization criteria table for phase identification
- Conflict prediction section for parallel phase merge planning
- Enhanced handoff requirements for parallel phases

### Changed

- code-validator "Checklist Update Authority" section now MANDATORY

## [0.0.5] - 2026-01-16

### Added

- `/merge-main` skill for feature-to-main merge with conflict resolution and branch cleanup
- `/tagging` skill for CHANGELOG-based version tagging
- `check-init-complete.sh` Stop hook for workflow enforcement
- SPEC.md SOT awareness rules to TechnicalWriter agent
- Mandatory commit steps to design/init-xxx workflows
- Plan Mode Policy to init-xxx skills (must NOT use EnterPlanMode)

### Fixed

- Stop hook infinite loop on main branch after /merge-main

### Changed

- Next Step Selection to cumulative sequential flow (Design → Code → CHANGELOG → Merge)
- Extract common init workflow to `_shared/init-workflow.md`
- Slim down init-xxx SKILL.md files (-28% lines, ~350 duplicate lines removed)
- Updated `/code` SKILL.md to reference new workflow (/merge-main → /tagging)

### Removed

- `/finalize` skill (replaced by /merge-main and /tagging)

## [0.0.4] - 2026-01-16

### Added

- `/start-new` skill as entry point for all new work (routes to init-feature/bugfix/refactor)
- `/init-bugfix` skill for bug fix workflow with 6-step questions
- `/init-refactor` skill for refactoring workflow with 6-step questions
- Step-by-step question gathering for all init skills using AskUserQuestion tool
- Next Step Selection routing after SPEC.md approval

### Fixed

- Workflow bypass bug in init-xxx skills when using plan mode with permission bypass
- Added "Mandatory Workflow Rules" section to all init-xxx skills
- Steps 5-7 (SPEC.md creation, user review, Next Step Selection) are now explicitly mandatory

### Changed

- Updated README.md to document all init skills and /code all option

## [0.0.3] - 2026-01-15

### Added

- `/code all` option for automatic execution of all phases without user intervention
- Phase detection algorithm (GLOBAL.md parsing with file system fallback)
- Topological sort for dependency-based execution order
- Parallel phase support with git worktree isolation
- Comprehensive execution report format

### Changed

- Updated `/code` skill description to include `all` argument

## [0.0.2] - 2026-01-15

### Changed

- Rename `/init-project` skill to `/init-feature`
- Add feature branch creation step (`feature/{keyword}`) before SPEC.md generation
- Add YAML frontmatter to all skills for Claude Code recognition

## [0.0.1] - 2026-01-15

### Added

- Initial multi-agent workflow system
- Agent definitions: Designer, TechnicalWriter, spec-validator, code-validator
- Language-specific coders: Python, JavaScript, Svelte, Rust, SQL
- Skills: /init-project, /design, /validate-spec, /code, /finalize
- Document templates: SPEC, GLOBAL, PHASE_PLAN, PHASE_TEST, PHASE_MERGE
- Global rules (CLAUDE.md) for all agents
