# Phase 2: Test Cases

## Test Coverage Target

≥ 70%

## Manual Verification Tests

### Issue Input (Step 1)

- [ ] Test 1: Full URL input `https://github.com/owner/repo/issues/123` parses correctly
- [ ] Test 2: Short form `#123` uses current repo context
- [ ] Test 3: Number only `123` uses current repo context
- [ ] Test 4: Invalid URL format shows error message

### Issue Parsing (Step 2)

- [ ] Test 5: Valid issue returns title, body, labels, milestone
- [ ] Test 6: Issue without milestone returns null for milestone
- [ ] Test 7: gh CLI not installed shows install instructions
- [ ] Test 8: gh CLI not authenticated shows auth instructions
- [ ] Test 9: Issue not found (404) shows appropriate error
- [ ] Test 10: Private repo no access (403) shows appropriate error

### Work Type Detection (Step 3)

- [ ] Test 11: Issue with `bug` label → routes to init-bugfix
- [ ] Test 12: Issue with `enhancement` label → routes to init-feature
- [ ] Test 13: Issue with `refactor` label → routes to init-refactor
- [ ] Test 14: Issue with no labels → body analysis triggered
- [ ] Test 15: Issue with conflicting labels → user confirmation requested
- [ ] Test 16: Body contains "fix bug" → detected as bugfix
- [ ] Test 17: Body contains "add new feature" → detected as feature
- [ ] Test 18: Body contains "refactor code" → detected as refactor

### Context Pre-population (Step 4)

- [ ] Test 19: Issue title becomes branch keyword
- [ ] Test 20: Milestone title becomes target_version
- [ ] Test 21: Issue body pre-fills problem/goal questions

### Routing (Step 5)

- [ ] Test 22: Routes to correct init file based on work_type
- [ ] Test 23: Pre-populated context passed to init file
- [ ] Test 24: User can override pre-filled values

## Edge Cases

- [ ] Cross-repo issue URL (different owner/repo than current)
- [ ] Issue title with special characters (slashes, spaces)
- [ ] Very long issue body (>1000 chars)
- [ ] Issue with many labels including unknown ones
- [ ] Milestone title in format "v0.0.12" vs "0.0.12"
