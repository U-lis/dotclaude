# SPEC: Command 파일명에서 dc: prefix 제거

**Target Version**: 0.1.2
**Work Type**: bugfix
**Branch**: bugfix/command-naming

---

## User-Reported Information

### Bug Description
`/dc` 입력 시 `/dotclaude:dc:xxx` 형식으로 표시됨. 중복된 prefix로 인해 명령어가 길어짐.

### Reproduction Steps
1. dotclaude plugin 설치
2. `/dc` 또는 `/dotclaude` 입력
3. Autocomplete에 `/dotclaude:dc:start-new` 등으로 표시됨

### User's Expected Cause
모르겠음

### Severity
Minor - 불편함이 있으나 우회 가능

### Related Files
commands/*.md (7개 파일)

### Impact Scope
모든 dotclaude skills (7개)

---

## AI Analysis Results

### Root Cause Analysis

**원인**: Claude Code의 command 네이밍 규칙

Claude Code는 command를 `{plugin-name}:{command-filename}` 형식으로 표시:
- Plugin 이름: `dotclaude`
- Command 파일: `dc:start-new.md`
- 결과: `/dotclaude:dc:start-new` (중복 prefix)

**비교**:
| Plugin | Command File | Autocomplete |
|--------|-------------|--------------|
| claude-hud | `commands/setup.md` | `/claude-hud:setup` |
| dotclaude | `commands/dc:start-new.md` | `/dotclaude:dc:start-new` |

### Fix Strategy

Command 파일명에서 `dc:` prefix 제거:

| Before | After |
|--------|-------|
| `commands/dc:start-new.md` | `commands/start-new.md` |
| `commands/dc:design.md` | `commands/design.md` |
| `commands/dc:code.md` | `commands/code.md` |
| `commands/dc:merge-main.md` | `commands/merge-main.md` |
| `commands/dc:tagging.md` | `commands/tagging.md` |
| `commands/dc:update-docs.md` | `commands/update-docs.md` |
| `commands/dc:validate-spec.md` | `commands/validate-spec.md` |

**결과**: `/dotclaude:start-new`, `/dotclaude:design` 등으로 표시됨

### Affected Code Locations

| File | Action |
|------|--------|
| `commands/dc:start-new.md` | Rename to `start-new.md` |
| `commands/dc:design.md` | Rename to `design.md` |
| `commands/dc:code.md` | Rename to `code.md` |
| `commands/dc:merge-main.md` | Rename to `merge-main.md` |
| `commands/dc:tagging.md` | Rename to `tagging.md` |
| `commands/dc:update-docs.md` | Rename to `update-docs.md` |
| `commands/dc:validate-spec.md` | Rename to `validate-spec.md` |
| `README.md` | Update command references |
| `CHANGELOG.md` | Update for v0.1.2 |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | `/dotclaude:` 입력 | 모든 7개 command 표시 |
| 2 | `/dotclaude:start-new` 실행 | 정상 동작 |
| 3 | 기존 `/dc:start-new` 입력 | 작동 안 함 (의도된 동작) |

---

## Verification Checklist

- [ ] 7개 command 파일 rename 완료
- [ ] Plugin 재설치 성공
- [ ] `/dotclaude:` 입력 시 autocomplete에 7개 command 표시
- [ ] `/dotclaude:start-new` 정상 동작
- [ ] README.md 업데이트
- [ ] CHANGELOG.md 업데이트
