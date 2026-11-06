<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-feature-reviewer-redesign
doc_dir: 2026_11_06-reviewer-redesign
target_version: 0.9.0
github_issue: 117
stage: code
approved_at: 2026-11-06T08:21:55Z
approved_hash: bb255d824d624be2f6ed0fb7f8a1238c5402e845a6cf779c8891943303614823
decisions: ["warn-commit-ok-for-markdown-phases", "evidence-raw-output-in-doc-dir", "evidence-commit-filled-by-orchestrator"]
handoff: "설계 문서 13개 작성, 검증 통과(마지막 경고 1건 수정). SPEC 본문이 D-6~D-10(원장 finding 줄은 reviewer가 직접 append)과 회차 용어로 바뀌어 재승인 대기. 재승인 후 approve, 설계 문서 커밋, stage code, phase 1 시작."
-->
# reviewer 재설계 - Specification

## Overview

**Purpose**: reviewer를 "작성자가 주장한 의도와 diff가 실제로 하는 일을 따로 구해 대조하는 외부 감사자"로 바꾼다. push 전 내부 점검과 팀원 PR 리뷰를 같은 절차로 수행하고, 사람이 읽을 양을 줄이는 보고서를 낸다.

**Problem**: 현행 reviewer는 SPEC/PLAN만 보고 diff를 훑는 읽기 전용 표 출력기다. 의도 자료(PRD, Jira)를 독립적으로 읽지 않고, 파급과 재발명을 조사하지 않으며, 테스트를 다시 돌리지 않고, 사람이 어디를 직접 봐야 하는지 알려 주지 않는다. ONE-7294 PR(#110~#112의 근거)은 내부 리뷰가 놓친 결함이 CodeRabbit 7회차에 걸쳐 되돌아왔다.

**Solution**: 기획서(`/home/ulismoon/Documents/dotclaude/dotclaude-reviewer-plan-2026-11-06.md`, 이하 "기획서")를 권위 문서로 삼아 다음을 구현한다. 한 에이전트가 phase / PR 두 깊이를 가진다. PR 깊이는 재진술, 의도 대조, 파급 조사, 재발명 조사, 증거 대조와 로컬 재실행, 중복 제거와 판정의 순서를 따르며, 재진술 전에 의도 자료를 열지 못하도록 PreToolUse 훅이 막는다. 증거 보고서 양식, 지식 기록, 리뷰 원장, 지적 처리 규약(#111 제안 1, 3)을 함께 도입한다.

원칙 P1~P7과 용어(재진술, 재진술 관문, 지식 기록, 원장)는 기획서 2장과 6~10장을 따른다. 이 SPEC은 그 내용을 복사하지 않고 검증 가능한 행동으로만 옮긴다.

---

## Functional Requirements

### Core Features
- [ ] FR-1: 한 reviewer 에이전트가 호출자가 넘기는 `Depth: phase | pr`로 두 깊이를 구분한다. phase 깊이는 SPEC과 해당 phase의 PLAN만 읽고, 축 2(scope)와 3(safety)만 채우며 나머지 세 축은 `n/a (phase depth)`로 답한다. 지식 기록, 열린 PR, 증거 보고서를 읽지 않고 아무것도 실행하지 않는다(단, 원장에 `finding` 줄을 덧붙이는 것은 예외이며 FR-12가 정한다). 출력은 현행 표 형식을 유지하고 마지막 줄이 정확히 `BLOCKERS: {n}`이라 `commands/code.md` 5단계가 그대로 동작한다.
- [ ] FR-2: PR 깊이 reviewer는 다음 순서로 진행한다 (기획서 6장). (1) diff와 주변 코드만으로 재진술한다. (2) 의도 대조: 누락 / 설명 없는 변경 / 불일치 / 모호함(질문)을 양방향으로 가린다. Jira 코멘트는 시간순으로 읽어 나중 결정이 앞 설명을 덮고, PRD와 Jira가 어긋나면 질문으로 낸다. (3) 파급 조사: 변경 심볼의 호출자, 같은 데이터를 읽고 쓰는 경로, 같은 파일을 고치는 열린 PR과 최근 머지, 고정 위험 구역 점검표(마이그레이션, 권한, 기본값 변경, 비밀값, 결제와 정산, 외부 발송)를 보고, 각 대상에 "영향 있음 / 없음 / 확인 불가"와 근거를 붙인다. (4) 재발명 조사: 새 함수, 클래스, 쿼리마다 기존 구현을 다시 검색하며 coder의 "Existing implementations" 기록은 주장으로만 취급한다. (5) 증거 대조(FR-8)와 로컬 재실행(FR-7). (6) PR의 기존 코멘트와 같은 지적은 내지 않고 "교차 확인됨"으로 표시한 뒤 판정한다. 근거(`file:line`, 검색어와 결과, 의도 자료 문장)가 없는 지적은 질문으로 내린다.
- [ ] FR-3: PR 깊이 보고서는 기획서 7장 형식을 따른다. 머리말에 판정 `PASS | PASS+NOTES | FAIL`과 3~5줄 요약, "사람이 직접 봐야 하는 곳"(개수 상한 없음; reviewer가 판정하지 못했고 되돌리기 어려운 곳만, 항목마다 `file:line`과 판정하지 못한 이유, 이유가 없으면 해당 축 절로 내림), "대충 봐도 되는 곳"을 둔다. 절은 재진술, `1 correctness`~`5 tests`(축마다 `checked`/`n/a`/`issue` 중 하나, 지적은 그것을 설명하는 첫 축에 한 번만), 같이 생각할 점, 확인하지 못한 것, 새로 알게 된 것이다. issue 행은 `file:line`과 심각도 Blocker/Major/Minor를 유지해 `commands/pr.md` 9f단계가 Review notes를 만들 수 있다. 판정은 Blocker가 하나 이상일 때만 `FAIL`이며 보고서도 마지막 줄이 `BLOCKERS: {n}`이다. PR 깊이 보고서는 사용자가 1차 독자이므로 설정 언어로 쓰고, phase 표는 영어를 유지한다.
- [x] FR-4: 재진술 관문. PR 깊이 리뷰가 시작되면 회차 디렉터리(FR-9) `{working_directory}/reviews/{YYYY_MM_DD}-{target}/r{n}/`에 상태 파일 `STATUS.md`가 있고, reviewer만 이 파일을 쓰며 재진술을 그 안의 재진술 절에 쓴다. 오케스트레이터는 호출 프롬프트에 그 회차 디렉터리 경로만 넘기고, reviewer는 PR 깊이에서 첫 행동으로 그 디렉터리에 Write 도구로 상태 파일을 만든다(reviewer는 Write를 가지며 상태 파일을 Write로만 쓰므로 훅은 `tool_input.file_path`에서 경로를 얻는다). 상태는 파일명이 아니라 파일 내용에 둔다. 새 PreToolUse 훅 `hooks/guard-review.sh`(`hooks/hooks.json`에 등록)는 훅 입력의 `agent_type`이 `dotclaude:reviewer`일 때만 동작하며, 동시에 여러 리뷰가 돌 수 있으므로(사용자 예상: 흔함) 상태 파일을 `agent_id`로 묶는다. 훅은 `dotclaude:reviewer`의 호출이 `{working_directory}/reviews/*/r*/` 아래 `STATUS.md`를 Write하는 것을 보면 `agent_id` → 상태 파일 경로 쌍을 기록하고, 같은 `agent_id`의 이후 호출은 그 파일 하나만 기준으로 검사한다. 회차마다 새 STATUS.md가 생기므로 앞 회차의 재진술이 다음 회차의 관문을 열 수 없다. "가장 최근 열린 디렉터리" 추정과 포인터 파일은 쓰지 않는다. 쌍이 기록된 reviewer 호출에서 재진술 절이 비어 있는 동안 (a) 이름이 설정 `review.intent_tools`에 맞는 MCP 도구 호출(기본값: 이름에 jira, atlassian, notion이 들어간 MCP 도구)과 (b) SPEC.md, `PHASE_*_PLAN_*.md`의 Read를 모두 거부하고, 재진술 절에 내용이 생기면 허용한다. 쌍이 없는 reviewer 호출은 의도 MCP 도구를 거부하며(상태 파일을 만들고 재진술을 먼저 쓰라는 메시지; phase 깊이는 이 도구를 쓰지 않으므로 잃는 것이 없다), SPEC.md와 `PHASE_*_PLAN_*.md` Read는 허용한다(phase 깊이가 읽어야 한다). 판정 기준은 상태 값이 아니라 내용 유무이며, 훅이 강제하는 전이는 이것 하나뿐이다. 다른 에이전트와 주 세션의 호출에는 훅이 아무것도 하지 않는다. 기존 훅처럼 내부 오류에는 fail open이다. 알려진 한계로 문서에 명시한다: Bash로 로컬 SPEC/PLAN을 읽는 우회는 완전히 막지 못하고, 상태 파일을 만들기 전에 SPEC을 읽는 PR 깊이 reviewer는 막히지 않는다(Jira/Notion은 여전히 막힌다). 2026-11-06 실험 결과: `--settings` 훅에서 입력 `agent_type`은 주 세션에서 null, 서브에이전트에서 `"dotclaude:reviewer"`였고 종료 코드 2는 대상 읽기만 거부했다(실행한 reviewer는 하나뿐이었다). 플러그인 `hooks.json` 경로의 훅과 MCP 호출 거부는 아직 확인하지 못했으며 phase 1에서 실험으로 확인한다.
- [ ] FR-5: PR 깊이 의도 자료는 reviewer가 직접 읽는다. reviewer의 도구 선언은 Jira와 Notion MCP 도구 사용을 허용해야 하고, 호출 프롬프트에는 대상과 티켓 키만 담기며 의도 자료의 내용은 담기지 않는다. 자료는 PRD(주로 Notion), Jira 설명과 코멘트, SPEC(있을 때), 그리고 SPEC 메타데이터에 `github_issue`가 있거나 PR 본문이 이슈를 링크할 때의 GitHub 이슈다. 읽지 못한 자료는 "확인하지 못한 것"에 적고 scope는 읽은 자료까지만 판단한다.
- [ ] FR-6: `/dotclaude:review`는 인자가 없으면 현재 브랜치를 PR 깊이로, `#N`이나 URL이면 그 PR을 PR 깊이로 리뷰한 뒤 기존 코멘트 처리 단계를 그대로 잇는다(읽기, 분류, 제안은 자동; 수정, 답글, resolve는 사용자가 말한 뒤에만, `commands/review.md:35-50`). reviewer와 review 단계는 GitHub에 아무것도 쓰지 않으며 `commands/review.md:57`(예외 사례 2)의 reviewer 표 게시 제안을 없앤다. 팀원 PR은 보고서로 리뷰가 끝난다.
- [ ] FR-7: 로컬 재실행(기획서 6장 "재실행 범위"). PR 깊이 reviewer는 테스트 러너와 격리된 테스트 DB, 로컬 docker DB 위의 서버 기동 후 호출을 스스로 실행하며, 임시 worktree에서 실행하고 끝나면 지운다. 터널이나 공유 DB가 필요한 확인, QA, 발송, 배포는 실행하지 않고 "실행 요청"으로만 낸다. 저장소의 기본 기동 명령이 터널을 쓰더라도 로컬 설정으로 띄운다. 환경 기동 방법은 대상 저장소의 Makefile, README, CLAUDE.md에서 찾으며 새 설정 키를 만들지 않는다. reviewer가 찾은 빠진 엣지는 임시 worktree 안에 테스트 코드로 써서 러너로 돌린다. 리뷰 대상 브랜치의 코드는 절대 수정하지 않는다(P4).
- [x] FR-8: 증거 보고서. 신규 `templates/EVIDENCE.md`, 위치 `{working_directory}/{doc_dir}/EVIDENCE.md`. 한 행은 단계(local/remote), 확인한 행동, 사전 데이터 준비, 실행한 명령 또는 조작, 결과 요약, 원본 출력 경로, 실행 시점의 커밋, 작성 주체이며 다른 사람이 그대로 따라 해 같은 결과를 볼 수 있어야 한다. 명령과 출력이 없는 행은 증거로 치지 않는다. 쓰는 주체는 coder(`commands/_coder-base.md`), run 단계의 오케스트레이터(`commands/start-new.md` Run stages), dotclaude 흐름 밖의 검증 역할 세션, 그리고 reviewer다. reviewer는 이 작업의 `{doc_dir}/EVIDENCE.md`를 읽을 수 있지만 쓰지 않으며, 자기 재실행 행은 자기 회차 디렉터리의 `EVIDENCE.md`에만 쓴다. `commands/_contract.md`에 양식 경로와 작성 규칙을 정의하는 절을 둔다. 팀원 PR에는 이 파일이 없고 CI 결과와 PR 본문 테스트 설명은 주장으로 읽으며, reviewer의 재실행 행은 회차 디렉터리의 EVIDENCE.md에만 남는다.
- [ ] FR-9: 리뷰 디렉터리(사용자 결정 2026-11-06). 모든 PR 깊이 리뷰(내 작업, 팀원 PR)는 주 체크아웃의 다음 구조에 쓴다. worktree에서 돌아도 주 체크아웃 경로를 쓴다.
  ```
  {working_directory}/reviews/{YYYY_MM_DD}-{target}/r{n}/
    REVIEW.md    (보고서)
    STATUS.md    (재진술과 진행; 관문 파일)
    EVIDENCE.md  (reviewer의 재실행 기록)
    *.log        (EVIDENCE 행이 가리키는 원본 출력; reviewer가 이 디렉터리에 쓴다)
  ```
  바깥 디렉터리의 날짜 형식은 작업 문서 디렉터리(`{YYYY_MM_DD}-{keyword}`, Contract: Names and paths)와 같고 경로 어디에도 시각을 넣지 않는다. `{target}`은 Jira 키가 있으면 그것, 없으면 `pr-{N}`, 그것도 없으면 브랜치 키워드다. 리뷰 한 회차마다 디렉터리 하나이며 오케스트레이터가 다음 `r{n}`(n = 1, 2, ...)을 만들고 프롬프트에는 그 경로만 넘긴다. 안의 파일 이름은 고정이며(`REVIEW.md`, `STATUS.md`, `EVIDENCE.md`), 그 밖에는 EVIDENCE 행이 가리키는 원본 출력 `.log` 파일만 둘 수 있다. reviewer는 자기 회차 디렉터리만 읽고 쓰며 앞 회차를 읽지 않는다(독립성: 뒤 회차가 앞 회차의 지적을 보면 안 된다). 고쳐졌는지는 현재 코드에서 새로 판단하고, 회차 사이의 변화는 원장에서 읽으며, 회차 간 자동 비교는 만들지 않는다. 다른 날짜의 리뷰는 새 날짜 디렉터리에서 r1로 시작한다. phase 리뷰는 현행대로 `{doc_dir}/REVIEW.md`에 추가한다.
- [ ] FR-10: 호출 연결. `/dotclaude:code`와 start-new Step 10은 reviewer를 `Depth: phase`로, 통합 전 전체 diff 리뷰(`commands/start-new.md` Run stages, `commands/pr.md` 9f단계)는 `Depth: pr`로 호출한다. `commands/_agent-prompts.md`의 reviewer 템플릿은 Depth, 대상, 티켓 키, 회차 디렉터리 경로, 보류 목록, 원장 경로(`{primary}/{working_directory}/review-ledger.log`), finding id 접두사(PR 깊이 `{target}-r{n}`, 단계 깊이 `{doc_dir}-p{k}`)를 담는다.

### Secondary Features
- [ ] FR-11: 지식 기록(기획서 9장). 입력은 설정 `knowledge_dirs`의 기존 조사 문서와 주 체크아웃의 `{working_directory}/knowledge/`이며, 읽기와 쓰기 모두 worktree에서 돌아도 주 체크아웃 경로를 쓴다. 기록 한 건은 파일 하나(`{date}-{target}-{n}.md`: 사실 한 줄, `file:line`, 확인한 커밋, 출처 리뷰)이고 추측과 저장된 색인은 없다. 인용 전에 코드가 지금도 그런지 확인하고, 확인 커밋 이후 해당 경로가 바뀌었으면 "오래됨"으로 표시한다. reviewer는 지식 전체를 읽거나 맥락에 전체 색인을 만들지 않는다. 변경된 경로와 심볼로 지식 디렉터리를 검색해 일치하는 기록만 읽는다. reviewer는 보고서의 "새로 알게 된 것"에 후보를 내고 명령이 파일로 쓴다.
- [ ] FR-12: 리뷰 원장(기획서 10장; 사용자 결정 2026-11-06). 주 체크아웃의 `{working_directory}/review-ledger.log`는 추가만 하는 이벤트 로그이며 한 줄이 탭으로 구분된 이벤트 하나다. 이벤트는 두 종류다. `finding`은 reviewer가 지적을 보고할 때 쓰며 id, date, target, depth, axis, kind, location, severity, verdict, must_see를 담는다. `disposition`은 나중에 finding id를 가리켜 추가하며 disposition(accepted/deferred/rebutted/ignored), defer_class(silent/loud), cross(coderabbit/human/none), later(missed/false-alarm), date를 담는다. 어떤 줄도 고치지 않으며 처분이 바뀌면 새 줄이므로 번복이 남고, 재리뷰는 새 finding 줄을 추가한다. `finding` 줄은 reviewer가 보고할 때 직접 추가한다(사용자 결정 D-10). 지적마다 한 줄을 셸 추가 쓰기(`printf ... >>`)로 쓰며, 원장을 읽지 않고 다시 쓰지도 않는다(Write 도구는 전체 내용을 요구하므로 쓰지 않는다; NFR-3, NFR-5). finding id는 읽지 않고도 정해지도록 PR 깊이 `{target}-r{n}-{행}`, 단계 깊이 `{doc_dir}-p{k}-{행}`이며 호출 명령이 프롬프트로 원장 경로와 id 접두사를 준다. 두 깊이 모두 finding 줄을 쓴다(단계 깊이가 "아무것도 실행하지 않는다"에서 갖는 유일한 예외). 호출 명령은 reviewer가 돌아온 뒤 이번 리뷰의 id 접두사를 가진 `finding` 줄 수가 보고서의 `issue` 행 수와 같은지 확인하고, 다르면 차이를 사용자에게 보고하며 원장을 직접 고치지 않는다. `disposition` 줄은 처분을 메인 세션에서 사용자와 정하므로 계속 명령이 추가한다. 사용자가 세션에서 처분을 말한 지적은 그때 쓰고, 나머지는 회고 세션에 남긴다. 회고 명령은 만들지 않는다. `hooks/workspace-archive.sh`는 바꾸지 않는다. `files` 모드는 `{working_directory}`의 최상위 디렉터리만 순회하므로(`hooks/workspace-archive.sh:317-318`) 최상위 파일 `review-ledger.log`는 보관 후보가 되지 않고, `preserve` 모드는 worktree에서 주 체크아웃으로 복사하는데 원장은 주 체크아웃에만 있다. 요구는 `tests/hooks/test_workspace_archive.sh`에 최상위의 추적되지 않는 100KB 초과 원장이 purge 보관 뒤에도 제자리에 남는다는 사례를 고정하는 것이며 코드 변경은 없다.
- [ ] FR-13: 지적 처리 규약(#111 제안 1, 3; 기획서 7장). 내 작업에서 지적의 처분은 수용 / 보류 / 거절이다. 보류에는 재현 결과와 분류가 필요하다. 조용한 누락(예외 없이 결과가 틀리거나 빠짐)은 보류할 수 없고 에러를 내는 가드로 막아야 한다. 시끄러운 실패는 보류할 수 있고 `{doc_dir}/REVIEW.md`의 `## Deferred` 절에만 "알려진 제약"으로 근거와 함께 적는다(PR 본문은 바꾸지 않는다). "시끄러운 실패" 판정은 입력의 모든 형태를 확인한 뒤에만 내린다. 보류 목록은 PR 깊이 리뷰의 입력이며 reviewer는 각 건을 재현해 분류를 다시 판정한다.
- [ ] FR-14: 설정 `review.intent_tools`와 `knowledge_dirs`를 `commands/_contract.md` Configuration 표에 문서화하고 `/dotclaude:configure`로 설정할 수 있다.

---

## Non-Functional Requirements

### Testing
- [x] NFR-1: `tests/hooks/test_guard_review.sh`를 `tests/hooks/test_guard_design.sh` 방식으로 둔다. 사례: `{working_directory}/reviews/*/r*/STATUS.md` Write 시 agent_id와 경로 쌍 기록(쓰기 시점 묶기; 같은 대상의 `r1`과 `r2`는 서로 다른 쌍, `r1`의 재진술은 `r2`의 관문을 열지 않음), reviewer + 쌍 있음 + 재진술 비어 있음 + 의도 MCP 도구 → deny, 같은 조건 + SPEC Read → deny, 재진술 채워짐 → allow, 동시성(agent_id가 다른 두 reviewer가 각자 `r{n}/STATUS.md`를 가짐; 하나는 재진술을 썼고 하나는 쓰지 않음 → 앞의 것 allow, 뒤의 것 deny), 쌍 없는 reviewer + 의도 MCP 도구 → deny, 쌍 없는 reviewer + SPEC/PLAN Read → allow, 다른 `agent_type`이나 null → allow, 기록된 쌍이 없고 `STATUS.md`도 없는 비reviewer 호출 → allow, 잘못된 입력 → allow. `tests/hooks/run_all.sh`는 계속 통과한다. `tests/hooks/test_workspace_archive.sh`에는 최상위의 추적되지 않는 100KB 초과 원장이 purge 보관 뒤에도 제자리에 남는 사례를 더한다(코드 변경 없이 고정만).
- [ ] NFR-2: 프롬프트 phase는 검증기가 아니라 실행으로 검증한다. worktree의 플러그인을 불러와(`claude --plugin-dir`로 추정, 미확인이므로 첫 phase에서 확인) 새 reviewer를 Zero-X-Flow/1Hour_Back의 PR 두 건에 돌린다. #3493(단순: "fix: [ONE-7384] teacher edit API 위협 제거", 3파일, +98/-97)과 #3459(복잡: ONE-7294, #110~#112의 근거 PR, 내부 리뷰가 놓친 결함이 CodeRabbit 7회차 16건으로 되돌아옴). 결과는 이 작업의 EVIDENCE.md에 새 양식으로 기록한다(첫 사용). #3459는 오염을 피하려고 이른 head 커밋을 리뷰하고 PR의 기존 리뷰 코멘트를 주지 않으며, #110/#111/#112에 적힌 알려진 결함(3단계 중첩 접두사 버그 CR-5, CR-2/6/10/12로 되돌아온 보류 지적 등)을 잡는지를 본다.

### Security
- [ ] NFR-3: reviewer는 GitHub에 쓰지 않고, 자기 회차 디렉터리(`REVIEW.md`, `STATUS.md`, `EVIDENCE.md`와 EVIDENCE 행이 가리키는 원본 출력 `.log` 파일)와 자기 임시 worktree, 그리고 원장에 `finding` 줄을 덧붙이는 것 밖에는 아무것도 쓰지 않는다. 작업의 `{doc_dir}/EVIDENCE.md`는 읽기만 하고, 원장에는 `finding` 줄을 셸 추가 쓰기(`printf ... >>`)로 덧붙이기만 하고(Write 도구로 쓰지 않는다) 읽지는 않는다(FR-12, NFR-5).

### Reliability
- [ ] NFR-4: 기존 동작을 유지한다. `BLOCKERS: {n}` 파싱, phase당 Blocker 수정 1회, PR 코멘트 처리 단계, 커밋 가드 마커.

### Performance
- [ ] NFR-5: reviewer가 한 회차에 읽는 양은 리뷰 대상 변경의 크기에 따라서만 늘고 과거 리뷰의 수에는 늘지 않는다. 구체적으로: 자기 회차 디렉터리만 읽고, 원장은 읽지 않으며(reviewer는 `finding` 줄을 추가만 하고 `disposition` 줄은 명령이 추가한다), 지식은 목표 검색으로만 읽고, 그 작업의 EVIDENCE.md는 그 작업으로 한정되며 커밋이 리뷰 중인 head와 다른 행은 읽지 않고 오래됨으로 표시만 하고, 보류 목록은 그 작업으로 한정된다.

---

## Constraints

### Technical Constraints
- Language/Framework: Markdown 프롬프트 파일(agents, commands, templates)과 bash 훅(`hooks/*.sh`, `hooks/_lib.sh`의 `json_get`, `cfg_get`, `find_worktrees`, `deny_pretool` 사용)
- Database: 해당 없음 (재실행 대상 저장소의 로컬 docker DB만 사용)
- External Dependencies: Jira와 Notion MCP, `gh` CLI, 대상 저장소의 로컬 docker. 플러그인 에이전트는 자기 전용 훅이나 mcpServers를 선언할 수 없으므로(https://code.claude.com/docs/en/sub-agents) 훅은 플러그인 수준 `hooks/hooks.json`에 둔다. reviewer의 `tools` 선언은 MCP를 쓰고 파일을 쓸 수 있게 designer가 정한다(`tools` 생략으로 상속, 또는 서버 와일드카드 나열).
- 다른 모델 계열은 쓰지 않고, 에이전트는 하나다(분할은 원장의 `axis` 열을 쓴 회고 뒤 재검토).
- phase 순서는 사용자가 승인했다(여섯 phase, designer는 4 초과를 되묻지 않는다): (1) 재진술 관문 훅 + 테스트 + 실험(플러그인 hooks.json 경로, MCP 거부, worktree 플러그인 로딩, 동시에 도는 두 reviewer가 서로 다른 `agent_id`를 받는지(2026-11-06 실험은 하나만 실행), 훅이 Write 호출에서 상태 파일 경로를 안정적으로 얻는지). 훅 방식이 여기서 막히면 reviewer를 두 번 호출하는 안(재진술 호출 후 의도 호출)으로 바꾼다. (2) 증거 양식과 계약. (3) reviewer 재작성과 프롬프트 템플릿. (4) `/dotclaude:review`의 리뷰 부분. (5) phase 호출과 통합 전 리뷰 연결. (6) 원장, 지식 기록, 처리 규약, 설정.
- 이 작업을 진행하는 흐름이 부르는 reviewer는 worktree의 것이 아니라 설치된 0.8.x 버전이다. 그래서 NFR-2의 실행 검증이 필요하다.

### 충돌과 해소
- `commands/_contract.md` Git safety("The pruner and the reviewer never modify files. Their Bash use is read-only.")와 `agents/reviewer.md:49-53`은 이번 요구(보고서, 상태 파일, 증거 행 쓰기, 임시 worktree에서 테스트 실행)와 충돌한다. 해소: "리뷰 대상 코드와 worktree는 수정하지 않고, 자기 회차 디렉터리(`REVIEW.md`, `STATUS.md`, `EVIDENCE.md`, 원본 출력 `.log`), 임시 worktree, 원장에 덧붙이는 `finding` 줄에만 쓴다"로 좁힌다(NFR-3).
- `hooks/guard-workspace.sh`와 계약의 Names and paths는 `{working_directory}`에 `.md`, `.json`, `.log`만 허용하고 이름 규칙을 강제한다. designer는 `reviews/`, `knowledge/` 하위 파일이 이 규칙을 통과하는지 확인하고 아니면 훅을 확장한다. 원장 `review-ledger.log`는 `.log`이므로 `hooks/guard-workspace.sh:49`를 이미 통과한다(`.jsonl`은 51행에서 명시적으로 거부되므로 쓰지 않는다; 사용자 결정 D-1, 2026-11-06).
- 관련 코드: `hooks/workspace-archive.sh`는 수정하지 않는다(FR-12, D-6). `tests/hooks/test_workspace_archive.sh`에 원장이 제자리에 남는 사례만 더한다.
- `docs/ARCHITECTURE.md`의 reviewer 줄과 훅 목록을 갱신한다(D-9).
- 계약의 Language 절은 에이전트 보고서를 영어로 정하지만 PR 깊이 보고서는 설정 언어다. SPEC.md처럼 사용자가 읽는 문서이므로 설정 언어 목록에 추가한다.

### Business Constraints
- Timeline: 마일스톤 0.9.0
- Budget: 해당 없음

---

## Data Migration

Not applicable

---

## Edge Cases

| FR | Partition | Case | Expected |
|----|-----------|------|----------|
| FR-1 | normal | phase 깊이 호출 | 축 1, 4, 5는 `n/a (phase depth)`인 표, 마지막 줄 `BLOCKERS: {n}` |
| FR-3 | boundary | 어느 축에도 지적 없음 | 판정 PASS, 모든 축이 본 것을 적은 `checked` 또는 `n/a` |
| FR-4 | invalid | 재진술을 쓰기 전에 Jira MCP 도구 호출 | 거부, 재진술부터 쓰라는 메시지 |
| FR-4 | normal | 회차 디렉터리 `r{n}/STATUS.md`의 재진술에 내용이 생긴 뒤 같은 호출 | 허용 |
| FR-4 | permission | `r{n}/STATUS.md`가 있는 동안 reviewer 아닌 에이전트나 주 세션이 같은 호출 | 허용 |
| FR-4 | error | `STATUS.md` 경로를 읽을 수 없거나 훅 입력이 잘못됨 | 허용 (fail open) |
| FR-4 | concurrency | reviewer 둘이 동시에 돌고 각자 `r{n}/STATUS.md`가 있음; 하나는 재진술을 썼고 다른 하나는 쓰지 않음 | 앞의 것은 허용, 뒤의 것은 거부 |
| FR-4 | boundary | 기록된 쌍이 없는 reviewer가 의도 MCP 도구를 호출 / SPEC을 Read | MCP 도구는 거부(`STATUS.md`를 만들고 재진술부터 쓰라는 메시지), SPEC Read는 허용 |
| FR-9 | boundary | 같은 대상을 같은 날 두 번 리뷰 | 두 번째는 `r2/`에 쓰고 `r1/`은 건드리지도 읽지도 않음 |
| FR-9 | boundary | 같은 대상을 더 늦은 날짜에 리뷰 | 새 날짜 디렉터리의 `r1/` |
| FR-5 | error | Jira나 Notion을 읽을 수 없음 (MCP 없음, 인증 실패) | "확인하지 못한 것"에 적고 읽은 자료까지만 scope 판단, 리뷰는 계속 |
| FR-6 | invalid | `#N`이 PR이 아니라 이슈 | 기존 오류 메시지, 리뷰 없음 (`commands/review.md:18` 유지) |
| FR-6 | boundary | 현재 브랜치에 변경 없음 | "Nothing to review." (유지) |
| FR-7 | error | 로컬 환경을 띄울 수 없음 (docker 없음, Makefile 대상 없음) | 사유와 함께 "실행하지 못함"으로 기록, 터널 대체 없음 |
| FR-7 | permission | 터널이나 공유 DB가 필요한 확인 | 실행하지 않고 "실행 요청"으로 기록 |
| FR-8 | invalid | 명령이나 원본 출력이 없는 증거 행 | 증거로 치지 않고 축 5에서 보고 |
| FR-8 | boundary | 증거의 커밋이 리뷰 중인 head와 다름 | 오래된 증거로 보고 |
| FR-11 | boundary | 인용 경로가 확인 커밋 이후 바뀐 지식 기록 | "오래됨"으로 표시, 사실로 인용하지 않음 |
| FR-11 | boundary | 지식 디렉터리에 변경과 무관한 기록이 많음 | 그중 어느 것도 읽지 않음 |
| FR-12 | normal | 같은 대상 재리뷰 | 새 finding 줄 추가, 기존 줄 불변 |
| FR-12 | normal | 처분이 바뀜 | 새 disposition 줄 추가, 이전 줄 불변 |
| FR-12 | error | 이번 리뷰의 id 접두사를 가진 finding 줄 수가 보고서의 issue 행 수와 다름 | 명령이 불일치(차이)를 사용자에게 보고, 원장은 손대지 않음 |
| FR-12 | boundary | 원장이 100KB를 넘고 추적되지 않은 채 purge 보관 실행 | 원장은 제자리에 남음 |
| FR-13 | invalid | 재현 결과나 분류 없는 보류, 또는 조용한 누락의 보류 | 보류로 인정하지 않고 열린 지적으로 남음 |

---

## Out of Scope

The following are explicitly NOT part of this work:
- #110 (SPEC 입력 계약 절), #112 (PR 코멘트 분류 개편), #111 제안 2 (입력 계약 절과 묶인 scope 축 문구): 사례를 더 모은 뒤 결정한다
- GitHub 코멘트 게시 기능, 답글 명령, 회고 명령
- 서비스 지도 일괄 생성
- 다중 에이전트 분할, 다른 모델 계열
- 사람 리뷰 없는 자동 머지
- 리뷰 회차 간 자동 비교(앞 회차 지적의 해소 여부 대조): reviewer는 앞 회차를 읽지 않고 현재 코드에서 새로 판단하며, 회차 사이의 변화는 원장에서 읽는다
- Stop/commit 훅의 변경: 이 훅들은 코드만 본다. 주 체크아웃 `{working_directory}`의 증거와 보고서 파일을 커밋할지는 기존 `workspace_tracking` 규칙에 맡긴다

---

## Assumptions

- 플러그인 hooks.json에 둔 PreToolUse 훅이 서브에이전트 호출에도 실행되고 입력에 `agent_type`이 온다 (https://code.claude.com/docs/en/hooks; phase 1 실험으로 확인).
- reviewer가 Jira와 Notion MCP를 플러그인 경유로 읽을 수 있다 (기획서 3장의 전제).
- 훅이 MCP 도구 호출도 종료 코드 2로 거부할 수 있다 (Read 거부만 확인됨; phase 1 실험으로 확인).
- worktree의 플러그인은 `claude --plugin-dir`로 불러올 수 있다 (기억상의 정보, 미검증; phase 1에서 확인).
- 1Hour_Back 저장소는 로컬 docker DB와 `api.settings.local` 기반 테스트로 재실행할 수 있다 (기획서 6장).

### 결정된 사항 (2026-11-06, 사용자)

- D-1 (원장 형식): 주 체크아웃 `{working_directory}/review-ledger.log`, 탭으로 구분한 추가 전용 이벤트 로그(`finding`, `disposition`). 이전 권고(마크다운 표)와 달리 이벤트 로그로 결정했다. 보관 스크립트는 바꾸지 않는다(D-6, FR-12).
- D-2 (동시 리뷰의 상태 파일 식별): 훅 입력의 `agent_id`로 묶는다. 상태 파일 Write 시 쌍을 기록하고 이후 호출은 그 파일만 본다(FR-4). 이전 권고(가장 최근 열린 디렉터리)는 채택하지 않았다.
- D-3 (리뷰 디렉터리 배치): `{working_directory}/reviews/{YYYY_MM_DD}-{target}/r{n}/` 아래 고정 이름 `REVIEW.md`, `STATUS.md`, `EVIDENCE.md`. 경로에 시각을 넣지 않고 회차마다 `r{n}`을 새로 만들며 reviewer는 자기 회차만 읽는다. 회차 간 자동 비교는 만들지 않는다(FR-4, FR-9, Out of Scope).
- D-4 (지식 기록 읽기): reviewer는 지식 전체를 읽거나 전체 색인을 만들지 않고, 변경된 경로와 심볼로 검색해 일치하는 기록만 읽는다(FR-11).
- D-5 (읽기량 상한): 한 회차에서 reviewer가 읽는 양은 변경의 크기에만 비례하고 과거 리뷰 수에는 비례하지 않는다(NFR-5).
- D-6 (보관 스크립트 불변): `hooks/workspace-archive.sh`는 바꾸지 않는다. `files` 모드는 `{working_directory}` 최상위 디렉터리만 순회하고(`hooks/workspace-archive.sh:317-318`) `preserve` 모드는 worktree에서 주 체크아웃으로 복사하므로 주 체크아웃에만 있는 최상위 원장은 보관 후보가 아니다. `tests/hooks/test_workspace_archive.sh`에 최상위의 추적되지 않는 100KB 초과 원장이 제자리에 남는 사례만 고정한다(FR-12).
- D-7 (EVIDENCE 쓰기 범위): reviewer의 재실행 행은 자기 회차 디렉터리의 `EVIDENCE.md`에만 쓴다. 작업의 `{doc_dir}/EVIDENCE.md`는 읽되 쓰지 않는다(FR-8, NFR-3).
- D-8 (보류 기록 위치): 시끄러운 실패의 "알려진 제약"은 `{doc_dir}/REVIEW.md`의 `## Deferred` 절에만 적고 PR 본문은 바꾸지 않는다(FR-13).
- D-9 (아키텍처 문서): `docs/ARCHITECTURE.md`의 reviewer 줄과 훅 목록을 갱신한다.
- D-10 (finding 줄의 작성자): `finding` 줄은 호출 명령이 아니라 reviewer가 보고할 때 직접 원장에 추가한다. 이유는 지적의 기록을 쓴 사람이 하나(산문 보고서를 다른 모델이 옮겨 적지 않고, 그 시점에 reviewer가 말한 그대로)이고 구현할 곳이 호출 지점 다섯 곳(`code.md`, start-new Step 10, start-new Run stages, `pr.md` 9f, `review.md`)이 아니라 한 곳이기 때문이다. reviewer는 셸 추가 쓰기(`printf ... >>`)로 지적마다 한 줄을 쓰고 원장을 읽거나 다시 쓰지 않는다. id는 PR 깊이 `{target}-r{n}-{행}`, 단계 깊이 `{doc_dir}-p{k}-{행}`로 읽지 않고 정해지며 접두사는 호출 명령이 프롬프트로 준다. 호출 명령은 돌아온 뒤 id 접두사별 `finding` 줄 수와 보고서 `issue` 행 수가 같은지만 확인하고 다르면 사용자에게 보고하며 원장을 고치지 않는다. `disposition` 줄은 처분을 메인 세션에서 사용자와 정하므로 명령이 계속 추가한다. 두 깊이 모두 finding 줄을 쓰며, 단계 깊이가 아무것도 실행하지 않는다는 규칙의 유일한 예외다(FR-12, NFR-3, NFR-5, FR-10).

---

## Open Questions

- [ ] 플러그인 `hooks.json`의 훅이 reviewer 서브에이전트 호출에서 `agent_type`을 받고 MCP 호출을 거부하는가? 아니면 재진술 호출과 의도 호출로 reviewer를 두 번 부르는 대안을 쓴다 (phase 1 실험).
- [ ] 동시에 도는 두 reviewer가 실제로 서로 다른 `agent_id`를 받는가 (2026-11-06 실험은 하나만 실행; phase 1).
- [ ] 훅이 reviewer의 Write 호출에서 `tool_input.file_path`로 상태 파일 경로를 안정적으로 얻는가 (phase 1).
- [ ] `claude --plugin-dir`로 worktree 플러그인을 불러올 수 있는가 (phase 1).
- [ ] `reviews/`, `knowledge/` 하위 파일이 `guard-workspace.sh`의 이름 규칙과 파일 형식 규칙을 통과하는가 (designer 확인).
- [ ] reviewer의 `tools` 선언 방식: `tools` 생략 상속과 서버 와일드카드 나열 중 무엇을 쓸 것인가 (designer 결정).

---

## Decisions Required

남은 결정 없음. D-1, D-2는 2026-11-06에 결정되어 Assumptions의 "결정된 사항"에 기록했다.

---

## References

- https://github.com/U-lis/dotclaude/issues/117 (이 작업), https://github.com/U-lis/dotclaude/issues/111 (제안 1, 3 흡수)
- 기획서: `/home/ulismoon/Documents/dotclaude/dotclaude-reviewer-plan-2026-11-06.md`
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/sub-agents
- https://yozm.wishket.com/magazine/detail/4027/
- https://github.com/cursor/plugins/tree/main/pstack
