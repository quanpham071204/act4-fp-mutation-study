# Dangling coverpoint references in `coverpoints/norm/*.yaml`

ACT4 `act4` @ `ac1923b`, 2026-10-24. Every `<covergroup>/<coverpoint>` reference in the
normative-rule mapping files was checked against the covergroups declared in
`coverpoints/priv/*.svh` and `coverpoints/unpriv/*.svh` (a reference `cp_x` also
matches a coverpoint family `cp_x_*`).

| File | Rule | Reference | Verdict |
|---|---|---|---|
| `Vx.yaml` | `vrgather_vrgatherei16_vl` | `Vx16_vrgatherei16_vv_cg/cr_vl_lmul_sew16` | **bug**: covergroup only has `cr_vl_lmul_e16_sew16` |
| `Sm.yaml` | `m_access_all_lower_priv_csrs` | `H_mcsr_cg/cp_hcsr_access` | placeholder for the not-yet-added H suite |
| `Sstc.yaml` | `stce_bit_exist` | `SstcH_vs_cg/cp_vs_stimecmp_accessible` | placeholder for the H suite |

Also: `ZicsrF.yaml` (tracker item F S6) has 18 references, all resolve, so F S6 was
already fixed by upstream PR #2616.

Root cause: nothing in the CTP build compares norm-YAML references with the
`.svh` declarations (`generators/ctp/generate_norm_table.py` checks rule names only).

Checker script: `tools/check_norm_refs.py` (**to be written by the author**, see TODO.md).
Expected output on `ac1923b`: exactly the 3 rows above.
