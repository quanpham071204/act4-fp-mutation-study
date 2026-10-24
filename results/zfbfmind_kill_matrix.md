# ZfbfminD: results

Measured 2026-10-24 in a cloud Linux environment, ACT4 `act4` @ `ac1923b`,
GCC prebuilt 2026.08.27, Sail 0.16, Spike built from source (HEAD of that day).
Re-run on the author's machine: **pending** (fill in below).

## Functional pass on reference models

| Config | New ZfbfminD tests | Cloud | Author's PC |
|---|---|---|---|
| `make sail-rv64-max EXTENSIONS=Zfbfmin`  | 12 files (6 rv64) | 12/12 PASS | pending |
| `make sail-rv32-max EXTENSIONS=Zfbfmin`  |                   | 12/12 PASS | pending |
| `make spike-rv64-max EXTENSIONS=Zfbfmin` |                   | 12/12 PASS | pending |
| `make spike-rv32-max EXTENSIONS=Zfbfmin` |                   | 12/12 PASS | pending |
| `prek` (lint/format)                     |                   | passed     | pending |

## Kill matrix (Spike with mutants M1 + M2, `spike-rv64-max`)

| Test | Suite | Result on mutant Spike | Kills |
|---|---|---|---|
| `Zfbfmin-*` (6 tests) | existing, S_H boxing | all PASS | none |
| `ZfbfminD-fcvt.s.bf16-00` | new | **FAIL** at bin `b0x7fffffffffff3c00`, expected `0xffffffff7fc00000` | M1 |
| `ZfbfminD-fmv.h.x-00` | new | **FAIL** at bin `NaNBox`, expected `0xffffffffffff3fa6` | M2 |
| `ZfbfminD-fcvt.bf16.s-00`, `-flh-00`, `-fmv.x.h-00`, `-fsh-00` | new | PASS (mutants are not in these instructions) | none |

Mutation score: existing suite **0/2**, with ZfbfminD **2/2**.

- M1: `fcvt.s.bf16` checks NaN-box bits [31:16] only, ignores [63:32].
- M2: `fmv.h.x` NaN-boxes only up to bit 31, leaves [63:32] = 0.
