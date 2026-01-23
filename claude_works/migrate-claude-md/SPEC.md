# Migrate CLAUDE.md Content - Specification

**Target Version**: 0.0.11

## Overview

**Purpose**: Migrate CLAUDE.md content to appropriate agents/skills and add CLAUDE.md to .gitignore

**Problem**: CLAUDE.md is the default configuration file for Claude Code in each project. Since dotclaude is a tool used by other projects, directly including CLAUDE.md causes file conflicts when users install dotclaude. The current CLAUDE.md content must be analyzed, migrated to proper locations (agents/skills), and CLAUDE.md must be added to .gitignore.

**Solution**:
1. Distribute each rule to the appropriate agent/skill file
2. Add CLAUDE.md to .gitignore
3. Remove CLAUDE.md from git tracking
4. Delete CLAUDE.md from repository

---

## Functional Requirements

### Core Features
- [ ] FR-1: Add "Never agree or praise without verification" to start-new/SKILL.md
- [ ] FR-2: Add "Request domain knowledge based on DDD" to all init-xxx.md files
- [ ] FR-3: Add "Follow Occam's Razor + YAGNI" to designer.md
- [ ] FR-4: Add "Consult man pages and official documentation first" to coders/_base.md
- [ ] FR-5: Add "Report unclear parts, wait for confirmation" to init-xxx.md and designer.md
- [ ] FR-6: Add "Report summary upon completion" to start-new/SKILL.md
- [ ] FR-7: Add "git reset --hard FORBIDDEN" to coders/_base.md
- [ ] FR-8: Create .gitignore with CLAUDE.md entry
- [ ] FR-9: Remove CLAUDE.md from git tracking (git rm --cached)
- [ ] FR-10: Delete CLAUDE.md file

### Verification Features
- [ ] FR-11: Verify all dotclaude skills continue to work after migration

---

## Non-Functional Requirements

### Compatibility
- [ ] NFR-1: Existing projects using dotclaude must not experience conflicts
- [ ] NFR-2: User-created CLAUDE.md files in target projects must not be affected

---

## Rule Migration Map

| Rule | Source | Target Location |
|------|--------|-----------------|
| Never agree or praise without verification | Section 0 | start-new/SKILL.md |
| Request domain knowledge based on DDD | Section 0 | init-feature.md, init-bugfix.md, init-refactor.md |
| Follow Occam's Razor + YAGNI principles | Section 0 | designer.md |
| Consult man pages and official documentation first | Section 0 | coders/_base.md |
| If there are unclear parts, report and wait | Section 2.0 | init-xxx.md, designer.md |
| Report summary upon completion | Section 2.0 | start-new/SKILL.md |
| git reset --hard FORBIDDEN | Section 2.0 | coders/_base.md |

---

## Rules NOT Migrated (Already Exist or Not Needed)

| Rule | Reason |
|------|--------|
| Use Korean for user communication, English for artifacts | Already in technical-writer.md and skills |
| Documents under claude_works/ | Already in start-new workflow |
| Do NOT start work until instructed | Covered by skill workflows |
| Do NOT git add/commit without instruction | Covered by code/SKILL.md |
| Use mv/cp for moving files | Already in _base.md |
| Never modify .env directly | Already in _base.md |
| Document Structure rules | Already in templates/ |
| Planning Instructions | Already in init-xxx.md |
| Direct User Commands | Already in init-xxx.md |
| Working from claude_works/ Plans | Already in code/SKILL.md |

---

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | Existing project has CLAUDE.md | No conflict - .gitignore prevents tracking |
| 2 | dotclaude installed without CLAUDE.md | Works normally - rules distributed in agents/skills |
| 3 | User manually creates CLAUDE.md in project | Project-specific customization allowed |
| 4 | .gitignore added but CLAUDE.md tracked | git rm --cached removes from tracking |

---

## Implementation Summary

### Files to Modify

| File | Changes |
|------|---------|
| `.claude/skills/start-new/SKILL.md` | Add: evidence-based responses rule, report summary rule |
| `.claude/skills/start-new/init-feature.md` | Add: DDD knowledge rule, report unclear parts rule |
| `.claude/skills/start-new/init-bugfix.md` | Add: DDD knowledge rule, report unclear parts rule |
| `.claude/skills/start-new/init-refactor.md` | Add: DDD knowledge rule, report unclear parts rule |
| `.claude/agents/designer.md` | Add: Occam's Razor/YAGNI rule, report unclear parts rule |
| `.claude/agents/coders/_base.md` | Add: man pages rule, git reset --hard FORBIDDEN rule |

### Files to Create
| File | Content |
|------|---------|
| `.gitignore` | CLAUDE.md entry |

### Files to Delete
| File | Action |
|------|--------|
| `CLAUDE.md` | git rm --cached, then delete |

---

## Out of Scope

- Modifying existing skill logic beyond adding rules
- Changing agent invocation patterns
- Creating new agents
- Modifying hooks

---

## References

- `/home/ulismoon/Documents/dotclaude/CLAUDE.md` - Source file to migrate
- `/home/ulismoon/Documents/dotclaude/.claude/agents/coders/_base.md` - Coder base rules
- `/home/ulismoon/Documents/dotclaude/.claude/agents/designer.md` - Designer agent
- `/home/ulismoon/Documents/dotclaude/.claude/skills/start-new/SKILL.md` - Orchestrator
- `/home/ulismoon/Documents/dotclaude/.claude/skills/start-new/init-*.md` - Init workflows
