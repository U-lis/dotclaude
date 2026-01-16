# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.7] - 2026-01-16

### Added

- Non-Stop Execution feature for init-workflow
- Execution Rules for automatic skill chaining
- Scope-to-Skill Chain Mapping table
- CLAUDE.md Rule Overrides for chained execution
- Progress Indicator format for multi-skill execution
- Final Summary Report format after workflow completion

## [0.0.6] - 2026-01-16

### Added

- Three-level dependency analysis (file/module/test) to Designer agent
- Explicit parallelization criteria table for phase identification
- Conflict prediction section for parallel phase merge planning
- Enhanced handoff requirements for parallel phases

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
