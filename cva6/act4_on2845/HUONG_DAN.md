# Dựng PR cv64a6_imafdc_sv39 trên nhánh #2845 (Bilal)

## Kết quả đã kiểm chứng trên cloud (28/10/2026)
- CVA6 ở pin của Bilal, 81245a47 (nhánh master), target `cv64a6_imafdc_sv39_hpdcache`, Verilator 5.008
- Full ACT4: **656/673 PASS, 17 FAIL**. Mọi FAIL đều có mục exclude trong `ci.yaml` (đã kiểm bằng script: không còn FAIL nào lọt ra ngoài exclude).
  - FS chưa Dirty sau FCVT (cva6#3173, PR #3678): S_F, Sm_F, U_F
  - LR báo cause của store (cva6#2455, #3394): Exceptions_Zalrsc, PMP_Zalrsc_cfg_wr, 5 test Sv_ExceptionsZalrsc*
  - cbo trên trang R=1, W=0 (cva6#3431): 2 test Sv_Zicbo
  - Bit 0 của pmpaddr NAPOT (cva6#697): PMP_Sm_grain
  - Địa chỉ 0 là debug module: PMP_Sm_cfg_A_tor_zero (Bilal đã ghi lý do)
  - Interrupt bị nhận trễ sau khi ghi mie/mideleg (cva6#3175): InterruptsSm_priority_mideleg_{M,S,U}. Ba test này nằm sẵn trong mục `InterruptsSm` mà Bilal đã exclude.
- Đối chiếu với ddb26b316 (master_candidate): 651/673. Ở commit đó có thêm 5 test PMP NAPOT fail mà master không bị.
- Runner `run-cva6.sh` của Bilal chạy được target cv64. Đã thử: Sm_xret PASS, Zknh PASS, S_F FAIL (đúng lỗi đã biết).
- Log: `act4_cloud_run/summary_673_81245a47.log`

## Patch gồm những gì
- `install-cva6.sh`: thêm `cv64a6_imafdc_sv39_hpdcache` vào `TARGETS` (1 dòng)
- `ci.yaml`: đổi sang dạng danh sách (act4 hiện bắt buộc, xem `ci_config.py`), đổi `PMPSm` thành `PMP_Sm_cfg_A_tor_zero` (tên test mới trên act4), thêm các mục của cv64 kèm link issue
- `README.md`: thêm dòng cv64 vào bảng, thêm đoạn mô tả, thêm lệnh make
- Thư mục mới `cv64a6_imafdc_sv39/`: yaml (link trỏ sang 81245a47), sail.json (schema 0.16), link.ld, rvmodel_macros.h, test_config.yaml, run_cmd.txt
- Đã chạy prettier

## Lệnh (trên WSL)
```bash
cd ~/work/riscv-arch-test
git status --short          # nên sạch; nếu còn file trace thì xoá: rm -f *.traces trace_*.dasm
git fetch https://github.com/BilalAli10x/riscv-arch-test.git cv32a60x-cv32a65x_config
git switch -c cva6-cv64a6-on2845 FETCH_HEAD
git log --oneline -1        # phải là c647a00cc ci(cva6): exclude PMPSm ...
P=$(find /mnt/c/Users/*/Downloads -maxdepth 1 -name 'cv64a6_on_2845*.patch' 2>/dev/null | head -1); echo "$P"
git apply "$P" && git status --short
git add -A config/cores/cva6 .github/scripts/install-cva6.sh
git commit -s               # tự viết message (tiếng Anh, ngắn): dòng đầu ~50 ký tự, thân xuống dòng ~72 ký tự
git push -u fork cva6-cv64a6-on2845
```
Nhánh cũ `cva6-cv64a6-config` cứ để nguyên, không cần xoá.

## Mở PR
- Base: `riscv/riscv-arch-test` nhánh `act4`, compare: `quanpham071204:cva6-cv64a6-on2845`. Mở dạng **Draft**.
- PR sẽ hiện cả các commit của Bilal, chuyện này bình thường. Ghi rõ trong mô tả: "Depends on #2845; based on its branch. I'll rebase once #2845 is merged."
- Mô tả tự viết, ngắn (theo AGENTS.md). Nên có các ý: config mới là gì; dùng chung script và pin của #2845; kết quả 656/673 và các test fail đã được exclude, mỗi mục kèm issue; tag @BilalAli10x để review.
- Nên hỏi Bilal một ý: `InterruptsSm` đang exclude cả suite. Trên cv64 thì 18/21 test của suite PASS, chỉ 3 test priority_mideleg fail (cva6#3175). Có nên thu hẹp exclude cho cv64 không?
