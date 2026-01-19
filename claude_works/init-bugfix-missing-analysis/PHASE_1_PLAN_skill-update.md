# Phase 1: Skill Update

## Objective

Update `.claude/skills/init-bugfix/SKILL.md` to include codebase analysis step and enhanced SPEC.md format.

## Prerequisites

- SPEC.md reviewed and approved

## Implementation Checklist

### 1. Add Step 7: Codebase Analysis

Location: After Step 6 (영향 범위), before "## Branch Keyword" section

- [x] Add new section header `### Step 7: Codebase Analysis`
- [x] Document conditional analysis flow (known files vs unknown)
- [x] Specify use of Explore agent for unknown file search
- [x] Specify use of Read tool for known file analysis
- [x] Define required outputs: root cause, affected code, fix strategy
- [x] Add handling for inconclusive analysis case

### 2. Update Output Section

Location: `## Output` section at end of file

- [x] Restructure SPEC.md format into two main sections
- [x] Add "User-Reported Information" subsection (Steps 1-6)
- [x] Add "AI Analysis Results" subsection (Step 7 output)
- [x] Define required fields for each subsection

### 3. Add Workflow Summary

Location: After Step 7, before "## Branch Keyword"

- [x] Add `## Workflow` section
- [x] Document complete flow: questions → analysis → branch → SPEC → commit

## Acceptance Criteria

1. SKILL.md contains Step 7 with clear analysis instructions
2. Output section defines two-part SPEC.md structure
3. Workflow section clarifies execution order
4. All instructions in English (per CLAUDE.md rule)
5. File maintains valid markdown syntax
