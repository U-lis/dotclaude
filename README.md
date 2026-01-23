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
├── .gitignore                   # Excludes CLAUDE.md from tracking
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
│   ├── skills/                  # Workflow commands (dc: prefix)
│   │   ├── start-new/           # /dc:start-new (entry point + orchestrator)
│   │   │   ├── SKILL.md         # 13-step orchestrator workflow
│   │   │   ├── _analysis.md     # Common analysis phases
│   │   │   ├── init-feature.md  # Feature init instructions
│   │   │   ├── init-bugfix.md   # Bugfix init instructions
│   │   │   └── init-refactor.md # Refactor init instructions
│   │   ├── design/SKILL.md           # /dc:design
│   │   ├── validate-spec/SKILL.md    # /dc:validate-spec
│   │   ├── code/SKILL.md             # /dc:code [phase]
│   │   ├── merge-main/SKILL.md       # /dc:merge-main
│   │   ├── tagging/SKILL.md          # /dc:tagging
│   │   ├── update-docs/SKILL.md      # /dc:update-docs
│   │   └── dotclaude/                # Framework management
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
| `/dotclaude:version` | Display installed vs latest dotclaude version |
| `/dotclaude:update` | Update dotclaude framework to latest version |

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

## Usage

### Install to Your Project

In your project's Claude Code session, say:

```
dotclaude repo (https://github.com/U-lis/dotclaude) 를 clone 해서
.claude/ 폴더를 이 프로젝트에 복사해줘.
```

Or manually:

```bash
git clone https://github.com/{username}/dotclaude /tmp/dotclaude
cp -r /tmp/dotclaude/.claude .
rm -rf /tmp/dotclaude
```

Note: CLAUDE.md is excluded from tracking. Agent/skill-specific rules are now embedded directly in their respective files.

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
/dc:design           # Create implementation plan
/dc:validate-spec    # Validate document consistency
/dc:code 1           # Implement Phase 1
/dc:code all         # Implement all phases
/dc:update-docs      # Update documentation
/dc:merge-main       # Merge to main
/dc:tagging          # Create version tag
/dotclaude:version   # Check installed version
/dotclaude:update    # Update to latest version
```

## License

MIT
