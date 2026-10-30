---
description: Update project documentation (README, CHANGELOG) after code implementation is complete.
---
# /dotclaude:update-docs

Update CHANGELOG.md and README.md for the work on the current branch. Shared rules are in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md`; the prompt template is in `${CLAUDE_PLUGIN_ROOT}/commands/_agent-prompts.md` (DOCS_UPDATE).

Prerequisite: every phase in GLOBAL.md is Complete or Skipped. If one is Not Started or In Progress, stop and say which.

1. Gather context: latest tag (`git describe --tags --abbrev=0`), commits since it (`git log {tag}..HEAD --oneline`), the SPEC.md overview, and the target version from the SPEC metadata.
2. Call technical-writer in its DOCS_UPDATE role with that context. It adds the version entry to CHANGELOG.md (Keep a Changelog categories, newest first, `## [X.Y.Z] - YYYY-MM-DD`, English) and edits README.md only where features, usage, configuration, or workflow diagrams visibly changed.
3. Commit (Contract: Commits).
4. Report the files updated, the CHANGELOG entry, and the commit hash.

Version numbers in version files are not changed here; they are updated at release time and checked by `/dotclaude:tagging`.
