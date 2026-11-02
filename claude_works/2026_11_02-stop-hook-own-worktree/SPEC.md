<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-stop-hook-own-worktree
doc_dir: 2026_11_02-stop-hook-own-worktree
target_version: 0.8.1
github_issue: 113
stage: pr
approved_at: 2026-11-02T09:50:44Z
approved_hash: f57c7fc04644f9371bf8d40bf4549f422e8fda9249379fcf9248eef821e0b7cb
decisions: []
handoff: ""
-->
# Stop 훅 미커밋 차단을 세션 worktree로 한정 - Specification

## Overview

**Purpose**: Stop 훅의 미커밋 코드 차단이 세션이 일하는 worktree만 보게 한다.

**Problem**: 훅이 저장소의 모든 worktree를 훑어, 다른 세션이 맡은 worktree의 미커밋 파일로 이 세션의 응답 종료를 매 턴 차단한다 (#113). 0.8.0은 용량 경고만 세션 worktree로 좁혔다.

**Solution**: 차단 검사도 세션 cwd가 속한 worktree만 대상으로 한다.

---

## Functional Requirements

- [x] FR-1: 세션 cwd가 속한 worktree(하위 디렉터리 포함)에 미커밋 코드가 있으면 지금과 같은 조건으로 차단한다.
- [x] FR-2: 다른 worktree의 미커밋 코드로는 차단하지 않는다. 세션이 메인에 있어도 같다.
- [x] FR-3: `README.md`, `commands/_contract.md`, `docs/ARCHITECTURE.md`, `CHANGELOG.md`가 이 범위를 설명한다.

---

## Non-Functional Requirements

- [x] NFR-1: SPEC stage 조건, `stop_hook_active`, git 저장소 밖 처리, 용량 경고는 바뀌지 않는다.

---

## Out of Scope

- 세션이 수정한 경로를 transcript로 추적하는 방식
- 다른 worktree 미커밋에 대한 비차단 경고
