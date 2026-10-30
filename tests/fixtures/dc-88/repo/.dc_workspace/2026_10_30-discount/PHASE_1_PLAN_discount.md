# Phase 1: clamp percent

## Requirements

- FR-1

## Instructions

- `pricing.py`: clamp `percent` to 0..100 in `apply_discount`.
- `tests/test_pricing.py`: add a boundary test for percent 150.

## Completion Checklist

- [ ] `apply_discount(100.0, 150)` returns 0.0
