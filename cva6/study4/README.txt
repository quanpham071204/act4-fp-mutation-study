# Study 4: ACT4 F/D on CVA6 (cv64a6_imafdc_sv39_hpdcache_pmp_mmu_axi, Variane_testharness)
# config: riscv-arch-test study4-cva6 config/cores/cva6/cv64a6_study4; per-ELF timeout 600s
== summary
    200 PASS

# Old-cvfpu re-run (oldfpu_results.txt): 100 tests of the #3585 groups + 8 controls
# 58ca3c3: ~/work/cva6-fpu58 (copy, unmodified). e5aa6a0: NOT BUILT (PULP cvfpu API: 6 FP formats,
# 5 op groups incl. DOTP, hart_id_i, no early_valid_o) - incompatible with current fpu_wrap.sv; edits reverted.
