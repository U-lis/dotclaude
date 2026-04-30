# Phase 1: Model Optimization

## Objective

Add an explicit `model:` field to the YAML frontmatter of every directly-invocable agent file under `agents/`, create a model selection guide at `docs/AGENT_MODEL_GUIDE.md`, and update `README.md` and `docs/ARCHITECTURE.md` to cross-reference the guide. All FRs (FR-1 through FR-6) are delivered in this single phase.

## Prerequisites

None. This phase has no upstream dependencies.

## Instructions

All file paths below are relative to the worktree root: `/home/ulismoon/Documents/dotclaude-feature-model-optimization`.

### Step 1: Frontmatter edits — top-level `agents/` (4 files)

For each of the four files below, open the file and locate the YAML frontmatter block (the opening `---` and closing `---` near the top of the file).

Insert a new line `model: <value>` between the existing `name:` line and the existing `description:` line. This placement is enforced for consistency across all 9 modified files.

YAML rules to obey:
- Use spaces, not tabs.
- Do NOT quote the value (the model identifier is a plain string with no special characters).
- Do not introduce blank lines inside the frontmatter block.
- Do not modify any other field.

| # | File | Line value to insert |
|---|------|----------------------|
| 1.1 | `agents/designer.md` | `model: claude-opus-4-7` |
| 1.2 | `agents/technical-writer.md` | `model: claude-sonnet-4-6` |
| 1.3 | `agents/code-validator.md` | `model: claude-sonnet-4-6` |
| 1.4 | `agents/spec-validator.md` | `model: claude-sonnet-4-6` |

### Step 2: Frontmatter edits — `agents/coders/` (5 files, NOT `_base.md`)

Same procedure as Step 1. Insert `model: claude-opus-4-7` between `name:` and `description:` for each file below.

| # | File | Line value to insert |
|---|------|----------------------|
| 2.1 | `agents/coders/python.md` | `model: claude-opus-4-7` |
| 2.2 | `agents/coders/javascript.md` | `model: claude-opus-4-7` |
| 2.3 | `agents/coders/rust.md` | `model: claude-opus-4-7` |
| 2.4 | `agents/coders/sql.md` | `model: claude-opus-4-7` |
| 2.5 | `agents/coders/svelte.md` | `model: claude-opus-4-7` |

**CRITICAL — `_base.md` exclusion**: Do NOT add a `model:` line to `agents/coders/_base.md`. It is a shared rules document loaded by inclusion, not directly invoked as an agent. A `model:` field on it would be inert and misleading. After this step, confirm by reading `agents/coders/_base.md` that no `model:` line exists.

### Step 3: Create `docs/AGENT_MODEL_GUIDE.md`

Create a new file at `docs/AGENT_MODEL_GUIDE.md` containing the following sections in order. The guide must be written as a standalone reference document for contributors adding new agents.

#### Section 3.1: Title and Purpose
A top-level heading and a 2-3 sentence purpose statement explaining that this document is the criteria reference for assigning a Claude model to each agent under `agents/`.

#### Section 3.2: Supported Model Identifiers (3 rows)
A table or bullet list with exactly three rows, each row giving the full model identifier and a one-line characterization:
- `claude-opus-4-7` — highest reasoning capacity; reserved for complex trade-off analysis and code generation.
- `claude-sonnet-4-6` — balanced cost/quality; default choice for template-driven and instruction-following work.
- `claude-haiku-4-5-20251001` — lowest cost; available for future short-context, deterministic tasks. (Not assigned to any agent in v0.5.0.)

#### Section 3.3: Decision Matrix (≥5 rows)
A markdown table with at least five rows mapping a task characteristic to a recommended model. Required rows:

| Task characteristic | Recommended model |
|---------------------|-------------------|
| Template-driven structured writing | `claude-sonnet-4-6` |
| Cross-reference / consistency validation | `claude-sonnet-4-6` |
| Checklist-driven decision making | `claude-sonnet-4-6` |
| Code generation (any language) | `claude-opus-4-7` |
| Architectural / design trade-off analysis | `claude-opus-4-7` |
| Complex debugging / root-cause analysis | `claude-opus-4-7` |

The table may include additional rows; six rows are recommended baseline. The matrix is the primary tool a contributor uses when adding a new agent.

#### Section 3.4: Resolution Order
Document the 4-step priority order used by Claude Code at agent invocation time:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (highest priority)
2. Per-invocation `model` parameter passed by the caller
3. Subagent definition `model:` frontmatter (this is what this work is setting)
4. Main conversation's model (lowest priority / fallback)

Include the citation: `Source: https://code.claude.com/docs/en/sub-agents` (section "Choose a model").

Add a one-paragraph note clarifying that SPEC NFR-4 originally described only steps 2-vs-3 (caller-vs-frontmatter); the full 4-step order including the environment variable is documented here for completeness.

#### Section 3.5: Current Assignments
Mirror the SPEC mapping table exactly. Use the following rows:

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

#### Section 3.6: How to Add a New Agent
A short procedural section. Required content:

1. Decide which row of the decision matrix the new agent's primary task profile matches.
2. Add `model: <full-identifier>` between `name:` and `description:` in the new agent's frontmatter.
3. Use the full version-pinned identifier (e.g., `claude-opus-4-7`), not an alias (e.g., `opus`).
4. **If the new file is a shared/included document** (loaded by inclusion, not invoked directly — like `agents/coders/_base.md`), do NOT add a `model:` field. The field would be inert and misleading.
5. Update Section 3.5 (Current Assignments) of this guide with the new agent's row.

#### Section 3.7: Haiku Status
A short paragraph stating that `claude-haiku-4-5-20251001` is supported and listed but is not assigned to any agent in v0.5.0. Future agents with strictly deterministic, short-context, low-stakes workloads may be candidates. Empirical cost-benefit measurement is out of scope for this release.

### Step 4: Cross-reference updates

#### Step 4.1: `README.md`
Open `README.md` at the repo root. Locate an appropriate section for documentation links (e.g., a "Documentation" or "Docs" subsection, or near the top-level overview). Add a bullet or link line referencing the new guide:

```
- [Agent Model Selection Guide](docs/AGENT_MODEL_GUIDE.md) — criteria for assigning Claude models to agents
```

The exact wording may be adjusted to match the existing README's link style, but the link target `docs/AGENT_MODEL_GUIDE.md` and the descriptive label must both be present.

#### Step 4.2: `docs/ARCHITECTURE.md`
Open `docs/ARCHITECTURE.md`. In a relevant section (e.g., where agent definitions are described, or in a "Related documents" section), add a sentence or bullet referencing the new guide. Example wording:

```
Agent model assignments are documented in [AGENT_MODEL_GUIDE.md](./AGENT_MODEL_GUIDE.md).
```

The exact phrasing may be adjusted to match the file's existing style. The relative link target must resolve to `docs/AGENT_MODEL_GUIDE.md`.

### Step 5: Verification (do this before declaring the phase complete)

Run the following checks from the worktree root:

1. `git grep -l '^model:' agents/` returns exactly **9** files. Expected list:
   - `agents/code-validator.md`
   - `agents/coders/javascript.md`
   - `agents/coders/python.md`
   - `agents/coders/rust.md`
   - `agents/coders/sql.md`
   - `agents/coders/svelte.md`
   - `agents/designer.md`
   - `agents/spec-validator.md`
   - `agents/technical-writer.md`

2. `agents/coders/_base.md` does NOT appear in the result above.

3. Every `model:` value found is one of: `claude-opus-4-7`, `claude-sonnet-4-6`. (`claude-haiku-4-5-20251001` is supported but unassigned in this release.)

4. For each modified agent file, confirm:
   - Opening `---` and closing `---` of the frontmatter block are still present.
   - `name:` and `description:` lines are still present.
   - The `model:` value matches the mapping table in Step 1 / Step 2.

5. `docs/AGENT_MODEL_GUIDE.md` exists and contains all 7 sections (3.1 through 3.7) defined above.

6. `README.md` contains a link whose target resolves to `docs/AGENT_MODEL_GUIDE.md`.

7. `docs/ARCHITECTURE.md` contains a reference to the guide.

## Completion Checklist

Frontmatter edits — top-level (4):
- [x] `agents/designer.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/designer.md:3
- [x] `agents/technical-writer.md` has `model: claude-sonnet-4-6` between `name:` and `description:` — Verified in agents/technical-writer.md:3
- [x] `agents/code-validator.md` has `model: claude-sonnet-4-6` between `name:` and `description:` — Verified in agents/code-validator.md:3
- [x] `agents/spec-validator.md` has `model: claude-sonnet-4-6` between `name:` and `description:` — Verified in agents/spec-validator.md:3

Frontmatter edits — coders/ (5):
- [x] `agents/coders/python.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/coders/python.md:3
- [x] `agents/coders/javascript.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/coders/javascript.md:3
- [x] `agents/coders/rust.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/coders/rust.md:3
- [x] `agents/coders/sql.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/coders/sql.md:3
- [x] `agents/coders/svelte.md` has `model: claude-opus-4-7` between `name:` and `description:` — Verified in agents/coders/svelte.md:3

Exclusion confirmed:
- [x] `agents/coders/_base.md` does NOT contain a `model:` line — Confirmed (grep count: 0)

Guide creation:
- [x] `docs/AGENT_MODEL_GUIDE.md` exists — 5000 bytes
- [x] Section 3.2 (Supported Identifiers) lists exactly 3 model identifiers — opus-4-7, sonnet-4-6, haiku-4-5-20251001
- [x] Section 3.3 (Decision Matrix) has at least 5 rows — 6 rows verified
- [x] Section 3.4 (Resolution Order) lists all 4 steps and cites `https://code.claude.com/docs/en/sub-agents` — Verified
- [x] Section 3.5 (Current Assignments) mirrors the SPEC mapping table — 10 rows (9 agents + _base.md)
- [x] Section 3.6 (How to Add a New Agent) instructs that shared/included files must NOT declare `model:` — Verified
- [x] Section 3.7 (Haiku Status) documents Haiku as supported-but-unassigned in v0.5.0 — Verified

Cross-references:
- [x] `README.md` contains a link to `docs/AGENT_MODEL_GUIDE.md` — Verified: "Agent Model Selection Guide" link present
- [x] `docs/ARCHITECTURE.md` mentions and links to the guide — Verified: links to ./AGENT_MODEL_GUIDE.md

Verification:
- [x] `git grep -l '^model:' agents/` returns exactly 9 files — Count confirmed: 9
- [x] All 9 `model:` values are exactly one of the two assigned identifiers (no typos) — Unique values: {claude-opus-4-7, claude-sonnet-4-6}
- [x] All modified agent files still have valid YAML frontmatter (opens with `---`, closes with `---`) — All 9 files verified

## Notes

- **Do not modify version files** in this phase. `CHANGELOG.md`, `.claude-plugin/plugin.json`, and `.claude-plugin/marketplace.json` are version files; they are updated only at release time per project convention (see project `CLAUDE.md`).
- **Do not modify `agents/coders/_base.md`**. This is enforced by AD-4. The `_base.md` file is loaded by inclusion and is not directly invocable as an agent; a `model:` field would be inert.
- **YAML insertion placement matters**. The instructions specify placing `model:` between `name:` and `description:`. This is for consistency across all 9 files so reviewers (human and AI) can scan diffs uniformly.
- **Use full model IDs, never aliases**. Per AD-2, write `claude-opus-4-7`, not `opus`. Aliases are not acceptable in frontmatter for this work because they are not version-pinned.
- **Caller override semantics**. The frontmatter value is a default. Callers passing `model=` at invocation time override the frontmatter (step 2 beats step 3 in the resolution order). This must be documented in the guide.
- **OQ-3 resolution**: SPEC asked whether `_base.md` should also receive `model:` for symmetry. Resolution: NO. A `model:` field on a non-invocable shared document is inert and misleading. Documented in AD-4 and reinforced in guide Section 3.6.
- **OQ-4 resolution**: No current agent is assigned to Haiku in this release. Haiku remains documented as a supported identifier for future agents. Resolved in AD-5.
- **Test strategy**: This phase is documentation/configuration only. There is no runtime code to unit-test. PHASE_1_TEST.md is verification-by-inspection (file-content checks).
