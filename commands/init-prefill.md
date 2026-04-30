---
description: Initialize work from a prefill conversation body. Auto-detects work type and extracts pre_filled context.
user-invocable: false
---
# init-prefill Instructions

Instructions for initializing work from a free-form conversation body provided via the `--prefill` option of `/dotclaude:start-new`.

## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).

## Step-by-Step Process

### Step 1: Prefill Input Reception

The `--prefill <text>` argument value is received as the conversation body. This step is the entry point of `init-prefill`; the orchestrator (`start-new.md` Step 0) routes here when row 2 (`--prefill` only) or row 3 (URL + `--prefill` simultaneously) of its branch matrix is matched.

**Inputs**:

| Variable | Source | Description |
|----------|--------|-------------|
| `prefill_body` | `--prefill` flag value | Free-form conversation body. Required. |
| `url_reference` | positional GitHub URL (optional) | Present only on `start-new.md` row 3 (URL + `--prefill` simultaneously). Stored as a literal string here; resolution happens in Step 2.5. |

**Validation**:

- Trim leading/trailing whitespace from `prefill_body`.
- If `prefill_body` is empty or whitespace-only after trimming: this is the **empty prefill fallback** path (Edge Case #1). The orchestrator MUST:
  1. Halt this `init-prefill` execution immediately.
  2. Return control to `start-new.md` Step 1 (Work Type Selection).
  3. Do NOT raise an error; this is a normal fallback to the standard interactive flow.
- If `prefill_body` is non-empty: store it as `prefill_body` and proceed to Step 2.
- If `url_reference` was passed: store it as `url_reference` and forward it to Step 2.5 unchanged. If absent, leave `url_reference` as `null`.

**Note**: Unlike `init-github-issue.md` Step 1, this step does NOT issue any `AskUserQuestion`. The body has already been provided via the command-line flag. No interactive input is required at this stage.

---

### Step 2: Sensitive Data Filtering

Apply sensitive-data filters to `prefill_body` before any extraction or routing.

**TBD: Phase 4** -- See `commands/_prefill-filters.md` for the regex pattern table and application order. Phase 4 will populate this section with:
- The actual filter reference linkage to `commands/_prefill-filters.md`
- The invocation order and pass-through semantics
- The output variable `filtered_prefill_body` that downstream Steps consume

For Phase 2 (current), this step is a **no-op placeholder**. Treat `filtered_prefill_body = prefill_body` (passthrough) and proceed to Step 2.5 with the body unmodified. This is acceptable because Scenario 1 of the Phase 2 manual verification does not include sensitive content.

---

### Step 2.5: GitHub URL Detection & Resolution

Detect GitHub Issue/PR URLs from either the `url_reference` context variable (passed by `start-new.md` Step 0) or by regex-scanning `filtered_prefill_body`, then resolve them per FR-9.

**URL Detection Regex** (identical across `start-new.md` Step 0, this step, and SPEC.md FR-9):

```
https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+
```

The regex captures:

- Group 1 (`issues|pull`): URL kind. `issues` -> issue; `pull` -> pull request.
- The `{owner}`, `{repo}`, and `{number}` substrings are extracted from the matched URL string itself by parsing the path segments after `https://github.com/`.

This step has two scenarios for finding the URL, then a shared fetch / resolution flow.

#### Scenario A: Positional URL Argument

If `url_reference` is non-null (i.e., `start-new.md` Step 0 row 3 forwarded a positional GitHub URL alongside `--prefill`):

1. Skip the body regex scan (Scenario B). The URL has already been resolved by Step 0.
2. Treat `url_reference` as the primary external context source.
3. Proceed directly to **URL Fetch** below.

#### Scenario B: URL Embedded in Prefill Body

If `url_reference` is null at entry:

1. Scan `filtered_prefill_body` for the URL regex above.
2. **No match**: skip Step 2.5 entirely. Set `url_resolution = null` (no URL involved). Proceed to Step 3.
3. **Single match**: set `url_reference = <matched URL>`. Proceed to **URL Fetch**.
4. **Multiple matches**: use the first match as `url_reference`. Preserve the remaining matches as `additional_url_references` (a plain list of strings); they are NOT fetched and remain inline in the body. The final SPEC.md inherits them as plain links.

#### URL Fetch

Use the `gh` CLI to fetch the URL content. The invocation pattern mirrors `init-github-issue.md` Step 2 (line 42-49) so that downstream context extraction can reuse the same JSON shape.

1. Parse `url_reference` to extract `owner`, `repo`, `number`, and `kind` (`issues` or `pull`).
2. Dispatch by `kind`:

```bash
# kind == "issues"
gh issue view {number} --repo {owner}/{repo} --json title,body,labels,milestone

# kind == "pull"
gh pr view {number} --repo {owner}/{repo} --json title,body,labels,milestone
```

3. Always pass `--repo {owner}/{repo}` derived from the URL itself (NOT the current worktree's repo). This handles cross-repo URLs correctly. Same pattern as `init-github-issue.md` Step 2 line 44.
4. On success: store the parsed JSON object as `url_fetch_result`. Proceed to **User Resolution Choice**.

#### Fetch Failure Handling (per FR-9 last clause and AD-6)

If the `gh` CLI fetch fails for any reason (`gh` not installed, not authenticated, 404, 403, network error, malformed JSON):

1. Notify the user via an information message in the configured language (no `AskUserQuestion`):

   ```
   GitHub URL fetch failed: {error_summary}.
   Proceeding with prefill content only; the URL is preserved as a plain reference in SPEC.md.
   ```

2. Set:
   - `url_fetch_result = null`
   - `url_resolution = "fallback_no_fetch"`
   - `url_reference` remains the original URL string (for SPEC.md header preservation per FR-6).
3. Skip the **User Resolution Choice** step entirely (do NOT call `AskUserQuestion`).
4. Proceed to Step 3 with `filtered_prefill_body` unchanged.

**Retry Policy** (AD-6): Single attempt, immediate fallback on failure. Retry policy refinement is deferred to a follow-up issue.

#### User Resolution Choice

If `url_fetch_result` is non-null, ask the user how to combine the URL-derived context with the prefill body using `AskUserQuestion`:

```
Question: "GitHub URL detected ({url_reference}). How should it be combined with the prefill content?"
Header:   "URL Resolution"
Options:
  - { label: "Merge (recommended)",
      description: "Combine URL extraction with prefill. On key conflict, prefill wins." }
  - { label: "URL Override",
      description: "Use URL extraction; on key conflict, URL wins (overrides prefill)." }
  - { label: "URL Ignore",
      description: "Use prefill only; preserve URL as a plain reference link in SPEC.md." }
  - { label: "Cancel",
      description: "Discard prefill entirely and fall back to the normal init flow." }
multiSelect: false
```

**Default**: "Merge (recommended)" -- presented as the first option per AD-4. This is the same default referenced in SPEC.md FR-9: when the user explicitly passed `--prefill`, prefill is the primary input and URL is the secondary context.

#### Option Handling

Each user selection sets `url_resolution` and triggers the corresponding follow-up:

| User Selection | `url_resolution` | Behavior |
|----------------|------------------|----------|
| Merge (recommended) | `merge_prefill_priority` | Apply `init-github-issue.md` Step 4 Deep Body Analysis (line 129-168) to `url_fetch_result.body` to produce `url_pre_filled`. Merge into the prefill-derived `pre_filled` (Step 4 output) with **prefill keys taking priority on conflict**. Step 3 keyword analysis runs on `filtered_prefill_body + url_fetch_result.body` concatenated for higher accuracy. |
| URL Override | `merge_url_priority` | Same as above, but **URL keys take priority on conflict**. |
| URL Ignore | `ignore_url` | Discard `url_fetch_result`. Keep `url_reference` as a plain link only; it appears in `conversation.url_reference` for SPEC.md header but contributes no `pre_filled` data. Step 3 runs on `filtered_prefill_body` only. |
| Cancel | `cancel_prefill` | Halt this `init-prefill` execution. Return control to `start-new.md` Step 1 (Work Type Selection). The user is then prompted: "Would you like to start from the GitHub Issue instead?" If yes, `start-new.md` Step 1 routes to `init-github-issue` with `url_reference` as the issue input. |

After the option is applied, set `url_resolution` and proceed to Step 3 (Work Type Detection) with the resolved context state.

#### Output State

After Step 2.5 completes (or is skipped because no URL was present), the following variables are defined and consumed by Step 3, Step 4, and Step 5:

| Variable | Value When No URL | Value When URL Resolved |
|----------|-------------------|-------------------------|
| `url_reference` | `null` | the original URL string |
| `url_fetch_result` | `null` | parsed `gh` JSON object, or `null` if fetch failed |
| `url_resolution` | `null` | one of `merge_prefill_priority`, `merge_url_priority`, `ignore_url`, `fallback_no_fetch`, `cancel_prefill` |
| `additional_url_references` | `[]` | list of additional matched URLs (Scenario B only) |

#### Edge Cases

- **Multiple URLs in body**: The first regex match wins for fetch. Remaining matches are preserved in body text as plain links (no fetch, no `AskUserQuestion` per additional URL).
- **URL inside code block or quoted text**: The regex still matches inside fenced code blocks or quotes. This is intentional for v0.5.0; refinement is deferred.
- **Pull request URL written as `/pull/`**: The regex group `(issues|pull)` correctly matches `/pull/`. `gh pr view` is invoked, NOT `gh issue view`. (GitHub URLs use the singular `/pull/` form even though the API surface and `gh pr` are plural.)
- **URL points to a different repo than the current worktree**: The fetch invocation uses `--repo {owner}/{repo}` derived from the URL itself, mirroring `init-github-issue.md` Step 2 line 44. Cross-repo references work without additional configuration.
- **URL references a private repo without access**: Fetch fails with 403/404. Falls into Fetch Failure Handling above (`url_resolution = fallback_no_fetch`).

---

### Step 3: Work Type Detection

Unlike `init-github-issue.md` (which uses GitHub labels first, then body keywords), prefill bodies have no labels available. Detection here is **keyword-only**, applied to `filtered_prefill_body`.

**Algorithm**:

1. Scan `filtered_prefill_body` for keywords (case-insensitive):

**Body Analysis Keywords** (case-insensitive):

| Keywords | Work Type |
|----------|-----------|
| fix, bug, error, broken, crash, issue, problem | bugfix |
| add, new, feature, implement, support, enable | feature |
| refactor, clean, improve code, restructure, reorganize | refactor |

(Same keyword set as `init-github-issue.md` Step 3 Body Analysis Keywords, line 80-87.)

2. Aggregate match counts per work type. The work type with the highest count wins.

3. If still ambiguous (tie between two or more work types, or zero matches), ask the user via `AskUserQuestion`:

```
Question: "Based on the prefill content, please confirm the work type:"
Header: "Work Type Confirmation"
Options:
  - { label: "Add/Modify Feature", description: "New feature development or improve existing feature" }
  - { label: "Bug Fix", description: "Fix discovered bugs or errors" }
  - { label: "Refactoring", description: "Improve code structure without changing functionality" }
multiSelect: false
```

**Work Type Mapping from User Confirmation** (same as `init-github-issue.md` line 99-102):

- "Add/Modify Feature" -> feature
- "Bug Fix" -> bugfix
- "Refactoring" -> refactor

Store the detected/confirmed work type as `work_type`.

---

### Step 4: Context Extraction

Analyze `filtered_prefill_body` to extract `pre_filled` keys for the detected `work_type`. The same heuristic tables as `init-github-issue.md` Step 4 (line 135-168) are applied, with the phrase "issue body" replaced by "prefill body" throughout.

**General extraction rule**: For each field below, scan `filtered_prefill_body` for the described patterns. If a confident extraction is found, include the field in `pre_filled`. If not found or ambiguous, OMIT the field entirely (do NOT set to empty string). Omitted fields fall through to the downstream init-xxx and are asked normally via `AskUserQuestion`.

**Feature heuristic table** (when `work_type == "feature"`):

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `goal` | Step 1: Goal | First sentence or first line of prefill body that states an intent ("we want to...", "the goal is...", "...이 필요합니다") |
| `problem` | Step 2: Problem | Paragraph(s) describing the current pain point or limitation |
| `core_features` | Step 3: Core Features | Bulleted lists, "must have", "core", "requirement" sections |
| `additional_features` | Step 4: Additional Features | "Nice to have", "optional", "bonus" sections |
| `technical_constraints` | Step 5: Technical Constraints | "Constraints", "must use", "required stack" mentions |
| `performance` | Step 6: Performance | "Performance", "latency", "throughput", "SLA" mentions |
| `security` | Step 7: Security | "Security", "auth", "encryption", "validation" mentions |
| `out_of_scope` | Step 8: Out of Scope | "Out of scope", "not included", "excluded" sections |

**Bugfix heuristic table** (when `work_type == "bugfix"`):

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `symptoms` | Step 1: Symptoms | Lines describing observed wrong behavior |
| `reproduction_steps` | Step 2: Reproduction Steps | "Steps to reproduce", numbered lists, "how to reproduce", "재현" sections |
| `expected_cause` | Step 3: Expected Cause | "Cause", "root cause", "suspect", "because", "원인", "추정" mentions |
| `severity` | Step 4: Severity | "Critical", "major", "minor", "trivial" keywords |
| `related_files` | Step 5: Related Files | File paths (e.g., `src/...`, `*.ts`), code blocks with filenames |
| `impact_scope` | Step 6: Impact Scope | "Affects", "impact", "related features" mentions |

**Refactor heuristic table** (when `work_type == "refactor"`):

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `target` | Step 1: Target | Mentioned subject of the refactoring (file, module, class) |
| `problems` | Step 2: Problems | "Problem", "issue", "code smell", DRY/SRP/coupling mentions |
| `goal_state` | Step 3: Goal State | "Goal", "expected result", "after refactoring" sections |
| `behavior_change` | Step 4: Behavior Change | "Breaking change", "preserve behavior", "no functional change", "동작은 변경하지 않고" mentions |
| `test_status` | Step 5: Test Status | "Test", "coverage", "tested", "untested" mentions |
| `dependencies` | Step 6: Dependencies | "Depends on", "used by", "dependency", module references |

**Branch Keyword Generation**:

- Extract a short keyword from the most prominent topic of `filtered_prefill_body` (first non-empty significant phrase, deduplicated and stripped of common stopwords).
- Format: `{work_type}/{keyword}`
- Example: prefill body starting with "We need a CSV export feature for the dashboard" -> `feature/csv-export-dashboard`
- Example: prefill body starting with "src/auth/AuthManager.ts 모듈을 리팩터링하고 싶습니다" -> `refactor/auth-manager`
- If extraction is ambiguous, ask the user via `AskUserQuestion` to confirm the branch keyword.

**Target Version**:

- Prefill body has no GitHub milestone available (unlike `init-github-issue.md` line 124-127, where `target_version` may come from milestone).
- `target_version` is OMIT (set to `null`). The standard `start-new.md` Step 2.6 (Target Version Question) will be asked normally.

---

### Step 5: Route to Init File

Based on detected `work_type`, route to the corresponding init file (same routing table as `init-github-issue.md` Step 5, line 174-180):

| Work Type | Init File | Branch Prefix |
|-----------|-----------|---------------|
| feature | `init-feature.md` | `feature/` |
| bugfix | `init-bugfix.md` | `bugfix/` |
| refactor | `init-refactor.md` | `refactor/` |

**Pre-populated Context**:

The same `pre_filled` YAML structure as `init-github-issue.md` line 187-243 is used, with two structural differences:

1. The `github_issue` block is REPLACED by a `conversation` block.
2. The `pre_filled` block keys per work type are identical to those in `init-github-issue.md` (1:1 match with each downstream init-xxx's line 16-31 pre-fill check table).

The `conversation` block schema:

```yaml
conversation:
  source: "prefill"           # fixed literal value
  body: "{filtered_prefill_body}"
  url_reference: "{url_reference or null}"  # populated by Step 2.5 result; null when no URL was passed
  url_resolution: "{url_resolution or null}"  # one of merge_prefill_priority / merge_url_priority / ignore_url / fallback_no_fetch; null when no URL was present
```

**Feature** (`init-feature.md`) -- full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{url_reference or null}"
  url_resolution: "{url_resolution or null}"

pre_filled:
  goal: "{extracted or null}"
  problem: "{extracted or null}"
  core_features: "{extracted or null}"
  additional_features: "{extracted or null}"
  technical_constraints: "{extracted or null}"
  performance: "{extracted or null}"
  security: "{extracted or null}"
  out_of_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: null
```

**Bugfix** (`init-bugfix.md`) -- full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{url_reference or null}"
  url_resolution: "{url_resolution or null}"

pre_filled:
  symptoms: "{extracted or null}"
  reproduction_steps: "{extracted or null}"
  expected_cause: "{extracted or null}"
  severity: "{extracted or null}"
  related_files: "{extracted or null}"
  impact_scope: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: null
```

**Refactor** (`init-refactor.md`) -- full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{url_reference or null}"
  url_resolution: "{url_resolution or null}"

pre_filled:
  target: "{extracted or null}"
  problems: "{extracted or null}"
  goal_state: "{extracted or null}"
  behavior_change: "{extracted or null}"
  test_status: "{extracted or null}"
  dependencies: "{extracted or null}"
  branch_keyword: "{extracted_keyword}"
  target_version: null
```

**Init File Behavior with Pre-filled Context**:

The downstream `init-feature.md` / `init-bugfix.md` / `init-refactor.md` uses the EXISTING pre-fill check infrastructure (line 16-31 of each file). No changes are needed in those files (per AD-7). Specifically:

1. **Branch Creation**: Use `pre_filled.branch_keyword`, follow branch creation steps in `_init-common`. The keyword is pre-filled, not auto-generated.

2. **Questions**: SKIP questions where `pre_filled` data is available and non-empty.
   - For each step in the downstream init-xxx, the existing "Pre-fill Check" line at the top of the step checks the corresponding `pre_filled` key.
   - If present and non-empty, the step uses the pre-filled value directly without asking.
   - If absent or empty, the step asks normally via `AskUserQuestion`.
   - SPEC.md review (Step 3 of `start-new.md`) serves as the validation checkpoint.

3. **Target Version**: Always run `start-new.md` Step 2.6 (no milestone is available from prefill, so `target_version` is always `null` here).

4. **SPEC.md Header** (FR-6 and FR-9): The downstream TechnicalWriter, when drafting SPEC.md, MUST include header lines according to `url_resolution` produced by Step 2.5. The `conversation` block (passed via the YAML payload below) carries `source`, `url_reference`, and `url_resolution`.

   | `url_resolution` | SPEC.md Header Lines |
   |------------------|----------------------|
   | `null` (no URL was present) | `**Source Conversation**: prefill` |
   | `merge_prefill_priority` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference}` |
   | `merge_url_priority` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference}` |
   | `ignore_url` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference} (reference only)` |
   | `fallback_no_fetch` | `**Source Conversation**: prefill`<br>`**Source Issue**: {url_reference} (fetch failed)` |
   | `cancel_prefill` | (not applicable -- this case halts before Step 5) |

   When `conversation.source != "prefill"` (i.e., direct init or `init-github-issue` path), the existing behavior of `init-github-issue.md` line 258-259 (`**Source Issue**: {issue_url}`) applies and `**Source Conversation**` is omitted.

This SPEC.md header guidance is consumed by the TechnicalWriter at SPEC.md drafting time. The downstream `init-feature.md` / `init-bugfix.md` / `init-refactor.md` files themselves do NOT need to be modified to support this; the TechnicalWriter receives the `conversation` block (including `url_resolution`) as part of its context payload and applies the rule above.

**Field Mapping per Work Type**:

The pre_filled key set per work type is unchanged from `init-github-issue.md` line 263-298 (same 8/6/6 keys for feature/bugfix/refactor respectively). Refer to that section for the explicit per-step mapping table; no duplication is added here in order to keep the two files semantically aligned.

---

## Analysis Phase

After context extraction and routing, the downstream init-xxx proceeds to its analysis phase as defined in `init-{type}.md` (same behavior as `init-github-issue.md` line 304-306).

**Note**: The analysis phase should still run to verify requirements against the codebase, but can reference `conversation.body` for context.

---

## Communication Rules

- **DDD Context**: Request domain knowledge based on DDD when context is needed
- **Clarification Required**: If unclear parts or decisions needed, report and wait for user confirmation

---

## Output

1. Filtered prefill body (Step 2 result; Phase 2 = passthrough)
2. Resolved URL reference, if any (Step 2.5 result; Phase 2 = passthrough)
3. Detected work type (feature/bugfix/refactor)
4. Pre-populated context for init workflow (`conversation` block + `pre_filled` block)
5. Worktree created at `../{project_name}-{work_type}-{branch_keyword}` with branch `{work_type}/{branch_keyword}` (via downstream `_init-common`)
6. Route to appropriate `init-xxx.md`
7. Continue normal init workflow from there (with pre-filled values auto-skipping eligible questions)
