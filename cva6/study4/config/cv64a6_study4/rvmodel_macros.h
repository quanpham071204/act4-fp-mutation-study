# rvmodel_macros.h
# Study 4 variant of cv64a6_imafdcv_sv39 for the stand-alone CVA6 ariane_testharness
# (Verilator, Variane_testharness). Same UDB config as the Ara one; only the DUT
# glue differs: HTIF tohost termination (fesvr) and the UART at 0x1000_0000.
# SPDX-License-Identifier: Apache-2.0

#ifndef _RVMODEL_MACROS_H
#define _RVMODEL_MACROS_H

#define RVMODEL_DATA_SECTION \
        .pushsection .tohost,"aw",@progbits;                \
        .balign 8; .global tohost; tohost: .dword 0;         \
        .balign 8; .global fromhost; fromhost: .dword 0;     \
        .popsection;

#define STANDARD_SM_SUPPORTED

//#define RVMODEL_BOOT

# fesvr: tohost = 1 -> exit code 0 (SUCCESS), tohost = 3 -> exit code 1 (FAILED)
#define RVMODEL_HALT_PASS  \
  li x1, 1                ;\
  la t0, tohost           ;\
  write_tohost_pass:      ;\
    sw x1, 0(t0)          ;\
    sw x0, 4(t0)          ;\
  self_loop_pass:         ;\
    j self_loop_pass      ;\

#define RVMODEL_HALT_FAIL \
  li x1, 3                ;\
  la t0, tohost           ;\
  write_tohost_fail:      ;\
    sw x1, 0(t0)          ;\
    sw x0, 4(t0)          ;\
  self_loop_fail:         ;\
    j self_loop_fail      ;\

#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR) \
1:                           ;                        \
  lbu  _R1, 0(_STR_PTR)      ; /* Load byte */        \
  beqz _R1, 3f               ; /* Exit if null */     \
2:                           ;                        \
  li   _R2, 0x10000000       ; /* ariane UART THR */  \
  sb   _R1, 0(_R2)           ;                        \
  addi _STR_PTR, _STR_PTR, 1 ; /* Next char */        \
  j 1b                       ; /* Loop */             \
3:

#define RVMODEL_INTERRUPT_LATENCY 10

//#define RVMODEL_MTIME_ADDRESS
//#define RVMODEL_MTIMECMP_ADDRESS
#define RVMODEL_TIMER_INT_SOON_DELAY 100

#endif // _RVMODEL_MACROS_H
