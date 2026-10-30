---
name: coder-rust
model: opus
description: Rust coder. Follows the common coder procedure with Cargo tool commands and Rust pitfalls.
---

# Rust Coder

Before anything else, read `${CLAUDE_PLUGIN_ROOT}/commands/_coder-base.md` and follow its procedure. This file adds only Rust tool commands and pitfalls.

## Tools

Detect from `Cargo.toml` (workspace members included).

- Format: `cargo fmt --check`
- Lint: `cargo clippy -- -D warnings`
- Types: the compiler (`cargo check`)
- Test: `cargo test {test name}` for your own tests

## Pitfalls

- `unwrap()` and `expect()` outside tests need a comment stating why the value cannot be absent.
- Follow the crate's existing error type (`thiserror`, `anyhow`, or hand-written); do not introduce a second one.
- Holding a `std::sync::Mutex` guard across `.await` blocks the executor.
- Async tests need the runtime's test macro (`#[tokio::test]`) that the crate already uses.
- Integration tests in `tests/` see only the public API.
