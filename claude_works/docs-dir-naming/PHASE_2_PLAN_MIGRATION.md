# Phase 2: Migration Support and Documentation

## Objective

Provide migration guidance for existing date-less directories (30+ existing directories in `claude_works/`) and update user-facing documentation to explain the new `{doc_dir}` naming convention.

## Prerequisites

- Phase 1 completed (all path references updated)
- `{doc_dir}` variable fully functional in `_init-common.md`

## Instructions

### 2.1: Add migration guidance section to `_init-common.md`

**File**: `commands/_init-common.md`
**Location**: Add a new section at the end of the file (after the "Skip Conditions" section, around line 283)

Add a new section titled "Migration: Existing Directories" with the following content:

```markdown
## Migration: Existing Directories

For directories created before the `{doc_dir}` date-prefix convention, use `git log` to detect the original creation date and rename.

### Detection Method

To find the creation date of an existing directory:
```bash
# Get the first commit that created files in the directory
git log --diff-filter=A --format="%ai" -- {working_directory}/{old_directory_name}/SPEC.md | tail -1
```

### Rename Pattern

```bash
# Example: rename "auth" to "2026_01_15-auth"
CREATION_DATE=$(git log --diff-filter=A --format="%Y_%m_%d" -- {working_directory}/auth/SPEC.md | tail -1)
mv {working_directory}/auth {working_directory}/${CREATION_DATE}-auth
```

### Bulk Migration

For all existing date-less directories:
```bash
for dir in {working_directory}/*/; do
  dirname=$(basename "$dir")
  # Skip if already has date prefix (matches YYYY_MM_DD- pattern)
  if [[ "$dirname" =~ ^[0-9]{4}_[0-9]{2}_[0-9]{2}- ]]; then
    continue
  fi
  CREATION_DATE=$(git log --diff-filter=A --format="%Y_%m_%d" -- "$dir/SPEC.md" | tail -1)
  if [ -n "$CREATION_DATE" ]; then
    mv "$dir" "{working_directory}/${CREATION_DATE}-${dirname}"
  fi
done
```

### Notes

- Migration is OPTIONAL. Existing directories continue to work.
- New directories created via `_init-common.md` automatically use the date-prefix convention.
- The SPEC.md metadata `doc_dir` field is only present in newly created directories.
```

### 2.2: Add `{doc_dir}` convention explanation to `README.md`

**File**: `README.md`
**Location**: After the "Configuration" section or within the "Appendix" section (around line 167, before "Commands & Core Workflow", or in the Appendix "Document Types" subsection around line 183)

Add a subsection explaining the naming convention. Insert within the "Document Types" subsection in Appendix:

```markdown
#### Directory Naming Convention

Documentation directories use date-prefixed names for chronological sorting:

```
{working_directory}/{yyyy_mm_dd}-{subject}/
```

- `{yyyy_mm_dd}`: Local date when directory is created (e.g., `2026_02_25`)
- `{subject}`: Work keyword (e.g., `auth`, `api-cleanup`)
- Combined as `{doc_dir}` variable (e.g., `2026_02_25-auth`)

This variable is stored in SPEC.md metadata as `doc_dir` and used by downstream commands for path resolution.

**Note**: `{subject}` continues to be used for branch names and commit messages.
```

### 2.3: Update directory structure example in `README.md`

**File**: `README.md`
**Location**: Lines 186-198 (Document Types > Complex Tasks section)

Ensure the complex tasks example already uses `{doc_dir}` (this should be done in Phase 1, item 1.16). If not yet updated, change:
```
{working_directory}/{subject}/
```
To:
```
{working_directory}/{doc_dir}/
```

Also add a comment or note showing a concrete example:
```
# Example: claude_works/2026_02_25-auth/
```

### 2.4: Verify migration guidance references `git log` for creation date detection

**File**: `commands/_init-common.md`

Verify that the migration section added in step 2.1:
1. Uses `git log --diff-filter=A` to detect file creation date
2. Uses `--format="%Y_%m_%d"` for consistent date format
3. Targets `SPEC.md` as the indicator file (first file created in any work directory)
4. Includes a skip pattern for directories that already have the date prefix

## Completion Checklist

- [ ] 2.1: Migration guidance section added to `_init-common.md` with detection method, rename pattern, and bulk migration script
- [ ] 2.2: `{doc_dir}` convention explanation subsection added to `README.md`
- [ ] 2.3: `README.md` directory structure example uses `{doc_dir}` (verify Phase 1 change)
- [ ] 2.4: Migration guidance correctly references `git log --diff-filter=A` for creation date detection

## Notes

- Migration is optional -- existing directories will continue to work. The system falls back to `{subject}` when `doc_dir` is not present in SPEC.md metadata.
- The bulk migration script should be treated as a convenience reference, not an automated tool. Users should review the detected dates before renaming.
- The `git log --diff-filter=A` approach finds the commit that ADDED the file, which gives the best approximation of directory creation date.
- If a SPEC.md was never committed (e.g., abandoned work), the `git log` command will return empty. The migration script handles this by skipping directories with no date found.
