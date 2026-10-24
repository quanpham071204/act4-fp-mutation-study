#!/usr/bin/env bash
# Put the ZfbfminD testplan patch on a fresh branch of ACT4 and regenerate tests.
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ACT"
git fetch -q origin act4
git checkout -B zfbfmind "${1:-$ACT_BASE}"
git am "$STUDY/patches/act4/0001-ZfbfminD.patch"
EXTENSIONS=Zfbfmin make tests
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: regenerated files differ from the patch:"; git status --short
else
  echo "OK: generated tests and covergroups match the patch."
fi
