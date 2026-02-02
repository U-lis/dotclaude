# Fix init-github flow - Design Document

## Phase Overview

| Phase | Description | Status | Dependencies | Files |
|-------|-------------|--------|--------------|-------|
| 1 | Enhance `init-github-issue.md` with deep body analysis and auto-skip routing | Complete | None | `commands/init-github-issue.md` |
| 2 | Add pre-fill skip logic to `init-feature.md`, `init-bugfix.md`, `init-refactor.md` | Complete | Phase 1 (key name contract) | `commands/init-feature.md`, `commands/init-bugfix.md`, `commands/init-refactor.md` |

---

## Architecture Decisions

### AD-1: Inline Conditional Block Per Step

Each init file step receives an inline conditional check immediately before the AskUserQuestion block. The pattern is:

```
**Pre-fill Check**: IF `pre_filled.{key}` exists and is non-empty, SKIP this step and use the pre-filled value. Otherwise, proceed with the question below.
```

**Rationale**: Placing the check directly before each step keeps the instruction self-contained and unambiguous. An AI agent reading the step sees the skip condition immediately, without needing to cross-reference a separate section.

### AD-2: Top-Level "Pre-filled Data Handling" Section

Each init file (`init-feature.md`, `init-bugfix.md`, `init-refactor.md`) receives a new section titled "Pre-filled Data Handling" placed BEFORE the "Step-by-Step Questions" section. This section:

- Explains that `pre_filled` context may be passed from `init-github-issue.md`
- Defines the general skip rule (IF key exists and is non-empty, SKIP)
- Lists the complete key-to-step mapping table for that work type
- States the backward compatibility rule (no `pre_filled` = ask all questions)

**Rationale**: Provides a single reference point for the skip contract. The inline checks (AD-1) are the execution-level instructions; this section is the overview-level documentation ensuring the agent understands the full picture before processing steps.

### AD-3: Heuristic Table Format for Deep Body Analysis

In `init-github-issue.md` Step 4, the deep body analysis extraction instructions use a per-work-type heuristic table with three columns: `Pre-filled Key`, `Maps to Step`, and `Extraction Heuristic`. The heuristic column contains concrete patterns and keywords the AI agent should search for in the issue body.

**Rationale**: Tables are scannable and unambiguous. Concrete keyword lists (e.g., "Steps to reproduce", numbered lists, "how to reproduce") give the AI agent specific textual patterns to match, reducing extraction errors.

### AD-4: Replace "show-as-default" with "auto-skip" in Step 5

In `init-github-issue.md` Step 5 item 2, the current instruction says "Show pre-filled values as defaults" with a `[Extracted from GitHub Issue]` format. This is replaced with "SKIP questions where pre_filled data is available". The per-question confirmation is unnecessary because SPEC.md validation at Step 3 of `start-new.md` serves as the correctness checkpoint.

**Rationale**: Auto-skip eliminates redundant user interaction. The downstream SPEC.md review step already provides a validation checkpoint where users can correct any misextracted data, making per-question confirmation unnecessary overhead.

---

## Phase 1: Enhance init-github-issue.md

### Objective

Modify `commands/init-github-issue.md` to perform deep body analysis extracting ALL possible init-xxx fields, and update routing behavior from "show-as-default" to "auto-skip".

### Prerequisites

- None (first phase)

### Instructions

#### 1.1: Add Deep Body Analysis Sub-section to Step 4

**Target**: `commands/init-github-issue.md`, Step 4 (Context Extraction), after the existing "Branch Keyword Generation" and "Target Version Extraction" sub-sections.

Add a new sub-section titled "Deep Body Analysis" containing:

1. An introductory paragraph instructing the agent to analyze the full `issue_body` text to extract structured data for ALL init-xxx question fields, not just `goal` and `problem`.

2. A general extraction rule: "For each field below, scan the issue body for the described patterns. If a confident extraction is found, include the field in `pre_filled`. If not found or ambiguous, OMIT the field entirely (do not set to empty string)."

3. Three heuristic tables (one per work type), each with columns: `Pre-filled Key | Maps to Step | Extraction Heuristic`. Use the exact tables from SPEC.md FR-2:

   **Feature heuristic table** (8 rows):
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

   **Bugfix heuristic table** (6 rows):
   | Pre-filled Key | Maps to Step | Extraction Heuristic |
   |----------------|--------------|----------------------|
   | `symptoms` | Step 1: Symptoms | Issue title + first paragraph of body |
   | `reproduction_steps` | Step 2: Reproduction Steps | "Steps to reproduce", numbered lists, "how to reproduce" sections |
   | `expected_cause` | Step 3: Expected Cause | "Cause", "root cause", "suspect", "because" mentions |
   | `severity` | Step 4: Severity | "Critical", "major", "minor", "trivial" keywords; label-based severity |
   | `related_files` | Step 5: Related Files | File paths (e.g., `src/...`, `*.ts`), code blocks with filenames |
   | `impact_scope` | Step 6: Impact Scope | "Affects", "impact", "related features" mentions |

   **Refactor heuristic table** (6 rows):
   | Pre-filled Key | Maps to Step | Extraction Heuristic |
   |----------------|--------------|----------------------|
   | `target` | Step 1: Target | Issue title, "target", "refactor" subject |
   | `problems` | Step 2: Problems | "Problem", "issue", "code smell", DRY/SRP/coupling mentions |
   | `goal_state` | Step 3: Goal State | "Goal", "expected result", "after refactoring" sections |
   | `behavior_change` | Step 4: Behavior Change | "Breaking change", "preserve behavior", "no functional change" mentions |
   | `test_status` | Step 5: Test Status | "Test", "coverage", "tested", "untested" mentions |
   | `dependencies` | Step 6: Dependencies | "Depends on", "used by", "dependency", module references |

#### 1.2: Update pre_filled YAML Blocks in Step 5

**Target**: `commands/init-github-issue.md`, Step 5 (Route to Init File), the "Pre-populated Context" sub-section.

Replace the single `pre_filled` YAML block with three work-type-specific YAML blocks showing ALL possible keys per work type. Use the expanded structures from SPEC.md "Fix Strategy" section. Each YAML block includes:
- All work-type-specific field keys (with `"{extracted or null}"` placeholder values)
- The shared keys `branch_keyword` and `target_version`
- A note that `null` fields are omitted from actual context

#### 1.3: Rewrite Step 5 Item 2 from "show-as-default" to "auto-skip"

**Target**: `commands/init-github-issue.md`, Step 5 (Route to Init File), the "Init File Behavior with Pre-filled Context" sub-section, item 2.

Current text (item 2):
```
2. **Questions**: Show pre-filled values as defaults
   - Format: "[Extracted from GitHub Issue] {value}"
   - User can modify if needed
```

Replace with:
```
2. **Questions**: SKIP questions where `pre_filled` data is available
   - If a `pre_filled` key exists and is non-empty for a question, that question is auto-skipped
   - The pre-filled value is used directly without user confirmation
   - SPEC.md review (Step 3 of start-new.md) serves as the validation checkpoint
```

#### 1.4: Add Field Mapping Tables to Step 5

**Target**: `commands/init-github-issue.md`, Step 5 (Route to Init File), after the "Init File Behavior with Pre-filled Context" sub-section.

Add a new sub-section titled "Field Mapping per Work Type" containing three tables (one per work type). Each table maps `pre_filled` keys to init file step numbers:

**Feature** (`init-feature.md`):
| Pre-filled Key | Init File Step |
|----------------|----------------|
| `goal` | Step 1 |
| `problem` | Step 2 |
| `core_features` | Step 3 |
| `additional_features` | Step 4 |
| `technical_constraints` | Step 5 |
| `performance` | Step 6 |
| `security` | Step 7 |
| `out_of_scope` | Step 8 |

**Bugfix** (`init-bugfix.md`):
| Pre-filled Key | Init File Step |
|----------------|----------------|
| `symptoms` | Step 1 |
| `reproduction_steps` | Step 2 |
| `expected_cause` | Step 3 |
| `severity` | Step 4 |
| `related_files` | Step 5 |
| `impact_scope` | Step 6 |

**Refactor** (`init-refactor.md`):
| Pre-filled Key | Init File Step |
|----------------|----------------|
| `target` | Step 1 |
| `problems` | Step 2 |
| `goal_state` | Step 3 |
| `behavior_change` | Step 4 |
| `test_status` | Step 5 |
| `dependencies` | Step 6 |

### Completion Checklist

- [x] Step 4 contains "Deep Body Analysis" sub-section with introductory paragraph, general extraction rule, and three heuristic tables (feature: 8 rows, bugfix: 6 rows, refactor: 6 rows): Verified in `commands/init-github-issue.md`:122-161
- [x] Step 5 "Pre-populated Context" shows three work-type-specific YAML blocks with all possible keys: Verified in `commands/init-github-issue.md`:179-236
- [x] Step 5 item 2 reads "SKIP questions where `pre_filled` data is available" (not "show-as-default"): Verified in `commands/init-github-issue.md`:243
- [x] Step 5 item 2 no longer contains "[Extracted from GitHub Issue]" format instruction: Verified via grep (zero matches)
- [x] Step 5 contains "Field Mapping per Work Type" sub-section with three mapping tables: Verified in `commands/init-github-issue.md`:255-293
- [x] Step 5 item 3 (Target Version) and item 4 (SPEC.md) are unchanged: Verified in `commands/init-github-issue.md`:248-253 (identical to original)
- [x] All other sections of `init-github-issue.md` are unchanged (Steps 1-3, Analysis Phase, Communication Rules, Output): Verified via git diff (no changes outside Step 4 Deep Body Analysis and Step 5 updates)

### Notes

- The heuristic tables define extraction INTENT, not rigid algorithms. The AI agent performing extraction uses judgment guided by the heuristic patterns.
- The "omit if not confident" rule (FR-3) is critical. Over-extraction leads to incorrect pre-fills that users must correct at SPEC.md review. Under-extraction merely asks the user a question they could have skipped.

---

## Phase 2: Add Skip Logic to init-feature.md, init-bugfix.md, init-refactor.md

### Objective

Add a "Pre-filled Data Handling" section and inline pre-fill checks to every step in `init-feature.md` (8 steps), `init-bugfix.md` (6 steps), and `init-refactor.md` (6 steps).

### Prerequisites

- Phase 1 completed (the `pre_filled` key names and contract must be finalized in `init-github-issue.md` before the init files can reference them)

### Instructions

#### 2.1: Add "Pre-filled Data Handling" Section to init-feature.md

**Target**: `commands/init-feature.md`, insert a new section AFTER the frontmatter heading block and BEFORE "## Step-by-Step Questions".

Add a section titled "## Pre-filled Data Handling" containing:

1. An explanatory paragraph: "When invoked from `init-github-issue.md`, a `pre_filled` context may be provided containing data extracted from the GitHub issue. For each step below, check whether the corresponding `pre_filled` key exists and is non-empty. If it does, SKIP the step and use the pre-filled value. If it does not exist, or is an empty string, ask the question normally."

2. A backward compatibility note: "When no `pre_filled` context is available (direct init without GitHub issue), all questions are asked normally."

3. A key-to-step mapping table:

   | Pre-filled Key | Step | Question |
   |----------------|------|----------|
   | `pre_filled.goal` | Step 1 | Goal |
   | `pre_filled.problem` | Step 2 | Problem |
   | `pre_filled.core_features` | Step 3 | Core Features |
   | `pre_filled.additional_features` | Step 4 | Additional Features |
   | `pre_filled.technical_constraints` | Step 5 | Technical Constraints |
   | `pre_filled.performance` | Step 6 | Performance |
   | `pre_filled.security` | Step 7 | Security |
   | `pre_filled.out_of_scope` | Step 8 | Out of Scope |

#### 2.2: Add Inline Pre-fill Check to Each Step in init-feature.md

**Target**: `commands/init-feature.md`, Steps 1 through 8.

For EACH step, insert the following block immediately after the step heading (`### Step N: {Name}`) and BEFORE the AskUserQuestion code block:

```
**Pre-fill Check**: IF `pre_filled.{key}` exists and is non-empty, SKIP this step and use the pre-filled value as the {description}. Otherwise, proceed with the question below.
```

Specific per-step instructions:

| Step | Key | Skip Description |
|------|-----|------------------|
| Step 1 | `pre_filled.goal` | "use the pre-filled value as the goal" |
| Step 2 | `pre_filled.problem` | "use the pre-filled value as the problem description" |
| Step 3 | `pre_filled.core_features` | "use the pre-filled value as the core features list" |
| Step 4 | `pre_filled.additional_features` | "use the pre-filled value as the additional features" |
| Step 5 | `pre_filled.technical_constraints` | "use the pre-filled value as the technical constraints" |
| Step 6 | `pre_filled.performance` | "use the pre-filled value as the performance requirements" |
| Step 7 | `pre_filled.security` | "use the pre-filled value as the security considerations" |
| Step 8 | `pre_filled.out_of_scope` | "use the pre-filled value as the out-of-scope items" |

#### 2.3: Add "Pre-filled Data Handling" Section to init-bugfix.md

**Target**: `commands/init-bugfix.md`, insert a new section AFTER the frontmatter heading block and BEFORE "## Step-by-Step Questions".

Add a section titled "## Pre-filled Data Handling" containing:

1. Same explanatory paragraph as 2.1 (adapted: "When invoked from `init-github-issue.md`...").
2. Same backward compatibility note as 2.1.
3. A key-to-step mapping table:

   | Pre-filled Key | Step | Question |
   |----------------|------|----------|
   | `pre_filled.symptoms` | Step 1 | Symptoms |
   | `pre_filled.reproduction_steps` | Step 2 | Reproduction Steps |
   | `pre_filled.expected_cause` | Step 3 | Expected Cause |
   | `pre_filled.severity` | Step 4 | Severity |
   | `pre_filled.related_files` | Step 5 | Related Files |
   | `pre_filled.impact_scope` | Step 6 | Impact Scope |

#### 2.4: Add Inline Pre-fill Check to Each Step in init-bugfix.md

**Target**: `commands/init-bugfix.md`, Steps 1 through 6.

Same pattern as 2.2. Per-step instructions:

| Step | Key | Skip Description |
|------|-----|------------------|
| Step 1 | `pre_filled.symptoms` | "use the pre-filled value as the bug symptom description" |
| Step 2 | `pre_filled.reproduction_steps` | "use the pre-filled value as the reproduction steps" |
| Step 3 | `pre_filled.expected_cause` | "use the pre-filled value as the expected cause" |
| Step 4 | `pre_filled.severity` | "use the pre-filled value as the severity level" |
| Step 5 | `pre_filled.related_files` | "use the pre-filled value as the related files" |
| Step 6 | `pre_filled.impact_scope` | "use the pre-filled value as the impact scope" |

#### 2.5: Add "Pre-filled Data Handling" Section to init-refactor.md

**Target**: `commands/init-refactor.md`, insert a new section AFTER the frontmatter heading block and BEFORE "## Step-by-Step Questions".

Add a section titled "## Pre-filled Data Handling" containing:

1. Same explanatory paragraph as 2.1 (adapted: "When invoked from `init-github-issue.md`...").
2. Same backward compatibility note as 2.1.
3. A key-to-step mapping table:

   | Pre-filled Key | Step | Question |
   |----------------|------|----------|
   | `pre_filled.target` | Step 1 | Target |
   | `pre_filled.problems` | Step 2 | Problems |
   | `pre_filled.goal_state` | Step 3 | Goal State |
   | `pre_filled.behavior_change` | Step 4 | Behavior Change |
   | `pre_filled.test_status` | Step 5 | Test Status |
   | `pre_filled.dependencies` | Step 6 | Dependencies |

#### 2.6: Add Inline Pre-fill Check to Each Step in init-refactor.md

**Target**: `commands/init-refactor.md`, Steps 1 through 6.

Same pattern as 2.2. Per-step instructions:

| Step | Key | Skip Description |
|------|-----|------------------|
| Step 1 | `pre_filled.target` | "use the pre-filled value as the refactoring target" |
| Step 2 | `pre_filled.problems` | "use the pre-filled value as the current problems" |
| Step 3 | `pre_filled.goal_state` | "use the pre-filled value as the goal state" |
| Step 4 | `pre_filled.behavior_change` | "use the pre-filled value as the behavior change policy" |
| Step 5 | `pre_filled.test_status` | "use the pre-filled value as the test status" |
| Step 6 | `pre_filled.dependencies` | "use the pre-filled value as the dependencies" |

### Completion Checklist

- [x] `init-feature.md` has "Pre-filled Data Handling" section with mapping table (8 rows) before "Step-by-Step Questions": Verified in `commands/init-feature.md`:9-24
- [x] `init-feature.md` Steps 1-8 each have a "Pre-fill Check" block with correct key and skip description: Verified in `commands/init-feature.md`:32,42,52,62,75,92,107,126
- [x] `init-bugfix.md` has "Pre-filled Data Handling" section with mapping table (6 rows) before "Step-by-Step Questions": Verified in `commands/init-bugfix.md`:9-22
- [x] `init-bugfix.md` Steps 1-6 each have a "Pre-fill Check" block with correct key and skip description: Verified in `commands/init-bugfix.md`:30,40,50,69,88,101
- [x] `init-refactor.md` has "Pre-filled Data Handling" section with mapping table (6 rows) before "Step-by-Step Questions": Verified in `commands/init-refactor.md`:9-22
- [x] `init-refactor.md` Steps 1-6 each have a "Pre-fill Check" block with correct key and skip description: Verified in `commands/init-refactor.md`:30,40,61,71,86,103
- [x] All pre-fill keys match exactly the keys defined in Phase 1 `init-github-issue.md` heuristic tables: Verified via cross-reference (feature: 8/8, bugfix: 6/6, refactor: 6/6)
- [x] No existing content in any init file is removed or altered (only additions): Verified via git diff (all changes are additions only)
- [x] Analysis Phase, Branch Keyword, SPEC.md Content, Communication Rules, and Output sections are unchanged in all three files: Verified via git diff and grep

### Notes

- The inline check pattern MUST be consistent across all three files. Use the exact wording: "**Pre-fill Check**: IF `pre_filled.{key}` exists and is non-empty, SKIP this step and use the pre-filled value as the {description}. Otherwise, proceed with the question below."
- The "Pre-filled Data Handling" section is a reference; the inline checks are the executable instructions. Both must be present.

---

## Test Criteria

### Phase 1 Test Cases

#### TC-1.1: Deep Body Analysis Sub-section Exists
- **Verify**: `commands/init-github-issue.md` Step 4 contains a "Deep Body Analysis" sub-section
- **Check**: Sub-section contains introductory paragraph, general extraction rule, and three heuristic tables
- **Check**: Feature table has 8 rows (goal, problem, core_features, additional_features, technical_constraints, performance, security, out_of_scope)
- **Check**: Bugfix table has 6 rows (symptoms, reproduction_steps, expected_cause, severity, related_files, impact_scope)
- **Check**: Refactor table has 6 rows (target, problems, goal_state, behavior_change, test_status, dependencies)

#### TC-1.2: Expanded YAML Blocks
- **Verify**: Step 5 "Pre-populated Context" contains three separate YAML blocks (feature, bugfix, refactor)
- **Check**: Feature YAML contains keys: goal, problem, core_features, additional_features, technical_constraints, performance, security, out_of_scope, branch_keyword, target_version
- **Check**: Bugfix YAML contains keys: symptoms, reproduction_steps, expected_cause, severity, related_files, impact_scope, branch_keyword, target_version
- **Check**: Refactor YAML contains keys: target, problems, goal_state, behavior_change, test_status, dependencies, branch_keyword, target_version

#### TC-1.3: Auto-skip Replaces Show-as-default
- **Verify**: Step 5 item 2 contains "SKIP questions where `pre_filled` data is available"
- **Check**: No occurrence of "Show pre-filled values as defaults" in the file
- **Check**: No occurrence of "[Extracted from GitHub Issue]" in the file

#### TC-1.4: Field Mapping Tables Present
- **Verify**: Step 5 contains "Field Mapping per Work Type" sub-section
- **Check**: Three mapping tables present (feature, bugfix, refactor) with correct key-to-step mappings

#### TC-1.5: No Unintended Changes
- **Verify**: Steps 1, 2, 3 are unchanged
- **Verify**: Analysis Phase, Communication Rules, Output sections are unchanged
- **Verify**: Step 5 items 1 (Branch Creation), 3 (Target Version), 4 (SPEC.md) are unchanged

### Phase 2 Test Cases

#### TC-2.1: Pre-filled Data Handling Section - init-feature.md
- **Verify**: Section exists between frontmatter heading and "Step-by-Step Questions"
- **Check**: Contains explanatory paragraph mentioning `init-github-issue.md` and skip rule
- **Check**: Contains backward compatibility note
- **Check**: Contains mapping table with 8 rows matching Phase 1 key names exactly

#### TC-2.2: Inline Pre-fill Checks - init-feature.md
- **Verify**: All 8 steps (Steps 1-8) have "Pre-fill Check" blocks
- **Check**: Each block references the correct `pre_filled.{key}` for that step
- **Check**: Each block appears AFTER step heading, BEFORE AskUserQuestion code block
- **Check**: Wording follows the standard pattern

#### TC-2.3: Pre-filled Data Handling Section - init-bugfix.md
- **Verify**: Section exists between frontmatter heading and "Step-by-Step Questions"
- **Check**: Contains mapping table with 6 rows matching Phase 1 key names exactly

#### TC-2.4: Inline Pre-fill Checks - init-bugfix.md
- **Verify**: All 6 steps (Steps 1-6) have "Pre-fill Check" blocks
- **Check**: Each block references the correct `pre_filled.{key}` for that step

#### TC-2.5: Pre-filled Data Handling Section - init-refactor.md
- **Verify**: Section exists between frontmatter heading and "Step-by-Step Questions"
- **Check**: Contains mapping table with 6 rows matching Phase 1 key names exactly

#### TC-2.6: Inline Pre-fill Checks - init-refactor.md
- **Verify**: All 6 steps (Steps 1-6) have "Pre-fill Check" blocks
- **Check**: Each block references the correct `pre_filled.{key}` for that step

#### TC-2.7: Key Name Consistency Across All Files
- **Verify**: Every `pre_filled` key referenced in init-feature.md appears in Phase 1 feature heuristic table
- **Verify**: Every `pre_filled` key referenced in init-bugfix.md appears in Phase 1 bugfix heuristic table
- **Verify**: Every `pre_filled` key referenced in init-refactor.md appears in Phase 1 refactor heuristic table
- **Check**: No typos or case differences in key names

#### TC-2.8: Backward Compatibility
- **Verify**: No existing content removed from any init file
- **Verify**: Analysis Phase sections unchanged in all three files
- **Verify**: Branch Keyword sections unchanged in all three files
- **Verify**: SPEC.md Content sections unchanged in all three files
- **Verify**: Output sections unchanged in all three files

### Edge Case Test Criteria

#### TC-E.1: Partial Pre-fill
- **Scenario**: `pre_filled` contains only `goal` and `problem`, other keys absent
- **Expected**: Steps 1-2 skipped, Steps 3-8 asked normally (init-feature.md)

#### TC-E.2: Empty String Value
- **Scenario**: `pre_filled.goal = ""`
- **Expected**: Step 1 is NOT skipped (empty string treated as not available)

#### TC-E.3: No Pre-filled Context
- **Scenario**: Init file invoked directly (not via init-github-issue.md), no `pre_filled` context
- **Expected**: All questions asked normally, identical to current behavior

#### TC-E.4: All Fields Extracted
- **Scenario**: `pre_filled` contains all keys for the work type with non-empty values
- **Expected**: All steps skipped, user proceeds directly to SPEC.md review
