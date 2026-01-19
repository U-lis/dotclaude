# Phase 2: Validation - init-workflow.md Reduction

## Validation Checklist

### 1. Deleted Sections Verification

```bash
# These should return NO results
grep -n "어디까지 진행할까요" .claude/skills/_shared/init-workflow.md
grep -n "## Next Step Selection" .claude/skills/_shared/init-workflow.md
grep -n "## Routing" .claude/skills/_shared/init-workflow.md
grep -n "## Non-Stop Execution" .claude/skills/_shared/init-workflow.md
grep -n "Scope-to-Skill Chain" .claude/skills/_shared/init-workflow.md
grep -n "CLAUDE.md Rule Overrides" .claude/skills/_shared/init-workflow.md
grep -n "Final Summary Report" .claude/skills/_shared/init-workflow.md
grep -n "Progress Indicator" .claude/skills/_shared/init-workflow.md
```

- [ ] All grep commands return empty (no matches)

### 2. New Section Verification

```bash
# This should return a match
grep -n "## Init Phase Attitude" .claude/skills/_shared/init-workflow.md
grep -n "Not In Scope" .claude/skills/_shared/init-workflow.md
grep -n "Invocation Behavior" .claude/skills/_shared/init-workflow.md
```

- [ ] Init Phase Attitude section exists
- [ ] Not In Scope subsection exists
- [ ] Invocation Behavior table exists

### 3. Modified Sections Verification

#### Mandatory Workflow Rules
```bash
grep -n "Steps 5-8 are MANDATORY" .claude/skills/_shared/init-workflow.md
```

- [ ] References Steps 5-8 (not Steps 5-9)

#### Prohibited Actions
```bash
grep "Skip the Next Step Selection" .claude/skills/_shared/init-workflow.md
```

- [ ] Returns empty (line was removed)

#### Correct Execution Order
```bash
grep -n "Ask Next Step Selection" .claude/skills/_shared/init-workflow.md
grep -n "Route based on user" .claude/skills/_shared/init-workflow.md
```

- [ ] Both return empty (steps 9-10 removed)

### 4. Diagram Verification

```bash
# Should NOT find Step 9 in diagram
grep -A2 "9\. Next Step Selection" .claude/skills/_shared/init-workflow.md
```

- [ ] Returns empty (Step 9 removed from diagram)

```bash
# Should find Step 8 as the last step in diagram
grep "8\. Review with User" .claude/skills/_shared/init-workflow.md
```

- [ ] Step 8 exists and is the last numbered step

### 5. Preserved Sections Verification

```bash
grep -n "## Plan Mode Policy" .claude/skills/_shared/init-workflow.md
grep -n "## Analysis Phase Workflow" .claude/skills/_shared/init-workflow.md
grep -n "analysis-phases.md" .claude/skills/_shared/init-workflow.md
```

- [ ] Plan Mode Policy exists
- [ ] Analysis Phase Workflow exists
- [ ] Reference to analysis-phases.md preserved

### 6. File Size Verification

```bash
wc -l .claude/skills/_shared/init-workflow.md
```

- [ ] Line count reduced (target: ~120-130 lines, original: ~235 lines)

### 7. Section Order Verification

Expected order:
1. Plan Mode Policy
2. Init Phase Attitude (NEW)
3. Generic Workflow Diagram
4. Analysis Phase Workflow
5. Mandatory Workflow Rules

```bash
grep -n "^## " .claude/skills/_shared/init-workflow.md
```

- [ ] Sections appear in expected order
- [ ] No sections after Mandatory Workflow Rules

### 8. DRY Compliance (Cross-file)

```bash
# "어디까지 진행할까요" should appear ONLY in orchestrator.md
grep -r "어디까지 진행할까요" .claude/
```

- [ ] Only one match in orchestrator.md
- [ ] No match in init-workflow.md
- [ ] No match in init-xxx SKILL.md files

## Expected Final Structure

```
# Common Init Workflow

## Plan Mode Policy
[content preserved]

## Init Phase Attitude
[new content]

## Generic Workflow Diagram
[Steps 1-8 only]

## Analysis Phase Workflow
[content preserved]

## Mandatory Workflow Rules
[updated to Steps 5-8]
```
