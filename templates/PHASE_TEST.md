# Phase {K}: Test Cases

## Test Coverage Target

Coverage 70% is a REFERENCE figure, not a pass/fail gate.

---

## Behaviors to Verify

List each behavior that this phase introduces or modifies. For each:
- **Behavior**: one-sentence description
- **Verification layer**: unit | integration | endpoint | scenario
- **Notes** (optional): any constraint on HOW to verify

Layer choice rule (criterion 1 in `agents/pruner.md`): branch combinations (each rejection / exception / boundary branch) are verified at exactly ONE layer (typically unit). Higher-layer tests are limited to: wiring, response contract (status code / schema), query count, representative flows (1 happy path + 1 representative failure per distinct response contract). Verifying the same feature at multiple layers is allowed; repeating lower-layer branch combinations at a higher layer is not.

- [ ] **Behavior**: {description}
  - **Verification layer**: {unit | integration | endpoint | scenario}
  - **Notes**: {optional}

---

## Edge Cases Actually Applicable to This Phase

List only edge cases that are real possibilities given this phase's code. Leave blank or omit if none apply.

---

## Mock / Stub Requirements

List only mocks that are actually needed for the behaviors above. Omit if not applicable.
