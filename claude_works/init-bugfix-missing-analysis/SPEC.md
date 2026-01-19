# init-bugfix Missing Analysis Step

## Bug Description

When using `/init-bugfix`, the skill proceeds directly to SPEC.md creation after gathering user questions. The SPEC.md should be the SOT (Source of Truth) containing all relevant information including root cause analysis, affected code locations, and fix strategy. However, the current skill skips codebase analysis entirely.

**Expected Behavior**: After gathering user input, perform codebase analysis to identify:
- Actual root cause in code
- Specific code locations requiring modification
- Concrete fix strategy

**Actual Behavior**: Questions end → SPEC.md written immediately with only user-provided information, lacking AI-driven analysis results.

## Reproduction Steps

1. Run `/init-bugfix`
2. Answer all 6 questions (증상, 재현 조건, 예상 원인, 심각도, 관련 파일, 영향 범위)
3. Observe that SPEC.md is created without any codebase investigation

## Root Cause Analysis

### Primary Cause
The `init-bugfix` SKILL.md (`.claude/skills/init-bugfix/SKILL.md`) lacks a codebase analysis step between question gathering and SPEC.md creation.

**Current workflow in SKILL.md:**
```
Step 1-6: Questions → Branch creation → SPEC.md creation
```

**Missing:**
- No instruction to use Explore agent or Task tool for codebase investigation
- No requirement to analyze related files mentioned by user
- No mandate to identify actual root cause vs user's guess

### Secondary Cause
The Output section defines SPEC.md format that only captures user input, not AI analysis:
```markdown
SPEC.md with bug-specific format:
- Bug Description (from Step 1)
- Reproduction Steps (from Step 2)
- Expected Cause (from Step 3)   ← User's guess only
- Severity (from Step 4)
- Related Files (from Step 5)
- Impact Scope (from Step 6)
```

### Comparison with Expected Pattern
Other SPEC.md files in the codebase (e.g., `mandatory-validation/SPEC.md`) contain:
- Goal / Problem / Target State analysis
- Functional Requirements derived from analysis
- Technical constraints identified through investigation

The `init-bugfix` output lacks equivalent analytical depth.

## Severity

Minor - The skill functions but produces incomplete specifications. Users can work around by manually requesting analysis.

## Affected Code Locations

| File | Section | Issue |
|------|---------|-------|
| `.claude/skills/init-bugfix/SKILL.md` | Line 26-93 | No codebase analysis step after questions |
| `.claude/skills/init-bugfix/SKILL.md` | Line 104-114 | Output format lacks analysis sections |

## Impact Scope

Limited to `/init-bugfix` skill only. Other init skills (init-feature, init-refactor) have their own issues but are out of scope per user request.

## Fix Strategy

### 1. Add Analysis Step (after Step 6, before Branch creation)

Insert new step between question gathering and SPEC creation:

```markdown
## Step 7: Codebase Analysis

After gathering user input, MUST perform investigation:

1. If user specified related files:
   - Read and analyze the specified files
   - Look for code patterns matching described symptoms

2. If user said "모름" (unknown):
   - Use Explore agent to search for relevant code
   - Search patterns: error messages, function names, symptoms

3. Identify and document:
   - Actual root cause code location
   - Why the bug occurs (code-level explanation)
   - Specific changes needed to fix

4. If investigation reveals different cause than user expected:
   - Note the discrepancy
   - Explain the actual cause
```

### 2. Update Output Section

Modify SPEC.md format to include analysis results:

```markdown
## Output

3. `claude_works/{subject}/SPEC.md` with bug-specific format:

### User-Reported Information
- Bug Description (from Step 1)
- Reproduction Steps (from Step 2)
- User's Expected Cause (from Step 3)
- Severity (from Step 4)
- Related Files (from Step 5)
- Impact Scope (from Step 6)

### AI Analysis Results
- Root Cause Analysis (from Step 7 investigation)
- Affected Code Locations (specific file:line references)
- Fix Strategy (concrete modification plan)
```

### 3. Update Workflow Description

Add clarification that SPEC.md creation depends on analysis completion:

```markdown
## Workflow

1. Gather user information (Steps 1-6)
2. Analyze codebase based on gathered information (Step 7)
3. Create branch
4. Create SPEC.md with BOTH user info AND analysis results
5. Commit and present for review
```

## Implementation Notes

- This is a documentation-only change (MD file modification)
- No new agents or tools required - uses existing Explore agent / Read tool
- Follow pattern from init-workflow.md: sequential steps, clear requirements
- Maintain Korean questions for user interaction, English for documentation
