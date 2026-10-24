#!/usr/bin/env bash
# Run the Zfbfmin suites (old S_H tests + new ZfbfminD tests) on normal Spike
# and on the mutant Spike, save logs, and print a summary.
# Run scripts/apply_zfbfmind.sh first.
set -uo pipefail
source "$(dirname "$0")/env.sh"
OUT=$STUDY/results/raw/zfbfmind-$(date +%Y%m%d-%H%M); mkdir -p "$OUT"
cd "$ACT"
echo "== reference Spike: $(command -v spike)"
make spike-rv64-max EXTENSIONS=Zfbfmin 2>&1 | tee "$OUT/ref.log" >/dev/null
echo "== mutant Spike: $SPIKE_ZFB/bin/spike"
PATH=$SPIKE_ZFB/bin:$PATH make spike-rv64-max EXTENSIONS=Zfbfmin 2>&1 | tee "$OUT/mutant.log" >/dev/null
for f in ref mutant; do echo "--- $f"; "$STUDY/scripts/summarize.sh" "$OUT/$f.log"; done
echo "Logs in $OUT. Copy the table into results/zfbfmind_kill_matrix.md."
