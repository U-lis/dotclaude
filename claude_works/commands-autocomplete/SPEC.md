# SPEC: commands/ 디렉토리 추가로 Autocomplete 지원

**Target Version**: 0.1.1
**Work Type**: bugfix
**Branch**: bugfix/commands-autocomplete

---

## User-Reported Information

### Bug Description
dotclaude plugin을 설치했지만 `/` 입력 시 autocomplete에 skill들(dc:start-new, dc:design 등)이 표시되지 않음. 같은 환경에서 claude-hud plugin의 commands는 정상 표시됨.

### Reproduction Steps
1. dotclaude plugin 설치 (`/plugin install dotclaude`)
2. Claude Code에서 `/` 입력
3. dotclaude skills이 autocomplete 목록에 표시되지 않음
4. 그러나 직접 `/dc:start-new` 입력 시에는 정상 동작함

### User's Expected Cause
디렉토리 구조 차이 - claude-hud는 `commands/` 디렉토리 사용, dotclaude는 `skills/` 디렉토리 사용

### Severity
**Major** - 주요 기능 장애 (skills을 autocomplete에서 찾을 수 없음)

### Related Files
- `skills/*/SKILL.md` (7개 파일)
- `.claude-plugin/plugin.json`

### Impact Scope
모든 dotclaude skills (7개): start-new, design, code, merge-main, tagging, update-docs, validate-spec

---

## AI Analysis Results

### Root Cause Analysis

**Exact Code Location**: Plugin 디렉토리 구조

**Why the Bug Occurs**:
Claude Code는 `commands/` 디렉토리의 `.md` 파일만 autocomplete에 노출함.
- **claude-hud**: `commands/setup.md`, `commands/configure.md` → autocomplete에 표시됨
- **oh-my-claudecode**: `commands/*.md` + `skills/*/SKILL.md` 둘 다 사용
- **dotclaude**: `skills/*/SKILL.md`만 사용 → autocomplete에 표시 안 됨

**Evidence**:
| Plugin | Directory | Autocomplete |
|--------|-----------|--------------|
| claude-hud | `commands/setup.md` | 표시됨 |
| oh-my-claudecode | `commands/omc-setup.md` | 표시됨 |
| dotclaude | `skills/start-new/SKILL.md` | 표시 안 됨 |

### Affected Code Locations

| File | Action |
|------|--------|
| `commands/` (신규) | 디렉토리 생성 |
| `commands/dc:start-new.md` (신규) | Command 파일 생성 |
| `commands/dc:design.md` (신규) | Command 파일 생성 |
| `commands/dc:code.md` (신규) | Command 파일 생성 |
| `commands/dc:merge-main.md` (신규) | Command 파일 생성 |
| `commands/dc:tagging.md` (신규) | Command 파일 생성 |
| `commands/dc:update-docs.md` (신규) | Command 파일 생성 |
| `commands/dc:validate-spec.md` (신규) | Command 파일 생성 |
| `skills/*/SKILL.md` | `name` 필드에서 `dc:` prefix 제거 |
| `CLAUDE.md` (신규) | 개발 시 혼동 방지 규칙 추가 |

### Fix Strategy

#### 1. commands/ 디렉토리 구조 추가

```
commands/                          # NEW - autocomplete용
├── dc:start-new.md
├── dc:design.md
├── dc:code.md
├── dc:merge-main.md
├── dc:tagging.md
├── dc:update-docs.md
└── dc:validate-spec.md
```

#### 2. Command 파일 형식 (claude-hud 패턴)

```yaml
---
description: {skill description}
---
Base directory for this skill: skills/{skill-name}

Read skills/{skill-name}/SKILL.md and follow its instructions.
```

#### 3. SKILL.md 수정

**Before**:
```yaml
---
name: dc:start-new
description: Entry point for starting new work...
user-invocable: true
---
```

**After**:
```yaml
---
name: start-new
description: Entry point for starting new work...
user-invocable: true
---
```

#### 4. CLAUDE.md 생성

dotclaude 개발 시 혼동 방지를 위한 규칙 추가:
- dotclaude 관련 변경은 현재 repo 파일 수정
- 설치된 plugin 파일(`~/.claude/plugins/cache/...`) 수정 금지

### Conflict Analysis

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | SKILL.md `name: dc:start-new` | commands에서만 `dc:` prefix | SKILL.md에서 `dc:` 제거, commands에서 `dc:` 사용 |
| 2 | `user-invocable: true` in SKILL.md | commands 구조에는 불필요 | SKILL.md는 유지 (내부 참조용), commands는 description만 |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | `/dc:` 입력 | 모든 dotclaude commands autocomplete에 표시 |
| 2 | `/dc:start-new` 직접 입력 | 정상 실행 |
| 3 | 기존 skill 참조 | skills/*/SKILL.md 계속 작동 |
| 4 | Plugin 재설치 후 | autocomplete 정상 작동 |

---

## Verification Checklist

- [ ] `commands/` 디렉토리 생성됨
- [ ] 7개 command 파일 생성됨
- [ ] `skills/*/SKILL.md`의 `name` 필드에서 `dc:` 제거됨
- [ ] CLAUDE.md 생성됨
- [ ] Plugin 재설치 성공
- [ ] `/dc:` 입력 시 autocomplete에 7개 command 표시
- [ ] `/dc:start-new` 정상 동작
- [ ] 기존 skill 기능 유지됨
