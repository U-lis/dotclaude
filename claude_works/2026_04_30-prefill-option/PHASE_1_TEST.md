# PHASE 1 TEST

## Test Status

- **Status**: Pending
- **Last Run**: -
- **Result**: -

---

## Test Items

### Document Structure Checks

- [ ] `commands/start-new.md` 파일이 존재한다
- [ ] "### Step 0: Argument Parsing" 헤딩이 존재한다
- [ ] Step 0 섹션은 "## Configuration Loading" 뒤에, "## 13-Step Workflow" 또는 "### INIT PHASE" 앞에 위치한다
- [ ] 4-row 분기 매트릭스 표가 다음 4가지 케이스를 모두 명시한다:
  - [ ] URL only
  - [ ] --prefill only
  - [ ] URL + --prefill 동시
  - [ ] neither (빈 인자)
- [ ] 각 row의 Action 열이 정확한 라우팅 대상(`Skill("dotclaude:init-github-issue")`, `Skill("dotclaude:init-prefill")`, 기존 Step 1)을 명시한다

### Argument Quoting Guide Checks

- [ ] "Argument Quoting Rules" 또는 동등 서브섹션이 존재한다
- [ ] 단일 라인 quoting 예시가 포함된다
- [ ] 멀티라인 quoting 예시 (HEREDOC)가 포함된다
- [ ] 따옴표 누락 시의 risk가 명시된다
- [ ] URL과 --prefill 인자 순서 무관 가이드가 포함된다

### Placeholder Checks

- [ ] init-prefill.md 미존재 시 출력될 에러 메시지 placeholder가 명시되어 있다
- [ ] Phase 2 마이그레이션 노트가 포함되어 있다 (Phase 2 완료 시 placeholder를 실제 Skill 호출로 치환)

### Regression Checks

- [ ] "## Configuration Loading" 섹션 (기존 line 8-34)이 unchanged이다
- [ ] "### SPEC.md Configuration Metadata" 서브섹션 (기존 line 20-34)이 unchanged이다
- [ ] "### Step 1: Work Type Selection" 본문 (기존 line 68-79)이 unchanged이다
- [ ] Step 2-13 본문이 unchanged이다
- [ ] "## Routing" 섹션 (Step 5 분기 처리부)이 unchanged이다
- [ ] "## Output Contract" 섹션이 unchanged이다

### Markdown Rendering Checks

- [ ] 4-row 표의 컬럼 정렬이 올바르다 (3-column: Form | Detection | Action)
- [ ] 코드 블록 (HEREDOC 예시 등)이 올바른 fence를 사용한다
- [ ] 헤딩 레벨이 일관된다 (Step 0는 `###`, 그 하위는 `####`)

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
