# Agent Model Selection Guide

## Policy

Agent frontmatter uses family aliases (`opus`, `sonnet`, `haiku`), never a dated model id. The plugin then follows the current generation of each family without file changes.

## Current Assignments

| Agent | Model |
|-------|-------|
| designer | `opus` |
| coders (`agents/coders/*.md`: python, javascript, svelte, rust, sql, generic) | `opus` |
| technical-writer | `sonnet` |
| spec-validator | `sonnet` |
| code-validator | `sonnet` |
| coder-generic (`agents/coders/generic.md`) | `opus` |
| pruner | `sonnet` |
| reviewer | `opus` (review judgment across scope and design; once per phase plus once per diff) |
| `commands/_coder-base.md` | none (reference read by coders, not an agent) |

## Decision Matrix

| Task type | Model |
|-----------|-------|
| Code generation, design trade-offs | `opus` |
| Template-driven writing, checklist validation, report-only analysis | `sonnet` |
| Wide read/search lookups | Built-in Explore agent with `haiku` or `sonnet` (called by the orchestrator, not an agent file) |

## Resolution Order

From https://code.claude.com/docs/en/sub-agents.md , Claude Code picks the subagent model in this order:

1. The per-invocation `model` parameter on the Agent call, which accepts only aliases.
2. The frontmatter `model`. The value `inherit` means the main conversation's model.
3. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable.
4. The main conversation's model.

## Changing an Assignment

Edit the `model:` line in the agent's frontmatter and update the table above. Use an alias value only.
