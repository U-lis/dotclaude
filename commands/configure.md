---
description: Interactive configuration management for dotclaude settings
---
# /dotclaude:configure

Edit dotclaude settings at global or local scope. User-facing text follows Contract: Language. The keys, defaults, file locations, and merge order are defined in `${CLAUDE_PLUGIN_ROOT}/commands/_contract.md` (Configuration); this command only edits the files.

## Step 1: Load

Read `~/.claude/dotclaude-config.json` and, when inside a git repository, `<git_root>/.claude/dotclaude-config.json` (`git rev-parse --show-toplevel`). Merge defaults < global < local and show the result. A file that is not valid JSON is reported and treated as absent; an unreadable file likewise.

## Step 2: Scope

Ask which file to edit: Global (all projects) or Local (this project). Local outside a git repository is an error; ask again.

## Step 3: Basic settings

One AskUserQuestion with three questions, each defaulting to the current value (do not add a manual "Other" option; AskUserQuestion adds one): `language` (a locale code such as `en_US`, `ko_KR`), `working_directory` (relative path under the project root), `base_branch`. Then validate:

- `language`: non-empty.
- `working_directory`: non-empty, not absolute, no `..` component, not `.`.
- `base_branch`: non-empty.

Re-ask only the invalid item. If `working_directory` changed and the old directory exists with files, ask: Migrate (move the directory to the new name) or Start fresh (leave it). Never move it without asking.

## Step 4: Version files

Ask: View, Add, Remove, Reset to auto-detection, Auto-detect and suggest, or Skip. Loop on this menu until Skip.

`version_files` is a list of `{path, pattern}`; `pattern` is a regex with exactly one capture group that yields the version. An empty list means auto-detection at tagging time. The known files and their patterns are the table in `${CLAUDE_PLUGIN_ROOT}/commands/tagging.md` (Auto-Detection); `CHANGELOG.md` with pattern `## \[([^\]]+)\]` is always present in an explicit list and cannot be removed.

- View: the explicit list, or "auto-detect" plus what auto-detection would find in this project.
- Add: ask path (same rules as `working_directory`) and pattern (exactly one capture group); reject duplicates; when the list was empty, note that an explicit list replaces auto-detection; append the CHANGELOG entry if missing.
- Remove: numbered list; refuse to remove CHANGELOG.md; when the last other entry is removed, suggest Reset.
- Reset: set `[]`.
- Auto-detect and suggest: for each known file, show detected version and status (new, already configured, configured but missing), then offer to add the new ones and remove the missing ones with the Add/Remove rules.

## Step 5: Save and confirm

Write the four keys as JSON to the chosen file, storing values exactly as entered after validation (no path normalization such as stripping a trailing slash) (create the parent directory if needed) and show the file path and the saved values. Changes apply to the next command invocation; nothing needs a restart. Do not create `working_directory`; commands create it when they need it.

Report write errors (permissions, invalid directory) with the path and stop; do not retry silently.
