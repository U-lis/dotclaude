# Phase 1: Core Loop Fix

## Objective

Establish the interface contract for the validator-managed validate-fix loop by rewriting `agents/code-validator.md` and updating `commands/start-new.md`. After this phase, the code-validator agent can autonomously run validation, invoke coder agents for fixes, update documentation, and return a final result to the orchestrator in a single invocation.

## Prerequisites

- SPEC.md reviewed and approved
- Access to `agents/code-validator.md`, `commands/start-new.md` source files
- Understanding of Task tool invocation syntax for subagents

## Instructions

### Part A: Rewrite `agents/code-validator.md`

#### A1. Add Context Reception Section (NEW section, insert after "## Language" section)

Add a new section titled `## Context from Orchestrator` that documents the parameters the validator receives in its invocation prompt:

- `worktree_path`: Absolute or relative path to the worktree root (used to resolve all file paths)
- `coder_namespace`: Full Task tool namespace for the coder agent (e.g., `dotclaude:coders:coder-python`)
- `phase_id`: Phase identifier (e.g., `1`, `2`, `3A`)
- `plan_path`: Path to the PHASE_{k}_PLAN_{keyword}.md file (relative to worktree)
- `test_path`: Path to the PHASE_{k}_TEST.md file (relative to worktree)
- `global_path`: Path to GLOBAL.md (relative to worktree)

Include instruction: "If `worktree_path` is not provided, default to `.` (current directory) and log a warning."

#### A2. Add Quality Tool Auto-Detection Section (NEW section, insert after "## Language-Specific Quality Commands")

Replace the current static quality commands section (lines 56-81) with a new section titled `## Quality Tool Detection and Execution`. The section must contain:

**Detection Algorithm:**

```
1. Inspect project root (worktree_path) for configuration files:
   - package.json       -> JavaScript/TypeScript project
   - pyproject.toml     -> Python project
   - Cargo.toml         -> Rust project
   - svelte.config.js   -> Svelte project (also has package.json)

2. For each detected project type, determine quality commands:

   Python (pyproject.toml detected):
     lint:  Check if "ruff" appears in pyproject.toml [tool.ruff] or dependencies -> "ruff check ."
     type:  Check if "ty" or "mypy" in dependencies -> "ty check" or "mypy ."
     test:  Check if "pytest" in dependencies -> "pytest"

   JavaScript/TypeScript (package.json detected):
     lint:  Check package.json devDependencies for "eslint" -> "npx eslint ."
     type:  Check for tsconfig.json existence -> "npx tsc --noEmit"
     test:  Check package.json "scripts.test" exists -> "npm test"

   Rust (Cargo.toml detected):
     lint:  "cargo clippy" (always available with Rust toolchain)
     type:  N/A (compiler handles types)
     test:  "cargo test"

   Svelte (svelte.config.js detected):
     lint:  Check package.json for "eslint" -> "npx eslint ."
     type:  Check for "svelte-check" in dependencies -> "npx svelte-check"
     test:  Check package.json "scripts.test" -> "npm test"

3. Before executing each command, verify binary availability:
   - Run: which {binary} OR command -v {binary}
   - If not found: mark check as N/A with message "Tool not available: {binary}"

4. Execute available commands and capture output
5. Report each check as: PASS / FAIL (with details) / N/A (with reason)
```

**Keep** the existing quality command examples as a reference subsection titled "### Quality Command Reference" but add a note at the top: "These are reference commands. The validator auto-detects which tools are available per project. Do not assume all commands exist."

#### A3. Rewrite Retry Logic Section (lines 86-103)

Replace the entire "## Retry Logic" section (lines 86-103 of current `code-validator.md`) with a new section titled `## Validate-Fix Loop`. The new section must contain:

**Flow Diagram:**

```
┌──────────────────────────────────────────────────────────────┐
│ VALIDATE-FIX LOOP (max 3 total attempts)                     │
│                                                              │
│ attempt = 1                                                  │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ Step 1: Run Validation                                   │ │
│ │   - Check PLAN checklist items against code              │ │
│ │   - Run quality tools (auto-detected)                    │ │
│ │   - Check TEST cases implementation                      │ │
│ └──────────────────────────┬─────────────────────────────┘ │
│                            │                                 │
│                     Passed? ─── YES ──→ Go to Document       │
│                            │            Update (Step 3)      │
│                           NO                                 │
│                            │                                 │
│                   attempt < 3?                               │
│                      │       │                               │
│                     YES      NO ──→ Mark as SKIPPED          │
│                      │              Update GLOBAL.md status   │
│                      ↓              Return FAIL report        │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ Step 2: Invoke Coder for Fix                             │ │
│ │                                                          │ │
│ │ Task(                                                    │ │
│ │   subagent_type="{coder_namespace}",                     │ │
│ │   prompt="""                                             │ │
│ │   ## Task: Fix Validation Errors - Attempt {attempt}/3   │ │
│ │                                                          │ │
│ │   ### Working Directory                                  │ │
│ │   CRITICAL: All operations in: {worktree_path}           │ │
│ │                                                          │ │
│ │   ### Errors to Fix                                      │ │
│ │   {detailed_error_list_from_validation}                   │ │
│ │                                                          │ │
│ │   ### Fix Instructions                                   │ │
│ │   {specific_fix_instructions_per_error}                   │ │
│ │                                                          │ │
│ │   ### Scope                                              │ │
│ │   ONLY fix the listed errors. Do NOT refactor or add     │ │
│ │   unrelated changes.                                     │ │
│ │   """                                                    │ │
│ │ )                                                        │ │
│ └──────────────────────────┬─────────────────────────────┘ │
│                            │                                 │
│                   attempt += 1                               │
│                   Go to Step 1 (re-validate)                 │
│                                                              │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ Step 3: Document Update (AFTER final success ONLY)       │ │
│ │   - Update PHASE_{k}_PLAN_{keyword}.md checklist         │ │
│ │   - Update GLOBAL.md phase status to "Complete"          │ │
│ │   - Update PHASE_{k}_TEST.md with results (if applicable)│ │
│ │   - Return PASS report to orchestrator                   │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**Key Rules:**
- Document updates (PLAN, GLOBAL, TEST) happen ONLY after final successful validation, never during retry iterations
- Coder invocation uses the `{coder_namespace}` received from the orchestrator prompt
- Each error report to the coder must include: file path, line number (if available), error message, and a specific fix suggestion
- The coder fix prompt must include `{worktree_path}` so the coder operates in the correct directory
- If all 3 attempts fail, update GLOBAL.md phase status to "Skipped" and return a FAIL report with all unresolved issues

#### A4. Enhance Checklist Update Authority Section (lines 167-207)

Update the "## Checklist Update Authority (MANDATORY)" section to include explicit file path resolution using `worktree_path`. Modify the instructions as follows:

- Add at the beginning of the section: "All file paths below must be resolved relative to `{worktree_path}`. Example: `{worktree_path}/{working_directory}/{subject}/PHASE_{k}_PLAN_{keyword}.md`"
- In subsection "### 1. Update PHASE_{k}_PLAN_{keyword}.md", add: "Read the plan path from the `plan_path` parameter received in the orchestrator prompt. Use `{worktree_path}` to construct the absolute path."
- In subsection "### 2. Update GLOBAL.md Phase Overview", add: "Read the global path from the `global_path` parameter received in the orchestrator prompt. Use `{worktree_path}` to construct the absolute path."
- Add a new subsection "### 3. Update PHASE_{k}_TEST.md" with instruction: "If the TEST document exists at `{test_path}`, update test results based on quality check outcomes. Mark passing tests with [x] and failing tests with [ ] along with failure reason."
- Renumber existing "### 3. Verification Before Reporting" to "### 4. Verification Before Reporting"

**CRITICAL TIMING RULE**: Add a bold note at the top of the section: "**TIMING: These updates execute ONLY after the final coder completion in the validate-fix loop. Never update documents during retry iterations.**"

---

### Part B: Update `commands/start-new.md`

#### B1. Fix Coder Agent Namespace (5 locations)

Replace the incorrect coder namespace at each of these locations:

**Location 1** - Line 600 (Sequential phase coder invocation):
Change `subagent_type="dotclaude:coder-{detected_language}"` to `subagent_type="dotclaude:coders:coder-{detected_language}"`

**Location 2** - Line 639 (Parallel phase coder invocation, Call 1):
Change `subagent_type="dotclaude:coder-{detected_language}"` to `subagent_type="dotclaude:coders:coder-{detected_language}"`

**Location 3** - Line 657 (Parallel phase coder invocation, Call 2):
Change `subagent_type="dotclaude:coder-{detected_language}"` to `subagent_type="dotclaude:coders:coder-{detected_language}"`

**Location 4** - Line 824 (Parallel execution pattern, Task tool call 1):
Change `subagent_type: "dotclaude:coder-{detected_language}"` to `subagent_type: "dotclaude:coders:coder-{detected_language}"`

**Location 5** - Line 829 (Parallel execution pattern, Task tool call 2):
Change `subagent_type: "dotclaude:coder-{detected_language}"` to `subagent_type: "dotclaude:coders:coder-{detected_language}"`

#### B2. Rewrite code-validator Invocation Prompt (lines 694-732)

Replace the entire code-validator Task tool invocation prompt (within the `### code-validator Invocation` section, lines 691-733) with a new comprehensive prompt that passes full context:

```
Task(
  subagent_type="dotclaude:code-validator",
  prompt="""
## Task: Validate and Fix Phase {phase_id} Implementation

### Context
Worktree Path: {worktree_path}
Coder Agent Namespace: dotclaude:coders:coder-{detected_language}
Phase ID: {phase_id}

### Document Paths (relative to worktree)
PLAN: {working_directory}/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md
TEST: {working_directory}/{subject}/PHASE_{phase_id}_TEST.md
GLOBAL: {working_directory}/{subject}/GLOBAL.md

### Your Authority
You manage the ENTIRE validate-fix loop for this phase:
1. Run validation (checklist + quality checks)
2. If FAIL: invoke the coder agent (via Task tool using the namespace above) with fix instructions
3. Re-validate after coder fix (max 3 total attempts)
4. On final SUCCESS: update PLAN checklist, GLOBAL phase status, TEST results
5. On 3x FAIL: mark phase as SKIPPED in GLOBAL, document unresolved errors

### Important Rules
- Use {worktree_path} to resolve ALL file paths
- Pass {worktree_path} to the coder agent in fix prompts
- Update documents ONLY after final successful validation (not during retries)
- Auto-detect quality tools from project config files
- Return final status: PASS or FAIL with comprehensive report

Follow validation procedures from your agent definition.
"""
)
```

#### B3. Simplify Retry Loop (lines 748-762)

Replace the retry loop pseudo-code block (lines 747-762, the section titled "**Retry Loop Pattern**") with a simplified single-invocation pattern:

```
**After code-validator Completes**:

The code-validator manages the entire validate-fix cycle internally.
The orchestrator receives only the final result.

Based on the final validation result:
- **PASS (recommendation: COMMIT)**: Commit the phase (all code files + updated documents)
  ```bash
  git add {changed_code_files}
  git add {working_directory}/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md
  git add {working_directory}/{subject}/GLOBAL.md
  git add {working_directory}/{subject}/PHASE_{phase_id}_TEST.md
  git commit -m "feat/fix: implement phase {phase_id} - {brief_description}"
  ```
- **FAIL (recommendation: SKIP)**: Phase already marked as SKIPPED in GLOBAL.md by the validator. Record error and continue to next phase.

There is NO orchestrator-level retry loop. The validator handles all retries internally.
```

#### B4. Expand Commit Scope (lines 741-742)

Replace the current commit block:
```bash
git add {changed_files}
git commit -m "feat/fix: implement phase {phase_id} - {brief_description}"
```

With the expanded version:
```bash
git add {changed_code_files}
git add {working_directory}/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md
git add {working_directory}/{subject}/GLOBAL.md
git add {working_directory}/{subject}/PHASE_{phase_id}_TEST.md
git commit -m "feat/fix: implement phase {phase_id} - {brief_description}"
```

Note: This is the commit block inside the "**PASS**" case (line 740-743). Update it in-place. The B3 section above also references this expanded commit, but B4 specifically targets the original location at lines 741-742.

#### B5. Update "After code-validator Completes" Section (lines 736-762)

The entire block from line 736 ("**After code-validator Completes**:") through line 762 (end of retry loop) should be replaced with the content specified in B3 above. This replaces:
- The old PASS/FAIL/SKIP branching logic (lines 738-745)
- The old retry loop pseudo-code (lines 747-762)

## Completion Checklist

### Part A: code-validator.md
- [ ] A1: New "Context from Orchestrator" section added after "Language" section
- [ ] A2: Quality Tool Auto-Detection section replaces static commands (lines 56-81)
- [ ] A2: Quality Command Reference subsection preserved as reference
- [ ] A2: Detection algorithm covers Python, JS/TS, Rust, Svelte
- [ ] A2: Binary availability check before execution documented
- [ ] A2: Graceful N/A fallback documented
- [ ] A3: Retry Logic section (lines 86-103) replaced with Validate-Fix Loop
- [ ] A3: Flow diagram shows Task tool coder invocation
- [ ] A3: Document update happens AFTER final success only
- [ ] A3: Max 3 attempts enforced
- [ ] A3: SKIPPED handling for 3x failure documented
- [ ] A4: File path resolution using worktree_path added
- [ ] A4: PHASE_TEST.md update subsection added
- [ ] A4: TIMING rule added (documents updated after final completion only)

### Part B: start-new.md
- [ ] B1: Namespace fixed at line 600 (`dotclaude:coders:coder-{detected_language}`)
- [ ] B1: Namespace fixed at line 639
- [ ] B1: Namespace fixed at line 657
- [ ] B1: Namespace fixed at line 824
- [ ] B1: Namespace fixed at line 829
- [ ] B2: Validator prompt rewritten with full context (worktree, namespace, document paths, loop authority)
- [ ] B3: Retry loop replaced with single-invocation pattern
- [ ] B4: Commit scope expanded to include PLAN, GLOBAL, TEST documents
- [ ] B5: "After code-validator Completes" section updated for single-invocation pattern

## Notes

- Phase 1 establishes the interface contract. Phase 2 aligns `code.md` to match these patterns.
- The line numbers referenced are from the current (unmodified) versions of the files. If lines shift during editing, use surrounding context to locate the correct sections.
- All changes are to `.md` instruction files only. No source code changes.
- The coder namespace correction is a simple string replacement; verify all 5 locations are updated.
- The validator prompt rewrite (B2) is the most critical change -- it defines the contract between orchestrator and validator.
