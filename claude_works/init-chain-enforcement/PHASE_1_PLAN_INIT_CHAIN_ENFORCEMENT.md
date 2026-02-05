# Phase 1: Init Chain Enforcement

## Objective

Harden the init delegation chain so that the orchestrator cannot bypass `git worktree add` during init, cannot skip post-init verification, and cannot override Step 6 Checkpoint HALT conditions. This phase addresses all 3 fixes (Change 1, Change 2, Change 3) in a single commit across 2 files.

## Prerequisites

- SPEC.md reviewed and approved
- Working branch `bugfix/init-chain-enforcement` exists in worktree `../dotclaude-bugfix-init-chain-enforcement`

## Files to Modify

| # | File | Type |
|---|------|------|
| 1 | `commands/_init-common.md` | Existing - modify Branch Creation section |
| 2 | `commands/start-new.md` | Existing - insert new section + modify existing section |

**Do NOT modify**: `commands/init-github-issue.md`, `commands/init-feature.md`, `commands/init-bugfix.md`, `commands/init-refactor.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`

## Instructions

### Change 1: `commands/_init-common.md` -- Strengthen Branch Creation

Target: Lines 11-23 (Branch Creation section and its Steps sub-section)

#### 1A. Replace section header

On line 11, replace:

```
## Branch Creation
```

with:

```
## Branch Creation -- MANDATORY
```

#### 1B. Replace intro sentence and add enforcement paragraph

On line 13, replace the single intro sentence:

```
After gathering requirements (or using pre-filled values from GitHub issue), create the work branch.
```

with two paragraphs:

```
After gathering requirements (or using pre-filled values from GitHub issue), create the work branch using `git worktree add`. This step is MANDATORY.

**MUST**: Use `git worktree add` as shown below. **NEVER** use `git checkout -b`, `git switch -c`, or any other branch creation method as a substitute.
```

#### 1C. Add verification sub-step

After the existing step 4 (line 23: `4. Create project directory: ...`), insert a new step 5:

```
5. **Verify worktree creation**: Run `ls ../{project_name}-{type}-{keyword}` and confirm the directory exists. If the directory does not exist, the worktree creation failed -- report the error immediately. Do NOT silently fall back to `git checkout -b`.
```

This becomes step 5 in the existing numbered list (steps 1-4 remain unchanged).

---

### Change 2: `commands/start-new.md` -- Add Post-Init Verification (Step 2.8)

Target: Insert a new section after the Step 2.6 block (after line 137, before the **Step 3: SPEC Review** heading on line 138).

#### 2A. Insert the following section

Insert this entire block between Step 2.6 content and Step 3:

```markdown
**Step 2.8: Post-Init Verification**

**MANDATORY**: After Step 2 (init-xxx) completes, verify that the init delegation chain executed correctly BEFORE proceeding to Step 3.

Verification checks:
1. Run `git worktree list` and confirm `../{project_name}-{type}-{keyword}` appears in the output
2. Run `git branch --show-current` and confirm the current branch is `{type}/{keyword}` (NOT main, NOT master)
3. Confirm the working directory `../{project_name}-{type}-{keyword}/{working_directory}/{subject}` exists

If ANY check fails:
```
retry_count = 0
while retry_count < 3:
    Re-execute Step 2 (init-xxx delegation) from the beginning
    Run verification checks again
    if all checks pass:
        break
    retry_count += 1

if retry_count == 3 and checks still fail:
    HALT workflow immediately
    Report to user: "Init delegation chain failed after 3 attempts.
    Worktree or branch was not created correctly.
    Manual intervention required."
```

This step ensures the orchestrator catches any case where the init chain was bypassed or partially executed.
```

The insertion point is between the line `Store the target_version for:` / `- Pass to TechnicalWriter for CHANGELOG updates (Step 11)` block and the `**Step 3: SPEC Review**` heading.

---

### Change 3: `commands/start-new.md` -- Make Step 6 Checkpoint UNCONDITIONAL

Target: Lines 169-192 (Step 6 Checkpoint section)

#### 3A. Replace section header

On line 169, replace:

```
### Step 6 Checkpoint (Before Design)
```

with:

```
### Step 6 Checkpoint (Before Design) -- UNCONDITIONAL
```

#### 3B. Replace intro text

On line 171, replace:

```
**MANDATORY**: Before calling Designer agent, validate:
```

with:

```
**MANDATORY -- UNCONDITIONAL CHECK -- NO EXCEPTIONS, NO OVERRIDES**: Before calling Designer agent, validate ALL of the following. Every check MUST pass. No agent may bypass, skip, or override any HALT condition below, regardless of project size, complexity, or any other justification.
```

#### 3C. Add [UNCONDITIONAL] prefix to all 4 checks

Replace each check's label as follows:

- Line 173: `1. **Branch Check**:` becomes `1. **[UNCONDITIONAL] Branch Check**:`
- Line 178: `2. **SPEC.md Check**:` becomes `2. **[UNCONDITIONAL] SPEC.md Check**:`
- Line 182: `3. **SPEC.md Committed Check**:` becomes `3. **[UNCONDITIONAL] SPEC.md Committed Check**:`
- Line 187: `4. **Worktree Check**:` becomes `4. **[UNCONDITIONAL] Worktree Check**:`

The body text of each check (indented lines after the label) remains unchanged.

#### 3D. Replace closing line

On line 192, replace:

```
If any check fails: halt workflow and report error to user.
```

with:

```
If ANY check fails: HALT workflow immediately and report error to user. There are NO exceptions to this rule. Do NOT proceed with a justification for why the check can be skipped.
```

---

## Completion Checklist

- [x] C-1: `_init-common.md` section header changed to `## Branch Creation -- MANDATORY` -- Verified in `commands/_init-common.md`:11
- [x] C-2: `_init-common.md` has MUST/NEVER enforcement paragraph after intro sentence -- Verified in `commands/_init-common.md`:15
- [x] C-3: `_init-common.md` has verification sub-step (step 5) checking directory existence -- Verified in `commands/_init-common.md`:26
- [x] C-4: `start-new.md` has Step 2.8 Post-Init Verification section inserted between Step 2.6 and Step 3 -- Verified in `commands/start-new.md`:138
- [x] C-5: Step 2.8 contains `git worktree list` check, `git branch --show-current` check, and working directory existence check -- Verified in `commands/start-new.md`:143-145
- [x] C-6: Step 2.8 contains retry loop (max 3 attempts) with HALT on exhaustion -- Verified in `commands/start-new.md`:148-162
- [x] C-7: `start-new.md` Step 6 Checkpoint header includes `-- UNCONDITIONAL` -- Verified in `commands/start-new.md`:197
- [x] C-8: Step 6 Checkpoint intro text includes "NO EXCEPTIONS, NO OVERRIDES" -- Verified in `commands/start-new.md`:199
- [x] C-9: All 4 checks in Step 6 Checkpoint have `[UNCONDITIONAL]` prefix -- Verified in `commands/start-new.md`:201,206,210,215
- [x] C-10: Step 6 Checkpoint closing line explicitly prohibits justification-based overrides -- Verified in `commands/start-new.md`:220
- [x] C-11: No changes made to `init-github-issue.md`, `init-feature.md`, `init-bugfix.md`, `init-refactor.md` -- Verified via `git diff main` (empty diff)
- [x] C-12: No version numbers modified in `plugin.json` or `marketplace.json` -- Verified via `git diff main` (empty diff)
- [x] C-13: Existing init flows (direct calls to init-feature/bugfix/refactor) are not broken by the changes -- Verified: init files unchanged, _init-common changes are additive only

## FR Traceability

| FR | Addressed By | Checklist Items |
|----|-------------|-----------------|
| FR-1: MANDATORY enforcement in _init-common.md | Change 1 | C-1, C-2, C-3 |
| FR-2: Post-init verification in start-new.md | Change 2 | C-4, C-5 |
| FR-3: Retry loop (max 3) with HALT | Change 2 | C-6 |
| FR-4: UNCONDITIONAL Step 6 Checkpoint | Change 3 | C-7, C-8, C-9, C-10 |
| FR-5: No breakage to existing init flows | All changes | C-11, C-12, C-13 |

## Notes

- All changes are documentation/instruction modifications only. No runtime code is affected.
- The `--` separator (double hyphen) is used in headers instead of an em dash to maintain consistent Markdown rendering across tools.
- Line numbers referenced are from the current source files as of commit `f248a2b`. If the files have been modified since, the implementer should locate sections by heading text rather than line numbers.
- The retry pseudocode in Change 2 uses fenced code blocks with no language specifier, matching the existing style in `start-new.md` (e.g., the retry loop in the Error Handling section).
