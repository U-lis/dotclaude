# init-invocation-fix - Design Document

## Architecture Decisions

### AD-1: Modify only `commands/start-new.md`

- **Decision**: The fix is scoped to a single file (`commands/start-new.md`), specifically lines 79-89 (Step 2: Load Init Instructions).
- **Rationale**: The root cause is ambiguous language in Step 2 that fails to instruct Claude to use the `Skill()` tool. No other files contribute to this bug. The init-xxx command files themselves are correct; only the invocation instruction is broken.

### AD-2: Replace ambiguous "follow" language with explicit `Skill()` invocation syntax

- **Decision**: Replace `"Follow the \`init-feature\` command"` pattern with `Skill("dotclaude:init-feature")` syntax in all four table rows.
- **Rationale**: The original text `"follow the corresponding init command (Claude auto-loads command content)"` is ambiguous about *how* Claude should load the command. Claude interprets this as permission to improvise questions rather than invoking the Skill tool. Using the exact `Skill("dotclaude:init-xxx")` call syntax removes all ambiguity.

### AD-3: Add CRITICAL warning against improvised questions

- **Decision**: Add a `**CRITICAL**` warning block immediately after the routing table, explicitly forbidding ad-hoc question generation.
- **Rationale**: Claude has a behavioral bias toward generating helpful questions when it lacks explicit instructions. The warning acts as a guardrail, ensuring Claude waits for the Skill to load its own question flow rather than inventing one.

### AD-4: Preserve all surrounding text unchanged

- **Decision**: Step 1, Step 2.6, the "Execute ALL steps" block (line 90+), and all subsequent steps remain untouched.
- **Rationale**: The bug is isolated to the routing table and its introductory sentence. Changing anything outside this scope introduces unnecessary risk and violates the constraint defined in SPEC.md.

---

## Phase Plan (Single Phase)

### Phase 1: Replace Step 2 text in `commands/start-new.md`

#### Objective

Replace the ambiguous init command routing table (lines 79-89) with explicit `Skill()` invocation syntax and add a CRITICAL warning block.

#### Prerequisites

- SPEC.md reviewed and approved
- `commands/start-new.md` is accessible in the worktree

#### Instructions

1. **Open** `commands/start-new.md` and locate lines 79-89 (Step 2: Load Init Instructions).

2. **Replace line 81** (introductory sentence):
   - Old: `Based on Step 1 response, follow the corresponding init command (Claude auto-loads command content):`
   - New: `Based on Step 1 response, invoke the corresponding init command via the Skill tool:`

3. **Replace the routing table** (lines 83-88):
   - Change header from `| User Selection | Init Command |` to `| User Selection | Action |`
   - Change separator from `|----------------|--------------|` to `|----------------|--------|`
   - Replace each row's second column:
     - `Follow the \`init-feature\` command` -> `` `Skill("dotclaude:init-feature")` ``
     - `Follow the \`init-bugfix\` command` -> `` `Skill("dotclaude:init-bugfix")` ``
     - `Follow the \`init-refactor\` command` -> `` `Skill("dotclaude:init-refactor")` ``
     - `Follow the \`init-github-issue\` command` -> `` `Skill("dotclaude:init-github-issue")` ``

4. **Insert CRITICAL warning block** immediately after the table (before line 90's "Execute ALL steps" block):
   ```
   **CRITICAL**: Do NOT improvise questions. The init command defines its own question flow.
   Wait for the Skill to load, then follow its instructions exactly.
   ```

5. **Verify** that the "Execute ALL steps defined in the loaded init file:" block (line 90+) remains unchanged.

6. **Verify** that Step 1 (lines 67-78) remains unchanged.

7. **Verify** that Step 2.6 and all subsequent steps remain unchanged.

#### Completion Checklist

- [ ] C-1: Line 81 changed from "follow the corresponding init command (Claude auto-loads command content):" to "invoke the corresponding init command via the Skill tool:"
- [ ] C-2: Table header changed from "Init Command" to "Action"
- [ ] C-3: All four table rows use `Skill("dotclaude:init-xxx")` syntax
- [ ] C-4: CRITICAL warning block added immediately after the table
- [ ] C-5: "Execute ALL steps defined in the loaded init file:" block remains unchanged
- [ ] C-6: Step 1 (lines 67-78) remains unchanged
- [ ] C-7: Step 2.6 and all subsequent steps remain unchanged
- [ ] C-8: No other files are modified

#### Notes

- The replacement must be an exact string match. Use the Edit tool with `old_string` / `new_string` for precision.
- The CRITICAL warning uses two lines: one for the prohibition, one for the expected behavior.
- Ensure a blank line separates the table from the CRITICAL warning block.

---

## Test Criteria

### Test Coverage Target

100% (single-file, single-region change)

### Verification Tests

#### Content Verification

- [ ] T-1: Line 81 contains the exact text `invoke the corresponding init command via the Skill tool:`
- [ ] T-2: Table header row contains `| User Selection | Action |`
- [ ] T-3: Feature row contains `` `Skill("dotclaude:init-feature")` ``
- [ ] T-4: Bug Fix row contains `` `Skill("dotclaude:init-bugfix")` ``
- [ ] T-5: Refactoring row contains `` `Skill("dotclaude:init-refactor")` ``
- [ ] T-6: GitHub Issue row contains `` `Skill("dotclaude:init-github-issue")` ``
- [ ] T-7: CRITICAL warning block is present with text "Do NOT improvise questions"
- [ ] T-8: Second line of warning contains "Wait for the Skill to load, then follow its instructions exactly."

#### Regression Tests (No Unintended Changes)

- [ ] T-9: Step 1 block (AskUserQuestion for work type selection) is unchanged
- [ ] T-10: "Execute ALL steps defined in the loaded init file:" block and its sub-items (lines 90-95) are unchanged
- [ ] T-11: Step 2.6 (Target Version Question) is unchanged
- [ ] T-12: Step 3 and all subsequent steps are unchanged
- [ ] T-13: No other files in the repository are modified (verify via `git diff --name-only`)

#### Edge Cases

- [ ] T-14: The word "follow" does NOT appear in the Step 2 routing table (confirms full replacement)
- [ ] T-15: The phrase "auto-loads" does NOT appear anywhere in Step 2 (confirms removal of ambiguous language)
