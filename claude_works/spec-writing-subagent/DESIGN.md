# Spec-Writing-Subagent Bug Fix - Design Document

**Target Version**: 0.2.0
**Work Type**: bugfix
**Complexity**: SIMPLE (documentation-only change to single file)
**Target File**: `skills/start-new/SKILL.md`

---

## Feature Overview

### Purpose
Fix the subagent delegation bypass issue in the `start-new` skill where TechnicalWriter, Designer, Coder, and code-validator agents are not being properly invoked via the Task tool.

### Problem
The current "Subagent Call Patterns" section (lines 323-377) in `skills/start-new/SKILL.md` uses descriptive pseudo-code format that appears as documentation examples rather than mandatory instructions. This causes the orchestrator to bypass proper Task tool invocation and instead read agent definition files directly to execute work inline.

**Evidence from Issue #5**:
```
● Read(.claude/templates/SPEC.md)
● Read(.claude/agents/technical-writer.md)  ← WRONG: Direct read
● Write(claude_works/github-issue-fetch/SPEC.md)  ← WRONG: Direct write
```

**Expected Behavior**:
```
● Invoke Task tool (subagent_type: general-purpose, TechnicalWriter)
  ⎿ Subagent completed
● SPEC.md created at claude_works/{subject}/SPEC.md
```

### Solution
Add explicit "Delegation Enforcement" section with MUST/FORBIDDEN imperative language, then convert all pseudo-code examples to mandatory Task tool invocation instructions.

---

## Architecture Decisions

### Decision 1: Add Delegation Enforcement Section
**Rationale**: Provide explicit protocol rules before showing implementation patterns. This establishes the "why" before the "how" and makes violations immediately obvious.

**Location**: Insert new section before "Subagent Call Patterns" (before line 323)

**Language Style**: Use MUST/SHALL/FORBIDDEN imperatives per RFC 2119 conventions.

### Decision 2: Convert Pseudo-Code to Imperative Instructions
**Rationale**: Current format `Task tool: subagent_type...` reads as example documentation. Converting to explicit invocation syntax with `<invoke Task>` XML-like format makes it clear these are mandatory actions, not reference examples.

### Decision 3: Use XML-Like Task Invocation Syntax
**Rationale**: Format like `<invoke Task>` is more recognizable as actual tool invocation instruction compared to YAML-style pseudo-code.

### Decision 4: Single-File Change Only
**Rationale**: This is a documentation clarification bug. No agent definition files or tool implementations need modification. All fixes are contained within `skills/start-new/SKILL.md`.

### Decision 5: Backward Compatibility
**Rationale**: Changes are additive (new Delegation Enforcement section) and clarifying (better formatted patterns). Existing correct implementations remain valid.

---

## Complete Implementation Instructions

### Phase 1: Add Delegation Enforcement Section

**Objective**: Insert new section establishing delegation protocol rules.

**Location**: `skills/start-new/SKILL.md`, insert AFTER line 319 (after "Response Quality Rules" section, BEFORE "Subagent Call Patterns" heading on line 321)

**Instructions for Coder**:

1. Locate the heading `## Subagent Call Patterns` at approximately line 321
2. Insert a blank line before this heading
3. Insert the following complete section:

```markdown
---

## Delegation Enforcement

### Critical Rule: Never Execute Agent Work Directly

**MANDATORY PROTOCOL**: When any agent-specific work is required (writing specs, designing architecture, implementing code, validating code), you MUST delegate to the appropriate subagent via the Task tool.

### MUST DO

The orchestrator MUST:
- ✓ Use Task tool with `subagent_type: "general-purpose"` for all agent invocations
- ✓ Pass agent role explicitly in prompt: "You are {AgentName}. Read agents/{agent-file}.md for your role."
- ✓ Wait for subagent completion before proceeding to next step
- ✓ Collect subagent results and use them for workflow decisions

### FORBIDDEN ACTIONS

The orchestrator is FORBIDDEN from:
- ✗ Reading agent definition files (agents/*.md) to execute work inline
- ✗ Implementing agent-specific logic directly in orchestrator context
- ✗ Bypassing Task tool invocation "for convenience" or "because it's simple"
- ✗ Writing SPEC.md, design documents, or code directly without subagent delegation

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
● Invoke Task tool (subagent_type: general-purpose, prompt: "You are TechnicalWriter...")
  ⎿ Subagent completed successfully
● Output created: claude_works/{subject}/SPEC.md
```

**Incorrect Pattern** (direct file operations):
```
● Read(agents/technical-writer.md)
● Write(claude_works/{subject}/SPEC.md)
```

If you see the incorrect pattern, STOP and revise your approach to use Task tool delegation.
```

4. Ensure proper markdown heading levels (use `##` for "Delegation Enforcement")
5. Ensure proper spacing: blank line before `---`, blank line after closing of section

**Completion Criteria**:
- [ ] New "Delegation Enforcement" section exists before "Subagent Call Patterns"
- [ ] Section uses imperative language (MUST/FORBIDDEN)
- [ ] Includes verification guidance with correct/incorrect log patterns
- [ ] Proper markdown formatting maintained

---

### Phase 2: Convert TechnicalWriter Pattern to Imperative Instructions

**Objective**: Replace pseudo-code example with explicit Task tool invocation instructions.

**Location**: `skills/start-new/SKILL.md`, lines 323-335 (TechnicalWriter section)

**Current Content** (to be replaced):
```markdown
### TechnicalWriter
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are TechnicalWriter. Read agents/technical-writer.md for your role.

    Create {document_type} document:
    - Input: {content_data}
    - Output path: {target_path}

    Follow the template structure from your agent definition.
```
```

**Instructions for Coder**:

1. Locate the `### TechnicalWriter` heading (approximately line 323)
2. Replace the entire subsection (from `### TechnicalWriter` through the closing triple backticks) with:

```markdown
### TechnicalWriter Invocation

**When to Use**: SPEC.md creation (Step 2), design document writing (Step 7), documentation updates (Step 11)

**Mandatory Task Tool Invocation Pattern**:

When invoking TechnicalWriter, you MUST call the Task tool with exactly this structure:

```
Task(
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.

{Specific task instructions based on context - see examples below}

Follow the template structure from your agent definition.
"""
)
```

**Example 1: SPEC.md Creation (Step 2)**

```
Task(
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.

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
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.

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
  subagent_type="general-purpose",
  prompt="""
You are TechnicalWriter. Read agents/technical-writer.md for your role.

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
```

3. Ensure proper markdown formatting and indentation
4. Verify all three examples are complete and properly closed

**Completion Criteria**:
- [ ] Section renamed to "TechnicalWriter Invocation"
- [ ] Includes "When to Use" guidance
- [ ] Shows mandatory Task() call structure
- [ ] Provides three concrete examples (SPEC, Design, Docs)
- [ ] Uses actual Task tool syntax, not pseudo-code
- [ ] Examples reference real workflow steps

---

### Phase 3: Convert Designer Pattern to Imperative Instructions

**Objective**: Replace pseudo-code example with explicit Task tool invocation instructions for Designer.

**Location**: `skills/start-new/SKILL.md`, lines 337-349 (Designer section)

**Current Content** (to be replaced):
```markdown
### Designer
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are Designer. Read agents/designer.md for your role.

    Analyze SPEC and create design:
    - SPEC path: {spec_path}
    - Output: architecture decisions, phase breakdown

    Follow the instructions in your agent definition.
```
```

**Instructions for Coder**:

1. Locate the `### Designer` heading (approximately line 337)
2. Replace the entire subsection with:

```markdown
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
  subagent_type="general-purpose",
  prompt="""
You are Designer. Read agents/designer.md for your role.

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
```

3. Ensure proper markdown formatting
4. Verify Task() call syntax is correct

**Completion Criteria**:
- [ ] Section renamed to "Designer Invocation"
- [ ] Includes "When to Use" and prerequisites
- [ ] Shows mandatory Task() call structure
- [ ] References Step 6 checkpoint validation
- [ ] Describes expected output format
- [ ] Links to next step (TechnicalWriter invocation)

---

### Phase 4: Convert Coder Pattern to Imperative Instructions

**Objective**: Replace pseudo-code example with explicit Task tool invocation instructions for Coder.

**Location**: `skills/start-new/SKILL.md`, lines 351-364 (Coder section)

**Current Content** (to be replaced):
```markdown
### Coder
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are Coder. Read agents/coders/{language}.md for your role.

    Implement phase:
    - Phase: {phase_id}
    - PLAN path: {plan_path}
    - Worktree: {worktree_path} (if parallel)

    Follow TDD and complete all checklist items.
```
```

**Instructions for Coder**:

1. Locate the `### Coder` heading (approximately line 351)
2. Replace the entire subsection with:

```markdown
### Coder Invocation

**When to Use**: Code implementation phase (Step 10), for each phase in execution order

**Context**: After design documents are created and committed, parse GLOBAL.md Phase Overview to get phase execution order.

**Mandatory Task Tool Invocation Pattern**:

**For Sequential Phases**:

```
Task(
  subagent_type="general-purpose",
  prompt="""
You are Coder. Read agents/coders/{detected_language}.md for your role.

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

Setup worktrees first:
```bash
git worktree add ../{subject}-3A -b feature/{subject}-3A
git worktree add ../{subject}-3B -b feature/{subject}-3B
git worktree add ../{subject}-3C -b feature/{subject}-3C
```

Then invoke multiple Coder agents in a SINGLE message (parallel execution):

```
# Call 1
Task(
  subagent_type="general-purpose",
  prompt="""
You are Coder. Read agents/coders/{detected_language}.md for your role.

## Task: Implement Phase 3A (Parallel Branch)

### Working Directory
CRITICAL: Execute all operations in worktree: ../{subject}-3A

### Input
Phase ID: 3A
PLAN path: claude_works/{subject}/PHASE_3A_PLAN_{keyword}.md

### Your Tasks
[Same as sequential, but all operations in worktree path]
"""
)

# Call 2
Task(
  subagent_type="general-purpose",
  prompt="""
You are Coder. Read agents/coders/{detected_language}.md for your role.

## Task: Implement Phase 3B (Parallel Branch)

### Working Directory
CRITICAL: Execute all operations in worktree: ../{subject}-3B

[... similar structure ...]
"""
)

# Call 3 (and so on for each parallel phase)
```

**After All Parallel Coders Complete**:

Execute merge phase as defined in PHASE_{k}.5_PLAN_MERGE.md, then clean up worktrees:
```bash
git merge feature/{subject}-3A --no-edit
git merge feature/{subject}-3B --no-edit
git merge feature/{subject}-3C --no-edit
git worktree remove ../{subject}-3A
git worktree remove ../{subject}-3B
git worktree remove ../{subject}-3C
```
```

3. Ensure proper formatting and syntax
4. Verify both sequential and parallel patterns are included

**Completion Criteria**:
- [ ] Section renamed to "Coder Invocation"
- [ ] Includes "When to Use" and context
- [ ] Shows sequential phase pattern
- [ ] Shows parallel phase pattern with worktree setup
- [ ] Describes post-parallel merge workflow
- [ ] Emphasizes worktree isolation for parallel phases

---

### Phase 5: Convert code-validator Pattern to Imperative Instructions

**Objective**: Replace pseudo-code example with explicit Task tool invocation instructions for code-validator.

**Location**: `skills/start-new/SKILL.md`, lines 366-377 (code-validator section)

**Current Content** (to be replaced):
```markdown
### code-validator
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are code-validator. Read agents/code-validator.md for your role.

    Validate phase implementation:
    - Phase: {phase_id}
    - Checklist: {items}

    Run quality checks and report results.
```
```

**Instructions for Coder**:

1. Locate the `### code-validator` heading (approximately line 366)
2. Replace the entire subsection with:

```markdown
### code-validator Invocation

**When to Use**: After each Coder completes a phase (Step 10), before committing changes

**Purpose**: Validate that phase implementation meets quality criteria and all checklist items are complete.

**Mandatory Task Tool Invocation Pattern**:

```
Task(
  subagent_type="general-purpose",
  prompt="""
You are code-validator. Read agents/code-validator.md for your role.

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
```

3. Ensure proper formatting
4. Verify YAML output format is correctly specified

**Completion Criteria**:
- [ ] Section renamed to "code-validator Invocation"
- [ ] Includes "When to Use" and purpose
- [ ] Shows mandatory Task() call structure
- [ ] Defines expected output format (YAML structure)
- [ ] Describes post-validation actions (commit/retry/skip)
- [ ] Includes retry loop pattern

---

### Phase 6: Verification Testing

**Objective**: Manually verify that updated documentation produces correct delegation behavior.

**Prerequisites**:
- All 5 phases above are complete
- File `skills/start-new/SKILL.md` has been modified and saved

**Manual Test Procedure**:

#### Test 1: TechnicalWriter Delegation (SPEC.md Creation)

1. Start a new feature workflow:
   ```bash
   /dc:start-new
   ```

2. Select "기능 추가/수정" (Feature)

3. Answer requirements questions

4. **CRITICAL CHECKPOINT**: At Step 2 (SPEC.md creation), observe Claude Code's execution log

5. **Expected Behavior**:
   - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are TechnicalWriter...")`
   - Log shows: `⎿ Subagent completed`
   - SPEC.md created at `claude_works/{subject}/SPEC.md`

6. **Forbidden Behavior** (must NOT see):
   - `● Read(agents/technical-writer.md)`
   - `● Write(claude_works/{subject}/SPEC.md)` without prior Task invocation

**Test 1 Result**: [ ] PASS / [ ] FAIL

---

#### Test 2: Designer Delegation (Design Phase)

1. Continue workflow from Test 1, approve SPEC.md

2. Select scope: "Design" or higher

3. **CRITICAL CHECKPOINT**: At Step 6 (Design phase), observe execution log

4. **Expected Behavior**:
   - Log shows prerequisite checks (branch check, SPEC.md exists, SPEC.md committed)
   - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are Designer...")`
   - Log shows: `⎿ Subagent completed`
   - Designer outputs architecture decisions and phase breakdown

5. **Forbidden Behavior** (must NOT see):
   - `● Read(agents/designer.md)` followed by inline design work
   - Direct analysis without Task invocation

**Test 2 Result**: [ ] PASS / [ ] FAIL

---

#### Test 3: TechnicalWriter Delegation (Design Documents)

1. Continue workflow from Test 2, after Designer completes

2. **CRITICAL CHECKPOINT**: At Step 7 (design document creation), observe execution log

3. **Expected Behavior**:
   - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are TechnicalWriter...")`
   - Prompt includes Designer output summary
   - Log shows: `⎿ Subagent completed`
   - Design documents created: GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md (or single DESIGN.md for simple tasks)

4. **Forbidden Behavior** (must NOT see):
   - Direct file writes without Task invocation
   - Reading template files and generating docs inline

**Test 3 Result**: [ ] PASS / [ ] FAIL

---

#### Test 4: Coder Delegation (Code Implementation)

1. Continue workflow with scope "Design → Code" or higher

2. **CRITICAL CHECKPOINT**: At Step 10 (phase execution), observe execution log

3. **Expected Behavior**:
   - For each phase in GLOBAL.md:
     - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are Coder...")`
     - Prompt includes phase ID and PLAN path
     - Log shows: `⎿ Subagent completed`
   - For parallel phases:
     - Multiple Task invocations in single message
     - Worktree paths specified in prompts

4. **Forbidden Behavior** (must NOT see):
   - Reading PLAN files and implementing directly
   - Code changes without Coder subagent invocation

**Test 4 Result**: [ ] PASS / [ ] FAIL

---

#### Test 5: code-validator Delegation (Validation)

1. Continue workflow from Test 4, observe after each Coder completes

2. **CRITICAL CHECKPOINT**: After Coder finishes a phase, before commit

3. **Expected Behavior**:
   - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are code-validator...")`
   - Prompt includes phase ID and checklist
   - Log shows: `⎿ Subagent completed`
   - Validator reports PASS/FAIL status
   - If PASS: commit happens
   - If FAIL: retry or skip logic activates

4. **Forbidden Behavior** (must NOT see):
   - Direct checklist verification without code-validator
   - Commits without validation

**Test 5 Result**: [ ] PASS / [ ] FAIL

---

#### Test 6: TechnicalWriter Delegation (Docs Update)

1. Continue workflow with scope "Design → Code → Docs" or higher

2. **CRITICAL CHECKPOINT**: At Step 11 (documentation update), observe execution log

3. **Expected Behavior**:
   - Log shows: `● Invoke Task tool (subagent_type: general-purpose, prompt: "You are TechnicalWriter...")`
   - Prompt includes DOCS_UPDATE role, target version, commit list
   - Log shows: `⎿ Subagent completed`
   - CHANGELOG.md and README.md updated

4. **Forbidden Behavior** (must NOT see):
   - Reading CHANGELOG.md and updating it directly
   - Direct git log analysis without TechnicalWriter delegation

**Test 6 Result**: [ ] PASS / [ ] FAIL

---

#### Final Verification Checklist

After completing all 6 tests above:

- [ ] All 6 tests passed
- [ ] No "Read(agents/*.md)" followed by direct work observed
- [ ] All agent work delegated via Task tool
- [ ] Subagent completion messages visible in logs
- [ ] Workflow completes successfully end-to-end
- [ ] Generated files (SPEC.md, design docs, code, CHANGELOG.md) are correct

**Overall Verification Result**: [ ] PASS / [ ] FAIL

If any test FAILS, review the corresponding phase implementation in `skills/start-new/SKILL.md` and revise the instructions to be more explicit.

---

## Completion Checklist

### Documentation Changes
- [ ] Phase 1: Delegation Enforcement section added
- [ ] Phase 2: TechnicalWriter pattern converted to imperative instructions
- [ ] Phase 3: Designer pattern converted to imperative instructions
- [ ] Phase 4: Coder pattern converted to imperative instructions
- [ ] Phase 5: code-validator pattern converted to imperative instructions

### Quality Checks
- [ ] All markdown syntax is correct (no broken headings, code blocks)
- [ ] All Task() call examples use correct syntax
- [ ] Section ordering is logical (Enforcement → Patterns)
- [ ] Cross-references between sections are accurate
- [ ] No typos or grammar errors

### Functional Verification
- [ ] Test 1 (TechnicalWriter SPEC.md): PASS
- [ ] Test 2 (Designer): PASS
- [ ] Test 3 (TechnicalWriter Design Docs): PASS
- [ ] Test 4 (Coder): PASS
- [ ] Test 5 (code-validator): PASS
- [ ] Test 6 (TechnicalWriter Docs Update): PASS

### Final Validation
- [ ] Full workflow test completed successfully
- [ ] No delegation bypass observed in logs
- [ ] SPEC.md correctly captures issue #5 resolution
- [ ] Ready for commit with message: "fix: enforce subagent delegation in start-new workflow"

---

## Test Cases

### Unit-Level Tests (Manual Inspection)

#### TC-1: Delegation Enforcement Section Exists
**Given**: File `skills/start-new/SKILL.md` is opened
**When**: Search for "## Delegation Enforcement"
**Then**: Section exists before "## Subagent Call Patterns"
**And**: Section contains subsections: Critical Rule, MUST DO, FORBIDDEN ACTIONS, Warning, Verification

**Expected Result**: Section found with all subsections present

---

#### TC-2: Imperative Language Used
**Given**: Delegation Enforcement section is read
**When**: Scan for imperative keywords
**Then**: Keywords MUST, SHALL, FORBIDDEN appear in appropriate contexts
**And**: Phrases like "should", "could", "recommended" are NOT used for mandatory rules

**Expected Result**: Only imperative language for mandatory protocols

---

#### TC-3: Task Tool Syntax is Correct
**Given**: TechnicalWriter Invocation section is read
**When**: Examine Example 1, 2, 3
**Then**: Each uses `Task(subagent_type="general-purpose", prompt="""...""")` format
**And**: No pseudo-code YAML format remains

**Expected Result**: All examples use actual Task() call syntax

---

#### TC-4: All Four Agents Covered
**Given**: Subagent Call Patterns section is complete
**When**: List all agent subsections
**Then**: Subsections exist for: TechnicalWriter, Designer, Coder, code-validator
**And**: Each has "Invocation" in the heading
**And**: Each shows mandatory Task() pattern

**Expected Result**: Four complete agent invocation subsections

---

### Integration-Level Tests (End-to-End Workflow)

#### TC-5: Feature Workflow - SPEC.md Delegation
**Given**: User runs `/dc:start-new`
**And**: Selects "기능 추가/수정"
**And**: Answers all requirements questions
**When**: Orchestrator reaches Step 2 (SPEC.md creation)
**Then**: Task tool is invoked with subagent_type "general-purpose"
**And**: Prompt begins with "You are TechnicalWriter. Read agents/technical-writer.md"
**And**: SPEC.md is created by subagent, not by orchestrator directly

**Expected Behavior**: Task invocation visible in log, SPEC.md created correctly

---

#### TC-6: Bugfix Workflow - Designer Delegation
**Given**: User runs `/dc:start-new`
**And**: Selects "버그 수정"
**And**: Completes init phase and SPEC.md approval
**And**: Selects scope "Design" or higher
**When**: Orchestrator reaches Step 6 (Design phase)
**Then**: Prerequisites are checked (branch, SPEC.md exists, SPEC.md committed)
**And**: Task tool is invoked for Designer
**And**: Designer analyzes SPEC.md and outputs design decisions

**Expected Behavior**: Prerequisite checks pass, Designer Task invoked, design output generated

---

#### TC-7: Refactor Workflow - Coder Delegation (Sequential)
**Given**: Workflow reaches Step 10 with sequential phases (1, 2, 3, 4)
**When**: Orchestrator executes phases in order
**Then**: For each phase:
  - Task tool is invoked with "You are Coder"
  - Prompt includes phase ID and PLAN path
  - Coder completes and reports changes
**And**: No direct code changes by orchestrator

**Expected Behavior**: Each phase delegated to Coder subagent, no inline implementation

---

#### TC-8: Feature Workflow - Coder Delegation (Parallel)
**Given**: Workflow reaches Step 10 with parallel phases (3A, 3B, 3C)
**When**: Orchestrator sets up worktrees and invokes Coders
**Then**: Multiple Task calls are made in single message
**And**: Each Task specifies different worktree path
**And**: All Coders complete before merge phase executes

**Expected Behavior**: Parallel Task invocations, worktree isolation, proper merge

---

#### TC-9: Code Implementation - code-validator Delegation
**Given**: Coder completes a phase implementation
**When**: Orchestrator proceeds to validation (Step 10)
**Then**: Task tool is invoked with "You are code-validator"
**And**: Prompt includes phase ID and checklist
**And**: code-validator reports PASS or FAIL status
**And**: If PASS: commit happens; If FAIL: retry or skip logic activates

**Expected Behavior**: Validation delegated to code-validator, proper handling of results

---

#### TC-10: Full Workflow - Docs Update Delegation
**Given**: Workflow completes all code phases
**And**: User scope includes "Docs"
**When**: Orchestrator reaches Step 11 (documentation update)
**Then**: Task tool is invoked with "You are TechnicalWriter"
**And**: Prompt includes DOCS_UPDATE role context
**And**: Prompt includes target version and commit list
**And**: TechnicalWriter updates CHANGELOG.md and README.md

**Expected Behavior**: TechnicalWriter delegated for docs, changes committed

---

### Edge Case Tests

#### TC-11: Error During Subagent Invocation
**Given**: Workflow reaches subagent invocation step
**When**: Task tool invocation fails (e.g., syntax error in prompt)
**Then**: Error is reported to user
**And**: Workflow halts at that step
**And**: User can diagnose issue from error message

**Expected Behavior**: Clear error propagation, workflow halt, no silent failure

---

#### TC-12: Subagent Returns Incomplete Result
**Given**: code-validator is invoked after Coder
**When**: code-validator returns FAIL status
**And**: Retry count < 3
**Then**: Coder is invoked again with validator feedback
**And**: Retry counter increments

**Expected Behavior**: Retry loop activates, Coder receives feedback

---

#### TC-13: User Interrupts During Subagent Work
**Given**: Task tool invocation is in progress
**When**: User sends interrupt signal (Ctrl+C or "stop" command)
**Then**: Subagent stops gracefully
**And**: Orchestrator resumes control
**And**: Workflow state is preserved for potential resume

**Expected Behavior**: Graceful interruption, state preserved

---

#### TC-14: Missing Agent Definition File
**Given**: Workflow invokes subagent via Task tool
**When**: Agent definition file (e.g., agents/technical-writer.md) is missing
**Then**: Task tool reports error
**And**: Error message indicates which agent file is missing
**And**: Workflow halts with actionable error

**Expected Behavior**: Clear error about missing agent file, workflow halt

---

### Regression Tests

#### TC-15: Existing Correct Workflows Still Work
**Given**: A workflow that was correctly using Task delegation before this fix
**When**: Workflow is executed after documentation changes
**Then**: Workflow completes successfully
**And**: No behavior changes observed
**And**: All subagents still invoked correctly

**Expected Behavior**: No regression, backward compatibility maintained

---

#### TC-16: Other Skills Not Affected
**Given**: Other skills in the dotclaude plugin (e.g., /dc:tagging, /dc:merge-main)
**When**: These skills are executed
**Then**: No errors occur
**And**: Behavior is unchanged
**And**: Documentation changes in start-new/SKILL.md do not affect other skills

**Expected Behavior**: Isolation of changes to start-new skill only

---

## Notes

### Why This is SIMPLE Complexity

This bug fix is classified as SIMPLE because:
1. **Single file modification**: Only `skills/start-new/SKILL.md` is changed
2. **Documentation-only**: No code logic, no agent definitions, no tool implementations modified
3. **Additive changes**: New section added, existing sections reformatted for clarity
4. **No breaking changes**: Existing correct usage remains valid
5. **Self-contained**: Fix does not require coordinated changes across multiple files

### Implementation Sequence

The 6 phases must be executed in order:
1. **Phase 1** establishes the protocol (the "why")
2. **Phases 2-5** apply the protocol to each agent (the "how")
3. **Phase 6** verifies the fix works end-to-end (the "proof")

Do not skip Phase 6 verification - it is critical to confirm that documentation changes actually fix the reported issue.

### Success Criteria

The fix is successful when:
- No workflow step directly reads `agents/*.md` files to execute agent work inline
- Every agent-specific task is delegated via Task tool with appropriate subagent_type
- Log patterns match "Expected Behavior" in test cases
- Issue #5 can be closed as resolved

---

## References

- **Original Issue**: https://github.com/U-lis/dotclaude/issues/5
- **Target File**: `/home/ulismoon/Documents/dotclaude/skills/start-new/SKILL.md`
- **Agent Definitions**: `/home/ulismoon/Documents/dotclaude/agents/`
- **SPEC Document**: `/home/ulismoon/Documents/dotclaude/claude_works/spec-writing-subagent/SPEC.md`
