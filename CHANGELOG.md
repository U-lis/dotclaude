# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-27

### Added

- `/dotclaude:configure` command for interactive configuration management
- Global configuration support (`~/.claude/dotclaude-config.json`)
- Local configuration support (`<project_root>/.claude/dotclaude-config.json`)
- Configuration settings: `language`, `working_directory`, `check_version`, `auto_update`, `base_branch`
- Working directory migration workflow when changing `working_directory` setting
- SessionStart hook (`init-config.sh`) for automatic default configuration initialization
- Configuration loading with merge strategy (local overrides global)
- Configuration section in README.md with examples and use cases

### Changed

- All skills now use configurable `{working_directory}` instead of hard-coded `claude_works/`
- Working directory is now customizable per-project or globally (default: `.dc_workspace`)
- Base branch for git operations is now configurable (default: `main`)

### Fixed

- Subagent delegation in `/dotclaude:start-new` workflow ([#5](https://github.com/U-lis/dotclaude/issues/5))
  - Orchestrator now properly delegates work to subagents via Task tool instead of reading agent definition files and executing inline
  - Added Delegation Enforcement section with explicit MUST/FORBIDDEN rules
  - Converted all pseudo-code patterns to imperative Task tool invocations for TechnicalWriter, Designer, Coder, and code-validator agents
  - Ensures consistent agent separation principle across all workflow phases

### Technical

- Configuration files use JSON format
- Configuration loading includes graceful error handling
- Invalid JSON falls back to default values without breaking skills
- Path validation prevents security issues (absolute paths, parent traversal rejected)

## [0.1.2] - 2026-01-27

### Fixed

- Command naming: removed `dc:` prefix from command filenames
  - Before: `/dotclaude:dc:start-new` (duplicate prefix)
  - After: `/dotclaude:start-new` (clean format)

## [0.1.1] - 2026-01-26

### Added

- `commands/` directory for autocomplete support
  - Skills now appear in `/` autocomplete menu (dc:start-new, dc:design, etc.)
  - Command files are thin wrappers that reference corresponding SKILL.md
- `CLAUDE.md` development guidelines
  - Clarifies distinction between source files and installed plugin cache
  - Prevents accidental modification of installed plugin files

### Fixed

- Plugin marketplace installation error: "skills: Invalid input"
  - Migrated to standard plugin directory structure (skills/, agents/, templates/ at root)
  - Removed invalid `skills` field from plugin.json
  - Updated all internal path references
- Skills not appearing in autocomplete when typing `/`
  - Added `commands/` directory following claude-hud pattern

### Changed

- SKILL.md `name` field no longer includes `dc:` prefix
  - `dc:` prefix now only in command filenames (commands/dc:*.md)
  - Prevents duplication in display

## [0.1.0] - 2026-01-23

### Added

- Plugin marketplace support for simplified installation ([#1](https://github.com/U-lis/dotclaude/issues/1), [#6](https://github.com/U-lis/dotclaude/issues/6)):
  - `.claude-plugin/marketplace.json`: Registry metadata for Claude Code marketplace
  - `.claude-plugin/plugin.json`: Plugin configuration with skills path
  - `hooks/hooks.json`: Hook configuration using `${CLAUDE_PLUGIN_ROOT}` for portable paths
  - Installation via `/plugin marketplace add` and `/plugin install dotclaude` commands
  - Dual installation support: Plugin marketplace (recommended) or manual (`cp -r`)
  - Installation guide in README with Plugin vs Manual options
- SessionStart hook (`check-update.sh`): Automatically checks for updates on session start and notifies if newer version available

### Removed

- `/dotclaude:update` skill: Use `/plugin update dotclaude` instead
- `/dotclaude:version` skill: Use `claude plugin list` instead

## [0.0.12] - 2026-01-23

### Added

- GitHub Issue integration for `/dc:start-new` workflow:
  - "GitHub Issue" option in Step 1 work type selection
  - `init-github-issue.md`: New init file for GitHub issue-based workflow
  - Issue parsing via `gh` CLI (title, body, labels, milestone)
  - Label-based work type auto-detection (`bug` → bugfix, `enhancement` → feature, `refactor` → refactor)
  - Body keyword analysis fallback when labels are missing or ambiguous
  - Milestone → target_version auto-mapping
  - Context pre-population for downstream init workflows
  - Graceful error handling with fallback to manual workflow

## [0.0.11] - 2026-01-23

### Added

- `.gitignore` with `CLAUDE.md` entry to prevent file conflicts during updates

### Changed

- Migrated CLAUDE.md rules to appropriate agent/skill files:
  - `skills/start-new/SKILL.md`: Evidence-based responses, completion reporting rules
  - `skills/start-new/init-*.md`: DDD context, clarification required rules
  - `agents/designer.md`: YAGNI/Occam's Razor, clarification required rules
  - `agents/coders/_base.md`: Man pages consultation, git reset --hard FORBIDDEN rules

### Removed

- `CLAUDE.md` from version control (rules distributed to agents/skills)

## [0.0.10] - 2026-01-22

### Added

- `/dotclaude:version` skill: Display installed vs latest dotclaude version
- `/dotclaude:update` skill: Update dotclaude framework with shallow clone-based file tracking
- `.dotclaude-manifest.json`: Tracks all dotclaude-managed files for safe updates
- Manifest-based update system: File-level updates preserve user customizations
- Smart settings.json merge: Adds new keys from upstream while preserving local values
- Backup and rollback: Automatic backup before update, restore on failure
- User confirmation required before any update changes
- Changelog preview in update flow

### Changed

- `dc:` prefix applied to all workflow skills (`/dc:start-new`, `/dc:design`, `/dc:code`, etc.)
- Orchestrator integrated into `/dc:start-new` skill (previously separate agent)
- Init workflow files moved to `skills/start-new/` directory:
  - `_analysis.md`: Common analysis phases
  - `init-feature.md`, `init-bugfix.md`, `init-refactor.md`: Work type instructions
- Skills directory now includes `dotclaude/` namespace for framework management skills

### Removed

- `agents/orchestrator.md`: Merged into `skills/start-new/SKILL.md`
- `agents/_shared/`: Moved to `skills/start-new/`
- `agents/init-xxx.md`: Moved to `skills/start-new/init-xxx.md`
- `skills/init-xxx/SKILL.md`: Replaced by integrated init workflow
- `hooks/check-init-complete.sh`: No longer needed with integrated workflow

## [0.0.9] - 2026-01-21

### Fixed

- Orchestrator not using AskUserQuestion tool in Step 1: Added explicit "CRITICAL" instruction, prohibited text tables and number typing, clarified tool call parameters format
- Orchestrator not calling init-xxx agents in Step 2: Added "CRITICAL" instruction with "MUST call init agent via Task tool", added "PROHIBITED" section, added mapping table for work type → agent selection
- Orchestrator assuming tools are unavailable: Added "IMPORTANT: All these tools ARE available to you" statement in Capabilities section, emphasized "YOU HAVE THIS TOOL. USE IT." for AskUserQuestion
- Missing target version question in `/dc:start-new` workflow (now asks before SPEC creation)

### Added

- init-xxx agents: `init-feature.md`, `init-bugfix.md`, `init-refactor.md` in agents directory
- Hybrid pattern: thin wrapper skills delegate to full-logic agents
- `agents/_shared/` directory for shared workflow files
- Output Contract section to init-xxx agents for structured return values
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
- `/update-docs` skill for documentation updates (CHANGELOG, README)
- TechnicalWriter DOCS_UPDATE role for structured documentation updates
- Init Phase Attitude section in init-workflow.md clarifying init-xxx scope
- Frontmatter to `update-docs/SKILL.md` (was missing)

### Changed

- start-new/SKILL.md: Rule 2 now explicitly requires "call init-xxx agent via Task tool for Step 2", added "IMPORTANT" box clarifying orchestrator must not ask questions directly
- Orchestrator Subagent Call Patterns: Init Agents section now references Step 2 instead of duplicating content
- init-xxx skills reduced from ~200 lines to ~60 lines (thin wrappers)
- Orchestrator now calls init-xxx agents via Task tool (previously Skill tool)
- `_shared/` directory moved from `skills/` to `agents/`
- Orchestrator Step 2 now invokes init-xxx agents via Task tool instead of skills
- Orchestrator workflow reduced from 16 to 13 steps (init questions, branch setup, version selection, SPEC creation delegated to init-xxx)
- init-feature: Added feature-specific analysis (similar functionality, modification points, patterns)
- init-bugfix: Enhanced existing analysis with recent change correlation, conflict detection, edge cases
- init-refactor: Added refactor-specific analysis (dependency graph, test coverage, behavior preservation)
- init-workflow step numbers updated (5→9 total steps)
- All init skills now reference `_shared/analysis-phases.md` for common analysis
- Orchestrator now owns full workflow control (routing, non-stop execution, progress reporting)
- init-workflow.md reduced by ~40% (Steps 1-8 only, routing/execution moved to orchestrator)
- init-xxx SKILL.md files now include Invocation Behavior section (direct vs orchestrator call)
- Orchestrator routing table updated to show step numbers instead of skill names
- Orchestrator Step 11 (Docs) now uses Task tool → TechnicalWriter instead of Skill tool
- Orchestrator Step 12 (Merge) clarified as direct Bash execution
- Orchestrator now explicitly prohibits Skill tool usage for workflow execution
- All skill commands renamed with `dc:` prefix for namespace identification (`/start-new` → `/dc:start-new`, `/code` → `/dc:code`, `/design` → `/dc:design`, `/validate-spec` → `/dc:validate-spec`, `/tagging` → `/dc:tagging`, `/merge-main` → `/dc:merge-main`, `/update-docs` → `/dc:update-docs`)
- `/dc:start-new` workflow now includes target version question (Step 2.6) before SPEC.md creation
- Target version question now shows recent 3 versions from CHANGELOG with key changes before asking

### Removed

- `agents/orchestrator.md` - integrated into `skills/start-new/SKILL.md`
- `agents/init-feature.md`, `agents/init-bugfix.md`, `agents/init-refactor.md` - moved to `skills/start-new/`
- `agents/_shared/init-workflow.md` - merged into `skills/start-new/SKILL.md`
- `agents/_shared/analysis-phases.md` - moved to `skills/start-new/_analysis.md`
- `.claude/hooks/check-init-complete.sh` - validation now in SKILL.md Step 6 checkpoint
- `skills/init-feature/`, `skills/init-bugfix/`, `skills/init-refactor/` directories - consolidated into start-new
- Question Sets section from orchestrator.md (now handled by init instructions)
- CHANGELOG rules from CLAUDE.md (now handled by /dc:update-docs + TechnicalWriter)

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
