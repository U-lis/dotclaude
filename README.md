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
├── CLAUDE.md                    # Global rules for all agents
├── .claude/
│   ├── settings.json            # Hooks configuration
│   ├── agents/                  # Agent definitions
│   │   ├── orchestrator.md      # Central workflow controller
│   │   ├── designer.md          # Architecture and planning
│   │   ├── technical-writer.md  # Documentation
│   │   ├── spec-validator.md    # Specification validation
│   │   ├── code-validator.md    # Code quality validation
│   │   └── coders/              # Language-specific coders
│   │       ├── _base.md         # Common coder rules
│   │       ├── python.md        # Python specialist
│   │       ├── javascript.md    # JS/TS specialist
│   │       ├── svelte.md        # Svelte specialist
│   │       ├── rust.md          # Rust specialist
│   │       └── sql.md           # SQL/DB specialist
│   ├── skills/                  # Workflow commands
│   │   ├── start-new/SKILL.md        # /start-new (entry point)
│   │   ├── init-feature/SKILL.md     # /init-feature (manual)
│   │   ├── init-bugfix/SKILL.md      # /init-bugfix (manual)
│   │   ├── init-refactor/SKILL.md    # /init-refactor (manual)
│   │   ├── design/SKILL.md           # /design
│   │   ├── validate-spec/SKILL.md    # /validate-spec
│   │   ├── code/SKILL.md             # /code [phase]
│   │   ├── merge-main/SKILL.md       # /merge-main
│   │   ├── tagging/SKILL.md          # /tagging
│   │   └── dotclaude/                # Update commands
│   │       ├── version/SKILL.md      # /dotclaude:version
│   │       └── update/SKILL.md       # /dotclaude:update
│   └── templates/               # Document templates
│       ├── SPEC.md
│       ├── GLOBAL.md
│       ├── PHASE_PLAN.md
│       ├── PHASE_TEST.md
│       └── PHASE_MERGE.md
└── claude_works/                # Working documents (per project)
```

## Workflow

```
User → /start-new → Orchestrator Agent
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

The orchestrator agent (`agents/orchestrator.md`) is the central controller that:

- **Manages entire workflow** from init to merge
- **Coordinates subagents** via Task tool
- **Enables parallel execution** for parallel phases
- **Tracks state** for resumability

### 13-Step Workflow

| Step | Phase | Description |
|------|-------|-------------|
| 1 | Init | Work type selection |
| 2 | Init | Call init-xxx skill (questions, analysis, branch, SPEC) |
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

| Command | Description |
|---------|-------------|
| `/start-new` | Entry point - calls orchestrator for full workflow |
| `/init-feature` | Manual: Gather requirements for new features |
| `/init-bugfix` | Manual: Gather bug details for bug fixes |
| `/init-refactor` | Manual: Gather refactor info for refactoring |
| `/design` | Transform SPEC into implementation plan |
| `/validate-spec` | Validate document consistency (optional) |
| `/code [phase]` | Execute coding for specified phase |
| `/code all` | Execute all phases automatically |
| `/merge-main` | Merge feature branch to main |
| `/tagging` | Create version tag based on CHANGELOG |
| `/dotclaude:version` | Display installed vs latest dotclaude version |
| `/dotclaude:update` | Update dotclaude framework to latest version |

## Agents

| Agent | Role |
|-------|------|
| Orchestrator | Central workflow controller |
| Designer | Technical architecture and phase decomposition |
| TechnicalWriter | Structured documentation |
| spec-validator | Document consistency validation |
| code-validator | Code quality + plan verification |
| Coders | Language-specific implementation |

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

## Usage

### Install to Your Project

In your project's Claude Code session, say:

```
dotclaude repo (https://github.com/U-lis/dotclaude) 를 clone 해서
.claude/ 폴더와 CLAUDE.md 를 이 프로젝트에 복사해줘.
```

Or manually:

```bash
git clone https://github.com/{username}/dotclaude /tmp/dotclaude
cp -r /tmp/dotclaude/.claude .
cp /tmp/dotclaude/CLAUDE.md .
rm -rf /tmp/dotclaude
```

### Start New Work

```bash
# In Claude Code session
/start-new

# Orchestrator takes over:
# 1. Asks work type (Feature/Bugfix/Refactor)
# 2. Calls init-xxx skill (handles questions, analysis, branch, SPEC)
# 3. Reviews SPEC with user
# 4. Asks execution scope
# 5. Executes selected scope (Design/Code/Docs/Merge)
# 6. Returns final summary

# After merge, optionally create version tag:
/tagging
```

### Update dotclaude

Check for updates and apply them:

```bash
# Check current and latest version
/dotclaude:version

# Update to latest version
/dotclaude:update

# Update to specific version
/dotclaude:update v0.1.0
```

The update process:
- Tracks managed files via `.dotclaude-manifest.json`
- Only updates dotclaude-managed files (preserves your customizations)
- Smart merges `settings.json` (adds new keys, keeps your values)
- Backs up before update, rolls back on failure
- Requires confirmation before making changes

### Manual Execution (Bypass Orchestrator)

Individual skills can be invoked directly for debugging or partial work:

```bash
/init-feature        # Direct feature initialization
/init-bugfix         # Direct bugfix initialization
/init-refactor       # Direct refactor initialization
/design              # Create implementation plan
/validate-spec       # Validate document consistency
/code 1              # Implement Phase 1
/code all            # Implement all phases
/merge-main          # Merge to main
/tagging             # Create version tag
/dotclaude:version   # Check installed version
/dotclaude:update    # Update to latest version
```

## License

MIT
