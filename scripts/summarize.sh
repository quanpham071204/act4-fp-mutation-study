#!/usr/bin/env bash
# Print PASS/FAIL per test from an ACT4 run log (lines tagged RVCP-SUMMARY).
# Usage: scripts/summarize.sh <logfile>
# If your ACT4 version prints results differently, adjust the pattern below.
grep -E "RVCP-SUMMARY|FAIL" "$1" | sed -E 's/\x1b\[[0-9;]*m//g' | sort -u
echo "passed: $(grep -c 'TEST PASSED' "$1" || true)  failed: $(grep -c 'TEST FAILED' "$1" || true)"
