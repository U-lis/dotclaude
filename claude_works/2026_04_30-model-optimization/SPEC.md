<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-model-optimization
doc_dir: 2026_04_30-model-optimization
-->

# Model Optimization for Agents - Specification

**Source Issue**: [U-lis/dotclaude#65 - Use cheaper model for simpler job](https://github.com/U-lis/dotclaude/issues/65)
**Target Version**: 0.5.0

## Overview

Update agent definitions in the `agents/` directory so that each agent specifies an appropriate Claude model in its frontmatter `model` field. The selection of the model for each agent is based on the characteristics and complexity of the agent's typical workload, with the goal of reducing cost without compromising output quality.

Currently, all agents are defined without a `model` field in their frontmatter, which means they implicitly rely on the caller's argument or the Claude Code default. Agents performing template-driven, deterministic, or instruction-following tasks (e.g., Technical Writer) do not need the most expensive model and can be served by Sonnet or Haiku at substantially lower cost.

This specification covers (1) per-agent model assignment in frontmatter, (2) creation of a model selection guide for future agent additions, and (3) the analysis basis for the proposed mapping.

## Functional Requirements

- [ ] FR-1: Add a `model` field to the frontmatter of every directly-invocable agent file under `agents/`. The targeted agents are:
  - `agents/technical-writer.md`
  - `agents/designer.md`
  - `agents/code-validator.md`
  - `agents/spec-validator.md`
  - `agents/coders/python.md`
  - `agents/coders/javascript.md`
  - `agents/coders/rust.md`
  - `agents/coders/sql.md`
  - `agents/coders/svelte.md`
- [ ] FR-2: The `model` value must be one of the supported identifiers: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`.
- [ ] FR-3: Assign each agent a model that matches the complexity profile of its work, following the initial mapping proposal below (final values are subject to confirmation in the design phase).
- [ ] FR-4: Leave `agents/coders/_base.md` without a mandatory `model` field, since it is a shared rules document and is not directly invoked. (Adding a `model` field is optional and considered out of scope unless design phase indicates a need.)
- [ ] FR-5: Create a model selection guide document (e.g., `AGENT_MODEL_GUIDE.md` or an equivalent README section) that documents the criteria used for model selection, so that future agents can be assigned a model consistently.
- [ ] FR-6: The guide must include: (a) the list of supported model identifiers, (b) a decision matrix mapping task characteristics (template-following, complex reasoning, design trade-offs, code generation, validation, etc.) to recommended models, and (c) instructions for caller-side override behavior.

## Non-Functional Requirements

- [ ] NFR-1 (Cost): Optimize cost by routing simple/template-driven work (writing, validation, cross-reference checking) to Sonnet, while reserving Opus for tasks requiring deep reasoning, code generation, or design trade-off analysis. Code generation is treated as Opus-class work because output quality directly affects downstream cost (validator retries, rework cycles).
- [ ] NFR-2 (Maintainability): The model selection guide must be discoverable from the project root (linked from README or placed in a known docs path) so that contributors adding new agents can apply consistent criteria.
- [ ] NFR-3 (Compatibility): The frontmatter syntax must conform to the Claude Code agent definition schema. Adding the `model` field must not break existing agent loading.
- [ ] NFR-4 (Override Semantics): Caller-supplied `model` arguments take precedence over the frontmatter value. This is the assumed Claude Code standard behavior and the design phase must verify it before finalizing.

## Constraints

- The frontmatter `model` field format must follow the Claude Code agent definition convention.
- Allowed model identifiers are limited to: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`.
- When a caller explicitly passes a `model` argument at invocation time, the caller's argument is assumed to override the frontmatter value (Claude Code standard behavior).
- Changes are limited to agent definition files under `agents/` and the new guide document. No changes to commands, skills, or runtime logic are required.

## Out of Scope

- Empirical cost-saving measurement / benchmarking. Verifying the actual cost reduction in production usage is deferred to a future task.
- Linting or automated validation that every new agent file declares a `model` field. The guide is documentation-only; no enforcement tool is built in this work.
- Adding a `model` field to non-invocable shared documents such as `agents/coders/_base.md` (optional, may be addressed in design if rationale emerges).
- Changing the orchestrator/caller logic to pick a model dynamically per-call. The selection lives in agent frontmatter; runtime model selection is a separate concern.

## Analysis Results

### Related Code

All paths are relative to the worktree root: `/home/ulismoon/Documents/dotclaude-feature-model-optimization`.

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | `agents/technical-writer.md` | 1-4 | Frontmatter has no `model` field |
| 2 | `agents/designer.md` | 1-4 | Frontmatter has no `model` field |
| 3 | `agents/code-validator.md` | 1-4 | Frontmatter has no `model` field |
| 4 | `agents/spec-validator.md` | 1-4 | Frontmatter has no `model` field |
| 5 | `agents/coders/_base.md` | 1-4 | Frontmatter has no `model` field (not directly invoked; optional) |
| 6 | `agents/coders/python.md` | 1-4 | Frontmatter has no `model` field |
| 7 | `agents/coders/javascript.md` | 1-4 | Frontmatter has no `model` field |
| 8 | `agents/coders/rust.md` | 1-4 | Frontmatter has no `model` field |
| 9 | `agents/coders/sql.md` | 1-4 | Frontmatter has no `model` field |
| 10 | `agents/coders/svelte.md` | 1-4 | Frontmatter has no `model` field |

### Conflicts Identified

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | All agents use the default model or the caller-supplied model | Each agent declares its preferred `model` in frontmatter | Add `model` field to frontmatter; caller-supplied arguments still take precedence per Claude Code standard behavior |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Caller passes a `model` argument AND frontmatter declares `model` | Caller's argument wins (Claude Code standard) |
| 2 | A new agent is added without a `model` field | Falls back to default; the guide document is the reference for adding the field correctly. No automated lint in scope. |
| 3 | Typo in the `model` identifier | Behavior is determined by Claude Code (loader error or fallback). Design phase must verify and document the actual behavior. |
| 4 | `agents/coders/_base.md` is read but never invoked directly | No `model` field needed; it remains a shared rules document. |

### Initial Model Mapping Proposal

The mapping below is the initial proposal derived from each agent's task characteristics. Final values must be confirmed in the design phase.

| Agent | Proposed Model | Rationale |
|-------|----------------|-----------|
| `agents/designer.md` | `claude-opus-4-7` | Performs complex reasoning and architectural trade-off analysis. The agent definition itself describes it as the most technically skilled agent. |
| `agents/technical-writer.md` | `claude-sonnet-4-6` | Template-driven precise writing; needs consistency across long documents but does not require Opus-level reasoning. |
| `agents/code-validator.md` | `claude-sonnet-4-6` | Checklist-driven decision making with coder collaboration. |
| `agents/spec-validator.md` | `claude-sonnet-4-6` | Cross-reference consistency analysis across planning documents. |
| `agents/coders/python.md` | `claude-opus-4-7` | Code authoring requires deep reasoning for design decisions, debugging, and TDD discipline. Quality of generated code directly affects downstream cost (rework, validation retries). |
| `agents/coders/javascript.md` | `claude-opus-4-7` | Same rationale as `coder-python`: code generation quality matters more than per-call cost. |
| `agents/coders/rust.md` | `claude-opus-4-7` | Rust requires careful ownership/lifetime reasoning; benefits most from Opus. |
| `agents/coders/sql.md` | `claude-opus-4-7` | Schema design and query optimization involve trade-off analysis benefiting from Opus. |
| `agents/coders/svelte.md` | `claude-opus-4-7` | Component authoring with TDD; code quality prioritized over per-call cost. |
| `agents/coders/_base.md` | (not required) | Shared rules document; not directly invoked. |

Note: Haiku (`claude-haiku-4-5-20251001`) is listed as a supported identifier in this project but is not assigned to any agent in this initial proposal. The design phase may revisit whether any agent (or a future agent) is a good fit for Haiku.

## Open Questions

- OQ-1: Confirm the exact precedence rules between the caller-supplied `model` argument and the frontmatter `model` field in the current Claude Code version. NFR-4 assumes caller wins; design phase must verify.
- OQ-2: Decide the location and exact filename of the model selection guide (`AGENT_MODEL_GUIDE.md` at repo root vs. a section appended to an existing README/docs file).
- OQ-3: Decide whether `agents/coders/_base.md` should also receive an explicit `model` field for documentation symmetry, even though it is not directly invoked.
- OQ-4: Decide whether any current agent is actually a good fit for Haiku, or whether Haiku should remain unassigned (only available for future agents).
