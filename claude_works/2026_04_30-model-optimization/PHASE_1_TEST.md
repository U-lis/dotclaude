# Phase 1: Test Cases

## Test Coverage Target

100% of FR-1 through FR-6.

## Test Strategy

This phase is documentation/configuration only. There is no runtime code to unit-test. All verification is by file-content inspection: each test case below is a deterministic check against the resulting filesystem state.

All paths below are relative to the worktree root: `/home/ulismoon/Documents/dotclaude-feature-model-optimization`.

## Verification Tests

### TC-1: Frontmatter integrity — exactly one `model:` line per modified file

Each of the 9 modified agent files must contain **exactly one** `model:` line at the start of a line within its YAML frontmatter block. No duplicates, no model field appearing in body text.

Verification command:
```
git grep -c '^model:' agents/
```
Expected: each of the 9 files reports `1`. `agents/coders/_base.md` reports `0` (or is absent from output).

- [x] TC-1.1: `agents/designer.md` contains exactly one `^model:` line
- [x] TC-1.2: `agents/technical-writer.md` contains exactly one `^model:` line
- [x] TC-1.3: `agents/code-validator.md` contains exactly one `^model:` line
- [x] TC-1.4: `agents/spec-validator.md` contains exactly one `^model:` line
- [x] TC-1.5: `agents/coders/python.md` contains exactly one `^model:` line
- [x] TC-1.6: `agents/coders/javascript.md` contains exactly one `^model:` line
- [x] TC-1.7: `agents/coders/rust.md` contains exactly one `^model:` line
- [x] TC-1.8: `agents/coders/sql.md` contains exactly one `^model:` line
- [x] TC-1.9: `agents/coders/svelte.md` contains exactly one `^model:` line

### TC-2: Frontmatter values match mapping table (string equality)

Each `model:` value is checked by exact string equality. Trailing whitespace is permitted; quoting is not (per Step 1/2 YAML rules).

| Test | File | Expected exact value |
|------|------|----------------------|
| TC-2.1 | `agents/designer.md` | `model: claude-opus-4-7` |
| TC-2.2 | `agents/technical-writer.md` | `model: claude-sonnet-4-6` |
| TC-2.3 | `agents/code-validator.md` | `model: claude-sonnet-4-6` |
| TC-2.4 | `agents/spec-validator.md` | `model: claude-sonnet-4-6` |
| TC-2.5 | `agents/coders/python.md` | `model: claude-opus-4-7` |
| TC-2.6 | `agents/coders/javascript.md` | `model: claude-opus-4-7` |
| TC-2.7 | `agents/coders/rust.md` | `model: claude-opus-4-7` |
| TC-2.8 | `agents/coders/sql.md` | `model: claude-opus-4-7` |
| TC-2.9 | `agents/coders/svelte.md` | `model: claude-opus-4-7` |

- [x] TC-2.1 through TC-2.9 all pass

### TC-3: `_base.md` exclusion confirmed

`agents/coders/_base.md` MUST NOT contain a `model:` line at the start of any line. This enforces AD-4.

Verification command:
```
grep -c '^model:' agents/coders/_base.md
```
Expected: `0`.

- [x] TC-3: `agents/coders/_base.md` contains zero `^model:` lines

### TC-4: YAML frontmatter remains parsable

For each of the 9 modified files, the frontmatter block must still:
- Begin with `---` on its own line at the very top (line 1).
- End with `---` on its own line.
- Contain `name:` and `description:` lines (preserved from before this work).
- Contain the new `model:` line between `name:` and `description:`.
- Use spaces only (no tabs); no blank lines inside the block.

- [x] TC-4.1: `agents/designer.md` frontmatter opens and closes with `---`, has `name:`, `model:`, `description:` in that order
- [x] TC-4.2: `agents/technical-writer.md` — same structural check
- [x] TC-4.3: `agents/code-validator.md` — same structural check
- [x] TC-4.4: `agents/spec-validator.md` — same structural check
- [x] TC-4.5: `agents/coders/python.md` — same structural check
- [x] TC-4.6: `agents/coders/javascript.md` — same structural check
- [x] TC-4.7: `agents/coders/rust.md` — same structural check
- [x] TC-4.8: `agents/coders/sql.md` — same structural check
- [x] TC-4.9: `agents/coders/svelte.md` — same structural check

### TC-5: Aggregate count of `model:` lines under `agents/`

Verification command:
```
git grep -l '^model:' agents/ | wc -l
```
Expected: `9`.

- [x] TC-5: Aggregate count is exactly 9; covers FR-1 fully

### TC-6: All `model:` values are within the supported identifier set

The set of unique values found across all 9 files must be a subset of `{claude-opus-4-7, claude-sonnet-4-6, claude-haiku-4-5-20251001}`. In this release the actual set used is `{claude-opus-4-7, claude-sonnet-4-6}` (Haiku unassigned per AD-5).

Verification command:
```
git grep -h '^model:' agents/ | sort -u
```
Expected output (exactly two lines):
```
model: claude-opus-4-7
model: claude-sonnet-4-6
```

- [x] TC-6: Unique value set matches expected; no typos; no aliases like `opus`/`sonnet`

### TC-7: `docs/AGENT_MODEL_GUIDE.md` exists and is non-empty

- [x] TC-7.1: File `docs/AGENT_MODEL_GUIDE.md` exists
- [x] TC-7.2: File size is non-zero

### TC-8: Guide contains all required sections

Inspect `docs/AGENT_MODEL_GUIDE.md` and confirm presence of section content for each of:

- [x] TC-8.1: Title and purpose statement (Section 3.1)
- [x] TC-8.2: Supported model identifiers — exactly 3 entries listed (Section 3.2)
- [x] TC-8.3: Decision matrix — at least 5 rows (Section 3.3) — 6 rows verified
- [x] TC-8.4: Resolution order — 4 numbered steps including `CLAUDE_CODE_SUBAGENT_MODEL` (Section 3.4)
- [x] TC-8.5: Resolution order section cites `https://code.claude.com/docs/en/sub-agents`
- [x] TC-8.6: Current assignments table mirrors the SPEC mapping (Section 3.5)
- [x] TC-8.7: How-to-add-a-new-agent section instructs that shared/included files must NOT declare `model:` (Section 3.6)
- [x] TC-8.8: Haiku status section states Haiku is supported-but-unassigned in v0.5.0 (Section 3.7)

### TC-9: README.md cross-references the guide

- [x] TC-9.1: `README.md` contains a link whose target resolves to `docs/AGENT_MODEL_GUIDE.md`
- [x] TC-9.2: The link has descriptive label text (not a bare URL); contributor can find it via a "documentation" or "guide" related section

Verification (one possible command):
```
grep -F 'docs/AGENT_MODEL_GUIDE.md' README.md
```
Expected: at least one match.

### TC-10: docs/ARCHITECTURE.md cross-references the guide

- [x] TC-10.1: `docs/ARCHITECTURE.md` contains a link or textual reference resolving to `AGENT_MODEL_GUIDE.md`

Verification (one possible command):
```
grep -F 'AGENT_MODEL_GUIDE.md' docs/ARCHITECTURE.md
```
Expected: at least one match.

### TC-11: Excluded files are unchanged

The following files MUST NOT be modified in this phase. A `git diff` against the base branch must show no changes for any of them.

- [x] TC-11.1: `agents/coders/_base.md` is unchanged
- [x] TC-11.2: `CHANGELOG.md` is unchanged
- [x] TC-11.3: `.claude-plugin/plugin.json` is unchanged
- [x] TC-11.4: `.claude-plugin/marketplace.json` is unchanged

## FR Coverage Mapping

| Functional Requirement | Covered by Test Cases |
|------------------------|------------------------|
| FR-1 (Add `model` to 9 invocable agents) | TC-1.1–TC-1.9, TC-5 |
| FR-2 (Value within supported identifier set) | TC-6 |
| FR-3 (Per-agent assignment matches complexity profile / mapping) | TC-2.1–TC-2.9 |
| FR-4 (`_base.md` left without mandatory `model`) | TC-3, TC-11.1 |
| FR-5 (Guide document created at known path) | TC-7.1, TC-7.2, TC-9, TC-10 |
| FR-6 (Guide content: identifiers, matrix, override semantics) | TC-8.1–TC-8.8 |

## NFR Coverage Mapping

| Non-Functional Requirement | Covered by Test Cases |
|----------------------------|-----------------------|
| NFR-1 (Cost): mapping reflects task profile | TC-2.1–TC-2.9 (Sonnet for template/validation, Opus for codegen/design) |
| NFR-2 (Maintainability): guide discoverable | TC-9, TC-10 |
| NFR-3 (Compatibility): YAML still parses | TC-4.1–TC-4.9 |
| NFR-4 (Override semantics): documented in guide | TC-8.4, TC-8.5 (4-step resolution order with citation) |

## Edge Case Coverage

| Edge Case (from SPEC) | Covered by |
|-----------------------|------------|
| Caller passes `model` AND frontmatter declares `model` — caller wins | TC-8.4 (resolution order documents step 2 > step 3) |
| New agent added without `model` field — falls back; guide is the reference | TC-8.7 (How to Add a New Agent section) |
| Typo in `model` identifier — behavior determined by Claude Code | TC-6 (rejects typos in this work; runtime behavior on bad value is out of scope per SPEC) |
| `_base.md` read but never invoked — no `model` field needed | TC-3, TC-11.1 |

## Notes

- All tests are deterministic file-content checks. No runtime execution is required.
- A failure of any TC means the corresponding instructions in PHASE_1_PLAN_model-optimization.md were not fully executed; the implementer must return to that step.
- TC-11 (excluded files unchanged) is included to catch accidental scope creep, especially version-file modifications which must wait for the release phase per project convention.
