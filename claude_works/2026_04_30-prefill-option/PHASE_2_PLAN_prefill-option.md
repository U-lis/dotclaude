# PHASE 2: init-prefill.md 신규 작성 (핵심 라우터)

## Phase Metadata

- **Status**: Complete
- **Type**: sequential
- **Dependencies**: 1
- **Effort**: large

---

## Objective

`commands/init-prefill.md`를 신규 작성하여 prefill 본문을 입력으로 받아 work_type을 자동 감지하고, 각 init-xxx의 `pre_filled` 인프라에 컨텍스트를 전달하는 라우터를 구현한다. 또한 Phase 1에서 작성한 `start-new.md` Step 0의 placeholder를 실제 `Skill("dotclaude:init-prefill")` 호출로 치환한다.

본 phase는 본 작업의 핵심 산출물이며, FR-1 / FR-2 / FR-3 / FR-4 / FR-5 / FR-6 모두를 충족한다.

---

## Files to Create

| Path | Purpose |
|------|---------|
| `commands/init-prefill.md` | prefill 본문 → work_type 감지 → pre_filled 추출 → init-xxx 라우팅 (internal command, `user-invocable: false`) |

## Files to Modify

| Path | Change |
|------|--------|
| `commands/start-new.md` | Phase 1에서 작성한 Step 0 placeholder를 실제 `Skill("dotclaude:init-prefill")` 호출로 치환 |

---

## Detailed Tasks

### Task 2.1: frontmatter 작성

`commands/init-prefill.md` 파일 최상단에 frontmatter:

```markdown
---
description: Initialize work from a prefill conversation body. Auto-detects work type and extracts pre_filled context.
user-invocable: false
---
# init-prefill Instructions

Instructions for initializing work from a free-form conversation body provided via the `--prefill` option of `/dotclaude:start-new`.
```

- [ ] `description` 필드는 marketplace에 표시될 수 있으므로 간결하고 정확하게 작성
- [ ] `user-invocable: false`로 internal command 명시 (`init-github-issue.md` line 3과 동일)

### Task 2.2: Language 섹션 작성

`init-github-issue.md` line 9-14와 동일한 Language 섹션 추가:

```markdown
## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
- If no language was provided at session start, default to English (en_US).
```

- [ ] 정확히 동일 문구로 복사 (정합성)

### Task 2.3: Step 1 - Prefill Input Reception 작성

`### Step 1: Prefill Input Reception` 섹션:

- [ ] `--prefill` 인자 본문 텍스트 수신 흐름 설명
- [ ] 빈 본문 처리: `--prefill ""` 또는 trimmed 결과가 빈 문자열인 경우 → 일반 init flow로 폴백 (Edge Case #1)
  - 폴백 동작: `start-new.md`의 Step 1 (Work Type Selection)으로 사용자에게 전달. 본 init-prefill 진행 중단.
- [ ] FR-9 Scenario A 입력 수용: `start-new.md` Step 0가 URL을 함께 전달했을 경우, URL을 별도 컨텍스트 변수 `url_reference`로 보존 (Step 2.5에서 사용)

```markdown
### Step 1: Prefill Input Reception

The `--prefill <text>` argument value is received as the conversation body.

**Validation**:
- If body is empty or whitespace-only after trimming: Fall back to the normal init flow (`start-new.md` Step 1, Work Type Selection). Halt this init-prefill execution.
- Store the body as `prefill_body`.
- If `start-new.md` Step 0 also passed a positional GitHub URL, store it as `url_reference` (used in Step 2.5).
```

### Task 2.4: Step 2 - Sensitive Data Filtering placeholder 작성

`### Step 2: Sensitive Data Filtering` 섹션:

- [ ] Phase 4에서 채워질 placeholder 명시
- [ ] 본 phase에서는 다음 형태로 placeholder 작성:

```markdown
### Step 2: Sensitive Data Filtering

Apply sensitive-data filters to `prefill_body` before any extraction.

**TBD: Phase 4** — See `commands/_prefill-filters.md` for the regex pattern table and application order. Phase 4 will populate this section with the actual reference linkage and filtering invocation. For now, treat this as a no-op placeholder; the body proceeds to Step 2.5 unfiltered.
```

- [ ] Phase 4가 본 placeholder를 채울 수 있도록 명확한 마커 (`TBD: Phase 4`) 포함

### Task 2.5: Step 2.5 - GitHub URL Detection & Resolution placeholder 작성

`### Step 2.5: GitHub URL Detection & Resolution` 섹션:

- [ ] Phase 3에서 채워질 placeholder 명시
- [ ] 본 phase에서는 다음 형태로 placeholder 작성:

```markdown
### Step 2.5: GitHub URL Detection & Resolution

Detect GitHub Issue/PR URLs in the prefill body or from the `url_reference` context variable, then resolve them per FR-9.

**TBD: Phase 3** — Phase 3 will populate this section with:
- URL regex detection (`https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`)
- Two scenarios (A: positional URL arg + --prefill, B: URL embedded in body)
- gh CLI fetch invocation
- AskUserQuestion with 4 options (Merge / URL Override / URL Ignore / Cancel)
- Fallback handling on fetch failure

For now, this step is a no-op placeholder; execution proceeds to Step 3 with `url_reference` (if any) preserved as a literal reference.
```

### Task 2.6: Step 3 - Work Type Detection 작성

`### Step 3: Work Type Detection` 섹션:

- [ ] `init-github-issue.md` Step 3 (line 65-103) 패턴을 prefill 본문 분석으로 적응
- [ ] Label 검사는 prefill에서는 적용 외 (label이 없음). 본문 키워드 분석만 수행
- [ ] Body Analysis Keywords 표는 `init-github-issue.md` line 80-87과 동일하게 사용

```markdown
### Step 3: Work Type Detection

Unlike `init-github-issue.md` (which uses GitHub labels first), prefill bodies have no labels. Detection is keyword-based on the filtered `prefill_body`.

**Algorithm**:

1. Scan `prefill_body` for keywords (case-insensitive):

| Keywords | Work Type |
|----------|-----------|
| fix, bug, error, broken, crash, issue, problem | bugfix |
| add, new, feature, implement, support, enable | feature |
| refactor, clean, improve code, restructure, reorganize | refactor |

(Same table as `init-github-issue.md` Step 3 Body Analysis Keywords, line 80-87.)

2. Aggregate match counts per work type. The work type with the highest count wins.

3. If still ambiguous (tie or no match), ask user via AskUserQuestion:

   - question: "Based on the prefill content, please confirm the work type:"
   - header: "Work Type Confirmation"
   - options:
     - { label: "Add/Modify Feature", description: "New feature development or improve existing feature" }
     - { label: "Bug Fix", description: "Fix discovered bugs or errors" }
     - { label: "Refactoring", description: "Improve code structure without changing functionality" }
   - multiSelect: false

**Work Type Mapping from User Confirmation** (same as `init-github-issue.md` line 99-102):
- "Add/Modify Feature" -> feature
- "Bug Fix" -> bugfix
- "Refactoring" -> refactor

Store the detected/confirmed work type as `work_type`.
```

- [ ] 키워드 표는 init-github-issue.md line 84-86과 자구까지 일치
- [ ] 모호 시 AskUserQuestion 분기는 init-github-issue.md line 88-97과 동일 패턴

### Task 2.7: Step 4 - Context Extraction 작성

`### Step 4: Context Extraction` 섹션:

- [ ] `init-github-issue.md` Step 4 line 106-168을 prefill 본문 분석으로 적응
- [ ] 3개 heuristic 표 (feature / bugfix / refactor)를 그대로 reuse하되 "issue body" → "prefill body"로 표현 변경
- [ ] Branch Keyword Generation: `init-github-issue.md` line 119-122 적응 — issue title이 없으므로 prefill body 첫 라인 또는 사용자 제공 keyword 사용

```markdown
### Step 4: Context Extraction

Analyze `prefill_body` to extract `pre_filled` keys for the detected `work_type`. The same heuristic tables as `init-github-issue.md` Step 4 (line 135-168) are applied, with "issue body" replaced by "prefill body".

**General extraction rule**: For each field below, scan `prefill_body` for the described patterns. If a confident extraction is found, include the field in `pre_filled`. If not found or ambiguous, OMIT the field entirely (do not set to empty string). Omitted fields are asked normally by the downstream init-xxx.

**Feature heuristic table** (when `work_type == "feature"`):

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `goal` | Step 1: Goal | First sentence or first line of prefill body that states an intent ("we want to...", "the goal is...") |
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
| `reproduction_steps` | Step 2: Reproduction Steps | "Steps to reproduce", numbered lists, "how to reproduce" sections |
| `expected_cause` | Step 3: Expected Cause | "Cause", "root cause", "suspect", "because" mentions |
| `severity` | Step 4: Severity | "Critical", "major", "minor", "trivial" keywords |
| `related_files` | Step 5: Related Files | File paths (e.g., `src/...`, `*.ts`), code blocks with filenames |
| `impact_scope` | Step 6: Impact Scope | "Affects", "impact", "related features" mentions |

**Refactor heuristic table** (when `work_type == "refactor"`):

| Pre-filled Key | Maps to Step | Extraction Heuristic |
|----------------|--------------|----------------------|
| `target` | Step 1: Target | Mentioned subject of the refactoring (file, module, class) |
| `problems` | Step 2: Problems | "Problem", "issue", "code smell", DRY/SRP/coupling mentions |
| `goal_state` | Step 3: Goal State | "Goal", "expected result", "after refactoring" sections |
| `behavior_change` | Step 4: Behavior Change | "Breaking change", "preserve behavior", "no functional change" mentions |
| `test_status` | Step 5: Test Status | "Test", "coverage", "tested", "untested" mentions |
| `dependencies` | Step 6: Dependencies | "Depends on", "used by", "dependency", module references |

**Branch Keyword Generation**:
- Extract a short keyword from the most prominent topic of `prefill_body` (first non-empty significant phrase, deduplicated and stripped of stopwords).
- Format: `{work_type}/{keyword}`
- Example: prefill body starting with "We need a CSV export feature for the dashboard" -> `feature/csv-export-dashboard`
- If extraction is ambiguous, ask the user via AskUserQuestion to confirm the branch keyword.

**Target Version**:
- Prefill body has no GitHub milestone. `target_version` is OMIT (the standard `start-new.md` Step 2.6 will ask).
```

### Task 2.8: Step 5 - Route to Init File 작성

`### Step 5: Route to Init File` 섹션:

- [ ] `init-github-issue.md` Step 5 (line 172-298)를 그대로 패턴으로 사용
- [ ] **차이점 1**: `github_issue` 블록을 omit하고 `conversation` 블록을 추가
- [ ] **차이점 2**: SPEC.md 헤더에 `**Source Conversation**: prefill` 표기 (FR-6)
- [ ] **차이점 3**: URL이 함께 입력되었고 사용자가 URL을 무시하지 않은 경우, 추가로 `**Source Issue**: {url}` 표기

```markdown
### Step 5: Route to Init File

Based on detected `work_type`, route to the corresponding init file (same routing table as `init-github-issue.md` Step 5, line 174-180):

| Work Type | Init File | Branch Prefix |
|-----------|-----------|---------------|
| feature | `init-feature.md` | `feature/` |
| bugfix | `init-bugfix.md` | `bugfix/` |
| refactor | `init-refactor.md` | `refactor/` |

**Pre-populated Context**:

The same `pre_filled` YAML structure as `init-github-issue.md` line 187-243 is used, with the following differences:

1. The `github_issue` block is REPLACED by a `conversation` block:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{github_url or null}"  # populated by Step 2.5 result
```

2. The `pre_filled` block keys are identical to those in `init-github-issue.md` for each work type.

**Feature** (`init-feature.md`) — full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{github_url or null}"

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

**Bugfix** (`init-bugfix.md`) — full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{github_url or null}"

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

**Refactor** (`init-refactor.md`) — full payload:

```yaml
conversation:
  source: "prefill"
  body: "{filtered_prefill_body}"
  url_reference: "{github_url or null}"

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

The downstream init-feature.md / init-bugfix.md / init-refactor.md uses the existing pre-fill check infrastructure (line 16-31 of each file). No changes are needed in those files. Specifically:

1. **Branch Creation**: Use `pre_filled.branch_keyword`, follow branch creation steps in `_init-common`.
2. **Questions**: SKIP questions where `pre_filled` data is available and non-empty. Otherwise ask normally.
3. **Target Version**: Always run `start-new.md` Step 2.6 (no milestone available from prefill).
4. **SPEC.md Header**: Include the following lines (FR-6):
   - `**Source Conversation**: prefill`
   - If `conversation.url_reference` is non-null AND the user did NOT select "URL Ignore" in Step 2.5: also include `**Source Issue**: {url_reference}`
```

### Task 2.9: start-new.md Step 0 placeholder → 실제 Skill 호출로 치환

- [ ] Phase 1에서 작성한 placeholder 마커 위치 확인
- [ ] "--prefill only" row의 Action을 실제 `Skill("dotclaude:init-prefill", args="<prefill_body>")` 호출로 치환
- [ ] "URL + --prefill 동시" row의 Action을 `Skill("dotclaude:init-prefill", args="<prefill_body>", url_reference="<url>")` 호출로 치환
- [ ] init-prefill.md 미존재 에러 메시지 placeholder를 제거

### Task 2.10: SPEC.md 헤더 표기 가이드 (FR-6) 명시

- [ ] init-prefill.md Step 5 본문에 SPEC.md 헤더 작성 가이드 명시 (Task 2.8 본문 안에 포함됨)
- [ ] 다운스트림 init-xxx가 SPEC.md를 작성할 때 `conversation.source == "prefill"`을 보고 `**Source Conversation**: prefill`을 헤더에 추가하도록 가이드 작성
- [ ] 본 가이드는 init-feature/bugfix/refactor.md 본문 변경 없이도 SPEC.md TechnicalWriter 단계에서 처리 가능하도록 명문화

---

## Implementation Notes

### Reference: AD-1, AD-7
- AD-1: 신규 `commands/init-prefill.md`를 추가하고 `init-github-issue.md`와 평행한 internal command로 다룬다
- AD-7: init-feature/bugfix/refactor.md는 변경하지 않는다

### Reference 모델: init-github-issue.md (line 1-325)
- 본 phase의 init-prefill.md는 init-github-issue.md를 모델로 평행 복제한다
- 차이점:
  - Step 1: GitHub URL 입력 → prefill 본문 입력
  - Step 2 (Issue Parsing): gh CLI 호출 → 본문 그대로 사용 (필터링은 본 init-prefill의 Step 2)
  - Step 3 (Work Type Detection): label 검사 단계 제거, 본문 키워드 분석만 수행
  - Step 4 (Context Extraction): "issue body" → "prefill body"로 표현 변경, 휴리스틱 자체는 동일
  - Step 5 (Route): `github_issue` 블록 → `conversation` 블록

### pre_filled 스키마 정합성
- init-feature.md line 22-31의 표와 init-prefill.md Step 5 Feature 페이로드의 키가 1:1 일치
- init-bugfix.md line 16-31, init-refactor.md line 16-31도 동일하게 검증 (Phase 5)

### start-new.md Step 0 치환 영역
- Phase 1에서 작성한 placeholder 마커 (`NOTE (Phase 1 → Phase 2 마이그레이션)` 블록)를 Phase 2 완료 시점에 제거
- 4-row 분기 매트릭스 자체는 unchanged

### 참조 파일/라인
- `commands/init-github-issue.md` (전체) — 모델로 사용
- `commands/init-feature.md` line 16-31 — pre_filled 인프라 (변경 없음, reference)
- `commands/init-bugfix.md` line 16-31 — pre_filled 인프라 (변경 없음, reference)
- `commands/init-refactor.md` line 16-31 — pre_filled 인프라 (변경 없음, reference)
- `commands/_init-common.md` — branch/worktree 생성 (변경 없음, reference)

---

## Completion Checklist

- [x] `commands/init-prefill.md` 파일이 존재한다
- [x] frontmatter (`description`, `user-invocable: false`)가 정확하다
- [x] Language 섹션이 init-github-issue.md line 9-14와 동일한 문구로 포함된다
- [x] Step 1 (Prefill Input Reception)이 빈 본문 폴백 흐름을 명시한다
- [x] Step 2 (Sensitive Data Filtering)가 Phase 4 placeholder로 작성되어 있다
- [x] Step 2.5 (GitHub URL Detection & Resolution)가 Phase 3 placeholder로 작성되어 있다
- [x] Step 3 (Work Type Detection)이 키워드 분석 + AskUserQuestion 분기를 포함한다
- [x] Step 4 (Context Extraction)이 3개 heuristic 표 (feature/bugfix/refactor)를 모두 포함한다
- [x] Step 5 (Route to Init File)가 3개 work_type에 대한 YAML 페이로드를 모두 명시한다
- [x] Step 5의 YAML 페이로드 키가 init-feature/bugfix/refactor.md line 22-31과 1:1 일치한다
- [x] Step 5 본문에 SPEC.md 헤더 `**Source Conversation**: prefill` 표기 가이드가 포함된다
- [x] `commands/start-new.md` Step 0의 placeholder가 실제 `Skill("dotclaude:init-prefill")` 호출로 치환되었다
- [x] start-new.md Step 0의 분기 매트릭스 4-row는 unchanged이다 (description만 정밀화 가능)

---

## Acceptance Criteria

1. **AC-1**: Scenario 1 수동 검증 통과 — `--prefill <feature-style text>` 입력 시 init-prefill → init-feature 라우팅이 동작하고, init-feature의 line 16-31 pre_filled 인프라가 자동 스킵을 수행한다.
2. **AC-2**: Step 4 휴리스틱 표가 init-github-issue.md line 135-168과 의미적으로 동등하다 (heuristic 자체는 동일, 표현만 "issue body" → "prefill body").
3. **AC-3**: Step 5 YAML 페이로드의 `pre_filled` 키 집합이 init-feature/bugfix/refactor.md의 pre-fill check 표 키 집합과 정확히 일치한다.
4. **AC-4**: SPEC.md 헤더에 `**Source Conversation**: prefill`이 표기된다 (FR-6 충족).
5. **AC-5**: Phase 3, Phase 4가 본 phase의 placeholder를 기반으로 채울 수 있도록 마커 위치가 명확하다.
