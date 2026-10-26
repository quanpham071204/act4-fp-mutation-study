# cv64a6_study4: thay đổi so với config cv64a6_imafdcv_sv39

Config gốc `config/cores/cva6/cv64a6_imafdcv_sv39` (CVA6 + Ara) được restore từ riscv-arch-test `19d56d7`; trên nhánh `act4` hiện tại nó đã bị xoá (#2821). Config này không chạy được trên CVA6 standalone (`ariane_testharness`, target `cv64a6_imafdc_sv39_hpdcache_pmp_mmu_axi`). Biến thể `cv64a6_study4` có 4 thay đổi.

## 1. rvmodel_macros.h: kết thúc test bằng tohost, UART ở 0x1000_0000

- Config gốc viết cho Ara SoC: kết thúc test bằng store tới thanh ghi điều khiển ở `0xD000_0000`, in chuỗi qua UART ở `0xC000_0000`.
- Trên ariane_testharness hai địa chỉ này không được decode. Kết quả là treo, kèm assertion `B Response Errored`, và test không bao giờ kết thúc.
- Biến thể dùng HTIF `tohost`/`fromhost` (fesvr):
  - `RVMODEL_HALT_PASS` ghi 1 → testharness in `*** SUCCESS ***` và thoát 0.
  - `RVMODEL_HALT_FAIL` ghi 3 → testharness in `*** FAILED *** (tohost = 1)` và thoát 1.
- `RVMODEL_IO_WRITE_STR` dùng `sb` tới UART của testharness ở `0x1000_0000`.

## 2. Bỏ V khỏi UDB và sail.json

- Nếu UDB khai báo V, boot code của ACT4 sẽ đọc `vlenb` và chạy `vsetivli`. CVA6 không có V nên lệnh đầu tiên gây illegal instruction, mọi test fail ngay ở check đầu (`Signature offset mismatch`). Vì vậy giữ V là sai, kể cả khi chỉ chạy F/D.
- Đã bỏ:
  - các extension `V`, `Zve*`, `Zvl*`;
  - mọi tham số vector (`VLEN`, `ELEN`, `VECTOR_*`, `RVV_*`, `VFREDUSUM_*`, …) và `MUTABLE_MISA_V`;
  - mục `V` trong `sail.json` (chuyển `supported: false`).
- Đã thêm `MSTATUS_VS_LEGAL_VALUES: [0]`, vì UDB vẫn bắt buộc tham số này.

## 3. Khai báo PMP đúng RTL

- Target có `CVA6ConfigNrPMPEntries = 8`, granularity 8 byte (G=1, theo `csr_regfile.sv`), `PMPNapotEn = 1`.
- Config gốc khai báo 0 entry (Ara SoC ép về 0). Khi đó ACT4 không cấu hình PMP. Nhưng CVA6 có PMP mà không có entry nào khớp, nên ngay khi xuống S/U-mode thì bị instruction access fault lặp vô hạn (test F/D chạy ở U-mode).
- UDB của biến thể:
  - `NUM_PMP_ENTRIES: 16`
  - `NUM_USABLE_PMP_ENTRIES: 8`
  - `PMP_GRANULARITY: 3`
  - `PMP_NAPOT_SUPPORTED: true`
  - `PMP_TOR_SUPPORTED: true`
  - `PMP_NA4_SUPPORTED: false`
- sail.json: `pmp = {grain 1, count 16, usable_count 8, tor, napot}`.
- Với khai báo này, `rvtest_setup.h` ghi `pmpaddr0 = -1` và `pmpcfg0 = TOR RWX`.

## 4. Theo kịp ACT4 và Sail 0.16 hiện tại

Thay đổi này áp dụng cho cả config gốc lẫn biến thể.

- UDB mới bắt buộc `MEDELEG_DELEGATABLE` và `MIDELEG_DELEGATABLE`. Giá trị lấy theo mask ghi trong `csr_regfile.sv` (RVS=1, RVH=0):
  - medeleg: bit 0–8, 12, 13, 15
  - mideleg: bit 1, 5, 9
- `sail.json` theo schema 0.15 thiếu các khóa mà Sail 0.16 bắt buộc:
  - `H.implicit_vs_pte_access_sets_gstage_d`
  - `Stateen.{m,h,s}stateen*`
  - `Sdtrig.{mcontrol6,textra}`
  - `memory.invalid_physical_address`

  Các khóa này lấy từ `cvw-rv64gc/sail.json`, giá trị đều là "không hỗ trợ" hoặc None.

`link.ld` (base `0x8000_0000`, 16 MiB) giữ nguyên.

Còn lại: UDB vẫn khai báo B/Zbc/Zbkb/Zbkc theo build CVA6 của Ara. Không ảnh hưởng F/D, nhưng phải rà lại trước khi chạy extension khác.

# Thử build với cvfpu cũ e5aa6a0 (bản #3585 dùng): thất bại

- `e5aa6a0` là cvfpu mà CVA6 `99eac9a6` (Ara `34bd3bc1`) dùng, thuộc nhánh cvfpu của PULP.
- Build trong một bản copy (`~/work/cva6-oldfpu`), không đụng checkout chính.
- Các lỗi gặp lần lượt:
  1. `%Error-PINMISSING: fpu_wrap.sv: Cell has missing pin: 'hart_id_i'`. Đã thử nối `.hart_id_i('0)`; cổng này chỉ đi vào khối SDOTP của PULP, FPU vô hướng không dùng.
  2. `%Error-PINNOTFOUND: 'early_valid_o'`. Đã thử gán `fpu_early_valid_o = 1'b0`; tín hiệu này chỉ được đọc khi `SuperscalarEn=1`, target này để 0.
  3. `Assignment pattern missed initializing elements` ở `FPU_FEATURES`/`FPU_IMPLEMENTATION`. `fpnew_pkg` của `e5aa6a0` có 6 FP format (thêm FP8alt) và 5 op group (thêm DOTP); `fpu_wrap.sv` hiện tại viết cho 5 format và 4 op group.
- Đây là khác biệt API: Ara đi kèm `fpu_wrap` riêng. Sửa tiếp nghĩa là viết lại cấu hình FPU, khi đó không còn là phép so sánh "chỉ đổi cvfpu". Vì vậy đã dừng và hoàn tác cả 2 chỗ sửa.
- So sánh thay thế dùng `58ca3c3`, là cvfpu ngay trước bump `6828cd623`, build không cần sửa. Kết quả nằm trong `oldfpu_results.txt`:
  - 2/100 test fail: `D-fdiv.s-00` và `D-fsqrt.s-00`.
  - Nguyên nhân: NaN-boxing trong `divsqrt_th_64`, kết quả ra `0xffffffff00000000` thay vì `0xffffffff7fc00000`.
  - Lỗi này được sửa bởi cvfpu `28c3e00`.
