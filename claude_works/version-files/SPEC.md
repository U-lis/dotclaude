<!-- dotclaude-config
working_directory: claude_works
base_branch: main
language: ko_KR
worktree_path: ../dotclaude-bugfix-version-files
-->

# Configurable Version Files - Specification

## Overview

The tagging command (`commands/tagging.md`) and `CLAUDE.md` currently hardcode three dotclaude-specific version files (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`). This makes the version management system unusable for non-plugin projects and projects that use standard language-specific version files (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.).

This specification defines a configurable `version_files` setting that replaces the hardcoded file list with a per-project configuration, including auto-detection of common version files when no explicit configuration is provided.

**GitHub Issue:** #39 (label: bug)
**Target Version:** 0.3.1
**Work Type:** bugfix

## Functional Requirements

- [ ] FR-1: Add `version_files` configuration to the configuration schema
  - Add a new `version_files` field to `dotclaude-config.json` (both global and local).
  - The field is an array of objects. Each object has:
    - `path` (string, required): Relative path from project root to the version file (e.g., `"package.json"`, `".claude-plugin/plugin.json"`).
    - `pattern` (string, required): A regex pattern used to extract the version string from the file. The pattern MUST contain a single capture group that matches the version number.
  - Example configuration:
    ```json
    {
      "version_files": [
        { "path": "package.json", "pattern": "\"version\":\\s*\"([^\"]+)\"" },
        { "path": ".claude-plugin/plugin.json", "pattern": "\"version\":\\s*\"([^\"]+)\"" },
        { "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" }
      ]
    }
    ```
  - `CHANGELOG.md` is mandatory. If the user provides a `version_files` array that does not include a `CHANGELOG.md` entry, the system MUST automatically append the default CHANGELOG.md entry.

- [ ] FR-2: Auto-detect common version files when `version_files` is not configured
  - When `version_files` is absent, null, or an empty array in the merged configuration, auto-detect version files by checking for existence of the following files (in order):
    1. `CHANGELOG.md` -- always included (mandatory)
    2. `package.json` -- pattern: `"version":\s*"([^"]+)"`
    3. `pyproject.toml` -- pattern: `version\s*=\s*"([^"]+)"`
    4. `Cargo.toml` -- pattern: `version\s*=\s*"([^"]+)"` (under `[package]` section)
    5. `pom.xml` -- pattern: `<version>([^<]+)</version>` (first occurrence)
    6. `.claude-plugin/plugin.json` -- pattern: `"version":\s*"([^"]+)"`
    7. `.claude-plugin/marketplace.json` -- pattern: `"version":\s*"([^"]+)"`
  - Only files that actually exist in the project root are included in the auto-detected list.
  - Auto-detection runs at tagging time, not at configuration time.

- [ ] FR-3: Update tagging command to use configured `version_files`
  - Modify `commands/tagging.md` to replace the hardcoded 3-file version consistency check with a dynamic check based on the resolved `version_files` list (configured or auto-detected).
  - The Version Consistency Check section must:
    1. Load `version_files` from merged config (global < local).
    2. If empty/absent, run auto-detection (FR-2).
    3. For each entry, read the file at `path` and extract the version using `pattern`.
    4. Compare ALL extracted versions against the target version.
    5. If ANY mismatch: HALT and report which files have which versions.
  - The Prerequisites section must be updated to remove hardcoded `.claude-plugin/` file references.
  - The output format for version consistency failure must dynamically list all checked files (not hardcoded 3 files).

- [ ] FR-4: Update `CLAUDE.md` version management sections
  - Replace the hardcoded "Version Files" list with a reference to the configurable `version_files` setting.
  - Replace the hardcoded "Version Tagging Checklist" bash snippet with a generic instruction to use the tagging command or check configured version files.
  - The updated sections must explain that version files are configurable per-project via `dotclaude-config.json` and auto-detected when not explicitly configured.

- [ ] FR-5: Add `version_files` management to the configure command
  - Add a new setting (Setting 6) to `commands/configure.md` for managing `version_files`.
  - The interactive workflow must support:
    - **View**: Display current version_files list (configured or auto-detected).
    - **Add**: Add a new version file entry (prompt for `path` and `pattern`).
    - **Remove**: Remove an existing version file entry (cannot remove CHANGELOG.md).
    - **Reset**: Clear explicit configuration and revert to auto-detection.
  - Validation rules:
    - `path` must be a relative path (no leading `/`, no `..`).
    - `pattern` must be a valid regex with exactly one capture group.
    - Cannot add duplicate `path` entries.
    - Cannot remove the CHANGELOG.md entry.

## Non-Functional Requirements

- [ ] NFR-1: Backward compatibility
  - When no `version_files` is configured, auto-detection MUST find files that are usually caintains version info inside the project (`CHANGELOG.md`, `pyproject.toml`, `package.json`, etc.). This ensures zero behavioral change for existing dotclaude development workflows.
- [ ] NFR-2: Minimal configuration overhead
  - Most projects should work with auto-detection alone. Explicit `version_files` configuration should only be needed for non-standard version file locations or patterns.
- [ ] NFR-3: Clear error messages
  - When version consistency check fails, the error output must list every checked file with its extracted version (or "not found" / "no version match"), making it straightforward to identify the mismatch.

## Constraints

- Configuration is stored in the existing `dotclaude-config.json` file (global: `~/.claude/dotclaude-config.json`, local: `<project_root>/.claude/dotclaude-config.json`). No new config files are introduced.
- The existing tagging workflow (version consistency check, annotated tags, mandatory push) must be preserved. Only the source of "which files to check" changes.
- `CHANGELOG.md` is always mandatory and cannot be removed from the version files list.
- The `check-update.sh` hook is out of scope. It reads the installed plugin version from the plugin cache directory, not the project version. It does not participate in project version management.

## Out of Scope

- Automatic version bumping in files (users handle version updates manually or via `update-docs`).
- Version file format auto-detection beyond the predefined patterns (users must specify `pattern` for custom files).
- Changes to the `check-update.sh` hook (reads installed plugin version, unrelated to project version management).
- Version range or constraint validation (e.g., semver ordering checks).
- Multi-line pattern matching for version extraction.

## Open Questions

None at this time. All requirements have been confirmed by the user.
