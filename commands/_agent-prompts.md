---
description: Prompt templates the orchestrator uses when calling dotclaude agents. Internal reference.
user-invocable: false
---
# Agent prompt templates

Each call uses the Agent tool with `subagent_type` set to the agent name. The agent definition supplies the rules; the prompt supplies the task, the paths, and the inputs. Paths are absolute or relative to the worktree root, and the worktree root is always stated because agents start in the main session's directory and `cd` does not persist between their tool calls.

## technical-writer: SPEC.md

```
Write {worktree_path}/{working_directory}/{doc_dir}/SPEC.md.
Template: ${CLAUDE_PLUGIN_ROOT}/templates/SPEC.md. Language: {language}.
Metadata block (first lines of the file, see ${CLAUDE_PLUGIN_ROOT}/templates/SPEC.md):
  working_directory: ..., base_branch: ..., language: ..., worktree_path: ..., doc_dir: ..., target_version: ..., github_issue: ... (omit if none), stage: spec_review, approved_at: null, approved_hash: null, decisions: [], handoff: ""
Source: {intake summary and reference (issue/Jira/prefill/free text)}
Requirements: {FR/NFR list}
Analysis results: related code table; conflicts with resolutions; edge cases as (FR, partition, case, expected behavior); out-of-scope findings (reported, not requirements)
{bugfix: root cause file:line and fix strategy | refactor: behavior preservation and dependents}
Decisions Required table: rows the user still has to choose, with options and a recommendation.
```

## designer

```
Read {worktree_path}/{working_directory}/{doc_dir}/SPEC.md and design the implementation. Worktree: {worktree_path}.
parallel_phases: {true|false}{; the user asked for parallel phases, when they did}
{answers to earlier OPEN items, when this is a repeat call}
Return: proportional true/false; architecture decisions with rationale; phases with the FR/NFR ids each completes and dependencies; per-phase checklist items that are verifiable; files to create or modify, each existing one cited file:line and each new one marked (new); the OPEN list (or "OPEN: none").
Confirm every existing symbol, path, and config key with Grep/Read before naming it. What you cannot confirm, and anything you would ask the user, goes to OPEN; do not guess it.
```

## technical-writer: design documents

```
Write the design documents in {worktree_path}/{working_directory}/{doc_dir}/ from this designer output:
{designer output}
Templates: ${CLAUDE_PLUGIN_ROOT}/templates/GLOBAL.md, PHASE_PLAN.md, PHASE_TEST.md, PHASE_MERGE.md.
Files: GLOBAL.md, PHASE_{k}_PLAN_{keyword}.md and PHASE_{k}_TEST.md per phase, PHASE_{k}.5_PLAN_MERGE.md per parallel group; when the output says proportional: true, one PLAN and one TEST and no GLOBAL.md. English. Each PLAN lists under Requirements the SPEC FR/NFR ids it completes; every SPEC requirement goes to exactly one phase. Existing documents are edited in place (your definition: Updating existing documents).
```

## pruner (scope mode)

Called on SPEC.md before it is shown for approval; technical-writer applies the report to the Edge Cases table.

```
Mode: scope. Working dir: {worktree_path}. Target: {working_directory}/{doc_dir}/SPEC.md (Edge Cases table and FR list).
```

## pruner (doc mode) and applying its report

```
Mode: doc. Working dir: {worktree_path}. Targets: all PHASE_*_TEST.md and PHASE_*_PLAN_*.md in {working_directory}/{doc_dir}/.
```

```
Apply this pruner doc-mode report to the PHASE_*_TEST.md and PHASE_*_PLAN_*.md files in {worktree_path}/{working_directory}/{doc_dir}/. Keep at least one test per behavior. Report:
{pruner report}
```

## spec-validator

```
Validate the documents in {worktree_path}/{working_directory}/{doc_dir}/ (SPEC.md, GLOBAL.md, PHASE_*_PLAN_*.md, PHASE_*_TEST.md, PHASE_*.5_PLAN_MERGE.md if present). Report each missing TEST matrix cell as Critical with its (FR, Partition), and each TEST row without a SPEC FR as Critical. Return the report with issues and suggested fixes.
```

## coder: implement a phase

```
Implement phase {phase_id}.
Worktree: {worktree_path}. All file operations happen there.
PLAN: {working_directory}/{doc_dir}/PHASE_{phase_id}_PLAN_{keyword}.md
TEST: {working_directory}/{doc_dir}/PHASE_{phase_id}_TEST.md
GLOBAL: {working_directory}/{doc_dir}/GLOBAL.md
Rules: {working_directory}/RULES.md (may be absent)
Follow the procedure in _coder-base.md: read conventions, search for existing implementations, work test-first, self-review. Do not commit.
Report in the _coder-base.md Report format: conventions read, existing-implementation results, tests with RED/GREEN output and pinned lines, self-review, decisions, anything unresolved.
```

For a parallel phase, `{worktree_path}` is that phase's own worktree.

## code-validator

```
Validate phase {phase_id} and own its validate-fix loop.
Worktree: {worktree_path}
Coder: {coder_namespace}
SPEC: {working_directory}/{doc_dir}/SPEC.md
PLAN: {working_directory}/{doc_dir}/PHASE_{phase_id}_PLAN_{keyword}.md
TEST: {working_directory}/{doc_dir}/PHASE_{phase_id}_TEST.md
GLOBAL: {working_directory}/{doc_dir}/GLOBAL.md
Check the checklist, every SPEC requirement against the PLAN's Requirements, every TEST matrix row, and the quality tools of each changed file's nearest project directory.
Return the report table and one status: PASS (marker created after the documents), PASS-WITH-WARN (no test runner or no linter; documents updated, marker not created, the user must confirm before the commit), or FAIL.
```

## technical-writer: DOCS_UPDATE

```
Role: DOCS_UPDATE. Target version: {target_version}. Latest tag: {tag}.
Commits since the tag:
{git log output}
SPEC summary: {one paragraph}
Update CHANGELOG.md (Keep a Changelog, new entry at the top) and README.md only where the work changed something a reader would notice.
```
