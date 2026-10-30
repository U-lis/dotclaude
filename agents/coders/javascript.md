---
name: coder-javascript
model: opus
description: JavaScript/TypeScript coder. Follows the common coder procedure with JS/TS tool commands and pitfalls.
---

# JavaScript/TypeScript Coder

Before anything else, read `${CLAUDE_PLUGIN_ROOT}/commands/_coder-base.md` and follow its procedure. This file adds only JS/TS tool commands and pitfalls.

## Tools

Detect from `package.json` and the lockfile (npm, pnpm, yarn, bun); use the project's runner and its `scripts` entries first.

- Format: `npx prettier --check .` if prettier is a devDependency
- Lint: `npx eslint .` if eslint is a devDependency
- Types: `npx tsc --noEmit` if `tsconfig.json` exists
- Test: `npm test -- {test path}` (or the project's runner) for your own tests

## Pitfalls

- A promise that is not awaited or returned lets the test finish before the assertion runs.
- `==` coerces; use `===` unless the conventions say otherwise.
- ES modules and CommonJS do not mix freely; follow `"type"` in `package.json`.
- `new Date()` and `Date.now()` in code under test: inject the clock or use fake timers with a fixed date.
- `Date` months are zero-based and parsing a date-only string yields UTC.
- Module mocks are hoisted; a mock declared inside a test does not apply to imports already made.
