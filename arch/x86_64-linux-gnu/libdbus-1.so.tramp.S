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

  .globl _libdbus_1_so_tramp_table
  .hidden _libdbus_1_so_tramp_table
  .align 8
_libdbus_1_so_tramp_table:
  .zero 4568

  .text

  .globl _libdbus_1_so_tramp_resolve
  .hidden _libdbus_1_so_tramp_resolve

  .globl _libdbus_1_so_save_regs_and_resolve
  .hidden _libdbus_1_so_save_regs_and_resolve
  .type _libdbus_1_so_save_regs_and_resolve, %function
_libdbus_1_so_save_regs_and_resolve:
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
  call _libdbus_1_so_tramp_resolve

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

  .globl _dbus_abort
  .p2align 4
  .type _dbus_abort, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_abort
#endif
_dbus_abort:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_address_append_escaped
  .p2align 4
  .type _dbus_address_append_escaped, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_address_append_escaped
#endif
_dbus_address_append_escaped:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_append_user_from_current_process
  .p2align 4
  .type _dbus_append_user_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_append_user_from_current_process
#endif
_dbus_append_user_from_current_process:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_atomic_dec
  .p2align 4
  .type _dbus_atomic_dec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_dec
#endif
_dbus_atomic_dec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_atomic_get
  .p2align 4
  .type _dbus_atomic_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_get
#endif
_dbus_atomic_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_atomic_inc
  .p2align 4
  .type _dbus_atomic_inc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_inc
#endif
_dbus_atomic_inc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_atomic_set_nonzero
  .p2align 4
  .type _dbus_atomic_set_nonzero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_set_nonzero
#endif
_dbus_atomic_set_nonzero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_atomic_set_zero
  .p2align 4
  .type _dbus_atomic_set_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_set_zero
#endif
_dbus_atomic_set_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_bytes_sent
  .p2align 4
  .type _dbus_auth_bytes_sent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_bytes_sent
#endif
_dbus_auth_bytes_sent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_client_new
  .p2align 4
  .type _dbus_auth_client_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_client_new
#endif
_dbus_auth_client_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_delete_unused_bytes
  .p2align 4
  .type _dbus_auth_delete_unused_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_delete_unused_bytes
#endif
_dbus_auth_delete_unused_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_do_work
  .p2align 4
  .type _dbus_auth_do_work, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_do_work
#endif
_dbus_auth_do_work:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_dump_supported_mechanisms
  .p2align 4
  .type _dbus_auth_dump_supported_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_dump_supported_mechanisms
#endif
_dbus_auth_dump_supported_mechanisms:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_get_buffer
  .p2align 4
  .type _dbus_auth_get_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_buffer
#endif
_dbus_auth_get_buffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_get_bytes_to_send
  .p2align 4
  .type _dbus_auth_get_bytes_to_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_bytes_to_send
#endif
_dbus_auth_get_bytes_to_send:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_get_identity
  .p2align 4
  .type _dbus_auth_get_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_identity
#endif
_dbus_auth_get_identity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_get_unused_bytes
  .p2align 4
  .type _dbus_auth_get_unused_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_unused_bytes
#endif
_dbus_auth_get_unused_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_is_supported_mechanism
  .p2align 4
  .type _dbus_auth_is_supported_mechanism, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_is_supported_mechanism
#endif
_dbus_auth_is_supported_mechanism:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_ref
  .p2align 4
  .type _dbus_auth_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_ref
#endif
_dbus_auth_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_return_buffer
  .p2align 4
  .type _dbus_auth_return_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_return_buffer
#endif
_dbus_auth_return_buffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_server_new
  .p2align 4
  .type _dbus_auth_server_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_server_new
#endif
_dbus_auth_server_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_set_context
  .p2align 4
  .type _dbus_auth_set_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_context
#endif
_dbus_auth_set_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_set_credentials
  .p2align 4
  .type _dbus_auth_set_credentials, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_credentials
#endif
_dbus_auth_set_credentials:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_set_mechanisms
  .p2align 4
  .type _dbus_auth_set_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_mechanisms
#endif
_dbus_auth_set_mechanisms:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_auth_unref
  .p2align 4
  .type _dbus_auth_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_unref
#endif
_dbus_auth_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_clearenv
  .p2align 4
  .type _dbus_clearenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_clearenv
#endif
_dbus_clearenv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_close
  .p2align 4
  .type _dbus_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close
#endif
_dbus_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_close_all
  .p2align 4
  .type _dbus_close_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close_all
#endif
_dbus_close_all:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_close_socket
  .p2align 4
  .type _dbus_close_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close_socket
#endif
_dbus_close_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_concat_dir_and_file
  .p2align 4
  .type _dbus_concat_dir_and_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_concat_dir_and_file
#endif
_dbus_concat_dir_and_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_get_credentials
  .p2align 4
  .type _dbus_connection_get_credentials, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_credentials
#endif
_dbus_connection_get_credentials:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_get_linux_security_label
  .p2align 4
  .type _dbus_connection_get_linux_security_label, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_linux_security_label
#endif
_dbus_connection_get_linux_security_label:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_get_next_client_serial
  .p2align 4
  .type _dbus_connection_get_next_client_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_next_client_serial
#endif
_dbus_connection_get_next_client_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_get_pending_fds_count
  .p2align 4
  .type _dbus_connection_get_pending_fds_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_pending_fds_count
#endif
_dbus_connection_get_pending_fds_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_get_stats
  .p2align 4
  .type _dbus_connection_get_stats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_stats
#endif
_dbus_connection_get_stats:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_lock
  .p2align 4
  .type _dbus_connection_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_lock
#endif
_dbus_connection_lock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_ref_unlocked
  .p2align 4
  .type _dbus_connection_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_ref_unlocked
#endif
_dbus_connection_ref_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_set_pending_fds_function
  .p2align 4
  .type _dbus_connection_set_pending_fds_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_set_pending_fds_function
#endif
_dbus_connection_set_pending_fds_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_unlock
  .p2align 4
  .type _dbus_connection_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_unlock
#endif
_dbus_connection_unlock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_connection_unref_unlocked
  .p2align 4
  .type _dbus_connection_unref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_unref_unlocked
#endif
_dbus_connection_unref_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_create_directory
  .p2align 4
  .type _dbus_create_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_create_directory
#endif
_dbus_create_directory:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_create_uuid
  .p2align 4
  .type _dbus_create_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_create_uuid
#endif
_dbus_create_uuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_add_pid
  .p2align 4
  .type _dbus_credentials_add_pid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_pid
#endif
_dbus_credentials_add_pid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_add_unix_uid
  .p2align 4
  .type _dbus_credentials_add_unix_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_unix_uid
#endif
_dbus_credentials_add_unix_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_add_windows_sid
  .p2align 4
  .type _dbus_credentials_add_windows_sid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_windows_sid
#endif
_dbus_credentials_add_windows_sid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_are_anonymous
  .p2align 4
  .type _dbus_credentials_are_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_anonymous
#endif
_dbus_credentials_are_anonymous:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_are_empty
  .p2align 4
  .type _dbus_credentials_are_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_empty
#endif
_dbus_credentials_are_empty:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_are_superset
  .p2align 4
  .type _dbus_credentials_are_superset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_superset
#endif
_dbus_credentials_are_superset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_clear
  .p2align 4
  .type _dbus_credentials_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_clear
#endif
_dbus_credentials_clear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_copy
  .p2align 4
  .type _dbus_credentials_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_copy
#endif
_dbus_credentials_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_linux_security_label
  .p2align 4
  .type _dbus_credentials_get_linux_security_label, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_linux_security_label
#endif
_dbus_credentials_get_linux_security_label:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_pid
  .p2align 4
  .type _dbus_credentials_get_pid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_pid
#endif
_dbus_credentials_get_pid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_pid_fd
  .p2align 4
  .type _dbus_credentials_get_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_pid_fd
#endif
_dbus_credentials_get_pid_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_unix_gids
  .p2align 4
  .type _dbus_credentials_get_unix_gids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_unix_gids
#endif
_dbus_credentials_get_unix_gids:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_unix_uid
  .p2align 4
  .type _dbus_credentials_get_unix_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_unix_uid
#endif
_dbus_credentials_get_unix_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_get_windows_sid
  .p2align 4
  .type _dbus_credentials_get_windows_sid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_windows_sid
#endif
_dbus_credentials_get_windows_sid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_include
  .p2align 4
  .type _dbus_credentials_include, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_include
#endif
_dbus_credentials_include:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_new
  .p2align 4
  .type _dbus_credentials_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_new
#endif
_dbus_credentials_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_new_from_current_process
  .p2align 4
  .type _dbus_credentials_new_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_new_from_current_process
#endif
_dbus_credentials_new_from_current_process:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_ref
  .p2align 4
  .type _dbus_credentials_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_ref
#endif
_dbus_credentials_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_same_user
  .p2align 4
  .type _dbus_credentials_same_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_same_user
#endif
_dbus_credentials_same_user:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_take_pid_fd
  .p2align 4
  .type _dbus_credentials_take_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_take_pid_fd
#endif
_dbus_credentials_take_pid_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_take_unix_gids
  .p2align 4
  .type _dbus_credentials_take_unix_gids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_take_unix_gids
#endif
_dbus_credentials_take_unix_gids:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_to_string_append
  .p2align 4
  .type _dbus_credentials_to_string_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_to_string_append
#endif
_dbus_credentials_to_string_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_credentials_unref
  .p2align 4
  .type _dbus_credentials_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_unref
#endif
_dbus_credentials_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_delete_directory
  .p2align 4
  .type _dbus_delete_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_delete_directory
#endif
_dbus_delete_directory:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_delete_file
  .p2align 4
  .type _dbus_delete_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_delete_file
#endif
_dbus_delete_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_dup
  .p2align 4
  .type _dbus_dup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_dup
#endif
_dbus_dup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_ensure_directory
  .p2align 4
  .type _dbus_ensure_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_ensure_directory
#endif
_dbus_ensure_directory:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_ensure_standard_fds
  .p2align 4
  .type _dbus_ensure_standard_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_ensure_standard_fds
#endif
_dbus_ensure_standard_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_error_from_errno
  .p2align 4
  .type _dbus_error_from_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_error_from_errno
#endif
_dbus_error_from_errno:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_error_from_system_errno
  .p2align 4
  .type _dbus_error_from_system_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_error_from_system_errno
#endif
_dbus_error_from_system_errno:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_exit
  .p2align 4
  .type _dbus_exit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_exit
#endif
_dbus_exit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_fd_clear_close_on_exec
  .p2align 4
  .type _dbus_fd_clear_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_clear_close_on_exec
#endif
_dbus_fd_clear_close_on_exec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_fd_set_all_close_on_exec
  .p2align 4
  .type _dbus_fd_set_all_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_set_all_close_on_exec
#endif
_dbus_fd_set_all_close_on_exec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_fd_set_close_on_exec
  .p2align 4
  .type _dbus_fd_set_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_set_close_on_exec
#endif
_dbus_fd_set_close_on_exec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_file_get_contents
  .p2align 4
  .type _dbus_file_get_contents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_file_get_contents
#endif
_dbus_file_get_contents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_first_type_in_signature
  .p2align 4
  .type _dbus_first_type_in_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_first_type_in_signature
#endif
_dbus_first_type_in_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_flush_caches
  .p2align 4
  .type _dbus_flush_caches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_flush_caches
#endif
_dbus_flush_caches:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_generate_random_ascii
  .p2align 4
  .type _dbus_generate_random_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_generate_random_ascii
#endif
_dbus_generate_random_ascii:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_generate_uuid
  .p2align 4
  .type _dbus_generate_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_generate_uuid
#endif
_dbus_generate_uuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_get_local_machine_uuid_encoded
  .p2align 4
  .type _dbus_get_local_machine_uuid_encoded, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_local_machine_uuid_encoded
#endif
_dbus_get_local_machine_uuid_encoded:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_get_monotonic_time
  .p2align 4
  .type _dbus_get_monotonic_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_monotonic_time
#endif
_dbus_get_monotonic_time:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_get_real_time
  .p2align 4
  .type _dbus_get_real_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_real_time
#endif
_dbus_get_real_time:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_get_tmpdir
  .p2align 4
  .type _dbus_get_tmpdir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_tmpdir
#endif
_dbus_get_tmpdir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_get_uuid
  .p2align 4
  .type _dbus_get_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_uuid
#endif
_dbus_get_uuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_getenv
  .p2align 4
  .type _dbus_getenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getenv
#endif
_dbus_getenv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_geteuid
  .p2align 4
  .type _dbus_geteuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_geteuid
#endif
_dbus_geteuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_getpid
  .p2align 4
  .type _dbus_getpid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getpid
#endif
_dbus_getpid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_getuid
  .p2align 4
  .type _dbus_getuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getuid
#endif
_dbus_getuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_group_info_unref
  .p2align 4
  .type _dbus_group_info_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_group_info_unref
#endif
_dbus_group_info_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_get_int_key
  .p2align 4
  .type _dbus_hash_iter_get_int_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_int_key
#endif
_dbus_hash_iter_get_int_key:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_get_string_key
  .p2align 4
  .type _dbus_hash_iter_get_string_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_string_key
#endif
_dbus_hash_iter_get_string_key:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_get_uintptr_key
  .p2align 4
  .type _dbus_hash_iter_get_uintptr_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_uintptr_key
#endif
_dbus_hash_iter_get_uintptr_key:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_get_value
  .p2align 4
  .type _dbus_hash_iter_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_value
#endif
_dbus_hash_iter_get_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_init
  .p2align 4
  .type _dbus_hash_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_init
#endif
_dbus_hash_iter_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_lookup
  .p2align 4
  .type _dbus_hash_iter_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_lookup
#endif
_dbus_hash_iter_lookup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_next
  .p2align 4
  .type _dbus_hash_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_next
#endif
_dbus_hash_iter_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_remove_entry
  .p2align 4
  .type _dbus_hash_iter_remove_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_remove_entry
#endif
_dbus_hash_iter_remove_entry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_iter_set_value
  .p2align 4
  .type _dbus_hash_iter_set_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_set_value
#endif
_dbus_hash_iter_set_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_free_preallocated_entry
  .p2align 4
  .type _dbus_hash_table_free_preallocated_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_free_preallocated_entry
#endif
_dbus_hash_table_free_preallocated_entry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_from_array
  .p2align 4
  .type _dbus_hash_table_from_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_from_array
#endif
_dbus_hash_table_from_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_get_n_entries
  .p2align 4
  .type _dbus_hash_table_get_n_entries, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_get_n_entries
#endif
_dbus_hash_table_get_n_entries:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_insert_int
  .p2align 4
  .type _dbus_hash_table_insert_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_int
#endif
_dbus_hash_table_insert_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_insert_string
  .p2align 4
  .type _dbus_hash_table_insert_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_string
#endif
_dbus_hash_table_insert_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_insert_string_preallocated
  .p2align 4
  .type _dbus_hash_table_insert_string_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_string_preallocated
#endif
_dbus_hash_table_insert_string_preallocated:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_insert_uintptr
  .p2align 4
  .type _dbus_hash_table_insert_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_uintptr
#endif
_dbus_hash_table_insert_uintptr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_lookup_int
  .p2align 4
  .type _dbus_hash_table_lookup_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_int
#endif
_dbus_hash_table_lookup_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_lookup_string
  .p2align 4
  .type _dbus_hash_table_lookup_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_string
#endif
_dbus_hash_table_lookup_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_lookup_uintptr
  .p2align 4
  .type _dbus_hash_table_lookup_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_uintptr
#endif
_dbus_hash_table_lookup_uintptr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_new
  .p2align 4
  .type _dbus_hash_table_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_new
#endif
_dbus_hash_table_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_preallocate_entry
  .p2align 4
  .type _dbus_hash_table_preallocate_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_preallocate_entry
#endif
_dbus_hash_table_preallocate_entry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_ref
  .p2align 4
  .type _dbus_hash_table_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_ref
#endif
_dbus_hash_table_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_remove_int
  .p2align 4
  .type _dbus_hash_table_remove_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_int
#endif
_dbus_hash_table_remove_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_remove_string
  .p2align 4
  .type _dbus_hash_table_remove_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_string
#endif
_dbus_hash_table_remove_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_remove_uintptr
  .p2align 4
  .type _dbus_hash_table_remove_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_uintptr
#endif
_dbus_hash_table_remove_uintptr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_to_array
  .p2align 4
  .type _dbus_hash_table_to_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_to_array
#endif
_dbus_hash_table_to_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_hash_table_unref
  .p2align 4
  .type _dbus_hash_table_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_unref
#endif
_dbus_hash_table_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_header_delete_field
  .p2align 4
  .type _dbus_header_delete_field, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_delete_field
#endif
_dbus_header_delete_field:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_header_get_byte_order
  .p2align 4
  .type _dbus_header_get_byte_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_get_byte_order
#endif
_dbus_header_get_byte_order:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_header_get_field_raw
  .p2align 4
  .type _dbus_header_get_field_raw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_get_field_raw
#endif
_dbus_header_get_field_raw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_header_set_field_basic
  .p2align 4
  .type _dbus_header_set_field_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_set_field_basic
#endif
_dbus_header_set_field_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_homedir_from_current_process
  .p2align 4
  .type _dbus_homedir_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_homedir_from_current_process
#endif
_dbus_homedir_from_current_process:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_init_system_log
  .p2align 4
  .type _dbus_init_system_log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_init_system_log
#endif
_dbus_init_system_log:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_is_a_number
  .p2align 4
  .type _dbus_is_a_number, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_is_a_number
#endif
_dbus_is_a_number:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_alloc_link
  .p2align 4
  .type _dbus_list_alloc_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_alloc_link
#endif
_dbus_list_alloc_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_append
  .p2align 4
  .type _dbus_list_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_append
#endif
_dbus_list_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_append_link
  .p2align 4
  .type _dbus_list_append_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_append_link
#endif
_dbus_list_append_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_clear
  .p2align 4
  .type _dbus_list_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_clear
#endif
_dbus_list_clear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_clear_full
  .p2align 4
  .type _dbus_list_clear_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_clear_full
#endif
_dbus_list_clear_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_copy
  .p2align 4
  .type _dbus_list_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_copy
#endif
_dbus_list_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_find_last
  .p2align 4
  .type _dbus_list_find_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_find_last
#endif
_dbus_list_find_last:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_foreach
  .p2align 4
  .type _dbus_list_foreach, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_foreach
#endif
_dbus_list_foreach:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_free_link
  .p2align 4
  .type _dbus_list_free_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_free_link
#endif
_dbus_list_free_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_first
  .p2align 4
  .type _dbus_list_get_first, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_first
#endif
_dbus_list_get_first:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_first_link
  .p2align 4
  .type _dbus_list_get_first_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_first_link
#endif
_dbus_list_get_first_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_last
  .p2align 4
  .type _dbus_list_get_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_last
#endif
_dbus_list_get_last:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_last_link
  .p2align 4
  .type _dbus_list_get_last_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_last_link
#endif
_dbus_list_get_last_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_length
  .p2align 4
  .type _dbus_list_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_length
#endif
_dbus_list_get_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_get_stats
  .p2align 4
  .type _dbus_list_get_stats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_stats
#endif
_dbus_list_get_stats:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_insert_after
  .p2align 4
  .type _dbus_list_insert_after, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_after
#endif
_dbus_list_insert_after:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_insert_after_link
  .p2align 4
  .type _dbus_list_insert_after_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_after_link
#endif
_dbus_list_insert_after_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_insert_before_link
  .p2align 4
  .type _dbus_list_insert_before_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_before_link
#endif
_dbus_list_insert_before_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_length_is_one
  .p2align 4
  .type _dbus_list_length_is_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_length_is_one
#endif
_dbus_list_length_is_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_pop_first
  .p2align 4
  .type _dbus_list_pop_first, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_first
#endif
_dbus_list_pop_first:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_pop_first_link
  .p2align 4
  .type _dbus_list_pop_first_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_first_link
#endif
_dbus_list_pop_first_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_pop_last
  .p2align 4
  .type _dbus_list_pop_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_last
#endif
_dbus_list_pop_last:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_prepend
  .p2align 4
  .type _dbus_list_prepend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_prepend
#endif
_dbus_list_prepend:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_prepend_link
  .p2align 4
  .type _dbus_list_prepend_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_prepend_link
#endif
_dbus_list_prepend_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_remove
  .p2align 4
  .type _dbus_list_remove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove
#endif
_dbus_list_remove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_remove_last
  .p2align 4
  .type _dbus_list_remove_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove_last
#endif
_dbus_list_remove_last:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_remove_link
  .p2align 4
  .type _dbus_list_remove_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove_link
#endif
_dbus_list_remove_link:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_list_unlink
  .p2align 4
  .type _dbus_list_unlink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_unlink
#endif
_dbus_list_unlink:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_log
  .p2align 4
  .type _dbus_log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_log
#endif
_dbus_log:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_logv
  .p2align 4
  .type _dbus_logv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_logv
#endif
_dbus_logv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_lookup_session_address
  .p2align 4
  .type _dbus_lookup_session_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_lookup_session_address
#endif
_dbus_lookup_session_address:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_marshal_byteswap
  .p2align 4
  .type _dbus_marshal_byteswap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_byteswap
#endif
_dbus_marshal_byteswap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_marshal_read_uint32
  .p2align 4
  .type _dbus_marshal_read_uint32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_read_uint32
#endif
_dbus_marshal_read_uint32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_marshal_set_uint32
  .p2align 4
  .type _dbus_marshal_set_uint32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_set_uint32
#endif
_dbus_marshal_set_uint32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_mem_pool_alloc
  .p2align 4
  .type _dbus_mem_pool_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_alloc
#endif
_dbus_mem_pool_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_mem_pool_dealloc
  .p2align 4
  .type _dbus_mem_pool_dealloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_dealloc
#endif
_dbus_mem_pool_dealloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_mem_pool_free
  .p2align 4
  .type _dbus_mem_pool_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_free
#endif
_dbus_mem_pool_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_mem_pool_new
  .p2align 4
  .type _dbus_mem_pool_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_new
#endif
_dbus_mem_pool_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_get_unix_fds
  .p2align 4
  .type _dbus_message_get_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_get_unix_fds
#endif
_dbus_message_get_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_iter_get_args_valist
  .p2align 4
  .type _dbus_message_iter_get_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_iter_get_args_valist
#endif
_dbus_message_iter_get_args_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_get_buffer
  .p2align 4
  .type _dbus_message_loader_get_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_buffer
#endif
_dbus_message_loader_get_buffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_get_is_corrupted
  .p2align 4
  .type _dbus_message_loader_get_is_corrupted, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_is_corrupted
#endif
_dbus_message_loader_get_is_corrupted:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_get_max_message_size
  .p2align 4
  .type _dbus_message_loader_get_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_max_message_size
#endif
_dbus_message_loader_get_max_message_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_get_unix_fds
  .p2align 4
  .type _dbus_message_loader_get_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_unix_fds
#endif
_dbus_message_loader_get_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_new
  .p2align 4
  .type _dbus_message_loader_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_new
#endif
_dbus_message_loader_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_pop_message
  .p2align 4
  .type _dbus_message_loader_pop_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_pop_message
#endif
_dbus_message_loader_pop_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_queue_messages
  .p2align 4
  .type _dbus_message_loader_queue_messages, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_queue_messages
#endif
_dbus_message_loader_queue_messages:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_ref
  .p2align 4
  .type _dbus_message_loader_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_ref
#endif
_dbus_message_loader_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_return_buffer
  .p2align 4
  .type _dbus_message_loader_return_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_return_buffer
#endif
_dbus_message_loader_return_buffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_return_unix_fds
  .p2align 4
  .type _dbus_message_loader_return_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_return_unix_fds
#endif
_dbus_message_loader_return_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_loader_unref
  .p2align 4
  .type _dbus_message_loader_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_unref
#endif
_dbus_message_loader_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_message_remove_unknown_fields
  .p2align 4
  .type _dbus_message_remove_unknown_fields, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_remove_unknown_fields
#endif
_dbus_message_remove_unknown_fields:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pending_call_new_unlocked
  .p2align 4
  .type _dbus_pending_call_new_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_new_unlocked
#endif
_dbus_pending_call_new_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pending_call_ref_unlocked
  .p2align 4
  .type _dbus_pending_call_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_ref_unlocked
#endif
_dbus_pending_call_ref_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pending_call_unref_and_unlock
  .p2align 4
  .type _dbus_pending_call_unref_and_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_unref_and_unlock
#endif
_dbus_pending_call_unref_and_unlock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_close
  .p2align 4
  .type _dbus_pipe_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_close
#endif
_dbus_pipe_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_init
  .p2align 4
  .type _dbus_pipe_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_init
#endif
_dbus_pipe_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_init_stdout
  .p2align 4
  .type _dbus_pipe_init_stdout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_init_stdout
#endif
_dbus_pipe_init_stdout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_invalidate
  .p2align 4
  .type _dbus_pipe_invalidate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_invalidate
#endif
_dbus_pipe_invalidate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_is_stdout_or_stderr
  .p2align 4
  .type _dbus_pipe_is_stdout_or_stderr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_is_stdout_or_stderr
#endif
_dbus_pipe_is_stdout_or_stderr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_is_valid
  .p2align 4
  .type _dbus_pipe_is_valid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_is_valid
#endif
_dbus_pipe_is_valid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_pipe_write
  .p2align 4
  .type _dbus_pipe_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_write
#endif
_dbus_pipe_write:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_poll
  .p2align 4
  .type _dbus_poll, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_poll
#endif
_dbus_poll:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_print_backtrace
  .p2align 4
  .type _dbus_print_backtrace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_print_backtrace
#endif
_dbus_print_backtrace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_printf_string_upper_bound
  .p2align 4
  .type _dbus_printf_string_upper_bound, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_printf_string_upper_bound
#endif
_dbus_printf_string_upper_bound:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_read
  .p2align 4
  .type _dbus_read, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read
#endif
_dbus_read:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_read_local_machine_uuid
  .p2align 4
  .type _dbus_read_local_machine_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read_local_machine_uuid
#endif
_dbus_read_local_machine_uuid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_read_socket
  .p2align 4
  .type _dbus_read_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read_socket
#endif
_dbus_read_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_register_shutdown_func
  .p2align 4
  .type _dbus_register_shutdown_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_register_shutdown_func
#endif
_dbus_register_shutdown_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_resolve_pid_fd
  .p2align 4
  .type _dbus_resolve_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_resolve_pid_fd
#endif
_dbus_resolve_pid_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_rmutex_lock
  .p2align 4
  .type _dbus_rmutex_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_rmutex_lock
#endif
_dbus_rmutex_lock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_rmutex_unlock
  .p2align 4
  .type _dbus_rmutex_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_rmutex_unlock
#endif
_dbus_rmutex_unlock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_server_new_for_tcp_socket
  .p2align 4
  .type _dbus_server_new_for_tcp_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_new_for_tcp_socket
#endif
_dbus_server_new_for_tcp_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_server_ref_unlocked
  .p2align 4
  .type _dbus_server_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_ref_unlocked
#endif
_dbus_server_ref_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_server_toggle_all_watches
  .p2align 4
  .type _dbus_server_toggle_all_watches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_toggle_all_watches
#endif
_dbus_server_toggle_all_watches:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_server_unref_unlocked
  .p2align 4
  .type _dbus_server_unref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_unref_unlocked
#endif
_dbus_server_unref_unlocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_set_error_valist
  .p2align 4
  .type _dbus_set_error_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_set_error_valist
#endif
_dbus_set_error_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_sleep_milliseconds
  .p2align 4
  .type _dbus_sleep_milliseconds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_sleep_milliseconds
#endif
_dbus_sleep_milliseconds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_socketpair
  .p2align 4
  .type _dbus_socketpair, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_socketpair
#endif
_dbus_socketpair:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_split_paths_and_append
  .p2align 4
  .type _dbus_split_paths_and_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_split_paths_and_append
#endif
_dbus_split_paths_and_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_strdup
  .p2align 4
  .type _dbus_strdup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strdup
#endif
_dbus_strdup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_strerror
  .p2align 4
  .type _dbus_strerror, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strerror
#endif
_dbus_strerror:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_strerror_from_errno
  .p2align 4
  .type _dbus_strerror_from_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strerror_from_errno
#endif
_dbus_strerror_from_errno:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append
  .p2align 4
  .type _dbus_string_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append
#endif
_dbus_string_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append_byte
  .p2align 4
  .type _dbus_string_append_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_byte
#endif
_dbus_string_append_byte:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append_len
  .p2align 4
  .type _dbus_string_append_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_len
#endif
_dbus_string_append_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append_printf
  .p2align 4
  .type _dbus_string_append_printf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_printf
#endif
_dbus_string_append_printf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append_printf_valist
  .p2align 4
  .type _dbus_string_append_printf_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_printf_valist
#endif
_dbus_string_append_printf_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_append_strings
  .p2align 4
  .type _dbus_string_append_strings, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_strings
#endif
_dbus_string_append_strings:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_array_contains
  .p2align 4
  .type _dbus_string_array_contains, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_array_contains
#endif
_dbus_string_array_contains:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_array_length
  .p2align 4
  .type _dbus_string_array_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_array_length
#endif
_dbus_string_array_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_chop_white
  .p2align 4
  .type _dbus_string_chop_white, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_chop_white
#endif
_dbus_string_chop_white:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_compact
  .p2align 4
  .type _dbus_string_compact, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_compact
#endif
_dbus_string_compact:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_copy
  .p2align 4
  .type _dbus_string_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy
#endif
_dbus_string_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_copy_data
  .p2align 4
  .type _dbus_string_copy_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_data
#endif
_dbus_string_copy_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_copy_len
  .p2align 4
  .type _dbus_string_copy_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_len
#endif
_dbus_string_copy_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_copy_to_buffer_with_nul
  .p2align 4
  .type _dbus_string_copy_to_buffer_with_nul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_to_buffer_with_nul
#endif
_dbus_string_copy_to_buffer_with_nul:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_delete
  .p2align 4
  .type _dbus_string_delete, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_delete
#endif
_dbus_string_delete:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_equal
  .p2align 4
  .type _dbus_string_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal
#endif
_dbus_string_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_equal_c_str
  .p2align 4
  .type _dbus_string_equal_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_c_str
#endif
_dbus_string_equal_c_str:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_equal_len
  .p2align 4
  .type _dbus_string_equal_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_len
#endif
_dbus_string_equal_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_equal_substring
  .p2align 4
  .type _dbus_string_equal_substring, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_substring
#endif
_dbus_string_equal_substring:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_find
  .p2align 4
  .type _dbus_string_find, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find
#endif
_dbus_string_find:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_find_blank
  .p2align 4
  .type _dbus_string_find_blank, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_blank
#endif
_dbus_string_find_blank:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_find_eol
  .p2align 4
  .type _dbus_string_find_eol, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_eol
#endif
_dbus_string_find_eol:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_find_to
  .p2align 4
  .type _dbus_string_find_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_to
#endif
_dbus_string_find_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_free
  .p2align 4
  .type _dbus_string_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_free
#endif
_dbus_string_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_get_allocated_size
  .p2align 4
  .type _dbus_string_get_allocated_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_get_allocated_size
#endif
_dbus_string_get_allocated_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_get_data_len
  .p2align 4
  .type _dbus_string_get_data_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_get_data_len
#endif
_dbus_string_get_data_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_hex_decode
  .p2align 4
  .type _dbus_string_hex_decode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_hex_decode
#endif
_dbus_string_hex_decode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_hex_encode
  .p2align 4
  .type _dbus_string_hex_encode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_hex_encode
#endif
_dbus_string_hex_encode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_init
  .p2align 4
  .type _dbus_string_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init
#endif
_dbus_string_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_init_const
  .p2align 4
  .type _dbus_string_init_const, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_const
#endif
_dbus_string_init_const:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_init_const_len
  .p2align 4
  .type _dbus_string_init_const_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_const_len
#endif
_dbus_string_init_const_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_init_from_string
  .p2align 4
  .type _dbus_string_init_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_from_string
#endif
_dbus_string_init_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_init_preallocated
  .p2align 4
  .type _dbus_string_init_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_preallocated
#endif
_dbus_string_init_preallocated:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_insert_8_aligned
  .p2align 4
  .type _dbus_string_insert_8_aligned, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_8_aligned
#endif
_dbus_string_insert_8_aligned:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_insert_byte
  .p2align 4
  .type _dbus_string_insert_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_byte
#endif
_dbus_string_insert_byte:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_insert_bytes
  .p2align 4
  .type _dbus_string_insert_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_bytes
#endif
_dbus_string_insert_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_lengthen
  .p2align 4
  .type _dbus_string_lengthen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_lengthen
#endif
_dbus_string_lengthen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_move
  .p2align 4
  .type _dbus_string_move, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_move
#endif
_dbus_string_move:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_parse_int
  .p2align 4
  .type _dbus_string_parse_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_int
#endif
_dbus_string_parse_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_parse_int64
  .p2align 4
  .type _dbus_string_parse_int64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_int64
#endif
_dbus_string_parse_int64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_parse_uint
  .p2align 4
  .type _dbus_string_parse_uint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_uint
#endif
_dbus_string_parse_uint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_pop_line
  .p2align 4
  .type _dbus_string_pop_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_pop_line
#endif
_dbus_string_pop_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_replace_len
  .p2align 4
  .type _dbus_string_replace_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_replace_len
#endif
_dbus_string_replace_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_set_length
  .p2align 4
  .type _dbus_string_set_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_set_length
#endif
_dbus_string_set_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_shorten
  .p2align 4
  .type _dbus_string_shorten, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_shorten
#endif
_dbus_string_shorten:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_skip_blank
  .p2align 4
  .type _dbus_string_skip_blank, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_skip_blank
#endif
_dbus_string_skip_blank:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_skip_white
  .p2align 4
  .type _dbus_string_skip_white, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_skip_white
#endif
_dbus_string_skip_white:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_split_on_byte
  .p2align 4
  .type _dbus_string_split_on_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_split_on_byte
#endif
_dbus_string_split_on_byte:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_starts_with_c_str
  .p2align 4
  .type _dbus_string_starts_with_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_starts_with_c_str
#endif
_dbus_string_starts_with_c_str:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_starts_with_words_c_str
  .p2align 4
  .type _dbus_string_starts_with_words_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_starts_with_words_c_str
#endif
_dbus_string_starts_with_words_c_str:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_steal_data
  .p2align 4
  .type _dbus_string_steal_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_steal_data
#endif
_dbus_string_steal_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_tolower_ascii
  .p2align 4
  .type _dbus_string_tolower_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_tolower_ascii
#endif
_dbus_string_tolower_ascii:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_toupper_ascii
  .p2align 4
  .type _dbus_string_toupper_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_toupper_ascii
#endif
_dbus_string_toupper_ascii:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_validate_nul
  .p2align 4
  .type _dbus_string_validate_nul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_validate_nul
#endif
_dbus_string_validate_nul:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_string_validate_utf8
  .p2align 4
  .type _dbus_string_validate_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_validate_utf8
#endif
_dbus_string_validate_utf8:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_disable
  .p2align 4
  .type _dbus_timeout_disable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_disable
#endif
_dbus_timeout_disable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_needs_restart
  .p2align 4
  .type _dbus_timeout_needs_restart, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_needs_restart
#endif
_dbus_timeout_needs_restart:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_new
  .p2align 4
  .type _dbus_timeout_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_new
#endif
_dbus_timeout_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_restart
  .p2align 4
  .type _dbus_timeout_restart, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_restart
#endif
_dbus_timeout_restart:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_restarted
  .p2align 4
  .type _dbus_timeout_restarted, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_restarted
#endif
_dbus_timeout_restarted:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_timeout_unref
  .p2align 4
  .type _dbus_timeout_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_unref
#endif
_dbus_timeout_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_delete
  .p2align 4
  .type _dbus_type_reader_delete, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_delete
#endif
_dbus_type_reader_delete:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_get_current_type
  .p2align 4
  .type _dbus_type_reader_get_current_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_current_type
#endif
_dbus_type_reader_get_current_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_get_element_type
  .p2align 4
  .type _dbus_type_reader_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_element_type
#endif
_dbus_type_reader_get_element_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_get_signature
  .p2align 4
  .type _dbus_type_reader_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_signature
#endif
_dbus_type_reader_get_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_get_value_pos
  .p2align 4
  .type _dbus_type_reader_get_value_pos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_value_pos
#endif
_dbus_type_reader_get_value_pos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_init
  .p2align 4
  .type _dbus_type_reader_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_init
#endif
_dbus_type_reader_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_init_types_only
  .p2align 4
  .type _dbus_type_reader_init_types_only, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_init_types_only
#endif
_dbus_type_reader_init_types_only:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_next
  .p2align 4
  .type _dbus_type_reader_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_next
#endif
_dbus_type_reader_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_read_basic
  .p2align 4
  .type _dbus_type_reader_read_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_read_basic
#endif
_dbus_type_reader_read_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_read_fixed_multi
  .p2align 4
  .type _dbus_type_reader_read_fixed_multi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_read_fixed_multi
#endif
_dbus_type_reader_read_fixed_multi:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_recurse
  .p2align 4
  .type _dbus_type_reader_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_recurse
#endif
_dbus_type_reader_recurse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_reader_set_basic
  .p2align 4
  .type _dbus_type_reader_set_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_set_basic
#endif
_dbus_type_reader_set_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_to_string
  .p2align 4
  .type _dbus_type_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_to_string
#endif
_dbus_type_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_init
  .p2align 4
  .type _dbus_type_writer_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_init
#endif
_dbus_type_writer_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_init_values_only
  .p2align 4
  .type _dbus_type_writer_init_values_only, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_init_values_only
#endif
_dbus_type_writer_init_values_only:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_recurse
  .p2align 4
  .type _dbus_type_writer_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_recurse
#endif
_dbus_type_writer_recurse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_unrecurse
  .p2align 4
  .type _dbus_type_writer_unrecurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_unrecurse
#endif
_dbus_type_writer_unrecurse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_write_basic
  .p2align 4
  .type _dbus_type_writer_write_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_basic
#endif
_dbus_type_writer_write_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_write_fixed_multi
  .p2align 4
  .type _dbus_type_writer_write_fixed_multi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_fixed_multi
#endif
_dbus_type_writer_write_fixed_multi:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_type_writer_write_reader
  .p2align 4
  .type _dbus_type_writer_write_reader, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_reader
#endif
_dbus_type_writer_write_reader:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_get_system
  .p2align 4
  .type _dbus_user_database_get_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_system
#endif
_dbus_user_database_get_system:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_get_uid
  .p2align 4
  .type _dbus_user_database_get_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_uid
#endif
_dbus_user_database_get_uid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_get_username
  .p2align 4
  .type _dbus_user_database_get_username, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_username
#endif
_dbus_user_database_get_username:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_lock_system
  .p2align 4
  .type _dbus_user_database_lock_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_lock_system
#endif
_dbus_user_database_lock_system:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_lookup
  .p2align 4
  .type _dbus_user_database_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_lookup
#endif
_dbus_user_database_lookup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_user_database_unlock_system
  .p2align 4
  .type _dbus_user_database_unlock_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_unlock_system
#endif
_dbus_user_database_unlock_system:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_username_from_current_process
  .p2align 4
  .type _dbus_username_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_username_from_current_process
#endif
_dbus_username_from_current_process:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_uuid_encode
  .p2align 4
  .type _dbus_uuid_encode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_uuid_encode
#endif
_dbus_uuid_encode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_body_with_reason
  .p2align 4
  .type _dbus_validate_body_with_reason, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_body_with_reason
#endif
_dbus_validate_body_with_reason:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_bus_name
  .p2align 4
  .type _dbus_validate_bus_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_bus_name
#endif
_dbus_validate_bus_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_bus_namespace
  .p2align 4
  .type _dbus_validate_bus_namespace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_bus_namespace
#endif
_dbus_validate_bus_namespace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_error_name
  .p2align 4
  .type _dbus_validate_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_error_name
#endif
_dbus_validate_error_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_interface
  .p2align 4
  .type _dbus_validate_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_interface
#endif
_dbus_validate_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_member
  .p2align 4
  .type _dbus_validate_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_member
#endif
_dbus_validate_member:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_path
  .p2align 4
  .type _dbus_validate_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_path
#endif
_dbus_validate_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_validate_signature_with_reason
  .p2align 4
  .type _dbus_validate_signature_with_reason, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_signature_with_reason
#endif
_dbus_validate_signature_with_reason:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_free
  .p2align 4
  .type _dbus_variant_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_free
#endif
_dbus_variant_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_get_length
  .p2align 4
  .type _dbus_variant_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_get_length
#endif
_dbus_variant_get_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_get_signature
  .p2align 4
  .type _dbus_variant_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_get_signature
#endif
_dbus_variant_get_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_peek
  .p2align 4
  .type _dbus_variant_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_peek
#endif
_dbus_variant_peek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_read
  .p2align 4
  .type _dbus_variant_read, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_read
#endif
_dbus_variant_read:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_variant_write
  .p2align 4
  .type _dbus_variant_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_write
#endif
_dbus_variant_write:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_verbose_bytes_of_string
  .p2align 4
  .type _dbus_verbose_bytes_of_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_verbose_bytes_of_string
#endif
_dbus_verbose_bytes_of_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_warn
  .p2align 4
  .type _dbus_warn, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn
#endif
_dbus_warn:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_warn_check_failed
  .p2align 4
  .type _dbus_warn_check_failed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn_check_failed
#endif
_dbus_warn_check_failed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_warn_return_if_fail
  .p2align 4
  .type _dbus_warn_return_if_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn_return_if_fail
#endif
_dbus_warn_return_if_fail:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_get_oom_last_time
  .p2align 4
  .type _dbus_watch_get_oom_last_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_get_oom_last_time
#endif
_dbus_watch_get_oom_last_time:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_get_pollable
  .p2align 4
  .type _dbus_watch_get_pollable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_get_pollable
#endif
_dbus_watch_get_pollable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_invalidate
  .p2align 4
  .type _dbus_watch_invalidate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_invalidate
#endif
_dbus_watch_invalidate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_list_add_watch
  .p2align 4
  .type _dbus_watch_list_add_watch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_add_watch
#endif
_dbus_watch_list_add_watch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_list_free
  .p2align 4
  .type _dbus_watch_list_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_free
#endif
_dbus_watch_list_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_list_new
  .p2align 4
  .type _dbus_watch_list_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_new
#endif
_dbus_watch_list_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_list_remove_watch
  .p2align 4
  .type _dbus_watch_list_remove_watch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_remove_watch
#endif
_dbus_watch_list_remove_watch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_list_set_functions
  .p2align 4
  .type _dbus_watch_list_set_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_set_functions
#endif
_dbus_watch_list_set_functions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_new
  .p2align 4
  .type _dbus_watch_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_new
#endif
_dbus_watch_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_ref
  .p2align 4
  .type _dbus_watch_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_ref
#endif
_dbus_watch_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_set_oom_last_time
  .p2align 4
  .type _dbus_watch_set_oom_last_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_set_oom_last_time
#endif
_dbus_watch_set_oom_last_time:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_watch_unref
  .p2align 4
  .type _dbus_watch_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_unref
#endif
_dbus_watch_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_write_socket
  .p2align 4
  .type _dbus_write_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_write_socket
#endif
_dbus_write_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl _dbus_write_socket_with_unix_fds
  .p2align 4
  .type _dbus_write_socket_with_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_write_socket_with_unix_fds
#endif
_dbus_write_socket_with_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_address_entries_free
  .p2align 4
  .type dbus_address_entries_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entries_free
#endif
dbus_address_entries_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_address_entry_get_method
  .p2align 4
  .type dbus_address_entry_get_method, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entry_get_method
#endif
dbus_address_entry_get_method:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_address_entry_get_value
  .p2align 4
  .type dbus_address_entry_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entry_get_value
#endif
dbus_address_entry_get_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_address_escape_value
  .p2align 4
  .type dbus_address_escape_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_escape_value
#endif
dbus_address_escape_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_address_unescape_value
  .p2align 4
  .type dbus_address_unescape_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_unescape_value
#endif
dbus_address_unescape_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_add_match
  .p2align 4
  .type dbus_bus_add_match, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_add_match
#endif
dbus_bus_add_match:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_get
  .p2align 4
  .type dbus_bus_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get
#endif
dbus_bus_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_get_id
  .p2align 4
  .type dbus_bus_get_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_id
#endif
dbus_bus_get_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_get_private
  .p2align 4
  .type dbus_bus_get_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_private
#endif
dbus_bus_get_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_get_unique_name
  .p2align 4
  .type dbus_bus_get_unique_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_unique_name
#endif
dbus_bus_get_unique_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_get_unix_user
  .p2align 4
  .type dbus_bus_get_unix_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_unix_user
#endif
dbus_bus_get_unix_user:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_name_has_owner
  .p2align 4
  .type dbus_bus_name_has_owner, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_name_has_owner
#endif
dbus_bus_name_has_owner:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_register
  .p2align 4
  .type dbus_bus_register, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_register
#endif
dbus_bus_register:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_release_name
  .p2align 4
  .type dbus_bus_release_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_release_name
#endif
dbus_bus_release_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_remove_match
  .p2align 4
  .type dbus_bus_remove_match, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_remove_match
#endif
dbus_bus_remove_match:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_request_name
  .p2align 4
  .type dbus_bus_request_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_request_name
#endif
dbus_bus_request_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_set_unique_name
  .p2align 4
  .type dbus_bus_set_unique_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_set_unique_name
#endif
dbus_bus_set_unique_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_bus_start_service_by_name
  .p2align 4
  .type dbus_bus_start_service_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_start_service_by_name
#endif
dbus_bus_start_service_by_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_add_filter
  .p2align 4
  .type dbus_connection_add_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_add_filter
#endif
dbus_connection_add_filter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_allocate_data_slot
  .p2align 4
  .type dbus_connection_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_allocate_data_slot
#endif
dbus_connection_allocate_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_borrow_message
  .p2align 4
  .type dbus_connection_borrow_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_borrow_message
#endif
dbus_connection_borrow_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_can_send_type
  .p2align 4
  .type dbus_connection_can_send_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_can_send_type
#endif
dbus_connection_can_send_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_close
  .p2align 4
  .type dbus_connection_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_close
#endif
dbus_connection_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_dispatch
  .p2align 4
  .type dbus_connection_dispatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_dispatch
#endif
dbus_connection_dispatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_flush
  .p2align 4
  .type dbus_connection_flush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_flush
#endif
dbus_connection_flush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_free_data_slot
  .p2align 4
  .type dbus_connection_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_free_data_slot
#endif
dbus_connection_free_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_free_preallocated_send
  .p2align 4
  .type dbus_connection_free_preallocated_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_free_preallocated_send
#endif
dbus_connection_free_preallocated_send:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_adt_audit_session_data
  .p2align 4
  .type dbus_connection_get_adt_audit_session_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_adt_audit_session_data
#endif
dbus_connection_get_adt_audit_session_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_data
  .p2align 4
  .type dbus_connection_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_data
#endif
dbus_connection_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_dispatch_status
  .p2align 4
  .type dbus_connection_get_dispatch_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_dispatch_status
#endif
dbus_connection_get_dispatch_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_is_anonymous
  .p2align 4
  .type dbus_connection_get_is_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_anonymous
#endif
dbus_connection_get_is_anonymous:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_is_authenticated
  .p2align 4
  .type dbus_connection_get_is_authenticated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_authenticated
#endif
dbus_connection_get_is_authenticated:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_is_connected
  .p2align 4
  .type dbus_connection_get_is_connected, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_connected
#endif
dbus_connection_get_is_connected:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_max_message_size
  .p2align 4
  .type dbus_connection_get_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_message_size
#endif
dbus_connection_get_max_message_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_max_message_unix_fds
  .p2align 4
  .type dbus_connection_get_max_message_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_message_unix_fds
#endif
dbus_connection_get_max_message_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_max_received_size
  .p2align 4
  .type dbus_connection_get_max_received_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_received_size
#endif
dbus_connection_get_max_received_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_max_received_unix_fds
  .p2align 4
  .type dbus_connection_get_max_received_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_received_unix_fds
#endif
dbus_connection_get_max_received_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_object_path_data
  .p2align 4
  .type dbus_connection_get_object_path_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_object_path_data
#endif
dbus_connection_get_object_path_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_outgoing_size
  .p2align 4
  .type dbus_connection_get_outgoing_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_outgoing_size
#endif
dbus_connection_get_outgoing_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_outgoing_unix_fds
  .p2align 4
  .type dbus_connection_get_outgoing_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_outgoing_unix_fds
#endif
dbus_connection_get_outgoing_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_server_id
  .p2align 4
  .type dbus_connection_get_server_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_server_id
#endif
dbus_connection_get_server_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_socket
  .p2align 4
  .type dbus_connection_get_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_socket
#endif
dbus_connection_get_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_unix_fd
  .p2align 4
  .type dbus_connection_get_unix_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_fd
#endif
dbus_connection_get_unix_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_unix_process_id
  .p2align 4
  .type dbus_connection_get_unix_process_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_process_id
#endif
dbus_connection_get_unix_process_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_unix_user
  .p2align 4
  .type dbus_connection_get_unix_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_user
#endif
dbus_connection_get_unix_user:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_get_windows_user
  .p2align 4
  .type dbus_connection_get_windows_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_windows_user
#endif
dbus_connection_get_windows_user:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_has_messages_to_send
  .p2align 4
  .type dbus_connection_has_messages_to_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_has_messages_to_send
#endif
dbus_connection_has_messages_to_send:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_list_registered
  .p2align 4
  .type dbus_connection_list_registered, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_list_registered
#endif
dbus_connection_list_registered:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_open
  .p2align 4
  .type dbus_connection_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_open
#endif
dbus_connection_open:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_open_private
  .p2align 4
  .type dbus_connection_open_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_open_private
#endif
dbus_connection_open_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_pop_message
  .p2align 4
  .type dbus_connection_pop_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_pop_message
#endif
dbus_connection_pop_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_preallocate_send
  .p2align 4
  .type dbus_connection_preallocate_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_preallocate_send
#endif
dbus_connection_preallocate_send:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_read_write
  .p2align 4
  .type dbus_connection_read_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_read_write
#endif
dbus_connection_read_write:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_read_write_dispatch
  .p2align 4
  .type dbus_connection_read_write_dispatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_read_write_dispatch
#endif
dbus_connection_read_write_dispatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_ref
  .p2align 4
  .type dbus_connection_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_ref
#endif
dbus_connection_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_register_fallback
  .p2align 4
  .type dbus_connection_register_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_register_fallback
#endif
dbus_connection_register_fallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_register_object_path
  .p2align 4
  .type dbus_connection_register_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_register_object_path
#endif
dbus_connection_register_object_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_remove_filter
  .p2align 4
  .type dbus_connection_remove_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_remove_filter
#endif
dbus_connection_remove_filter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_return_message
  .p2align 4
  .type dbus_connection_return_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_return_message
#endif
dbus_connection_return_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_send
  .p2align 4
  .type dbus_connection_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send
#endif
dbus_connection_send:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_send_preallocated
  .p2align 4
  .type dbus_connection_send_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_preallocated
#endif
dbus_connection_send_preallocated:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_send_with_reply
  .p2align 4
  .type dbus_connection_send_with_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_with_reply
#endif
dbus_connection_send_with_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_send_with_reply_and_block
  .p2align 4
  .type dbus_connection_send_with_reply_and_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_with_reply_and_block
#endif
dbus_connection_send_with_reply_and_block:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_allow_anonymous
  .p2align 4
  .type dbus_connection_set_allow_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_allow_anonymous
#endif
dbus_connection_set_allow_anonymous:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_builtin_filters_enabled
  .p2align 4
  .type dbus_connection_set_builtin_filters_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_builtin_filters_enabled
#endif
dbus_connection_set_builtin_filters_enabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_change_sigpipe
  .p2align 4
  .type dbus_connection_set_change_sigpipe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_change_sigpipe
#endif
dbus_connection_set_change_sigpipe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_data
  .p2align 4
  .type dbus_connection_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_data
#endif
dbus_connection_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_dispatch_status_function
  .p2align 4
  .type dbus_connection_set_dispatch_status_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_dispatch_status_function
#endif
dbus_connection_set_dispatch_status_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_exit_on_disconnect
  .p2align 4
  .type dbus_connection_set_exit_on_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_exit_on_disconnect
#endif
dbus_connection_set_exit_on_disconnect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_max_message_size
  .p2align 4
  .type dbus_connection_set_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_message_size
#endif
dbus_connection_set_max_message_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_max_message_unix_fds
  .p2align 4
  .type dbus_connection_set_max_message_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_message_unix_fds
#endif
dbus_connection_set_max_message_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_max_received_size
  .p2align 4
  .type dbus_connection_set_max_received_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_received_size
#endif
dbus_connection_set_max_received_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_max_received_unix_fds
  .p2align 4
  .type dbus_connection_set_max_received_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_received_unix_fds
#endif
dbus_connection_set_max_received_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_route_peer_messages
  .p2align 4
  .type dbus_connection_set_route_peer_messages, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_route_peer_messages
#endif
dbus_connection_set_route_peer_messages:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_timeout_functions
  .p2align 4
  .type dbus_connection_set_timeout_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_timeout_functions
#endif
dbus_connection_set_timeout_functions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_unix_user_function
  .p2align 4
  .type dbus_connection_set_unix_user_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_unix_user_function
#endif
dbus_connection_set_unix_user_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_wakeup_main_function
  .p2align 4
  .type dbus_connection_set_wakeup_main_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_wakeup_main_function
#endif
dbus_connection_set_wakeup_main_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_watch_functions
  .p2align 4
  .type dbus_connection_set_watch_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_watch_functions
#endif
dbus_connection_set_watch_functions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_set_windows_user_function
  .p2align 4
  .type dbus_connection_set_windows_user_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_windows_user_function
#endif
dbus_connection_set_windows_user_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_steal_borrowed_message
  .p2align 4
  .type dbus_connection_steal_borrowed_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_steal_borrowed_message
#endif
dbus_connection_steal_borrowed_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_try_register_fallback
  .p2align 4
  .type dbus_connection_try_register_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_try_register_fallback
#endif
dbus_connection_try_register_fallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_try_register_object_path
  .p2align 4
  .type dbus_connection_try_register_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_try_register_object_path
#endif
dbus_connection_try_register_object_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_unref
  .p2align 4
  .type dbus_connection_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_unref
#endif
dbus_connection_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_connection_unregister_object_path
  .p2align 4
  .type dbus_connection_unregister_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_unregister_object_path
#endif
dbus_connection_unregister_object_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_error_free
  .p2align 4
  .type dbus_error_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_free
#endif
dbus_error_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_error_has_name
  .p2align 4
  .type dbus_error_has_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_has_name
#endif
dbus_error_has_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_error_init
  .p2align 4
  .type dbus_error_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_init
#endif
dbus_error_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_error_is_set
  .p2align 4
  .type dbus_error_is_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_is_set
#endif
dbus_error_is_set:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_free
  .p2align 4
  .type dbus_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_free
#endif
dbus_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_free_string_array
  .p2align 4
  .type dbus_free_string_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_free_string_array
#endif
dbus_free_string_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_get_local_machine_id
  .p2align 4
  .type dbus_get_local_machine_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_get_local_machine_id
#endif
dbus_get_local_machine_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_get_version
  .p2align 4
  .type dbus_get_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_get_version
#endif
dbus_get_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_malloc
  .p2align 4
  .type dbus_malloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_malloc
#endif
dbus_malloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_malloc0
  .p2align 4
  .type dbus_malloc0, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_malloc0
#endif
dbus_malloc0:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_allocate_data_slot
  .p2align 4
  .type dbus_message_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_allocate_data_slot
#endif
dbus_message_allocate_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_append_args
  .p2align 4
  .type dbus_message_append_args, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_append_args
#endif
dbus_message_append_args:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_append_args_valist
  .p2align 4
  .type dbus_message_append_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_append_args_valist
#endif
dbus_message_append_args_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_contains_unix_fds
  .p2align 4
  .type dbus_message_contains_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_contains_unix_fds
#endif
dbus_message_contains_unix_fds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_copy
  .p2align 4
  .type dbus_message_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_copy
#endif
dbus_message_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_demarshal
  .p2align 4
  .type dbus_message_demarshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_demarshal
#endif
dbus_message_demarshal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_demarshal_bytes_needed
  .p2align 4
  .type dbus_message_demarshal_bytes_needed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_demarshal_bytes_needed
#endif
dbus_message_demarshal_bytes_needed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_free_data_slot
  .p2align 4
  .type dbus_message_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_free_data_slot
#endif
dbus_message_free_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_allow_interactive_authorization
  .p2align 4
  .type dbus_message_get_allow_interactive_authorization, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_allow_interactive_authorization
#endif
dbus_message_get_allow_interactive_authorization:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_args
  .p2align 4
  .type dbus_message_get_args, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_args
#endif
dbus_message_get_args:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_args_valist
  .p2align 4
  .type dbus_message_get_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_args_valist
#endif
dbus_message_get_args_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_auto_start
  .p2align 4
  .type dbus_message_get_auto_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_auto_start
#endif
dbus_message_get_auto_start:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_container_instance
  .p2align 4
  .type dbus_message_get_container_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_container_instance
#endif
dbus_message_get_container_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_data
  .p2align 4
  .type dbus_message_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_data
#endif
dbus_message_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_destination
  .p2align 4
  .type dbus_message_get_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_destination
#endif
dbus_message_get_destination:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_error_name
  .p2align 4
  .type dbus_message_get_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_error_name
#endif
dbus_message_get_error_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_interface
  .p2align 4
  .type dbus_message_get_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_interface
#endif
dbus_message_get_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_member
  .p2align 4
  .type dbus_message_get_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_member
#endif
dbus_message_get_member:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_no_reply
  .p2align 4
  .type dbus_message_get_no_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_no_reply
#endif
dbus_message_get_no_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_path
  .p2align 4
  .type dbus_message_get_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_path
#endif
dbus_message_get_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_path_decomposed
  .p2align 4
  .type dbus_message_get_path_decomposed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_path_decomposed
#endif
dbus_message_get_path_decomposed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_reply_serial
  .p2align 4
  .type dbus_message_get_reply_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_reply_serial
#endif
dbus_message_get_reply_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_sender
  .p2align 4
  .type dbus_message_get_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_sender
#endif
dbus_message_get_sender:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_serial
  .p2align 4
  .type dbus_message_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_serial
#endif
dbus_message_get_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_signature
  .p2align 4
  .type dbus_message_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_signature
#endif
dbus_message_get_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_get_type
  .p2align 4
  .type dbus_message_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_type
#endif
dbus_message_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_destination
  .p2align 4
  .type dbus_message_has_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_destination
#endif
dbus_message_has_destination:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3592(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3592(%rip)
2:
  pushq $449
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_interface
  .p2align 4
  .type dbus_message_has_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_interface
#endif
dbus_message_has_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3600(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3600(%rip)
2:
  pushq $450
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_member
  .p2align 4
  .type dbus_message_has_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_member
#endif
dbus_message_has_member:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3608(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3608(%rip)
2:
  pushq $451
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_path
  .p2align 4
  .type dbus_message_has_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_path
#endif
dbus_message_has_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3616(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3616(%rip)
2:
  pushq $452
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_sender
  .p2align 4
  .type dbus_message_has_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_sender
#endif
dbus_message_has_sender:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3624(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3624(%rip)
2:
  pushq $453
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_has_signature
  .p2align 4
  .type dbus_message_has_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_signature
#endif
dbus_message_has_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3632(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3632(%rip)
2:
  pushq $454
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_is_error
  .p2align 4
  .type dbus_message_is_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_error
#endif
dbus_message_is_error:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3640(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3640(%rip)
2:
  pushq $455
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_is_method_call
  .p2align 4
  .type dbus_message_is_method_call, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_method_call
#endif
dbus_message_is_method_call:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3648(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3648(%rip)
2:
  pushq $456
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_is_signal
  .p2align 4
  .type dbus_message_is_signal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_signal
#endif
dbus_message_is_signal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3656(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3656(%rip)
2:
  pushq $457
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_abandon_container
  .p2align 4
  .type dbus_message_iter_abandon_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_abandon_container
#endif
dbus_message_iter_abandon_container:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3664(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3664(%rip)
2:
  pushq $458
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_abandon_container_if_open
  .p2align 4
  .type dbus_message_iter_abandon_container_if_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_abandon_container_if_open
#endif
dbus_message_iter_abandon_container_if_open:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3672(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3672(%rip)
2:
  pushq $459
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_append_basic
  .p2align 4
  .type dbus_message_iter_append_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_append_basic
#endif
dbus_message_iter_append_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3680(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3680(%rip)
2:
  pushq $460
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_append_fixed_array
  .p2align 4
  .type dbus_message_iter_append_fixed_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_append_fixed_array
#endif
dbus_message_iter_append_fixed_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3688(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3688(%rip)
2:
  pushq $461
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_close_container
  .p2align 4
  .type dbus_message_iter_close_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_close_container
#endif
dbus_message_iter_close_container:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3696(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3696(%rip)
2:
  pushq $462
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_arg_type
  .p2align 4
  .type dbus_message_iter_get_arg_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_arg_type
#endif
dbus_message_iter_get_arg_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3704(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3704(%rip)
2:
  pushq $463
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_array_len
  .p2align 4
  .type dbus_message_iter_get_array_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_array_len
#endif
dbus_message_iter_get_array_len:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3712(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3712(%rip)
2:
  pushq $464
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_basic
  .p2align 4
  .type dbus_message_iter_get_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_basic
#endif
dbus_message_iter_get_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3720(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3720(%rip)
2:
  pushq $465
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_element_count
  .p2align 4
  .type dbus_message_iter_get_element_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_element_count
#endif
dbus_message_iter_get_element_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3728(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3728(%rip)
2:
  pushq $466
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_element_type
  .p2align 4
  .type dbus_message_iter_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_element_type
#endif
dbus_message_iter_get_element_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3736(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3736(%rip)
2:
  pushq $467
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_fixed_array
  .p2align 4
  .type dbus_message_iter_get_fixed_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_fixed_array
#endif
dbus_message_iter_get_fixed_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3744(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3744(%rip)
2:
  pushq $468
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_get_signature
  .p2align 4
  .type dbus_message_iter_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_signature
#endif
dbus_message_iter_get_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3752(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3752(%rip)
2:
  pushq $469
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_has_next
  .p2align 4
  .type dbus_message_iter_has_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_has_next
#endif
dbus_message_iter_has_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3760(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3760(%rip)
2:
  pushq $470
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_init
  .p2align 4
  .type dbus_message_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init
#endif
dbus_message_iter_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3768(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3768(%rip)
2:
  pushq $471
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_init_append
  .p2align 4
  .type dbus_message_iter_init_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init_append
#endif
dbus_message_iter_init_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3776(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3776(%rip)
2:
  pushq $472
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_init_closed
  .p2align 4
  .type dbus_message_iter_init_closed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init_closed
#endif
dbus_message_iter_init_closed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3784(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3784(%rip)
2:
  pushq $473
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_next
  .p2align 4
  .type dbus_message_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_next
#endif
dbus_message_iter_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3792(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3792(%rip)
2:
  pushq $474
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_open_container
  .p2align 4
  .type dbus_message_iter_open_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_open_container
#endif
dbus_message_iter_open_container:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3800(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3800(%rip)
2:
  pushq $475
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_iter_recurse
  .p2align 4
  .type dbus_message_iter_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_recurse
#endif
dbus_message_iter_recurse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3808(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3808(%rip)
2:
  pushq $476
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_lock
  .p2align 4
  .type dbus_message_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_lock
#endif
dbus_message_lock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3816(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3816(%rip)
2:
  pushq $477
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_marshal
  .p2align 4
  .type dbus_message_marshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_marshal
#endif
dbus_message_marshal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3824(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3824(%rip)
2:
  pushq $478
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new
  .p2align 4
  .type dbus_message_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new
#endif
dbus_message_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3832(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3832(%rip)
2:
  pushq $479
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new_error
  .p2align 4
  .type dbus_message_new_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_error
#endif
dbus_message_new_error:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3840(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3840(%rip)
2:
  pushq $480
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new_error_printf
  .p2align 4
  .type dbus_message_new_error_printf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_error_printf
#endif
dbus_message_new_error_printf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3848(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3848(%rip)
2:
  pushq $481
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new_method_call
  .p2align 4
  .type dbus_message_new_method_call, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_method_call
#endif
dbus_message_new_method_call:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3856(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3856(%rip)
2:
  pushq $482
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new_method_return
  .p2align 4
  .type dbus_message_new_method_return, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_method_return
#endif
dbus_message_new_method_return:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3864(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3864(%rip)
2:
  pushq $483
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_new_signal
  .p2align 4
  .type dbus_message_new_signal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_signal
#endif
dbus_message_new_signal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3872(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3872(%rip)
2:
  pushq $484
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_ref
  .p2align 4
  .type dbus_message_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_ref
#endif
dbus_message_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3880(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3880(%rip)
2:
  pushq $485
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_allow_interactive_authorization
  .p2align 4
  .type dbus_message_set_allow_interactive_authorization, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_allow_interactive_authorization
#endif
dbus_message_set_allow_interactive_authorization:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3888(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3888(%rip)
2:
  pushq $486
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_auto_start
  .p2align 4
  .type dbus_message_set_auto_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_auto_start
#endif
dbus_message_set_auto_start:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3896(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3896(%rip)
2:
  pushq $487
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_container_instance
  .p2align 4
  .type dbus_message_set_container_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_container_instance
#endif
dbus_message_set_container_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3904(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3904(%rip)
2:
  pushq $488
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_data
  .p2align 4
  .type dbus_message_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_data
#endif
dbus_message_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3912(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3912(%rip)
2:
  pushq $489
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_destination
  .p2align 4
  .type dbus_message_set_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_destination
#endif
dbus_message_set_destination:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3920(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3920(%rip)
2:
  pushq $490
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_error_name
  .p2align 4
  .type dbus_message_set_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_error_name
#endif
dbus_message_set_error_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3928(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3928(%rip)
2:
  pushq $491
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_interface
  .p2align 4
  .type dbus_message_set_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_interface
#endif
dbus_message_set_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3936(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3936(%rip)
2:
  pushq $492
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_member
  .p2align 4
  .type dbus_message_set_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_member
#endif
dbus_message_set_member:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3944(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3944(%rip)
2:
  pushq $493
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_no_reply
  .p2align 4
  .type dbus_message_set_no_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_no_reply
#endif
dbus_message_set_no_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3952(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3952(%rip)
2:
  pushq $494
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_path
  .p2align 4
  .type dbus_message_set_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_path
#endif
dbus_message_set_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3960(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3960(%rip)
2:
  pushq $495
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_reply_serial
  .p2align 4
  .type dbus_message_set_reply_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_reply_serial
#endif
dbus_message_set_reply_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3968(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3968(%rip)
2:
  pushq $496
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_sender
  .p2align 4
  .type dbus_message_set_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_sender
#endif
dbus_message_set_sender:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3976(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3976(%rip)
2:
  pushq $497
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_set_serial
  .p2align 4
  .type dbus_message_set_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_serial
#endif
dbus_message_set_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3984(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3984(%rip)
2:
  pushq $498
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_type_from_string
  .p2align 4
  .type dbus_message_type_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_type_from_string
#endif
dbus_message_type_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+3992(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+3992(%rip)
2:
  pushq $499
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_type_to_string
  .p2align 4
  .type dbus_message_type_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_type_to_string
#endif
dbus_message_type_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4000(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4000(%rip)
2:
  pushq $500
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_message_unref
  .p2align 4
  .type dbus_message_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_unref
#endif
dbus_message_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4008(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4008(%rip)
2:
  pushq $501
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_move_error
  .p2align 4
  .type dbus_move_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_move_error
#endif
dbus_move_error:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4016(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4016(%rip)
2:
  pushq $502
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_parse_address
  .p2align 4
  .type dbus_parse_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_parse_address
#endif
dbus_parse_address:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4024(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4024(%rip)
2:
  pushq $503
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_allocate_data_slot
  .p2align 4
  .type dbus_pending_call_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_allocate_data_slot
#endif
dbus_pending_call_allocate_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4032(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4032(%rip)
2:
  pushq $504
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_block
  .p2align 4
  .type dbus_pending_call_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_block
#endif
dbus_pending_call_block:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4040(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4040(%rip)
2:
  pushq $505
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_cancel
  .p2align 4
  .type dbus_pending_call_cancel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_cancel
#endif
dbus_pending_call_cancel:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4048(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4048(%rip)
2:
  pushq $506
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_free_data_slot
  .p2align 4
  .type dbus_pending_call_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_free_data_slot
#endif
dbus_pending_call_free_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4056(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4056(%rip)
2:
  pushq $507
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_get_completed
  .p2align 4
  .type dbus_pending_call_get_completed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_get_completed
#endif
dbus_pending_call_get_completed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4064(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4064(%rip)
2:
  pushq $508
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_get_data
  .p2align 4
  .type dbus_pending_call_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_get_data
#endif
dbus_pending_call_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4072(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4072(%rip)
2:
  pushq $509
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_ref
  .p2align 4
  .type dbus_pending_call_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_ref
#endif
dbus_pending_call_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4080(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4080(%rip)
2:
  pushq $510
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_set_data
  .p2align 4
  .type dbus_pending_call_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_set_data
#endif
dbus_pending_call_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4088(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4088(%rip)
2:
  pushq $511
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_set_notify
  .p2align 4
  .type dbus_pending_call_set_notify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_set_notify
#endif
dbus_pending_call_set_notify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4096(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4096(%rip)
2:
  pushq $512
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_steal_reply
  .p2align 4
  .type dbus_pending_call_steal_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_steal_reply
#endif
dbus_pending_call_steal_reply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4104(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4104(%rip)
2:
  pushq $513
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_pending_call_unref
  .p2align 4
  .type dbus_pending_call_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_unref
#endif
dbus_pending_call_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4112(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4112(%rip)
2:
  pushq $514
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_realloc
  .p2align 4
  .type dbus_realloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_realloc
#endif
dbus_realloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4120(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4120(%rip)
2:
  pushq $515
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_allocate_data_slot
  .p2align 4
  .type dbus_server_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_allocate_data_slot
#endif
dbus_server_allocate_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4128(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4128(%rip)
2:
  pushq $516
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_disconnect
  .p2align 4
  .type dbus_server_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_disconnect
#endif
dbus_server_disconnect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4136(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4136(%rip)
2:
  pushq $517
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_free_data_slot
  .p2align 4
  .type dbus_server_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_free_data_slot
#endif
dbus_server_free_data_slot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4144(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4144(%rip)
2:
  pushq $518
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_get_address
  .p2align 4
  .type dbus_server_get_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_address
#endif
dbus_server_get_address:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4152(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4152(%rip)
2:
  pushq $519
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_get_data
  .p2align 4
  .type dbus_server_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_data
#endif
dbus_server_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4160(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4160(%rip)
2:
  pushq $520
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_get_id
  .p2align 4
  .type dbus_server_get_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_id
#endif
dbus_server_get_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4168(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4168(%rip)
2:
  pushq $521
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_get_is_connected
  .p2align 4
  .type dbus_server_get_is_connected, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_is_connected
#endif
dbus_server_get_is_connected:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4176(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4176(%rip)
2:
  pushq $522
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_listen
  .p2align 4
  .type dbus_server_listen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_listen
#endif
dbus_server_listen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4184(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4184(%rip)
2:
  pushq $523
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_ref
  .p2align 4
  .type dbus_server_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_ref
#endif
dbus_server_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4192(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4192(%rip)
2:
  pushq $524
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_set_auth_mechanisms
  .p2align 4
  .type dbus_server_set_auth_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_auth_mechanisms
#endif
dbus_server_set_auth_mechanisms:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4200(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4200(%rip)
2:
  pushq $525
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_set_data
  .p2align 4
  .type dbus_server_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_data
#endif
dbus_server_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4208(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4208(%rip)
2:
  pushq $526
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_set_new_connection_function
  .p2align 4
  .type dbus_server_set_new_connection_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_new_connection_function
#endif
dbus_server_set_new_connection_function:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4216(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4216(%rip)
2:
  pushq $527
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_set_timeout_functions
  .p2align 4
  .type dbus_server_set_timeout_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_timeout_functions
#endif
dbus_server_set_timeout_functions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4224(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4224(%rip)
2:
  pushq $528
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_set_watch_functions
  .p2align 4
  .type dbus_server_set_watch_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_watch_functions
#endif
dbus_server_set_watch_functions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4232(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4232(%rip)
2:
  pushq $529
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_server_unref
  .p2align 4
  .type dbus_server_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_unref
#endif
dbus_server_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4240(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4240(%rip)
2:
  pushq $530
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_set_error
  .p2align 4
  .type dbus_set_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error
#endif
dbus_set_error:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4248(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4248(%rip)
2:
  pushq $531
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_set_error_const
  .p2align 4
  .type dbus_set_error_const, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error_const
#endif
dbus_set_error_const:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4256(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4256(%rip)
2:
  pushq $532
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_set_error_from_message
  .p2align 4
  .type dbus_set_error_from_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error_from_message
#endif
dbus_set_error_from_message:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4264(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4264(%rip)
2:
  pushq $533
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_setenv
  .p2align 4
  .type dbus_setenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_setenv
#endif
dbus_setenv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4272(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4272(%rip)
2:
  pushq $534
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_shutdown
  .p2align 4
  .type dbus_shutdown, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_shutdown
#endif
dbus_shutdown:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4280(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4280(%rip)
2:
  pushq $535
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_get_current_type
  .p2align 4
  .type dbus_signature_iter_get_current_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_current_type
#endif
dbus_signature_iter_get_current_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4288(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4288(%rip)
2:
  pushq $536
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_get_element_type
  .p2align 4
  .type dbus_signature_iter_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_element_type
#endif
dbus_signature_iter_get_element_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4296(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4296(%rip)
2:
  pushq $537
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_get_signature
  .p2align 4
  .type dbus_signature_iter_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_signature
#endif
dbus_signature_iter_get_signature:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4304(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4304(%rip)
2:
  pushq $538
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_init
  .p2align 4
  .type dbus_signature_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_init
#endif
dbus_signature_iter_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4312(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4312(%rip)
2:
  pushq $539
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_next
  .p2align 4
  .type dbus_signature_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_next
#endif
dbus_signature_iter_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4320(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4320(%rip)
2:
  pushq $540
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_iter_recurse
  .p2align 4
  .type dbus_signature_iter_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_recurse
#endif
dbus_signature_iter_recurse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4328(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4328(%rip)
2:
  pushq $541
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_validate
  .p2align 4
  .type dbus_signature_validate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_validate
#endif
dbus_signature_validate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4336(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4336(%rip)
2:
  pushq $542
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_signature_validate_single
  .p2align 4
  .type dbus_signature_validate_single, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_validate_single
#endif
dbus_signature_validate_single:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4344(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4344(%rip)
2:
  pushq $543
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_threads_init
  .p2align 4
  .type dbus_threads_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_threads_init
#endif
dbus_threads_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4352(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4352(%rip)
2:
  pushq $544
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_threads_init_default
  .p2align 4
  .type dbus_threads_init_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_threads_init_default
#endif
dbus_threads_init_default:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4360(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4360(%rip)
2:
  pushq $545
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_timeout_get_data
  .p2align 4
  .type dbus_timeout_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_data
#endif
dbus_timeout_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4368(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4368(%rip)
2:
  pushq $546
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_timeout_get_enabled
  .p2align 4
  .type dbus_timeout_get_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_enabled
#endif
dbus_timeout_get_enabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4376(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4376(%rip)
2:
  pushq $547
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_timeout_get_interval
  .p2align 4
  .type dbus_timeout_get_interval, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_interval
#endif
dbus_timeout_get_interval:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4384(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4384(%rip)
2:
  pushq $548
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_timeout_handle
  .p2align 4
  .type dbus_timeout_handle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_handle
#endif
dbus_timeout_handle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4392(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4392(%rip)
2:
  pushq $549
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_timeout_set_data
  .p2align 4
  .type dbus_timeout_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_set_data
#endif
dbus_timeout_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4400(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4400(%rip)
2:
  pushq $550
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_try_get_local_machine_id
  .p2align 4
  .type dbus_try_get_local_machine_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_try_get_local_machine_id
#endif
dbus_try_get_local_machine_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4408(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4408(%rip)
2:
  pushq $551
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_type_is_basic
  .p2align 4
  .type dbus_type_is_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_basic
#endif
dbus_type_is_basic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4416(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4416(%rip)
2:
  pushq $552
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_type_is_container
  .p2align 4
  .type dbus_type_is_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_container
#endif
dbus_type_is_container:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4424(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4424(%rip)
2:
  pushq $553
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_type_is_fixed
  .p2align 4
  .type dbus_type_is_fixed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_fixed
#endif
dbus_type_is_fixed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4432(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4432(%rip)
2:
  pushq $554
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_type_is_valid
  .p2align 4
  .type dbus_type_is_valid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_valid
#endif
dbus_type_is_valid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4440(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4440(%rip)
2:
  pushq $555
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_bus_name
  .p2align 4
  .type dbus_validate_bus_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_bus_name
#endif
dbus_validate_bus_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4448(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4448(%rip)
2:
  pushq $556
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_error_name
  .p2align 4
  .type dbus_validate_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_error_name
#endif
dbus_validate_error_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4456(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4456(%rip)
2:
  pushq $557
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_interface
  .p2align 4
  .type dbus_validate_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_interface
#endif
dbus_validate_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4464(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4464(%rip)
2:
  pushq $558
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_member
  .p2align 4
  .type dbus_validate_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_member
#endif
dbus_validate_member:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4472(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4472(%rip)
2:
  pushq $559
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_path
  .p2align 4
  .type dbus_validate_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_path
#endif
dbus_validate_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4480(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4480(%rip)
2:
  pushq $560
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_validate_utf8
  .p2align 4
  .type dbus_validate_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_utf8
#endif
dbus_validate_utf8:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4488(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4488(%rip)
2:
  pushq $561
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_data
  .p2align 4
  .type dbus_watch_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_data
#endif
dbus_watch_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4496(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4496(%rip)
2:
  pushq $562
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_enabled
  .p2align 4
  .type dbus_watch_get_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_enabled
#endif
dbus_watch_get_enabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4504(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4504(%rip)
2:
  pushq $563
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_fd
  .p2align 4
  .type dbus_watch_get_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_fd
#endif
dbus_watch_get_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4512(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4512(%rip)
2:
  pushq $564
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_flags
  .p2align 4
  .type dbus_watch_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_flags
#endif
dbus_watch_get_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4520(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4520(%rip)
2:
  pushq $565
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_socket
  .p2align 4
  .type dbus_watch_get_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_socket
#endif
dbus_watch_get_socket:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4528(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4528(%rip)
2:
  pushq $566
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_get_unix_fd
  .p2align 4
  .type dbus_watch_get_unix_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_unix_fd
#endif
dbus_watch_get_unix_fd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4536(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4536(%rip)
2:
  pushq $567
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_handle
  .p2align 4
  .type dbus_watch_handle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_handle
#endif
dbus_watch_handle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4544(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4544(%rip)
2:
  pushq $568
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
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

  .globl dbus_watch_set_data
  .p2align 4
  .type dbus_watch_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_set_data
#endif
dbus_watch_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libdbus_1_so_tramp_table+4552(%rip)
  je 2f
1:
  jmp *_libdbus_1_so_tramp_table+4552(%rip)
2:
  pushq $569
  .cfi_adjust_cfa_offset 8
  call _libdbus_1_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

