#!/usr/bin/env bash
# Build a Spike with a mutant patch applied.
# Usage: scripts/build_spike.sh <patch> <install-prefix> [spike-commit]
# Example: scripts/build_spike.sh patches/spike/ds4-mutants.patch ~/tools/spike-ds4 2c300cd
set -euo pipefail
PATCH=$(realpath "$1"); PREFIX=$2; COMMIT=${3:-}
SRC=${SPIKE_SRC_DIR:-$HOME/work/spike-src-$(basename "$PREFIX")}
JOBS=${JOBS:-4}
command -v dtc >/dev/null || { echo "Install device-tree-compiler first (sudo apt install device-tree-compiler)"; exit 1; }
[ -d "$SRC" ] || git clone https://github.com/riscv-software-src/riscv-isa-sim "$SRC"
cd "$SRC"
git reset --hard -q && git clean -fdq
[ -n "$COMMIT" ] && git checkout -q "$COMMIT"
echo "Spike source: $(git rev-parse --short HEAD)"
patch -p1 < "$PATCH"
git --no-pager diff --stat
mkdir -p build && cd build
../configure --prefix="$PREFIX" >/dev/null
make -j"$JOBS" && make install
echo "Installed: $PREFIX/bin/spike"
