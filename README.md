# act4-fp-mutation-study

How much do the RISC-V architectural tests (ACT4) actually check? This repository
injects bugs into the Spike simulator and measures which ones the ACT4
floating-point tests detect, then adds tests for the gaps.

Full write-up: [`docs/report.md`](docs/report.md) (PDF: [`docs/report.pdf`](docs/report.pdf)).

## Results at a glance

| Study | What | Status | Result |
|---|---|---|---|
| 1. ZfbfminD | BF16 NaN-boxing with FLEN=64 (Zfbfmin + D) | measured | existing suite kills **0/2** mutants, with new ZfbfminD tests **2/2**; 12/12 pass on Sail and Spike (rv32/rv64) |
| 2. D S4 | rm field of `fcvt.d.s`, `fcvt.d.w`, `fcvt.d.wu` (only tested with rm=000) | partly measured | 4/4 mutants observable with 24 minimal tests; ACT4 kill matrix **pending** |
| 3. Norm refs | dangling coverpoint references in `coverpoints/norm/*.yaml` | measured | 3 unresolved, 1 real bug (`Vx.yaml`) |
| 4. ACT4 F/D on CVA6 | 200 ACT4 F/D tests on CVA6 RTL (Verilator), current vs older CVFPU | measured on author's PC | **200/200 pass** on `master_candidate` (CVFPU `3eb6afe`); CVFPU `58ca3c3` fails 2 NaN-boxing tests fixed by CVFPU `28c3e00` |
| CVA6 PR | Sv39 privileged smoke tests used a wrong linker path | PR open | [openhwfoundation/cva6#3672](https://github.com/openhwfoundation/cva6/pull/3672): 0/32 → 32/32 Sv39 smoke tests run and pass |

Studies 1–3 were first measured in a cloud Linux environment on 2026-10-24 at ACT4
`act4` @ `ac1923b`. Study 4 and the CVA6 PR were measured on the author's PC
(WSL2, Verilator 5.008) on 2026-10-25/26. Each results file marks what is
measured and what is pending.

## CVA6 work

- `cva6/pr3672/`: fix for the Sv39 smoke-test linker path: patch, report (Vietnamese PDF),
  log extract with the 32 `cannot open linker script` errors before the fix, and the
  per-test summary after it.
- `cva6/study4/`: ACT4 F/D on CVA6 `cv64a6_imafdc_sv39_hpdcache_pmp_mmu_axi`.
  - The old ACT4 config `cv64a6_imafdcv_sv39` (CVA6 + Ara) does not run on the
    standalone CVA6 testharness. `config/cv64a6_study4/` is a working variant, and
    `CONFIG_CHANGES.md` lists the 4 changes (tohost halt, no V, PMP as in RTL,
    current UDB/Sail keys).
  - `results.txt`: 200/200 pass on current CVFPU `3eb6afe`.
  - `oldfpu_results.txt`: 108 tests from the
    [cva6#3585](https://github.com/openhwfoundation/cva6/issues/3585) failure groups on the
    pre-bump CVFPU `58ca3c3`. Two fail (`D-fdiv.s-00`, `D-fsqrt.s-00`, `cp_fs1_badNB_D_S`).
    The CVFPU used in #3585 (`e5aa6a0`, PULP/Ara branch) does not build with the current
    `fpu_wrap.sv`, so the original 32-failure set is not reproduced.

## Layout

```
docs/report.md               technical report (source of the PDF)
patches/act4/                ZfbfminD testplan patch for ACT4 (git am)
patches/spike/               Spike mutants: zfbfmind-mutants.diff (M1+M2),
                             ds4-mutants.patch (M1..M4, chosen by SPIKE_MUTANT)
mutation/ds4-minitest/       24 standalone tests that prove D S4 mutants are observable
scripts/                     build, apply, run and summarize
results/                     tables (measured or pending) and raw/ logs
cva6/                        CVA6 work: PR 3672 material and Study 4 (ACT4 F/D on CVA6)
TODO.md                      open work
```

## Requirements

Linux or WSL2 with: riscv64-unknown-elf GCC, Spike, Sail (`sail_riscv_sim`),
an ACT4 checkout that runs (`make sail-rv64-max EXTENSIONS=F` passes), and
`device-tree-compiler` to build Spike. Tested setup: Ubuntu 24.04 (WSL2),
GCC 16.1, Sail 0.16, Spike 1.1.1-dev.

## Reproduce

```bash
source scripts/env.sh          # edit ACT / SPIKE_* paths in this file first

# Study 1: ZfbfminD
scripts/apply_zfbfmind.sh                                    # branch + git am + make tests
(cd $ACT && make sail-rv64-max spike-rv64-max EXTENSIONS=Zfbfmin)
scripts/build_spike.sh patches/spike/zfbfmind-mutants.diff $SPIKE_ZFB
scripts/kill_matrix_zfbfmind.sh

# Study 2: D S4
scripts/build_spike.sh patches/spike/ds4-mutants.patch $SPIKE_DS4 2c300cd
bash mutation/ds4-minitest/run.sh $SPIKE_DS4/bin/spike | diff - results/ds4_minitest_cloud.txt
scripts/kill_matrix_ds4.sh D spike-rv64-max
scripts/kill_matrix_ds4.sh Ssstrict spike-rv64-max
```

Two things to check on your setup:

- ACT4 must pick up the mutant Spike. The scripts put it first on `PATH`; if a
  config hard-codes the Spike path, `grep -rn spike $ACT/config/` and adjust.
- `SPIKE_MUTANT` must reach Spike through `make`. If the M1 run of
  `kill_matrix_ds4.sh` looks identical to `none` even on tests that use rm≠0,
  check this first.

## Background

This started as contributions to the ACT4 tracker issue
[riscv-arch-test#2644](https://github.com/riscv/riscv-arch-test/issues/2644).
The maintainers plan to resolve its items in bulk and are not reviewing
individual PRs for it, so the work is published here instead.

## Authorship

Project by Wan ([@quanpham071204](https://github.com/quanpham071204)).
An AI assistant (Claude) was used for research, for drafting the patches,
mutants, scripts and report, and for the first measurements in a cloud
environment. The author chose the direction, reviews every change, and is
reproducing all results on their own machine; results not yet reproduced are
marked in `results/`.

## License

This repository's own files are released under the [MIT License](LICENSE).
The patches in `patches/` modify
[riscv-arch-test](https://github.com/riscv/riscv-arch-test) and
[Spike](https://github.com/riscv-software-src/riscv-isa-sim) and remain under
those projects' licenses.
