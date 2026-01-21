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
│   ├── skills/                  # Workflow commands (dc: prefix)
│   │   ├── start-new/SKILL.md        # /dc:start-new (entry point)
│   │   ├── design/SKILL.md           # /dc:design
│   │   ├── validate-spec/SKILL.md    # /dc:validate-spec
│   │   ├── code/SKILL.md             # /dc:code [phase]
│   │   ├── merge-main/SKILL.md       # /dc:merge-main
│   │   ├── tagging/SKILL.md          # /dc:tagging
│   │   └── update-docs/SKILL.md      # /dc:update-docs
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

All dotclaude skills use the `dc:` prefix for namespace identification:

| Command | Description |
|---------|-------------|
| `/dc:start-new` | Entry point - calls orchestrator for full workflow |
| `/dc:design` | Transform SPEC into implementation plan |
| `/dc:validate-spec` | Validate document consistency (optional) |
| `/dc:code [phase]` | Execute coding for specified phase |
| `/dc:code all` | Execute all phases automatically |
| `/dc:merge-main` | Merge feature branch to main |
| `/dc:tagging` | Create version tag based on CHANGELOG |
| `/dc:update-docs` | Update documentation (CHANGELOG, README) |

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
dotclaude repo (https://github.com/{username}/dotclaude) 를 clone 해서
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
/dc:start-new

# Orchestrator takes over:
# 1. Asks work type (Feature/Bugfix/Refactor)
# 2. Gathers requirements via step-by-step questions
# 3. Asks target version
# 4. Creates and reviews SPEC with user
# 5. Asks execution scope
# 6. Executes selected scope (Design/Code/Docs/Merge)
# 7. Returns final summary

# After merge, optionally create version tag:
/dc:tagging
```

### Manual Execution (Bypass Orchestrator)

Individual skills can be invoked directly for debugging or partial work:

```bash
/dc:design           # Create implementation plan
/dc:validate-spec    # Validate document consistency
/dc:code 1           # Implement Phase 1
/dc:code all         # Implement all phases
/dc:update-docs      # Update documentation
/dc:merge-main       # Merge to main
/dc:tagging          # Create version tag
```

## License

MIT
