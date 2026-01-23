# Phase 1: Test Cases

## Test Coverage Target

≥ 70%

## Manual Verification Tests

### SKILL.md Modification

- [ ] Test 1: Verify 4th option "GitHub Issue" appears in Step 1 question
- [ ] Test 2: Verify existing 3 options unchanged (기능 추가/수정, 버그 수정, 리팩토링)
- [ ] Test 3: Verify Step 2 routing table has entry for "GitHub Issue"
- [ ] Test 4: Verify routing points to `init-github-issue.md`

## Edge Cases

- [ ] Option label must be exact match "GitHub Issue" (not "Github Issue" or "github issue")
- [ ] Table formatting preserved (markdown pipe syntax)
