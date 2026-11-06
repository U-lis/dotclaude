# Review: reviewer-redesign

## Phase 1

| # | Axis | Result | Location | Severity | Finding | Notes |
|---|------|--------|----------|----------|---------|-------|
| 1 | 1 correctness | issue | `hooks/guard-review.sh:86` | Minor | The tool name is lowercased (`${TOOL,,}`) but the configured `review.intent_tools` globs are not. A user glob such as `*Jira*` silently never matches, so the gate never fires for that config. | Follows GLOBAL AD-1, so the defaults work. Suggested direction: lowercase each glob too, or document "globs must be lowercase" when `configure` gets the key in phase 6. E3 used `mcp__godot__get_godot_version` instead of a Notion tool; recorded in the PLAN Notes; the gate matches by tool name. |
| 2 | 2 scope | checked | — | — | — | Every change traces to PLAN Steps 1-5 and FR-4 / NFR-1. `agents/reviewer.md` and `hooks/workspace-archive.sh` unchanged, as the PLAN requires. |
| 3 | 3 safety | issue | `hooks/guard-review.sh:64` | Minor | The binding store is accepted if any directory already exists at `${TMPDIR:-/tmp}/dotclaude-review-$(id -u)`; owner and symlink are not checked. On a shared host another user could create it first and read or replace binding files. | Low risk: needs another user on the same host, and the gate is a workflow guard, not a security boundary. Suggested direction: use the store only if owned by the current user, not a symlink, mode 700; otherwise fail open. Binding files are never cleaned up (small, under /tmp). |
| 4 | 4 maintainability | issue | `hooks/guard-review.sh:2-7` | Minor | The header comment is 6 lines and mostly says what the hook does; RULES.md asks for 1-5 lines of "why". | Keep the two known limitations the PLAN requires; trim the description. Side note: the closing sentence of SPEC FR-4 still says the plugin-path hook and MCP deny are "not yet confirmed"; E2 and E3 now confirm them. |
| 5 | 5 tests | checked | — | — | — | Each assertion maps to a PHASE_1_TEST row with pinned hook lines. `:98` overlaps `:104` but SPEC NFR-1 lists the case. The archive case pins a combination of behaviors, explained in the Notes. |

BLOCKERS: 0
