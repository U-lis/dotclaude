# Phase 1: Auto-detect and suggest

## Objective

`commands/configure.md`의 Setting 6 (Version Files)에 "Auto-detect and suggest" 서브 액션을 추가한다. 이 서브 액션은 `tagging.md`의 자동 감지 테이블에 정의된 7개 파일을 프로젝트에서 스캔하고, 결과를 테이블로 표시하며, 사용자가 추가/제거할 항목을 선택할 수 있도록 한다.

## Prerequisites

- None (첫 번째이자 유일한 Phase)

## Instructions

수정 대상 파일: `commands/configure.md` (3개 위치)

---

### Change 1: YAML options 배열에 "Auto-detect and suggest" 옵션 삽입

**위치**: `commands/configure.md` line 348-352 (Setting 6의 YAML options 배열)

**현재 코드**:
```yaml
options:
  - "View current version files"
  - "Add a version file"
  - "Remove a version file"
  - "Reset to auto-detection"
  - "Skip (no changes)"
```

**변경 내용**: `"Reset to auto-detection"` 다음, `"Skip (no changes)"` 이전에 새 옵션을 삽입한다.

**변경 후 코드**:
```yaml
options:
  - "View current version files"
  - "Add a version file"
  - "Remove a version file"
  - "Reset to auto-detection"
  - "Auto-detect and suggest"
  - "Skip (no changes)"
```

---

### Change 2: Auto-detect and suggest 서브 액션 섹션 추가

**위치**: `commands/configure.md` line 461 이후 (Reset Sub-action 섹션의 `- Return to Setting 6 menu` 다음, `### Step 4: Save Configuration` 이전)

**내용**: 아래의 새 섹션을 삽입한다. 기존 서브 액션(View/Add/Remove/Reset)과 동일한 마크다운 형식(##### 헤더, 불릿 리스트, 의사코드 블록)을 따른다.

```markdown
##### Auto-detect and suggest Sub-action

이 서브 액션은 3단계로 수행된다: Scan -> Display -> Act

**Step 1: Scan**

`tagging.md`의 Auto-Detection 테이블에 정의된 7개 알려진 파일을 스캔한다 (참조: `commands/tagging.md` line 51-63).

```bash
# Known version files table (source of truth: tagging.md Auto-Detection table)
KNOWN_FILES=(
  "CHANGELOG.md|## \[([^\]]+)\]"
  "package.json|\"version\":\s*\"([^\"]+)\""
  "pyproject.toml|version\s*=\s*\"([^\"]+)\""
  "Cargo.toml|version\s*=\s*\"([^\"]+)\""
  "pom.xml|<version>([^<]+)</version>"
  ".claude-plugin/plugin.json|\"version\":\s*\"([^\"]+)\""
  ".claude-plugin/marketplace.json|\"version\":\s*\"([^\"]+)\""
)

# Load current version_files from config
CONFIGURED_PATHS = [entry.path for entry in config.version_files]

RESULTS = []
for each (file, pattern) in KNOWN_FILES:
    entry = { file: file, pattern: pattern, version: null, status: null }

    if file exists in project root:
        # Try to extract version using pattern
        match = regex_search(read_file(file), pattern)
        if match:
            entry.version = match.group(1)
        else:
            entry.version = "extraction failed"

        if file in CONFIGURED_PATHS:
            entry.status = "Already configured"
        else:
            entry.status = "New - can add"
    else:
        if file in CONFIGURED_PATHS:
            entry.status = "Configured but missing"
            entry.version = "-"
        else:
            # File doesn't exist and not configured -> skip (don't show)
            continue

    RESULTS.append(entry)
```

**Step 2: Display**

스캔 결과를 테이블 형태로 표시한다.

엣지 케이스 처리:
- RESULTS가 비어있는 경우 (알려진 파일이 프로젝트에 하나도 없고, 설정된 파일 중 사라진 것도 없는 경우): "No known version files detected in this project. Use 'Add a version file' to manually add one." 메시지를 출력하고 Setting 6 메뉴로 복귀한다.
- 모든 항목이 "Already configured" 상태인 경우: 테이블을 표시한 후 "All detected version files are already configured. No new files to add." 메시지를 출력한다.

결과 테이블 형식:

```
| File | Detected Version | Pattern | Status |
|------|-----------------|---------|--------|
| package.json | 1.2.3 | "version":\s*"([^"]+)" | New - can add |
| CHANGELOG.md | 1.2.3 | ## \[([^\]]+)\] | Already configured |
| pyproject.toml | - | version\s*=\s*"([^"]+)" | Configured but missing |
```

**Step 3: Act**

스캔 결과에 따라 사용자에게 추가/제거를 제안한다.

**3a. Add Prompt (New - can add 파일이 있는 경우)**:

"New - can add" 상태 파일이 있으면 AskUserQuestion으로 추가할 파일 목록을 제시한다.

```
AskUserQuestion:
  question: "Which files would you like to add to version_files?"
  options:
    - "<file1> (version: <detected_version>)"
    - "<file2> (version: <detected_version>)"
    - ...
    - "None - skip adding"
```

사용자가 파일을 선택하면 해당 파일의 path와 pattern을 version_files에 추가한다. 이때 기존 Add 워크플로우의 규칙을 동일하게 적용한다:
- 빈 리스트(자동 감지 모드)에서 첫 추가 시: "Note: Adding explicit version files will override auto-detection mode." 경고를 표시한다
- CHANGELOG.md 항목이 version_files에 없으면 자동으로 추가한다 (path: "CHANGELOG.md", pattern: `## \[(\d+\.\d+\.\d+)\]`)

**3b. Remove Prompt (Configured but missing 파일이 있는 경우)**:

"Configured but missing" 상태 파일이 있으면 AskUserQuestion으로 제거를 제안한다.

```
AskUserQuestion:
  question: "These configured files no longer exist on disk. Remove them from version_files?"
  options:
    - "Yes, remove missing files"
    - "No, keep them"
```

사용자가 제거를 선택하면 해당 파일들을 version_files에서 제거한다. 이때 기존 Remove 서브 액션의 규칙을 동일하게 적용한다:
- CHANGELOG.md는 제거할 수 없다 (디스크에 없더라도 설정에서 제거 불가)

**Step 4: Return**

- Setting 6 메뉴로 복귀한다 (다른 서브 액션과 동일한 패턴)
```

위 전체 내용을 하나의 `##### Auto-detect and suggest Sub-action` 섹션으로 삽입한다. 마크다운 헤더 레벨, 의사코드 스타일, 불릿 리스트 형식 등이 기존 서브 액션(View/Add/Remove/Reset)과 일관되도록 한다.

---

### Change 3: Testing Checklist에 새 항목 추가

**위치**: `commands/configure.md` line 631 이후 (Testing Checklist 섹션, 기존 마지막 항목 `- [ ] Changes take effect immediately` 다음)

**추가할 항목**:

```markdown
- [ ] Auto-detect scans all 7 known files from tagging.md
- [ ] Detected files show correct version extraction
- [ ] "New - can add" status shown for unregistered existing files
- [ ] "Already configured" status shown for registered existing files
- [ ] "Configured but missing" status shown for registered non-existing files
- [ ] Adding from auto-detect applies Add workflow rules (empty list warning, CHANGELOG.md auto-append)
- [ ] Removing missing files applies Remove rules (CHANGELOG.md cannot be removed)
- [ ] No known files detected shows appropriate message
```

---

## Completion Checklist

- [ ] 1.1: "Auto-detect and suggest" 옵션을 YAML options에 삽입 (Skip 앞)
- [ ] 1.2: `##### Auto-detect and suggest Sub-action` 섹션 생성 (Reset 서브 액션 뒤)
- [ ] 1.3: tagging.md의 7개 알려진 파일 참조하는 스캔 의사코드 정의
- [ ] 1.4: 상태 분류 로직 정의 (New/Already configured/Configured but missing)
- [ ] 1.5: 결과 테이블 형식 정의 (File, Detected Version, Pattern, Status 컬럼)
- [ ] 1.6: 엣지 케이스 처리 정의 (파일 없음, 모두 설정됨)
- [ ] 1.7: "추가할 파일 선택" 워크플로우 정의 (AskUserQuestion, Add 규칙 재사용)
- [ ] 1.8: "사라진 파일 제거" 워크플로우 정의 (AskUserQuestion, Remove 규칙 재사용)
- [ ] 1.9: Setting 6 메뉴 복귀 추가
- [ ] 1.10: Testing Checklist에 자동 감지 관련 항목 추가
- [ ] 1.11: 기존 서브 액션과 동일한 마크다운 서식 및 의사코드 스타일 확인

## Notes

- `commands/configure.md` 파일만 수정한다. 다른 파일은 변경하지 않는다.
- 의사코드 내 7개 파일과 패턴은 `commands/tagging.md` line 51-63의 Auto-Detection 테이블과 정확히 일치해야 한다. 향후 테이블이 변경되면 이 섹션도 함께 업데이트해야 한다.
- 기존 서브 액션과 동일한 수준의 마크다운 헤더(`#####`)를 사용한다.
- "Auto-detect and suggest"라는 영문 이름은 기존 옵션명("View current version files", "Add a version file" 등)과 스타일을 맞추기 위해 영문으로 유지한다.
