# Global Rules

This document defines mandatory rules that ALL AI Agents MUST follow.

## 0. Communication & Behavior

- Never agree or praise without verification. Always provide evidence-based responses.
- Request domain knowledge based on DDD (Domain-Driven Design) when context is needed.
- Follow Occam's Razor + YAGNI principles. Avoid the "Maserati Problem" (over-engineering).
- Use Korean for user communication. Use English for work artifacts (commits, changelog, context, docs).
- When checking tool usage or configuration, ALWAYS consult `man` pages and official documentation first. NEVER infer from patterns learned from other tools or outdated versions.

## 1. Work Planning Rules

### 1.0. Ground Rules

- All documents are written under `claude_works/` directory.
- All documents are written assuming other AI Agents will read them. Write clearly to avoid context misunderstanding.
- All documents use English + AI Optimized prompts for fast parsing and token efficiency.

### 1.1. Planning Instructions

#### New Feature
- Check if the feature already exists in the codebase.
- Determine the most appropriate location based on Clean Architecture principles.

#### Bug Fix / Feature Modification
- Analyze all usages and impact of the modification.
- Identify all affected tests.

#### Refactoring / Restructuring
- Present reasoning from an XP expert perspective (current state, code smell, principle violation, solution).

### 1.2. Document Structure

#### Simple Tasks (1-2 phases)
- Single file: `claude_works/{SUBJECT}.md`

#### Complex Tasks (3+ phases)
```
claude_works/{subject}/
├── SPEC.md                      # Requirements specification (What)
├── GLOBAL.md                    # Global context, architecture, phase overview
├── PHASE_{k}_PLAN_{keyword}.md  # Phase implementation plan
├── PHASE_{k}_TEST.md            # Phase test cases
└── PHASE_{k}.5_PLAN_MERGE.md    # Merge phase (after parallel phases)
```

#### Document Writing Rules
- Do NOT write modified code directly. Write instructions: "Modify X method of Y class to do Z"
- Sample code is allowed ONLY for new patterns/functions that cannot be inferred from context.

## 2. Work Execution Rules

### 2.0. Ground Rules

- `git reset --hard` is ABSOLUTELY FORBIDDEN under any circumstances.
- Do NOT start actual code work until explicitly instructed to begin.
- If there are unclear parts or decisions needed, report them and wait for user confirmation.
- Report summary upon completion and wait for user review/additional commands.
- Do NOT `git add` or `git commit` without explicit user instruction.
- When moving files/classes/functions, do NOT rewrite. Use `mv`/`cp` commands to preserve originals.
- Never modify `.env` directly. Update `.env.example` and notify user about required `.env` changes.

### 2.1. Direct User Commands

#### New Feature
- Find the most appropriate location from Clean Architecture perspective.
- If god class exists or refactoring is needed, work in current structure and signal refactoring need in completion report.
- Check for duplicate code or reusable existing code.

#### Bug Fix
- Find the code causing the issue.
- Add test cases to prevent recurrence if needed.
- Do NOT start immediately. Explain cause and solution, then wait for instruction.
- After fix, run full test suite and fix all failing tests caused by the modification.

#### Refactoring
- Verify the instruction is valid from XP perspective before starting.

### 2.2. Working from claude_works/ Plans

#### Ground Rules
- Re-verify plan against current codebase state (may have changed since document creation).
- After phase completion, run full test suite. Fix broken tests (max 3 attempts per test, then skip and report).
- Work one phase at a time. Do NOT proceed to next phase without user instruction.
- Do NOT modify GLOBAL/PHASE md files without user instruction.

#### New Feature (TDD)
- All development follows TDD: Test → Feature → Small Refactoring loop.
- During development, run only newly written tests for fast iteration.

#### Bug Fix
- Summarize work plan and wait for instruction before starting.
- Validate and respond based on DDD + XP philosophy. Suggest better approaches if any.

#### Refactoring
- Clearly understand which XP principle this work follows and focus on that direction.

