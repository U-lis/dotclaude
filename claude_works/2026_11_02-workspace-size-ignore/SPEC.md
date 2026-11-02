<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: .
doc_dir: 2026_11_02-workspace-size-ignore
target_version: 0.8.0
stage: code
approved_at: 2026-11-02T07:16:31Z
approved_hash: fae776f606431091077eac7b13842f61b9d97055395da6d9e17dd56c3677d49f
decisions: []
handoff: ""
-->
# 워크스페이스 용량 경고 범위 조정과 purge 아카이브 - Specification

## Overview

**Purpose**: Stop 훅 용량 경고를 쓸모 있는 수준으로 좁히고, purge가 워크스페이스의 대용량 파일을 레포별 아카이브로 내보내게 한다.

**Problem**: 0.7.0의 경고는 모든 worktree를 재서 다른 worktree 세션에도 메인 경고가 뜨고, 작업 문서가 쌓이는 메인 디렉터리에서는 끌 방법이 없다. purge에는 용량을 줄이는 단계가 없고, 날짜 없는 작업 폴더는 언제 처리했는지 남지 않는다.

**Solution**: 경고는 세션의 worktree만 재고 무시 목록을 둔다. 정리 로직은 테스트 가능한 스크립트 `hooks/workspace-archive.sh`로 두고 purge는 이를 호출한다.

---

## Functional Requirements

### Core Features
- [x] FR-1: Stop 훅 용량 경고는 세션 cwd가 속한 worktree의 `{working_directory}`만 잰다.
- [x] FR-2: `workspace_size_ignore`(glob 배열)에 맞는 `{working_directory}` 최상위 항목은 용량에서 뺀다.
- [x] FR-3: 경고에 가장 큰 항목 이름과 크기를 표시한다.
- [x] FR-4: `workspace-archive.sh files`는 로그·텍스트 데이터를 gzip하고 이미지·스프레드시트·테스트 산출물을 그대로 `{workspace_archive_dir}/{메인 checkout 이름}/{doc_dir}/` 아래로 옮기며, 파일마다 메인의 `{doc_dir}/ARCHIVED.md`에 기록한다.
- [x] FR-5: 다음은 대상에서 뺀다: git 추적 파일, `.md`, 코드, 100KB 이하, 24시간 내 수정, 열려 있는 파일, 무시 목록 항목, `--exclude` 항목, 남는 worktree에 같은 이름이 있는 메인의 doc dir.
- [x] FR-6: `workspace_archive_dir`이 없으면 apply는 exit 3으로 멈추고 아무것도 바꾸지 않으며, purge는 위치를 임의로 정하지 않고 묻는다.
- [x] FR-7: `workspace-archive.sh preserve`는 지워질 worktree의 문서를 메인에 덮어쓰지 않고 복사한다. 날짜 없는 doc dir에는 `YYYY_MM_DD-`를 붙이고, 메인에 이미 있는 폴더 이름은 바꾸지 않는다.
- [x] FR-8: `workspace-archive.sh deps`는 남는 worktree의 심링크 아닌 `.venv`/`venv`를 지우고, `worktree.share_from_base`가 켜져 있고 메인에 같은 디렉터리가 있으면 상대 심링크로 잇는다. 세션의 worktree는 건너뛴다.
- [x] FR-9: `$CLAUDE_CONFIG_DIR/dotclaude-config.json`을 `~/.claude`와 저장소 config 사이에서 읽는다.

### Secondary Features
- [x] FR-10: `commands/purge.md`는 미리보기·확인·실행 단계에서 스크립트를 호출하고, `_contract.md`, `configure.md`, `README.md`, `CHANGELOG.md`가 새 설정과 동작을 설명한다.

---

## Non-Functional Requirements

- [x] NFR-1: 복사본 검증에 실패하거나 내용이 다른 파일이 목적지에 있으면 원본을 지우지 않고 exit 1로 보고한다.

---

## Out of Scope

- 메인에 이미 있는 날짜 없는 폴더의 이름 변경 (초기 생성분으로 보존)
- 프로젝트별 로컬 purge 커맨드 (dotclaude 저장소 밖)
