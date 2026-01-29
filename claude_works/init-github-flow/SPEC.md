<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Fix init-github flow - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/27
**Target Version**: 0.3.0
**Severity**: Major

## Overview

When `init-xxx` commands (`init-feature`, `init-bugfix`, `init-refactor`) receive a GitHub issue with pre-collected information via `init-github-issue`, they unconditionally ask ALL questions regardless of whether the data is already available. This causes redundant user interaction. The fix enhances `init-github-issue.md` to perform deep body analysis extracting ALL possible init-xxx fields, and adds conditional skip logic to every step in every init file so that ANY question with pre-filled data is automatically skipped.

## Bug Description

### Current Behavior

1. User runs `/dotclaude:start-new` and selects "GitHub Issue"
2. `init-github-issue.md` parses the issue and extracts a `pre_filled` context containing ONLY `goal`, `problem`, `branch_keyword`, and `target_version`
3. Control routes to `init-feature.md`, `init-bugfix.md`, or `init-refactor.md`
4. ALL questions are asked sequentially, including those already answered by the GitHub issue data
5. User must manually re-enter or confirm information that is already available

### Expected Behavior

1. `init-github-issue.md` performs deep analysis of the issue body, extracting structured information that maps to ALL possible init-xxx question fields (not just goal/problem)
2. When `pre_filled` context is available, ANY question with matching pre-filled data is AUTO-SKIPPED
3. Only questions without pre-filled data are asked to the user
4. SPEC.md validation at Step 3 handles overall correctness, so per-question confirmation is unnecessary

### Reproduction Steps

1. Run `/dotclaude:start-new` with a GitHub issue URL that contains detailed information (e.g., reproduction steps, severity, technical constraints)
2. Issue is parsed, work type detected, context extracted
3. Control routes to the appropriate init file (init-feature / init-bugfix / init-refactor)
4. Observe: ALL questions are asked, even those already answered by the GitHub issue body

## Root Cause Analysis

### Source of Pre-filled Data

The `init-github-issue.md` command (Step 4) currently passes a minimal `pre_filled` context to the init file:

```yaml
pre_filled:
  goal: "{issue_title}"
  problem: "{first paragraph of issue_body}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

This context only covers 2 fields (`goal`, `problem`) that map to init-xxx questions, leaving all other steps without pre-filled data even when the issue body contains relevant information.

### Root Cause

Two issues combine to produce the bug:

1. **Shallow extraction**: `init-github-issue.md` Step 4 (Context Extraction) only extracts `goal`, `problem`, `branch_keyword`, and `target_version`. It does NOT analyze the issue body deeply to extract information for other init-xxx question fields (e.g., reproduction steps, severity, core features, technical constraints).

2. **No skip logic**: The init files (`init-feature.md`, `init-bugfix.md`, `init-refactor.md`) contain NO conditional logic. They always ask every question sequentially using `AskUserQuestion` without checking whether `pre_filled` data exists for that question. There is no "IF pre_filled exists THEN skip" instruction in any init file.

### Contributing Factor

The `init-github-issue.md` Step 5 documentation describes showing pre-filled values as defaults with "[Extracted from GitHub Issue]" format (show-as-default), but the desired behavior is to SKIP the question entirely (auto-skip). The downstream SPEC.md review at Step 3 serves as the validation checkpoint, making per-question confirmation unnecessary.

## Functional Requirements

### Enhanced Context Extraction (init-github-issue.md)

- [ ] FR-1: `init-github-issue.md` Step 4 (Context Extraction) MUST perform deep analysis of the issue body to extract structured information matching ALL possible init-xxx question fields, not just `goal` and `problem`.
- [ ] FR-2: The deep body analysis MUST attempt to extract the following fields per work type:

  **For feature** (`init-feature.md` Steps 1-8):
  | Pre-filled Key | Maps to Step | Extraction Heuristic |
  |----------------|--------------|----------------------|
  | `goal` | Step 1: Goal | Issue title |
  | `problem` | Step 2: Problem | First paragraph of issue body |
  | `core_features` | Step 3: Core Features | Bulleted lists, "requirements", "must have", "core" sections |
  | `additional_features` | Step 4: Additional Features | "Nice to have", "optional", "bonus" sections |
  | `technical_constraints` | Step 5: Technical Constraints | "Constraints", "must use", "required stack" mentions |
  | `performance` | Step 6: Performance | "Performance", "latency", "throughput", "SLA" mentions |
  | `security` | Step 7: Security | "Security", "auth", "encryption", "validation" mentions |
  | `out_of_scope` | Step 8: Out of Scope | "Out of scope", "not included", "excluded" sections |

  **For bugfix** (`init-bugfix.md` Steps 1-6):
  | Pre-filled Key | Maps to Step | Extraction Heuristic |
  |----------------|--------------|----------------------|
  | `symptoms` | Step 1: Symptoms | Issue title + first paragraph of body |
  | `reproduction_steps` | Step 2: Reproduction Steps | "Steps to reproduce", numbered lists, "how to reproduce" sections |
  | `expected_cause` | Step 3: Expected Cause | "Cause", "root cause", "suspect", "because" mentions |
  | `severity` | Step 4: Severity | "Critical", "major", "minor", "trivial" keywords; label-based severity |
  | `related_files` | Step 5: Related Files | File paths (e.g., `src/...`, `*.ts`), code blocks with filenames |
  | `impact_scope` | Step 6: Impact Scope | "Affects", "impact", "related features" mentions |

  **For refactor** (`init-refactor.md` Steps 1-6):
  | Pre-filled Key | Maps to Step | Extraction Heuristic |
  |----------------|--------------|----------------------|
  | `target` | Step 1: Target | Issue title, "target", "refactor" subject |
  | `problems` | Step 2: Problems | "Problem", "issue", "code smell", DRY/SRP/coupling mentions |
  | `goal_state` | Step 3: Goal State | "Goal", "expected result", "after refactoring" sections |
  | `behavior_change` | Step 4: Behavior Change | "Breaking change", "preserve behavior", "no functional change" mentions |
  | `test_status` | Step 5: Test Status | "Test", "coverage", "tested", "untested" mentions |
  | `dependencies` | Step 6: Dependencies | "Depends on", "used by", "dependency", module references |

- [ ] FR-3: Fields that cannot be confidently extracted from the issue body MUST be omitted from `pre_filled` (not set to empty string). Only include a field when the extraction produces meaningful, non-empty content.

### Skip Logic for All Init File Steps

- [ ] FR-4: `init-feature.md` - ALL Steps 1 through 8 MUST check for pre-filled data before asking. For each step: IF the corresponding `pre_filled` key exists and is non-empty, SKIP the step and use the pre-filled value. Otherwise, ask the question normally.

  | Step | Question | Pre-filled Key |
  |------|----------|----------------|
  | Step 1 | Goal | `pre_filled.goal` |
  | Step 2 | Problem | `pre_filled.problem` |
  | Step 3 | Core Features | `pre_filled.core_features` |
  | Step 4 | Additional Features | `pre_filled.additional_features` |
  | Step 5 | Technical Constraints | `pre_filled.technical_constraints` |
  | Step 6 | Performance | `pre_filled.performance` |
  | Step 7 | Security | `pre_filled.security` |
  | Step 8 | Out of Scope | `pre_filled.out_of_scope` |

- [ ] FR-5: `init-bugfix.md` - ALL Steps 1 through 6 MUST check for pre-filled data before asking. For each step: IF the corresponding `pre_filled` key exists and is non-empty, SKIP the step and use the pre-filled value. Otherwise, ask the question normally.

  | Step | Question | Pre-filled Key |
  |------|----------|----------------|
  | Step 1 | Symptoms | `pre_filled.symptoms` |
  | Step 2 | Reproduction Steps | `pre_filled.reproduction_steps` |
  | Step 3 | Expected Cause | `pre_filled.expected_cause` |
  | Step 4 | Severity | `pre_filled.severity` |
  | Step 5 | Related Files | `pre_filled.related_files` |
  | Step 6 | Impact Scope | `pre_filled.impact_scope` |

- [ ] FR-6: `init-refactor.md` - ALL Steps 1 through 6 MUST check for pre-filled data before asking. For each step: IF the corresponding `pre_filled` key exists and is non-empty, SKIP the step and use the pre-filled value. Otherwise, ask the question normally.

  | Step | Question | Pre-filled Key |
  |------|----------|----------------|
  | Step 1 | Target | `pre_filled.target` |
  | Step 2 | Problems | `pre_filled.problems` |
  | Step 3 | Goal State | `pre_filled.goal_state` |
  | Step 4 | Behavior Change | `pre_filled.behavior_change` |
  | Step 5 | Test Status | `pre_filled.test_status` |
  | Step 6 | Dependencies | `pre_filled.dependencies` |

### Documentation and Behavior Clarification

- [ ] FR-7: `init-github-issue.md` Step 5 - Update documentation to clarify that pre-filled questions should be SKIPPED (auto-skip), not shown with default values (show-as-default). Remove the "[Extracted from GitHub Issue]" format instruction.
- [ ] FR-8: `init-github-issue.md` Step 5 - Add explicit mapping table showing which `pre_filled` keys map to which init file question steps (per work type).

### Backward Compatibility

- [ ] FR-9: All init files - When `pre_filled` context does NOT exist (direct init without GitHub issue), all questions MUST be asked normally (backward compatibility).
- [ ] FR-10: All init files - When a `pre_filled` field exists but is empty string (`""`), treat it as not available and ask the question.

## Non-Functional Requirements

- [ ] NFR-1: Changes are markdown instruction files only. No executable code is involved.
- [ ] NFR-2: Conditional logic must be expressed as clear, unambiguous natural language instructions that an AI agent can follow.
- [ ] NFR-3: The skip logic must not introduce ambiguity about which questions to ask and which to skip.
- [ ] NFR-4: The deep body analysis extraction heuristics must be expressed as clear instructions with example patterns, so that AI agents can reliably perform the extraction.

## Constraints

- All changes are to `.md` instruction files (commands directory)
- Must maintain full backward compatibility when no `pre_filled` context exists
- The SPEC.md review at Step 3 of `start-new.md` remains the validation checkpoint for all gathered data
- Branch keyword handling is already working correctly via `init-github-issue.md` Step 5 and is NOT part of this fix
- Extraction must be best-effort: not all issue bodies will contain information for every field. Only extract fields with confident matches.

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/init-github-issue.md` | Modify | Enhance Step 4 with deep body analysis; update Step 5 to clarify auto-skip behavior and add field mapping tables |
| `commands/init-feature.md` | Modify | Add conditional skip logic for ALL Steps 1-8 |
| `commands/init-bugfix.md` | Modify | Add conditional skip logic for ALL Steps 1-6 |
| `commands/init-refactor.md` | Modify | Add conditional skip logic for ALL Steps 1-6 |

## Fix Strategy

### Per-File Changes

#### `commands/init-github-issue.md`

**Step 4 (Context Extraction) - Enhanced Deep Body Analysis:**

Add a new sub-step after existing field extraction. The agent MUST analyze the full issue body to extract structured information matching init-xxx question fields. Instructions:

1. After extracting `issue_title`, `issue_body`, `target_version`, determine the `work_type`.
2. Based on `work_type`, scan the issue body for content matching each init-xxx question field using the extraction heuristics defined in FR-2.
3. For each field: if a confident extraction is found, include it in `pre_filled`. If not found or ambiguous, omit the field entirely.
4. The expanded `pre_filled` structure becomes:

```yaml
# For feature work type:
pre_filled:
  goal: "{issue_title}"
  problem: "{extracted or null}"
  core_features: "{extracted or null}"
  additional_features: "{extracted or null}"
  technical_constraints: "{extracted or null}"
  performance: "{extracted or null}"
  security: "{extracted or null}"
  out_of_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"

# For bugfix work type:
pre_filled:
  symptoms: "{issue_title + extracted symptom description}"
  reproduction_steps: "{extracted or null}"
  expected_cause: "{extracted or null}"
  severity: "{extracted or null}"
  related_files: "{extracted or null}"
  impact_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"

# For refactor work type:
pre_filled:
  target: "{issue_title or extracted target}"
  problems: "{extracted or null}"
  goal_state: "{extracted or null}"
  behavior_change: "{extracted or null}"
  test_status: "{extracted or null}"
  dependencies: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: "{milestone_title or null}"
```

Note: `null` fields are omitted from the actual context (not passed as empty strings).

**Step 5 (Route to Init File) - Behavior Clarification:**

- Change item 2 from "Show pre-filled values as defaults" to "SKIP questions where pre_filled data is available"
- Remove the "[Extracted from GitHub Issue]" format instruction
- Add explicit mapping table showing which `pre_filled` keys map to which init file question steps
- Clarify that SPEC.md review at Step 3 of `start-new.md` handles validation

#### `commands/init-feature.md`

Add a conditional block before the Step-by-Step Questions section. For EACH step (1 through 8):

- Before Step 1 (Goal): IF `pre_filled.goal` exists and is non-empty, SKIP Step 1 and use `pre_filled.goal` as the goal. Otherwise, ask Step 1 normally.
- Before Step 2 (Problem): IF `pre_filled.problem` exists and is non-empty, SKIP Step 2 and use `pre_filled.problem` as the problem description. Otherwise, ask Step 2 normally.
- Before Step 3 (Core Features): IF `pre_filled.core_features` exists and is non-empty, SKIP Step 3 and use `pre_filled.core_features`. Otherwise, ask Step 3 normally.
- Before Step 4 (Additional Features): IF `pre_filled.additional_features` exists and is non-empty, SKIP Step 4 and use `pre_filled.additional_features`. Otherwise, ask Step 4 normally.
- Before Step 5 (Technical Constraints): IF `pre_filled.technical_constraints` exists and is non-empty, SKIP Step 5 and use `pre_filled.technical_constraints`. Otherwise, ask Step 5 normally.
- Before Step 6 (Performance): IF `pre_filled.performance` exists and is non-empty, SKIP Step 6 and use `pre_filled.performance`. Otherwise, ask Step 6 normally.
- Before Step 7 (Security): IF `pre_filled.security` exists and is non-empty, SKIP Step 7 and use `pre_filled.security`. Otherwise, ask Step 7 normally.
- Before Step 8 (Out of Scope): IF `pre_filled.out_of_scope` exists and is non-empty, SKIP Step 8 and use `pre_filled.out_of_scope`. Otherwise, ask Step 8 normally.

#### `commands/init-bugfix.md`

Add a conditional block before the Step-by-Step Questions section. For EACH step (1 through 6):

- Before Step 1 (Symptoms): IF `pre_filled.symptoms` exists and is non-empty, SKIP Step 1 and use `pre_filled.symptoms` as the bug symptom description. Otherwise, ask Step 1 normally.
- Before Step 2 (Reproduction Steps): IF `pre_filled.reproduction_steps` exists and is non-empty, SKIP Step 2 and use `pre_filled.reproduction_steps`. Otherwise, ask Step 2 normally.
- Before Step 3 (Expected Cause): IF `pre_filled.expected_cause` exists and is non-empty, SKIP Step 3 and use `pre_filled.expected_cause`. Otherwise, ask Step 3 normally.
- Before Step 4 (Severity): IF `pre_filled.severity` exists and is non-empty, SKIP Step 4 and use `pre_filled.severity`. Otherwise, ask Step 4 normally.
- Before Step 5 (Related Files): IF `pre_filled.related_files` exists and is non-empty, SKIP Step 5 and use `pre_filled.related_files`. Otherwise, ask Step 5 normally.
- Before Step 6 (Impact Scope): IF `pre_filled.impact_scope` exists and is non-empty, SKIP Step 6 and use `pre_filled.impact_scope`. Otherwise, ask Step 6 normally.

#### `commands/init-refactor.md`

Add a conditional block before the Step-by-Step Questions section. For EACH step (1 through 6):

- Before Step 1 (Target): IF `pre_filled.target` exists and is non-empty, SKIP Step 1 and use `pre_filled.target` as the refactoring target description. Otherwise, ask Step 1 normally.
- Before Step 2 (Problems): IF `pre_filled.problems` exists and is non-empty, SKIP Step 2 and use `pre_filled.problems`. Otherwise, ask Step 2 normally.
- Before Step 3 (Goal State): IF `pre_filled.goal_state` exists and is non-empty, SKIP Step 3 and use `pre_filled.goal_state`. Otherwise, ask Step 3 normally.
- Before Step 4 (Behavior Change): IF `pre_filled.behavior_change` exists and is non-empty, SKIP Step 4 and use `pre_filled.behavior_change`. Otherwise, ask Step 4 normally.
- Before Step 5 (Test Status): IF `pre_filled.test_status` exists and is non-empty, SKIP Step 5 and use `pre_filled.test_status`. Otherwise, ask Step 5 normally.
- Before Step 6 (Dependencies): IF `pre_filled.dependencies` exists and is non-empty, SKIP Step 6 and use `pre_filled.dependencies`. Otherwise, ask Step 6 normally.

## Edge Cases

- [ ] EC-1: Partial `pre_filled` - Some fields exist, others do not. Only skip questions for fields that exist and are non-empty. Ask all other questions normally. This is the most common case since issue bodies rarely contain ALL information.
- [ ] EC-2: Empty string `pre_filled` values - `pre_filled.goal = ""` should be treated as not available. Ask the question.
- [ ] EC-3: No `pre_filled` context at all - Normal flow. All questions asked. Full backward compatibility.
- [ ] EC-4: `pre_filled.target_version` set - The target version question (Step 2.6 in `start-new.md`) is already handled separately by the orchestrator. This fix does not change that behavior.
- [ ] EC-5: `pre_filled.branch_keyword` set - Branch creation is already handled by `init-github-issue.md` Step 5 routing. This fix does not change that behavior.
- [ ] EC-6: Ambiguous extraction - Issue body mentions keywords that could match a field but the meaning is unclear. The extraction MUST err on the side of omission (do not include the field) rather than passing incorrect data. The user will be asked the question normally.
- [ ] EC-7: All fields extracted - Issue body is comprehensive and all fields are extracted. All steps are skipped. The user proceeds directly to SPEC.md review at Step 3 of `start-new.md` for validation.
- [ ] EC-8: Extraction produces incorrect data - The SPEC.md review step (Step 3 of `start-new.md`) serves as the safety net. Users can correct any misextracted data during review.

## Out of Scope

- Modifying `start-new.md` orchestrator workflow
- Adding new questions to any init file
- Changing the SPEC.md review step (Step 3) behavior
- Branch keyword generation or branch creation logic
- Target version question handling (already works via `start-new.md` Step 2.6)
- Changing the `AskUserQuestion` tool itself
- Adding user confirmation prompts for extracted data (SPEC.md review handles this)
