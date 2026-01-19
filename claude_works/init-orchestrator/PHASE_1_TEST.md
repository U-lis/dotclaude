# Phase 1: Test Cases

## Test Coverage Target
≥ 70%

## Validation Tests

### File Existence
- [ ] `.claude/agents/orchestrator.md` exists

### Structure Validation
- [ ] File has "# Orchestrator Agent" header
- [ ] Role section present
- [ ] Capabilities section present
- [ ] 16-step workflow section present
- [ ] Question Sets section present (all 3 types)
- [ ] Subagent Call Patterns section present
- [ ] Parallel Execution section present
- [ ] State Management section present
- [ ] Error Handling section present
- [ ] Output Contract section present

### Content Validation

#### Workflow Steps
- [ ] Step 1: Work type question defined
- [ ] Step 4: Target version selection defined
- [ ] Step 5: TechnicalWriter call for SPEC.md
- [ ] Step 6: SPEC review before commit
- [ ] Step 8: Scope selection defined
- [ ] Step 9: Designer call defined
- [ ] Step 13: Parallel phase handling defined
- [ ] Step 14: Documentation update defined
- [ ] Step 16: Output contract return defined

#### Question Sets
- [ ] Feature questions: 8 items (goal, problem, core_features, etc.)
- [ ] Bugfix questions: 6 items (symptom, reproduction, etc.)
- [ ] Refactor questions: 6 items (target, problems, etc.)

#### Subagent Patterns
- [ ] TechnicalWriter call pattern documented
- [ ] Designer call pattern documented
- [ ] Coder call pattern documented
- [ ] code-validator call pattern documented

#### Parallel Execution
- [ ] Parallel phase detection logic documented
- [ ] Worktree setup instructions present
- [ ] Multiple Task tool call example present
- [ ] Result collection logic documented

### Consistency Check
- [ ] Workflow matches SPEC.md (16 steps)
- [ ] Question sets match SPEC.md
- [ ] Output contract matches SPEC.md

## Manual Verification
- [ ] Read through orchestrator.md for completeness
- [ ] Verify no placeholder text remains
- [ ] Verify token-efficient writing style
