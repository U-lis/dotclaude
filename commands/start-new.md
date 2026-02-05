---
description: Entry point for starting new work. Executes full orchestrator workflow with AskUserQuestion support and conditional post-completion integration.
---
# /dotclaude:start-new

Central workflow controller for the full development process from init to integration.

## Configuration Loading

Before executing any operations, load configuration:

1. **Default**: `working_directory = ".dc_workspace"`, `base_branch = "main"`, `language = "en_US"`
2. **Global Override**: Load from `~/.claude/dotclaude-config.json` if exists
3. **Local Override**: Load from `<git_root>/.claude/dotclaude-config.json` if exists

Configuration merge order: Defaults < Global < Local

The resolved config values are used throughout this workflow and **must be written into SPEC.md as metadata** so that downstream commands (`/dotclaude:design`, `/dotclaude:code`, etc.) can read them without re-loading config files.

### SPEC.md Configuration Metadata

When creating SPEC.md (Step 2.7), include a metadata block at the very top of the file, before the title:

```html
<!-- dotclaude-config
working_directory: {resolved_value}
base_branch: {resolved_value}
language: {resolved_value}
worktree_path: ../{project_name}-{type}-{keyword}
-->
```

Downstream commands read this metadata to resolve `{working_directory}`, `{worktree_path}`, and other config values. If they cannot find SPEC.md, they fall back to default values (`worktree_path` defaults to `.`).

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

## Role

- **Central workflow controller**: Manage all steps from init to integration
- **Direct user interaction**: Use AskUserQuestion for all user interactions (Steps 1, 3, 5)
- **Subagent coordinator**: Call TechnicalWriter, Designer, Coder, code-validator via Task tool
- **State manager**: Track workflow progress, enable resume from failure

## Capabilities

**IMPORTANT**: All these tools ARE available to you. Do NOT assume any tool is missing.

- **AskUserQuestion**: Direct user interaction for questions and confirmations. YOU HAVE THIS TOOL. USE IT.
- **Task tool**: Invoke subagents (TechnicalWriter, Designer, Coder, code-validator)
- **Parallel Task calls**: Execute multiple subagents simultaneously for parallel phases
- **Bash tool**: Git operations, directory creation
- **Read/Write tools**: File operations

**NEVER** output text tables and ask users to type numbers. ALWAYS use AskUserQuestion tool.

---

## 13-Step Workflow

### INIT PHASE

**Step 1: Work Type Selection**

Call AskUserQuestion tool with these exact parameters:
- question: "What type of work do you want to start?"
- header: "Work Type"
- options:
  - { label: "Add/Modify Feature", description: "New feature development or improve existing feature" }
  - { label: "Bug Fix", description: "Fix discovered bugs or errors" }
  - { label: "Refactoring", description: "Improve code structure without changing functionality" }
  - { label: "GitHub Issue", description: "Auto-initialize from GitHub issue URL" }
- multiSelect: false

**Step 2: Load Init Instructions**

Based on Step 1 response, follow the corresponding init command (Claude auto-loads command content):

| User Selection | Init Command |
|----------------|--------------|
| Add/Modify Feature | Follow the `init-feature` command |
| Bug Fix | Follow the `init-bugfix` command |
| Refactoring | Follow the `init-refactor` command |
| GitHub Issue | Follow the `init-github-issue` command |

Execute ALL steps defined in the loaded init file:
1. Step-by-step questions (using AskUserQuestion)
2. Branch creation & analysis phase (each init file defines this)
3. **Target Version Question** (see below)
4. Draft SPEC.md via TechnicalWriter (include target_version in SPEC)
5. Commit SPEC.md

**Step 2.6: Target Version Question**

After analysis, before drafting SPEC.md:

1. **Read CHANGELOG.md** to gather version context:
   ```
   Read CHANGELOG.md -> Extract recent 3 versions (including unreleased if exists)
   For each version: version number, date, key changes (1-2 lines summary)
   ```

2. **Present version history** to user before asking:
   ```markdown
   ## Recent Version History

   | Version | Date | Key Changes |
   |------|------|--------------|
   | 0.0.9 | 2026-01-21 | dc: prefix 추가, target version 질문 추가 |
   | 0.0.8 | 2026-01-19 | Orchestrator 추가, 16단계 워크플로우 |
   | 0.0.7 | 2026-01-19 | init-bugfix 분석 단계 추가 |
   ```

3. **Call AskUserQuestion** with context-aware options:
   - question: "What is the target version for this work?"
   - header: "Target Version"
   - options (dynamically generated based on current version):
     - { label: "{current}.{+1} (Patch)", description: "Bug fixes, small changes" }
     - { label: "{current+minor}.0 (Minor)", description: "New features, backward compatible" }
     - { label: "{current+major}.0.0 (Major)", description: "Includes breaking changes" }
   - multiSelect: false

   Example if current is 0.0.9:
   - { label: "0.0.10 (Patch)", description: "Bug fixes, small changes" }
   - { label: "0.1.0 (Minor)", description: "New features, backward compatible" }
   - { label: "1.0.0 (Major)", description: "Includes breaking changes" }

User can also enter specific version via "Other" option.

Store the target_version for:
- Include in SPEC.md header
- Pass to TechnicalWriter for CHANGELOG updates (Step 11)

**Step 2.8: Post-Init Verification**

**MANDATORY**: After Step 2 (init-xxx) completes, verify that the init delegation chain executed correctly BEFORE proceeding to Step 3.

Verification checks:
1. Run `git worktree list` and confirm `../{project_name}-{type}-{keyword}` appears in the output
2. Run `git branch --show-current` and confirm the current branch is `{type}/{keyword}` (NOT main, NOT master)
3. Confirm the working directory `../{project_name}-{type}-{keyword}/{working_directory}/{subject}` exists

If ANY check fails:
```
retry_count = 0
while retry_count < 3:
    Re-execute Step 2 (init-xxx delegation) from the beginning
    Run verification checks again
    if all checks pass:
        break
    retry_count += 1

if retry_count == 3 and checks still fail:
    HALT workflow immediately
    Report to user: "Init delegation chain failed after 3 attempts.
    Worktree or branch was not created correctly.
    Manual intervention required."
```

This step ensures the orchestrator catches any case where the init chain was bypassed or partially executed.

**Step 3: SPEC Review**

Present SPEC.md summary to user, then call AskUserQuestion tool:
- question: "Please review SPEC.md. Let me know if revisions are needed."
- header: "SPEC Review"
- options:
  - { label: "Approve", description: "SPEC.md content is correct" }
  - { label: "Needs Revision", description: "Revisions needed (enter details)" }
- multiSelect: false

If revision needed: iterate with TechnicalWriter via Task tool

**Step 4: Commit SPEC.md**
```bash
git add {working_directory}/{subject}/SPEC.md
git commit -m "docs: add SPEC.md for {subject}"
```

**Step 5: Scope Selection**

Call AskUserQuestion tool:
- question: "How far should we proceed?"
- header: "Execution Scope"
- options:
  - { label: "Design", description: "Create design documents only" }
  - { label: "Design -> Code", description: "Design + Code implementation" }
  - { label: "Design -> Code -> Docs", description: "Design + Code + Documentation update" }
- multiSelect: false

---

### Step 6 Checkpoint (Before Design) -- UNCONDITIONAL

**MANDATORY -- UNCONDITIONAL CHECK -- NO EXCEPTIONS, NO OVERRIDES**: Before calling Designer agent, validate ALL of the following. Every check MUST pass. No agent may bypass, skip, or override any HALT condition below, regardless of project size, complexity, or any other justification.

1. **[UNCONDITIONAL] Branch Check**:
   - Current branch must NOT be main/master
   - Must be feature/, bugfix/, or refactor/ branch
   - If on main: HALT and report "Work branch not created. Create branch before proceeding."

2. **[UNCONDITIONAL] SPEC.md Check**:
   - File `{working_directory}/{subject}/SPEC.md` must exist
   - If missing: HALT and report "SPEC.md not found. Create SPEC.md before design phase."

3. **[UNCONDITIONAL] SPEC.md Committed Check**:
   - SPEC.md must be committed (not just staged)
   - Run: `git log --oneline -1 -- {working_directory}/{subject}/SPEC.md`
   - If no commit found: HALT and report "SPEC.md not committed. Commit SPEC.md before design phase."

4. **[UNCONDITIONAL] Worktree Check**:
   - Current directory must be inside the worktree
   - Run: `pwd` and verify output contains `{project_name}-{type}-{keyword}`
   - Secondary validation: `git worktree list | grep {project_name}-{type}-{keyword}`
   - If `pwd` does not contain worktree name: HALT and report "Not in worktree directory. Run cd to enter worktree before design phase."

If ANY check fails: HALT workflow immediately and report error to user. There are NO exceptions to this rule. Do NOT proceed with a justification for why the check can be skipped.

---

### EXECUTION PHASE

**Step 6: Design - Call Designer**
```
Task tool -> Designer
  Input:
    spec_path: "{working_directory}/{subject}/SPEC.md"
  Output: architecture decisions, phase breakdown
```

**Step 7: Design - Create Documents**
```
Task tool -> TechnicalWriter
  Input:
    document_type: "DESIGN"
    designer_output: {Designer results}
    target_dir: "{working_directory}/{subject}/"
  Output: GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md
```

**Step 8: Commit Design Documents**
```bash
git add {working_directory}/{subject}/*.md
git commit -m "docs: add design documents for {subject}"
```

**Step 9: Parse Phase List**
```
Read GLOBAL.md -> extract Phase Overview table
Build execution order:
  - Sequential phases: execute in order
  - Parallel phases (e.g., 3A, 3B, 3C): group together
  - Merge phase (e.g., 3.5): after parallel phases
```

**Step 10: Execute Phases**

For sequential phase:
```
Task tool -> Coder
  Input:
    phase_id: "{k}"
    plan_path: "{working_directory}/{subject}/PHASE_{k}_PLAN_*.md"
  Output: implementation, files changed

Task tool -> code-validator
  Input:
    phase_id: "{k}"
    checklist: [items from PLAN]
  Output: validation result

If passed: commit
If failed: retry (max 3), then skip
```

For parallel phases (e.g., 3A, 3B, 3C):
```bash
# Setup worktrees (branching from feature branch, not main)
# Worktree naming: {project_name}-{type}-{keyword}-{phase}
git worktree add ../{project_name}-{type}-{keyword}-3A -b feature/{keyword}-3A feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3B -b feature/{keyword}-3B feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3C -b feature/{keyword}-3C feature/{keyword}

# Single message with multiple Task tool calls (parallel execution)
Task tool -> Coder (phase=3A, worktree=../{project_name}-{type}-{keyword}-3A)
Task tool -> Coder (phase=3B, worktree=../{project_name}-{type}-{keyword}-3B)
Task tool -> Coder (phase=3C, worktree=../{project_name}-{type}-{keyword}-3C)

# Wait for all results

# Merge phase (3.5)
git merge feature/{keyword}-3A --no-edit
git merge feature/{keyword}-3B --no-edit
git merge feature/{keyword}-3C --no-edit

# Cleanup
git worktree remove ../{project_name}-{type}-{keyword}-3A
git worktree remove ../{project_name}-{type}-{keyword}-3B
git worktree remove ../{project_name}-{type}-{keyword}-3C
```

**Step 11: Update Documentation**
```
Task tool -> TechnicalWriter (DOCS_UPDATE role)
  Input:
    role: "DOCS_UPDATE"
    commits: git log since last tag
    target_version: from init phase
  Output: CHANGELOG.md, README.md updates

Then commit:
  git add CHANGELOG.md README.md
  git commit -m "docs: update CHANGELOG and README for {version}"
```

**Step 12: Post-Completion Integration (Conditional)**

This step executes ONLY when the selected scope includes Code or Docs (not design-only).

Call AskUserQuestion tool:
- question: "How would you like to integrate this work?"
- header: "Integration Method"
- options:
  - { label: "Direct Merge", description: "Merge current branch to base branch" }
  - { label: "Create PR", description: "Create a GitHub Pull Request (requires /dotclaude:pr)" }
- multiSelect: false

**Routing based on user selection:**

| Selection | Action |
|-----------|--------|
| Direct Merge | Invoke `/dotclaude:merge` command behavior (merge current branch to base_branch, conflict resolution, branch cleanup). After merge, clean up worktree: `git worktree remove ../{project_name}-{type}-{keyword}` |
| Create PR | Invoke `/dotclaude:pr` command behavior (worktree remains for further work until PR is merged) |

**Skip condition**: If scope is "Design" only, skip Step 12 entirely and proceed directly to Step 13 (Return Summary).

**Step 13: Return Summary**
Return structured output (see "Output Contract" section)

---

## Init Phase Rules

### Plan Mode Policy

**CRITICAL**: Init phase MUST NOT use plan mode (EnterPlanMode).

Reasons:
- Plan mode is for implementation planning, not requirements gathering
- ExitPlanMode can cause workflow interruption
- User approval happens at SPEC.md review stage, not plan approval

Instead:
- Use AskUserQuestion for sequential requirements gathering
- Proceed directly through workflow steps
- User reviews and approves at Step 3 (SPEC.md review)

### Mandatory Workflow Rules

**CRITICAL**: The following rules MUST be followed regardless of permission settings.

Steps 2-4 are MANDATORY and CANNOT be skipped:
- Step 2: Execute init instructions (questions + analysis + SPEC.md creation)
- Step 3: Present SPEC.md for user review
- Step 4: Commit SPEC.md after approval

### Prohibited Actions

NEVER do any of the following:
- Skip directly to implementation after gathering requirements
- Skip Analysis Phase
- Bypass SPEC.md file creation
- Start coding without user explicitly selecting a scope that includes "Code"

### Iteration Limits

| Limit Type | Maximum |
|------------|---------|
| Input clarification | 5 questions per category |
| SPEC revision loop | 3 iterations |
| Codebase search | 10 file reads |

### Response Quality Rules

**CRITICAL**: These rules ensure response quality.

- **Evidence-Based Responses**: Never agree or praise without verification. Always provide evidence-based responses.
- **Completion Reporting**: Report summary upon completion and wait for user review/additional commands.

---

## Delegation Enforcement

### Critical Rule: Never Execute Agent Work Directly

**MANDATORY PROTOCOL**: When any agent-specific work is required (writing specs, designing architecture, implementing code, validating code), you MUST delegate to the appropriate subagent via the Task tool.

### MUST DO

The orchestrator MUST:
- Use Task tool with the appropriate `subagent_type: "dotclaude:{agent-name}"` for all agent invocations
- The agent role is auto-loaded by the plugin system. Prompts should contain only task instructions.
- Wait for subagent completion before proceeding to next step
- Collect subagent results and use them for workflow decisions

### FORBIDDEN ACTIONS

The orchestrator is FORBIDDEN from:
- Reading agent definition files (agents/*.md) to execute work inline
- Implementing agent-specific logic directly in orchestrator context
- Bypassing Task tool invocation "for convenience" or "because it's simple"
- Writing SPEC.md, design documents, or code directly without subagent delegation

### Warning: Protocol Violation Consequences

Direct execution without proper delegation causes:
- **Inconsistent behavior**: Agent-specific optimizations and quality checks are skipped
- **Loss of specialization**: Domain expertise encoded in agent definitions is not applied
- **Maintenance difficulty**: Inline execution scattered across orchestrator makes updates harder
- **Audit trail loss**: Task tool invocations provide clear delegation logs; inline work does not

### Verification

After executing any workflow step involving TechnicalWriter, Designer, Coder, or code-validator, verify logs show:

**Correct Pattern** (Task tool invocation visible):
```
Invoke Task tool (subagent_type: "dotclaude:technical-writer")
  Subagent completed successfully
Output created: claude_works/{subject}/SPEC.md
```

**Incorrect Pattern** (direct file operations):
```
Read(agents/technical-writer.md)
Write(claude_works/{subject}/SPEC.md)
```

If you see the incorrect pattern, STOP and revise your approach to use Task tool delegation.

---

## Subagent Call Patterns

### TechnicalWriter Invocation

**When to Use**: SPEC.md creation (Step 2), design document writing (Step 7), documentation updates (Step 11)

**Mandatory Task Tool Invocation Pattern**:

When invoking TechnicalWriter, you MUST call the Task tool with exactly this structure:

```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
{Specific task instructions based on context - see examples below}

Follow the template structure from your agent definition.
"""
)
```

**Example 1: SPEC.md Creation (Step 2)**

```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
Create SPEC.md document at: claude_works/{subject}/SPEC.md

Include these sections:
- Overview: {Brief description from user requirements}
- Functional Requirements: {List of FR items from interview}
- Non-Functional Requirements: {List of NFR items}
- Constraints: {Technical and business constraints}
- Out of Scope: {Explicitly excluded items}

Target Version: {version from Step 2.6}

Use the template structure from templates/SPEC.md as reference.
"""
)
```

**Example 2: Design Document Writing (Step 7)**

```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
Create design documents based on Designer output:

Designer Output Summary:
{paste Designer's architecture decisions and phase breakdown}

Target Directory: claude_works/{subject}/

Create documents according to complexity:
- Simple tasks (1-2 phases): Single combined DESIGN.md
- Complex tasks (3+ phases): GLOBAL.md + PHASE_*_PLAN.md + PHASE_*_TEST.md

Follow the document templates from your agent definition.
"""
)
```

**Example 3: Documentation Update (Step 11)**

```
Task(
  subagent_type="dotclaude:technical-writer",
  prompt="""
## Task: Update Documentation (DOCS_UPDATE Role)

### Context
Target Version: {version from init phase}
Commits to document: {output from git log since last tag}

### Your Tasks
1. Update CHANGELOG.md:
   - Add new version entry at top
   - Classify changes by Keep a Changelog categories
   - Use semver format, date YYYY-MM-DD

2. Update README.md:
   - Review if implementation affects feature list, usage examples, or configuration
   - Only update sections with visible changes

Follow the DOCS_UPDATE role instructions from your agent definition.
"""
)
```

### Designer Invocation

**When to Use**: Design phase (Step 6), after SPEC.md is approved and committed

**Prerequisites Verification** (Step 6 Checkpoint):
- Current branch is NOT main/master
- SPEC.md exists at claude_works/{subject}/SPEC.md
- SPEC.md is committed (not just staged)

If any prerequisite fails, HALT and report error. Do NOT proceed to Designer invocation.

**Mandatory Task Tool Invocation Pattern**:

```
Task(
  subagent_type="dotclaude:designer",
  prompt="""
## Task: Analyze SPEC and Create Design

### Input
SPEC path: claude_works/{subject}/SPEC.md

### Your Tasks
1. Read and analyze the SPEC.md
2. Determine task complexity (SIMPLE vs COMPLEX)
3. Create architecture decisions with rationale
4. Break work into phases with dependencies
5. Output structured design results

### Output Format
Provide:
- Complexity assessment (SIMPLE/COMPLEX)
- Architecture decisions (list with rationale)
- Phase breakdown (sequential, parallel, merge phases)
- File structure (files to create/modify)
- Technology choices (if applicable)

Follow the analysis framework from your agent definition.
"""
)
```

**After Designer Completes**:

Collect Designer output and pass it to TechnicalWriter for document creation (Step 7). See TechnicalWriter Example 2 above.

### Coder Invocation

**When to Use**: Code implementation phase (Step 10), for each phase in execution order

**Context**: After design documents are created and committed, parse GLOBAL.md Phase Overview to get phase execution order.

**Mandatory Task Tool Invocation Pattern**:

**For Sequential Phases**:

```
Task(
  subagent_type="dotclaude:coder-{detected_language}",
  prompt="""
## Task: Implement Phase {phase_id}

### Input
Phase ID: {phase_id}
PLAN path: claude_works/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md

### Your Tasks
1. Read the PLAN document completely
2. Identify all files to create or modify
3. Implement changes following TDD approach
4. Complete all checklist items in the PLAN
5. Verify implementation works (build passes, no errors)

### Output
- Report files changed
- Confirm all checklist items completed
- Report any issues or blockers

Follow TDD principles from your agent definition.
"""
)
```

**For Parallel Phases** (e.g., 3A, 3B, 3C):

Setup worktrees first (branching from feature branch, not main):
```bash
git worktree add ../{project_name}-{type}-{keyword}-3A -b feature/{keyword}-3A feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3B -b feature/{keyword}-3B feature/{keyword}
git worktree add ../{project_name}-{type}-{keyword}-3C -b feature/{keyword}-3C feature/{keyword}
```

Then invoke multiple Coder agents in a SINGLE message (parallel execution):

```
# Call 1
Task(
  subagent_type="dotclaude:coder-{detected_language}",
  prompt="""
## Task: Implement Phase 3A (Parallel Branch)

### Working Directory
CRITICAL: Execute all operations in worktree: ../{project_name}-{type}-{keyword}-3A

### Input
Phase ID: 3A
PLAN path: claude_works/{subject}/PHASE_3A_PLAN_{keyword}.md

### Your Tasks
[Same as sequential, but all operations in worktree path]
"""
)

# Call 2
Task(
  subagent_type="dotclaude:coder-{detected_language}",
  prompt="""
## Task: Implement Phase 3B (Parallel Branch)

### Working Directory
CRITICAL: Execute all operations in worktree: ../{project_name}-{type}-{keyword}-3B

[... similar structure ...]
"""
)

# Call 3 (and so on for each parallel phase)
```

**After All Parallel Coders Complete**:

Execute merge phase as defined in PHASE_{k}.5_PLAN_MERGE.md, then clean up worktrees:
```bash
git merge feature/{keyword}-3A --no-edit
git merge feature/{keyword}-3B --no-edit
git merge feature/{keyword}-3C --no-edit
git worktree remove ../{project_name}-{type}-{keyword}-3A
git worktree remove ../{project_name}-{type}-{keyword}-3B
git worktree remove ../{project_name}-{type}-{keyword}-3C
```

### code-validator Invocation

**When to Use**: After each Coder completes a phase (Step 10), before committing changes

**Purpose**: Validate that phase implementation meets quality criteria and all checklist items are complete.

**Mandatory Task Tool Invocation Pattern**:

```
Task(
  subagent_type="dotclaude:code-validator",
  prompt="""
## Task: Validate Phase {phase_id} Implementation

### Input
Phase ID: {phase_id}
PLAN path: claude_works/{subject}/PHASE_{phase_id}_PLAN_{keyword}.md
(Read this file to extract the completion checklist)

### Your Tasks
1. Extract completion checklist from PLAN document
2. Verify each checklist item:
   - Files created/modified as specified
   - Functionality implemented correctly
   - Code follows project conventions
3. Run quality checks:
   - Build passes (if applicable)
   - No linting errors
   - No type errors (TypeScript projects)
4. Report validation result: PASS or FAIL with details

### Output Format
```yaml
status: "PASS" | "FAIL"
phase_id: "{phase_id}"
checklist_results:
  - item: "Checklist item description"
    status: "COMPLETE" | "INCOMPLETE"
    notes: "Details if incomplete"
quality_checks:
  build: "PASS" | "FAIL" | "N/A"
  lint: "PASS" | "FAIL" | "N/A"
  types: "PASS" | "FAIL" | "N/A"
issues:
  - "Description of any issues found"
recommendation: "COMMIT" | "RETRY" | "SKIP"
```

Follow validation procedures from your agent definition.
"""
)
```

**After code-validator Completes**:

Based on validation result:
- **PASS**: Commit the phase
  ```bash
  git add {changed_files}
  git commit -m "feat/fix: implement phase {phase_id} - {brief_description}"
  ```
- **FAIL + retry_count < 3**: Call Coder again with feedback from validator
- **FAIL + retry_count >= 3**: Mark phase as SKIPPED, record error, continue to next phase

**Retry Loop Pattern**:
```
attempt = 0
while attempt < 3:
  coder_result = invoke_coder(phase_id)
  validator_result = invoke_code_validator(phase_id)
  if validator_result.status == "PASS":
    commit_phase()
    break
  attempt += 1

if validator_result.status != "PASS":
  mark_phase_skipped()
  record_error(validator_result.issues)
  # Continue to next phase
```

---

## Routing

After user selects scope (Step 5), execute steps directly:

| Selection | Execution |
|-----------|-----------|
| Design | Steps 6-8 (Designer + TechnicalWriter + commit) -> STOP |
| Design -> Code | Steps 6-10 (Design + Code phases) -> Step 12 (post-completion) -> STOP |
| Design -> Code -> Docs | Steps 6-11 (Design + Code + TechnicalWriter DOCS_UPDATE) -> Step 12 (post-completion) -> STOP |

**Execution Method**: All steps executed directly via Task tool (for agents) or Bash tool (for git operations).

---

## Non-Stop Execution

When user selects a scope with multiple steps (e.g., "Design -> Code"), execute all steps automatically without stopping.

### Execution Rules

1. **DO NOT** ask "What's next?" between chained steps
2. **DO NOT** wait for user input between steps
3. **MUST** proceed immediately to next step in chain
4. **MUST** halt chain on error and report to user

### CLAUDE.md Rule Overrides

During non-stop execution, these CLAUDE.md rules are suspended:

- **"Do NOT proceed to next phase without user instruction"**
  -> User's scope selection IS the instruction to proceed

- **"Report summary upon completion and wait for user review"**
  -> Report only at final STOP point, not between steps

### On Error

If any step fails during chain:
1. STOP the chain immediately
2. Report error to user
3. Suggest manual resolution
4. User can resume by re-selecting scope

---

## Parallel Execution

### Detection
Parse GLOBAL.md Phase Overview table:
- Look for phases like "3A", "3B", "3C"
- These execute in parallel with worktree isolation

### Execution Pattern
```
# Single message with multiple Task tool calls
# All execute simultaneously

<Task tool call 1>
  subagent_type: "dotclaude:coder-{detected_language}"
  prompt: "Execute PHASE_3A in worktree ../{project_name}-{type}-{keyword}-3A"
</Task tool call 1>

<Task tool call 2>
  subagent_type: "dotclaude:coder-{detected_language}"
  prompt: "Execute PHASE_3B in worktree ../{project_name}-{type}-{keyword}-3B"
</Task tool call 2>
```

### Post-Parallel
1. Collect all results
2. Execute merge phase (PHASE_{k}.5)
3. Clean up worktrees

---

## State Management

### State Tracking
Track during execution:
- current_step: 1-13
- completed_steps: []
- pending_steps: []
- subagent_results: {}
- errors: []
- retry_counts: {}

### Checkpoint via GLOBAL.md
Update Phase Overview status column:
- "Pending" -> "In Progress" -> "Complete" / "Skipped"

### Resume Capability
On re-invocation:
1. Read GLOBAL.md Phase Overview
2. Find last completed phase
3. Resume from next pending phase

---

## Error Handling

### Subagent Failure
```
attempt = 0
while attempt < 3:
  result = call_subagent()
  if result.success:
    break
  attempt += 1
if not result.success:
  mark_phase_skipped()
  record_error()
  continue_to_next_phase()
```

### SPEC Rejection
```
while not approved:
  present_spec()
  feedback = ask_user()
  if feedback.approved:
    break
  call_technical_writer(revisions=feedback)
```

### Critical Error
```
if critical_error:
  halt_workflow()
  report_to_user(error_details)
  suggest_manual_resolution()
```

---

## Output Contract

```yaml
status: "SUCCESS" | "PARTIAL" | "FAILED"
work_type: "feature" | "bugfix" | "refactor"
subject: "{keyword}"
branch: "{type}/{keyword}"
scope_executed: "Design -> Code -> Docs"
integration_method: "merge" | "pr" | "none"
init:
  spec_path: "{working_directory}/{subject}/SPEC.md"
  spec_approved: true
  target_version: "X.Y.Z"
design:
  global_path: "{working_directory}/{subject}/GLOBAL.md"
  phases: ["1", "2", "3A", "3B", "3C", "3.5", "4"]
code:
  phases:
    - phase: "1"
      status: "SUCCESS"
      commit: "abc123"
    - phase: "3B"
      status: "SKIPPED"
      error: "Error message"
docs:
  updated:
    - "CHANGELOG.md"
    - "README.md"
integration:
  method: "merge" | "pr" | "none"
  merged_to: "{base_branch}"       # only when method is "merge"
  branch_deleted: true | false      # only when method is "merge"
  pr_url: "https://..."            # only when method is "pr"
issues:
  - "Description of issue"
next_steps:
  - "Recommended action"
```

---

## Final Summary Report

After all steps in the chain complete, display summary:

```markdown
# Workflow Complete

## Scope: {selected scope}

## Results

| Step | Description | Status |
|------|-------------|--------|
| 1 | Design | SUCCESS |
| 2 | Code | SUCCESS |
| 3 | Documentation | SUCCESS |
| 4 | Integration | MERGE / PR / SKIPPED |

## Files Changed
- {working_directory}/{subject}/*.md
- [implementation files...]
- CHANGELOG.md

## Next Steps (conditional based on integration method)

**If integration was "merge":**
1. Review changes: `git log --oneline -10`
2. Push to remote: `git push origin {base_branch}`
3. (Optional) Create tag: `/dotclaude:tagging`

**If integration was "pr":**
1. Review PR: {pr_url}
2. Request reviews from teammates
3. Merge PR after approval

**If integration was "none" (design-only):**
1. Review design documents in `{working_directory}/{subject}/`
2. When ready to implement: re-run `/dotclaude:start-new` with broader scope
3. Or manually proceed: `/dotclaude:code`, `/dotclaude:merge`
```

This summary appears ONLY at the final STOP point, not between steps.

---

## Progress Reporting

### Step Progress

Display progress at each major step:

```
===============================================================
[Step {N}/13] {Step description}
Current: {Current action}
===============================================================
```

### Chain Progress

During multi-step execution (non-stop mode), display:

```
===============================================================
[Step {M}/{Total}] {Step description}
Current: Executing {step name}
===============================================================
```

Example for "Design -> Code -> Docs":
- [Step 1/3] Design phase - Creating architecture
- [Step 2/3] Code implementation - Executing phases
- [Step 3/3] Documentation update - Updating CHANGELOG
- [Post] Integration - Asking user for merge/PR preference
