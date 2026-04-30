# PHASE 1 TEST

## Test Status

- **Status**: Passed
- **Last Run**: 2026-04-30
- **Result**: PASS (all document structure / quoting guide / placeholder / regression / markdown checks succeeded; manual scenarios 1.1-1.4 routing logic verified via document inspection)

---

## Test Items

### Document Structure Checks

- [x] `commands/start-new.md` 파일이 존재한다
- [x] "### Step 0: Argument Parsing" 헤딩이 존재한다 (line 64)
- [x] Step 0 섹션은 "## Configuration Loading" 뒤에, "## 13-Step Workflow" 또는 "### INIT PHASE" 앞에 위치한다 (line 64, before line 132 "## 13-Step Workflow")
- [x] 4-row 분기 매트릭스 표가 다음 4가지 케이스를 모두 명시한다:
  - [x] URL only (line 78)
  - [x] --prefill only (line 79)
  - [x] URL + --prefill 동시 (line 80)
  - [x] neither (빈 인자) (line 81)
- [x] 각 row의 Action 열이 정확한 라우팅 대상(`Skill("dotclaude:init-github-issue")`, `Skill("dotclaude:init-prefill")`, 기존 Step 1)을 명시한다

### Argument Quoting Guide Checks

- [x] "Argument Quoting Rules" 또는 동등 서브섹션이 존재한다 (line 90)
- [x] 단일 라인 quoting 예시가 포함된다 (line 94-97)
- [x] 멀티라인 quoting 예시 (HEREDOC)가 포함된다 (line 99-110)
- [x] 따옴표 누락 시의 risk가 명시된다 (line 112)
- [x] URL과 --prefill 인자 순서 무관 가이드가 포함된다 (line 114-118)

### Placeholder Checks

- [x] init-prefill.md 미존재 시 출력될 에러 메시지 placeholder가 명시되어 있다 (line 122-128, "init-prefill command is not yet available...")
- [x] Phase 2 마이그레이션 노트가 포함되어 있다 (line 122 "Phase 1 → Phase 2 migration", line 128 "replaced with the actual Skill invocation in Phase 2")

### Regression Checks

- [x] "## Configuration Loading" 섹션 (기존 line 8-34)이 unchanged이다 (`git diff HEAD`: 0 changes in this range)
- [x] "### SPEC.md Configuration Metadata" 서브섹션 (기존 line 20-34)이 unchanged이다 (verified via direct comparison with HEAD version)
- [x] "### Step 1: Work Type Selection" 본문이 unchanged이다 (이제 line 136-146, content identical, only relocated by +68 lines from Step 0 insertion)
- [x] Step 2-13 본문이 unchanged이다 (`git diff HEAD --numstat`: +68 -0)
- [x] "## Routing" 섹션 (Step 5 분기 처리부)이 unchanged이다 (line 818-828, no diff)
- [x] "## Output Contract" 섹션이 unchanged이다 (line 952-989, no diff)

### Markdown Rendering Checks

- [x] 4-row 표의 컬럼 정렬이 올바르다 (3-column: Form | Detection | Action) (verified at line 76-77)
- [x] 코드 블록 (HEREDOC 예시 등)이 올바른 fence를 사용한다 (file total code fences = 60, even number)
- [x] 헤딩 레벨이 일관된다 (Step 0는 `###` line 64, 그 하위는 `####` line 74/90/120)

---

## Manual Test Scenarios

### Scenario 1.1: 빈 인자 호출 (Regression)

**입력**: `/dotclaude:start-new` (인자 없음)

**검증 절차**:
1. Step 0 분기 매트릭스에서 "neither" row가 적용되는지 확인
2. Step 1 (Work Type Selection)으로 진행하는 흐름이 표/문구로 명시되어 있는지 확인
3. AskUserQuestion이 Work Type 선택지를 제시하는지 확인 (기존 동작)

**기대 결과**: 기존 동작과 100% 동일

### Scenario 1.2: GitHub URL only 호출 (Regression)

**입력**: `/dotclaude:start-new https://github.com/U-lis/dotclaude/issues/13`

**검증 절차**:
1. Step 0 분기 매트릭스에서 "URL only" row가 적용되는지 확인
2. `Skill("dotclaude:init-github-issue")` 호출 흐름이 명시되어 있는지 확인
3. 기존 init-github-issue 라우팅과 동등한지 확인

**기대 결과**: 기존 동작과 동등 (변경 없음)

### Scenario 1.3: --prefill 호출 (Phase 1 placeholder)

**입력**: `/dotclaude:start-new --prefill "사용자가 작성 권한 요청 기능을 원함"`

**검증 절차**:
1. Step 0 분기 매트릭스에서 "--prefill only" row가 적용되는지 확인
2. Phase 1 시점에서는 init-prefill.md가 미존재이므로 명시된 에러 메시지가 출력되는지 확인 (placeholder 동작)

**기대 결과**: 명시된 에러 메시지 출력 후 중단. 워크플로우 무한 루프나 unhandled error 없음

### Scenario 1.4: URL + --prefill 동시 호출 (Phase 1 placeholder)

**입력**: `/dotclaude:start-new https://github.com/U-lis/dotclaude/issues/13 --prefill "본문..."`

**검증 절차**:
1. Step 0 분기 매트릭스에서 "URL + --prefill 동시" row가 적용되는지 확인
2. Phase 1 시점에서는 init-prefill.md가 미존재이므로 명시된 에러 메시지가 출력되는지 확인 (placeholder 동작)

**기대 결과**: 명시된 에러 메시지 출력. URL fetch나 init-github-issue 라우팅으로 잘못 빠지지 않음

---

## Notes / Observations

- 본 phase는 마크다운 문서 변경만 포함하므로 자동화된 단위 테스트는 적용 외
- 모든 검증은 `commands/start-new.md` 파일 직접 읽기 + 수동 호출 테스트로 수행
- Phase 2 완료 후 Scenario 1.3, 1.4의 기대 결과가 달라짐 (placeholder → 실제 init-prefill 호출)

## Validation Results (2026-04-30)

### Verification Method

- Document structure: direct read of `commands/start-new.md` (line numbers cited above)
- Regression: `git diff HEAD -- commands/start-new.md` produced +68/-0 (pure addition; zero modifications to existing content)
- Markdown rendering: heading hierarchy + table column count + code-fence parity verified by structural inspection

### Manual Scenario Coverage

Each scenario was validated by tracing the routing logic in the document (no live invocation possible at Phase 1 because `init-prefill.md` is intentionally absent until Phase 2):

- **Scenario 1.1 (empty arguments)**: Branch matrix row 4 ("neither") routes to existing Step 1 (line 81) — confirmed
- **Scenario 1.2 (URL only)**: Branch matrix row 1 routes to `Skill("dotclaude:init-github-issue")` (line 78) — confirmed
- **Scenario 1.3 (--prefill only)**: Branch matrix row 2 + Phase 1 placeholder error message (line 122-128) — confirmed
- **Scenario 1.4 (URL + --prefill)**: Branch matrix row 3 + Phase 1 placeholder error message (line 122-128) — confirmed

### Outcome

All checklist items passed on the first validation attempt. No fix iterations required.
