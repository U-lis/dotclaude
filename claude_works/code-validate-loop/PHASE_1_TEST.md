# Phase 1: Test Cases

## Test Coverage Target

>= 70%

These test cases verify the correctness of changes to `agents/code-validator.md` and `commands/start-new.md`. Since all changes are to markdown instruction files (not executable code), "testing" means structural verification, content correctness, and behavioral contract validation through manual or automated inspection.

## Unit Tests

### code-validator.md: Context from Orchestrator Section

- [x] TC-1.1: Section "## Context from Orchestrator" exists after "## Language" section (line 25, after Language section ending at line 23)
- [x] TC-1.2: Section documents all 6 required parameters: worktree_path, coder_namespace, phase_id, plan_path, test_path, global_path (lines 29-34)
- [x] TC-1.3: Default behavior documented for missing worktree_path (defaults to ".", warns) (line 36)

### code-validator.md: Quality Tool Auto-Detection

- [x] TC-2.1: Section "## Quality Tool Detection and Execution" exists and replaces the old static commands section (line 67; no "## Language-Specific Quality Commands" section found)
- [x] TC-2.2: Detection algorithm covers package.json (JS/TS), pyproject.toml (Python), Cargo.toml (Rust), svelte.config.js (Svelte) (lines 75-78)
- [x] TC-2.3: For Python detection: ruff, ty/mypy, pytest commands listed with dependency checks (lines 82-85)
- [x] TC-2.4: For JS/TS detection: eslint, tsc, npm test commands listed with config checks (lines 87-90)
- [x] TC-2.5: For Rust detection: cargo clippy, cargo test commands listed (lines 92-95)
- [x] TC-2.6: For Svelte detection: eslint, svelte-check, npm test commands listed (lines 97-100)
- [x] TC-2.7: Binary availability check instruction present (which/command -v pattern) (lines 102-103)
- [x] TC-2.8: N/A fallback documented with message format "Tool not available: {binary}" (line 104)
- [x] TC-2.9: Quality Command Reference subsection preserved as reference with disclaimer note (line 110 heading, line 112 disclaimer)
- [x] TC-2.10: Each check reports as PASS / FAIL (with details) / N/A (with reason) (line 107)

### code-validator.md: Validate-Fix Loop

- [x] TC-3.1: Section "## Validate-Fix Loop" exists and replaces old "## Retry Logic" section (line 141; no "## Retry Logic" found)
- [x] TC-3.2: Flow diagram shows 3 steps: Validate -> Invoke Coder -> Document Update (lines 150, 166, 192)
- [x] TC-3.3: Coder invocation uses Task tool with `{coder_namespace}` parameter (line 169)
- [x] TC-3.4: Coder fix prompt includes: worktree_path, detailed error list, fix instructions, scope limitation (lines 174, 177, 180, 183-184)
- [x] TC-3.5: Maximum 3 attempts enforced (attempt counter starts at 1, loops while < 3) (lines 147, 160)
- [x] TC-3.6: Document update step explicitly states "AFTER final success ONLY" (line 193, line 203)
- [x] TC-3.7: On 3x failure: GLOBAL.md updated to "Skipped", FAIL report returned (lines 162-164, line 207)
- [x] TC-3.8: No references to old pseudo-code patterns (send_fix_instructions, wait_for_coder_completion) (grep confirmed: no matches)

### code-validator.md: Checklist Update Authority

- [x] TC-4.1: Timing rule present at top of section: "TIMING: These updates execute ONLY after the final coder completion" (line 272)
- [x] TC-4.2: File path resolution instruction references `{worktree_path}` for constructing absolute paths (line 276)
- [x] TC-4.3: PLAN update subsection references `plan_path` parameter from orchestrator prompt (line 282)
- [x] TC-4.4: GLOBAL update subsection references `global_path` parameter from orchestrator prompt (line 296)
- [x] TC-4.5: New subsection "### 3. Update PHASE_{k}_TEST.md" exists with test result update instructions (line 310)
- [x] TC-4.6: Verification subsection renumbered to "### 4. Verification Before Reporting" (line 314)

### start-new.md: Coder Namespace Fix

- [x] TC-5.1: Line ~600 contains `dotclaude:coders:coder-{detected_language}` (sequential phase) (line 600)
- [x] TC-5.2: Line ~639 contains `dotclaude:coders:coder-{detected_language}` (parallel Call 1) (line 639)
- [x] TC-5.3: Line ~657 contains `dotclaude:coders:coder-{detected_language}` (parallel Call 2) (line 657)
- [x] TC-5.4: Line ~824 contains `dotclaude:coders:coder-{detected_language}` (parallel execution pattern 1) (line 805 after edits)
- [x] TC-5.5: Line ~829 contains `dotclaude:coders:coder-{detected_language}` (parallel execution pattern 2) (line 810 after edits)
- [x] TC-5.6: No remaining occurrences of `dotclaude:coder-{detected_language}` (without `coders:`) in the file (grep confirmed: no matches)
- [x] TC-5.7: Corrected namespace matches actual agent directory: `agents/coders/` exists with coder agent files (directory contains: _base.md, javascript.md, python.md, rust.md, sql.md, svelte.md)

### start-new.md: Validator Prompt Rewrite

- [x] TC-6.1: Validator Task tool prompt includes `Worktree Path: {worktree_path}` (line 698)
- [x] TC-6.2: Validator prompt includes `Coder Agent Namespace: dotclaude:coders:coder-{detected_language}` (line 699)
- [x] TC-6.3: Validator prompt includes all 3 document paths (PLAN, TEST, GLOBAL) relative to worktree (lines 703-705)
- [x] TC-6.4: Validator prompt grants loop management authority ("You manage the ENTIRE validate-fix loop") (line 708)
- [x] TC-6.5: Validator prompt instructs: update documents ONLY after final successful validation (line 718)
- [x] TC-6.6: Validator prompt instructs: auto-detect quality tools from project config files (line 719)
- [x] TC-6.7: Validator prompt instructs: return final status (PASS or FAIL) with comprehensive report (line 720)

### start-new.md: Simplified Retry Loop

- [x] TC-7.1: No orchestrator-level retry loop exists (no `while attempt < 3` in orchestrator context) -- Note: line 850 has a generic `while attempt < 3` but it is in the general "Error Handling > Subagent Failure" section, not the code-validator specific section
- [x] TC-7.2: "After code-validator Completes" section describes single-invocation pattern (lines 727-743)
- [x] TC-7.3: PASS case includes expanded commit (code files + PLAN + GLOBAL + TEST) (lines 735-738)
- [x] TC-7.4: FAIL case states validator already marked SKIPPED in GLOBAL.md (line 741)
- [x] TC-7.5: Explicit statement: "There is NO orchestrator-level retry loop" (line 743)

### start-new.md: Expanded Commit Scope

- [x] TC-8.1: git add includes `{working_directory}/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md` (line 736)
- [x] TC-8.2: git add includes `{working_directory}/{subject}/GLOBAL.md` (line 737)
- [x] TC-8.3: git add includes `{working_directory}/{subject}/PHASE_{phase_id}_TEST.md` (line 738)
- [x] TC-8.4: git add still includes changed code files (line 735: `git add {changed_code_files}`)

## Integration Tests

- [x] IT-1: Validator prompt in start-new.md references parameters that match the "Context from Orchestrator" section in code-validator.md (worktree_path, coder_namespace, phase_id, plan_path, test_path, global_path) -- Validator prompt (lines 696-722) passes worktree_path, coder namespace, phase_id, and document paths (PLAN, TEST, GLOBAL); code-validator.md Context section (lines 29-34) documents all 6 parameters
- [x] IT-2: Coder namespace in validator prompt matches the corrected namespace used in coder invocations (`dotclaude:coders:coder-{detected_language}`) -- Both validator prompt (line 699) and coder invocations (lines 600, 639, 657, 805, 810) use identical namespace format
- [x] IT-3: Document paths in validator prompt use the same `{working_directory}/{subject}/` pattern as the rest of start-new.md -- Lines 703-705 use `{working_directory}/{subject}/` consistent with patterns throughout start-new.md
- [x] IT-4: The "After code-validator Completes" section in start-new.md is consistent with the validator's output contract (PASS -> COMMIT, FAIL -> SKIP) -- Lines 732-741: PASS leads to commit, FAIL notes validator already marked SKIPPED
- [x] IT-5: The commit scope in start-new.md matches the documents the validator is instructed to update (PLAN, GLOBAL, TEST) -- Lines 736-738 add PLAN, GLOBAL, TEST; code-validator.md lines 194-196 update the same three documents

## Edge Cases

- [x] EC-1: Verify code-validator.md handles missing worktree_path gracefully (default to ".", log warning) -- Line 36: explicit instruction
- [x] EC-2: Verify quality detection handles project with no config files (all checks N/A, validation still proceeds) -- Lines 74-78 inspect for config files; lines 102-107 show N/A fallback when binary not found; detection algorithm proceeds through all project types
- [x] EC-3: Verify quality detection handles project with multiple config files (e.g., package.json AND pyproject.toml - both toolchains detected) -- Line 80: "For each detected project type" implies all detected types are processed
- [x] EC-4: Verify 3x failure path updates GLOBAL.md to "Skipped" and returns structured FAIL report -- Lines 162-164 (SKIPPED path in flow diagram), line 207 (key rule), lines 255-268 (skip report template)
- [x] EC-5: Verify document update timing constraint is explicitly stated (no updates during retry iterations) -- Line 272 (bold TIMING rule), line 203 (key rule: "never during retry iterations")
- [x] EC-6: Verify coder fix prompt includes scope limitation ("ONLY fix the listed errors") -- Lines 183-184 in flow diagram: "ONLY fix the listed errors. Do NOT refactor or add unrelated changes."
