#!/usr/bin/env bash
# D S4: run a suite on Spike with each mutant selected by SPIKE_MUTANT.
# Usage: scripts/kill_matrix_ds4.sh [EXTENSIONS] [config]
#   before your change: scripts/kill_matrix_ds4.sh D spike-rv64-max
#   also try:           scripts/kill_matrix_ds4.sh Ssstrict spike-rv64-max
set -uo pipefail
source "$(dirname "$0")/env.sh"
EXT=${1:-D}; CFG=${2:-spike-rv64-max}
OUT=$STUDY/results/raw/ds4-$EXT-$(date +%Y%m%d-%H%M); mkdir -p "$OUT"
cd "$ACT"
for m in none M1 M2 M3 M4; do
  echo "== $m"
  sm=$m; [ "$m" = none ] && sm=
  SPIKE_MUTANT=$sm PATH=$SPIKE_DS4/bin:$PATH make "$CFG" EXTENSIONS="$EXT" 2>&1 | tee "$OUT/$m.log" >/dev/null
  "$STUDY/scripts/summarize.sh" "$OUT/$m.log" | tail -1
done
echo "A mutant is KILLED if its run has at least one failure that the 'none' run does not have."
echo "Logs in $OUT. Fill in results/ds4_kill_matrix.md."
