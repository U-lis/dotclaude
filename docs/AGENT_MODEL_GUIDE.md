# Agent Model Selection Guide

This document is the criteria reference for assigning a Claude model to each agent under `agents/`. Contributors adding new agents should consult this guide to determine the appropriate model identifier and placement in the agent's YAML frontmatter. All assignments in this guide reflect the v0.5.0 release.

## Supported Model Identifiers

| Model Identifier | Characterization |
|------------------|-----------------|
| `claude-opus-4-7` | Highest reasoning capacity; reserved for complex trade-off analysis and code generation. |
| `claude-sonnet-4-6` | Balanced cost/quality; default choice for template-driven and instruction-following work. |
| `claude-haiku-4-5-20251001` | Lowest cost; available for future short-context, deterministic tasks. (Not assigned to any agent in v0.5.0.) |

## Decision Matrix

Use this table to determine which model to assign when adding a new agent. Match the agent's primary task profile to a row.

| Task characteristic | Recommended model |
|---------------------|-------------------|
| Template-driven structured writing | `claude-sonnet-4-6` |
| Cross-reference / consistency validation | `claude-sonnet-4-6` |
| Checklist-driven decision making | `claude-sonnet-4-6` |
| Code generation (any language) | `claude-opus-4-7` |
| Architectural / design trade-off analysis | `claude-opus-4-7` |
| Complex debugging / root-cause analysis | `claude-opus-4-7` |

## Resolution Order

Claude Code resolves the model for a subagent invocation using the following 4-step priority order (highest to lowest):

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (highest priority) — overrides everything when set in the execution environment.
2. Per-invocation `model` parameter passed by the caller — the value passed at call time to the Task tool or equivalent.
3. Subagent definition `model:` frontmatter — the value declared in the agent file's YAML frontmatter (this is what Phase 1 of the model-optimization work is setting).
4. Main conversation's model (lowest priority / fallback) — used when none of steps 1-3 are present.

Source: https://code.claude.com/docs/en/sub-agents (section "Choose a model").

Note: SPEC NFR-4 originally described only steps 2 vs. 3 (caller-vs-frontmatter precedence). The full 4-step order, including the environment variable override at step 1 and the main-conversation fallback at step 4, is documented here for completeness. When diagnosing unexpected model usage, check for a `CLAUDE_CODE_SUBAGENT_MODEL` environment variable first, as it will silently override all other settings.

## Current Assignments

The table below mirrors the SPEC mapping for v0.5.0. Keep this table in sync whenever a new agent is added or an assignment changes.

| Agent | Model | Rationale (one-line) |
|-------|-------|----------------------|
| `agents/designer.md` | `claude-opus-4-7` | Complex reasoning and architectural trade-off analysis |
| `agents/technical-writer.md` | `claude-sonnet-4-6` | Template-driven precise writing |
| `agents/code-validator.md` | `claude-sonnet-4-6` | Checklist-driven validation |
| `agents/spec-validator.md` | `claude-sonnet-4-6` | Cross-reference consistency analysis |
| `agents/coders/python.md` | `claude-opus-4-7` | Code generation with TDD discipline |
| `agents/coders/javascript.md` | `claude-opus-4-7` | Code generation with TDD discipline |
| `agents/coders/rust.md` | `claude-opus-4-7` | Ownership/lifetime reasoning |
| `agents/coders/sql.md` | `claude-opus-4-7` | Schema design and query optimization |
| `agents/coders/svelte.md` | `claude-opus-4-7` | Component authoring with TDD |
| `agents/coders/_base.md` | (none — shared rules document) | Not directly invoked; no `model:` field |

## How to Add a New Agent

1. Decide which row of the [Decision Matrix](#decision-matrix) the new agent's primary task profile matches.
2. Add `model: <full-identifier>` between `name:` and `description:` in the new agent's frontmatter.
3. Use the full version-pinned identifier (e.g., `claude-opus-4-7`), not an alias (e.g., `opus`). Aliases are not version-pinned and may resolve differently across Claude Code releases.
4. **If the new file is a shared/included document** (loaded by inclusion, not invoked directly — like `agents/coders/_base.md`), do NOT add a `model:` field. The field would be inert and misleading because the file is never invoked as a standalone agent.
5. Update the [Current Assignments](#current-assignments) table above with the new agent's row.

## Haiku Status

`claude-haiku-4-5-20251001` is a supported model identifier and is listed in the [Supported Model Identifiers](#supported-model-identifiers) table above, but it is not assigned to any agent in v0.5.0. Future agents with strictly deterministic, short-context, low-stakes workloads — for example, simple lookup or classification tasks — may be candidates for Haiku assignment. Empirical cost-benefit measurement for such assignments is out of scope for this release.
