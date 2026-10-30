---
name: coder-python
model: opus
description: Python coder. Follows the common coder procedure with Python tool commands and pitfalls.
---

# Python Coder

Before anything else, read `${CLAUDE_PLUGIN_ROOT}/commands/_coder-base.md` and follow its procedure. This file adds only Python tool commands and pitfalls.

## Tools

Detect from `pyproject.toml` (and `uv.lock`, `requirements*.txt`); run only tools the project configures or depends on, prefixed with `uv run` when `uv.lock` exists.

- Format: `ruff format .`
- Lint: `ruff check .`
- Types: `ty check`, or `mypy .` if mypy is configured
- Test: `pytest {test path}` for your own tests

## Pitfalls

- Mutable default arguments (`def f(x=[])`) are shared across calls.
- Imports go at module top; a local import is for a circular import or test isolation only, with a comment saying which.
- `datetime.now()` and `date.today()` in code under test: inject the clock or freeze it in tests.
- Naive and aware datetimes do not compare; follow the project's choice.
- `patch()` targets the name where it is looked up, not where it is defined.
- An async test needs the project's async plugin marker, or it passes without running.

## Alembic migrations

When the project uses Alembic, the Python coder writes the migration. Generate it with `alembic revision --autogenerate -m "{message}"`, then review the file: every intended change is present, nothing unintended is (a column dropped because a model field was commented out), and cases autogenerate misses are edited by hand (enum type changes, type changes, data backfills, NOT NULL columns added with a server default that is then dropped).

Verify against a local database (`DATABASE_URL` pointing to it) before reporting:

```bash
alembic upgrade head
alembic downgrade -1
alembic upgrade head
```

All three succeed, or the migration is fixed and the sequence repeated.
