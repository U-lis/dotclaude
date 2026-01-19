# Phase 2: Test Cases

## Test Coverage Target
≥ 70%

## Validation Tests

### File Modification
- [ ] `.claude/skills/start-new/SKILL.md` updated

### YAML Frontmatter
- [ ] name: "start-new" preserved
- [ ] user-invocable: true preserved
- [ ] description updated to mention orchestrator

### Structure Validation
- [ ] Workflow section simplified
- [ ] Orchestrator Call section present
- [ ] Manual Mode section present
- [ ] Old routing logic removed
- [ ] Old question section removed

### Content Validation

#### Workflow
- [ ] Shows Task tool → Orchestrator pattern
- [ ] No direct init-xxx routing
- [ ] No direct question asking

#### Orchestrator Call
- [ ] Explains how to call orchestrator
- [ ] Lists what orchestrator handles

#### Manual Mode
- [ ] Lists available manual skills
- [ ] Explains bypass scenario

### Consistency Check
- [ ] References orchestrator.md correctly
- [ ] No broken references to removed sections
- [ ] No outdated workflow diagrams

### Negative Tests
- [ ] No "Question:" block for work type
- [ ] No "Routing" table
- [ ] No init-xxx routing logic

## Manual Verification
- [ ] Read through updated SKILL.md for clarity
- [ ] Verify skill can still be invoked
- [ ] Verify no leftover old content
