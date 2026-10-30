<!-- dotclaude-config
working_directory: .dc_workspace
base_branch: release/0.7.0
language: en_US
worktree_path: .
doc_dir: fixture-two-fr
target_version: 0.7.0
stage: spec_review
approved_at: null
approved_hash: null
decisions: []
handoff: ""
-->
# Remove a decision token - Specification

## Overview

**Purpose**: Let the orchestrator withdraw an operating decision.

**Problem**: `spec-meta.sh decision` supports `add` and `list` only, so a wrong token stays in the metadata block.

**Solution**: Add a `remove` subcommand next to `add`.

---

## Functional Requirements

### Core Features
- [ ] FR-1: `spec-meta.sh decision <spec> remove <token>` removes the token from `decisions`; removing an absent token exits 0 and changes nothing.
- [ ] FR-2: The `--help` text and the `decision` usage error list `remove`.

---

## Non-Functional Requirements

- None

---

## Data Migration

Not applicable

---

## Constraints

### Technical Constraints
- Language/Framework: bash; the test goes in the existing hook test suite

---

## Out of Scope

- Changing `add` or `list`

---

## Assumptions

- None

---

## Open Questions

- None

---

## Decisions Required

| # | Decision | Options | Recommendation | User's choice |
|---|----------|---------|----------------|---------------|

---

## References

- hooks/spec-meta.sh (decision subcommand)
- tests/hooks/test_spec_meta.sh
