# Fixture dc-86: spec-validator test matrix check

Input for a manual spec-validator run (no automation). Run it on this directory as the work document directory.

The SPEC lists 6 (FR, Partition) pairs in its Edge Cases table. The TEST matrix has a row for 5 of them and one extra row with no FR.

Expected report, `Status: FAILED`, with exactly these two Critical issues:

1. Missing cell `(FR-3, concurrency)` in `PHASE_1_TEST.md` (SPEC Edge Cases #6 has no TEST row).
2. TEST row without FR: "Response carries a request id header" in `PHASE_1_TEST.md`.

Not expected: any other Critical or Warning about requirements coverage, the PLAN checklist, or the matrix format. The paths in the PLAN (`app/users/...`, `migrations/...`) do not exist in this repository; a path-existence finding about them is fixture noise, not a defect of the check.
