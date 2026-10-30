#!/usr/bin/env bash
# Run every test_*.sh in this directory; exit non-zero if any fails.
HERE=$(cd "$(dirname "$0")" && pwd)
bad=0
for t in "$HERE"/test_*.sh; do
  echo "=== $(basename "$t")"
  bash "$t" || { echo "!!! $(basename "$t") FAILED"; bad=$((bad+1)); }
done
[ "$bad" = 0 ] && echo "ALL PASSED" || echo "$bad test file(s) failed"
[ "$bad" = 0 ]
