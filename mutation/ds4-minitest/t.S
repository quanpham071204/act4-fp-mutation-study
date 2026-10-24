.section .text.init
.globl _start
_start:
  la t0, trap
  csrw mtvec, t0
  li t0, 0x2000
  csrs mstatus, t0
  li t1, FRM
  csrw frm, t1
  li a0, VAL
  fmv.w.x f2, a0
  .insn ENC
  fmv.x.d a1, f1
  li a2, EXPECT
  bne a1, a2, fail
  li a0, 1
  j done
fail:
  li a0, 3
  j done
.align 2
trap:
  li a0, 5
done:
  la t0, tohost
  sd a0, 0(t0)
1: j 1b
.section .tohost,"aw",@progbits
.align 6
.globl tohost
tohost: .dword 0
.align 6
.globl fromhost
fromhost: .dword 0
