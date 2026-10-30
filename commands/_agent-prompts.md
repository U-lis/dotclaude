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
Requirements gathered from the user: {answers}
Analysis results: {related code, conflicts and resolutions, edge cases}
Include a "Decisions required" section for anything the user still has to choose.
```

## designer

```
Read {worktree_path}/{working_directory}/{doc_dir}/SPEC.md and design the implementation.
Return: architecture decisions with rationale; phase breakdown with dependencies, marking parallel groups only when the file/module/test analysis shows independence; per-phase checklist items that are verifiable; files to create or modify.
If something in SPEC is ambiguous, return the questions instead of guessing. You cannot ask the user directly.
```

## technical-writer: design documents

```
Write the design documents in {worktree_path}/{working_directory}/{doc_dir}/ from this designer output:
{designer output}
Templates: ${CLAUDE_PLUGIN_ROOT}/templates/GLOBAL.md, PHASE_PLAN.md, PHASE_TEST.md, PHASE_MERGE.md.
Files: GLOBAL.md, PHASE_{k}_PLAN_{keyword}.md and PHASE_{k}_TEST.md per phase, PHASE_{k}.5_PLAN_MERGE.md per parallel group. English. Each PLAN lists under Requirements the SPEC FR/NFR ids it completes; every SPEC requirement goes to exactly one phase.
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
Validate the documents in {worktree_path}/{working_directory}/{doc_dir}/ (SPEC.md, GLOBAL.md, PHASE_*_PLAN_*.md, PHASE_*_TEST.md, PHASE_*.5_PLAN_MERGE.md if present). Return the report with issues and suggested fixes.
```

## coder: implement a phase

```
Implement phase {phase_id}.
Worktree: {worktree_path}. All file operations happen there.
PLAN: {working_directory}/{doc_dir}/PHASE_{phase_id}_PLAN_{keyword}.md
TEST: {working_directory}/{doc_dir}/PHASE_{phase_id}_TEST.md
GLOBAL: {working_directory}/{doc_dir}/GLOBAL.md
Work test-first: write the tests from TEST, run them and report that they fail, then implement until they pass. Do not commit.
Report: files changed, tests added, the RED and GREEN run output, anything unresolved.
```

For a parallel phase, `{worktree_path}` is that phase's own worktree.

## code-validator

```
Validate phase {phase_id} and own its validate-fix loop.
Worktree: {worktree_path}
Coder: {coder_namespace}
PLAN: {working_directory}/{doc_dir}/PHASE_{phase_id}_PLAN_{keyword}.md
TEST: {working_directory}/{doc_dir}/PHASE_{phase_id}_TEST.md
GLOBAL: {working_directory}/{doc_dir}/GLOBAL.md
Return PASS or FAIL with the report.
```

## technical-writer: DOCS_UPDATE

```
Role: DOCS_UPDATE. Target version: {target_version}. Latest tag: {tag}.
Commits since the tag:
{git log output}
SPEC summary: {one paragraph}
Update CHANGELOG.md (Keep a Changelog, new entry at the top) and README.md only where the work changed something a reader would notice.
```
