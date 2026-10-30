# dotclaude - Architecture

This document shows the project directory structure for dotclaude. For the full project documentation, see the [README](../README.md).

## Directory Structure

```
.
├── CLAUDE.md                    # Development guidelines
├── .claude/
│   └── dotclaude-config.json    # Plugin configuration
├── .claude-plugin/              # Plugin marketplace metadata
│   ├── marketplace.json         # Registry metadata
│   └── plugin.json              # Plugin configuration
├── commands/                    # Self-contained command files
│   ├── _coder-base.md          # Common coder rules, read by every coder agent
│   ├── _contract.md             # Internal: single definition of shared rules (user-invocable: false)
│   ├── _agent-prompts.md        # Internal: prompt templates for agent calls (user-invocable: false)
│   ├── configure.md             # /dotclaude:configure
│   ├── start-new.md             # /dotclaude:start-new (entry point + orchestrator)
│   ├── design.md                # /dotclaude:design
│   ├── code.md                  # /dotclaude:code [phase]
│   ├── merge.md                 # /dotclaude:merge
│   ├── pr.md                    # /dotclaude:pr
│   ├── tagging.md               # /dotclaude:tagging
│   ├── update-docs.md           # /dotclaude:update-docs
│   ├── validate-spec.md         # /dotclaude:validate-spec
│   ├── purge.md                 # /dotclaude:purge
│   ├── prune.md                 # /dotclaude:prune (report-only bloat analysis)
│   ├── init.md                  # Internal: intake, work type, analysis, SPEC draft
│   └── _prefill-filters.md      # Internal: sensitive data filters for prefill (user-invocable: false)
├── agents/                      # Agent definitions (frontmatter-enabled)
│   ├── designer.md              # Architecture and planning
│   ├── technical-writer.md      # Documentation
│   ├── spec-validator.md        # Specification validation
│   ├── code-validator.md        # Code quality validation
│   ├── pruner.md                # Report-only bloat analysis
│   └── coders/                  # Language-specific coders
│       ├── python.md            # Python specialist
│       ├── javascript.md        # JS/TS specialist
│       ├── svelte.md            # Svelte specialist
│       ├── rust.md              # Rust specialist
│       ├── generic.md           # Fallback coder for other languages
│       └── sql.md               # SQL/DB specialist
├── templates/                   # Document templates
│   ├── SPEC.md
│   ├── GLOBAL.md
│   ├── PHASE_PLAN.md
│   ├── PHASE_TEST.md
│   ├── PHASE_MERGE.md
│   └── RULES.md                 # Project coding rules, copied by init
├── docs/                        # Project documentation
│   ├── ARCHITECTURE.md         # This file
│   ├── AGENT_MODEL_GUIDE.md    # Agent model selection
│   └── CTL_PROTOCOL.md         # Controller/worker session protocol (draft)
├── hooks/                       # Hook scripts
│   ├── hooks.json               # Hook configuration
│   ├── _lib.sh                  # Shared helpers (JSON, config, worktrees, fail-open)
│   ├── init-config.sh           # SessionStart: global config + language line
│   ├── spec-meta.sh             # SPEC metadata block reader/writer (state)
│   ├── check-validation-complete.sh  # Stop: uncommitted code in a dotclaude worktree
│   ├── guard-commit.sh          # PreToolUse Bash: code commit needs .validated marker
│   ├── guard-design.sh          # PreToolUse Agent: designer needs approved SPEC
│   └── title-prefix.sh          # Terminal title prefix while waiting for the user
├── scripts/
│   └── lint-prompts.sh          # Static checks for prompt files
├── tests/
│   ├── fixtures/                # Fixtures for tests
│   └── hooks/                   # Shell tests for hooks (run_all.sh)
└── {working_directory}/         # Working documents (configurable, default: .dc_workspace)
```

## Agent Models

Each agent file under `agents/` declares a `model:` field in its YAML frontmatter. The value is a family alias (`opus` or `sonnet`), not a dated model id, so the plugin follows the current model generation. Assignments and selection criteria are in [AGENT_MODEL_GUIDE.md](./AGENT_MODEL_GUIDE.md).
