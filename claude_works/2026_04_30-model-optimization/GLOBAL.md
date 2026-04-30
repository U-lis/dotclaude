# Model Optimization for Agents - Global Documentation

## Feature Overview

**Purpose**: Assign an explicit `model` field to every directly-invocable agent under `agents/`, and publish a model selection guide so future agent additions follow consistent criteria.

**Problem**: All agents currently lack a frontmatter `model` field. They implicitly fall back to the caller's argument or the Claude Code default. Template-driven, deterministic, instruction-following agents (e.g., Technical Writer) consume Opus-class capacity unnecessarily, increasing cost without quality benefit.

**Solution**:
1. Add `model:` to the YAML frontmatter of 9 invocable agent files using full version-pinned identifiers (`claude-opus-4-7`, `claude-sonnet-4-6`).
2. Create `docs/AGENT_MODEL_GUIDE.md` documenting supported identifiers, decision matrix, the 4-step resolution order from official Claude Code docs, current assignments, and how to add new agents.
3. Cross-link the guide from `README.md` and `docs/ARCHITECTURE.md`.

The work is documentation/configuration only. No runtime code changes. No CHANGELOG/version-file updates in this phase (deferred to release).

## Architecture Decision

### AD-1: SOT = Frontmatter
Each directly-invocable agent declares its model in YAML frontmatter. Caller-supplied `model` arguments override at invocation time per Claude Code semantics. Frontmatter is the single source of truth for the default model assignment.

### AD-2: Identifier Form = Full Model ID
Use full model IDs (`claude-opus-4-7`, `claude-sonnet-4-6`) rather than aliases (`opus`, `sonnet`). Full IDs are version-pinned, preventing silent migration when Anthropic publishes a new alias mapping. This protects deterministic behavior across releases.

### AD-3: Guide as Standalone Document
The model selection guide lives at `docs/AGENT_MODEL_GUIDE.md` (standalone document). It is linked from `README.md` and cross-referenced from `docs/ARCHITECTURE.md`. Standalone form keeps the guide independently versionable and discoverable; duplication into multiple docs is avoided.

### AD-4: `_base.md` Excluded
`agents/coders/_base.md` is a shared rules document loaded by inclusion (not invoked as an agent). A `model:` field on it would be inert and misleading because the file never participates in resolution. It remains without `model:`.

### AD-5: No Haiku Assignments in This Release
Haiku (`claude-haiku-4-5-20251001`) is documented as a supported identifier in the guide for future agents, but no current agent is assigned to Haiku. The current agent set is too central to the workflow to risk quality degradation without empirical measurement (which is out of scope per SPEC).

### AD-6: Single-Phase Delivery
All FRs (FR-1 through FR-6) are delivered in one phase. The work is small, sequential, and has no parallelizable subdivision. No phase split, no merge phase.

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Add `model:` to 9 invocable agent frontmatters; create `docs/AGENT_MODEL_GUIDE.md`; update README and ARCHITECTURE cross-references | Not Started | None |

## File Structure

### Files Modified (9)

| File | `model:` value |
|------|----------------|
| `agents/designer.md` | `claude-opus-4-7` |
| `agents/technical-writer.md` | `claude-sonnet-4-6` |
| `agents/code-validator.md` | `claude-sonnet-4-6` |
| `agents/spec-validator.md` | `claude-sonnet-4-6` |
| `agents/coders/python.md` | `claude-opus-4-7` |
| `agents/coders/javascript.md` | `claude-opus-4-7` |
| `agents/coders/rust.md` | `claude-opus-4-7` |
| `agents/coders/sql.md` | `claude-opus-4-7` |
| `agents/coders/svelte.md` | `claude-opus-4-7` |

### Files Created (1)

- `docs/AGENT_MODEL_GUIDE.md` — Model selection guide (supported identifiers, decision matrix, resolution order, current assignments, how to add a new agent, Haiku status).

### Files Cross-Reference Updated (2)

- `README.md` — Add link to `docs/AGENT_MODEL_GUIDE.md`.
- `docs/ARCHITECTURE.md` — Note the guide and reference its location.

### Files NOT Modified (Intentionally)

- `agents/coders/_base.md` — Shared rules document, not directly invoked. Must NOT receive a `model:` field (per AD-4).
- `CHANGELOG.md` — Version updates deferred to release (per project convention: do not bump version during code/docs phases).
- `.claude-plugin/plugin.json` — Same reason as above.
- `.claude-plugin/marketplace.json` — Same reason as above.

## Resolution Order (Reference)

The model resolution order documented in the guide must follow the official 4-step priority from Claude Code docs (https://code.claude.com/docs/en/sub-agents — section "Choose a model"):

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (caller argument)
3. Subagent definition `model` frontmatter
4. Main conversation's model

NFR-4 in SPEC mentions only caller-vs-frontmatter (steps 2 vs 3). The guide MUST document all 4 steps including the env var.
