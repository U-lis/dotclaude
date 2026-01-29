# Update Dev Flow - Design Document

**SPEC Reference**: `claude_works/update-dev-flow/SPEC.md`
**Target Version**: 0.3.0
**Source Issue**: https://github.com/U-lis/dotclaude/issues/20
**Complexity**: SIMPLE (2 sequential phases)

---

## Overview

Restructure the development workflow's merge and PR creation steps. Decouple merge/PR behavior from scope selection in `/dotclaude:start-new`. Rename and simplify `/dotclaude:merge-main` to `/dotclaude:merge` (direct merge only, enhanced conflict resolution). Add a post-completion question that asks users how to integrate completed work.

---

## Architecture Decisions

### AD-1: Rename via `git mv` to preserve file history

Rename `commands/merge-main.md` to `commands/merge.md` using `git mv` instead of delete+create. This preserves the file's commit history in git, allowing `git log --follow` to trace changes back to the original file.

### AD-2: Simplify merge command to direct-merge-only

Remove the "PR Option" section from the merge command entirely. The current `/merge-main` asks "How to proceed?" with options for direct merge or PR creation. The new `/merge` command performs direct merge unconditionally. PR creation is handled separately by the future `/dotclaude:pr` command (Issue #9).

### AD-3: Enhanced conflict resolution with analysis, recommendation, and user confirmation

Replace the current passive conflict resolution (list files, user resolves manually) with an active analysis flow:
1. List all conflicted files
2. Analyze conflict content (read conflict markers, identify changes from each branch)
3. Recommend a resolution strategy per file (accept ours, accept theirs, manual merge)
4. Wait for explicit user confirmation before applying resolution
5. Execute confirmed resolution strategy

This gives users informed choices rather than leaving them to figure out conflicts on their own.

### AD-4: Post-completion question replaces scope option 4

Instead of including "Merge" as part of the upfront scope selection (Step 5), ask users how to integrate their work after the selected scope completes. This decouples the integration decision from the planning decision, allowing users to see results before choosing how to integrate.

### AD-5: "Create PR" references future `/pr` command (Issue #9)

The post-completion question includes a "Create PR" option that invokes `/dotclaude:pr`. Since Issue #9 is not yet implemented, the merge command and post-completion flow must include a fallback comment noting that `/dotclaude:pr` is not yet available. This avoids a broken reference while keeping the design forward-compatible.

### AD-6: Read `base_branch` from config chain

The merge command reads the target branch from a three-level config chain:
1. **SPEC.md metadata** (highest priority): `<!-- dotclaude-config ... base_branch: {value} -->`
2. **Config file**: `.claude/dotclaude-config.json` field `base_branch`
3. **Default**: `"main"` (lowest priority)

This is consistent with how `start-new.md` already resolves configuration values.

### AD-7: Update references in `code.md` and `README.md`

All references to the old command name `merge-main` must be updated to `merge` across the codebase. The affected files are:
- `commands/code.md`: "Next Steps" section references `/dotclaude:merge-main`
- `README.md`: Skills table and Manual Execution section reference `merge-main`

### AD-8: Step 12 becomes conditional post-completion flow

Step 12 in `start-new.md` currently performs an unconditional merge to main. It becomes a conditional post-completion question flow:
- Triggered only when scope includes Code or Docs (not design-only)
- Presents AskUserQuestion with "Direct Merge" and "Create PR" options
- Routes to the appropriate command based on user selection

---

## Phase Overview

| Phase | Description | Status | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Rename and rewrite merge command + update references | Pending | None |
| 2 | Update start-new.md scope selection and post-completion flow | Pending | Phase 1 |

---

## Phase 1: Rename and Rewrite Merge Command

### Objective

Rename `/dotclaude:merge-main` to `/dotclaude:merge`, rewrite the command to support direct-merge-only with enhanced conflict resolution and configurable base branch, and update all cross-references in the codebase.

### Scope

FR-1, FR-2, FR-3 (from SPEC.md)

### Files to Modify

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/merge-main.md` | Rename + Rewrite | `git mv` to `commands/merge.md`, full content rewrite |
| `commands/code.md` | Reference update | Change `/dotclaude:merge-main` to `/dotclaude:merge` |
| `README.md` | Reference update | Change all `merge-main` references to `merge` |

### Instructions

#### 1. Rename the file

```bash
git mv commands/merge-main.md commands/merge.md
```

#### 2. Rewrite `commands/merge.md`

Apply the following changes to the renamed file:

**Frontmatter**: Change the description from "Merge feature branch to main with conflict resolution and branch cleanup" to "Merge current branch to base branch with conflict analysis and branch cleanup".

**Title**: Change from `# /dotclaude:merge-main [branch]` to `# /dotclaude:merge [branch]`.

**Add "base_branch Resolution" section** (new section, place after Arguments):

The command must resolve `base_branch` using this priority chain:
1. Read SPEC.md in the current working directory tree. Parse the HTML comment metadata block (`<!-- dotclaude-config ... -->`). Extract `base_branch` value if present.
2. If not found in SPEC.md: read `.claude/dotclaude-config.json`. Extract `base_branch` field if present.
3. If not found in config file: default to `"main"`.

Store the resolved value as `{base_branch}` for use throughout the workflow.

**Workflow section**: Replace all hardcoded references to `main` with `{base_branch}`. The workflow becomes:
1. Save current branch name as `{feature_branch}`
2. `git checkout {base_branch} && git pull origin {base_branch}`
3. `git merge {feature_branch}`
   - If conflict: execute enhanced conflict resolution (see below)
4. Run tests (if configured)
5. `git branch -d {feature_branch}`
6. Report summary

**Remove the "PR Option" section entirely**. Delete the entire section that asks "How to proceed?" with "Direct merge" / "Create PR" options.

**Rewrite "Conflict Resolution" section** with enhanced analysis flow:

If merge conflict occurs:
1. **List conflicted files**: Run `git diff --name-only --diff-filter=U` to enumerate all files with conflicts.
2. **Analyze conflict content**: For each conflicted file, read the file and parse conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`). Identify what each branch changed.
3. **Recommend strategy**: For each file, recommend one of:
   - "Accept current ({base_branch})": Use the base branch version
   - "Accept incoming ({feature_branch})": Use the feature branch version
   - "Manual merge required": Conflicts are too complex for automatic recommendation
4. **Present recommendation to user**: Display the analysis and recommendations. Use AskUserQuestion to confirm the strategy for each file or group of files.
5. **Wait for user confirmation**: Do NOT auto-resolve. Explicitly wait for user to approve the recommended strategy or provide alternative instructions.
6. **Execute resolution**: After confirmation, apply the chosen strategy:
   - For "Accept current": `git checkout --ours {file} && git add {file}`
   - For "Accept incoming": `git checkout --theirs {file} && git add {file}`
   - For "Manual merge": User edits the file, then signals completion
7. After all conflicts resolved: `git commit` (no `--no-edit`, let git use the merge commit message)

**Output section**: Replace hardcoded `main` with `{base_branch}`:
```
- Merged to: {base_branch}
...
Next: git push origin {base_branch}
```

#### 3. Update references in `commands/code.md`

In the "Next Steps" section (line 191) and the `/dotclaude:code all` output section (line 346), change `/dotclaude:merge-main` to `/dotclaude:merge`.

Specifically:
- Line 191: `3. If all phases done: /dotclaude:merge-main` -> `3. If all phases done: /dotclaude:merge`
- Line 346: `3. Run /dotclaude:merge-main` -> `3. Run /dotclaude:merge`

#### 4. Update references in `README.md`

Update all occurrences of `merge-main` to `merge`:

- Skills table (line 122): `| /dotclaude:merge-main` -> `| /dotclaude:merge`
- Skills table description: "Merge feature branch to main" -> "Merge current branch to base branch"
- Structure section (line 30): `merge-main.md` -> `merge.md`
- Structure section comment: `# /dotclaude:merge-main` -> `# /dotclaude:merge`
- Manual Execution section (line 298): `/dotclaude:merge-main` -> `/dotclaude:merge`
- Manual Execution comment: `# Merge to main` -> `# Merge to base branch`

#### 5. Verify no other active source files reference `merge-main`

Search the entire repository for remaining references to `merge-main`. Exclude:
- `.git/` directory
- `node_modules/` or other dependency directories
- The SPEC.md and DESIGN.md files (documentation about the change itself)
- `CHANGELOG.md` (historical entries are expected)

If any active source file still references `merge-main`, update it.

### Completion Checklist

- [ ] `git mv commands/merge-main.md commands/merge.md` executed
- [ ] Frontmatter description updated to reference "base branch" instead of "main"
- [ ] Title changed from `/dotclaude:merge-main [branch]` to `/dotclaude:merge [branch]`
- [ ] "PR Option" section removed entirely
- [ ] "Conflict Resolution" section rewritten with: conflict analysis (list files, analyze content, recommend strategy), explicit user confirmation step, resolution execution after confirmation
- [ ] "base_branch Resolution" section added with config chain: SPEC.md metadata -> `.claude/dotclaude-config.json` -> default "main"
- [ ] Workflow section uses `{base_branch}` instead of hardcoded "main"
- [ ] Output section uses `{base_branch}` instead of hardcoded "main"
- [ ] `commands/code.md` line 191: `/dotclaude:merge-main` changed to `/dotclaude:merge`
- [ ] `commands/code.md` line 346: `/dotclaude:merge-main` changed to `/dotclaude:merge`
- [ ] `README.md`: all `merge-main` references changed to `merge`
- [ ] No other active source files reference `merge-main` (verified by search)

### Notes

- The `git mv` must be the first operation so that git tracks the rename. Modifying the file content after rename is fine; git will still detect it as a rename if similarity is above threshold.
- The "base_branch Resolution" logic is the same pattern already used by `start-new.md` for reading `working_directory` from SPEC.md metadata. Reuse that same parsing approach (HTML comment block at top of SPEC.md).

---

## Phase 2: Update start-new.md Scope Selection and Post-Completion Flow

### Objective

Remove the "Design -> Code -> Docs -> Merge" option from Step 5 scope selection. Replace Step 12 with a conditional post-completion question that asks users how to integrate their work, triggered only when the scope includes Code or Docs phases.

### Scope

FR-4, FR-5 (from SPEC.md)

### Prerequisites

- Phase 1 completed (merge command renamed and rewritten)

### Files to Modify

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/start-new.md` | Modify | Remove 4th scope option, replace Step 12, update routing and output |

### Instructions

#### 1. Remove the 4th scope option from Step 5

In `commands/start-new.md`, locate the Step 5 AskUserQuestion call (approximately lines 151-161). Remove the 4th option:

**Current** (4 options):
```
- { label: "Design", description: "Create design documents only" }
- { label: "Design -> Code", description: "Design + Code implementation" }
- { label: "Design -> Code -> Docs", description: "Design + Code + Documentation update" }
- { label: "Design -> Code -> Docs -> Merge", description: "Execute full workflow" }
```

**Target** (3 options):
```
- { label: "Design", description: "Create design documents only" }
- { label: "Design -> Code", description: "Design + Code implementation" }
- { label: "Design -> Code -> Docs", description: "Design + Code + Documentation update" }
```

#### 2. Update the Routing table

In the Routing section (approximately lines 713-720), remove the "Design -> Code -> Docs -> Merge" row and add a post-completion note.

**Current**:
```
| Design | Steps 6-8 (Designer + TechnicalWriter + commit) -> STOP |
| Design -> Code | Steps 6-10 (Design + Code phases) -> STOP |
| Design -> Code -> Docs | Steps 6-11 (Design + Code + TechnicalWriter DOCS_UPDATE) -> STOP |
| Design -> Code -> Docs -> Merge | Steps 6-12 (Full workflow) -> STOP |
```

**Target**:
```
| Design | Steps 6-8 (Designer + TechnicalWriter + commit) -> STOP |
| Design -> Code | Steps 6-10 (Design + Code phases) -> Step 12 (post-completion) -> STOP |
| Design -> Code -> Docs | Steps 6-11 (Design + Code + TechnicalWriter DOCS_UPDATE) -> Step 12 (post-completion) -> STOP |
```

Note: Step 12 (post-completion question) is triggered only for scopes that include Code or Docs. Design-only scope does not trigger post-completion.

#### 3. Replace Step 12 with post-completion question flow

Replace the current Step 12 content (approximately lines 281-287) which performs an unconditional merge:

**Current Step 12**:
```
**Step 12: Merge to Main**
git checkout main
git pull origin main
git merge {branch} --no-edit
git branch -d {branch}
```

**New Step 12**:

```markdown
**Step 12: Post-Completion Integration (Conditional)**

This step executes ONLY when the selected scope includes Code or Docs (not design-only).

Call AskUserQuestion tool:
- question: "How would you like to integrate this work?"
- header: "Integration Method"
- options:
  - { label: "Direct Merge", description: "Merge current branch to base branch" }
  - { label: "Create PR", description: "Create a GitHub Pull Request (requires /dotclaude:pr)" }
- multiSelect: false

**Routing based on user selection:**

| Selection | Action |
|-----------|--------|
| Direct Merge | Invoke `/dotclaude:merge` command behavior (merge current branch to base_branch, conflict resolution, branch cleanup) |
| Create PR | Invoke `/dotclaude:pr` command behavior. NOTE: `/dotclaude:pr` is planned for Issue #9. If not yet available, inform user: "The /dotclaude:pr command is not yet implemented (see Issue #9: https://github.com/U-lis/dotclaude/issues/9). Please create the PR manually using `gh pr create`." |

**Skip condition**: If scope is "Design" only, skip Step 12 entirely and proceed directly to Step 13 (Return Summary).
```

#### 4. Update Output Contract

In the Output Contract section (approximately lines 846-880), modify the `merge` section to reflect the new conditional integration behavior.

**Current**:
```yaml
merge:
  merged_to: "main"
  branch_deleted: true
```

**Target**:
```yaml
integration:
  method: "merge" | "pr" | "none"
  merged_to: "{base_branch}"       # only when method is "merge"
  branch_deleted: true | false      # only when method is "merge"
  pr_url: "https://..."            # only when method is "pr"
```

Also update `scope_executed` to no longer include "Merge" as a fixed scope element. Change:
```yaml
scope_executed: "Design -> Code -> Docs -> Merge"
```
To reflect that integration is a separate conditional step, not part of the scope chain:
```yaml
scope_executed: "Design -> Code -> Docs"
integration_method: "merge" | "pr" | "none"
```

#### 5. Update Progress Reporting

In the Progress Reporting section (approximately lines 919-945), update the chain progress example.

**Current**:
```
Example for "Design -> Code -> Docs -> Merge":
- [Step 1/4] Design phase - Creating architecture
- [Step 2/4] Code implementation - Executing phases
- [Step 3/4] Documentation update - Updating CHANGELOG
- [Step 4/4] Merge to main - Completing workflow
```

**Target**:
```
Example for "Design -> Code -> Docs":
- [Step 1/3] Design phase - Creating architecture
- [Step 2/3] Code implementation - Executing phases
- [Step 3/3] Documentation update - Updating CHANGELOG
- [Post] Integration - Asking user for merge/PR preference
```

#### 6. Update Final Summary Report

In the Final Summary Report section (approximately lines 886-913), update to reflect the conditional integration step.

**Current**:
```markdown
| 4 | Merge | SUCCESS |
```

**Target**:
```markdown
| 4 | Integration | MERGE / PR / SKIPPED |
```

Also update the "Next Steps" in the summary to be conditional:
- If integration was "merge": show `git push origin {base_branch}` and optional tagging
- If integration was "pr": show PR URL and review instructions
- If integration was "none" (design-only): show manual next steps

### Completion Checklist

- [ ] Step 5: 4th option "Design -> Code -> Docs -> Merge" removed (3 options remain)
- [ ] Routing table: "Design -> Code -> Docs -> Merge" row removed
- [ ] Routing table: "Design -> Code" and "Design -> Code -> Docs" rows updated to include Step 12 (post-completion)
- [ ] Step 12: Replaced with post-completion AskUserQuestion flow
- [ ] Step 12: "Direct Merge" routes to `/dotclaude:merge` behavior
- [ ] Step 12: "Create PR" routes to `/dotclaude:pr` behavior with fallback comment for Issue #9
- [ ] Step 12: Skip condition for design-only scope documented
- [ ] Output Contract: `merge` section replaced with `integration` section using `method: "merge" | "pr" | "none"`
- [ ] Output Contract: `scope_executed` no longer includes "Merge" as fixed element
- [ ] Progress Reporting: Chain progress example updated (no "Merge" step, post-completion shown separately)
- [ ] Final Summary Report: Merge row replaced with conditional Integration row
- [ ] Final Summary Report: Next Steps section is conditional based on integration method

### Notes

- The post-completion question uses AskUserQuestion consistent with NFR-3 and the existing UX pattern in start-new.md.
- The "Create PR" fallback comment is a temporary measure. Once Issue #9 ships `/dotclaude:pr`, the fallback can be removed. However, this design document does NOT include that removal -- it is out of scope.
- Design-only scope (option 1) intentionally skips the integration question because there is no code or docs to integrate. The user can always run `/dotclaude:merge` or `/dotclaude:pr` manually later.
