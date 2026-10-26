#!/bin/bash
# Progress of the Study 4 F/D run (results_unsorted.txt grows while running; results.txt appears at the end)
f=~/study4/results_unsorted.txt; t=200
n=$(wc -l < $f 2>/dev/null || echo 0)
p=$((n*100/t)); w=40; k=$((n*w/t))
printf '[%s%s] %d/%d (%d%%)\n' "$(printf '%*s' $k '' | tr ' ' '#')" "$(printf '%*s' $((w-k)) '' | tr ' ' '-')" $n $t $p
awk '{print $2}' $f 2>/dev/null | sort | uniq -c
echo "--- khong PASS:"; grep -v " PASS " $f 2>/dev/null
[ -f ~/study4/results.txt ] && echo "=== XONG: ~/study4/results.txt, ~/study4/summary.txt"
