# PHASE 1: Core Mechanism - Dynamic Version Files in Tagging Command

## Objective

Replace the hardcoded 3-file version consistency check in `commands/tagging.md` with a dynamic check based on a configurable `version_files` list, including auto-detection when no explicit configuration exists.

## Target File

- `commands/tagging.md`

## Architecture

### version_files Schema

Each entry in the `version_files` array:

```json
{
  "path": "relative/path/to/file",
  "pattern": "regex with (one capture group)"
}
```

### Resolution Order

1. Load `version_files` from merged config (global `~/.claude/dotclaude-config.json` < local `<project_root>/.claude/dotclaude-config.json`)
2. If the field is absent, null, or an empty array: run auto-detection
3. If present and non-empty: use as-is, but ensure CHANGELOG.md entry exists (append default if missing)

### Auto-Detection Order

When no explicit `version_files` configured, check for existence of these files in order:

| Priority | File | Pattern | Notes |
|----------|------|---------|-------|
| 1 | `CHANGELOG.md` | `## \[([^\]]+)\]` | Always included (mandatory) |
| 2 | `package.json` | `"version":\s*"([^"]+)"` | Node.js projects |
| 3 | `pyproject.toml` | `version\s*=\s*"([^"]+)"` | Python projects |
| 4 | `Cargo.toml` | `version\s*=\s*"([^"]+)"` | Rust projects (under [package]) |
| 5 | `pom.xml` | `<version>([^<]+)</version>` | Java/Maven projects (first occurrence) |
| 6 | `.claude-plugin/plugin.json` | `"version":\s*"([^"]+)"` | dotclaude plugin projects |
| 7 | `.claude-plugin/marketplace.json` | `"version":\s*"([^"]+)"` | dotclaude plugin projects |

Only files that actually exist in the project root are included.

### CHANGELOG.md Mandatory Rule

- CHANGELOG.md is ALWAYS included in the version files list.
- If user provides explicit `version_files` without a CHANGELOG.md entry, the system auto-appends:
  ```json
  { "path": "CHANGELOG.md", "pattern": "## \\[([^\\]]+)\\]" }
  ```
- The CHANGELOG.md entry cannot be removed.

## Checklist

### Prerequisites Section
- [ ] Remove hardcoded `.claude-plugin/plugin.json` prerequisite
- [ ] Remove hardcoded `.claude-plugin/marketplace.json` prerequisite
- [ ] Add generic prerequisite: "CHANGELOG.md exists with version entry"
- [ ] Add prerequisite: "Version files are configured in dotclaude-config.json OR auto-detectable in project root"

### New Section: Version Files Resolution
- [ ] Add new section between "Version Argument" and "Workflow" explaining version_files resolution
- [ ] Document config loading: merged config (global < local)
- [ ] Document auto-detection logic with full file/pattern table
- [ ] Document CHANGELOG.md mandatory rule
- [ ] Document the bash/pseudo-code for loading version_files from config

### Workflow Section (Step 2)
- [ ] Replace "Read version from .claude-plugin/plugin.json" with "Resolve version_files list (configured or auto-detected)"
- [ ] Replace "Read version from .claude-plugin/marketplace.json (plugins[0].version)" with "For each entry in version_files, read file at `path` and extract version using `pattern`"
- [ ] Replace "Read latest version from CHANGELOG.md" (already covered by version_files)
- [ ] Replace "ALL THREE must match" with "ALL extracted versions must match the target version"
- [ ] Keep the HALT behavior on mismatch

### Version Consistency Check Section
- [ ] Replace the hardcoded 3-row table with a description of dynamic checking
- [ ] Explain: "For each entry in the resolved version_files list, read the file and apply the regex pattern to extract the version"
- [ ] Keep the rule: "All values MUST match the target version"
- [ ] Keep the HALT instruction on mismatch

### Version Consistency Failure Output Format
- [ ] Replace hardcoded `plugin.json` / `marketplace.json` / `CHANGELOG.md` lines with dynamic listing
- [ ] Format: list each checked file path with its extracted version (or "not found" / "no version match")
- [ ] Keep Status and Action required lines

### Backward Compatibility
- [ ] When no version_files configured, auto-detection for a dotclaude plugin project MUST find: CHANGELOG.md, .claude-plugin/plugin.json, .claude-plugin/marketplace.json (same 3 files as before)
- [ ] The workflow (tag creation, push, error handling) is UNCHANGED - only the "which files to check" logic changes

## Acceptance Criteria

1. A dotclaude plugin project with no `version_files` config behaves identically to before (auto-detects the same 3 files)
2. A Node.js project with no config auto-detects `CHANGELOG.md` + `package.json`
3. A project with explicit `version_files` config uses exactly those files (plus CHANGELOG.md if missing)
4. Version consistency failure output dynamically lists all checked files
5. The rest of the tagging workflow (tag creation, push, error handling, output format) is unchanged
