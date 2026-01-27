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
│   └── settings.json            # Hooks configuration
├── .claude-plugin/              # Plugin marketplace metadata
│   ├── marketplace.json         # Registry metadata
│   └── plugin.json              # Plugin configuration
├── commands/                    # Autocomplete entry points
│   ├── start-new.md
│   ├── design.md
│   ├── code.md
│   ├── merge-main.md
│   ├── tagging.md
│   ├── update-docs.md
│   └── validate-spec.md
├── agents/                      # Agent definitions
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
├── skills/                      # Workflow commands (dc: prefix)
│   ├── start-new/               # /dc:start-new (entry point + orchestrator)
│   │   ├── SKILL.md             # 13-step orchestrator workflow
│   │   ├── _analysis.md         # Common analysis phases
│   │   ├── init-feature.md      # Feature init instructions
│   │   ├── init-bugfix.md       # Bugfix init instructions
│   │   ├── init-refactor.md     # Refactor init instructions
│   │   └── init-github-issue.md # GitHub issue-based init
│   ├── design/SKILL.md          # /dc:design
│   ├── validate-spec/SKILL.md   # /dc:validate-spec
│   ├── code/SKILL.md            # /dc:code [phase]
│   ├── merge-main/SKILL.md      # /dc:merge-main
│   ├── tagging/SKILL.md         # /dc:tagging
│   └── update-docs/SKILL.md     # /dc:update-docs
├── templates/                   # Document templates
│   ├── SPEC.md
│   ├── GLOBAL.md
│   ├── PHASE_PLAN.md
│   ├── PHASE_TEST.md
│   └── PHASE_MERGE.md
├── hooks/                       # Hook scripts
│   ├── hooks.json               # Hook configuration
│   └── check-update.sh          # SessionStart update checker
└── claude_works/                # Working documents (per project)
```

## Workflow

```
User → /dc:start-new → Orchestrator Agent
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

The orchestrator workflow is integrated into `/dc:start-new` skill (`skills/start-new/SKILL.md`):

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
| `/dotclaude:start-new` | Entry point - calls orchestrator for full workflow |
| `/dotclaude:design` | Transform SPEC into implementation plan |
| `/dotclaude:validate-spec` | Validate document consistency (optional) |
| `/dotclaude:code [phase]` | Execute coding for specified phase |
| `/dotclaude:code all` | Execute all phases automatically |
| `/dotclaude:merge-main` | Merge feature branch to main |
| `/dotclaude:tagging` | Create version tag based on CHANGELOG |
| `/dotclaude:update-docs` | Update documentation (CHANGELOG, README) |

## Agents

| Agent | Role |
|-------|------|
| Designer | Technical architecture and phase decomposition |
| TechnicalWriter | Structured documentation |
| spec-validator | Document consistency validation |
| code-validator | Code quality + plan verification |
| Coders | Language-specific implementation |

Note: Orchestrator workflow is now integrated into `/dc:start-new` skill.

## Document Types

### Simple Tasks (1-2 phases)
```
claude_works/{SUBJECT}.md
```

### Complex Tasks (3+ phases)
```
claude_works/{subject}/
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

# After merge, optionally create version tag:
/dotclaude:tagging
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
/dotclaude:tagging          # Create version tag
```

## License

MIT
