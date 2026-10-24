# TODO

## Reproduce on own machine
- [ ] Study 1: apply patch, 12/12 on Sail + Spike rv32/rv64, fill "Author's PC" column
- [ ] Study 1: build mutant Spike, rerun kill matrix, compare with results/zfbfmind_kill_matrix.md
- [ ] Study 2: build Spike 2c300cd + ds4 mutants, minitest output equals results/ds4_minitest_cloud.txt

## New work
- [ ] Study 2: measure kill matrix for D and Ssstrict **before** any change
- [ ] Study 2 Part A: `cp_frm` for fcvt.d.s / fcvt.d.w / fcvt.d.wu in testplans/D.csv (.insn encoding)
- [ ] Study 2 Part B: Ssstrict rm sweep 0..7 + rm=111 with frm 5/6/7
- [ ] Study 2: kill matrix **after**, update report section 4.3
- [ ] Study 3: write `tools/check_norm_refs.py` (reuse `coverpoints_of()` from
      `generators/ctp/generate_priv_testplans.py`); must print exactly the 3 rows in results/norm_refs.md
- [ ] Study 1 extension: BF16 sNaN bad-box operand (e.g. low half 0x7F81) + a mutant that skips the box check
- [ ] Optional: run D S4 tests on CVW via Verilator (`make cvw-rv64gc EXTENSIONS=D`)

## Publish
- [ ] Pick a license, edit Authorship section
- [ ] Regenerate docs/report.pdf after updating numbers
