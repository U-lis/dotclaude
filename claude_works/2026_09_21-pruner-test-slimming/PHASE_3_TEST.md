# Phase 3: Test Cases

## Test Coverage

Coverage: N/A. No executable test suite exists in this repository (Markdown plugin). The 70% figure is a reference, not a gate.

## Test Strategy

All verification is by file-content inspection using grep and read checks. Each check below is a deterministic command against the resulting filesystem state.

All paths are relative to the worktree root: `/home/ulismoon/Documents/dotclaude/dotclaude-feature-pruner-test-slimming`.

---

## Behaviors to Verify

### B-1: `templates/PHASE_TEST.md` 70% demotion (FR-3)

Verification layer: grep checks

- [x] B-1.1: `70%` appears at most once in the template (only in the reference-figure sentence)
  ```bash
  grep -c '70%' templates/PHASE_TEST.md
  ```
  Expected: `<=1` — Actual: `1` PASS

- [x] B-1.2: "reference figure" or "not a pass/fail gate" phrase present
  ```bash
  grep -ciE 'reference figure|not a pass/fail gate' templates/PHASE_TEST.md
  ```
  Expected: `>=1` — Actual: `1` PASS

### B-2: Per-function unit slot patterns removed from `templates/PHASE_TEST.md` (FR-3)

Verification layer: grep checks

- [x] B-2.1: No `Function/Method` or `#### {Function` headings remain
  ```bash
  grep -cE 'Function/Method|#### \{Function' templates/PHASE_TEST.md
  ```
  Expected: `0` — Actual: `0` PASS

### B-3: Generic edge cases catalog removed from `templates/PHASE_TEST.md` (FR-3)

Verification layer: grep checks

- [x] B-3.1: None of the generic catalog items remain
  ```bash
  grep -cE 'Empty input|Network failure|Database error|Timeout|Maximum size|Minimum size|Input sanitization|Authentication required|Authorization enforced' templates/PHASE_TEST.md
  ```
  Expected: `0` — Actual: `0` PASS

### B-4: `≥ 70%` and `>= 70%` removed from all three aligned files (FR-3)

Verification layer: grep checks

- [x] B-4.1: No hard coverage gate in technical-writer, spec-validator, or validate-spec
  ```bash
  grep -cE '≥ 70%|>= 70%' agents/technical-writer.md agents/spec-validator.md commands/validate-spec.md
  ```
  Expected: `0` across all three files — Actual: `0` each PASS

### B-5: `agents/spec-validator.md` "MUST NOT add test cases" rule added (FR-4)

Verification layer: grep check

- [x] B-5.1: The prohibition on adding test cases is present
  ```bash
  grep -c 'MUST NOT add test cases' agents/spec-validator.md
  ```
  Expected: `>=1` — Actual: `2` PASS

### B-6: "No missing edge cases" removed from spec-validator and validate-spec (FR-4)

Verification layer: grep checks

- [x] B-6.1: "No missing edge cases" not present in spec-validator or validate-spec
  ```bash
  grep -c 'No missing edge cases' agents/spec-validator.md commands/validate-spec.md
  ```
  Expected: `0` — Actual: `0` each PASS

## FR / NFR Coverage Mapping

| Requirement | Covered by |
|-------------|------------|
| FR-3 (PHASE_TEST.md: per-function slots removed, generic edge cases removed, 70% demoted) | B-1, B-2, B-3 |
| FR-3 (technical-writer.md and validate-spec.md aligned) | B-4 |
| FR-4 (spec-validator MUST NOT add test cases; no edge-case inflation items) | B-5, B-6 |
