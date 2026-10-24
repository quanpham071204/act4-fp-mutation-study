#!/usr/bin/env bash
# Mini kiểm chứng mutant Spike (không cần ACT4). Cần riscv64-unknown-elf-as/ld và spike-mut.
# Dùng: bash run.sh ~/tools/spike-mut/bin/spike
set -e
SPIKE=${1:-spike}; AS=${AS:-riscv64-unknown-elf-as}; LD=${LD:-riscv64-unknown-elf-ld}
cd "$(dirname "$0")"
while read n enc val frm ex; do
  [ -n "$n" ] || continue
  $AS -march=rv64gc --defsym ENC=$enc --defsym VAL=$val --defsym FRM=$frm --defsym EXPECT=$ex t.S -o $n.o
  $LD -T link.ld $n.o -o $n.elf
done < cases.txt
printf "%-14s" case; for m in none M1 M2 M3 M4; do printf "%-6s" $m; done; echo
for f in $(ls *.elf | sort -V); do
  printf "%-14s" "${f%.elf}"
  for m in "" M1 M2 M3 M4; do
    set +e; SPIKE_MUTANT=$m timeout 10 $SPIKE --isa=rv64gc $f >/dev/null 2>&1; rc=$?; set -e
    case $rc in 0) r=ok;; 1) r=WRONG;; 2) r=TRAP;; *) r=rc$rc;; esac; printf "%-6s" $r
  done; echo
done
