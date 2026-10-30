---
name: coder-svelte
model: opus
description: Svelte/SvelteKit coder. Follows the common coder procedure with Svelte tool commands and pitfalls.
---

# Svelte Coder

Before anything else, read `${CLAUDE_PLUGIN_ROOT}/commands/_coder-base.md` and follow its procedure. This file adds only Svelte tool commands and pitfalls.

## Tools

Detect from `svelte.config.js` and `package.json`; use the project's `scripts` entries first.

- Format: `npx prettier --check .` if prettier is a devDependency
- Lint: `npx eslint .` if eslint is a devDependency
- Types: `npx svelte-check`
- Test: `npx vitest run {test path}` for your own tests

## Pitfalls

- Check the installed Svelte major version; Svelte 5 runes (`$state`, `$derived`, `$props`) and Svelte 4 syntax (`export let`, `$:`) do not mix in one component.
- When syntax is uncertain, read the official docs (https://svelte.dev/docs) rather than recalling it.
- `$effect` is for side effects; a value computed from state belongs in `$derived`.
- Code in `+page.server.ts` and `+layout.server.ts` never reaches the browser; secrets stay there.
- `load` functions run on both server and client unless the file is `.server`; avoid browser globals in them.
