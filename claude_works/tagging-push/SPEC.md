<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Tagging Push - Specification

## Context

- **GitHub Issue**: https://github.com/U-lis/dotclaude/issues/3
- **Issue Title**: dc:tagging push
- **Issue Label**: bug
- **Target Version**: 0.3.0

## Overview

The `/dotclaude:tagging` command should execute `git push` and `git push --tags` after creating a tag. While the current command specification (`commands/tagging.md`) already lists push steps (steps 6-7), the specification needs to be strengthened to ensure push is reliably executed as a mandatory post-tag action.

The issue specifies the expected behavior:

```
git tag -a {version} -m "{summary1}" -m "{summary2}" ... && git push && git push --tags
```

## Functional Requirements

- [ ] FR-1: After creating an annotated git tag, the command MUST execute `git push` to push commits to remote
- [ ] FR-2: After pushing commits, the command MUST execute `git push --tags` to push tags to remote
- [ ] FR-3: The push operations should be presented as mandatory steps, not optional
- [ ] FR-4: Error handling for push failures (network errors, auth failures, remote rejection)
- [ ] FR-5: Report push results in the output summary (success/failure for each push operation)
- [ ] FR-6: The tag message should include CHANGELOG section summaries as multiple `-m` arguments
- [ ] FR-7: Before creating a tag, MUST verify version consistency across all version files:
  - `.claude-plugin/plugin.json` -> `"version": "X.Y.Z"`
  - `.claude-plugin/marketplace.json` -> `"version": "X.Y.Z"` (in `plugins[0]`)
  - `CHANGELOG.md` -> `## [X.Y.Z] - YYYY-MM-DD` (latest entry)
  - If any mismatch is found: HALT and report the inconsistency to the user. Do NOT proceed with tagging.
- [ ] FR-8: Version determination logic:
  - If user explicitly provides a version argument (e.g., `/dotclaude:tagging 0.3.0`), use that version for tagging
  - If no version argument is provided:
    1. Parse `CHANGELOG.md` for the latest version
    2. Get the latest git tag via `git describe --tags --abbrev=0`
    3. Compare them and present to the user for confirmation
  - In both cases, the FR-7 version consistency check MUST pass before proceeding

## Non-Functional Requirements

- [ ] NFR-1: Push operations should fail gracefully with clear error messages
- [ ] NFR-2: If push fails, the local tag should remain (do not rollback tag on push failure)

## Constraints

- Only modify `commands/tagging.md`
- Follow the existing specification format (markdown workflow steps)
- The command is a specification document that Claude follows as instructions

## Out of Scope

- Tag deletion functionality
- Force push behavior
- Remote repository configuration

## Analysis Results

### Related Code

| File | Relevance |
|------|-----------|
| `commands/tagging.md` | Primary file to modify - the tagging command specification |

### Workflow

1. Determine target version (from explicit argument or CHANGELOG + tag list)
2. Version consistency check (FR-7) - verify all version files match the target version
3. Get latest git tag for comparison
4. If version is already tagged: report "Already tagged" and stop
5. If new version: confirm with user before proceeding
6. `git tag -a vX.Y.Z -m "{summary1}" -m "{summary2}" ...`
7. `git push` (push commits to remote) - MANDATORY
8. `git push --tags` (push tags to remote) - MANDATORY
9. Report summary

### Root Cause

The tagging command specification at `commands/tagging.md` has push steps listed but they may not be explicit enough. The specification needs:

1. Stronger "MUST" language for push steps
2. Clear error handling instructions for push failures
3. Explicit output format showing push results
4. Missing version consistency verification before tagging
5. No support for explicit version argument
6. Push steps not enforced strongly enough

### Fix Strategy

1. Strengthen the push-related sections of `commands/tagging.md` to make push behavior mandatory and include error handling instructions
2. Add a version consistency check as a pre-tagging gate (FR-7) that halts on mismatch
3. Support explicit version argument passed to the command (FR-8)
4. Strengthen push enforcement language -- push steps are MANDATORY, not advisory

## Open Questions

None.
