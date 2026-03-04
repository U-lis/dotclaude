<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-code-validate-loop
-->

# Code > Validate > Checklist > Commit Loop Fix - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/57
**Target Version**: 0.4.0
**Severity**: Major (core functionality failure)

## Overview

The code > validate > checklist update > commit loop in the dotclaude workflow is non-functional. After the SPEC-based design phase completes correctly, the code implementation phase fails at multiple points: the coder agent does not wait for validator inspection, the validator does not update checklist documents, lint/format/test quality checks do not execute, and per-phase commits do not include updated documentation files. This bugfix restores the intended loop behavior where each phase undergoes a complete code > validate > document update > commit cycle.

## Bug Description

### Symptoms

1. Coder completes coding but does not wait for validator inspection results
2. code-validator does not update PHASE_{k}_PLAN.md checklist items
3. code-validator does not update GLOBAL.md phase status
4. Lint, format, and test quality checks do not execute during validation
5. Per-phase commits only include code files, missing updated PLAN/GLOBAL/TEST documents
6. The retry loop (coder fix -> re-validate) does not function

### Reproduction

1. Run `/dotclaude:start-new`
2. Select any work type
3. Complete SPEC and Design phases (these work correctly)
4. Select scope that includes "Code" (e.g., "Design -> Code")
5. Observe: validation loop does not execute properly during code phase

## Root Cause Analysis

### RC-1: Coder Agent Namespace Mismatch

**Location**: `commands/start-new.md` lines 600, 639, 657

**Current (incorrect)**:
```
subagent_type="dotclaude:coder-{detected_language}"
```

**Correct**:
```
subagent_type="dotclaude:coders:coder-{detected_language}"
```

**Evidence**: Coder agents reside in `agents/coders/*.md` (subdirectory), requiring the `coders:coder-{lang}` namespace path. The current flat namespace `coder-{lang}` does not resolve to any agent definition.

**Impact**: Coder agent invocation may fail silently or map to wrong agent, causing the entire code phase to malfunction.

### RC-2: Missing Orchestrator Mediation Logic

**Location**: `commands/start-new.md` lines 748-762

**Problem**: The retry loop between coder and validator is pseudo-code only. There is no concrete implementation for:
- Passing validator feedback (error details, fix instructions) back to the coder
- Handling the result handoff between coder and validator Task tool invocations
- Determining whether to retry, skip, or commit based on validator output

**Current pseudo-code**:
```
attempt = 0
while attempt < 3:
  coder_result = invoke_coder(phase_id)
  validator_result = invoke_code_validator(phase_id)
  if validator_result.status == "PASS":
    commit_phase()
    break
  attempt += 1
```

This is not executable instruction -- it is abstract pseudo-code that agents cannot follow.

### RC-3: Incomplete Commit Scope

**Location**: `commands/start-new.md` lines 741-742

**Current**: Only code files are committed:
```bash
git add {changed_files}
git commit -m "feat/fix: implement phase {phase_id} - {brief_description}"
```

**Missing from commit**:
- Updated `PHASE_{k}_PLAN_{keyword}.md` (checked checklist items)
- Updated `GLOBAL.md` (phase status changes)
- Updated `PHASE_{k}_TEST.md` (test results if applicable)

### RC-4: Missing Project Quality Tool Detection

**Location**: `agents/code-validator.md` lines 56-80

**Problem**: Language-specific quality commands (ruff, eslint, cargo clippy, etc.) are listed statically but there is no mechanism to:
- Detect which language/toolchain the current project uses
- Determine if the listed commands are actually available in the project
- Fall back gracefully when a command does not exist
- Read project-specific quality tool configuration

**User expectation**: "lint, format, test must work, and since each project is different, it should check the project settings and proceed accordingly."

### RC-5: Incomplete code-validator Prompt in Orchestrator

**Location**: `commands/start-new.md` lines 694-732

**Problem**: The prompt sent to code-validator:
- Asks for validation result report only (read-only inspection)
- Does NOT instruct validator to update PLAN/GLOBAL documents
- Does NOT provide worktree path context (validator cannot find files in worktree)
- Does NOT instruct validator to invoke coder for fixes (validator has no loop authority)
- Does NOT provide the coder agent namespace for fix delegation

## Functional Requirements

### FR-1: Fix Coder Agent Namespace

- [ ] FR-1.1: Update all coder agent invocations in `commands/start-new.md` to use correct namespace `dotclaude:coders:coder-{detected_language}`
- [ ] FR-1.2: Update coder agent references in `commands/code.md` to match the corrected namespace
- [ ] FR-1.3: Verify namespace matches actual agent file locations in `agents/coders/` directory

### FR-2: Implement Validator-Managed Loop

The code-validator agent manages the entire validate-fix cycle internally (user decision: "validator self-loop" approach).

- [ ] FR-2.1: code-validator receives full context from orchestrator in a single invocation (phase info, worktree path, coder agent namespace, document paths)
- [ ] FR-2.2: code-validator executes validation checks (checklist verification, quality checks)
- [ ] FR-2.3: On validation failure, code-validator invokes the appropriate coder agent via Task tool with specific fix instructions
- [ ] FR-2.4: code-validator re-validates after coder fix (max 3 total attempts)
- [ ] FR-2.5: On final success, code-validator updates PHASE_{k}_PLAN.md checklist, GLOBAL.md phase status, and PHASE_{k}_TEST.md
- [ ] FR-2.6: code-validator returns final result (PASS/FAIL) with comprehensive report to orchestrator
- [ ] FR-2.7: On 3x failure, code-validator marks phase as SKIPPED in GLOBAL.md and documents unresolved errors

### FR-3: Expand Commit Scope

- [ ] FR-3.1: Per-phase commits must include all changed code files
- [ ] FR-3.2: Per-phase commits must include updated `PHASE_{k}_PLAN_{keyword}.md`
- [ ] FR-3.3: Per-phase commits must include updated `GLOBAL.md`
- [ ] FR-3.4: Per-phase commits must include updated `PHASE_{k}_TEST.md` (if modified)
- [ ] FR-3.5: Commit message must reflect both code and document changes

### FR-4: Implement Quality Tool Detection

- [ ] FR-4.1: code-validator must detect available quality tools by inspecting project configuration files (package.json, pyproject.toml, Cargo.toml, etc.)
- [ ] FR-4.2: code-validator must verify command availability before execution (check if tool binary exists)
- [ ] FR-4.3: When a quality tool is not available, mark that check as N/A (do not fail validation)
- [ ] FR-4.4: Quality check results must be included in the validation report
- [ ] FR-4.5: Support detection for at minimum: Python (ruff, pytest), JavaScript/TypeScript (eslint, tsc, npm test), Rust (cargo clippy, cargo test), Svelte (eslint, svelte-check)

### FR-5: Simplify Orchestrator Loop

- [ ] FR-5.1: Orchestrator (`start-new.md`) invokes code-validator ONCE per phase with full context
- [ ] FR-5.2: Orchestrator receives final result from code-validator (no intermediate retry management)
- [ ] FR-5.3: Orchestrator commits all files (code + documents) based on validator result
- [ ] FR-5.4: Orchestrator handles SKIP case (mark in GLOBAL.md, continue to next phase)

### FR-6: Align code.md with New Pattern

- [ ] FR-6.1: `commands/code.md` validation loop section must reference the validator-managed loop pattern
- [ ] FR-6.2: `commands/code.md` must use corrected coder agent namespace
- [ ] FR-6.3: `commands/code.md` commit scope must include document files
- [ ] FR-6.4: `commands/code.md` must pass worktree path context to code-validator

### FR-7: Provide Worktree Context to Validator

- [ ] FR-7.1: Orchestrator must pass `worktree_path` to code-validator prompt
- [ ] FR-7.2: code-validator must use worktree path to locate all files (code, PLAN, GLOBAL, TEST documents)
- [ ] FR-7.3: code-validator must pass worktree path to coder when delegating fixes

## Non-Functional Requirements

- [ ] NFR-1: All changes are to `.md` instruction files only (no source code changes required)
- [ ] NFR-2: Backward compatible with existing SPEC > Design > Code workflow sequence
- [ ] NFR-3: Parallel phase execution (worktree isolation) must continue to function correctly
- [ ] NFR-4: Maximum 3 retry attempts per phase (existing limit preserved)
- [ ] NFR-5: Quality check graceful degradation -- missing tools must not block the entire validation
- [ ] NFR-6: Document updates (PLAN, GLOBAL, TEST) must happen AFTER final coder completion to prevent overwrites during retry

## Constraints

- All changes are limited to `.md` instruction files (agents and commands)
- Must maintain backward compatibility with existing SPEC > Design > Code workflow
- Must not break parallel phase execution (worktree isolation pattern)
- Quality tool commands must be auto-detected per project (not hardcoded assumptions)
- The validator self-loop approach requires code-validator to use Task tool for coder invocation
- Maximum retry limit of 3 attempts per phase must be preserved

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/start-new.md` | Modify | Fix coder namespace (3 locations), enhance validator prompt, expand commit scope, simplify retry loop |
| `agents/code-validator.md` | Modify | Implement validator-managed loop with coder invocation, add quality tool detection, enhance document update logic |
| `commands/code.md` | Modify | Align validation loop with new pattern, fix coder namespace, expand commit scope |

## Conflict Analysis

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | code-validator retry logic assumes direct agent-to-agent communication (`send_fix_instructions`, `wait_for_coder_completion`) | code-validator invokes coder via Task tool with fix instructions | Rewrite retry logic in `agents/code-validator.md` to use explicit Task tool invocations |
| 2 | `start-new.md` and `code.md` both implement their own validation workflow with different levels of detail | Single source of truth for loop logic owned by code-validator | Both `start-new.md` and `code.md` delegate loop management to code-validator; they only invoke validator once and handle the final result |

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Project has no test runner configured | Quality check for tests marked as N/A; validation proceeds with available checks only |
| 2 | Coder creates files not listed in PLAN | Validator reports additional files in validation result; all changed files included in commit |
| 3 | Validator updates GLOBAL.md then coder retry overwrites | Validator updates documents AFTER final coder completion only (FR-2.5, NFR-6) |
| 4 | Parallel phases need different quality tools | Detect language/toolchain from each phase's PLAN document independently |
| 5 | lint/test commands do not exist in project | Graceful skip with warning in validation report; do not fail validation |
| 6 | 3x retry still fails | GLOBAL.md phase status marked as SKIPPED; errors documented in validation report; orchestrator continues to next phase |
| 7 | code-validator selects wrong coder language | Detect language from PLAN document metadata or SPEC.md metadata; fall back to file extension analysis |
| 8 | Worktree path not provided in validator prompt | code-validator defaults to current directory (`.`); logs warning about missing worktree context |

## Out of Scope

- Changes to `agents/designer.md` or `agents/technical-writer.md` agents
- Changes to `commands/init-*.md` workflow files
- New quality tool integrations beyond existing language support (Python, JS/TS, Rust, Svelte)
- UI or user experience changes to the workflow
- Changes to SPEC or Design phase behavior (these work correctly)
- Addition of new configuration fields to `dotclaude-config.json` (quality tools are auto-detected)

## Open Questions

None. All design decisions have been resolved:
- Validator self-loop approach confirmed by user
- Quality tool detection via project file inspection (not configuration)
- Document update timing: after final coder completion only
