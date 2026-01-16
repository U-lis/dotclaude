# dotclaude

A multi-agent development workflow system for Claude Code.

## Overview

This repository provides a structured workflow for software development using specialized AI agents. The system enables:

- Systematic project planning and specification
- Parallel development with git worktrees
- Automated code validation
- Language-specific coding standards

## Structure

```
.
├── CLAUDE.md                    # Global rules for all agents
├── .claude/
│   ├── settings.json            # Hooks configuration
│   ├── agents/                  # Agent definitions
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
│   │   ├── _shared/init-workflow.md  # Common init workflow
│   │   ├── start-new/SKILL.md        # /start-new (entry point)
│   │   ├── init-feature/SKILL.md     # /init-feature
│   │   ├── init-bugfix/SKILL.md      # /init-bugfix
│   │   ├── init-refactor/SKILL.md    # /init-refactor
│   │   ├── design/SKILL.md           # /design
│   │   ├── validate-spec/SKILL.md    # /validate-spec
│   │   ├── code/SKILL.md             # /code [phase]
│   │   ├── merge-main/SKILL.md       # /merge-main
│   │   └── tagging/SKILL.md          # /tagging
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
User → Orchestrator → Designer → TechnicalWriter → spec-validator
                                                         ↓
                      (documents finalized)            (loop)
                           ↓
    Orchestrator → Coder(s) ←→ code-validator
                      ↓
              TechnicalWriter → README/CHANGELOG
                      ↓
                 git commit
```

## Skills (Commands)

| Command | Description |
|---------|-------------|
| `/start-new` | Entry point - routes to init-feature/bugfix/refactor |
| `/init-feature` | Gather requirements and create SPEC.md for new features |
| `/init-bugfix` | Gather bug details and create SPEC.md for bug fixes |
| `/init-refactor` | Gather refactor info and create SPEC.md for refactoring |
| `/design` | Transform SPEC into implementation plan |
| `/validate-spec` | Validate document consistency |
| `/code [phase]` | Execute coding for specified phase |
| `/code all` | Execute all phases automatically |
| `/merge-main` | Merge feature branch to main with conflict resolution |
| `/tagging` | Create version tag based on CHANGELOG |

## Agents

| Agent | Role |
|-------|------|
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
/start-new
# Select work type: Feature / Bugfix / Refactor
# Answer step-by-step questions
# SPEC.md is created

/design
# Designer creates implementation plan
# GLOBAL.md, PHASE_*_PLAN_*.md, PHASE_*_TEST.md created

/validate-spec
# Validates document consistency

/code 1
# Implements Phase 1

/code 2
# Implements Phase 2

# Or run all phases automatically:
/code all

# Update CHANGELOG, then merge to main:
/merge-main
# Merges feature branch to main, handles conflicts, cleans up branch

/tagging
# Creates version tag from CHANGELOG
```

## License

MIT
