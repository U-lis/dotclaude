# dotclaude

A multi-agent development workflow system for Claude Code.

## Overview

This repository provides a structured workflow for software development using specialized AI agents. The system enables:

- Systematic project planning and specification
- Parallel development with git worktrees
- Automated code validation
- Language-specific coding standards
- **Orchestrator-managed workflow** from init to merge

For the full project structure, see [Architecture](docs/ARCHITECTURE.md). For model selection criteria across agents, see the [Agent Model Selection Guide](docs/AGENT_MODEL_GUIDE.md) — criteria for assigning Claude models to agents.

## Getting Started

### Install

```bash
/plugin install dotclaude --marketplace U-lis/dotclaude
```

Alternatively, add the marketplace first and install in a second step:

```bash
/plugin marketplace add https://github.com/U-lis/dotclaude
/plugin install dotclaude
```

**Note**: For updates, use `/plugin update dotclaude`. Restart Claude Code after updating to apply changes.

### Optional: GitHub CLI

The `/dotclaude:pr` command requires [GitHub CLI (`gh`)](https://cli.github.com/).

- Install: `brew install gh` (macOS) or see [installation guide](https://github.com/cli/cli#installation)
- Authenticate: `gh auth login`

### Configure

Configure dotclaude settings for your project:

```bash
/dotclaude:configure
```

See the [Configuration](#configuration) section below for available settings and file locations.

### Start Your First Task

```bash
# In Claude Code session
/dotclaude:start-new

# Orchestrator takes over:
# 1. Infers the work type (feature/bugfix/refactor) from your input and confirms it once
# 2. Analyzes the codebase and drafts SPEC.md in a new worktree
# 3. Asks one combined question for anything missing (including target version)
# 4. Reviews the SPEC with you and commits it once approved
# 5. Runs Design, Code, and Docs as one set (no scope question)
# 6. Runs the configured stages (local_test, test_deploy, remote_test); empty ones are skipped
# 7. Stops and reports; continues to the PR (or merge, per `integration`) when you say "proceed",
#    unless stages.stop_after is "pr"
# 8. Returns final summary

# start-new accepts free text, a GitHub issue/PR URL or #N, a Jira key, or --prefill "<text>":
/dotclaude:start-new "add CSV export to the report page"
/dotclaude:start-new https://github.com/owner/repo/issues/123
/dotclaude:start-new PROJ-42
/dotclaude:start-new --prefill "<text from the current conversation>"

# After merge, create version tag (verifies version consistency, pushes automatically):
/dotclaude:tagging
# Or specify version explicitly:
/dotclaude:tagging 0.3.0
```

**Note**: `--prefill` text is filtered for sensitive data (API keys, passwords, JWT tokens, etc.) before anything else uses it; the unfiltered text is never written to disk.

### Manual Execution (Bypass Orchestrator)

Individual skills can be invoked directly for debugging or partial work:

```bash
/dotclaude:design           # Create implementation plan
/dotclaude:validate-spec    # Validate document consistency
/dotclaude:code 1           # Implement Phase 1
/dotclaude:code all         # Implement all phases
/dotclaude:update-docs      # Update documentation
/dotclaude:merge             # Merge to base branch
/dotclaude:tagging          # Create version tag (with push + version checks)
/dotclaude:tagging 0.3.0   # Create tag for specific version
/dotclaude:purge            # Clean up merged branches and worktrees
/dotclaude:purge 0.3.0     # Clean up using specific version as deployment boundary
```

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

Interactive workflow to edit settings at global or local scope. Basic settings (Language, Working Directory, Base Branch) are presented as a multi-question batch for faster configuration. Version Files uses a separate interactive workflow. Changes take effect immediately.

### Available Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `language` | string | `en_US` | User-facing text, SPEC.md, and PR title/body use this language. GLOBAL, PLAN, TEST, CHANGELOG, and README stay English. |
| `working_directory` | string | `.dc_workspace` | Directory for work files (relative to project root) |
| `base_branch` | string | `main` | Default base branch for git operations |
| `version_files` | array | `[]` | Version files for tagging consistency check. Empty = auto-detect. See [Version Files](#version-files). |
| `title_prefix` | boolean | `false` | Prefix the terminal title while the session waits for user input |
| `stages.local_test` / `stages.test_deploy` / `stages.remote_test` | string | `""` | Shell command run from the worktree root after Docs, in that order. Empty = skipped, reported as "not configured". A non-zero exit stops the chain. |
| `stages.stop_after` | string | `remote_test` | `local_test`, `remote_test`, or `pr`. Where start-new stops and waits for "proceed"; `pr` continues to integration without waiting. |
| `integration` | string | `pr` | `pr` runs the `/dotclaude:pr` procedure, `merge` runs `/dotclaude:merge` |
| `pr.labels` | array | `[]` | Labels added to the PR besides the branch-prefix label |
| `pr.assignee` | string | `@me` | PR assignee; empty = none |
| `pr.reviewers` | array | `[]` | PR reviewers |
| `worktree.share_from_base` | boolean | `true` | Symlink `.venv`, `venv`, `node_modules`, `target`, `vendor` from the primary checkout into new worktrees |
| `parallel_phases` | boolean | `false` | Allow the designer to propose parallel phase groups (`{k}A`/`{k}B` plus merge `{k}.5`); when false, phases are sequential unless you ask |

#### Version Files

When `version_files` is empty (default), `/dotclaude:tagging` auto-detects common version files in the project (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`, `.claude-plugin/plugin.json`). To override, configure explicit `{path, pattern}` entries where `pattern` is a regex with a capture group for the version string. `CHANGELOG.md` is always included regardless of configuration. Use `/dotclaude:configure` (Setting 4) to manage version files interactively -- the "Auto-detect and suggest" option scans the project for all 7 known version file types, shows their status, and lets you add or remove entries in one step.

## Commands & Core Workflow

### Skills (Commands)

All dotclaude skills are prefixed with `dotclaude:` namespace:

| Command | Description |
|---------|-------------|
| `/dotclaude:configure` | Interactive configuration management |
| `/dotclaude:start-new` | Entry point - accepts free text, a GitHub issue/PR URL or #N, a Jira key, or `--prefill "<text>"`; infers the work type and confirms it once, analyzes, asks one combined question for anything missing, then runs the full workflow |
| `/dotclaude:design` | Transform SPEC into implementation plan |
| `/dotclaude:validate-spec` | Validate document consistency (optional) |
| `/dotclaude:code [phase]` | Execute coding for specified phase |
| `/dotclaude:code all` | Execute all phases automatically |
| `/dotclaude:merge` | Merge current branch to base branch |
| `/dotclaude:pr` | Create GitHub Pull Request with structured body (Summary, Changes, Test plan) from design docs or git history |
| `/dotclaude:tagging [version]` | Create version tag with push enforcement and version consistency checks |
| `/dotclaude:update-docs` | Update documentation (CHANGELOG, README) |
| `/dotclaude:purge [version]` | Clean up merged branches and orphaned worktrees |
| `/dotclaude:prune [target]` | Analyze current diff or target (phase id / PR / issue / Jira key) and report deletion/merge candidates. Report-only. |

### Orchestrator

The orchestrator workflow is integrated into `/dotclaude:start-new` command (`commands/start-new.md`):

- **Manages entire workflow** from init to merge
- **Coordinates subagents** via the Agent tool
- **Enables parallel execution** for parallel phases
- **Tracks state** for resumability

Shared rules (configuration, commits, limits, the validate-fix loop) are defined once in `commands/_contract.md`. Other command and agent files reference it instead of restating the rules.

## Appendix

### Agents

| Agent | Role |
|-------|------|
| Designer | Technical architecture and phase decomposition |
| TechnicalWriter | Structured documentation |
| spec-validator | Document consistency validation (report-only; does not add or instruct tests) |
| code-validator | Code quality + plan verification, with post-PASS pruning pass |
| pruner | Report-only bloat analyzer — deletion/merge candidates for tests and docstring/comment reduction candidates, in doc mode (design-time) or code mode (post-implementation) |
| Coders | Language-specific implementation; `coder-generic` is the fallback for languages without a dedicated coder |

Agent frontmatter has `name`, `model` (a family alias), `description`, and an optional `tools` list. Agents are invoked via `dotclaude:{agent-name}`; coders are invoked as `dotclaude:coders:coder-{language}`. Init creates `{working_directory}/RULES.md` from `templates/RULES.md` when missing; coders and the reviewer read it as the project's coding rules.

Note: Orchestrator workflow is now integrated into `/dotclaude:start-new` command.

### Hooks

| Event | Script | Behavior |
|-------|--------|----------|
| `SessionStart` | `init-config.sh` | Creates the global config if missing and prints `[dotclaude] language: …` |
| `Stop` | `check-validation-complete.sh` | Blocks ending the turn (once) when a dotclaude worktree whose SPEC stage is `code`…`remote_test` holds uncommitted code outside `{working_directory}`. Logs to `{working_directory}/.hook.log` |
| `PreToolUse` Bash | `guard-commit.sh` | Denies `git commit` of code on a work branch unless `.validated/PHASE_{k}` exists for the phase named in the message (code-validator writes it on PASS). Documents-only commits pass |
| `PreToolUse` Agent | `guard-design.sh` | Denies calling `dotclaude:designer` when the SPEC is not approved (`spec-meta.sh check-approved`) |
| `PreToolUse` AskUserQuestion, `Notification`, `UserPromptSubmit` | `title-prefix.sh` | With `title_prefix: true`, sets the terminal title to `[확인요청]`/`[INPUT] <dir>` while waiting for the user and clears it on the next prompt |

Every hook fails open: a missing tool or an unexpected error exits 0 so the user is never blocked by a hook bug. `hooks/spec-meta.sh` reads and writes the SPEC metadata block (`find get set stage approve check-approved handoff decision`). Tests: `tests/hooks/run_all.sh`.

### Document Types

#### Directory Naming Convention

Documentation directories use date-prefixed names for chronological sorting:

```
{working_directory}/{yyyy_mm_dd}-{subject}/
```

- `{yyyy_mm_dd}`: Local date when directory is created (e.g., `2026_02_25`)
- `{subject}`: Work keyword (e.g., `auth`, `api-cleanup`)
- Combined as `{doc_dir}` variable (e.g., `2026_02_25-auth`)

This variable is stored in SPEC.md metadata as `doc_dir` and used by downstream commands for path resolution.

**Note**: `{subject}` continues to be used for branch names and commit messages.

#### Work Directory
```
{working_directory}/{doc_dir}/               # Example: .dc_workspace/2026_02_25-auth/
├── SPEC.md                      # Requirements (What)
├── GLOBAL.md                    # Architecture, phase overview
├── PHASE_1_PLAN_{keyword}.md    # Implementation plan
├── PHASE_1_TEST.md              # Test cases
└── ...
```

#### Parallel Phases
```
├── PHASE_3A_PLAN_{keyword}.md   # Parallel work A
├── PHASE_3B_PLAN_{keyword}.md   # Parallel work B
├── PHASE_3.5_PLAN_MERGE.md      # Merge phase (required)
```

### Phase Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Sequential | `PHASE_{k}` | PHASE_1, PHASE_2 |
| Parallel | `PHASE_{k}{A\|B\|C}` | PHASE_3A, PHASE_3B |
| Merge | `PHASE_{k}.5` | PHASE_3.5 |

### 13-Step Workflow

| Step | Phase | Description |
|------|-------|-------------|
| 1 | Init | Intake and work type (init) |
| 2 | Init | Analysis and SPEC draft (init) |
| 3 | Init | SPEC review (editor or ask) |
| 4 | Init | Approve and commit SPEC |
| 5 | (removed) | No scope question; Design, Code, and Docs always run |
| 6 | Design | Designer analysis |
| 7 | Design | Document creation via technical-writer |
| 8 | Design | Commit design documents |
| 9 | Code | Phase list parsing |
| 10 | Code | Phase execution (coder, then code-validator; sequential or parallel) |
| 11 | Docs | Documentation update |
| 12 | Stages and integration | Configured test stages, go-ahead, then PR or merge |
| 13 | Final | Summary |

## License

MIT
