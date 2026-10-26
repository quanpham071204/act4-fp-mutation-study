#!/bin/bash
# Progress of the 58ca3c3 (old cvfpu) re-run: 108 tests = 100 in the #3585 groups + 8 controls
f=~/study4/oldfpu/raw_fpu58.txt; t=108
n=$(wc -l < $f 2>/dev/null || echo 0)
p=$((n*100/t)); w=40; k=$((n*w/t))
printf '[%s%s] %d/%d (%d%%)\n' "$(printf '%*s' $k '' | tr ' ' '#')" "$(printf '%*s' $((w-k)) '' | tr ' ' '-')" $n $t $p
awk '{print $2}' $f 2>/dev/null | sort | uniq -c
echo "--- khong PASS:"; grep -v " PASS" $f 2>/dev/null | sort
[ -f ~/study4/oldfpu_results.txt ] && echo "=== XONG: ~/study4/oldfpu_results.txt"
