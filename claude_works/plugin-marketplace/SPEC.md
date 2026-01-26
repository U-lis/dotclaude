# Plugin Marketplace - Specification

**Source Issues**:
- https://github.com/U-lis/dotclaude/issues/1
- https://github.com/U-lis/dotclaude/issues/6 (resolved by this)

**Target Version**: 0.1.0

## Overview

**Purpose**: dotclaude를 Claude Code의 plugin marketplace를 통해 간편하게 설치할 수 있도록 변환

**Problem**:
1. 현재 dotclaude 설치가 복잡함 (git clone → cp -r .claude → 수동 복사)
2. 다른 프로젝트에 설치 시 hook 파일이 누락되거나 권한 문제 발생 (Issue #6)
3. 버전 업데이트가 수동으로 이루어져야 함

**Solution**:
- `.claude-plugin/` 디렉토리 구조 추가하여 plugin marketplace 지원
- `${CLAUDE_PLUGIN_ROOT}` 환경변수 사용으로 hook 경로 문제 해결
- `/plugin install dotclaude` 명령으로 간편 설치

---

## Functional Requirements

### Core Features
- [ ] FR-1: `.claude-plugin/marketplace.json` 생성 - 마켓플레이스 메타데이터
- [ ] FR-2: `.claude-plugin/plugin.json` 생성 - 플러그인 설정 (skills 경로)
- [ ] FR-3: hooks를 `${CLAUDE_PLUGIN_ROOT}` 경로 사용하도록 수정
- [ ] FR-4: `/plugin marketplace add` 및 `/plugin install` 명령으로 설치 가능하게 구성

### Secondary Features
- [ ] FR-5: `/dotclaude:update` 스킬을 plugin 방식에 맞게 수정 또는 제거
- [ ] FR-6: README.md 설치 가이드 업데이트

---

## Non-Functional Requirements

### Compatibility
- [ ] NFR-1: 기존 수동 설치 방식(cp -r .claude)과 호환 유지
- [ ] NFR-2: Claude Code의 plugin marketplace 스펙 준수

### User Experience
- [ ] NFR-3: 설치 명령 2줄 이내로 단순화

---

## Constraints

### Technical Constraints
- Claude Code plugin marketplace 스펙 준수 필요
- `${CLAUDE_PLUGIN_ROOT}` 환경변수는 plugin 설치 시에만 제공됨

### Reference Implementation
- oh-my-claudecode: https://github.com/Yeachan-Heo/oh-my-claudecode

---

## Out of Scope

- npm 패키지 배포 (oh-my-claudecode는 npm도 사용하지만 현재 scope 외)
- global vs project 별 설치 옵션 (추후 버전에서 고려)
- 자동 버전 업데이트 알림

---

## Assumptions

- Claude Code가 plugin marketplace 기능을 지원함
- `${CLAUDE_PLUGIN_ROOT}` 환경변수가 plugin 설치 시 자동 제공됨
- hooks/hooks.json 파일이 plugin 설치 시 자동 로드됨

---

## Analysis Results

### Related Code

| # | File | Relationship |
|---|------|--------------|
| 1 | `.claude/settings.json` | 현재 hook 설정 위치 - 수정 필요 |
| 2 | `.claude/hooks/check-validation-complete.sh` | hook 스크립트 - 경로 수정 필요 |
| 3 | `.dotclaude-manifest.json` | 현재 버전 관리 - plugin.json과 통합 고려 |
| 4 | `.claude/skills/dotclaude/update/SKILL.md` | 업데이트 스킬 - 수정 필요 |

### Reference: oh-my-claudecode 구조

```
.claude-plugin/
├── marketplace.json    # 마켓플레이스 메타데이터
└── plugin.json         # 플러그인 설정

hooks/
└── hooks.json          # hook 설정 (${CLAUDE_PLUGIN_ROOT} 사용)

skills/                 # plugin.json에서 참조
```

### Conflicts Identified

| # | Existing | Required | Resolution |
|---|----------|----------|------------|
| 1 | `.claude/settings.json`에 hook 설정 | `hooks/hooks.json` 분리 | 두 방식 모두 지원 (plugin 설치 시 hooks.json 사용) |
| 2 | `.dotclaude-manifest.json` 버전 관리 | `plugin.json` 버전 관리 | plugin.json에 통합, manifest는 수동 설치용 유지 |

### Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | 수동 설치 (cp -r) 후 사용 | 기존처럼 동작 (settings.json의 상대 경로 사용) |
| 2 | plugin 설치 후 사용 | ${CLAUDE_PLUGIN_ROOT} 경로로 hook 실행 |
| 3 | plugin 설치 후 수동 업데이트 시도 | 경고 메시지 표시 |

---

## Open Questions

- [x] dotclaude 이름 사용 가능 여부 → 확인 필요 (marketplace 등록 시)
- [ ] plugin marketplace 공식 등록 절차 → 조사 필요
- [ ] global vs project 설치 분리 지원 여부 → 추후 버전에서 고려

---

## References

- Issue #1: https://github.com/U-lis/dotclaude/issues/1
- Issue #6: https://github.com/U-lis/dotclaude/issues/6
- oh-my-claudecode: https://github.com/Yeachan-Heo/oh-my-claudecode
- Claude Code Plugin Marketplace Schema: https://anthropic.com/claude-code/marketplace.schema.json
