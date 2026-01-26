# SPEC: Plugin Directory Structure Migration

**Target Version**: 0.1.1
**Work Type**: bugfix
**Branch**: bugfix/plugin-skills-path

---

## User-Reported Information

### Bug Description
marketplace를 통한 dotclaude 플러그인 설치 시 에러 발생:
```
Error: Failed to install: Plugin has an invalid manifest file at
/home/ulismoon/.claude/plugins/cache/temp_local_1769395300753_orfaaw/.claude-plugin/plugin.json.
Validation errors: skills: Invalid input
```

### Reproduction Steps
1. Claude Code에서 `/plugin install dotclaude` 실행
2. 설치 범위 선택 (user, project, local 무관)
3. 에러 발생 - 모든 scope에서 동일

### User's Expected Cause
설정 오류 (plugin.json의 skills 필드 형식 문제)

### Severity
**Critical** - 플러그인 설치가 전혀 불가능하여 marketplace 배포 기능 완전 차단

### Related Files
- `.claude-plugin/plugin.json`
- `.claude/skills/` (현재 위치)
- `.claude/agents/` (현재 위치)

### Impact Scope
marketplace를 통한 모든 플러그인 설치에 영향

---

## AI Analysis Results

### Root Cause Analysis

**Primary Issue**: `.claude-plugin/plugin.json:5`의 경로 형식 오류
- `./`로 시작하지 않는 경로 사용

**Secondary Issue**: 비표준 디렉토리 구조
- 현재: `.claude/skills/`, `.claude/agents/`
- 표준: `skills/`, `agents/` (플러그인 루트)

**Current Structure**:
```
dotclaude/
├── .claude-plugin/
│   └── plugin.json     ← skills: ".claude/skills/" (잘못된 형식)
├── .claude/
│   ├── agents/         ← 비표준 위치
│   ├── skills/         ← 비표준 위치
│   ├── hooks/          ← 비표준 위치
│   └── settings.json
├── hooks/              ← 표준 위치 (현재 hook 스크립트 위치)
└── ...
```

**Target Structure (Standard)**:
```
dotclaude/
├── .claude-plugin/
│   └── plugin.json     ← skills 필드 제거 (기본 위치 사용)
├── .claude/
│   └── settings.json   ← Claude Code 프로젝트 설정만 유지
├── agents/             ← 표준 위치로 이동
├── skills/             ← 표준 위치로 이동
├── hooks/              ← 이미 표준 위치 (스크립트 + hooks.json 통합)
└── ...
```

**Why the Bug Occurs**:

1. Claude Code plugin manifest 스키마에서 경로는 반드시 `./`로 시작해야 함
   > "All paths must be relative to plugin root and start with `./`"
   > Source: [Plugins reference](https://code.claude.com/docs/en/plugins-reference)

2. 표준 플러그인 구조에서 components는 플러그인 루트에 위치해야 함
   > "Skills: `skills/` directory in plugin root"
   > Reference: oh-my-claudecode 구조 분석

**Recent Change Correlation**:
- 커밋 `705d5ec` (feat: add plugin marketplace support)에서 최초 생성 시부터 비표준 구조로 작성됨

### Affected Code Locations

| # | File/Directory | Change | Reason |
|---|----------------|--------|--------|
| 1 | `.claude-plugin/plugin.json` | skills 필드 제거 | 기본 위치(`./skills/`) 자동 감지 |
| 2 | `.claude/skills/` | → `skills/` 이동 | 표준 위치로 마이그레이션 |
| 3 | `.claude/agents/` | → `agents/` 이동 | 표준 위치로 마이그레이션 |
| 4 | `.claude/hooks/` | → `hooks/`와 통합 | 중복 제거 및 표준화 |
| 5 | `.claude/templates/` | → `templates/` 이동 | 일관성 유지 |
| 6 | 모든 skill 파일 내 경로 참조 | 업데이트 | 새 위치 반영 |
| 7 | `.dotclaude-manifest.json` | 업데이트 | 새 파일 경로 반영 |

### Fix Strategy

**Phase 1: 디렉토리 마이그레이션**
```bash
# skills 이동
mv .claude/skills/ skills/

# agents 이동
mv .claude/agents/ agents/

# templates 이동
mv .claude/templates/ templates/

# .claude/hooks/ 내용을 hooks/로 통합 (현재 hooks.json만 있음)
# hooks/hooks.json은 이미 루트에 있으므로 .claude/hooks/는 제거
rm -rf .claude/hooks/
```

**Phase 2: plugin.json 업데이트**
```json
// Before
{
  "name": "dotclaude",
  "version": "0.1.0",
  "description": "Structured development workflow orchestration for Claude Code",
  "skills": ".claude/skills/"
}

// After - 표준 위치 사용시 skills 필드 불필요
{
  "name": "dotclaude",
  "version": "0.1.1",
  "description": "Structured development workflow orchestration for Claude Code"
}
```

**Phase 3: 내부 경로 참조 업데이트**
- skill 파일들 내 `.claude/skills/`, `.claude/agents/` 참조를 `skills/`, `agents/`로 변경
- `.dotclaude-manifest.json` 내 경로 업데이트

**Expected Behavior After Fix**:
- marketplace를 통한 dotclaude 플러그인 설치 정상 동작
- user, project, local 모든 scope에서 설치 가능
- 표준 플러그인 구조 준수

### Conflict Analysis

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | `.claude/` 하위에 agents, skills 위치 | 플러그인 루트에 위치 | 디렉토리 이동으로 해결 |
| 2 | `.claude/settings.json` Claude Code 설정 | 그대로 유지 | settings.json은 이동하지 않음 |
| 3 | hooks/ 와 .claude/hooks/ 이중 구조 | hooks/ 단일 구조 | .claude/hooks/ 제거, hooks/ 유지 |

### Edge Cases

| # | Case | Expected Behavior | Handling |
|---|------|-------------------|----------|
| 1 | 기존 사용자의 수동 설치 | 업데이트 필요 | README에 마이그레이션 가이드 추가 |
| 2 | skill 파일 내 상대 경로 참조 | 경로 깨짐 가능 | 모든 참조 업데이트 |
| 3 | `.dotclaude-manifest.json` 정합성 | 경로 불일치 | manifest 파일 업데이트 |
| 4 | `.claude/` 디렉토리 완전 삭제 | settings.json 손실 위험 | settings.json은 유지 |

---

## Migration Checklist

- [ ] `.claude/skills/` → `skills/` 이동
- [ ] `.claude/agents/` → `agents/` 이동
- [ ] `.claude/templates/` → `templates/` 이동
- [ ] `.claude/hooks/` 제거 (hooks/와 통합)
- [ ] `plugin.json` skills 필드 제거 및 버전 업데이트
- [ ] skill 파일 내 경로 참조 업데이트
- [ ] `.dotclaude-manifest.json` 경로 업데이트
- [ ] README.md 마이그레이션 가이드 추가 (기존 사용자용)
- [ ] CHANGELOG.md 업데이트

---

## References

- [Plugins reference - Claude Code Docs](https://code.claude.com/docs/en/plugins-reference)
- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) - 표준 플러그인 구조 참조
