<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-primary-size-warn-off
doc_dir: 2026_11_02-primary-size-warn-off
target_version: 0.8.2
stage: pr
approved_at: 2026-11-02T10:24:47Z
approved_hash: 04a7261dca35a2ffd835146f2221f6165ba36be3ee7ce46d88d067b84e9530b7
decisions: []
handoff: ""
-->
# 메인 worktree 용량 경고 끄기 - Specification

## Overview

**Purpose**: 작업 문서가 쌓이는 메인 worktree의 용량 경고만 끌 수 있게 한다.

**Problem**: `workspace_size_ignore`는 `{working_directory}` 안의 항목을 고르는 설정이라, 작업 폴더가 많이 쌓인 메인의 경고를 끄려면 `*`를 써야 한다. 그러면 worktree 경고와 purge 압축까지 함께 꺼진다.

**Solution**: 메인 worktree의 용량 경고 여부만 정하는 설정을 추가한다.

---

## Functional Requirements

- [x] FR-1: `workspace_size_warn_primary`(boolean, 기본 `true`)가 `false`이면 세션의 worktree가 메인일 때 Stop 훅이 용량 경고를 내지 않는다.
- [x] FR-2: 설정이 `false`여도 메인이 아닌 worktree의 용량 경고는 그대로 나온다.
- [x] FR-3: 설정이 없거나 `true`이면 메인의 용량 경고는 지금과 같다.
- [x] FR-4: `commands/_contract.md`, `commands/configure.md`, `README.md`, `CHANGELOG.md`가 이 설정을 설명한다.

---

## Non-Functional Requirements

- [x] NFR-1: `/dotclaude:purge` 압축과 `workspace_size_ignore`, 미커밋 코드 차단은 이 설정의 영향을 받지 않는다.

---

## Out of Scope

- 용량 기준(10MB) 변경
- 경고를 세션당 1회로 줄이는 동작
