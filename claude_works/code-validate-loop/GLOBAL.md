# Code > Validate > Checklist > Commit Loop Fix - Global Documentation

## Feature Overview

### Purpose

Restore the intended code > validate > checklist update > commit loop in the dotclaude workflow. The loop is currently non-functional: coder agents are invoked with incorrect namespaces, the validator cannot invoke coder agents for fixes, quality tools are not auto-detected, document updates are skipped during validation, and per-phase commits omit documentation files.

### Problem

After the SPEC-based design phase completes correctly, the code implementation phase fails at multiple points:
1. Coder agent namespace mismatch (`dotclaude:coder-{lang}` vs correct `dotclaude:coders:coder-{lang}`)
2. Validator retry logic uses abstract pseudo-code (`send_fix_instructions`, `wait_for_coder_completion`) that agents cannot execute
3. Orchestrator manages the retry loop externally but provides no concrete implementation
4. Quality tools are listed statically without project-aware detection or graceful fallback
5. Document updates (PLAN, GLOBAL, TEST) are not performed by the validator
6. Per-phase commits only include code files, omitting updated documentation

### Solution

- **Validator self-loop**: code-validator owns the entire validate-fix cycle internally, invoking coder agents via Task tool when fixes are needed (max 3 attempts)
- **Single invocation**: Orchestrator invokes code-validator ONCE per phase with full context (worktree path, coder namespace, document paths); receives final PASS/FAIL result
- **Quality auto-detection**: Validator inspects project config files (package.json, pyproject.toml, Cargo.toml, etc.) to determine available tools, verifies command availability, falls back to N/A gracefully
- **Document update timing**: Validator updates PLAN checklist, GLOBAL phase status, and TEST results AFTER final successful coder completion only (prevents overwrites during retries)
- **Expanded commit scope**: Per-phase commits include code files AND updated PHASE_PLAN, GLOBAL, PHASE_TEST documents

## Architecture Decisions

### AD-1: Validator Owns the Validate-Fix Loop

**Decision**: The code-validator agent manages the entire validate-fix cycle internally via Task tool invocations of coder agents.

**Rationale**: The orchestrator-mediated loop (current design) uses abstract pseudo-code that agents cannot execute. Moving loop ownership to the validator eliminates the need for orchestrator-level retry management and makes the validator a self-contained unit. The orchestrator invokes the validator once and receives a final result.

**Consequence**: The validator must receive the coder agent namespace from the orchestrator prompt so it can invoke the correct coder agent for fixes.

### AD-2: Coder Namespace Corrected to Match Directory Structure

**Decision**: All coder agent invocations use `dotclaude:coders:coder-{detected_language}` (with `coders:` prefix).

**Rationale**: Coder agents reside in `agents/coders/*.md` (subdirectory). The Task tool namespace must reflect the actual directory path: `coders:coder-{lang}`. The current flat namespace `coder-{lang}` does not resolve to any agent definition.

**Consequence**: All references in `start-new.md`, `code.md`, and `code-validator.md` must use the corrected namespace.

### AD-3: Quality Tools Auto-Detected from Project Config Files

**Decision**: The validator detects available quality tools by inspecting project configuration files (package.json, pyproject.toml, Cargo.toml, etc.) and verifies command availability before execution.

**Rationale**: Projects use different toolchains. Hardcoded quality commands fail when the expected tool is not installed. Auto-detection with graceful N/A fallback ensures validation proceeds with whatever tools are available.

**Consequence**: The validator needs a detection algorithm that maps config files to tool commands and checks binary availability.

### AD-4: Document Updates After Final Coder Completion Only

**Decision**: The validator updates PHASE_PLAN checklist, GLOBAL phase status, and PHASE_TEST results only after the final successful coder completion (not during retry iterations).

**Rationale**: If the validator updates documents during retries and then the coder overwrites files during a fix attempt, the document updates may be lost or inconsistent. Deferring updates to after final success ensures consistency.

**Consequence**: The validator must track validation state internally across retry attempts and only write document updates once at the end.

### AD-5: Commit Scope Expanded to Include Documentation

**Decision**: Per-phase `git add` and `git commit` includes PHASE_PLAN, GLOBAL, and PHASE_TEST documents alongside code files.

**Rationale**: The validator updates these documents as part of the validation cycle. Omitting them from the commit creates a gap where the repository state does not reflect the actual phase completion status.

**Consequence**: Both `start-new.md` and `code.md` must expand their `git add` patterns.

### AD-6: Single-Invocation Orchestrator Prompt

**Decision**: The orchestrator passes all necessary context (worktree_path, coder namespace, phase info, document paths) to the validator in a single prompt. No intermediate orchestrator-validator communication.

**Rationale**: Eliminates the need for orchestrator-level retry loops and intermediate result handling. The validator operates autonomously with full context.

**Consequence**: The validator prompt must be comprehensive, including all paths and context the validator needs to operate independently.

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Core Loop Fix: Rewrite code-validator.md (self-loop, quality detection, document timing) and start-new.md (namespace fix, validator prompt, simplified loop, expanded commit) | Not Started | - |
| 2 | Align code.md: Mirror Phase 1 patterns (correct namespace, validator-managed loop reference, expanded commit, worktree context) | Not Started | Phase 1 |

## File Structure

### Files to Modify

| File | Phase | Change Summary |
|------|-------|----------------|
| `agents/code-validator.md` | 1 | Rewrite retry logic with Task tool coder invocation; add quality tool auto-detection; enhance document update timing; add worktree/namespace context handling |
| `commands/start-new.md` | 1 | Fix coder namespace (5 locations); rewrite validator prompt with full context; simplify retry loop to single invocation; expand commit scope |
| `commands/code.md` | 2 | Fix coder namespace in Coder Selection and Task patterns; update validation loop diagram; expand pre-commit checklist; add worktree context to validator invocation |

### Files NOT Modified

| File | Reason |
|------|--------|
| `agents/designer.md` | Out of scope (design phase works correctly) |
| `agents/technical-writer.md` | Out of scope |
| `commands/init-*.md` | Out of scope |
| `agents/coders/*.md` | Coder agent definitions do not need changes |
| `dotclaude-config.json` | No new configuration fields (quality tools auto-detected) |
