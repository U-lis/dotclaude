<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
-->

# Language Integration - Specification

> GitHub Issue: #17 (https://github.com/U-lis/dotclaude/issues/17)
> Labels: enhancement
> Milestone: 0.3.0

## Overview

The dotclaude plugin stores a `language` configuration value (e.g., `en_US`, `ko_KR`) in its config JSON files, but this value is never consumed at runtime. This feature integrates the language setting so that agent conversations and user-facing text use the configured language, while AI-to-AI documents remain in English.

### Problem

- The `language` field exists in both global (`~/.claude/dotclaude-config.json`) and local (`.claude/dotclaude-config.json`) config files.
- Default value is `en_US`, configurable via `/dotclaude:configure`.
- The value is written into SPEC.md metadata but never read or acted upon.
- All agent and command text is hardcoded in English.
- The `init-config.sh` SessionStart hook creates the default config but does not output language context to Claude.

### Solution

Add language-awareness through instruction blocks in agents and commands, leveraging Claude's native multilingual capability. This is NOT a full i18n translation system. Instead:

1. The SessionStart hook reads the resolved language from config and outputs it for Claude to receive at session start.
2. Agents and commands include an instruction section that says "Communicate with the user in {language}".
3. Claude naturally produces responses, questions, and labels in the specified language.

### Key Design Decision

The approach relies on Claude's multilingual LLM capability rather than maintaining translation files. A single instruction block per agent/command directs Claude to use the configured language for user-facing communication, while keeping all AI-to-AI documents in English.

---

## Functional Requirements

- [ ] **FR-1: SessionStart language loading**
  - Modify `hooks/init-config.sh` to read the resolved language value from config (local overrides global, default `en_US`).
  - Output the language value so Claude receives it as session context at startup.
  - The hook MUST remain idempotent. Adding language output MUST NOT break existing hook behavior.

- [ ] **FR-2: Agent language instruction**
  - Add a language instruction section to agent definition files that directs agents to communicate with users in the configured language.
  - Place this instruction in the base/shared agent file (`agents/coders/_base.md`) so all coder agents inherit it.
  - Add the same instruction to standalone agents: `agents/technical-writer.md`, `agents/designer.md`, `agents/spec-validator.md`, `agents/code-validator.md`.

- [ ] **FR-3: Command language awareness**
  - Add language instruction to the following command files so they produce user-facing text (including AskUserQuestion labels) in the configured language:
    - `commands/start-new.md`
    - `commands/init-feature.md`
    - `commands/init-bugfix.md`
    - `commands/init-refactor.md`
    - `commands/init-github-issue.md`
    - `commands/_analysis.md`
    - `commands/merge-main.md`
    - `commands/configure.md`

- [ ] **FR-4: TechnicalWriter language handling**
  - The TechnicalWriter agent currently mandates "English + AI Optimized prompts" for all documents.
  - AI-to-AI documents (SPEC.md, GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md) MUST continue to be written in English.
  - DOCS_UPDATE role outputs (CHANGELOG.md, README.md) MUST also remain in English for content.
  - User-facing conversation (explanations, questions, status updates) MUST use the configured language.
  - Resolve the conflict by adding a separate rule for user communication language while keeping the existing English document rule intact.

- [ ] **FR-5: Design documents remain English**
  - SPEC.md, GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md are AI-optimized documents read by other agents.
  - These documents MUST stay in English regardless of the configured language setting.
  - This is a hard constraint that overrides FR-2 and FR-3 for document output contexts.

---

## Non-Functional Requirements

- [ ] **NFR-1: Backward compatibility**
  - Existing config files without a `language` field MUST default to `en_US`.
  - No user action required for existing installations to continue working.

- [ ] **NFR-2: Hook output safety**
  - The language output from `init-config.sh` MUST NOT break existing hook behavior or other hook outputs.
  - Output format must be compatible with Claude's SessionStart hook consumption.

- [ ] **NFR-3: Simplicity**
  - The implementation adds a language instruction block to agents and commands.
  - No translation files, no i18n framework, no locale-specific templates.
  - The approach leverages Claude's native multilingual capability.

---

## Constraints

- Source files in this repository only. NEVER modify installed plugin files (`~/.claude/plugins/cache/...`).
- Config merge order MUST be preserved: Defaults < Global (`~/.claude/dotclaude-config.json`) < Local (`.claude/dotclaude-config.json`).
- `init-config.sh` hook MUST remain idempotent (safe to run multiple times without side effects).
- Documents read by AI agents (SPEC, GLOBAL, PLAN, TEST) remain in English always.

---

## Out of Scope

- Full i18n translation system with translation files
- Language-specific document templates
- Per-agent language override (all agents use the same configured language)
- RTL (right-to-left) language support
- Language string validation (any locale string is accepted as-is)

---

## Related Code

| # | File | Relationship | Change Required |
|---|------|-------------|-----------------|
| 1 | `hooks/init-config.sh` | SessionStart hook | Add language output (FR-1) |
| 2 | `hooks/hooks.json` | Hook configuration | No changes needed |
| 3 | `commands/start-new.md` | Main orchestrator command | Add language instruction (FR-3) |
| 4 | `commands/init-feature.md` | Feature init command | Add language instruction (FR-3) |
| 5 | `commands/init-bugfix.md` | Bugfix init command | Add language instruction (FR-3) |
| 6 | `commands/init-refactor.md` | Refactor init command | Add language instruction (FR-3) |
| 7 | `commands/init-github-issue.md` | GitHub issue init command | Add language instruction (FR-3) |
| 8 | `commands/_analysis.md` | Analysis workflow command | Add language instruction (FR-3) |
| 9 | `commands/merge-main.md` | Merge workflow command | Add language instruction (FR-3) |
| 10 | `commands/configure.md` | Configure command | Add language instruction, remove "Future Enhancement" note (FR-3) |
| 11 | `agents/technical-writer.md` | TechnicalWriter agent | Keep docs English, add user communication language rule (FR-2, FR-4) |
| 12 | `agents/designer.md` | Designer agent | Add language instruction (FR-2) |
| 13 | `agents/spec-validator.md` | Spec validator agent | Add language instruction (FR-2) |
| 14 | `agents/code-validator.md` | Code validator agent | Add language instruction (FR-2) |
| 15 | `agents/coders/_base.md` | Base coder agent (inherited by all coders) | Add language instruction (FR-2) |

---

## Conflicts and Resolutions

| # | Existing Behavior | Required Behavior | Resolution |
|---|-------------------|-------------------|------------|
| 1 | TechnicalWriter mandates "English + AI Optimized prompts" for all output | User communication must use configured language | Add a separate rule: documents stay English, user-facing conversation uses configured language |
| 2 | `configure.md` lists "Language translation support" as a future enhancement | Language integration is now being implemented | Remove from future enhancements list in `configure.md` |

---

## Edge Cases

| # | Case | Expected Behavior |
|---|------|-------------------|
| 1 | No `language` field in config | Default to `en_US` |
| 2 | Invalid locale string (e.g., `xx_YY`) | Accept as-is; Claude handles gracefully with best-effort output |
| 3 | Language changed mid-session | Takes effect on next session (hook runs only at SessionStart) |
| 4 | No config file exists at all | `init-config.sh` creates config with `en_US` default |
| 5 | Local config has language, global does not | Local value is used (local overrides global) |
| 6 | Global config has language, local does not | Global value is used |
| 7 | Both configs have language | Local value wins (merge order: Defaults < Global < Local) |

---

## Open Questions

None at this time. All requirements have been gathered and confirmed through analysis.
