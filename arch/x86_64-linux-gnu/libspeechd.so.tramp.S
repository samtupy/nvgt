/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .section .note.GNU-stack,"",@progbits

  .data

  .globl _libspeechd_so_tramp_table
  .hidden _libspeechd_so_tramp_table
  .align 8
_libspeechd_so_tramp_table:
  .zero 696

  .text

  .globl _libspeechd_so_tramp_resolve
  .hidden _libspeechd_so_tramp_resolve

  .globl _libspeechd_so_save_regs_and_resolve
  .hidden _libspeechd_so_save_regs_and_resolve
  .type _libspeechd_so_save_regs_and_resolve, %function
_libspeechd_so_save_regs_and_resolve:
  .cfi_startproc

#define PUSH_REG(reg) pushq %reg ; .cfi_adjust_cfa_offset 8; .cfi_rel_offset reg, 0
#define POP_REG(reg) popq %reg ; .cfi_adjust_cfa_offset -8; .cfi_restore reg

#define DEC_STACK(d) subq $d, %rsp; .cfi_adjust_cfa_offset d
#define INC_STACK(d) addq $d, %rsp; .cfi_adjust_cfa_offset -d

#define PUSH_MMX_REG(reg) DEC_STACK(8); movq %reg, (%rsp); .cfi_rel_offset reg, 0
#define POP_MMX_REG(reg) movq (%rsp), %reg; .cfi_restore reg; INC_STACK(8)

#define PUSH_XMM_REG(reg) DEC_STACK(16); movdqa %reg, (%rsp); .cfi_rel_offset reg, 0
#define POP_XMM_REG(reg) movdqa (%rsp), %reg; .cfi_restore reg; INC_STACK(16)

// TODO: cfi_offset/cfi_restore
#define PUSH_YMM_REG(reg) DEC_STACK(32); vmovdqu %reg, (%rsp)
#define POP_YMM_REG(reg) vmovdqu (%rsp), %reg; INC_STACK(32)

// TODO: cfi_offset/cfi_restore
#define PUSH_ZMM_REG(reg) DEC_STACK(64); vmovdqu32 %reg, (%rsp)
#define POP_ZMM_REG(reg) vmovdqu32 (%rsp), %reg; INC_STACK(64)

  // Slow path which calls dlsym, taken only on first call.
  // All registers are stored to handle arbitrary calling conventions
  // (except x87 FPU registers which do not have to be preserved).
  // For Dwarf directives, read https://www.imperialviolet.org/2017/01/18/cfi.html.

  .cfi_def_cfa_offset 8  // Return address

  PUSH_REG(rdi)  // 16
  mov 0x10(%rsp), %rdi
  PUSH_REG(rbx)
  PUSH_REG(rbx)  // 16
  PUSH_REG(rcx)
  PUSH_REG(rdx)  // 16
  PUSH_REG(rbp)
  PUSH_REG(rsi)  // 16
  PUSH_REG(r8)
  PUSH_REG(r9)  // 16
  PUSH_REG(r10)
  PUSH_REG(r11)  // 16
  PUSH_REG(r12)
  PUSH_REG(r13)  // 16
  PUSH_REG(r14)
  PUSH_REG(r15)  // 16

  // Maybe use cpuid instead of macro to detect current vector size...
#ifdef __AVX512F__
  PUSH_ZMM_REG(zmm0)
  PUSH_ZMM_REG(zmm1)
  PUSH_ZMM_REG(zmm2)
  PUSH_ZMM_REG(zmm3)
  PUSH_ZMM_REG(zmm4)
  PUSH_ZMM_REG(zmm5)
  PUSH_ZMM_REG(zmm6)
  PUSH_ZMM_REG(zmm7)
#elif defined __AVX__
  PUSH_YMM_REG(ymm0)
  PUSH_YMM_REG(ymm1)
  PUSH_YMM_REG(ymm2)
  PUSH_YMM_REG(ymm3)
  PUSH_YMM_REG(ymm4)
  PUSH_YMM_REG(ymm5)
  PUSH_YMM_REG(ymm6)
  PUSH_YMM_REG(ymm7)
#elif defined __SSE__
  PUSH_XMM_REG(xmm0)
  PUSH_XMM_REG(xmm1)
  PUSH_XMM_REG(xmm2)
  PUSH_XMM_REG(xmm3)
  PUSH_XMM_REG(xmm4)
  PUSH_XMM_REG(xmm5)
  PUSH_XMM_REG(xmm6)
  PUSH_XMM_REG(xmm7)
#endif

  // MMX registers are not used to pass arguments so we do not save them

  // Stack is just 8-byte aligned but callee will re-align to 16
  call _libspeechd_so_tramp_resolve

#ifdef __AVX512F__
  POP_ZMM_REG(zmm7)
  POP_ZMM_REG(zmm6)
  POP_ZMM_REG(zmm5)
  POP_ZMM_REG(zmm4)
  POP_ZMM_REG(zmm3)
  POP_ZMM_REG(zmm2)
  POP_ZMM_REG(zmm1)
  POP_ZMM_REG(zmm0)  // 16
#elif defined __AVX__
  POP_YMM_REG(ymm7)
  POP_YMM_REG(ymm6)
  POP_YMM_REG(ymm5)
  POP_YMM_REG(ymm4)
  POP_YMM_REG(ymm3)
  POP_YMM_REG(ymm2)
  POP_YMM_REG(ymm1)
  POP_YMM_REG(ymm0)  // 16
#elif defined __SSE__
  POP_XMM_REG(xmm7)
  POP_XMM_REG(xmm6)
  POP_XMM_REG(xmm5)
  POP_XMM_REG(xmm4)
  POP_XMM_REG(xmm3)
  POP_XMM_REG(xmm2)
  POP_XMM_REG(xmm1)
  POP_XMM_REG(xmm0)  // 16
#endif

  POP_REG(r15)
  POP_REG(r14)  // 16
  POP_REG(r13)
  POP_REG(r12)  // 16
  POP_REG(r11)
  POP_REG(r10)  // 16
  POP_REG(r9)
  POP_REG(r8)  // 16
  POP_REG(rsi)
  POP_REG(rbp)  // 16
  POP_REG(rdx)
  POP_REG(rcx)  // 16
  POP_REG(rbx)
  POP_REG(rbx)  // 16
  POP_REG(rdi)

  ret

  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SPDConnectionAddress__free
  .p2align 4
  .type SPDConnectionAddress__free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SPDConnectionAddress__free
#endif
SPDConnectionAddress__free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_modules
  .p2align 4
  .type free_spd_modules, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_modules
#endif
free_spd_modules:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_symbolic_voices
  .p2align 4
  .type free_spd_symbolic_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_symbolic_voices
#endif
free_spd_symbolic_voices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_voices
  .p2align 4
  .type free_spd_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_voices
#endif
free_spd_voices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel
  .p2align 4
  .type spd_cancel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel
#endif
spd_cancel:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel_all
  .p2align 4
  .type spd_cancel_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel_all
#endif
spd_cancel_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel_uid
  .p2align 4
  .type spd_cancel_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel_uid
#endif
spd_cancel_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_char
  .p2align 4
  .type spd_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_char
#endif
spd_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_close
  .p2align 4
  .type spd_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_close
#endif
spd_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command
  .p2align 4
  .type spd_execute_command, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command
#endif
spd_execute_command:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_with_list_reply
  .p2align 4
  .type spd_execute_command_with_list_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_with_list_reply
#endif
spd_execute_command_with_list_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_with_reply
  .p2align 4
  .type spd_execute_command_with_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_with_reply
#endif
spd_execute_command_with_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_wo_mutex
  .p2align 4
  .type spd_execute_command_wo_mutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_wo_mutex
#endif
spd_execute_command_wo_mutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_fd
  .p2align 4
  .type spd_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_fd
#endif
spd_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_client_id
  .p2align 4
  .type spd_get_client_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_client_id
#endif
spd_get_client_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_default_address
  .p2align 4
  .type spd_get_default_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_default_address
#endif
spd_get_default_address:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_language
  .p2align 4
  .type spd_get_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_language
#endif
spd_get_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_message_list_fd
  .p2align 4
  .type spd_get_message_list_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_message_list_fd
#endif
spd_get_message_list_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_output_module
  .p2align 4
  .type spd_get_output_module, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_output_module
#endif
spd_get_output_module:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_pitch
  .p2align 4
  .type spd_get_voice_pitch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_pitch
#endif
spd_get_voice_pitch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_rate
  .p2align 4
  .type spd_get_voice_rate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_rate
#endif
spd_get_voice_rate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_type
  .p2align 4
  .type spd_get_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_type
#endif
spd_get_voice_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_volume
  .p2align 4
  .type spd_get_volume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_volume
#endif
spd_get_volume:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_key
  .p2align 4
  .type spd_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_key
#endif
spd_key:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_modules
  .p2align 4
  .type spd_list_modules, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_modules
#endif
spd_list_modules:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_synthesis_voices
  .p2align 4
  .type spd_list_synthesis_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_synthesis_voices
#endif
spd_list_synthesis_voices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_synthesis_voices2
  .p2align 4
  .type spd_list_synthesis_voices2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_synthesis_voices2
#endif
spd_list_synthesis_voices2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_voices
  .p2align 4
  .type spd_list_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_voices
#endif
spd_list_voices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_open
  .p2align 4
  .type spd_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_open
#endif
spd_open:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_open2
  .p2align 4
  .type spd_open2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_open2
#endif
spd_open2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause
  .p2align 4
  .type spd_pause, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause
#endif
spd_pause:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause_all
  .p2align 4
  .type spd_pause_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause_all
#endif
spd_pause_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause_uid
  .p2align 4
  .type spd_pause_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause_uid
#endif
spd_pause_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume
  .p2align 4
  .type spd_resume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume
#endif
spd_resume:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume_all
  .p2align 4
  .type spd_resume_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume_all
#endif
spd_resume_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume_uid
  .p2align 4
  .type spd_resume_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume_uid
#endif
spd_resume_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_say
  .p2align 4
  .type spd_say, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_say
#endif
spd_say:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_sayf
  .p2align 4
  .type spd_sayf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_sayf
#endif
spd_sayf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_send_data
  .p2align 4
  .type spd_send_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_send_data
#endif
spd_send_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_send_data_wo_mutex
  .p2align 4
  .type spd_send_data_wo_mutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_send_data_wo_mutex
#endif
spd_send_data_wo_mutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters
  .p2align 4
  .type spd_set_capital_letters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters
#endif
spd_set_capital_letters:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters_all
  .p2align 4
  .type spd_set_capital_letters_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters_all
#endif
spd_set_capital_letters_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters_uid
  .p2align 4
  .type spd_set_capital_letters_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters_uid
#endif
spd_set_capital_letters_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_data_mode
  .p2align 4
  .type spd_set_data_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_data_mode
#endif
spd_set_data_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language
  .p2align 4
  .type spd_set_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language
#endif
spd_set_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language_all
  .p2align 4
  .type spd_set_language_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language_all
#endif
spd_set_language_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language_uid
  .p2align 4
  .type spd_set_language_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language_uid
#endif
spd_set_language_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification
  .p2align 4
  .type spd_set_notification, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification
#endif
spd_set_notification:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification_off
  .p2align 4
  .type spd_set_notification_off, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification_off
#endif
spd_set_notification_off:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification_on
  .p2align 4
  .type spd_set_notification_on, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification_on
#endif
spd_set_notification_on:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module
  .p2align 4
  .type spd_set_output_module, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module
#endif
spd_set_output_module:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module_all
  .p2align 4
  .type spd_set_output_module_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module_all
#endif
spd_set_output_module_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module_uid
  .p2align 4
  .type spd_set_output_module_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module_uid
#endif
spd_set_output_module_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation
  .p2align 4
  .type spd_set_punctuation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation
#endif
spd_set_punctuation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation_all
  .p2align 4
  .type spd_set_punctuation_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation_all
#endif
spd_set_punctuation_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation_uid
  .p2align 4
  .type spd_set_punctuation_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation_uid
#endif
spd_set_punctuation_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling
  .p2align 4
  .type spd_set_spelling, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling
#endif
spd_set_spelling:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling_all
  .p2align 4
  .type spd_set_spelling_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling_all
#endif
spd_set_spelling_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling_uid
  .p2align 4
  .type spd_set_spelling_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling_uid
#endif
spd_set_spelling_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice
  .p2align 4
  .type spd_set_synthesis_voice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice
#endif
spd_set_synthesis_voice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice_all
  .p2align 4
  .type spd_set_synthesis_voice_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice_all
#endif
spd_set_synthesis_voice_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice_uid
  .p2align 4
  .type spd_set_synthesis_voice_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice_uid
#endif
spd_set_synthesis_voice_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch
  .p2align 4
  .type spd_set_voice_pitch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch
#endif
spd_set_voice_pitch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_all
  .p2align 4
  .type spd_set_voice_pitch_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_all
#endif
spd_set_voice_pitch_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range
  .p2align 4
  .type spd_set_voice_pitch_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range
#endif
spd_set_voice_pitch_range:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range_all
  .p2align 4
  .type spd_set_voice_pitch_range_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range_all
#endif
spd_set_voice_pitch_range_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range_uid
  .p2align 4
  .type spd_set_voice_pitch_range_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range_uid
#endif
spd_set_voice_pitch_range_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_uid
  .p2align 4
  .type spd_set_voice_pitch_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_uid
#endif
spd_set_voice_pitch_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate
  .p2align 4
  .type spd_set_voice_rate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate
#endif
spd_set_voice_rate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate_all
  .p2align 4
  .type spd_set_voice_rate_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate_all
#endif
spd_set_voice_rate_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate_uid
  .p2align 4
  .type spd_set_voice_rate_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate_uid
#endif
spd_set_voice_rate_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type
  .p2align 4
  .type spd_set_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type
#endif
spd_set_voice_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type_all
  .p2align 4
  .type spd_set_voice_type_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type_all
#endif
spd_set_voice_type_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type_uid
  .p2align 4
  .type spd_set_voice_type_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type_uid
#endif
spd_set_voice_type_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume
  .p2align 4
  .type spd_set_volume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume
#endif
spd_set_volume:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume_all
  .p2align 4
  .type spd_set_volume_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume_all
#endif
spd_set_volume_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume_uid
  .p2align 4
  .type spd_set_volume_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume_uid
#endif
spd_set_volume_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_sound_icon
  .p2align 4
  .type spd_sound_icon, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_sound_icon
#endif
spd_sound_icon:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop
  .p2align 4
  .type spd_stop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop
#endif
spd_stop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop_all
  .p2align 4
  .type spd_stop_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop_all
#endif
spd_stop_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop_uid
  .p2align 4
  .type spd_stop_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop_uid
#endif
spd_stop_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_capital_letters
  .p2align 4
  .type spd_w_set_capital_letters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_capital_letters
#endif
spd_w_set_capital_letters:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_punctuation
  .p2align 4
  .type spd_w_set_punctuation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_punctuation
#endif
spd_w_set_punctuation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_spelling
  .p2align 4
  .type spd_w_set_spelling, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_spelling
#endif
spd_w_set_spelling:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_voice_type
  .p2align 4
  .type spd_w_set_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_voice_type
#endif
spd_w_set_voice_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_wchar
  .p2align 4
  .type spd_wchar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_wchar
#endif
spd_wchar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libspeechd_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libspeechd_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libspeechd_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

