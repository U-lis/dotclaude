# Spec-Writing-Subagent Bug Fix - Specification

**Target Version**: 0.2.0
**Work Type**: bugfix
**Source Issue**: https://github.com/U-lis/dotclaude/issues/5

---

## User-Reported Information

### Symptom
The `start-new` skill does not invoke TechnicalWriter as a subagent using the Task tool. Instead, it directly reads the agent definition file (`agents/technical-writer.md`) and executes the work inline.

### Evidence from Issue Log
```
● Read(.claude/templates/SPEC.md)
● Read(.claude/agents/technical-writer.md)
● Write(claude_works/github-issue-fetch/SPEC.md)
```

**Expected Behavior**: Spawn TechnicalWriter via Task tool with `subagent_type: "general-purpose"`

**Actual Behavior**: Read agent markdown file and perform work directly

### User Concerns
1. Primary issue: SPEC.md writing (Step 2) bypasses subagent invocation
2. Possible similar issues in:
   - Design phase (Step 6-7) calling Designer
   - Design docs writing (Step 7) calling TechnicalWriter
   - Docs update (Step 11) calling TechnicalWriter with DOCS_UPDATE role

---

## AI Analysis Results

### Root Cause

**Location**: `skills/start-new/SKILL.md`, lines 323-377 (Subagent Call Patterns section)

**Issue**: The "Subagent Call Patterns" section uses descriptive pseudo-code rather than mandatory instructions.

**Current Format**:
```markdown
### TechnicalWriter
```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    You are TechnicalWriter. Read agents/technical-writer.md for your role.
    ...
```
```

**Why This Fails**:
- Format appears as documentation/example rather than imperative instruction
- No explicit enforcement mechanism prevents direct execution
- Missing MUST/FORBIDDEN language
- No warning about direct execution being a violation

### Affected Code Sections

| File | Lines | Phase | Current Behavior | Should Be |
|------|-------|-------|------------------|-----------|
| `skills/start-new/SKILL.md` | 323-335 | Step 2 (SPEC.md) | Direct execution | Task tool invocation |
| `skills/start-new/SKILL.md` | 337-349 | Step 6-7 (Design) | **Needs verification** | Task tool invocation |
| `skills/start-new/SKILL.md` | N/A | Step 7 (Design docs) | **Needs verification** | Task tool invocation |
| `skills/start-new/SKILL.md` | N/A | Step 11 (Docs update) | **Needs verification** | Task tool invocation |

### Impact Assessment

**Severity**: Medium
**User Impact**: High (affects all start-new workflows)
**Consistency**: Breaks agent separation principle
**Technical Debt**: Creates precedent for inline execution instead of proper delegation

---

## Functional Requirements

### Core Fix
- [ ] FR-1: Add "Delegation Enforcement" section to SKILL.md with explicit MUST/FORBIDDEN rules
- [ ] FR-2: Convert pseudo-code examples to imperative Task tool invocation instructions
- [ ] FR-3: Add warning that direct execution of agent work is a protocol violation
- [ ] FR-4: Ensure TechnicalWriter subagent invocation for SPEC.md writing (Step 2)

### Verification Requirements
- [ ] FR-5: Verify Designer subagent invocation for design phase (Step 6-7)
- [ ] FR-6: Verify TechnicalWriter subagent invocation for design docs (Step 7)
- [ ] FR-7: Verify TechnicalWriter subagent invocation for docs update (Step 11)

### Documentation Requirements
- [ ] FR-8: Document correct subagent invocation pattern in SKILL.md
- [ ] FR-9: Provide clear examples of Task tool usage for each agent type
- [ ] FR-10: Add troubleshooting section for delegation issues

---

## Non-Functional Requirements

### Clarity
- [ ] NFR-1: Instructions must be unambiguous and immediately actionable
- [ ] NFR-2: Use imperative language (MUST, SHALL, FORBIDDEN) for enforcement
- [ ] NFR-3: Distinguish between examples and mandatory protocols

### Maintainability
- [ ] NFR-4: Changes must not break existing workflow compatibility
- [ ] NFR-5: Pattern should be reusable for other skills requiring subagent delegation

### Testability
- [ ] NFR-6: Provide verifiable criteria for correct delegation behavior
- [ ] NFR-7: Include manual testing checklist in PHASE_1_TEST.md

---

## Constraints

### Technical Constraints
- Must modify: `skills/start-new/SKILL.md`
- Cannot change: Agent definitions in `agents/` directory
- Cannot change: Task tool API or behavior
- Language: Markdown documentation
- Framework: dotclaude plugin architecture

### Compatibility Constraints
- Must maintain backward compatibility with existing start-new workflows
- Changes should not affect other skills or commands
- Must work with general-purpose subagent type

---

## Out of Scope

The following are explicitly NOT part of this bug fix:
- Creating new agent types or roles
- Modifying Task tool implementation
- Changing agent definition file structure
- Adding automated enforcement mechanisms (runtime checks)
- Refactoring entire start-new workflow beyond delegation fix
- Performance optimization of subagent calls

---

## Fix Strategy

### Phase 1: Documentation Enhancement

**Location**: `skills/start-new/SKILL.md`

**Changes Required**:

1. **Add Delegation Enforcement Section** (before Subagent Call Patterns)
   ```markdown
   ## Delegation Enforcement

   **CRITICAL RULE**: NEVER execute agent work directly. ALWAYS delegate via Task tool.

   **MUST**:
   - Use Task tool with appropriate subagent_type
   - Pass agent role explicitly in prompt
   - Wait for subagent completion before proceeding

   **FORBIDDEN**:
   - Reading agent .md files to execute work inline
   - Implementing agent logic directly in orchestrator context
   - Bypassing Task tool for convenience

   **WARNING**: Direct execution violates agent separation principle and may cause:
   - Inconsistent behavior across workflows
   - Loss of agent-specific optimizations
   - Difficulty in debugging and maintenance
   ```

2. **Convert Pseudo-Code to Imperative Instructions**

   Replace current format:
   ```markdown
   ### TechnicalWriter
   ```
   Task tool:
     subagent_type: "general-purpose"
     ...
   ```
   ```

   With mandatory format:
   ```markdown
   ### TechnicalWriter Invocation

   **When**: SPEC.md writing, design docs, documentation updates

   **Mandatory Task Tool Call**:
   ```
   <invoke Task>
     subagent_type: "general-purpose"
     prompt: |
       You are TechnicalWriter. Read agents/technical-writer.md for your role.

       Create {document_type} document:
       - Input: {content_data}
       - Output path: {target_path}

       Follow the template structure from your agent definition.
   </invoke>
   ```

   **Example for SPEC.md** (Step 2):
   ```
   <invoke Task>
     subagent_type: "general-purpose"
     prompt: |
       You are TechnicalWriter. Read agents/technical-writer.md for your role.

       Create SPEC.md at: claude_works/{subject}/SPEC.md

       Include:
       - Overview (purpose, problem, solution)
       - Functional requirements from interview
       - Non-functional requirements
       - Constraints identified
       - Out of scope items

       Use template structure from templates/SPEC.md
   </invoke>
   ```
   ```

3. **Apply Same Pattern to All Agents**
   - Designer invocation (Step 6-7)
   - Coder invocation (Step 8-9)
   - code-validator invocation (Step 10)

### Phase 2: Verification Testing

**Manual Test Checklist**:
- [ ] Run `/dotclaude:start-new` with new feature request
- [ ] Verify Step 2 shows Task tool invocation (not direct Read/Write)
- [ ] Verify SPEC.md is created correctly
- [ ] Verify Step 6-7 shows Designer Task tool invocation
- [ ] Verify Step 11 shows TechnicalWriter Task tool invocation for docs

**Expected Log Pattern**:
```
● Invoke Task tool (subagent_type: general-purpose, TechnicalWriter)
  ⎿ Subagent completed
● SPEC.md created at claude_works/{subject}/SPEC.md
```

**Forbidden Log Pattern**:
```
● Read(agents/technical-writer.md)
● Write(claude_works/{subject}/SPEC.md)
```

---

## Edge Cases for Testing

### Edge Case 1: User Interrupts During Subagent Work
- **Scenario**: Task tool running, user sends cancel
- **Expected**: Subagent stops gracefully, orchestrator resumes control
- **Test**: Interrupt during SPEC.md writing

### Edge Case 2: Subagent Fails with Error
- **Scenario**: TechnicalWriter throws error during document creation
- **Expected**: Error propagates to orchestrator, clear failure message
- **Test**: Invalid template path or missing data

### Edge Case 3: Multiple Sequential Subagent Calls
- **Scenario**: Designer → TechnicalWriter → Coder sequence
- **Expected**: Each waits for previous completion, no parallel confusion
- **Test**: Full workflow through Step 8

### Edge Case 4: Existing claude_works Directory
- **Scenario**: SPEC.md path already exists from previous run
- **Expected**: TechnicalWriter handles overwrite or creates versioned file
- **Test**: Rerun start-new with same subject

---

## Assumptions

- Task tool with `subagent_type: "general-purpose"` works correctly for all agent types
- Agent definition files (agents/*.md) contain sufficient role instructions
- Orchestrator correctly interprets imperative Task tool invocation syntax
- No runtime enforcement needed beyond documentation clarity

---

## Open Questions

- [ ] Should we add automated detection (e.g., grep for Read(agents/) in logs)?
- [ ] Should delegation violations log warnings even if they complete successfully?
- [ ] Should we create a linter for SKILL.md files to validate delegation patterns?
- [ ] Do any other skills (beyond start-new) have similar delegation issues?

---

## References

- Original Issue: https://github.com/U-lis/dotclaude/issues/5
- Affected File: `skills/start-new/SKILL.md`
- Agent Definitions: `agents/technical-writer.md`, `agents/designer.md`, `agents/coders/*.md`
- Template: `templates/SPEC.md`
