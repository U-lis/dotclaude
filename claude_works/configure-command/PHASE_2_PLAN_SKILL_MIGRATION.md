# Phase 2: Skill Migration

## Objective

Update all existing skills that reference hard-coded paths to use the configuration system. Replace all occurrences of `claude_works/` with the configurable `{working_directory}` value loaded from configuration files.

---

## Prerequisites

- [x] Phase 1 completed
- [x] Configuration infrastructure is functional
- [x] Default global config is created by SessionStart hook
- [x] `/dotclaude:configure` command works

---

## Scope

### In Scope
- Add configuration loading pattern to all skills that use working directory
- Replace `claude_works/` with `{working_directory}` variable in:
  - `skills/start-new/SKILL.md`
  - `skills/start-new/init-feature.md`
  - `skills/start-new/init-bugfix.md`
  - `skills/start-new/init-refactor.md`
  - `skills/design/SKILL.md`
  - `skills/code/SKILL.md`
  - `skills/update-docs/SKILL.md`
  - `skills/validate-spec/SKILL.md`
- Add configuration loading pattern to any other skills referencing `claude_works/`

### Out of Scope
- Modifying skills that don't use working directory
- Automatic migration of existing `claude_works/` directories (user must manually migrate)
- Documentation updates (handled in Phase 3)

---

## Instructions

### Step 1: Identify All Skills Using Working Directory

**Action**: Search all skill files for references to `claude_works/` path to ensure complete coverage

Expected files (from SPEC.md FR-9):
- `skills/start-new/SKILL.md`
- `skills/start-new/init-feature.md`
- `skills/start-new/init-bugfix.md`
- `skills/start-new/init-refactor.md`
- `skills/design/SKILL.md`
- `skills/code/SKILL.md`
- `skills/update-docs/SKILL.md`
- `skills/validate-spec/SKILL.md`

### Step 2: Add Configuration Loading Section to Each Skill

**Files**: All skills identified in Step 1

**Action**: Add a new section near the beginning of each skill (after Role section, before main workflow instructions) titled "## Configuration Loading"

Section content should instruct:
1. Load configuration from global and local config files
2. Apply merge strategy (local overrides global, defaults for missing keys)
3. Extract `working_directory` setting
4. Store in variable `WORKING_DIR` for use throughout skill
5. Use default `.dc_workspace` if config loading fails

Include bash code pattern:
```bash
# Load configuration
GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
LOCAL_CONFIG="$GIT_ROOT/.claude/dotclaude-config.json"

# Default value
WORKING_DIR=".dc_workspace"

# Load global config if exists
if [ -f "$GLOBAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // ".dc_workspace"' "$GLOBAL_CONFIG" 2>/dev/null || echo ".dc_workspace")
fi

# Load local config if exists (overrides global)
if [ -f "$LOCAL_CONFIG" ]; then
  WORKING_DIR=$(jq -r '.working_directory // "'"$WORKING_DIR"'"' "$LOCAL_CONFIG" 2>/dev/null || echo "$WORKING_DIR")
fi
```

### Step 3: Update skills/start-new/SKILL.md

**File**: `skills/start-new/SKILL.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Find all references to `claude_works/` literal string
3. Replace with `$WORKING_DIR` variable or `{working_directory}` in descriptions
4. Update directory creation instructions to use `$WORKING_DIR`
5. Update Step 2 instructions that reference init-*.md files (they use working_directory too)

Example transformations:
- `claude_works/{SUBJECT}/` → `$WORKING_DIR/{SUBJECT}/`
- `mkdir -p claude_works` → `mkdir -p "$WORKING_DIR"`
- Description text "claude_works directory" → "{working_directory} directory"

### Step 4: Update skills/start-new/init-feature.md

**File**: `skills/start-new/init-feature.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Replace all `claude_works/` with `$WORKING_DIR` variable
3. Update all directory paths in instructions
4. Update all file paths that reference working directory

Ensure consistency in:
- Directory creation instructions
- File path references
- Git operations
- Documentation references

### Step 5: Update skills/start-new/init-bugfix.md

**File**: `skills/start-new/init-bugfix.md`

**Action**: Same as Step 4
1. Add Configuration Loading section
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update directory and file path references

### Step 6: Update skills/start-new/init-refactor.md

**File**: `skills/start-new/init-refactor.md`

**Action**: Same as Step 4
1. Add Configuration Loading section
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update directory and file path references

### Step 7: Update skills/design/SKILL.md

**File**: `skills/design/SKILL.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update instructions for creating design documents
4. Ensure TechnicalWriter agent instructions reference correct paths with `$WORKING_DIR`

### Step 8: Update skills/code/SKILL.md

**File**: `skills/code/SKILL.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update instructions for reading PHASE_*_PLAN_*.md files
4. Update instructions for reading GLOBAL.md
5. Ensure all document references use `$WORKING_DIR` variable

### Step 9: Update skills/update-docs/SKILL.md

**File**: `skills/update-docs/SKILL.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update instructions for reading work documents
4. Update any paths used in git operations

### Step 10: Update skills/validate-spec/SKILL.md

**File**: `skills/validate-spec/SKILL.md`

**Action**:
1. Add Configuration Loading section from Step 2
2. Replace all `claude_works/` with `$WORKING_DIR`
3. Update instructions for finding and validating SPEC.md
4. Update any document path references

### Step 11: Search for Additional References

**Action**: Perform final search across all skills for any remaining hard-coded `claude_works/` references

Search patterns to check:
- Literal string `claude_works/`
- Literal string `claude_works`
- Any path construction that assumes working directory name

Fix any remaining references found.

---

## Implementation Notes

### Consistency Requirements
- All skills must use identical configuration loading pattern
- All skills must use same variable name: `WORKING_DIR`
- All skills must handle config loading errors gracefully (fall back to default)
- All skills must support both global and local config with proper merging

### Variable Usage in Bash
When using `WORKING_DIR` in bash commands:
- Always quote: `"$WORKING_DIR"`
- Use in paths: `"$WORKING_DIR/{SUBJECT}/SPEC.md"`
- Use in mkdir: `mkdir -p "$WORKING_DIR"`

### Variable Usage in Descriptions
In markdown text describing workflow:
- Use placeholder: `{working_directory}`
- Example: "Create design documents in {working_directory}/{SUBJECT}/ directory"

### Error Handling
All configuration loading must be fault-tolerant:
- Invalid JSON → use default value
- Missing file → use default value
- Permission denied → use default value
- Never fail skill execution due to config issues

---

## Completion Checklist

- [x] Configuration Loading section added to all 8 identified skills
- [x] All literal `claude_works/` strings replaced in skills/start-new/SKILL.md
- [x] All literal `claude_works/` strings replaced in skills/start-new/init-feature.md
- [x] All literal `claude_works/` strings replaced in skills/start-new/init-bugfix.md
- [x] All literal `claude_works/` strings replaced in skills/start-new/init-refactor.md
- [x] All literal `claude_works/` strings replaced in skills/design/SKILL.md
- [x] All literal `claude_works/` strings replaced in skills/code/SKILL.md
- [x] All literal `claude_works/` strings replaced in skills/update-docs/SKILL.md
- [x] All literal `claude_works/` strings replaced in skills/validate-spec/SKILL.md
- [x] All literal `claude_works/` strings replaced in agents/designer.md
- [x] All literal `claude_works/` strings replaced in agents/spec-validator.md
- [x] All literal `claude_works/` strings replaced in agents/technical-writer.md
- [x] Final search confirms no remaining hard-coded `claude_works/` references in skills/ and agents/
- [x] All skills use consistent configuration loading pattern
- [x] All skills use same variable name `WORKING_DIR`
- [x] All bash code properly quotes variables
- [x] All error handling is fault-tolerant

---

## Verification

### Manual Verification
```bash
# Verify no hard-coded claude_works references remain
grep -r "claude_works" skills/ --exclude-dir=.git

# Should only find:
# - Comments explaining migration from claude_works
# - Historical references in documentation
# - No literal path construction with claude_works/

# Test with custom working directory
echo '{"working_directory": "my_workspace"}' > ~/.claude/dotclaude-config.json

# Run a workflow and verify it uses my_workspace instead of .dc_workspace
# For example: /dotclaude:start-new
# Check that files are created in my_workspace/ directory

# Test local override
cd /path/to/test/project
mkdir -p .claude
echo '{"working_directory": "project_docs"}' > .claude/dotclaude-config.json

# Run workflow and verify it uses project_docs/ instead of global setting
```

### Expected Output
- No grep matches for literal `claude_works/` path construction
- Skills use `$WORKING_DIR` variable throughout
- Configuration loading works correctly
- Local config overrides global config
- Default values work when no config exists

---

## Notes

- This phase does NOT migrate existing `claude_works/` directories - users must do this manually if desired
- After this phase, users can set working_directory to `claude_works` if they want to keep existing name
- All skills remain backward compatible - default value `.dc_workspace` works for new projects
- Existing projects with `claude_works/` directory can either:
  1. Keep using it by setting `working_directory: "claude_works"` in config
  2. Migrate to new name using `/dotclaude:configure` migration workflow
- Skills should never assume working directory name - always load from config

---

## Completion Date

2026-01-27

## Completed By

Claude Opus 4.5
