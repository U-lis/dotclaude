# Phase 3: Template & Validator Slimming

## Objective

Revise `templates/PHASE_TEST.md` to remove the per-function slot structure and generic edge case catalog, demote the 70% coverage gate to a reference figure, and align `agents/technical-writer.md`, `agents/spec-validator.md`, and `commands/validate-spec.md` with the new approach.

## Prerequisites

- None structurally. Run after Phase 2 for a clean commit history (Phases 1 and 2 must be committed before this phase starts).

## Instructions

### Step 1: Rewrite `templates/PHASE_TEST.md` (FR-3)

Rewrite the entire template. The new structure replaces the old per-function unit slots and generic edge-case catalog with a behavior-centric format. Retain only the following sections:

**New template structure**:

```markdown
# Phase {K}: Test Cases

## Test Coverage Target

Coverage 70% is a REFERENCE figure, not a pass/fail gate.

---

## Behaviors to Verify

List each behavior that this phase introduces or modifies. For each:
- **Behavior**: one-sentence description
- **Verification layer**: unit | integration | endpoint | scenario
- **Notes** (optional): any constraint on HOW to verify

Layer choice rule (pruner criterion 1): branch combinations (each rejection / exception / boundary branch) are verified at exactly ONE layer (typically unit). Higher-layer tests are limited to: wiring, response contract (status code / schema), query count, representative flows (1 happy path + 1 representative failure per distinct response contract).

---

## Edge Cases Actually Applicable to This Phase

List only edge cases that are real possibilities given this phase's code. Leave blank or omit if none apply.

---

## Mock / Stub Requirements

List only mocks that are actually needed for the behaviors above. Omit if not applicable.
```

Specific removals from the current template:

- Remove the entire "Unit Tests" section with `### {Component/Module 1}` and `#### {Function/Method 1}` per-function slots.
- Remove the entire generic "Edge Cases" section containing: Empty input, Network failure, Database error, Timeout, Maximum size, Minimum size, Zero/null values, Input sanitization, Authentication required, Authorization enforced.
- Remove the "Integration Tests" section with per-scenario slots.
- Remove the "Performance Tests (if applicable)" section.
- Remove the "Security Tests (if applicable)" section listing generic input sanitization / authentication / authorization items.
- The `## Test Coverage Target` section must contain "Coverage 70% is a REFERENCE figure, not a pass/fail gate." and nothing else as a minimum requirement.

### Step 2: Align `agents/technical-writer.md` (FR-3)

Two locations to update:

**Location A — line 44** (the document table row):
Current text: `| \`PHASE_{k}_TEST.md\` | Phase test cases - target coverage ≥ 70% |`
New text: `| \`PHASE_{k}_TEST.md\` | Phase test cases - coverage 70% is a reference figure, not a gate |`

**Location B — lines 163-181** (the PHASE_TEST structure block):
Current text:
```markdown
### PHASE_{k}_TEST.md Structure
```markdown
# Phase {k}: Test Cases

## Test Coverage Target
≥ 70%

## Unit Tests
### {Component/Function}
- [ ] Test case 1: ...
- [ ] Test case 2: ...

## Integration Tests
- [ ] ...

## Edge Cases
- [ ] ...
```
```

Replace with:
```markdown
### PHASE_{k}_TEST.md Structure
```markdown
# Phase {k}: Test Cases

## Test Coverage Target
Coverage 70% is a REFERENCE figure, not a pass/fail gate.

## Behaviors to Verify
- **Behavior**: {description} | **Layer**: unit | integration | endpoint | scenario

## Edge Cases Actually Applicable to This Phase
{only edge cases real for this phase; omit if none}
```
```

Do NOT modify any other section of `agents/technical-writer.md`.

### Step 3: Align `agents/spec-validator.md` (FR-4)

Three locations to update:

**Location A — around line 44** (Plan-Test Alignment checklist):
Current text:
```
- [ ] Test coverage target (≥ 70%) is achievable with defined test cases
```
Replace with:
```
- [ ] Test coverage reported (reference only; not a pass/fail gate)
```

**Location B — around lines 46-48** (Completeness bullets):
Current text:
```
### Completeness
- [ ] No missing edge cases
- [ ] Error handling scenarios covered
- [ ] Boundary conditions addressed
```
Replace with (or reword to report-only):
```
### Completeness
- [ ] Behavior coverage is reported (informational only; spec-validator MUST NOT add test cases and MUST NOT instruct TechnicalWriter to add test cases)
```

**Location C — Output / "Validation Passed" checklist**:
Locate the coverage item in the output checklist (search for `≥ 70%` or `coverage` in that section). Replace any `≥ 70%` or `>= 70%` occurrence with "Coverage reported (reference only)".

Add the following rule as a standalone line or subsection in the spec-validator body (not inside a checklist item, but as an explicit rule):
```
**spec-validator MUST NOT add test cases and MUST NOT instruct TechnicalWriter to add test cases. Missing behavior coverage is reported as informational only.**
```

### Step 4: Align `commands/validate-spec.md` (FR-3, FR-4)

**Line 63** (currently: `- [ ] Coverage target achievable (≥ 70%)`):
Replace with:
```
- [ ] Coverage reported (reference only; 70% is not a pass/fail gate)
```

Also locate any "No missing edge cases" style item in this file. If present, remove or reword to report-only (informational, not a blocking check).

Do NOT modify any other content in `commands/validate-spec.md`.

## Completion Checklist

- [ ] `templates/PHASE_TEST.md`: `70%` appears at most once, only in the reference-figure sentence
- [ ] `templates/PHASE_TEST.md`: per-function unit slot patterns removed (no `Function/Method` or `#### {Function` headings)
- [ ] `templates/PHASE_TEST.md`: generic edge cases catalog removed (no "Empty input", "Network failure", "Database error", "Timeout", "Maximum size", "Minimum size", "Input sanitization", "Authentication required", "Authorization enforced")
- [ ] `templates/PHASE_TEST.md`: "reference figure" or "not a pass/fail gate" phrase present
- [ ] `agents/technical-writer.md` line 44: no `≥ 70%` or `>= 70%`
- [ ] `agents/technical-writer.md` PHASE_TEST structure block (~lines 163-181): no `≥ 70%` or `>= 70%`
- [ ] `agents/spec-validator.md`: no `≥ 70%` or `>= 70%`
- [ ] `agents/spec-validator.md`: "MUST NOT add test cases" present
- [ ] `agents/spec-validator.md`: "No missing edge cases" removed
- [ ] `commands/validate-spec.md` line 63: no `≥ 70%` or `>= 70%`
- [ ] `commands/validate-spec.md`: "No missing edge cases" removed or reworded to informational

## Notes

- The `agents/spec-validator.md` is only triggered manually via `/dotclaude:validate-spec` (see `commands/design.md:102`); it is not part of the default start-new/code flow. FR-4 therefore affects manual validation runs only.
- The `agents/code-validator.md:225` line (`Test coverage: {X}%`) is informational output; it is out of scope for Phase 3 and must not be changed.
- Do NOT modify `CHANGELOG.md` or version files (per project convention).
