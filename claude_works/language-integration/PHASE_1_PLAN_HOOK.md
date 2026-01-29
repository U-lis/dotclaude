# Phase 1: Hook Language Output

## Objective

Modify `hooks/init-config.sh` to resolve the configured language value from config files and output it to stdout so Claude receives it as session context at startup.

## Prerequisites

- None (this is the first phase)

## Instructions

### Step 1: Understand Current Hook

The current `hooks/init-config.sh` does the following:
1. Sets `GLOBAL_CONFIG="$HOME/.claude/dotclaude-config.json"`
2. If the global config file does not exist, creates it with default JSON including `"language": "en_US"`
3. Exits with code 0

The hook is idempotent: it only creates the config if missing, then exits.

### Step 2: Add Language Resolution Logic

After the existing config-creation block (after the `fi` on line 21), add language resolution logic.

The resolution order is: Default (`en_US`) < Global config < Local config.

**Implementation instructions for `hooks/init-config.sh`:**

1. After the existing `fi` block (line 21), add a blank line and then the language resolution block.

2. The language resolution block must:

   a. Set default language:
      ```
      LANGUAGE="en_US"
      ```

   b. Define local config path:
      ```
      GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
      LOCAL_CONFIG=""
      if [ -n "$GIT_ROOT" ]; then
        LOCAL_CONFIG="$GIT_ROOT/.claude/dotclaude-config.json"
      fi
      ```

   c. Read language from global config (if file exists and is valid JSON):
      - Check if `jq` is available: `command -v jq >/dev/null 2>&1`
      - If jq is available AND global config exists AND global config is valid JSON (`jq empty "$GLOBAL_CONFIG" 2>/dev/null`):
        - Extract language: `jq -r '.language // "en_US"' "$GLOBAL_CONFIG"`
        - Assign to LANGUAGE variable
      - If jq is NOT available:
        - Use grep/sed fallback to extract the language value from JSON
        - Pattern: `grep -o '"language"[[:space:]]*:[[:space:]]*"[^"]*"' "$GLOBAL_CONFIG" | sed 's/.*"language"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'`
        - If extraction yields empty string, keep default

   d. Read language from local config (if file exists and is valid JSON):
      - Same logic as global config but using `LOCAL_CONFIG` path
      - Only attempt if `LOCAL_CONFIG` is non-empty AND the file exists
      - Local value overrides global value

   e. Output the resolved language:
      ```
      echo "[dotclaude] language: $LANGUAGE"
      ```

3. The existing `exit 0` at the end of the file remains unchanged.

### Step 3: Handle Edge Cases

The implementation MUST handle these cases gracefully without errors or non-zero exit:

| Case | Handling |
|------|----------|
| `jq` not installed | Use grep/sed fallback to extract language from JSON |
| Global config has no `language` field | Default `en_US` is used (jq `// "en_US"` handles this; grep returns empty, default kept) |
| Local config file does not exist | Skip local config reading, use global/default value |
| Not in a git repository | `GIT_ROOT` is empty, `LOCAL_CONFIG` is empty, skip local config |
| Malformed JSON in global config | `jq empty` returns non-zero, skip reading that file, keep current LANGUAGE value |
| Malformed JSON in local config | Same as above for local file |
| Both configs have language | Local wins (read global first, then local overwrites) |

### Step 4: Verify Idempotency

The hook must remain idempotent. The language output line (`echo "[dotclaude] language: ..."`) is a read-only operation that:
- Does not modify any files
- Does not create any files
- Always outputs exactly one line of language context
- Does not affect the exit code (still `exit 0`)

Running the hook multiple times produces the same language output each time (given same config state).

## Completion Checklist

- [ ] `hooks/init-config.sh` includes language resolution logic after the config-creation block
- [ ] Default language is `en_US` when no config specifies a language
- [ ] Global config language is read when file exists and is valid JSON
- [ ] Local config language overrides global when both exist
- [ ] `jq` absence is handled gracefully with grep/sed fallback
- [ ] Malformed JSON in either config file does not cause errors or non-zero exit
- [ ] Not being in a git repo does not cause errors (local config is skipped)
- [ ] Output format is exactly: `[dotclaude] language: {locale}` (one line to stdout)
- [ ] Hook remains idempotent (no file modifications added)
- [ ] Hook still exits with code 0
- [ ] Existing config-creation behavior is unchanged

## Notes

- The `[dotclaude]` prefix in the output line follows the convention established by the plugin system for hook outputs.
- The grep/sed fallback for non-jq environments handles simple JSON only (single-line `"language": "value"` pattern). This is acceptable because dotclaude config files are always generated in a simple flat JSON format by `configure.md` and the hook itself.
- The language output line is always emitted, even when the language is `en_US` (the default). This ensures consistent behavior and makes the language context always available to Claude.
