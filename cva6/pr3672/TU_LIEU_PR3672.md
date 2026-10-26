# Tư liệu: PR openhwfoundation/cva6#3672 (sửa linker path cho Sv39 smoke test)

Cập nhật: 26/10/2026. Báo cáo đầy đủ: `BaoCao_PR3672_LinkerPath.pdf`.

## Thông tin nhanh

| Mục | Giá trị |
| --- | --- |
| PR | https://github.com/openhwfoundation/cva6/pull/3672 (Open, ECA pass, chưa review) |
| Commit | `e3a72caab` "Fix the linker script path of the Sv39 privileged smoke tests" |
| Nhánh | fork `quanpham071204:fix-sv39-linker-path` → base `master_candidate` |
| Repo trong WSL | `~/work/cva6` (remote `fork` = git@github.com:quanpham071204/cva6.git) |
| File sửa | 4 script `verif/regress/smoke-tests-cv64a6_imafdc_sv39_hpdcache_pmp_{mmu,nommu}_{axi,obi}.sh` |
| Thay đổi | `--linker=../tests/custom/privtests/...` → `--linker=../tests/custom/env/privtests/priv/config/link.ld` |

## Lỗi

```
ld: cannot open linker script file ../tests/custom/privtests/priv/config/link.ld: No such file or directory
```

- Xuất hiện 32 lần trong `cva6_smoke.log`, đúng bằng số test trong mảng `SV39_PRIV_TESTS`.
- Script không dừng lại, và dòng tổng kết chỉ báo 6 test độc lập PASS. Vì vậy lỗi bị che.
- Nguyên nhân: test được chuyển sang `verif/tests/custom/env/privtests/` (commit `85f5c1903`, #3449, 10/08/2026). Testlist yaml đã cập nhật, còn tham số `--linker` trong 4 script thì chưa.

## Kết quả sau khi sửa (target `pmp_mmu_axi`, veri-testharness + spike)

- 32/32 test Sv39 trong smoke list PASS (ví dụ `sv39_canonical_Smode`: 387 matched).
- Testlist yaml đầy đủ có 34 test. Hai test SBE (`sv39_mstatus_sbe_set_Smode` và `sv39_mstatus_sbe_and_sum_set_Smode`) không nằm trong smoke list. Chúng lỗi ở bước Spike vì CVA6 và Spike không hỗ trợ big-endian (`mstatus.SBE` = 0).
- Chưa chạy 3 target `mmu_obi`, `nommu_axi` và `nommu_obi`.

## Tái hiện

```bash
cd ~/work/cva6
source ~/cva6_env.sh
source verif/sim/setup-env.sh
export DV_SIMULATORS=veri-testharness,spike
git switch fix-sv39-linker-path        # nhánh có bản sửa
bash verif/regress/smoke-tests-cv64a6_imafdc_sv39_hpdcache_pmp_mmu_axi.sh
grep -c "cannot open linker script" verif/regress/logs/*.log
```

Không chạy `git submodule update` trong `~/work/cva6`: các thay đổi trong submodule là patch chính thức do `./cook.py git-dependencies` áp vào.

## Việc tiếp theo

- [ ] Theo dõi review của PR 3672 và trả lời maintainer.
- [ ] (Tuỳ chọn) Chạy 3 target còn lại rồi cập nhật mô tả PR.
- [ ] Đề xuất riêng: cho script dừng (hoặc báo FAIL) khi một test không biên dịch được.
