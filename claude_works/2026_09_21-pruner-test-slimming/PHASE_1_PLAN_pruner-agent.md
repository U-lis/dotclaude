# Phase 1: Pruner Agent Foundation

## Objective

Create `agents/pruner.md` as the new report-only pruner agent, and add its model assignment row to `docs/AGENT_MODEL_GUIDE.md`.

## Prerequisites

- None. Phase 1 has no upstream dependencies.

## Instructions

### Step 1: Create `agents/pruner.md`

Create the file `agents/pruner.md` from scratch. The file must conform to all existing agent conventions (frontmatter fields, Language section, Output Format section). Refer to `agents/code-validator.md` lines 1-17 for the frontmatter + Language section pattern.

**Frontmatter** (exact content, per AD-1):
```yaml
---
name: pruner
model: claude-sonnet-4-6
description: Analyze and report deletion/merge candidates for tests and docstring/comment trim candidates. Report-only, never modifies files.
tools: Read, Grep, Glob, Bash
---
```

**Language section**: Follow the pattern at `agents/code-validator.md:11-17`. Specify "English".

**Body sections required** (in order):

1. **Role** — one paragraph: "Analyze and report deletion/merge candidates. Never modify files."

2. **Two Modes** — introduce that a single agent operates in two modes: Doc Mode and Code Mode.

3. **Doc Mode** section with subsections:
   - **Input**: `PHASE_*_TEST.md` and `PHASE_*_PLAN.md` files for the target phase.
   - **Applicable Criteria**: criteria 1, 3, 4, 6 only. State explicitly: "Only criteria applicable without code."
   - **Safeguards**:
     - "Nothing to prune" is a valid non-error result.
     - Keep at least one test per behavior.

4. **Code Mode** section with subsections:
   - **Input**: implemented phase source files + test files.
   - **Applicable Criteria**: criteria 2, 5, 7 (primary); plus newly introduced criteria 1, 3, 4, 6 violations by the coder.
   - **Criterion 2 requirement**: For every kept test, explicitly pin the production file:line it would catch if deleted. If a production line cannot be pinned, the test is a deletion candidate.
   - **Safeguards**:
     - "Nothing to prune" is a valid non-error result.
     - Keep at least one test per behavior.

5. **All 7 Criteria** — list all seven criteria exactly as specified in SPEC.md:54-64 and AD-6. Criterion 1 must use the AD-6 English text verbatim (see GLOBAL.md AD-6 for exact wording). Criteria 2–7 as in SPEC.md:59-64.

6. **Forbidden Actions** — a clearly labeled section that states the agent MUST NOT modify any file (code, test, or document). Explicitly prohibit the following Bash operations: `sed -i`, `>` redirect, `>>` redirect, `tee` (for writes), `mv`, `cp` (to write new content), `patch`, `git checkout -- <path>`, `git restore`, `git stash`, `git reset --hard`. State: "Never suggest logic changes."

7. **Edge Cases** (specific to this agent):
   - Edge case #5 (no tests in phase): if the phase has no test files, review docstrings/comments only, or report "Nothing to analyze" if no doc content is present either.
   - Criterion 7 (ratio warning): report as a non-blocking warning; does not block any action.

8. **Output Format** — a table with columns:

   | Column | Description |
   |--------|-------------|
   | Location | `file:line-range` |
   | Kind | `delete`, `merge`, or `trim` |
   | Reason | `criterion #N — one line` |
   | Pinned production line | `file:line` (criterion #2 only) or `N/A` |
   | Notes | optional |

   After the table:
   - One line for criterion-7 ratio warning if applicable (non-blocking, labeled as such).
   - Explicit statement: if no candidates exist, output "Nothing to prune." (verbatim, not an error).

### Step 2: Edit `docs/AGENT_MODEL_GUIDE.md`

Locate the "Current Assignments" table. Add one row for the new pruner agent:

```
| `agents/pruner.md` | `claude-sonnet-4-6` | Checklist-driven pruning analysis (report-only) |
```

Do NOT change any other row or section in `docs/AGENT_MODEL_GUIDE.md`.

## Completion Checklist

- [ ] `agents/pruner.md` created
- [ ] Frontmatter: `name: pruner` on its own line
- [ ] Frontmatter: `model: claude-sonnet-4-6` on its own line
- [ ] Frontmatter: `tools: Read, Grep, Glob, Bash` on its own line
- [ ] Body contains both "Doc Mode" and "Code Mode" labeled sections
- [ ] Criterion 1 text uses AD-6 wording ("branch combinations" phrase present)
- [ ] All 7 criteria listed in the body
- [ ] "Nothing to prune" phrase present in at least two places (Doc Mode safeguards, Code Mode safeguards, or Output Format)
- [ ] "Keep at least one test per behavior" phrase present in at least two places (Doc Mode safeguards and Code Mode safeguards)
- [ ] "Never suggest logic changes" phrase present
- [ ] Forbidden Actions section lists `sed -i`, `git reset --hard`, and `git stash`
- [ ] Output Format table has columns: Location, Kind, Reason, Pinned production line, Notes
- [ ] `docs/AGENT_MODEL_GUIDE.md` Current Assignments table has a row matching `agents/pruner.md`

## Notes

- The `tools:` frontmatter field is the first usage in this repository. No other agent file uses it. Verify by checking `agents/*.md` before writing.
- AD-3 wires `code-validator` to call `dotclaude:pruner`; the pruner agent must exist before Phase 2 integrations reference it by name.
- The "SPEC.md says `frontmatter tools: field if supported`" question is resolved: it is supported. See AD-1.
- Do NOT add pruner to `commands/` (that is Phase 2).
- Do NOT modify `CHANGELOG.md` or version files (per project convention: updates deferred to release tagging).
