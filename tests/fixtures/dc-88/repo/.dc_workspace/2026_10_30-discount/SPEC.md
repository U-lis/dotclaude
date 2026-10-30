<!-- dotclaude-config
working_directory: .dc_workspace
base_branch: main
language: en_US
worktree_path: .
doc_dir: 2026_10_30-discount
stage: code
-->
# SPEC: discount clamp

## Overview

`apply_discount` accepts any percent today, so a percent above 100 produces a negative price. Clamp the percent to the range 0..100.

## Requirements

- [ ] FR-1: `apply_discount(price, percent)` clamps `percent` to 0..100 before applying it.

## Edge Cases

| # | FR | Partition | Case | Expected behavior |
|---|----|-----------|------|-------------------|
| 1 | FR-1 | normal | percent 10 | price reduced by 10% |
| 2 | FR-1 | boundary | percent 150 | treated as 100; price 0 |

## Out of scope

- Any other pricing rule.
