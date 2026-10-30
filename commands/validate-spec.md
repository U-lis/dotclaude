---
description: Validate consistency across all planning documents using spec-validator agent. Use after design documents are created or when user invokes /dotclaude:validate-spec.
---
# /dotclaude:validate-spec

Check that SPEC, GLOBAL, PLAN, and TEST documents agree. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`.

Prerequisite: `{working_directory}/{doc_dir}/` holds `SPEC.md`, `GLOBAL.md`, at least one `PHASE_{k}_PLAN_{keyword}.md`, and the matching `PHASE_{k}_TEST.md`.

1. Call spec-validator with the directory. Its checklist (requirements coverage, test matrix cells, consistency, dependencies, merge plans for parallel groups) is in its definition.
2. If the report lists Critical or Warning issues, call technical-writer with the report (missing matrix cells become new TEST rows) and validate again. Stop after 3 rounds (Contract: Limits) and show the remaining issues to the user; some may need a SPEC decision rather than a document fix.
3. Report PASSED or the remaining issues.

Next: `/dotclaude:code 1`.
