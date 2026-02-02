# README Restructure - Design Document

## Overview

Reorganize the README.md for progressive disclosure and extract the directory tree into a dedicated architecture document. This is a documentation-only change affecting two files: one new (`docs/ARCHITECTURE.md`) and one modified (`README.md`).

## Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-1 | Single new file (`docs/ARCHITECTURE.md`), one modified file (`README.md`) | Minimal file footprint; directory tree is reference material that does not belong in the landing page |
| AD-2 | `docs/ARCHITECTURE.md` contains only the directory tree with a brief intro paragraph | Keep the file focused; avoid scope creep into full architecture docs |
| AD-3 | README retains all content EXCEPT the directory tree and three removed blocks (JSON format, Common Use Cases, Language Support detail) | These blocks duplicate information already captured in the settings table or are low-value for first-time readers |
| AD-4 | Section ordering follows progressive disclosure: Intro > Install > Quick Start > Config > Commands > Appendix > License | Users need setup instructions before workflow details |
| AD-5 | Prerequisites merged into Installation as an optional subsection | Avoids a standalone section for a single bullet point |
| AD-6 | Appendix consolidates reference material (agents table, document types, phase naming, 13-step workflow table) | Reference material is valuable but should not interrupt the main reading flow |
| AD-7 | Orchestrator section splits: overview goes to Commands section, 13-step table goes to Appendix | The overview is useful in context of commands; the detailed table is reference material |
| AD-8 | Cross-reference link from README intro paragraph to `docs/ARCHITECTURE.md` | Enables navigation without cluttering the README |

## File Change Summary

| Action | File | Description |
|--------|------|-------------|
| CREATE | `docs/ARCHITECTURE.md` | Directory tree with intro paragraph and backlink to README |
| MODIFY | `README.md` | Reorder sections, remove 3 blocks, add cross-reference link |

---

## Phase 1: Extract Directory Tree to docs/ARCHITECTURE.md

### Objective

Create `docs/ARCHITECTURE.md` containing the full directory tree currently in README.md lines 17-65, preceded by a brief intro paragraph. This file must exist before Phase 2 removes the tree from README.

### Prerequisites

- None (first phase)

### Instructions

1. Create directory `docs/` at repository root (`/home/ulismoon/Documents/dotclaude/docs/`)
2. Create file `docs/ARCHITECTURE.md` with the following structure:
   - H1 heading: `# dotclaude - Architecture`
   - Intro paragraph: One sentence explaining this document shows the project directory structure. Include a markdown link back to the main `README.md` (relative path: `../README.md`).
   - H2 heading: `## Directory Structure`
   - The full fenced code block from README lines 17-65 (the tree starting with `.` and ending with `{working_directory}/`), copied verbatim with no modifications to content
3. Verify the markdown renders correctly (no broken fences, correct indentation)

### Completion Checklist

- [ ] `docs/` directory exists at repository root
- [ ] `docs/ARCHITECTURE.md` exists with H1 heading
- [ ] Intro paragraph includes backlink to `../README.md`
- [ ] Full directory tree is present inside a fenced code block
- [ ] Tree content matches README lines 17-65 exactly
- [ ] No trailing whitespace issues or broken markdown syntax

---

## Phase 2: Reorganize README.md

### Objective

Restructure README.md into seven sections following progressive disclosure order. Remove three low-value blocks. Add cross-reference to `docs/ARCHITECTURE.md`. Merge Prerequisites into Installation.

### Prerequisites

- Phase 1 completed (`docs/ARCHITECTURE.md` exists with the directory tree)

### Instructions

Rewrite `README.md` with the following section order. Each instruction references the current README line numbers for source content.

#### Section 1 - Intro (lines 1-14, modified)

- Keep H1 `# dotclaude` and the subtitle line (line 3)
- Keep `## Overview` heading and bullet list (lines 5-13)
- After the bullet list, add one new line: `For the full project structure, see [Architecture](docs/ARCHITECTURE.md).`
- REMOVE: The entire `## Structure` section (lines 15-65) -- this content now lives in `docs/ARCHITECTURE.md`

#### Section 2 - Installation (lines 249-272, moved up; lines 274-279 merged)

- Move `## Installation` (lines 249-272) to directly follow the Intro section
- Append a subsection `### Optional: GitHub CLI` containing the Prerequisites content (lines 276-278), reworded as:
  - "The `/dotclaude:pr` command requires [GitHub CLI (`gh`)](https://cli.github.com/)."
  - Include install hint: `brew install gh` (macOS) or link to installation guide
  - Include auth hint: `gh auth login`
- REMOVE: The standalone `## Prerequisites` section heading (line 274)

#### Section 3 - Quick Start (lines 280-329, adapted)

- Rename `## Usage` to `## Quick Start`
- Keep `### Start New Work` subsection (lines 282-303) as-is
- Keep `### Update dotclaude` subsection (lines 306-313) as-is
- Keep `### Manual Execution (Bypass Orchestrator)` subsection (lines 315-329) as-is
- No content changes, only the H2 heading changes from "Usage" to "Quick Start"

#### Section 4 - Configuration (lines 176-206, trimmed)

- Keep `## Configuration` heading and intro line (lines 176-178)
- Keep `### Configuration Files` table (lines 180-187) and merge-order note (line 187)
- Keep `### Configuration Command` block (lines 189-195)
- Keep `### Available Settings` table (lines 197-206)
- REMOVE: `### Configuration File Format` JSON block (lines 207-217)
- REMOVE: `### Common Use Cases` subsection (lines 219-234)
- REMOVE: `### Language Support` subsection (lines 236-247)

#### Section 5 - Commands & Core Workflow (lines 112-129, 67-83, 85-93)

- Heading: `## Commands & Core Workflow`
- First, include the `### Skills (Commands)` content: the intro line (line 114) and full command table (lines 116-128). Change the H2 `## Skills (Commands)` to H3 `### Skills (Commands)`
- Second, include the workflow diagram under `### Workflow Overview`: the ASCII diagram from lines 69-83. Change the H2 `## Workflow` to H3 `### Workflow Overview`
- Third, include a condensed orchestrator overview under `### Orchestrator`: the four bullet points from lines 89-92 and the note that the orchestrator is integrated into `/dotclaude:start-new` (line 87). Change the H2 `## Orchestrator` to H3 `### Orchestrator`. Do NOT include the `### 13-Step Workflow` sub-subsection here (it moves to Appendix)

#### Section 6 - Appendix

- Heading: `## Appendix`
- Sub-sections in this order:
  1. `### Agents` -- content from lines 130-142 (agents table + frontmatter note + orchestrator note). Change original H2 to H3.
  2. `### Document Types` -- content from lines 144-167 (simple/complex/parallel task file structures). Change original H2 to H3.
  3. `### Phase Naming Convention` -- content from lines 168-175 (naming pattern table). Change original H2 to H3.
  4. `### 13-Step Workflow` -- content from lines 94-111 (the step table from the Orchestrator section). Change original H3 to H3 under Appendix.

#### Section 7 - License (lines 331-334)

- Keep `## License` and `MIT` as-is, no changes

### Content Migration Reference

This table maps every current README section to its destination:

| Current Section (lines) | Destination | Action |
|--------------------------|-------------|--------|
| H1 + subtitle (1-3) | Section 1 - Intro | Keep |
| Overview (5-14) | Section 1 - Intro | Keep, add ARCHITECTURE.md link |
| Structure (15-65) | REMOVED from README | Extracted to `docs/ARCHITECTURE.md` |
| Workflow (67-83) | Section 5 - Commands & Core Workflow | Moved, demoted to H3 |
| Orchestrator overview (85-93) | Section 5 - Commands & Core Workflow | Moved, demoted to H3 |
| 13-Step Workflow (94-111) | Section 6 - Appendix | Moved |
| Skills/Commands (112-129) | Section 5 - Commands & Core Workflow | Moved, demoted to H3 |
| Agents (130-142) | Section 6 - Appendix | Moved |
| Document Types (144-167) | Section 6 - Appendix | Moved |
| Phase Naming (168-175) | Section 6 - Appendix | Moved |
| Configuration intro + tables + command (176-206) | Section 4 - Configuration | Kept, trimmed |
| Configuration File Format JSON (207-217) | REMOVED | Redundant with settings table |
| Common Use Cases (219-234) | REMOVED | Low-value examples |
| Language Support detail (236-247) | REMOVED | Already covered by settings table description |
| Installation (249-272) | Section 2 - Installation | Moved up |
| Prerequisites (274-279) | Section 2 - Installation (subsection) | Merged into Installation |
| Usage (280-329) | Section 3 - Quick Start | Renamed heading |
| License (331-334) | Section 7 - License | Keep |

### Completion Checklist

- [ ] README.md has exactly 7 top-level sections in order: Intro, Installation, Quick Start, Configuration, Commands & Core Workflow, Appendix, License
- [ ] Intro contains link to `docs/ARCHITECTURE.md`
- [ ] No `## Structure` section exists in README
- [ ] Installation section includes Optional: GitHub CLI subsection
- [ ] No standalone `## Prerequisites` section exists
- [ ] `## Usage` renamed to `## Quick Start`
- [ ] Configuration section does NOT contain JSON format block, Common Use Cases, or Language Support subsections
- [ ] Commands & Core Workflow contains: Skills table, Workflow diagram, Orchestrator overview (no 13-step table)
- [ ] Appendix contains: Agents, Document Types, Phase Naming, 13-Step Workflow (in that order)
- [ ] License section is present and unchanged
- [ ] All internal markdown links are valid
- [ ] No content was accidentally lost (cross-check against migration reference table)
- [ ] No duplicate content exists between sections

## Notes

- This is a documentation-only change. No code files, tests, or configurations are modified.
- The directory tree in `docs/ARCHITECTURE.md` must be kept in sync with the actual project structure on future changes. Consider adding a note about this in `ARCHITECTURE.md`.
- The three removed blocks (JSON format, Common Use Cases, Language Support) are intentional removals. Their information is either redundant (JSON block duplicates the settings table defaults) or too detailed for a README (use cases and language support detail).
