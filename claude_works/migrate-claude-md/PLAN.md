# Migrate CLAUDE.md Rules to Agent/Skill Files

## Overview

Migrate global rules from CLAUDE.md to appropriate agent/skill files, then remove CLAUDE.md from git tracking.

## Target Version

0.0.11 (patch)

## Phases

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Add rules to agent/skill files | Pending |
| 2 | Git operations (gitignore + remove CLAUDE.md) | Pending |

---

## Phase 1: Add Rules to Agent/Skill Files

### Objective

Distribute CLAUDE.md rules to appropriate agent/skill files where they are contextually relevant.

### Prerequisites

- None

### Instructions

#### 1.1 Update `.claude/skills/start-new/SKILL.md`

**Location**: Add rules to "Init Phase Rules" section, under "Mandatory Workflow Rules"

**Add the following rules**:
- "Never agree or praise without verification. Always provide evidence-based responses."
- "Report summary upon completion and wait for user review/additional commands."

#### 1.2 Update `.claude/skills/start-new/init-feature.md`

**Location**: Add new section "## Communication Rules" before "## Output" section

**Add the following rules**:
- "Request domain knowledge based on DDD (Domain-Driven Design) when context is needed."
- "If there are unclear parts or decisions needed, report them and wait for user confirmation."

#### 1.3 Update `.claude/skills/start-new/init-bugfix.md`

**Location**: Add new section "## Communication Rules" before "## Output" section

**Add the following rules**:
- "Request domain knowledge based on DDD (Domain-Driven Design) when context is needed."
- "If there are unclear parts or decisions needed, report them and wait for user confirmation."

#### 1.4 Update `.claude/skills/start-new/init-refactor.md`

**Location**: Add new section "## Communication Rules" before "## Output" section

**Add the following rules**:
- "Request domain knowledge based on DDD (Domain-Driven Design) when context is needed."
- "If there are unclear parts or decisions needed, report them and wait for user confirmation."

#### 1.5 Update `.claude/agents/designer.md`

**Location**: Add new section "## Design Principles" after "## Capabilities" section

**Add the following rules**:
- "Follow Occam's Razor + YAGNI principles. Avoid the 'Maserati Problem' (over-engineering)."
- "If there are unclear parts or decisions needed, report them and wait for user confirmation."

#### 1.6 Update `.claude/agents/coders/_base.md`

**Location**: Add to "## Common Rules" section, as new subsection "### 8. Critical Safety Rules"

**Add the following rules**:
- "When checking tool usage or configuration, ALWAYS consult `man` pages and official documentation first. NEVER infer from patterns learned from other tools or outdated versions."
- "`git reset --hard` is ABSOLUTELY FORBIDDEN under any circumstances."

### Completion Checklist

- [ ] `.claude/skills/start-new/SKILL.md` updated with evidence-based responses and report summary rules
- [ ] `.claude/skills/start-new/init-feature.md` updated with DDD knowledge and unclear parts rules
- [ ] `.claude/skills/start-new/init-bugfix.md` updated with DDD knowledge and unclear parts rules
- [ ] `.claude/skills/start-new/init-refactor.md` updated with DDD knowledge and unclear parts rules
- [ ] `.claude/agents/designer.md` updated with Occam's Razor/YAGNI and unclear parts rules
- [ ] `.claude/agents/coders/_base.md` updated with man pages and git reset --hard FORBIDDEN rules
- [ ] All rules are placed in contextually appropriate sections
- [ ] No duplicate rules introduced

---

## Phase 2: Git Operations

### Objective

Remove CLAUDE.md from git tracking while preserving local file, then delete the file.

### Prerequisites

- Phase 1 completed (rules migrated to appropriate files)

### Instructions

#### 2.1 Create `.gitignore` with CLAUDE.md entry

**Action**: Create file `.gitignore` in repository root

**Content**:
```
CLAUDE.md
```

#### 2.2 Remove CLAUDE.md from git tracking

**Command**: `git rm --cached CLAUDE.md`

**Purpose**: Remove file from git index while preserving local copy

#### 2.3 Delete CLAUDE.md file

**Command**: `rm CLAUDE.md`

**Purpose**: Remove the file completely as rules have been migrated

### Completion Checklist

- [ ] `.gitignore` file created with `CLAUDE.md` entry
- [ ] `CLAUDE.md` removed from git tracking via `git rm --cached`
- [ ] `CLAUDE.md` file deleted from filesystem
- [ ] Verify `git status` shows `.gitignore` as new file
- [ ] Verify `git status` does NOT show CLAUDE.md as tracked

---

## Notes

- Phase 1 must be completed before Phase 2 to ensure all rules are preserved
- After Phase 2, CLAUDE.md content will only exist in agent/skill files
- The `.gitignore` entry prevents accidental re-addition of CLAUDE.md
