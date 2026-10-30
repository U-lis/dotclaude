# dc-90 manual checks

These fixtures exercise the designer and technical-writer rules from issue #90. They are run by hand because the checks need an agent call; nothing in `tests/hooks/run_all.sh` uses them.

Both SPECs describe work on this repository, so run the checks from a scratch worktree of it. For each fixture, copy it into the document directory its metadata names and approve it, because the design guard denies the designer call for an unapproved SPEC:

```bash
d=.dc_workspace/fixture-missing-symbol   # or fixture-two-fr
mkdir -p "$d" && cp tests/fixtures/dc-90/SPEC_missing_symbol.md "$d/SPEC.md"
bash hooks/spec-meta.sh approve "$d/SPEC.md"
```

Then call the agents with the prompts in `commands/_agent-prompts.md` (designer, then technical-writer: design documents), with `parallel_phases: false`.

## 1. Missing symbol → OPEN

Fixture: `SPEC_missing_symbol.md`. It assumes a `spec-meta.sh diff-approved` subcommand and a `spec_review.max_age_days` config key; neither exists (`grep -rn 'diff-approved\|max_age' hooks commands agents` prints nothing).

Pass when:
- the designer output's `OPEN` list has an item for each of `diff-approved` and `spec_review.max_age_days`, saying what was searched;
- neither name appears in the design as an existing symbol (it may appear only marked `(new)` after the user's answer, or inside `OPEN`);
- every other existing path or symbol in the output is cited `file:line`.

After answering the `OPEN` items, the PLAN files technical-writer writes contain no invented symbol: `grep -n 'diff-approved\|max_age_days' .dc_workspace/fixture-missing-symbol/PHASE_*` matches only where the PLAN says the name is created.

## 2. Two FRs → PLAN + TEST only

Fixture: `SPEC_two_fr.md`. Two FRs; the change touches `hooks/spec-meta.sh` and `tests/hooks/test_spec_meta.sh`.

Pass when:
- the designer output says `proportional: true` with exactly one phase naming FR-1 and FR-2, and `OPEN: none`;
- technical-writer writes exactly `PHASE_1_PLAN_{keyword}.md` and `PHASE_1_TEST.md` and no `GLOBAL.md`: `ls .dc_workspace/fixture-two-fr/` shows `SPEC.md` and those two files.

## 3. Shrinking update → stop

Use the PLAN from check 1 (or any PLAN over 3 KB). Copy it aside and record `wc -c`, then call technical-writer with: "Update {path}: make it concise, keep only the Requirements and Completion Checklist."

Pass when technical-writer's report says it stopped, with the document, both byte sizes, and the sections that shrank, and it touched no other document. It edits with the Edit tool rather than writing the file anew. Restore the PLAN from the copy afterwards.
