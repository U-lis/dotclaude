---
name: coder-sql
model: opus
description: SQL and database coder. Follows the common coder procedure with migration tool commands and SQL pitfalls.
---

# SQL/Database Coder

Before anything else, read `${CLAUDE_PLUGIN_ROOT}/commands/_coder-base.md` and follow its procedure. This file adds only database tool commands and pitfalls.

## Tools

Detect the migration tool from the project (`alembic.ini`, `prisma/schema.prisma`, `migrations/` with a tool-specific layout); naming follows the existing schema.

- Alembic: `alembic upgrade head`, `alembic downgrade -1`, `alembic upgrade head`
- Prisma: `npx prisma migrate dev`, `npx prisma validate`
- Plain SQL: the project's runner, applied to a local database
- Query plans: `EXPLAIN ANALYZE` on the database the project targets

## Pitfalls

- Every migration has a working down step, verified by applying up, down, and up again.
- Adding a NOT NULL column to a table with rows needs a default or a backfill first.
- Renaming a column in one step breaks code still running against the old name.
- An index on a large table locks writes unless built concurrently where the database supports it.
- `NULL` comparisons need `IS NULL`; `= NULL` is never true.
- Timestamp columns follow the existing time-zone choice.
