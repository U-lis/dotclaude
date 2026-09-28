# Phase 1: Test Cases

## Test Coverage

Coverage: N/A. No executable test suite exists in this repository (Markdown plugin). The 70% figure is a reference, not a gate.

## Test Strategy

All verification is by file-content inspection using grep and read checks. Each check below is a deterministic command against the resulting filesystem state. Pass/fail is determined by matching the expected output.

All paths are relative to the worktree root: `/home/ulismoon/Documents/dotclaude/dotclaude-feature-pruner-test-slimming`.

---

## Behaviors to Verify

### B-1: `agents/pruner.md` frontmatter is exactly as specified (AD-1)

Verification layer: grep checks (file content)

- [ ] B-1.1: `name: pruner` appears exactly once at a line start in the frontmatter
  ```bash
  grep -c '^name: pruner$' agents/pruner.md
  ```
  Expected: `1`

- [ ] B-1.2: `model: claude-sonnet-4-6` appears exactly once at a line start
  ```bash
  grep -c '^model: claude-sonnet-4-6$' agents/pruner.md
  ```
  Expected: `1`

- [ ] B-1.3: `tools: Read, Grep, Glob, Bash` appears exactly once at a line start
  ```bash
  grep -c '^tools: Read, Grep, Glob, Bash$' agents/pruner.md
  ```
  Expected: `1`

### B-2: Both operating modes are documented (FR-1)

Verification layer: grep checks (file content)

- [ ] B-2.1: Doc Mode and Code Mode sections both present
  ```bash
  grep -cE 'Doc Mode|Code Mode' agents/pruner.md
  ```
  Expected: `>=2`

### B-3: Criterion 1 uses the AD-6 English text (AD-6)

Verification layer: grep checks (file content)

- [ ] B-3.1: "branch combinations" phrase present (AD-6 verbatim language)
  ```bash
  grep -ci 'branch combinations' agents/pruner.md
  ```
  Expected: `>=1`

### B-4: Safeguards are present in both modes (FR-1, edge cases #1, #2, #10)

Verification layer: grep checks (file content)

- [ ] B-4.1: "Nothing to prune" appears at least twice (Doc Mode and Code Mode safeguards, plus Output Format)
  ```bash
  grep -c 'Nothing to prune' agents/pruner.md
  ```
  Expected: `>=2`

- [ ] B-4.2: "Keep at least one test per behavior" appears at least twice (Doc Mode and Code Mode safeguards)
  ```bash
  grep -c 'Keep at least one test per behavior' agents/pruner.md
  ```
  Expected: `>=2`

### B-5: Logic-change prohibition is stated (FR-1)

Verification layer: grep checks (file content)

- [ ] B-5.1: "Never suggest logic changes" present
  ```bash
  grep -c 'Never suggest logic changes' agents/pruner.md
  ```
  Expected: `>=1`

### B-6: Forbidden Bash operations listed in body (AD-1, NFR-2)

Verification layer: grep checks (file content)

- [ ] B-6.1: `sed -i`, `git reset --hard`, and `git stash` all appear (inside Forbidden Actions section)
  ```bash
  grep -cE 'sed -i|git reset --hard|git stash' agents/pruner.md
  ```
  Expected: `>=3`

### B-7: `docs/AGENT_MODEL_GUIDE.md` Current Assignments row added (AD-2)

Verification layer: grep check (file content)

- [ ] B-7.1: Row for `agents/pruner.md` present in AGENT_MODEL_GUIDE
  ```bash
  grep -F 'agents/pruner.md' docs/AGENT_MODEL_GUIDE.md
  ```
  Expected: `1` match (the added table row)

### B-8: No other agent files were modified (scope guard)

Verification layer: git diff

- [ ] B-8.1: Only `agents/pruner.md` (new) and `docs/AGENT_MODEL_GUIDE.md` changed
  ```bash
  git diff main --name-only
  ```
  Expected: exactly `agents/pruner.md` and `docs/AGENT_MODEL_GUIDE.md` (plus any design doc files under `claude_works/`). No other files under `agents/`, `commands/`, or `templates/`.

## FR / NFR Coverage Mapping

| Requirement | Covered by |
|-------------|------------|
| FR-1 (agents/pruner.md created with two modes, safeguards, output format) | B-1, B-2, B-3, B-4, B-5, B-6 |
| NFR-2 (pruner report-only, no file edits) | B-6 |
| NFR-3 (English language in agent doc) | Read `agents/pruner.md` and confirm body is in English |
| SPEC constraint: model assignment per AGENT_MODEL_GUIDE | B-1.2, B-7 |
