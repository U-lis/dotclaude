<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-version-file-auto-detect
-->

# version_file configure 시 자동 감지로 추천 - Specification

- **Source Issue**: https://github.com/U-lis/dotclaude/issues/56
- **Target Version**: 0.4.0
- **Work Type**: feature

## Overview

### Goal
`configure.md` Setting 6 (Version Files 관리)에 "자동 감지로 추천" 서브 액션을 추가하여, `tagging.md`에 정의된 자동 감지 테이블(7개 알려진 파일 + 패턴)을 활용해 프로젝트의 버전 파일을 자동으로 스캔하고 추천하는 기능을 구현한다.

### Problem
현재 `configure.md` Setting 6의 버전 파일 관리에서는 View/Add/Remove/Reset/Skip 서브 액션만 제공한다. 버전 파일을 추가하려면 사용자가 파일 경로와 패턴을 수동으로 입력해야 한다. `tagging.md`에는 이미 7개 알려진 버전 파일에 대한 자동 감지 테이블이 정의되어 있지만, `configure.md`의 Add 워크플로우에서는 이를 활용하지 않는다. 또한 설정된 파일이 디스크에서 사라진 경우 이를 감지하고 제거를 추천하는 기능이 없다.

### Solution
Setting 6 메뉴에 "자동 감지로 추천" 옵션을 추가한다. 이 옵션을 선택하면 `tagging.md`의 자동 감지 테이블에 정의된 7개 파일을 프로젝트에서 스캔하고, 결과를 테이블로 표시한 뒤, 사용자가 추가/제거할 항목을 선택할 수 있도록 한다.

## Functional Requirements

- [ ] **FR-1**: `configure.md` Setting 6에 "자동 감지로 추천" 서브 액션 추가
  - 기존 옵션 목록 (View / Add / Remove / Reset / Skip) 에 "Auto-detect and suggest" 옵션을 추가한다
  - Setting 6 question의 options 배열에 새 항목을 삽입한다

- [ ] **FR-2**: `tagging.md`의 자동 감지 테이블(7개 알려진 파일)을 활용한 프로젝트 스캔
  - 스캔 대상 파일과 패턴 (tagging.md Auto-Detection 테이블 참조):

    | Priority | File | Pattern |
    |----------|------|---------|
    | 1 | `CHANGELOG.md` | `## \[([^\]]+)\]` |
    | 2 | `package.json` | `"version":\s*"([^"]+)"` |
    | 3 | `pyproject.toml` | `version\s*=\s*"([^"]+)"` |
    | 4 | `Cargo.toml` | `version\s*=\s*"([^"]+)"` |
    | 5 | `pom.xml` | `<version>([^<]+)</version>` |
    | 6 | `.claude-plugin/plugin.json` | `"version":\s*"([^"]+)"` |
    | 7 | `.claude-plugin/marketplace.json` | `"version":\s*"([^"]+)"` |

  - 각 파일에 대해 프로젝트 루트에서 존재 여부를 확인한다
  - 파일이 존재하면 정의된 패턴으로 버전 문자열 추출을 시도한다

- [ ] **FR-3**: 스캔 결과를 테이블 형태로 표시
  - 테이블 컬럼 구성:

    | Column | Description |
    |--------|-------------|
    | 파일명 (File) | 버전 파일의 상대 경로 |
    | 찾은 버전 (Detected Version) | 패턴 매칭으로 추출된 버전 문자열. 추출 실패 시 "추출 실패" 표시 |
    | 패턴 (Pattern) | 해당 파일에 사용된 정규식 패턴 |
    | 상태 (Status) | 아래 3가지 상태 중 하나 |

  - 상태(Status) 값:
    - **신규 추가 가능 (New - can add)**: 디스크에 존재하지만 현재 version_files 설정에 없는 파일
    - **이미 설정됨 (Already configured)**: 디스크에 존재하고 현재 version_files 설정에도 있는 파일
    - **설정됐으나 사라짐 (Configured but missing)**: 현재 version_files 설정에 있지만 디스크에 존재하지 않는 파일

- [ ] **FR-4**: 사용자가 추가할 항목을 선택할 수 있는 인터페이스
  - 스캔 결과 테이블을 표시한 후, "신규 추가 가능" 상태인 파일 목록을 AskUserQuestion으로 제시한다
  - 사용자가 추가할 파일을 선택하면 해당 파일의 path와 pattern을 version_files 설정에 추가한다
  - 추가 시 기존 Add 워크플로우의 규칙을 동일하게 적용한다:
    - 빈 리스트(자동 감지 모드)에서 첫 추가 시 명시적 설정이 자동 감지를 오버라이드함을 경고한다
    - CHANGELOG.md 항목이 없으면 자동으로 추가한다

- [ ] **FR-5**: 설정된 파일 중 더 이상 존재하지 않는 파일 감지 및 제거 추천
  - 현재 version_files 설정에 등록된 파일 중 디스크에 존재하지 않는 파일을 식별한다
  - 해당 파일 목록을 "설정됐으나 사라짐" 상태로 테이블에 표시한다
  - 제거 여부를 AskUserQuestion으로 확인한다
  - CHANGELOG.md는 제거 불가 (기존 Remove 서브 액션의 규칙과 동일)

## Non-Functional Requirements

- [ ] **NFR-1**: `configure.md`의 기존 Setting 6 구조와 코드 스타일 일관성을 유지한다
  - 기존 서브 액션(View/Add/Remove/Reset)과 동일한 문서 구조 및 형식을 따른다
  - 기존 워크플로우(Add, Remove)의 규칙과 검증 로직을 재사용한다

- [ ] **NFR-2**: 특별한 성능/보안 요구사항 없음

## Constraints

- **수정 대상 파일**: `commands/configure.md` 파일만 수정한다
- **패턴 소스**: `tagging.md`의 자동 감지 테이블에 정의된 동일한 7개 파일 및 패턴을 사용한다 (중복 정의하지 않고 참조)
- **CHANGELOG.md 필수 규칙**: CHANGELOG.md는 항상 필수이며 제거할 수 없다 (기존 규칙 유지)
- **기존 코드 패턴 준수**: `configure.md` 내 기존 서브 액션들의 코드 패턴과 구조를 따른다

## Out of Scope

- 없음 (필수 기능만 구현)

## Analysis Results

### Related Code

| # | File | Line | Relationship |
|---|------|------|--------------|
| 1 | `commands/configure.md` | 344-461 | Setting 6 현재 구현 - View/Add/Remove/Reset 서브 액션 정의 |
| 2 | `commands/tagging.md` | 51-97 | 자동 감지 테이블 - 7개 알려진 파일과 패턴 정의 및 해결 의사코드 |
| 3 | `commands/configure.md` | 366-367 | View 서브 액션에서 자동 감지 결과를 보여주는 기존 로직 |
| 4 | `commands/configure.md` | 440-447 | Add 워크플로우 (현재 수동 입력만 지원) |

### Conflicts Identified

충돌 없음. 기존 서브 액션 목록에 새 옵션을 추가하는 형태이므로 기존 기능에 영향이 없다.

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | 프로젝트에 알려진 버전 파일이 하나도 없는 경우 | 빈 테이블을 표시하고 "추천할 파일이 없습니다" 메시지를 출력한다 |
| 2 | 모든 알려진 파일이 이미 명시적 설정에 있는 경우 | 테이블에 모두 "이미 설정됨" 상태로 표시하고 "추가할 새 파일이 없습니다" 메시지를 출력한다 |
| 3 | 설정된 파일이 더 이상 디스크에 존재하지 않는 경우 | "설정됐으나 사라짐" 상태로 표시하고 제거 여부를 확인한다 |
| 4 | 파일은 존재하지만 패턴이 매치되지 않는 경우 | "찾은 버전" 컬럼에 "추출 실패"를 표시하고 사용한 패턴을 함께 표시한다. 추가 선택은 여전히 가능하다 |
| 5 | 혼합 상태 (일부 신규, 일부 설정됨, 일부 사라짐) | 모든 항목을 통합 테이블에 표시하고 상태(Status) 컬럼으로 구분한다 |
