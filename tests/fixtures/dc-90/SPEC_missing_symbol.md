<!-- dotclaude-config
working_directory: .dc_workspace
base_branch: release/0.7.0
language: en_US
worktree_path: .
doc_dir: fixture-missing-symbol
target_version: 0.7.0
stage: spec_review
approved_at: null
approved_hash: null
decisions: []
handoff: ""
-->
# Stale SPEC explanation - Specification

## Overview

**Purpose**: Tell the user why a SPEC is no longer approved.

**Problem**: `spec-meta.sh check-approved` exits 1 without saying what changed, so the design guard's denial is hard to act on.

**Solution**: Reuse the existing `spec-meta.sh diff-approved` subcommand to print the changed lines, and expire approvals older than the existing `spec_review.max_age_days` config key.

---

## Functional Requirements

### Core Features
- [ ] FR-1: When `check-approved` fails, the design guard hook prints the output of `spec-meta.sh diff-approved <spec>` in its denial reason.
- [ ] FR-2: `check-approved` also fails when `approved_at` is older than `spec_review.max_age_days` days.
- [ ] FR-3: `/dotclaude:configure` lets the user edit `spec_review.max_age_days`.

---

## Non-Functional Requirements

### Reliability
- [ ] NFR-1: The hook still exits within 1 second on a 2,000-line SPEC.

---

## Data Migration

Not applicable

---

## Constraints

### Technical Constraints
- Language/Framework: bash, no new dependencies

---

## Out of Scope

- Changing how the approval hash is computed

---

## Assumptions

- `diff-approved` and `spec_review.max_age_days` already exist (this assumption is false on purpose; see README.md).

---

## Open Questions

- None

---

## Decisions Required

| # | Decision | Options | Recommendation | User's choice |
|---|----------|---------|----------------|---------------|

---

## References

- hooks/spec-meta.sh
