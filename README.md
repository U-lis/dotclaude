# dotclaude

A multi-agent development workflow system for Claude Code.

## Overview

This repository provides a structured workflow for software development using specialized AI agents. The system enables:

- Systematic project planning and specification
- Parallel development with git worktrees
- Automated code validation
- Language-specific coding standards
- **Orchestrator-managed workflow** from init to merge

## Structure

```
.
├── CLAUDE.md                    # Development guidelines
├── .claude/
│   └── dotclaude-config.json    # Plugin configuration
├── .claude-plugin/              # Plugin marketplace metadata
│   ├── marketplace.json         # Registry metadata
│   └── plugin.json              # Plugin configuration
├── commands/                    # Self-contained command files
│   ├── configure.md             # /dotclaude:configure
│   ├── start-new.md             # /dotclaude:start-new (entry point + orchestrator)
│   ├── design.md                # /dotclaude:design
│   ├── code.md                  # /dotclaude:code [phase]
│   ├── merge-main.md            # /dotclaude:merge-main
│   ├── pr.md                    # /dotclaude:pr
│   ├── tagging.md               # /dotclaude:tagging
│   ├── update-docs.md           # /dotclaude:update-docs
│   ├── validate-spec.md         # /dotclaude:validate-spec
│   ├── purge.md                 # /dotclaude:purge
│   ├── init-feature.md          # Internal: feature init (user-invocable: false)
│   ├── init-bugfix.md           # Internal: bugfix init (user-invocable: false)
│   ├── init-refactor.md         # Internal: refactor init (user-invocable: false)
│   ├── init-github-issue.md     # Internal: GitHub issue init (user-invocable: false)
│   └── _analysis.md             # Internal: common analysis phases (user-invocable: false)
├── agents/                      # Agent definitions (frontmatter-enabled)
│   ├── designer.md              # Architecture and planning
│   ├── technical-writer.md      # Documentation
│   ├── spec-validator.md        # Specification validation
│   ├── code-validator.md        # Code quality validation
│   └── coders/                  # Language-specific coders
│       ├── _base.md             # Common coder rules
│       ├── python.md            # Python specialist
│       ├── javascript.md        # JS/TS specialist
│       ├── svelte.md            # Svelte specialist
│       ├── rust.md              # Rust specialist
│       └── sql.md               # SQL/DB specialist
├── templates/                   # Document templates
│   ├── SPEC.md
│   ├── GLOBAL.md
│   ├── PHASE_PLAN.md
│   ├── PHASE_TEST.md
│   └── PHASE_MERGE.md
├── hooks/                       # Hook scripts
│   ├── hooks.json               # Hook configuration
│   ├── init-config.sh           # SessionStart config initializer
│   ├── check-update.sh          # SessionStart update checker
│   └── check-validation-complete.sh  # Validation completion checker
└── {working_directory}/         # Working documents (configurable, default: .dc_workspace)
```

## Workflow

```
User → /dotclaude:start-new → Orchestrator Agent
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

## Orchestrator

The orchestrator workflow is integrated into `/dotclaude:start-new` command (`commands/start-new.md`):

- **Manages entire workflow** from init to merge
- **Coordinates subagents** via Task tool
- **Enables parallel execution** for parallel phases
- **Tracks state** for resumability

### 13-Step Workflow

| Step | Phase | Description |
|------|-------|-------------|
| 1 | Init | Work type selection |
| 2 | Init | Load init instructions (questions, analysis, target version, branch, SPEC) |
| 3 | Init | SPEC review |
| 4 | Init | SPEC commit |
| 5 | Init | Scope selection |
| 6 | Design | Designer analysis |
| 7 | Design | Document creation via TechnicalWriter |
| 8 | Design | Design commit |
| 9 | Code | Phase list parsing |
| 10 | Code | Phase execution (sequential/parallel) |
| 11 | Docs | Documentation update |
| 12 | Merge | Merge to main |
| 13 | Final | Summary return |

## Skills (Commands)

All dotclaude skills are prefixed with `dotclaude:` namespace:

| Command | Description |
|---------|-------------|
| `/dotclaude:configure` | Interactive configuration management |
| `/dotclaude:start-new` | Entry point - calls orchestrator for full workflow |
| `/dotclaude:design` | Transform SPEC into implementation plan |
| `/dotclaude:validate-spec` | Validate document consistency (optional) |
| `/dotclaude:code [phase]` | Execute coding for specified phase |
| `/dotclaude:code all` | Execute all phases automatically |
| `/dotclaude:merge-main` | Merge feature branch to main |
| `/dotclaude:pr` | Create GitHub Pull Request from current branch |
| `/dotclaude:tagging [version]` | Create version tag with push enforcement and version consistency checks |
| `/dotclaude:update-docs` | Update documentation (CHANGELOG, README) |
| `/dotclaude:purge` | Clean up merged branches and orphaned worktrees |

## Agents

| Agent | Role |
|-------|------|
| Designer | Technical architecture and phase decomposition |
| TechnicalWriter | Structured documentation |
| spec-validator | Document consistency validation |
| code-validator | Code quality + plan verification |
| Coders | Language-specific implementation |

Agents have YAML frontmatter (`name`, `description`) and can be invoked directly via `dotclaude:{agent-name}` pattern.

Note: Orchestrator workflow is now integrated into `/dotclaude:start-new` command.

## Document Types

### Simple Tasks (1-2 phases)
```
{working_directory}/{SUBJECT}.md
```

### Complex Tasks (3+ phases)
```
{working_directory}/{subject}/
├── SPEC.md                      # Requirements (What)
├── GLOBAL.md                    # Architecture, phase overview
├── PHASE_1_PLAN_{keyword}.md    # Implementation plan
├── PHASE_1_TEST.md              # Test cases
└── ...
```

### Parallel Phases
```
├── PHASE_3A_PLAN_{keyword}.md   # Parallel work A
├── PHASE_3B_PLAN_{keyword}.md   # Parallel work B
├── PHASE_3.5_PLAN_MERGE.md      # Merge phase (required)
```

## Phase Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Sequential | `PHASE_{k}` | PHASE_1, PHASE_2 |
| Parallel | `PHASE_{k}{A\|B\|C}` | PHASE_3A, PHASE_3B |
| Merge | `PHASE_{k}.5` | PHASE_3.5 |

## Configuration

dotclaude supports both global and per-project configuration.

### Configuration Files

| Scope | Location | Description |
|-------|----------|-------------|
| Global | `~/.claude/dotclaude-config.json` | Applies to all projects |
| Local | `<project_root>/.claude/dotclaude-config.json` | Project-specific overrides |

Configuration merge order: **Defaults < Global < Local**

### Configuration Command

```bash
/dotclaude:configure
```

Interactive workflow to edit settings at global or local scope. Changes take effect immediately.

### Available Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `language` | string | `en_US` | Language for conversations and documents |
| `working_directory` | string | `.dc_workspace` | Directory for work files (relative to project root) |
| `check_version` | boolean | `true` | Check for plugin updates on session start |
| `auto_update` | boolean | `false` | Auto-update when update available |
| `base_branch` | string | `main` | Default base branch for git operations |

### Configuration File Format

```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main"
}
```

### Common Use Cases

**Change working directory globally:**
```bash
/dotclaude:configure → Global → Set working_directory to "docs"
```

**Per-project working directory:**
```bash
/dotclaude:configure → Local → Set working_directory to "project_docs"
```

**Different base branch:**
```bash
/dotclaude:configure → Set base_branch to "develop"
```

## Installation

### Option 1: Plugin Marketplace (Recommended)

Install dotclaude via Claude Code's plugin marketplace:

```bash
# Add the marketplace repository (first time only)
/plugin marketplace add https://github.com/U-lis/dotclaude

# Install the plugin
/plugin install dotclaude
```

### Option 2: Manual Installation

For direct control or customization, clone and copy manually:

```bash
git clone https://github.com/U-lis/dotclaude.git
cp -r dotclaude/.claude your-project/
```

**Note**: For updates, use `/plugin update dotclaude` (plugin installation) or re-clone and copy (manual installation).

## Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) - Required for `/dotclaude:pr` command
  - Install: `brew install gh` (macOS) or see [installation guide](https://github.com/cli/cli#installation)
  - Authenticate: `gh auth login`

## Usage

### Start New Work

```bash
# In Claude Code session
/dotclaude:start-new

# Orchestrator takes over:
# 1. Asks work type (Feature/Bugfix/Refactor/GitHub Issue)
# 2. Gathers requirements via step-by-step questions
#    - If GitHub Issue: parses issue URL, auto-detects type, pre-populates fields
# 3. Asks target version (auto-filled from milestone if GitHub Issue)
# 4. Creates and reviews SPEC with user
# 5. Asks execution scope
# 6. Executes selected scope (Design/Code/Docs/Merge)
# 7. Returns final summary

# After merge, create version tag (verifies version consistency, pushes automatically):
/dotclaude:tagging
# Or specify version explicitly:
/dotclaude:tagging 0.3.0
```

### Update dotclaude

```bash
# Update via plugin marketplace
/plugin update dotclaude
```

Note: Restart Claude Code after updating to apply changes.

### Manual Execution (Bypass Orchestrator)

Individual skills can be invoked directly for debugging or partial work:

```bash
/dotclaude:design           # Create implementation plan
/dotclaude:validate-spec    # Validate document consistency
/dotclaude:code 1           # Implement Phase 1
/dotclaude:code all         # Implement all phases
/dotclaude:update-docs      # Update documentation
/dotclaude:merge-main       # Merge to main
/dotclaude:tagging          # Create version tag (with push + version checks)
/dotclaude:tagging 0.3.0   # Create tag for specific version
/dotclaude:purge            # Clean up merged branches and worktrees
```

## License

MIT
