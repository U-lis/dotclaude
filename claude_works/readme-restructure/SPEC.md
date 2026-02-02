<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
target_version: 0.3.0
-->

# README Restructure - Specification (Refactoring)

## Target

`README.md` - The main project documentation file (334 lines). This is the primary entry point for external users discovering dotclaude on GitHub or the Claude Code plugin marketplace.

## Current Problems

1. **Information overload for newcomers**: The README is 334 lines long with deep internal details (directory tree, 13-step orchestrator table, phase naming conventions) that overwhelm first-time users before they reach installation instructions at line 249.
2. **Installation buried too deep**: Users must scroll past 248 lines of technical detail before finding how to install the plugin. This violates the principle of progressive disclosure.
3. **Mixed audience content**: Developer-internal reference material (document types, phase naming, full configuration examples) is intermixed with user-facing onboarding content, serving neither audience well.
4. **Section ordering does not match user journey**: A first-time user needs intro, install, quick start -- not directory tree and orchestrator internals up front.
5. **Verbose configuration section**: The Configuration section spans 72 lines (lines 176-248) with redundant examples (common use cases, configuration file format) that repeat information already conveyed in the settings table.
6. **50-line directory tree is developer-internal detail**: The Structure section uses 50 lines for a full directory tree that is not needed by users who just want to install and use the plugin.

## Goal State

A reorganized documentation set where:

- **README.md** (~180-220 lines) retains most content but reordered for progressive disclosure:
  1. **Intro** - Concise introduction (what dotclaude is, why use it)
  2. **Installation** - Plugin marketplace (recommended) + manual installation + optional prerequisites (gh CLI noted as optional within this section)
  3. **Quick Start** - `/dotclaude:start-new` with brief flow description and usage examples
  4. **Configuration** - Condensed settings reference (table only, remove verbose examples and JSON format block)
  5. **Commands & Core Workflow** - Skills/commands table + core workflow flow diagram + orchestrator overview
  6. **Appendix** - Agent list, Document types, Phase naming convention, 13-step workflow table
  7. **License** - MIT

- **docs/ARCHITECTURE.md** contains only the extracted directory structure:
  - Full directory tree (the 50-line Structure section currently at lines 16-65)
  - Brief introductory context for the tree

### Section Order Rationale

The proposed order follows **progressive disclosure** for first-time users:

| Position | Section | Purpose |
|----------|---------|---------|
| 1 | Intro | Understand what this is |
| 2 | Installation | Get it installed (prerequisites noted inline as optional) |
| 3 | Quick Start | Use it immediately |
| 4 | Configuration | Customize when needed |
| 5 | Commands & Core Workflow | Deeper usage reference |
| 6 | Appendix | Reference-level detail |

This order is appropriate for newcomers because: understand -> setup -> use -> customize -> reference. Prerequisites (gh CLI) are integrated into the Installation section as optional since they are only needed for `/dotclaude:pr`. This avoids creating an unnecessary barrier before installation. Each section builds on the previous one. Users can stop reading at any point and still have enough context to use the plugin at their current depth of need.

## Behavior Change Policy

**Preserve behavior (required)** - This is a pure documentation refactoring. No functional changes to any command, agent, hook, or configuration file. Only `.md` documentation files are affected.

## Test Coverage

No automated tests exist for documentation. Verification is manual:
- All internal cross-references resolve correctly
- No content is lost during reorganization
- GitHub renders the README correctly as a landing page
- Link from README to docs/ARCHITECTURE.md works
- Configuration section is shorter but still contains all settings information

## Dependencies

None. README.md is standalone documentation with no build or runtime dependencies.

## XP Principle Reference

**Progressive Disclosure** applied to documentation:
- Each section is positioned based on when a user needs it in their journey
- README: single file serves all audiences, organized from beginner to advanced
- docs/ARCHITECTURE.md: extracted only the directory tree (developer-internal detail)

## Analysis Results

### Related Files

| File | Role | Action |
|------|------|--------|
| `README.md` | Primary target | Reorganize sections, condense Configuration |
| `docs/ARCHITECTURE.md` | New file | Extract directory structure tree only |
| `CHANGELOG.md` | Reference only | No modification |
| `.claude-plugin/marketplace.json` | Reference only | No modification |

### Content Migration Map

| Current README Section | Lines | Destination | Action |
|------------------------|-------|-------------|--------|
| Overview (lines 1-14) | 14 | README.md section 1 (Intro) | Keep, condense slightly |
| Structure (lines 16-65) | 50 | docs/ARCHITECTURE.md | Extract (only section that moves) |
| Workflow (lines 67-83) | 17 | README.md section 6 (Commands & Core Workflow) | Keep, move down |
| Orchestrator (lines 85-111) | 27 | README.md section 6 (Commands & Core Workflow) for overview, section 7 (Appendix) for 13-step table | Keep, split |
| Skills/Commands (lines 112-129) | 18 | README.md section 6 (Commands & Core Workflow) | Keep, move |
| Agents (lines 130-142) | 13 | README.md section 7 (Appendix) | Keep, move to appendix |
| Document Types (lines 144-167) | 24 | README.md section 7 (Appendix) | Keep, move to appendix |
| Phase Naming (lines 169-175) | 7 | README.md section 7 (Appendix) | Keep, move to appendix |
| Configuration (lines 176-248) | 73 | README.md section 5 (Configuration) | Keep settings table, remove verbose examples |
| Installation (lines 249-272) | 24 | README.md section 2 (Installation) | Keep, move up |
| Prerequisites (lines 273-279) | 7 | README.md section 2 (Installation) | Merge into Installation as optional subsection |
| Usage (lines 280-329) | 50 | README.md section 3 (Quick Start) | Integrate start-new flow, tagging, manual execution |
| License (lines 331-334) | 4 | README.md section 7 (License) | Keep at bottom |

### Content Removed from README (Condensed)

The following content is **removed** (not moved) to reduce verbosity in the Configuration section:

| Content | Current Lines | Reason for Removal |
|---------|---------------|-------------------|
| Configuration File Format (JSON block) | 208-217 | Duplicates the settings table; users can infer JSON format from the table |
| Common Use Cases (3 examples) | 219-234 | Redundant; the `/dotclaude:configure` command is self-explanatory |
| Language Support detail block | 236-247 | Redundant; the settings table already describes the `language` setting |

### Conflicts

| Conflict | Resolution |
|----------|------------|
| External links pointing to README section anchors | Most sections stay in README with new anchor names; add a note in docs/ARCHITECTURE.md for the moved Structure section |
| GitHub auto-renders README.md as landing page | README retains all essential content, just reordered; landing page impression is improved |
| marketplace.json has its own description field | No conflict: marketplace.json description is independent and requires no change |

### Edge Cases

1. **Broken anchor links from external sources**: The `#structure` anchor will break since that section moves to docs/ARCHITECTURE.md. All other section anchors change names due to reorganization (e.g., `#configuration` stays but position changes). Mitigation: Accept this for a project of this scale.
2. **GitHub navigation**: docs/ARCHITECTURE.md requires users to click into the docs/ directory. Mitigation: Provide a clear link from the README Intro section.
3. **Plugin marketplace display**: The marketplace may display README.md content. The reorganized README will have a stronger opening (intro + prerequisites + install) compared to the current version where the directory tree dominates the fold.

## Refactoring Plan Summary

| Phase | Description | Output |
|-------|-------------|--------|
| 1 | Create `docs/` directory and extract Structure section (lines 16-65) into `docs/ARCHITECTURE.md` | 1 new documentation file |
| 2 | Reorganize `README.md`: reorder sections, condense Configuration, add Appendix section | Updated README.md (~180-220 lines) |

## Out of Scope

- Functional changes to any command, agent, hook, or configuration file
- Changes to CHANGELOG.md content
- Changes to marketplace.json or plugin.json
- Translation of documentation content
- Adding new features or documentation for unreleased features
- Automated testing infrastructure for documentation
- Creating docs/CONFIGURATION.md (content stays in README)
- Creating docs/COMMANDS.md (content stays in README)
- Rewriting content (only reorganize and condense)
