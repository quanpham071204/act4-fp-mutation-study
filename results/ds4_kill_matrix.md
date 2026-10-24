# D S4: results

## 1. Mutant validation (done, cloud, 2026-10-24)

Each mutant must be *observable*: some single instruction must behave differently
from normal Spike. `mutation/ds4-minitest/` runs 24 hand-written cases
(`fcvt.d.w` and `fcvt.d.s`, every static rm, frm = 0 or 5) on Spike `2c300cd`
with `patches/spike/ds4-mutants.patch`. Raw output: `ds4_minitest_cloud.txt`.

| Mutant | Bug it models | Seen in minitest as |
|---|---|---|
| M1 | decoder accepts only rm=000 on exact conversions | TRAP for every rm in 1..4, 7 |
| M2 | rm field never checked | reserved rm 101/110 and dyn+frm=5 execute instead of trapping |
| M3 | `fcvt.d.w` rounds through single precision when rm≠0 | WRONG result for 2^24+1 with rm 1..4, 7 |
| M4 | dynamic rm ignores a reserved frm | rm=111 with frm=5 executes instead of trapping |

Result: 4/4 mutants observable. On the author's PC: pending
(`bash mutation/ds4-minitest/run.sh $SPIKE_DS4/bin/spike`, output must equal the cloud file).

## 2. Kill matrix of the ACT4 suites (pending, run on author's PC)

`scripts/kill_matrix_ds4.sh D spike-rv64-max` and `scripts/kill_matrix_ds4.sh Ssstrict spike-rv64-max`.

| Suite | M1 | M2 | M3 | M4 | Score |
|---|---|---|---|---|---|
| D (act4 `ac1923b`), before change | pending | pending | pending | pending | pending |
| Ssstrict, before change | pending | pending | pending | pending | pending |
| D + Part A (`cp_frm` on the 3 exact conversions) | pending | pending | pending | pending | pending |
| Ssstrict + Part B (rm sweep 0..7, rm=111 with frm 5..7) | pending | pending | pending | pending | pending |

Hypothesis (not yet measured): the current suites kill none of the four, because
they only emit these instructions with rm=000 and Ssstrict's `cp_Ftype` sweep
randomizes fmt/rs2. Part A should kill M1 and M3, Part B should kill M2 and M4.
