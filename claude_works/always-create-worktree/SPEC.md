<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../always-create-worktree
-->

# Always Create Worktree - Specification

**Source Issue**: https://github.com/U-lis/dotclaude/issues/29
**Target Version**: 0.3.0
**Type**: Bugfix
**Severity**: Minor

## Overview

SPEC 생성 시 branch를 분리할 때, 현재 `git checkout -b`로 현재 working tree에서만 branch를 전환하고 있다. 이를 `git worktree add`로 변경하여 항상 별도의 worktree를 생성해야 한다. 또한 SPEC.md metadata에 `worktree_path` 필드를 추가하여 이후 작업(design, code, merge 등)이 올바른 위치에서 수행되도록 해야 한다.

## User-Reported Information

### Bug Description
SPEC 생성 시 branch를 분리할 때 항상 worktree를 분리해야 하는데, 현재 `git checkout -b`로 현재 working tree에서만 작업함. SPEC.md에 worktree path를 기록해서 이후 작업이 올바른 위치에서 수행되도록 해야 함.

### Reproduction Steps
`init-xxx`에서 SPEC 작성 시점에 branch를 생성하는 부분이 있음. `git checkout -b`를 사용하여 현재 working tree에서 branch만 전환할 뿐, worktree를 분리하지 않음.

### User's Expected Cause
init-xxx config issue - 명령어 파일에서 worktree 사용 없이 단순 branch checkout만 수행.

### Severity
Minor (inconvenient but workaround available)

### Related Files
- `commands/init-feature.md`
- `commands/init-bugfix.md`
- `commands/init-refactor.md`
- `commands/init-github-issue.md`
- `commands/start-new.md`
- `commands/code.md`

### Impact Scope
All init workflows (init-feature, init-bugfix, init-refactor, init-github-issue) 모두 영향

## AI Analysis Results

### Root Cause Analysis

- **Location**: `commands/start-new.md:85` - branch 생성 시 `git checkout -b {type}/{keyword}` 사용
- **Why**: worktree는 parallel phases (Step 10)에서만 사용되고, init phase에서는 사용하지 않음
- **Impact**: SPEC.md metadata에 `worktree_path` 필드가 없어서 downstream 명령어가 worktree 위치를 알 수 없음

### Affected Code Locations (6 files)

| # | File | Affected Area | Change Required |
|---|------|---------------|-----------------|
| 1 | `commands/start-new.md` | Line 85: branch 생성 로직, SPEC metadata 정의, parallel phase base, merge step cleanup | `git checkout -b` -> `git worktree add`, metadata에 `worktree_path` 추가, parallel phase base 변경, merge step에 worktree cleanup 추가 |
| 2 | `commands/init-feature.md` | Output section | worktree 생성 및 경로 참조 추가 |
| 3 | `commands/init-bugfix.md` | Output section | worktree 생성 및 경로 참조 추가 |
| 4 | `commands/init-refactor.md` | Output section | worktree 생성 및 경로 참조 추가 |
| 5 | `commands/init-github-issue.md` | Branch creation instructions (Step 5) | `git checkout -b` -> `git worktree add` 사용 |
| 6 | `commands/code.md` | worktree_path 참조, parallel phase base | feature worktree 기반 작업, parallel phase base를 feature worktree로 변경 |

### Fix Strategy

1. **Init 단계 branch 생성 변경**: `git checkout -b {type}/{keyword}`를 `git worktree add ../{subject} -b {type}/{keyword} {base_branch}`로 변경
2. **SPEC.md metadata 확장**: `worktree_path` 필드 추가 (예: `worktree_path: ../always-create-worktree`)
3. **Parallel phases base 변경**: config의 `base_branch`가 아닌 feature worktree를 base로 설정
4. **Merge step (Step 12) cleanup**: worktree 제거 로직 추가
5. **Downstream 명령어 업데이트**: 모든 후속 작업(mkdir, analysis, code execution)이 `worktree_path`를 기준으로 수행되도록 변경

### Conflict Analysis

- Parallel phases (3A, 3B, 3C) worktree 생성 시 base가 feature branch worktree여야 함 (main이 아님)
- 기존 `code.md`의 parallel phase handling 로직도 업데이트 필요
- `start-new.md`의 Step 10 parallel phase worktree 생성이 feature worktree 내에서 수행되어야 함

## Functional Requirements

- [ ] FR-1: Init phase에서 `git checkout -b {type}/{keyword}` 대신 `git worktree add ../{subject} -b {type}/{keyword} {base_branch}`를 사용하여 별도 worktree 생성
- [ ] FR-2: SPEC.md metadata block에 `worktree_path` 필드 추가 (예: `worktree_path: ../{subject}`)
- [ ] FR-3: Downstream 명령어(`/dotclaude:design`, `/dotclaude:code` 등)가 SPEC.md의 `worktree_path`를 읽어 해당 경로에서 작업 수행
- [ ] FR-4: `worktree_path`가 metadata에 없을 경우 현재 디렉토리(`.`)를 기본값으로 사용 (하위 호환성)
- [ ] FR-5: Parallel phases (3A, 3B, 3C) worktree 생성 시 base를 feature worktree로 설정 (`main`이 아닌 feature branch 기준)
- [ ] FR-6: Merge step (Step 12)에서 feature worktree cleanup 추가 (`git worktree remove`)
- [ ] FR-7: `init-feature.md`, `init-bugfix.md`, `init-refactor.md`, `init-github-issue.md` 모두 동일한 worktree 패턴으로 변경
- [ ] FR-8: 모든 후속 작업(directory 생성, analysis, code execution)이 `worktree_path` 기준으로 수행되도록 변경

## Non-Functional Requirements

- [ ] NFR-1: 기존 13-step workflow 구조 유지 (step 순서 및 구조 변경 없음)
- [ ] NFR-2: SPEC.md metadata 하위 호환성 유지 (`worktree_path` 미존재 시 현재 디렉토리 fallback)
- [ ] NFR-3: Worktree 잔여 디렉토리 처리 (이전 실행 중단으로 인한 잔여 worktree가 있을 경우 에러 메시지와 cleanup 안내)

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Worktree directory가 이미 존재 (이전 실행 중단으로 인한 잔여) | 에러 메시지 출력 후 cleanup 안내 또는 자동 정리 후 재생성 |
| 2 | Branch name이 이미 존재 | 기존 branch를 활용하거나 사용자에게 확인 요청 |
| 3 | Worktree 내부에 working directory 생성 | `{worktree_path}/{working_directory}/{subject}/` 경로로 정상 생성 |
| 4 | Merge step에서 worktree cleanup 실패 | 경고 메시지 출력, 수동 cleanup 안내 |
| 5 | Parallel phases의 base = feature worktree (not main) | feature branch에서 파생된 parallel branch 생성 확인 |

## Constraints

- 기존 workflow의 13-step 구조 유지
- SPEC.md metadata 하위 호환성 유지 (`worktree_path`가 없으면 현재 디렉토리 사용)
- `init-feature`, `init-bugfix`, `init-refactor`, `init-github-issue` 모두 동일한 패턴으로 변경
- `commands/start-new.md`가 중앙 워크플로우 컨트롤러이므로 해당 파일의 변경이 핵심

## Out of Scope

- Worktree 관리 UI/UX 개선
- 동시 다중 작업 세션 지원
- IDE worktree 통합
- Worktree 자동 정리 스케줄러
- 기존 완료된 작업의 마이그레이션

## Open Questions

(None at this time - all requirements are clear from the issue and analysis.)
