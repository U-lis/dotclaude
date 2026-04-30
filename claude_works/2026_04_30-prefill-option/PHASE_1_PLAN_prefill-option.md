# PHASE 1: ARGUMENTS 파싱 분기 추가 (start-new.md)

## Phase Metadata

- **Status**: Pending
- **Type**: sequential
- **Dependencies**: -
- **Effort**: small

---

## Objective

`commands/start-new.md`에 "Step 0: Argument Parsing" 섹션을 신설하여, 위치 인자(GitHub URL)와 `--prefill` 플래그의 라우팅 분기를 한 곳에 명문화한다. 본 phase에서는 분기 매트릭스와 quoting 가이드만 추가하며, init-prefill.md 호출은 Phase 2에서 placeholder를 실제 Skill 호출로 치환한다.

---

## Files to Create

(없음)

## Files to Modify

| Path | Change |
|------|--------|
| `commands/start-new.md` | "Configuration Loading" 섹션 직후에 "Step 0: Argument Parsing" 섹션 신설 |

---

## Detailed Tasks

### Task 1.1: start-new.md 섹션 위치 식별
- [ ] `commands/start-new.md`의 "Configuration Loading" 섹션 종료 위치 확인 (현재 line 8-34, "## Language" 시작 직전)
- [ ] "## Language" 섹션 직전 또는 "## 13-Step Workflow" 섹션 직전 위치 후보 비교
- [ ] **결정**: "## 13-Step Workflow" 섹션 (현재 line 64) 직전에 신설. 이유: Workflow의 Step 0가 자연스럽게 Step 1 이전에 위치.

### Task 1.2: "Step 0: Argument Parsing" 섹션 본문 작성
- [ ] 섹션 헤더: `### Step 0: Argument Parsing`
- [ ] 섹션 도입부: ARGUMENTS 사전 파싱의 목적과 적용 시점 설명 (Step 1 진입 전)
- [ ] 4-row 분기 매트릭스 표 작성:

| ARGUMENTS Form | Detection Rule | Action |
|----------------|----------------|--------|
| URL only (GitHub Issue/PR URL) | 정규식 `https://github\.com/[^/]+/[^/]+/(issues\|pull)/\d+` 매칭, `--prefill` 플래그 없음 | `Skill("dotclaude:init-github-issue")` 호출. URL을 issue 입력으로 전달 |
| `--prefill` only | `--prefill` 플래그 존재, 위치 인자에 GitHub URL 정규식 미매칭 | `Skill("dotclaude:init-prefill")` 호출. 본문 텍스트를 `--prefill` 인자 값으로 전달 |
| URL + `--prefill` 동시 | 위치 인자에 URL 정규식 매칭 AND `--prefill` 플래그 존재 | `Skill("dotclaude:init-prefill")` 호출. URL을 추가 컨텍스트로 함께 전달 (FR-9 Scenario A → init-prefill의 Step 2.5에서 처리) |
| neither (빈 인자) | 위치 인자 미입력 AND `--prefill` 플래그 미입력 | 기존 Step 1 (Work Type Selection)으로 진행. 변경 없음 |

- [ ] 표 아래에 각 row의 동작을 부연 설명하는 단락 추가

### Task 1.3: Quoting 가이드 추가 (Risk #1 mitigation)
- [ ] Step 0 본문에 "Argument Quoting Rules" 서브섹션 추가:
  - 단일 라인 본문: `--prefill "본문 텍스트"` 형태
  - 멀티라인 본문: `--prefill "$(cat << 'EOF' ... EOF)"` 형태 권장
  - 따옴표가 누락되면 첫 단어만 본문으로 인식되어 분기 오작동 위험 명시
- [ ] 추가 가이드: URL과 `--prefill`을 함께 입력할 때 순서는 무관 (`/dotclaude:start-new <url> --prefill <text>` 또는 `/dotclaude:start-new --prefill <text> <url>` 모두 동일)

### Task 1.4: init-prefill.md 미존재 placeholder 작성 (Risk #2 mitigation)
- [ ] 분기 매트릭스 표 row 2/3의 Action 열 또는 표 아래에 Phase 2 시점까지 적용될 placeholder 명시:
  ```
  NOTE (Phase 1 → Phase 2 마이그레이션):
  Phase 1 시점에서는 commands/init-prefill.md가 아직 존재하지 않는다.
  Phase 1 적용 직후 사용자가 --prefill을 호출하면 다음 에러를 출력하고 중단한다:

  "init-prefill command is not yet available. This feature is currently
   in development (target version 0.5.0). Use /dotclaude:start-new
   without --prefill for now, or wait for the 0.5.0 release."

  Phase 2 완료 시 본 placeholder는 실제 Skill 호출로 치환된다.
  ```

### Task 1.5: 다운스트림 영향 검증 (메타데이터 무영향 확인)
- [ ] `commands/start-new.md`의 "SPEC.md Configuration Metadata" 섹션 (line 20-34) 본문이 Step 0 추가로 변경되지 않는지 확인
- [ ] `working_directory`, `worktree_path`, `doc_dir` 등 메타데이터 필드는 Step 0 신설과 무관하게 그대로 유지

### Task 1.6: 기존 Step 1-13 본문 unchanged 검증
- [ ] Step 1 (Work Type Selection, line 68-79) 본문 unchanged 확인
- [ ] Step 2-13 본문 unchanged 확인 (diff 검토)
- [ ] Step 0가 새 섹션으로 추가되었을 뿐, 기존 섹션 어디에도 수정이 없어야 함

---

## Implementation Notes

### Reference: AD-2
> `start-new.md`에 "Step 0: Argument Parsing" 섹션을 신설하고, `--prefill` / GitHub URL / 둘 다 / 빈 인자의 4-row 분기 매트릭스를 정의한다. 기존 Step 1(Work Type Selection) 본문은 unmodified로 유지하면서, ARGUMENTS의 사전 파싱만 추가한다.

### 위치 결정 근거
"Configuration Loading" 섹션은 config 파일 로드를 다루므로 Step 0와 분리한다. "## 13-Step Workflow" 섹션 직전에 Step 0를 두면 논리적으로 "Workflow 진입 전 사전 파싱" 의미가 자연스럽다.

### 정규식 일치성
GitHub URL 감지 정규식 `https://github\.com/[^/]+/[^/]+/(issues|pull)/\d+`는 SPEC.md FR-9 line 50과 동일하게 사용. Phase 3에서 init-prefill.md Step 2.5도 동일한 정규식을 사용한다.

### 다운스트림 다운스트림 호환성
다운스트림 명령(`/dotclaude:design`, `/dotclaude:code` 등)은 SPEC.md 메타데이터 블록에서 `worktree_path`, `working_directory`, `doc_dir` 등을 읽는다. Step 0 추가는 SPEC.md 작성 단계 이전에 발생하므로 메타데이터 작성 단계(Step 2.7)에 영향이 없다.

### 참조 파일/라인
- `commands/start-new.md` line 8-34: Configuration Loading
- `commands/start-new.md` line 64-79: 13-Step Workflow / Step 1
- `commands/init-github-issue.md` line 20-32: GitHub URL 입력 패턴 (참고용)

---

## Completion Checklist

- [ ] `commands/start-new.md`에 "### Step 0: Argument Parsing" 섹션이 존재한다
- [ ] 4-row 분기 매트릭스 표가 정확하다 (URL only / --prefill only / both / neither)
- [ ] Quoting 가이드 서브섹션이 포함되어 있다
- [ ] init-prefill.md 미존재 placeholder가 명시되어 있다
- [ ] 기존 Step 1-13 본문은 unchanged이다 (`git diff` 검토 결과 Step 0 추가 외 변경 없음)
- [ ] "SPEC.md Configuration Metadata" 섹션 (line 20-34) 본문 unchanged
- [ ] 마크다운 렌더링이 깨지지 않는다 (헤딩 레벨, 표 컬럼 정렬)

---

## Acceptance Criteria

1. **AC-1**: `commands/start-new.md`를 단독으로 읽었을 때 Step 0가 명확히 식별 가능하며, 4가지 입력 형태에 대한 라우팅이 모호함 없이 기술된다.
2. **AC-2**: `git diff` 결과 Step 0 신설 외에는 line 단위 변경이 없다.
3. **AC-3**: Phase 2 진입 시 Step 0의 placeholder를 실제 Skill 호출로 한 번에 치환할 수 있도록 placeholder 위치가 명확히 표시되어 있다.
4. **AC-4**: 빈 인자 호출 (regression case) 시 Step 0를 거쳐 Step 1로 진행되는 흐름이 표/문구로 명확히 기술된다.
