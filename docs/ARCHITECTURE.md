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
│   ├── init-feature.md          # Internal: feature init (user-invocable: false)
│   ├── init-bugfix.md           # Internal: bugfix init (user-invocable: false)
│   ├── init-refactor.md         # Internal: refactor init (user-invocable: false)
│   ├── init-github-issue.md     # Internal: GitHub issue init (user-invocable: false)
│   └── _init-common.md           # Internal: common init workflow (user-invocable: false)
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
