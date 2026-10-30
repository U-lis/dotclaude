---
description: Transform SPEC into detailed implementation plan using Designer agent. Use after SPEC.md is approved or when user invokes /dotclaude:design.
---
# /dotclaude:design

Turn an approved SPEC.md into design documents. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; prompt templates in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md`.

Prerequisite: `{working_directory}/{doc_dir}/SPEC.md` exists and is committed, and the current branch is the work branch (Contract: Worktree). Paths come from the SPEC metadata block.

1. Call designer with the SPEC path. If it returns open questions, ask the user and call it again with the answers.
2. Call technical-writer with the designer output. It writes `GLOBAL.md`, `PHASE_{k}_PLAN_{keyword}.md` and `PHASE_{k}_TEST.md` per phase, and `PHASE_{k}.5_PLAN_MERGE.md` per parallel group.
3. Call pruner in doc mode on the PLAN and TEST files. If it lists candidates, call technical-writer to apply them (keep at least one test per behavior).
4. Commit the design documents (Contract: Commits).
5. Show the user the architecture decisions and the phase table from GLOBAL.md. If the user asks for changes, run steps 1–4 again with the feedback and commit the revised documents.

Next: `/dotclaude:validate-spec`, then `/dotclaude:code 1`.
