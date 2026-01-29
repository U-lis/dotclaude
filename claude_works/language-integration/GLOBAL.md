# Language Integration - Global Documentation

## Feature Overview

### Purpose
Integrate the existing `language` configuration value into dotclaude's runtime behavior so that agents and commands communicate with users in the configured language.

### Problem
The `language` field exists in config JSON files (global and local) but is never consumed at runtime. All agent and command text is hardcoded in English. The `init-config.sh` SessionStart hook creates the default config but does not output language context to Claude.

### Solution
Add language-awareness through two mechanisms:
1. The SessionStart hook reads the resolved language from config and outputs it to stdout for Claude to receive at session start.
2. Agents and commands include a `## Language` instruction section directing Claude to use the configured language for user-facing communication while keeping AI-to-AI documents in English.

This leverages Claude's native multilingual capability. No translation files, no i18n framework.

---

## Architecture Decisions

### AD-1: Hook Output Format
- **Decision**: The hook outputs `[dotclaude] language: {locale}` to stdout.
- **Rationale**: Uses the existing `[dotclaude]` prefix convention. The output is a single line that Claude receives as session context. Simple grep-friendly format.

### AD-2: Language Resolution Order
- **Decision**: Language resolution uses Defaults < Global < Local merge order.
- **Rationale**: Matches the existing config merge order used by `configure.md` and `start-new.md`. Default is `en_US`. Global config (`~/.claude/dotclaude-config.json`) overrides default. Local config (`<git_root>/.claude/dotclaude-config.json`) overrides global.

### AD-3: Agent Language Section (Full Variant)
- **Decision**: Agents get a `## Language` section placed after `## Role` with instructions about both user-facing communication and AI-to-AI document language.
- **Rationale**: Agents produce both user-facing output (conversation, status, questions) and AI-to-AI documents (SPEC, GLOBAL, PLAN, TEST). The instruction must explicitly separate these two contexts. Placement after `## Role` ensures early visibility.

### AD-4: Command Language Section (Short Variant)
- **Decision**: Commands get a `## Language` section with a shorter variant covering only user communication.
- **Rationale**: Commands do not produce AI-to-AI documents. They only interact with users (AskUserQuestion, status messages, reports). A shorter instruction is sufficient.

### AD-5: TechnicalWriter Special Handling
- **Decision**: TechnicalWriter's existing `### Language & Style` section under `## Writing Principles` is modified (not a new section added) to explicitly separate document language and user communication language.
- **Rationale**: TechnicalWriter already has a `### Language & Style` section that says "Use English + AI Optimized prompts". Modifying this existing section avoids conflicting instructions. The modification adds a rule: "When communicating with the user (explanations, questions, status updates), use the language configured in the session (output by the SessionStart hook). All documents (SPEC, GLOBAL, PLAN, TEST, CHANGELOG, README) remain in English."

### AD-6: Configure.md Cleanup
- **Decision**: Remove "Language translation support" from `configure.md` future enhancements list.
- **Rationale**: Language integration is now being implemented. The line "Language translation support (currently language setting stored but unused)" is no longer accurate.

### AD-7: Agent Language Section Placement
- **Decision**: The `## Language` section in agent files is placed immediately after `## Role`.
- **Rationale**: Early placement ensures agents read the language instruction before processing any other instructions. This makes the language context available for all subsequent behavior.

### AD-8: Command Language Section Placement
- **Decision**: The `## Language` section in command files is placed at the end of the file, except for `start-new.md` where it is placed after the `## Configuration Loading` section.
- **Rationale**: Commands are lengthy instruction documents. Adding a section at the end avoids disrupting the existing instruction flow. `start-new.md` is the exception because it loads configuration first and the language instruction should appear near config loading for logical coherence.

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Hook Language Output - Modify `hooks/init-config.sh` to resolve and output the configured language | Not Started | None |
| 2 | Agent and Command Language Instructions - Add `## Language` sections to 5 agent files and 8 command files | Not Started | Phase 1 (language output must exist before instructions reference it) |

**Execution**: Sequential (Phase 1 then Phase 2)

---

## File Structure

### Phase 1: Files Modified

| File | Change |
|------|--------|
| `hooks/init-config.sh` | Add language resolution logic and stdout output line |

### Phase 2: Files Modified

**Agents (5 files)**:

| File | Change Type |
|------|-------------|
| `agents/technical-writer.md` | Modify existing `### Language & Style` section (AD-5) |
| `agents/designer.md` | Add `## Language` section after `## Role` (AD-3, AD-7) |
| `agents/spec-validator.md` | Add `## Language` section after `## Role` (AD-3, AD-7) |
| `agents/code-validator.md` | Add `## Language` section after `## Role` (AD-3, AD-7) |
| `agents/coders/_base.md` | Add `## Language` section after `## Role` (AD-3, AD-7) |

**Commands (8 files)**:

| File | Change Type | Placement |
|------|-------------|-----------|
| `commands/start-new.md` | Add `## Language` section | After `## Configuration Loading` section (AD-8) |
| `commands/init-feature.md` | Add `## Language` section | End of file (AD-8) |
| `commands/init-bugfix.md` | Add `## Language` section | End of file (AD-8) |
| `commands/init-refactor.md` | Add `## Language` section | End of file (AD-8) |
| `commands/init-github-issue.md` | Add `## Language` section | End of file (AD-8) |
| `commands/_analysis.md` | Add `## Language` section | End of file (AD-8) |
| `commands/merge-main.md` | Add `## Language` section | End of file (AD-8) |
| `commands/configure.md` | Add `## Language` section + remove future enhancement line + remove outdated note | End of file for Language section (AD-8); inline edits for cleanup (AD-6) |
