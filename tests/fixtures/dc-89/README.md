# dc-89 manual check: coder procedure and report

Checks that a coder follows the convention-loading, search, and self-review procedure. Run in a throwaway project with a dotclaude SPEC and design documents for one small phase (a function with a date-dependent branch works well).

1. Setup: create `{working_directory}/RULES.md` from `templates/RULES.md` and add one project term (for example the "admin" line filled in). Add a `CLAUDE.md` at the repository root; leave `CONVENTIONS.md` absent. Put a helper in the codebase that does something close to what the phase needs.
2. Run `/dotclaude:code 1`. In the coder's completion report, confirm:
   - "Conventions read" lists `CLAUDE.md: read`, `CONVENTIONS.md: absent`, `RULES.md: read`.
   - "Existing implementations" names the helper's `file:line` as reused or not reused with a reason.
   - Every entry under "Tests Added" has a `pins {file:line}`, and the date-dependent test uses a fixed date.
3. Open `PHASE_1_TEST.md`: the `Test ref` and `Pinned line` columns are filled for each row the coder implemented, other columns are unchanged, and deleting one pinned production line makes its test fail. Repeat step 2 with the PLAN naming a language without a dedicated coder (for example Go) and confirm `coder-generic` is selected and its report lists the discovered tool commands and their sources.
