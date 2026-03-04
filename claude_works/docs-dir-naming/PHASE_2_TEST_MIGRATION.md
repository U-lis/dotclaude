# Phase 2: Test Cases - Migration Support and Documentation

## Test Coverage Target

>= 70%

This phase adds documentation content (migration guidance and convention explanation). Verification is manual.

---

## Unit Tests

### Migration Guidance (`_init-common.md`)

- [ ] TC-1.1: `_init-common.md` contains a "Migration" section
  - Verify: `grep -n 'Migration' commands/_init-common.md` returns at least 1 match for a section header
- [ ] TC-1.2: Migration section references `git log --diff-filter=A` for date detection
  - Verify: `grep -n 'diff-filter=A' commands/_init-common.md` returns at least 1 match
- [ ] TC-1.3: Migration section includes `--format="%Y_%m_%d"` for date format
  - Verify: `grep -n '%Y_%m_%d' commands/_init-common.md` returns at least 1 match in the migration section
- [ ] TC-1.4: Migration section includes a skip pattern for already-prefixed directories
  - Verify: `grep -n 'YYYY_MM_DD\|[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}' commands/_init-common.md` returns at least 1 match showing the regex pattern for skipping
- [ ] TC-1.5: Migration section explicitly states migration is OPTIONAL
  - Verify: `grep -in 'optional' commands/_init-common.md` returns at least 1 match in migration context
- [ ] TC-1.6: Migration section targets `SPEC.md` as the indicator file
  - Verify: `grep -n 'SPEC.md' commands/_init-common.md` in migration section references SPEC.md as the file to check for creation date

### README Convention Documentation

- [ ] TC-2.1: `README.md` contains `{doc_dir}` explanation text
  - Verify: `grep -n 'doc_dir' README.md` returns at least 2 matches (variable reference and explanation)
- [ ] TC-2.2: `README.md` explains the `{yyyy_mm_dd}-{subject}` format
  - Verify: `grep -n 'yyyy_mm_dd' README.md` returns at least 1 match
- [ ] TC-2.3: `README.md` states that `{subject}` is still used for branch names and commit messages
  - Verify: README contains text explaining that `{subject}` continues to be used for branch names
- [ ] TC-2.4: `README.md` directory structure example uses `{doc_dir}`
  - Verify: In the "Complex Tasks" code block, the path uses `{doc_dir}` not `{subject}`

---

## Integration Tests

### Content Consistency

- [ ] IT-1: Migration guidance in `_init-common.md` is consistent with `{doc_dir}` generation logic in Phase 1
  - Verify: The date format in migration (`%Y_%m_%d`) matches the format used in `{doc_dir}` generation (`%Y_%m_%d`)
- [ ] IT-2: `README.md` convention documentation is consistent with SPEC.md metadata format
  - Verify: README mentions `doc_dir` in SPEC.md metadata, matching the template in `start-new.md`
- [ ] IT-3: Migration bulk script correctly handles the directory naming pattern
  - Verify: The regex `^[0-9]{4}_[0-9]{2}_[0-9]{2}-` in the bulk migration script matches the `{doc_dir}` format

---

## Edge Cases

- [ ] EC-1: Migration script handles directories without SPEC.md (abandoned work)
  - Verify: The bulk migration script checks for empty `CREATION_DATE` before renaming (`if [ -n "$CREATION_DATE" ]`)
- [ ] EC-2: Migration script skips directories that already have date prefix
  - Verify: The skip pattern (`[0-9]{4}_[0-9]{2}_[0-9]{2}-`) is checked before processing each directory
- [ ] EC-3: Existing Phase 1 changes in `README.md` are not overwritten by Phase 2
  - Verify: Phase 2 README changes are ADDITIVE (new subsection), not replacing Phase 1 changes
- [ ] EC-4: Migration section does not introduce any new variable dependencies
  - Verify: Migration commands only use standard shell commands (`git log`, `mv`, `basename`) with no custom variables beyond what is defined in the migration script itself
