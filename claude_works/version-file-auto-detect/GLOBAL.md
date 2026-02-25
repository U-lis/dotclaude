# version_file configure 시 자동 감지로 추천 - Global Documentation

## Feature Overview

### Purpose
`configure.md` Setting 6 (Version Files 관리)에 "Auto-detect and suggest" 서브 액션을 추가한다.

### Problem
현재 Setting 6에서 버전 파일을 추가하려면 사용자가 경로와 패턴을 수동으로 입력해야 한다. `tagging.md`에 이미 정의된 7개 알려진 파일의 자동 감지 테이블을 활용하지 않고 있으며, 설정된 파일이 디스크에서 사라진 경우를 감지하는 기능도 없다.

### Solution
Setting 6 메뉴에 "Auto-detect and suggest" 옵션을 추가하여, `tagging.md`의 자동 감지 테이블에 정의된 7개 파일을 프로젝트에서 스캔하고, 결과를 테이블로 표시한 뒤, 사용자가 추가/제거할 항목을 선택할 수 있도록 한다.

## Architecture Decision

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-1 | "Auto-detect and suggest" 옵션을 YAML options 배열의 5번째 위치에 추가 (Reset 다음, Skip 이전) | 기존 CRUD 옵션(View/Add/Remove/Reset) 뒤, 탈출 옵션(Skip) 앞에 배치하여 논리적 그룹핑 |
| AD-2 | 자동 감지 테이블을 새 서브 액션 섹션에 인라인으로 정의하되, tagging.md를 정식 소스로 참조 | tagging.md와 이중 관리를 피하면서도 구현 지침을 명확하게 전달 |
| AD-3 | 서브 액션을 3단계로 구조화: Scan -> Display -> Act | 단계별 분리로 로직을 명확하게 하고 엣지 케이스 처리를 용이하게 함 |
| AD-4 | 파일 추가 시 기존 Add 워크플로우 규칙 재사용 (빈 리스트 경고, CHANGELOG.md 자동 추가) | 코드 일관성 유지 및 중복 로직 방지 |
| AD-5 | 파일 제거 시 기존 Remove 워크플로우 규칙 재사용 (CHANGELOG.md 제거 불가) | 기존 제약 조건을 동일하게 적용 |
| AD-6 | 완료 후 Setting 6 메뉴로 복귀 | 다른 서브 액션과 동일한 UX 패턴 |
| AD-7 | Testing Checklist에 새 항목 추가 | 기존 테스트 체크리스트와 일관성 유지 |

## Data Model

변경 없음. 기존 `dotclaude-config.json`의 `version_files` 배열 구조를 그대로 사용한다.

```json
{
  "version_files": [
    { "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" },
    { "path": "package.json", "pattern": "\"version\":\\s*\"([^\"]+)\"" }
  ]
}
```

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | "Auto-detect and suggest" 서브 액션을 Setting 6에 추가 | pending | None |

## File Structure

### Modified Files

| File | Change Description |
|------|-------------------|
| `commands/configure.md` | Setting 6에 "Auto-detect and suggest" 옵션 및 서브 액션 섹션 추가, Testing Checklist 항목 추가 |

### Referenced Files (read-only)

| File | Reference Purpose |
|------|-------------------|
| `commands/tagging.md` (line 51-97) | 자동 감지 테이블의 정식 소스 (7개 알려진 파일 및 패턴) |
