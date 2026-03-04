<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-configure-multi-question
-->

# configure multi-question - Design Document

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | `commands/configure.md` multi-question 배치 전환 + check_version/auto_update 제거 | Pending | PR #59 머지 완료 |

**Complexity**: SIMPLE (1 phase, 1 file)
**Target File**: `commands/configure.md`

---

## Architecture Decisions

### AD-1: Setting 1-3을 단일 AskUserQuestion multi-question 호출로 통합

Setting 1 (Language), Setting 2 (Working Directory), Setting 3 (Base Branch)을 개별 `AskUserQuestion` 호출 대신 단일 multi-question 호출(questions 배열)로 통합한다. `AskUserQuestion`은 최대 4개 질문을 지원하며, 3개 질문은 제한 내에 있다.

**근거**: 사용자 인터랙션 횟수를 줄이고 설정 항목을 한눈에 확인할 수 있도록 개선.

### AD-2: check_version 및 auto_update 제거 (PR #59 전제)

PR #59 머지를 전제로 `check_version`과 `auto_update` 설정을 `commands/configure.md`에서 완전히 제거한다. Configuration Schema, Default Values, Step 1 (Load), Step 4 (Save), Step 5 (Confirm) 모든 섹션에서 해당 항목을 삭제한다.

**근거**: PR #59에서 해당 기능 제거 확정. configure 커맨드 문서에서도 동일하게 반영 필요.

### AD-3: 배치 응답 후 항목별 유효성 검증 및 재질문

multi-question 배치 응답 수신 후 각 항목에 대해 기존 유효성 검증 로직을 수행한다. 검증 실패 시 실패한 항목만 개별 재질문한다. 전체 배치를 다시 묻지 않는다.

**근거**: 전체 재질문은 사용자 경험 저하. 실패 항목만 재질문하면 효율적.

### AD-4: 마이그레이션 프롬프트는 배치 완료 후 발동

Working Directory 변경 시 마이그레이션 프롬프트를 배치 질문 도중이 아닌 배치 완료 후(Phase B) 발동한다.

**근거**: multi-question 배치 내에서 조건부 프롬프트를 끼워넣을 수 없음. 배치 완료 후 후처리 단계에서 자연스럽게 처리.

### AD-5: AskUserQuestion의 자동 "Other" 옵션 활용

기존 수동 "Other" 옵션(e.g., Setting 3의 "Other (enter manually)" 같은 선택지)을 제거하고, `AskUserQuestion` 도구가 자체 제공하는 "Other" 옵션을 활용한다.

**근거**: AskUserQuestion이 이미 "Other" 기능을 내장하고 있으므로 수동 추가 불필요.

### AD-6: Configuration Schema, Default Values, Step 1, Step 4, Step 5에서 check_version/auto_update 제거

AD-2의 구체적 반영 범위. 아래 섹션에서 해당 항목을 삭제한다:
- Configuration Schema JSON: `check_version`, `auto_update` 필드 삭제
- Default Values bash: `DEFAULT_CHECK_VERSION`, `DEFAULT_AUTO_UPDATE` 삭제
- Step 1 bash script: `CHECK_VERSION`, `AUTO_UPDATE` 변수 및 jq 로드 코드 삭제
- Step 4 bash script: `--argjson cv`, `--argjson au` 및 JSON 출력 필드 삭제
- Step 5 display: `check_version`, `auto_update` 출력 라인 삭제

### AD-7: 설정 번호 재부여

`check_version` (기존 Setting 3)과 `auto_update` (기존 Setting 4) 제거 후 설정 번호를 재부여한다:
- Setting 1: Language (변경 없음)
- Setting 2: Working Directory (변경 없음)
- Setting 3: Base Branch (기존 Setting 5 -> 3)
- Setting 4: Version Files (기존 Setting 6 -> 4)

문서 전체에서 "Setting 6" 참조를 "Setting 4"로, "Setting 5" 참조를 "Setting 3"으로 수정한다.

---

## Phase 1 Plan: Multi-Question 배치 전환 + check_version/auto_update 제거

### Objective

`commands/configure.md`를 수정하여:
1. `check_version`과 `auto_update` 관련 코드를 모든 섹션에서 제거한다
2. Step 3의 개별 순차 질문 방식을 multi-question 배치 방식으로 전환한다
3. 설정 번호를 재부여한다

### Prerequisites

- PR #59 머지 완료 (check_version, auto_update 제거 PR)

### Instructions

수정 대상 파일: `commands/configure.md`

아래 순서대로 `commands/configure.md`를 수정한다.

#### 1. Configuration Schema 섹션 수정 (L50-59 부근)

Configuration Schema JSON에서 `check_version`과 `auto_update` 필드를 삭제한다.

수정 전:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "check_version": true,
  "auto_update": false,
  "base_branch": "main",
  "version_files": []
}
```

수정 후:
```json
{
  "language": "en_US",
  "working_directory": ".dc_workspace",
  "base_branch": "main",
  "version_files": []
}
```

#### 2. Default Values 섹션 수정 (L63-73 부근)

`DEFAULT_CHECK_VERSION`과 `DEFAULT_AUTO_UPDATE` 라인을 삭제한다.

수정 전:
```bash
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_CHECK_VERSION=true
DEFAULT_AUTO_UPDATE=false
DEFAULT_BASE_BRANCH="main"
DEFAULT_VERSION_FILES="[]"
```

수정 후:
```bash
DEFAULT_LANGUAGE="en_US"
DEFAULT_WORKING_DIRECTORY=".dc_workspace"
DEFAULT_BASE_BRANCH="main"
DEFAULT_VERSION_FILES="[]"
```

#### 3. Step 1 (Load Config) bash 스크립트 수정 (L82-136 부근)

bash 스크립트에서 `CHECK_VERSION`, `AUTO_UPDATE` 변수 초기화, global config 로드, local config 로드, 출력 라인을 모두 삭제한다.

삭제할 라인들:
- 초기화: `CHECK_VERSION="true"`, `AUTO_UPDATE="false"`
- Global config 로드: `CHECK_VERSION=$(jq -r '.check_version // true' "$GLOBAL_CONFIG")`, `AUTO_UPDATE=$(jq -r '.auto_update // false' "$GLOBAL_CONFIG")`
- Local config 로드: `CHECK_VERSION=$(jq -r '.check_version // '"$CHECK_VERSION"'' "$LOCAL_CONFIG")`, `AUTO_UPDATE=$(jq -r '.auto_update // '"$AUTO_UPDATE"'' "$LOCAL_CONFIG")`
- 출력: `echo "  check_version: $CHECK_VERSION"`, `echo "  auto_update: $AUTO_UPDATE"`

#### 4. Step 3 (Interactive Configuration Workflow) 전면 재작성 (L165-462 부근)

기존 Setting 1 ~ Setting 6 (Setting 3: Check Version, Setting 4: Auto Update 포함)을 전면 삭제하고 아래 구조로 대체한다.

**Phase A: Multi-Question 배치 (Setting 1-3)**

Step 3 시작 부분에 다음과 같은 multi-question 배치 구조를 작성한다:

Setting 1 (Language), Setting 2 (Working Directory), Setting 3 (Base Branch)을 단일 `AskUserQuestion` multi-question 호출로 통합한다.

```yaml
questions:
  - question: "Language code for conversations and documents?"
    default_value: <current_language>
    context: |
      Specify language code (e.g., en_US, fr_FR, ja_JP, ko_KR).
      The SessionStart hook reads this setting and outputs it as session context.

  - question: "Working directory name (relative path from project root)?"
    default_value: <current_working_dir>
    context: |
      This is where dotclaude stores plans, notepads, and work artifacts.
      Must be a relative path (no leading /, no ..).
      Examples: .dc_workspace, claude_works, workspace/dotclaude

  - question: "Default base branch for git operations?"
    default_value: <current_base_branch>
    context: |
      Used for creating feature branches, PR targets, comparing changes.
      Common values: main, master, develop
```

각 질문에 `default_value`를 제공하여 사용자가 변경 없이 Enter만 누르면 기존 값이 유지되도록 한다. 수동 "Other" 옵션은 추가하지 않는다 (`AskUserQuestion`의 자동 Other 기능을 활용).

**Phase B: 배치 응답 후처리 (유효성 검증 + 마이그레이션)**

배치 응답 수신 후 아래 순서로 후처리한다:

1. **Language 유효성 검증**: 비어있지 않으면 통과. 빈 값이면 해당 항목만 개별 재질문.
2. **Working Directory 유효성 검증**: 기존 `validate_working_dir()` 로직 적용 (빈 값, 절대 경로, parent traversal, `.` or `..` 거부). 실패 시 해당 항목만 개별 재질문.
3. **Base Branch 유효성 검증**: 기존 `validate_base_branch()` 로직 적용 (빈 값 거부). 실패 시 해당 항목만 개별 재질문.
4. **Working Directory 마이그레이션**: Working Directory 값이 이전 값과 다른 경우, git repo 내에 기존 디렉토리가 존재하고 파일이 있으면 마이그레이션 프롬프트를 발동한다 (기존 마이그레이션 워크플로우와 동일한 AskUserQuestion 사용: "Migrate to new location" / "Start fresh").

유효성 검증 함수(`validate_working_dir`, `validate_base_branch`)는 기존 구현을 그대로 유지하되, Setting 3/4/5 위치에서 Phase B 위치로 이동한다.

**Phase C: Version Files 인터랙티브 워크플로우 (Setting 4)**

기존 Setting 6의 Version Files 인터랙티브 워크플로우를 그대로 유지한다. 변경 사항:
- 섹션 제목을 "Setting 6: Version Files"에서 "Setting 4: Version Files"로 변경
- 내부 구조 (View/Add/Remove/Reset/Skip)는 변경 없음
- "Return to Setting 6 menu" 등의 참조를 "Return to Setting 4 menu"로 변경

#### 5. Step 4 (Save Configuration) 수정 (L463-500 부근)

jq 명령어에서 `check_version`과 `auto_update` 관련 부분을 삭제한다.

수정 전:
```bash
jq -n \
  --arg lang "$LANGUAGE" \
  --arg wd "$WORKING_DIR" \
  --argjson cv "$CHECK_VERSION" \
  --argjson au "$AUTO_UPDATE" \
  --arg bb "$BASE_BRANCH" \
  --argjson vf "$VERSION_FILES" \
  '{
    language: $lang,
    working_directory: $wd,
    check_version: $cv,
    auto_update: $au,
    base_branch: $bb,
    version_files: $vf
  }' > "$TARGET_CONFIG"
```

수정 후:
```bash
jq -n \
  --arg lang "$LANGUAGE" \
  --arg wd "$WORKING_DIR" \
  --arg bb "$BASE_BRANCH" \
  --argjson vf "$VERSION_FILES" \
  '{
    language: $lang,
    working_directory: $wd,
    base_branch: $bb,
    version_files: $vf
  }' > "$TARGET_CONFIG"
```

#### 6. Step 5 (Confirm Success) 수정 (L504-521 부근)

표시 설정에서 `check_version`과 `auto_update` 라인을 삭제한다.

수정 전:
```
Settings:
  language: <value>
  working_directory: <value>
  check_version: <value>
  auto_update: <value>
  base_branch: <value>
  version_files: <value or "auto-detect">
```

수정 후:
```
Settings:
  language: <value>
  working_directory: <value>
  base_branch: <value>
  version_files: <value or "auto-detect">
```

#### 7. Testing Checklist 수정 (L631-655 부근)

기존 "All 6 settings can be modified" 항목을 "All 4 settings can be modified"로 변경하고, multi-question 배치 동작에 대한 테스트 항목을 추가한다.

### Completion Checklist

- [ ] Configuration Schema JSON에서 `check_version`, `auto_update` 삭제
- [ ] Default Values에서 `DEFAULT_CHECK_VERSION`, `DEFAULT_AUTO_UPDATE` 삭제
- [ ] Step 1 (Load Config) bash 스크립트에서 `CHECK_VERSION`, `AUTO_UPDATE` 관련 코드 전부 삭제
- [ ] Step 3에서 기존 Setting 1~6 개별 질문 구조를 삭제
- [ ] Step 3 Phase A: Setting 1-3 multi-question 배치 구조 작성
- [ ] Step 3 Phase B: 배치 응답 후처리 (유효성 검증 + 재질문 + 마이그레이션) 구조 작성
- [ ] Step 3 Phase C: Version Files 워크플로우를 Setting 4로 재번호 부여
- [ ] Step 4 (Save) jq 명령어에서 `check_version`, `auto_update` 삭제
- [ ] Step 5 (Confirm) 표시에서 `check_version`, `auto_update` 삭제
- [ ] 수동 "Other" 옵션 모두 제거 (AskUserQuestion 자동 Other 활용)
- [ ] Testing Checklist를 4개 설정 + multi-question 배치 동작 기준으로 갱신
- [ ] 문서 내 "Setting 5" -> "Setting 3", "Setting 6" -> "Setting 4" 등 모든 교차 참조 수정

### Notes

- `AskUserQuestion` multi-question 호출의 `questions` 배열은 최대 4개 질문을 지원한다. Setting 1-3은 3개이므로 제한 내.
- `validate_working_dir()`와 `validate_base_branch()` 함수 본문은 변경하지 않는다. 위치만 Phase B로 이동.
- Version Files 워크플로우 (View/Add/Remove/Reset/Skip)의 내부 구현은 변경하지 않는다. 섹션 제목과 참조 번호만 수정.
- Implementation Notes, Error Handling, Safety, Future Enhancements 섹션은 `check_version`/`auto_update` 관련 내용이 없으므로 수정 불필요.
- Boolean Values in JSON 참고사항: `check_version`/`auto_update` 제거로 boolean 저장 관련 내용은 `version_files` 제거 시에만 해당될 수 있으나, `version_files`는 array이므로 해당 없음. 단, 해당 참고사항 섹션 자체는 삭제하지 않는다 (향후 boolean 설정 추가 가능성 고려).

---

## Phase 1 Test Plan

### Test Coverage Target

>= 70%

### Unit Tests

#### Configuration Schema

- [ ] TC-1: 수정된 Configuration Schema JSON에 `check_version`, `auto_update` 필드가 없는지 확인
- [ ] TC-2: 수정된 Configuration Schema JSON에 `language`, `working_directory`, `base_branch`, `version_files` 4개 필드만 존재하는지 확인

#### Default Values

- [ ] TC-3: Default Values bash에 `DEFAULT_CHECK_VERSION`, `DEFAULT_AUTO_UPDATE`가 없는지 확인
- [ ] TC-4: Default Values bash에 `DEFAULT_LANGUAGE`, `DEFAULT_WORKING_DIRECTORY`, `DEFAULT_BASE_BRANCH`, `DEFAULT_VERSION_FILES` 4개만 존재하는지 확인

#### Step 1 (Load Config)

- [ ] TC-5: Step 1 bash 스크립트에 `CHECK_VERSION`, `AUTO_UPDATE` 변수가 없는지 확인
- [ ] TC-6: Step 1 출력에 `check_version`, `auto_update` 라인이 없는지 확인

### Integration Tests

#### Multi-Question 배치 (Phase A)

- [ ] TC-7: Multi-question 배치가 3개 질문(Language, Working Directory, Base Branch)을 한 번에 제시하는지 확인
- [ ] TC-8: 각 질문에 `default_value`로 현재 설정값이 제공되는지 확인
- [ ] TC-9: 사용자가 "Other"를 선택하여 커스텀 값을 입력할 수 있는지 확인 (AskUserQuestion 자동 Other)
- [ ] TC-10: 모든 값을 기본값 그대로 유지(변경 없음)했을 때 정상 저장되는지 확인

#### 배치 응답 후처리 (Phase B)

- [ ] TC-11: Language에 빈 값 입력 시 해당 항목만 재질문하는지 확인
- [ ] TC-12: Working Directory에 절대 경로 입력 시 해당 항목만 재질문하는지 확인
- [ ] TC-13: Working Directory에 `..` 포함 경로 입력 시 해당 항목만 재질문하는지 확인
- [ ] TC-14: Working Directory에 `.` 또는 `..` 입력 시 해당 항목만 재질문하는지 확인
- [ ] TC-15: Base Branch에 빈 값 입력 시 해당 항목만 재질문하는지 확인
- [ ] TC-16: Working Directory 변경 시(이전 값과 다를 때) 마이그레이션 프롬프트가 배치 완료 후 발동하는지 확인
- [ ] TC-17: Working Directory 변경 + 기존 디렉토리에 파일 존재 시 마이그레이션 옵션(Migrate/Start fresh)이 제시되는지 확인
- [ ] TC-18: Working Directory 변경 + 기존 디렉토리가 비어있거나 없을 때 마이그레이션 프롬프트가 발동하지 않는지 확인

#### Version Files (Phase C)

- [ ] TC-19: Version Files 인터랙티브 워크플로우가 기존과 동일하게 동작하는지 확인 (View/Add/Remove/Reset/Skip)
- [ ] TC-20: 섹션 제목이 "Setting 4: Version Files"로 표시되는지 확인

#### Step 4 (Save) / Step 5 (Confirm)

- [ ] TC-21: 저장된 JSON에 `check_version`, `auto_update` 필드가 없는지 확인
- [ ] TC-22: 저장된 JSON에 `language`, `working_directory`, `base_branch`, `version_files` 4개 필드만 존재하는지 확인
- [ ] TC-23: Confirm 표시에 `check_version`, `auto_update`가 없고 4개 설정만 표시되는지 확인

### Edge Cases

- [ ] TC-24: 배치에서 복수 항목이 유효성 검증 실패 시 각각 개별 재질문하는지 확인
- [ ] TC-25: 재질문 후에도 유효하지 않은 값 입력 시 다시 재질문하는지 확인
- [ ] TC-26: Working Directory 변경 + Migrate 선택 시 디렉토리가 정상 이동하는지 확인
- [ ] TC-27: Working Directory 변경 + Start fresh 선택 시 기존 디렉토리가 유지되는지 확인
- [ ] TC-28: 문서 내 모든 "Setting 5" 참조가 "Setting 3"으로, "Setting 6" 참조가 "Setting 4"로 변경되었는지 확인
