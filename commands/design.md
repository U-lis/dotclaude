---
description: Transform SPEC into detailed implementation plan using Designer agent. Use after SPEC.md is approved or when user invokes /dotclaude:design.
---
# /dotclaude:design

Turn an approved SPEC.md into design documents. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; prompt templates in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`.

Prerequisite: `${CLAUDE_PLUGIN_ROOT}/hooks/spec-meta.sh check-approved <spec>` exits 0 (SPEC approved and unchanged since), and the current branch is the work branch (Contract: Worktree). Paths come from the SPEC metadata block (`spec-meta.sh find`).

1. Call designer with the SPEC path and the resolved `parallel_phases` value (Contract: Configuration); say in the prompt when the user asked for parallel phases. If the output's `OPEN` list is not `none`, ask the user all of its items in one AskUserQuestion and call designer again with the answers. Over-cap phase counts and work outside the SPEC's requirements arrive as `OPEN` items too.
2. Call technical-writer with the designer output. It writes `GLOBAL.md`, `PHASE_{k}_PLAN_{keyword}.md` and `PHASE_{k}_TEST.md` per phase, and `PHASE_{k}.5_PLAN_MERGE.md` per parallel group. When the output says `proportional: true`, it writes one PLAN and one TEST and no GLOBAL.md; record it with `spec-meta.sh decision <spec> add proportional`.
3. Call pruner in doc mode on the PLAN and TEST files. If it lists candidates, call technical-writer to apply them (keep at least one test per behavior).
4. Commit the design documents (Contract: Commits; with `workspace_tracking: ignore` take the snapshot described there instead) and run `spec-meta.sh stage <spec> code`.
5. Show the user the architecture decisions and the phase table from GLOBAL.md (for proportional work, from the single PLAN). If the user asks for changes, run steps 1–4 again with the feedback and commit the revised documents.

Next: `/dotclaude:validate-spec`, then `/dotclaude:code 1`. For proportional work, `/dotclaude:validate-spec` may be skipped; code-validator still runs for the phase.
