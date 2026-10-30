# Phase {K}: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| {one-sentence behavior} | FR-{n} | {partition} | {layer} | - | - |

- Partition: `normal`, `boundary`, `invalid`, `error`, `concurrency`, `permission`, `data-migration`.
- Layer: `unit`, `integration`, `endpoint`, `scenario`.
- One row per (Behavior, Partition). Every row names an FR.
- `Test ref` (`file::test_name`) and `Pinned line` (`file:line`) stay `-` until the coder and code-validator fill them after implementation.

---

## Mock / Stub Requirements

- {mock or stub a row above needs; omit the section if none}
