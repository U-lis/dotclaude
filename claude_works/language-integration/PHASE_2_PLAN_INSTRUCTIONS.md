# Phase 2: Agent and Command Language Instructions

## Objective

Add `## Language` instruction sections to 5 agent files and 8 command files so that agents and commands communicate with users in the configured language. Also clean up `configure.md` by removing the outdated future enhancement line.

## Prerequisites

- Phase 1 completed (the SessionStart hook outputs `[dotclaude] language: {locale}`)

## Instructions

This phase modifies 13 files total. Each modification adds a `## Language` section with the appropriate instruction text. There are two variants of the language section: a full variant for agents (which produce both user-facing output and AI-to-AI documents) and a short variant for commands (which only interact with users).

---

### Part A: Agent Files (5 files)

#### Instruction Text Variants

**Full Agent Variant** (for `designer.md`, `spec-validator.md`, `code-validator.md`, `coders/_base.md`):

```markdown
## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- **User-facing communication** (conversation, questions, status updates, AskUserQuestion labels): Use the configured language.
- **AI-to-AI documents** (SPEC.md, GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md, and all documents in `{working_directory}/`): Always write in English regardless of the configured language. These documents are optimized for other AI agents to read.
```

**TechnicalWriter Variant** (special handling per AD-5):

Do NOT add a new `## Language` section. Instead, modify the existing `### Language & Style` section under `## Writing Principles`.

---

#### A-1: Modify `agents/technical-writer.md`

**Location**: The existing `### Language & Style` section (lines 52-55).

**Current content**:
```markdown
### Language & Style
- Use English + AI Optimized prompts
- Assume other AI Agents will read the documents
- Be explicit and unambiguous
```

**Replace with**:
```markdown
### Language & Style
- **Document language**: Use English for ALL documents (SPEC.md, GLOBAL.md, PHASE_*_PLAN.md, PHASE_*_TEST.md, CHANGELOG.md, README.md). These are AI-optimized and must remain in English regardless of the configured language.
- **User communication language**: When communicating with the user (explanations, questions, status updates), use the language configured in the session. The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).
- Assume other AI Agents will read the documents
- Be explicit and unambiguous
```

**What changes**: The first bullet "Use English + AI Optimized prompts" is replaced with two bullets that explicitly separate document language (English always) and user communication language (configured language). The remaining two bullets are unchanged.

---

#### A-2: Modify `agents/designer.md`

**Location**: Insert `## Language` section immediately after `## Role` (after line 16, before `## Capabilities`).

**Insert the full agent variant text** (see above).

---

#### A-3: Modify `agents/spec-validator.md`

**Location**: Insert `## Language` section immediately after `## Role` (after line 14, before `## Validation Target`).

**Insert the full agent variant text** (see above).

---

#### A-4: Modify `agents/code-validator.md`

**Location**: Insert `## Language` section immediately after `## Role` (after line 14, before `## Validation Target`).

**Insert the full agent variant text** (see above).

---

#### A-5: Modify `agents/coders/_base.md`

**Location**: Insert `## Language` section immediately after `## Role` (after line 14, before `## Common Rules`).

**Insert the full agent variant text** (see above).

---

### Part B: Command Files (8 files)

#### Instruction Text

**Short Command Variant** (for all command files except special cases):

```markdown
## Language

The SessionStart hook outputs the configured language (e.g., `[dotclaude] language: ko_KR`).

- All user-facing communication (questions, AskUserQuestion labels and descriptions, status messages, reports, error messages) MUST use the configured language.
```

---

#### B-1: Modify `commands/start-new.md`

**Location**: Insert the `## Language` section after the `## Configuration Loading` section. Specifically, insert it after the SPEC.md Configuration Metadata subsection ends (after line 33, before `## Role`).

**Insert the short command variant text** (see above).

---

#### B-2: Modify `commands/init-feature.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-3: Modify `commands/init-bugfix.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-4: Modify `commands/init-refactor.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-5: Modify `commands/init-github-issue.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-6: Modify `commands/_analysis.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-7: Modify `commands/merge-main.md`

**Location**: Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

#### B-8: Modify `commands/configure.md`

This file requires three changes:

**Change 1 - Remove future enhancement line (AD-6)**:

In the `## Future Enhancements (Out of Scope for v0.2.0)` section (line 482), remove the line:
```
- Language translation support (currently language setting stored but unused)
```

**Change 2 - Remove outdated note in Setting 1: Language**:

In the `#### Setting 1: Language` section (lines 155-163), the context block contains this line:
```
  Note: Translation features not implemented in v0.2.0 - this setting is stored for future use.
```
Remove this line. The language setting is now actively used.

**Change 3 - Add Language section**:

Append the `## Language` section at the end of the file (after the last line).

**Insert the short command variant text** (see above).

---

## Completion Checklist

### Agent Files
- [ ] `agents/technical-writer.md`: Existing `### Language & Style` section modified to separate document language (English) and user communication language (configured language)
- [ ] `agents/designer.md`: `## Language` section added after `## Role`
- [ ] `agents/spec-validator.md`: `## Language` section added after `## Role`
- [ ] `agents/code-validator.md`: `## Language` section added after `## Role`
- [ ] `agents/coders/_base.md`: `## Language` section added after `## Role`

### Command Files
- [ ] `commands/start-new.md`: `## Language` section added after `## Configuration Loading` section
- [ ] `commands/init-feature.md`: `## Language` section added at end of file
- [ ] `commands/init-bugfix.md`: `## Language` section added at end of file
- [ ] `commands/init-refactor.md`: `## Language` section added at end of file
- [ ] `commands/init-github-issue.md`: `## Language` section added at end of file
- [ ] `commands/_analysis.md`: `## Language` section added at end of file
- [ ] `commands/merge-main.md`: `## Language` section added at end of file
- [ ] `commands/configure.md`: `## Language` section added at end of file

### Configure.md Cleanup
- [ ] `commands/configure.md`: "Language translation support" line removed from future enhancements
- [ ] `commands/configure.md`: "Note: Translation features not implemented" line removed from Setting 1 context

### Verification
- [ ] All 5 agent files contain language instructions
- [ ] All 8 command files contain language instructions
- [ ] TechnicalWriter uses the modified existing section (not a new `## Language` section)
- [ ] All other agents use the full variant with both user-facing and AI-to-AI rules
- [ ] All commands use the short variant with user-facing rule only
- [ ] No existing content is broken or removed (only additions and the specified removals)

## Notes

- The `## Language` section references `[dotclaude] language: ko_KR` as an example. The actual language code varies per user configuration. `ko_KR` is used as the example because the SPEC.md for this feature was created in a `ko_KR` configured session.
- The TechnicalWriter is the only agent that does NOT get a new `## Language` section. It gets a modification to its existing `### Language & Style` section instead. This is because it already has explicit language guidance that would conflict with a new top-level section.
- The `coders/_base.md` language section is inherited by all coder agents (`javascript.md`, `python.md`, `rust.md`, `svelte.md`, `sql.md`) because those files extend the base. No changes needed to individual coder files.
