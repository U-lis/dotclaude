# Tagging Push - Design Document

## Feature Overview

**Purpose:** Strengthen the `/dotclaude:tagging` command to enforce mandatory push behavior, add version consistency verification, and support explicit version arguments.

**Problem:** The current `commands/tagging.md` specification lists push steps but lacks enforcement language, version consistency gating, explicit version argument support, and structured error handling for push failures.

**Solution:** Rewrite `commands/tagging.md` with a 7-step workflow that front-loads version determination, adds a mandatory consistency gate, uses MUST/MANDATORY language for push steps, and includes error handling with per-step push reporting.

**Complexity:** SIMPLE (single file modification)

**Reference:** [SPEC.md](/home/ulismoon/Documents/dotclaude-tagging-push/claude_works/tagging-push/SPEC.md) (Source of Truth for requirements)

---

## Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-1 | Front-load version determination (explicit arg vs auto-detect) | Simplifies downstream logic; the target version is resolved once at the start and reused in all subsequent steps. |
| AD-2 | Mandatory version consistency gate before tag creation | Prevents creating tags when `plugin.json`, `marketplace.json`, and `CHANGELOG.md` are out of sync. Implements FR-7. |
| AD-3 | Use MUST/MANDATORY language for push steps | Removes ambiguity; agents reading the spec will treat push as non-optional. Implements FR-1, FR-2, FR-3. |
| AD-4 | Explicit error handling for push failures (preserve local tag) | Push failures (network, auth, remote rejection) must not cause tag rollback. Implements FR-4, NFR-1, NFR-2. |
| AD-5 | Per-step push results in output summary | Separate status lines for `git push` and `git push --tags` provide clear diagnostics. Implements FR-5. |
| AD-6 | Multiple `-m` flags from CHANGELOG section summaries | Each CHANGELOG section (Added, Changed, Fixed, etc.) becomes a separate `-m` argument for the annotated tag. Implements FR-6. |

---

## File Structure

| File | Action | Description |
|------|--------|-------------|
| `commands/tagging.md` | Rewrite | The sole file to modify. Contains the full tagging command specification that Claude follows as instructions. |

---

## Phase Plan: Rewrite `commands/tagging.md`

### Objective

Rewrite the tagging command specification to implement all functional and non-functional requirements from SPEC.md (FR-1 through FR-8, NFR-1, NFR-2).

### Prerequisites

- Branch `feature/pr-command` is checked out
- File `commands/tagging.md` exists at `/home/ulismoon/Documents/dotclaude/commands/tagging.md`

### Current State

The existing `commands/tagging.md` has:
- Basic 8-step workflow (parse, compare, confirm, tag, push, push tags, report)
- Simple version parsing from CHANGELOG
- Minimal output format
- Basic safety section

It lacks:
- Explicit version argument support (FR-8)
- Version consistency gate across `plugin.json`, `marketplace.json`, `CHANGELOG.md` (FR-7)
- MUST/MANDATORY enforcement language for push (FR-1, FR-2, FR-3)
- Error handling for push failures (FR-4, NFR-1)
- Tag preservation rule on push failure (NFR-2)
- Per-step push result reporting (FR-5)
- Section-level extraction for tag `-m` flags (FR-6)

### Instructions

Rewrite `commands/tagging.md` with the following structure. Do NOT write the modified code directly; follow these section-by-section instructions.

#### 1. Frontmatter

Keep the existing frontmatter unchanged:
```yaml
---
description: Create version tag based on CHANGELOG
---
```

#### 2. Header and Description

Update the header description line to mention push behavior:
- Current: `Create git tag based on CHANGELOG.md version.`
- New: State that the command creates a git tag AND pushes both commits and tags to remote.

#### 3. Prerequisites Section

Add version file prerequisites alongside the existing ones. The section must list:
- On main branch
- `CHANGELOG.md` exists with version entry
- `.claude-plugin/plugin.json` exists and contains `"version"` field
- `.claude-plugin/marketplace.json` exists and contains `"version"` field in `plugins[0]`

#### 4. Version Argument Section (NEW)

Add a new section titled "Version Argument" immediately after Prerequisites. Document:
- If the user provides an explicit version argument (e.g., `/dotclaude:tagging 0.3.0`), use that as the target version directly.
- If no argument is provided, fall back to auto-detection: parse CHANGELOG.md for the latest version.
- In both cases, the version consistency check (see section 6) MUST pass before proceeding.

This implements FR-8.

#### 5. Workflow Section

Rewrite the workflow block to use a 7-step structure:

```
1. Determine target version
   - If explicit version argument provided: use it
   - Else: parse CHANGELOG.md for latest ## [X.Y.Z] entry
2. Version consistency check (MANDATORY GATE)
   - Read version from .claude-plugin/plugin.json
   - Read version from .claude-plugin/marketplace.json (plugins[0].version)
   - Read latest version from CHANGELOG.md
   - ALL THREE must match the target version
   - If ANY mismatch: HALT immediately, report inconsistency, do NOT proceed
3. Get latest git tag (git describe --tags --abbrev=0)
   - If target version matches latest tag: report "Already tagged" and stop
   - If mismatch: proceed
4. Confirm with user (show target version and previous tag)
5. Create annotated tag: git tag -a vX.Y.Z -m "{Section1}" -m "{Section2}" ...
6. git push (MANDATORY - push commits to remote)
7. git push --tags (MANDATORY - push tags to remote)
8. Report summary
```

Note: Steps 6 and 7 use MUST/MANDATORY language. The agent reading this spec must treat these as non-optional.

#### 6. Version Consistency Check Section (NEW)

Add a new section titled "Version Consistency Check" after the Workflow block. Specify:
- Exact file paths: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`
- Exact fields: `version` in plugin.json root, `version` in marketplace.json `plugins[0]`, latest `## [X.Y.Z]` in CHANGELOG.md
- Behavior on mismatch: HALT and report which files have which versions. Do NOT proceed with tagging.
- Present as a mandatory gate: "This check MUST pass before any tag is created."

This implements FR-7.

#### 7. Version Parsing Section

Update the existing "Version Parsing" section to include section-level extraction:
- Keep the existing CHANGELOG format example
- Add: after extracting the version number, also extract each section header (### Added, ### Changed, ### Fixed, etc.) and its content under the target version entry
- Each section becomes a separate `-m` argument for `git tag -a`
- Example: if CHANGELOG has `### Added` and `### Fixed` sections, the tag command becomes:
  `git tag -a v1.2.3 -m "Added: Feature X, Feature Y" -m "Fixed: Bug A, Bug B"`

This implements FR-6.

#### 8. Version Mismatch Handling Section

Keep the existing section but update to reflect the new workflow:
- The version comparison now occurs at step 3 (comparing target version to latest tag)
- Show diff format: `Target: 1.2.0` vs `Latest tag: 1.1.0`
- Ask confirmation to create new tag

#### 9. Push Steps Section (NEW or integrated)

Ensure the push steps are described with MUST/MANDATORY language:
- "After creating the tag, the command MUST execute `git push` to push commits to remote."
- "After pushing commits, the command MUST execute `git push --tags` to push tags to remote."
- "These push steps are MANDATORY. Do NOT skip them."

This implements FR-1, FR-2, FR-3.

#### 10. Error Handling Section (NEW)

Add a new section titled "Error Handling" covering push failures:
- If `git push` fails: report the error, note that the local tag is preserved, suggest the user retry manually.
- If `git push --tags` fails: report the error, note that commits were pushed but tags were not, suggest the user retry `git push --tags` manually.
- Never rollback or delete the local tag on push failure.
- Error output format should clearly indicate which step failed and what the user should do.

This implements FR-4, NFR-1, NFR-2.

#### 11. Output Section

Expand the output section to include:

Success format:
```
# Tag Created & Pushed

- Version: v1.2.0
- Based on: CHANGELOG.md
- Previous tag: v1.1.0
- Commits pushed: success
- Tags pushed: success
```

Partial failure format (example: tag push failed):
```
# Tag Created - Push Partially Failed

- Version: v1.2.0
- Based on: CHANGELOG.md
- Previous tag: v1.1.0
- Commits pushed: success
- Tags pushed: FAILED (error message)
- Local tag preserved: yes
- Action required: retry `git push --tags`
```

Version consistency failure format:
```
# Version Consistency Check Failed

- plugin.json: 0.2.1
- marketplace.json: 0.2.1
- CHANGELOG.md: 0.3.0
- Status: MISMATCH - cannot proceed
- Action required: update version files to match before tagging
```

This implements FR-5.

#### 12. Safety Section

Update the existing safety section to include:
- Only create tags, never delete (keep existing)
- Require user confirmation (keep existing)
- Push is mandatory after tag creation (new)
- Never rollback local tag on push failure (new, implements NFR-2)

### Completion Checklist

- [ ] Update header description to mention push behavior
- [ ] Add version file prerequisites (`plugin.json`, `marketplace.json` must exist)
- [ ] Add "Version Argument" section documenting explicit version support (FR-8)
- [ ] Rewrite Workflow block with 7-step structure (steps 1-8 as documented above)
- [ ] Add "Version Consistency Check" section with exact file paths and halt-on-mismatch (FR-7)
- [ ] Update "Version Parsing" to include section-level extraction for tag `-m` flags (FR-6)
- [ ] Strengthen push steps with MUST/MANDATORY language (FR-1, FR-2, FR-3)
- [ ] Add "Error Handling" section for push failures (FR-4, NFR-1)
- [ ] Add NFR-2 rule: never rollback local tag on push failure
- [ ] Expand "Output" section with separate push result lines (FR-5)
- [ ] Add error output format for push failures
- [ ] Add version consistency failure output format
- [ ] Update "Safety" section with push failure preservation rule

### Notes

- This is a specification document, not executable code. The file `commands/tagging.md` is read by Claude as instructions for how to perform the tagging workflow.
- Do NOT include sample code beyond what is needed to illustrate command formats (e.g., `git tag -a` syntax).
- Keep the markdown format consistent with the existing style in `commands/tagging.md`.
- All requirements trace back to SPEC.md. Cross-reference FR/NFR IDs in the checklist above.
