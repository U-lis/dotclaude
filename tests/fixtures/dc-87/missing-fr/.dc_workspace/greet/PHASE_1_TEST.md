# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| greet returns the greeting | FR-1 | normal | unit | tests/test_greet.py::test_greet_returns_greeting | src/greet/core.py:4 |
| greet rejects an empty name | FR-1 | invalid | unit | tests/test_greet.py::test_greet_rejects_empty_name | src/greet/core.py:40 |
