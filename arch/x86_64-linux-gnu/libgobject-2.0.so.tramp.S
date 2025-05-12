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

  .globl _libgobject_2_0_so_tramp_table
  .hidden _libgobject_2_0_so_tramp_table
  .align 8
_libgobject_2_0_so_tramp_table:
  .zero 3840

  .text

  .globl _libgobject_2_0_so_tramp_resolve
  .hidden _libgobject_2_0_so_tramp_resolve

  .globl _libgobject_2_0_so_save_regs_and_resolve
  .hidden _libgobject_2_0_so_save_regs_and_resolve
  .type _libgobject_2_0_so_save_regs_and_resolve, %function
_libgobject_2_0_so_save_regs_and_resolve:
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
  call _libgobject_2_0_so_tramp_resolve

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

  .globl g_array_get_type
  .p2align 4
  .type g_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_array_get_type
#endif
g_array_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_dup_source
  .p2align 4
  .type g_binding_dup_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_dup_source
#endif
g_binding_dup_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_dup_target
  .p2align 4
  .type g_binding_dup_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_dup_target
#endif
g_binding_dup_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_flags_get_type
  .p2align 4
  .type g_binding_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_flags_get_type
#endif
g_binding_flags_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_flags
  .p2align 4
  .type g_binding_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_flags
#endif
g_binding_get_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_source
  .p2align 4
  .type g_binding_get_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_source
#endif
g_binding_get_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_source_property
  .p2align 4
  .type g_binding_get_source_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_source_property
#endif
g_binding_get_source_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_target
  .p2align 4
  .type g_binding_get_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_target
#endif
g_binding_get_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_target_property
  .p2align 4
  .type g_binding_get_target_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_target_property
#endif
g_binding_get_target_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_get_type
  .p2align 4
  .type g_binding_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_get_type
#endif
g_binding_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_bind
  .p2align 4
  .type g_binding_group_bind, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_bind
#endif
g_binding_group_bind:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_bind_full
  .p2align 4
  .type g_binding_group_bind_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_bind_full
#endif
g_binding_group_bind_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_bind_with_closures
  .p2align 4
  .type g_binding_group_bind_with_closures, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_bind_with_closures
#endif
g_binding_group_bind_with_closures:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_dup_source
  .p2align 4
  .type g_binding_group_dup_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_dup_source
#endif
g_binding_group_dup_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_get_type
  .p2align 4
  .type g_binding_group_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_get_type
#endif
g_binding_group_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_new
  .p2align 4
  .type g_binding_group_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_new
#endif
g_binding_group_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_group_set_source
  .p2align 4
  .type g_binding_group_set_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_group_set_source
#endif
g_binding_group_set_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_binding_unbind
  .p2align 4
  .type g_binding_unbind, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_binding_unbind
#endif
g_binding_unbind:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_bookmark_file_get_type
  .p2align 4
  .type g_bookmark_file_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_bookmark_file_get_type
#endif
g_bookmark_file_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_boxed_copy
  .p2align 4
  .type g_boxed_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_boxed_copy
#endif
g_boxed_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_boxed_free
  .p2align 4
  .type g_boxed_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_boxed_free
#endif
g_boxed_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_boxed_type_register_static
  .p2align 4
  .type g_boxed_type_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_boxed_type_register_static
#endif
g_boxed_type_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_byte_array_get_type
  .p2align 4
  .type g_byte_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_byte_array_get_type
#endif
g_byte_array_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_bytes_get_type
  .p2align 4
  .type g_bytes_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_bytes_get_type
#endif
g_bytes_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_BOOLEAN__BOXED_BOXED
  .p2align 4
  .type g_cclosure_marshal_BOOLEAN__BOXED_BOXED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_BOOLEAN__BOXED_BOXED
#endif
g_cclosure_marshal_BOOLEAN__BOXED_BOXED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_BOOLEAN__BOXED_BOXEDv
  .p2align 4
  .type g_cclosure_marshal_BOOLEAN__BOXED_BOXEDv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_BOOLEAN__BOXED_BOXEDv
#endif
g_cclosure_marshal_BOOLEAN__BOXED_BOXEDv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_BOOLEAN__FLAGS
  .p2align 4
  .type g_cclosure_marshal_BOOLEAN__FLAGS, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_BOOLEAN__FLAGS
#endif
g_cclosure_marshal_BOOLEAN__FLAGS:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_BOOLEAN__FLAGSv
  .p2align 4
  .type g_cclosure_marshal_BOOLEAN__FLAGSv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_BOOLEAN__FLAGSv
#endif
g_cclosure_marshal_BOOLEAN__FLAGSv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_STRING__OBJECT_POINTER
  .p2align 4
  .type g_cclosure_marshal_STRING__OBJECT_POINTER, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_STRING__OBJECT_POINTER
#endif
g_cclosure_marshal_STRING__OBJECT_POINTER:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_STRING__OBJECT_POINTERv
  .p2align 4
  .type g_cclosure_marshal_STRING__OBJECT_POINTERv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_STRING__OBJECT_POINTERv
#endif
g_cclosure_marshal_STRING__OBJECT_POINTERv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__BOOLEAN
  .p2align 4
  .type g_cclosure_marshal_VOID__BOOLEAN, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__BOOLEAN
#endif
g_cclosure_marshal_VOID__BOOLEAN:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__BOOLEANv
  .p2align 4
  .type g_cclosure_marshal_VOID__BOOLEANv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__BOOLEANv
#endif
g_cclosure_marshal_VOID__BOOLEANv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__BOXED
  .p2align 4
  .type g_cclosure_marshal_VOID__BOXED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__BOXED
#endif
g_cclosure_marshal_VOID__BOXED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__BOXEDv
  .p2align 4
  .type g_cclosure_marshal_VOID__BOXEDv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__BOXEDv
#endif
g_cclosure_marshal_VOID__BOXEDv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__CHAR
  .p2align 4
  .type g_cclosure_marshal_VOID__CHAR, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__CHAR
#endif
g_cclosure_marshal_VOID__CHAR:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__CHARv
  .p2align 4
  .type g_cclosure_marshal_VOID__CHARv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__CHARv
#endif
g_cclosure_marshal_VOID__CHARv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__DOUBLE
  .p2align 4
  .type g_cclosure_marshal_VOID__DOUBLE, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__DOUBLE
#endif
g_cclosure_marshal_VOID__DOUBLE:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__DOUBLEv
  .p2align 4
  .type g_cclosure_marshal_VOID__DOUBLEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__DOUBLEv
#endif
g_cclosure_marshal_VOID__DOUBLEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__ENUM
  .p2align 4
  .type g_cclosure_marshal_VOID__ENUM, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__ENUM
#endif
g_cclosure_marshal_VOID__ENUM:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__ENUMv
  .p2align 4
  .type g_cclosure_marshal_VOID__ENUMv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__ENUMv
#endif
g_cclosure_marshal_VOID__ENUMv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__FLAGS
  .p2align 4
  .type g_cclosure_marshal_VOID__FLAGS, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__FLAGS
#endif
g_cclosure_marshal_VOID__FLAGS:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__FLAGSv
  .p2align 4
  .type g_cclosure_marshal_VOID__FLAGSv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__FLAGSv
#endif
g_cclosure_marshal_VOID__FLAGSv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__FLOAT
  .p2align 4
  .type g_cclosure_marshal_VOID__FLOAT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__FLOAT
#endif
g_cclosure_marshal_VOID__FLOAT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__FLOATv
  .p2align 4
  .type g_cclosure_marshal_VOID__FLOATv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__FLOATv
#endif
g_cclosure_marshal_VOID__FLOATv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__INT
  .p2align 4
  .type g_cclosure_marshal_VOID__INT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__INT
#endif
g_cclosure_marshal_VOID__INT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__INTv
  .p2align 4
  .type g_cclosure_marshal_VOID__INTv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__INTv
#endif
g_cclosure_marshal_VOID__INTv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__LONG
  .p2align 4
  .type g_cclosure_marshal_VOID__LONG, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__LONG
#endif
g_cclosure_marshal_VOID__LONG:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__LONGv
  .p2align 4
  .type g_cclosure_marshal_VOID__LONGv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__LONGv
#endif
g_cclosure_marshal_VOID__LONGv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__OBJECT
  .p2align 4
  .type g_cclosure_marshal_VOID__OBJECT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__OBJECT
#endif
g_cclosure_marshal_VOID__OBJECT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__OBJECTv
  .p2align 4
  .type g_cclosure_marshal_VOID__OBJECTv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__OBJECTv
#endif
g_cclosure_marshal_VOID__OBJECTv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__PARAM
  .p2align 4
  .type g_cclosure_marshal_VOID__PARAM, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__PARAM
#endif
g_cclosure_marshal_VOID__PARAM:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__PARAMv
  .p2align 4
  .type g_cclosure_marshal_VOID__PARAMv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__PARAMv
#endif
g_cclosure_marshal_VOID__PARAMv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__POINTER
  .p2align 4
  .type g_cclosure_marshal_VOID__POINTER, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__POINTER
#endif
g_cclosure_marshal_VOID__POINTER:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__POINTERv
  .p2align 4
  .type g_cclosure_marshal_VOID__POINTERv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__POINTERv
#endif
g_cclosure_marshal_VOID__POINTERv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__STRING
  .p2align 4
  .type g_cclosure_marshal_VOID__STRING, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__STRING
#endif
g_cclosure_marshal_VOID__STRING:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__STRINGv
  .p2align 4
  .type g_cclosure_marshal_VOID__STRINGv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__STRINGv
#endif
g_cclosure_marshal_VOID__STRINGv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UCHAR
  .p2align 4
  .type g_cclosure_marshal_VOID__UCHAR, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UCHAR
#endif
g_cclosure_marshal_VOID__UCHAR:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UCHARv
  .p2align 4
  .type g_cclosure_marshal_VOID__UCHARv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UCHARv
#endif
g_cclosure_marshal_VOID__UCHARv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UINT
  .p2align 4
  .type g_cclosure_marshal_VOID__UINT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UINT
#endif
g_cclosure_marshal_VOID__UINT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UINT_POINTER
  .p2align 4
  .type g_cclosure_marshal_VOID__UINT_POINTER, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UINT_POINTER
#endif
g_cclosure_marshal_VOID__UINT_POINTER:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UINT_POINTERv
  .p2align 4
  .type g_cclosure_marshal_VOID__UINT_POINTERv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UINT_POINTERv
#endif
g_cclosure_marshal_VOID__UINT_POINTERv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__UINTv
  .p2align 4
  .type g_cclosure_marshal_VOID__UINTv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__UINTv
#endif
g_cclosure_marshal_VOID__UINTv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__ULONG
  .p2align 4
  .type g_cclosure_marshal_VOID__ULONG, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__ULONG
#endif
g_cclosure_marshal_VOID__ULONG:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__ULONGv
  .p2align 4
  .type g_cclosure_marshal_VOID__ULONGv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__ULONGv
#endif
g_cclosure_marshal_VOID__ULONGv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__VARIANT
  .p2align 4
  .type g_cclosure_marshal_VOID__VARIANT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__VARIANT
#endif
g_cclosure_marshal_VOID__VARIANT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__VARIANTv
  .p2align 4
  .type g_cclosure_marshal_VOID__VARIANTv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__VARIANTv
#endif
g_cclosure_marshal_VOID__VARIANTv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__VOID
  .p2align 4
  .type g_cclosure_marshal_VOID__VOID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__VOID
#endif
g_cclosure_marshal_VOID__VOID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_VOID__VOIDv
  .p2align 4
  .type g_cclosure_marshal_VOID__VOIDv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_VOID__VOIDv
#endif
g_cclosure_marshal_VOID__VOIDv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_generic
  .p2align 4
  .type g_cclosure_marshal_generic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_generic
#endif
g_cclosure_marshal_generic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_marshal_generic_va
  .p2align 4
  .type g_cclosure_marshal_generic_va, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_marshal_generic_va
#endif
g_cclosure_marshal_generic_va:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_new
  .p2align 4
  .type g_cclosure_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_new
#endif
g_cclosure_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_new_object
  .p2align 4
  .type g_cclosure_new_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_new_object
#endif
g_cclosure_new_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_new_object_swap
  .p2align 4
  .type g_cclosure_new_object_swap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_new_object_swap
#endif
g_cclosure_new_object_swap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_cclosure_new_swap
  .p2align 4
  .type g_cclosure_new_swap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_cclosure_new_swap
#endif
g_cclosure_new_swap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_checksum_get_type
  .p2align 4
  .type g_checksum_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_checksum_get_type
#endif
g_checksum_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_clear_object
  .p2align 4
  .type g_clear_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_clear_object
#endif
g_clear_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_clear_signal_handler
  .p2align 4
  .type g_clear_signal_handler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_clear_signal_handler
#endif
g_clear_signal_handler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_add_finalize_notifier
  .p2align 4
  .type g_closure_add_finalize_notifier, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_add_finalize_notifier
#endif
g_closure_add_finalize_notifier:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_add_invalidate_notifier
  .p2align 4
  .type g_closure_add_invalidate_notifier, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_add_invalidate_notifier
#endif
g_closure_add_invalidate_notifier:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_add_marshal_guards
  .p2align 4
  .type g_closure_add_marshal_guards, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_add_marshal_guards
#endif
g_closure_add_marshal_guards:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_get_type
  .p2align 4
  .type g_closure_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_get_type
#endif
g_closure_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_invalidate
  .p2align 4
  .type g_closure_invalidate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_invalidate
#endif
g_closure_invalidate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_invoke
  .p2align 4
  .type g_closure_invoke, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_invoke
#endif
g_closure_invoke:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_new_object
  .p2align 4
  .type g_closure_new_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_new_object
#endif
g_closure_new_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_new_simple
  .p2align 4
  .type g_closure_new_simple, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_new_simple
#endif
g_closure_new_simple:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_ref
  .p2align 4
  .type g_closure_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_ref
#endif
g_closure_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_remove_finalize_notifier
  .p2align 4
  .type g_closure_remove_finalize_notifier, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_remove_finalize_notifier
#endif
g_closure_remove_finalize_notifier:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_remove_invalidate_notifier
  .p2align 4
  .type g_closure_remove_invalidate_notifier, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_remove_invalidate_notifier
#endif
g_closure_remove_invalidate_notifier:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_set_marshal
  .p2align 4
  .type g_closure_set_marshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_set_marshal
#endif
g_closure_set_marshal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_set_meta_marshal
  .p2align 4
  .type g_closure_set_meta_marshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_set_meta_marshal
#endif
g_closure_set_meta_marshal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_sink
  .p2align 4
  .type g_closure_sink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_sink
#endif
g_closure_sink:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_closure_unref
  .p2align 4
  .type g_closure_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_closure_unref
#endif
g_closure_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_date_get_type
  .p2align 4
  .type g_date_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_date_get_type
#endif
g_date_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_date_time_get_type
  .p2align 4
  .type g_date_time_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_date_time_get_type
#endif
g_date_time_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_dir_get_type
  .p2align 4
  .type g_dir_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_dir_get_type
#endif
g_dir_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_complete_type_info
  .p2align 4
  .type g_enum_complete_type_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_complete_type_info
#endif
g_enum_complete_type_info:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_get_value
  .p2align 4
  .type g_enum_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_get_value
#endif
g_enum_get_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_get_value_by_name
  .p2align 4
  .type g_enum_get_value_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_get_value_by_name
#endif
g_enum_get_value_by_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_get_value_by_nick
  .p2align 4
  .type g_enum_get_value_by_nick, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_get_value_by_nick
#endif
g_enum_get_value_by_nick:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_register_static
  .p2align 4
  .type g_enum_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_register_static
#endif
g_enum_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_enum_to_string
  .p2align 4
  .type g_enum_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_enum_to_string
#endif
g_enum_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_error_get_type
  .p2align 4
  .type g_error_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_error_get_type
#endif
g_error_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_complete_type_info
  .p2align 4
  .type g_flags_complete_type_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_complete_type_info
#endif
g_flags_complete_type_info:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_get_first_value
  .p2align 4
  .type g_flags_get_first_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_get_first_value
#endif
g_flags_get_first_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_get_value_by_name
  .p2align 4
  .type g_flags_get_value_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_get_value_by_name
#endif
g_flags_get_value_by_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_get_value_by_nick
  .p2align 4
  .type g_flags_get_value_by_nick, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_get_value_by_nick
#endif
g_flags_get_value_by_nick:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_register_static
  .p2align 4
  .type g_flags_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_register_static
#endif
g_flags_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_flags_to_string
  .p2align 4
  .type g_flags_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_flags_to_string
#endif
g_flags_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_gstring_get_type
  .p2align 4
  .type g_gstring_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_gstring_get_type
#endif
g_gstring_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_gtype_get_type
  .p2align 4
  .type g_gtype_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_gtype_get_type
#endif
g_gtype_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_hash_table_get_type
  .p2align 4
  .type g_hash_table_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_hash_table_get_type
#endif
g_hash_table_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_hmac_get_type
  .p2align 4
  .type g_hmac_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_hmac_get_type
#endif
g_hmac_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_initially_unowned_get_type
  .p2align 4
  .type g_initially_unowned_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_initially_unowned_get_type
#endif
g_initially_unowned_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_io_channel_get_type
  .p2align 4
  .type g_io_channel_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_io_channel_get_type
#endif
g_io_channel_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_io_condition_get_type
  .p2align 4
  .type g_io_condition_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_io_condition_get_type
#endif
g_io_condition_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_key_file_get_type
  .p2align 4
  .type g_key_file_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_key_file_get_type
#endif
g_key_file_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_main_context_get_type
  .p2align 4
  .type g_main_context_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_main_context_get_type
#endif
g_main_context_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_main_loop_get_type
  .p2align 4
  .type g_main_loop_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_main_loop_get_type
#endif
g_main_loop_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_mapped_file_get_type
  .p2align 4
  .type g_mapped_file_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_mapped_file_get_type
#endif
g_mapped_file_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_markup_parse_context_get_type
  .p2align 4
  .type g_markup_parse_context_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_markup_parse_context_get_type
#endif
g_markup_parse_context_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_match_info_get_type
  .p2align 4
  .type g_match_info_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_match_info_get_type
#endif
g_match_info_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_normalize_mode_get_type
  .p2align 4
  .type g_normalize_mode_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_normalize_mode_get_type
#endif
g_normalize_mode_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_add_toggle_ref
  .p2align 4
  .type g_object_add_toggle_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_add_toggle_ref
#endif
g_object_add_toggle_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_add_weak_pointer
  .p2align 4
  .type g_object_add_weak_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_add_weak_pointer
#endif
g_object_add_weak_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_bind_property
  .p2align 4
  .type g_object_bind_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_bind_property
#endif
g_object_bind_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_bind_property_full
  .p2align 4
  .type g_object_bind_property_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_bind_property_full
#endif
g_object_bind_property_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_bind_property_with_closures
  .p2align 4
  .type g_object_bind_property_with_closures, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_bind_property_with_closures
#endif
g_object_bind_property_with_closures:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_class_find_property
  .p2align 4
  .type g_object_class_find_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_class_find_property
#endif
g_object_class_find_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_class_install_properties
  .p2align 4
  .type g_object_class_install_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_class_install_properties
#endif
g_object_class_install_properties:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_class_install_property
  .p2align 4
  .type g_object_class_install_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_class_install_property
#endif
g_object_class_install_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_class_list_properties
  .p2align 4
  .type g_object_class_list_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_class_list_properties
#endif
g_object_class_list_properties:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_class_override_property
  .p2align 4
  .type g_object_class_override_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_class_override_property
#endif
g_object_class_override_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_compat_control
  .p2align 4
  .type g_object_compat_control, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_compat_control
#endif
g_object_compat_control:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_connect
  .p2align 4
  .type g_object_connect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_connect
#endif
g_object_connect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_disconnect
  .p2align 4
  .type g_object_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_disconnect
#endif
g_object_disconnect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_dup_data
  .p2align 4
  .type g_object_dup_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_dup_data
#endif
g_object_dup_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_dup_qdata
  .p2align 4
  .type g_object_dup_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_dup_qdata
#endif
g_object_dup_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_force_floating
  .p2align 4
  .type g_object_force_floating, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_force_floating
#endif
g_object_force_floating:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_freeze_notify
  .p2align 4
  .type g_object_freeze_notify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_freeze_notify
#endif
g_object_freeze_notify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get
  .p2align 4
  .type g_object_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get
#endif
g_object_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get_data
  .p2align 4
  .type g_object_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get_data
#endif
g_object_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get_property
  .p2align 4
  .type g_object_get_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get_property
#endif
g_object_get_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get_qdata
  .p2align 4
  .type g_object_get_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get_qdata
#endif
g_object_get_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get_type
  .p2align 4
  .type g_object_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get_type
#endif
g_object_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_get_valist
  .p2align 4
  .type g_object_get_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_get_valist
#endif
g_object_get_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_getv
  .p2align 4
  .type g_object_getv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_getv
#endif
g_object_getv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_interface_find_property
  .p2align 4
  .type g_object_interface_find_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_interface_find_property
#endif
g_object_interface_find_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_interface_install_property
  .p2align 4
  .type g_object_interface_install_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_interface_install_property
#endif
g_object_interface_install_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_interface_list_properties
  .p2align 4
  .type g_object_interface_list_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_interface_list_properties
#endif
g_object_interface_list_properties:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_is_floating
  .p2align 4
  .type g_object_is_floating, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_is_floating
#endif
g_object_is_floating:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_new
  .p2align 4
  .type g_object_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_new
#endif
g_object_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_new_valist
  .p2align 4
  .type g_object_new_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_new_valist
#endif
g_object_new_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_new_with_properties
  .p2align 4
  .type g_object_new_with_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_new_with_properties
#endif
g_object_new_with_properties:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_newv
  .p2align 4
  .type g_object_newv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_newv
#endif
g_object_newv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_notify
  .p2align 4
  .type g_object_notify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_notify
#endif
g_object_notify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_notify_by_pspec
  .p2align 4
  .type g_object_notify_by_pspec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_notify_by_pspec
#endif
g_object_notify_by_pspec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_ref
  .p2align 4
  .type g_object_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_ref
#endif
g_object_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_ref_sink
  .p2align 4
  .type g_object_ref_sink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_ref_sink
#endif
g_object_ref_sink:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_remove_toggle_ref
  .p2align 4
  .type g_object_remove_toggle_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_remove_toggle_ref
#endif
g_object_remove_toggle_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_remove_weak_pointer
  .p2align 4
  .type g_object_remove_weak_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_remove_weak_pointer
#endif
g_object_remove_weak_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_replace_data
  .p2align 4
  .type g_object_replace_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_replace_data
#endif
g_object_replace_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_replace_qdata
  .p2align 4
  .type g_object_replace_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_replace_qdata
#endif
g_object_replace_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_run_dispose
  .p2align 4
  .type g_object_run_dispose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_run_dispose
#endif
g_object_run_dispose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set
  .p2align 4
  .type g_object_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set
#endif
g_object_set:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_data
  .p2align 4
  .type g_object_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_data
#endif
g_object_set_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_data_full
  .p2align 4
  .type g_object_set_data_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_data_full
#endif
g_object_set_data_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_property
  .p2align 4
  .type g_object_set_property, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_property
#endif
g_object_set_property:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_qdata
  .p2align 4
  .type g_object_set_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_qdata
#endif
g_object_set_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_qdata_full
  .p2align 4
  .type g_object_set_qdata_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_qdata_full
#endif
g_object_set_qdata_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_set_valist
  .p2align 4
  .type g_object_set_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_set_valist
#endif
g_object_set_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_setv
  .p2align 4
  .type g_object_setv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_setv
#endif
g_object_setv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_steal_data
  .p2align 4
  .type g_object_steal_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_steal_data
#endif
g_object_steal_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_steal_qdata
  .p2align 4
  .type g_object_steal_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_steal_qdata
#endif
g_object_steal_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_take_ref
  .p2align 4
  .type g_object_take_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_take_ref
#endif
g_object_take_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_thaw_notify
  .p2align 4
  .type g_object_thaw_notify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_thaw_notify
#endif
g_object_thaw_notify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_unref
  .p2align 4
  .type g_object_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_unref
#endif
g_object_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_watch_closure
  .p2align 4
  .type g_object_watch_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_watch_closure
#endif
g_object_watch_closure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_weak_ref
  .p2align 4
  .type g_object_weak_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_weak_ref
#endif
g_object_weak_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_object_weak_unref
  .p2align 4
  .type g_object_weak_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_object_weak_unref
#endif
g_object_weak_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_option_group_get_type
  .p2align 4
  .type g_option_group_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_option_group_get_type
#endif
g_option_group_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_boolean
  .p2align 4
  .type g_param_spec_boolean, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_boolean
#endif
g_param_spec_boolean:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_boxed
  .p2align 4
  .type g_param_spec_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_boxed
#endif
g_param_spec_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_char
  .p2align 4
  .type g_param_spec_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_char
#endif
g_param_spec_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_double
  .p2align 4
  .type g_param_spec_double, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_double
#endif
g_param_spec_double:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_enum
  .p2align 4
  .type g_param_spec_enum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_enum
#endif
g_param_spec_enum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_flags
  .p2align 4
  .type g_param_spec_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_flags
#endif
g_param_spec_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_float
  .p2align 4
  .type g_param_spec_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_float
#endif
g_param_spec_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_blurb
  .p2align 4
  .type g_param_spec_get_blurb, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_blurb
#endif
g_param_spec_get_blurb:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_default_value
  .p2align 4
  .type g_param_spec_get_default_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_default_value
#endif
g_param_spec_get_default_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_name
  .p2align 4
  .type g_param_spec_get_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_name
#endif
g_param_spec_get_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_name_quark
  .p2align 4
  .type g_param_spec_get_name_quark, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_name_quark
#endif
g_param_spec_get_name_quark:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_nick
  .p2align 4
  .type g_param_spec_get_nick, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_nick
#endif
g_param_spec_get_nick:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_qdata
  .p2align 4
  .type g_param_spec_get_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_qdata
#endif
g_param_spec_get_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_get_redirect_target
  .p2align 4
  .type g_param_spec_get_redirect_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_get_redirect_target
#endif
g_param_spec_get_redirect_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_gtype
  .p2align 4
  .type g_param_spec_gtype, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_gtype
#endif
g_param_spec_gtype:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_int
  .p2align 4
  .type g_param_spec_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_int
#endif
g_param_spec_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_int64
  .p2align 4
  .type g_param_spec_int64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_int64
#endif
g_param_spec_int64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_internal
  .p2align 4
  .type g_param_spec_internal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_internal
#endif
g_param_spec_internal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_is_valid_name
  .p2align 4
  .type g_param_spec_is_valid_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_is_valid_name
#endif
g_param_spec_is_valid_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_long
  .p2align 4
  .type g_param_spec_long, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_long
#endif
g_param_spec_long:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_object
  .p2align 4
  .type g_param_spec_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_object
#endif
g_param_spec_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_override
  .p2align 4
  .type g_param_spec_override, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_override
#endif
g_param_spec_override:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_param
  .p2align 4
  .type g_param_spec_param, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_param
#endif
g_param_spec_param:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pointer
  .p2align 4
  .type g_param_spec_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pointer
#endif
g_param_spec_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_free
  .p2align 4
  .type g_param_spec_pool_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_free
#endif
g_param_spec_pool_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_insert
  .p2align 4
  .type g_param_spec_pool_insert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_insert
#endif
g_param_spec_pool_insert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_list
  .p2align 4
  .type g_param_spec_pool_list, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_list
#endif
g_param_spec_pool_list:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_list_owned
  .p2align 4
  .type g_param_spec_pool_list_owned, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_list_owned
#endif
g_param_spec_pool_list_owned:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_lookup
  .p2align 4
  .type g_param_spec_pool_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_lookup
#endif
g_param_spec_pool_lookup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_new
  .p2align 4
  .type g_param_spec_pool_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_new
#endif
g_param_spec_pool_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_pool_remove
  .p2align 4
  .type g_param_spec_pool_remove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_pool_remove
#endif
g_param_spec_pool_remove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_ref
  .p2align 4
  .type g_param_spec_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_ref
#endif
g_param_spec_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_ref_sink
  .p2align 4
  .type g_param_spec_ref_sink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_ref_sink
#endif
g_param_spec_ref_sink:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_set_qdata
  .p2align 4
  .type g_param_spec_set_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_set_qdata
#endif
g_param_spec_set_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_set_qdata_full
  .p2align 4
  .type g_param_spec_set_qdata_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_set_qdata_full
#endif
g_param_spec_set_qdata_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_sink
  .p2align 4
  .type g_param_spec_sink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_sink
#endif
g_param_spec_sink:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_steal_qdata
  .p2align 4
  .type g_param_spec_steal_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_steal_qdata
#endif
g_param_spec_steal_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_string
  .p2align 4
  .type g_param_spec_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_string
#endif
g_param_spec_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_uchar
  .p2align 4
  .type g_param_spec_uchar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_uchar
#endif
g_param_spec_uchar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_uint
  .p2align 4
  .type g_param_spec_uint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_uint
#endif
g_param_spec_uint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_uint64
  .p2align 4
  .type g_param_spec_uint64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_uint64
#endif
g_param_spec_uint64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_ulong
  .p2align 4
  .type g_param_spec_ulong, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_ulong
#endif
g_param_spec_ulong:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_unichar
  .p2align 4
  .type g_param_spec_unichar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_unichar
#endif
g_param_spec_unichar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_unref
  .p2align 4
  .type g_param_spec_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_unref
#endif
g_param_spec_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_value_array
  .p2align 4
  .type g_param_spec_value_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_value_array
#endif
g_param_spec_value_array:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_spec_variant
  .p2align 4
  .type g_param_spec_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_spec_variant
#endif
g_param_spec_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_type_register_static
  .p2align 4
  .type g_param_type_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_type_register_static
#endif
g_param_type_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_value_convert
  .p2align 4
  .type g_param_value_convert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_value_convert
#endif
g_param_value_convert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_value_defaults
  .p2align 4
  .type g_param_value_defaults, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_value_defaults
#endif
g_param_value_defaults:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_value_is_valid
  .p2align 4
  .type g_param_value_is_valid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_value_is_valid
#endif
g_param_value_is_valid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_value_set_default
  .p2align 4
  .type g_param_value_set_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_value_set_default
#endif
g_param_value_set_default:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_value_validate
  .p2align 4
  .type g_param_value_validate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_value_validate
#endif
g_param_value_validate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_param_values_cmp
  .p2align 4
  .type g_param_values_cmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_param_values_cmp
#endif
g_param_values_cmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_pattern_spec_get_type
  .p2align 4
  .type g_pattern_spec_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_pattern_spec_get_type
#endif
g_pattern_spec_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_pointer_type_register_static
  .p2align 4
  .type g_pointer_type_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_pointer_type_register_static
#endif
g_pointer_type_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_pollfd_get_type
  .p2align 4
  .type g_pollfd_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_pollfd_get_type
#endif
g_pollfd_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_ptr_array_get_type
  .p2align 4
  .type g_ptr_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_ptr_array_get_type
#endif
g_ptr_array_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_rand_get_type
  .p2align 4
  .type g_rand_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_rand_get_type
#endif
g_rand_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_regex_get_type
  .p2align 4
  .type g_regex_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_regex_get_type
#endif
g_regex_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_accumulator_first_wins
  .p2align 4
  .type g_signal_accumulator_first_wins, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_accumulator_first_wins
#endif
g_signal_accumulator_first_wins:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_accumulator_true_handled
  .p2align 4
  .type g_signal_accumulator_true_handled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_accumulator_true_handled
#endif
g_signal_accumulator_true_handled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_add_emission_hook
  .p2align 4
  .type g_signal_add_emission_hook, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_add_emission_hook
#endif
g_signal_add_emission_hook:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_chain_from_overridden
  .p2align 4
  .type g_signal_chain_from_overridden, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_chain_from_overridden
#endif
g_signal_chain_from_overridden:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_chain_from_overridden_handler
  .p2align 4
  .type g_signal_chain_from_overridden_handler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_chain_from_overridden_handler
#endif
g_signal_chain_from_overridden_handler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_connect_closure
  .p2align 4
  .type g_signal_connect_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_connect_closure
#endif
g_signal_connect_closure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_connect_closure_by_id
  .p2align 4
  .type g_signal_connect_closure_by_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_connect_closure_by_id
#endif
g_signal_connect_closure_by_id:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_connect_data
  .p2align 4
  .type g_signal_connect_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_connect_data
#endif
g_signal_connect_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_connect_object
  .p2align 4
  .type g_signal_connect_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_connect_object
#endif
g_signal_connect_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_emit
  .p2align 4
  .type g_signal_emit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_emit
#endif
g_signal_emit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_emit_by_name
  .p2align 4
  .type g_signal_emit_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_emit_by_name
#endif
g_signal_emit_by_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_emit_valist
  .p2align 4
  .type g_signal_emit_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_emit_valist
#endif
g_signal_emit_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_emitv
  .p2align 4
  .type g_signal_emitv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_emitv
#endif
g_signal_emitv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_get_invocation_hint
  .p2align 4
  .type g_signal_get_invocation_hint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_get_invocation_hint
#endif
g_signal_get_invocation_hint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_block
  .p2align 4
  .type g_signal_group_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_block
#endif
g_signal_group_block:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect
  .p2align 4
  .type g_signal_group_connect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect
#endif
g_signal_group_connect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect_after
  .p2align 4
  .type g_signal_group_connect_after, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect_after
#endif
g_signal_group_connect_after:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect_closure
  .p2align 4
  .type g_signal_group_connect_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect_closure
#endif
g_signal_group_connect_closure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect_data
  .p2align 4
  .type g_signal_group_connect_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect_data
#endif
g_signal_group_connect_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect_object
  .p2align 4
  .type g_signal_group_connect_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect_object
#endif
g_signal_group_connect_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_connect_swapped
  .p2align 4
  .type g_signal_group_connect_swapped, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_connect_swapped
#endif
g_signal_group_connect_swapped:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_dup_target
  .p2align 4
  .type g_signal_group_dup_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_dup_target
#endif
g_signal_group_dup_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_get_type
  .p2align 4
  .type g_signal_group_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_get_type
#endif
g_signal_group_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_new
  .p2align 4
  .type g_signal_group_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_new
#endif
g_signal_group_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_set_target
  .p2align 4
  .type g_signal_group_set_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_set_target
#endif
g_signal_group_set_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_group_unblock
  .p2align 4
  .type g_signal_group_unblock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_group_unblock
#endif
g_signal_group_unblock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handler_block
  .p2align 4
  .type g_signal_handler_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handler_block
#endif
g_signal_handler_block:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handler_disconnect
  .p2align 4
  .type g_signal_handler_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handler_disconnect
#endif
g_signal_handler_disconnect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handler_find
  .p2align 4
  .type g_signal_handler_find, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handler_find
#endif
g_signal_handler_find:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handler_is_connected
  .p2align 4
  .type g_signal_handler_is_connected, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handler_is_connected
#endif
g_signal_handler_is_connected:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handler_unblock
  .p2align 4
  .type g_signal_handler_unblock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handler_unblock
#endif
g_signal_handler_unblock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handlers_block_matched
  .p2align 4
  .type g_signal_handlers_block_matched, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handlers_block_matched
#endif
g_signal_handlers_block_matched:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handlers_destroy
  .p2align 4
  .type g_signal_handlers_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handlers_destroy
#endif
g_signal_handlers_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handlers_disconnect_matched
  .p2align 4
  .type g_signal_handlers_disconnect_matched, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handlers_disconnect_matched
#endif
g_signal_handlers_disconnect_matched:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_handlers_unblock_matched
  .p2align 4
  .type g_signal_handlers_unblock_matched, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_handlers_unblock_matched
#endif
g_signal_handlers_unblock_matched:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_has_handler_pending
  .p2align 4
  .type g_signal_has_handler_pending, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_has_handler_pending
#endif
g_signal_has_handler_pending:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_is_valid_name
  .p2align 4
  .type g_signal_is_valid_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_is_valid_name
#endif
g_signal_is_valid_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_list_ids
  .p2align 4
  .type g_signal_list_ids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_list_ids
#endif
g_signal_list_ids:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_lookup
  .p2align 4
  .type g_signal_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_lookup
#endif
g_signal_lookup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_name
  .p2align 4
  .type g_signal_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_name
#endif
g_signal_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_new
  .p2align 4
  .type g_signal_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_new
#endif
g_signal_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_new_class_handler
  .p2align 4
  .type g_signal_new_class_handler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_new_class_handler
#endif
g_signal_new_class_handler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_new_valist
  .p2align 4
  .type g_signal_new_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_new_valist
#endif
g_signal_new_valist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_newv
  .p2align 4
  .type g_signal_newv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_newv
#endif
g_signal_newv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_override_class_closure
  .p2align 4
  .type g_signal_override_class_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_override_class_closure
#endif
g_signal_override_class_closure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_override_class_handler
  .p2align 4
  .type g_signal_override_class_handler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_override_class_handler
#endif
g_signal_override_class_handler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_parse_name
  .p2align 4
  .type g_signal_parse_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_parse_name
#endif
g_signal_parse_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_query
  .p2align 4
  .type g_signal_query, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_query
#endif
g_signal_query:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_remove_emission_hook
  .p2align 4
  .type g_signal_remove_emission_hook, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_remove_emission_hook
#endif
g_signal_remove_emission_hook:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_set_va_marshaller
  .p2align 4
  .type g_signal_set_va_marshaller, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_set_va_marshaller
#endif
g_signal_set_va_marshaller:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_stop_emission
  .p2align 4
  .type g_signal_stop_emission, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_stop_emission
#endif
g_signal_stop_emission:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_stop_emission_by_name
  .p2align 4
  .type g_signal_stop_emission_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_stop_emission_by_name
#endif
g_signal_stop_emission_by_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_signal_type_cclosure_new
  .p2align 4
  .type g_signal_type_cclosure_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_signal_type_cclosure_new
#endif
g_signal_type_cclosure_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_source_get_type
  .p2align 4
  .type g_source_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_source_get_type
#endif
g_source_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_source_set_closure
  .p2align 4
  .type g_source_set_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_source_set_closure
#endif
g_source_set_closure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_source_set_dummy_callback
  .p2align 4
  .type g_source_set_dummy_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_source_set_dummy_callback
#endif
g_source_set_dummy_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_strdup_value_contents
  .p2align 4
  .type g_strdup_value_contents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_strdup_value_contents
#endif
g_strdup_value_contents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_strv_builder_get_type
  .p2align 4
  .type g_strv_builder_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_strv_builder_get_type
#endif
g_strv_builder_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_strv_get_type
  .p2align 4
  .type g_strv_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_strv_get_type
#endif
g_strv_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_thread_get_type
  .p2align 4
  .type g_thread_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_thread_get_type
#endif
g_thread_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_time_zone_get_type
  .p2align 4
  .type g_time_zone_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_time_zone_get_type
#endif
g_time_zone_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_tree_get_type
  .p2align 4
  .type g_tree_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_tree_get_type
#endif
g_tree_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_class_cache_func
  .p2align 4
  .type g_type_add_class_cache_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_class_cache_func
#endif
g_type_add_class_cache_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_class_private
  .p2align 4
  .type g_type_add_class_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_class_private
#endif
g_type_add_class_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_instance_private
  .p2align 4
  .type g_type_add_instance_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_instance_private
#endif
g_type_add_instance_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_interface_check
  .p2align 4
  .type g_type_add_interface_check, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_interface_check
#endif
g_type_add_interface_check:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_interface_dynamic
  .p2align 4
  .type g_type_add_interface_dynamic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_interface_dynamic
#endif
g_type_add_interface_dynamic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_add_interface_static
  .p2align 4
  .type g_type_add_interface_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_add_interface_static
#endif
g_type_add_interface_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_class_cast
  .p2align 4
  .type g_type_check_class_cast, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_class_cast
#endif
g_type_check_class_cast:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_class_is_a
  .p2align 4
  .type g_type_check_class_is_a, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_class_is_a
#endif
g_type_check_class_is_a:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_instance
  .p2align 4
  .type g_type_check_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_instance
#endif
g_type_check_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_instance_cast
  .p2align 4
  .type g_type_check_instance_cast, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_instance_cast
#endif
g_type_check_instance_cast:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_instance_is_a
  .p2align 4
  .type g_type_check_instance_is_a, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_instance_is_a
#endif
g_type_check_instance_is_a:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_instance_is_fundamentally_a
  .p2align 4
  .type g_type_check_instance_is_fundamentally_a, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_instance_is_fundamentally_a
#endif
g_type_check_instance_is_fundamentally_a:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_is_value_type
  .p2align 4
  .type g_type_check_is_value_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_is_value_type
#endif
g_type_check_is_value_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_value
  .p2align 4
  .type g_type_check_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_value
#endif
g_type_check_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_check_value_holds
  .p2align 4
  .type g_type_check_value_holds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_check_value_holds
#endif
g_type_check_value_holds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_children
  .p2align 4
  .type g_type_children, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_children
#endif
g_type_children:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_add_private
  .p2align 4
  .type g_type_class_add_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_add_private
#endif
g_type_class_add_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_adjust_private_offset
  .p2align 4
  .type g_type_class_adjust_private_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_adjust_private_offset
#endif
g_type_class_adjust_private_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_get
  .p2align 4
  .type g_type_class_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_get
#endif
g_type_class_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_get_instance_private_offset
  .p2align 4
  .type g_type_class_get_instance_private_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_get_instance_private_offset
#endif
g_type_class_get_instance_private_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_get_private
  .p2align 4
  .type g_type_class_get_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_get_private
#endif
g_type_class_get_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_peek
  .p2align 4
  .type g_type_class_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_peek
#endif
g_type_class_peek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_peek_parent
  .p2align 4
  .type g_type_class_peek_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_peek_parent
#endif
g_type_class_peek_parent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_peek_static
  .p2align 4
  .type g_type_class_peek_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_peek_static
#endif
g_type_class_peek_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_ref
  .p2align 4
  .type g_type_class_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_ref
#endif
g_type_class_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_unref
  .p2align 4
  .type g_type_class_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_unref
#endif
g_type_class_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_class_unref_uncached
  .p2align 4
  .type g_type_class_unref_uncached, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_class_unref_uncached
#endif
g_type_class_unref_uncached:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_create_instance
  .p2align 4
  .type g_type_create_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_create_instance
#endif
g_type_create_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_default_interface_get
  .p2align 4
  .type g_type_default_interface_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_default_interface_get
#endif
g_type_default_interface_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_default_interface_peek
  .p2align 4
  .type g_type_default_interface_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_default_interface_peek
#endif
g_type_default_interface_peek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_default_interface_ref
  .p2align 4
  .type g_type_default_interface_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_default_interface_ref
#endif
g_type_default_interface_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_default_interface_unref
  .p2align 4
  .type g_type_default_interface_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_default_interface_unref
#endif
g_type_default_interface_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_depth
  .p2align 4
  .type g_type_depth, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_depth
#endif
g_type_depth:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_ensure
  .p2align 4
  .type g_type_ensure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_ensure
#endif
g_type_ensure:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_free_instance
  .p2align 4
  .type g_type_free_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_free_instance
#endif
g_type_free_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_from_name
  .p2align 4
  .type g_type_from_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_from_name
#endif
g_type_from_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_fundamental
  .p2align 4
  .type g_type_fundamental, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_fundamental
#endif
g_type_fundamental:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_fundamental_next
  .p2align 4
  .type g_type_fundamental_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_fundamental_next
#endif
g_type_fundamental_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_get_instance_count
  .p2align 4
  .type g_type_get_instance_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_get_instance_count
#endif
g_type_get_instance_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_get_plugin
  .p2align 4
  .type g_type_get_plugin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_get_plugin
#endif
g_type_get_plugin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_get_qdata
  .p2align 4
  .type g_type_get_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_get_qdata
#endif
g_type_get_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_get_type_registration_serial
  .p2align 4
  .type g_type_get_type_registration_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_get_type_registration_serial
#endif
g_type_get_type_registration_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_init
  .p2align 4
  .type g_type_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_init
#endif
g_type_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_init_with_debug_flags
  .p2align 4
  .type g_type_init_with_debug_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_init_with_debug_flags
#endif
g_type_init_with_debug_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_instance_get_private
  .p2align 4
  .type g_type_instance_get_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_instance_get_private
#endif
g_type_instance_get_private:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_add_prerequisite
  .p2align 4
  .type g_type_interface_add_prerequisite, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_add_prerequisite
#endif
g_type_interface_add_prerequisite:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_get_plugin
  .p2align 4
  .type g_type_interface_get_plugin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_get_plugin
#endif
g_type_interface_get_plugin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_instantiatable_prerequisite
  .p2align 4
  .type g_type_interface_instantiatable_prerequisite, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_instantiatable_prerequisite
#endif
g_type_interface_instantiatable_prerequisite:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_peek
  .p2align 4
  .type g_type_interface_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_peek
#endif
g_type_interface_peek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_peek_parent
  .p2align 4
  .type g_type_interface_peek_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_peek_parent
#endif
g_type_interface_peek_parent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interface_prerequisites
  .p2align 4
  .type g_type_interface_prerequisites, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interface_prerequisites
#endif
g_type_interface_prerequisites:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_interfaces
  .p2align 4
  .type g_type_interfaces, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_interfaces
#endif
g_type_interfaces:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_is_a
  .p2align 4
  .type g_type_is_a, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_is_a
#endif
g_type_is_a:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_add_interface
  .p2align 4
  .type g_type_module_add_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_add_interface
#endif
g_type_module_add_interface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_get_type
  .p2align 4
  .type g_type_module_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_get_type
#endif
g_type_module_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_register_enum
  .p2align 4
  .type g_type_module_register_enum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_register_enum
#endif
g_type_module_register_enum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_register_flags
  .p2align 4
  .type g_type_module_register_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_register_flags
#endif
g_type_module_register_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_register_type
  .p2align 4
  .type g_type_module_register_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_register_type
#endif
g_type_module_register_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_set_name
  .p2align 4
  .type g_type_module_set_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_set_name
#endif
g_type_module_set_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_unuse
  .p2align 4
  .type g_type_module_unuse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_unuse
#endif
g_type_module_unuse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_module_use
  .p2align 4
  .type g_type_module_use, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_module_use
#endif
g_type_module_use:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_name
  .p2align 4
  .type g_type_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_name
#endif
g_type_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_name_from_class
  .p2align 4
  .type g_type_name_from_class, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_name_from_class
#endif
g_type_name_from_class:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_name_from_instance
  .p2align 4
  .type g_type_name_from_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_name_from_instance
#endif
g_type_name_from_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_next_base
  .p2align 4
  .type g_type_next_base, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_next_base
#endif
g_type_next_base:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_parent
  .p2align 4
  .type g_type_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_parent
#endif
g_type_parent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_plugin_complete_interface_info
  .p2align 4
  .type g_type_plugin_complete_interface_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_plugin_complete_interface_info
#endif
g_type_plugin_complete_interface_info:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_plugin_complete_type_info
  .p2align 4
  .type g_type_plugin_complete_type_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_plugin_complete_type_info
#endif
g_type_plugin_complete_type_info:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_plugin_get_type
  .p2align 4
  .type g_type_plugin_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_plugin_get_type
#endif
g_type_plugin_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_plugin_unuse
  .p2align 4
  .type g_type_plugin_unuse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_plugin_unuse
#endif
g_type_plugin_unuse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_plugin_use
  .p2align 4
  .type g_type_plugin_use, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_plugin_use
#endif
g_type_plugin_use:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_qname
  .p2align 4
  .type g_type_qname, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_qname
#endif
g_type_qname:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_query
  .p2align 4
  .type g_type_query, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_query
#endif
g_type_query:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_register_dynamic
  .p2align 4
  .type g_type_register_dynamic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_register_dynamic
#endif
g_type_register_dynamic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_register_fundamental
  .p2align 4
  .type g_type_register_fundamental, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_register_fundamental
#endif
g_type_register_fundamental:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_register_static
  .p2align 4
  .type g_type_register_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_register_static
#endif
g_type_register_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_register_static_simple
  .p2align 4
  .type g_type_register_static_simple, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_register_static_simple
#endif
g_type_register_static_simple:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_remove_class_cache_func
  .p2align 4
  .type g_type_remove_class_cache_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_remove_class_cache_func
#endif
g_type_remove_class_cache_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_remove_interface_check
  .p2align 4
  .type g_type_remove_interface_check, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_remove_interface_check
#endif
g_type_remove_interface_check:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_set_qdata
  .p2align 4
  .type g_type_set_qdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_set_qdata
#endif
g_type_set_qdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_test_flags
  .p2align 4
  .type g_type_test_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_test_flags
#endif
g_type_test_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_type_value_table_peek
  .p2align 4
  .type g_type_value_table_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_type_value_table_peek
#endif
g_type_value_table_peek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_unicode_break_type_get_type
  .p2align 4
  .type g_unicode_break_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_unicode_break_type_get_type
#endif
g_unicode_break_type_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_unicode_script_get_type
  .p2align 4
  .type g_unicode_script_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_unicode_script_get_type
#endif
g_unicode_script_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_unicode_type_get_type
  .p2align 4
  .type g_unicode_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_unicode_type_get_type
#endif
g_unicode_type_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_uri_get_type
  .p2align 4
  .type g_uri_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_uri_get_type
#endif
g_uri_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_append
  .p2align 4
  .type g_value_array_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_append
#endif
g_value_array_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_copy
  .p2align 4
  .type g_value_array_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_copy
#endif
g_value_array_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_free
  .p2align 4
  .type g_value_array_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_free
#endif
g_value_array_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_get_nth
  .p2align 4
  .type g_value_array_get_nth, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_get_nth
#endif
g_value_array_get_nth:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_get_type
  .p2align 4
  .type g_value_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_get_type
#endif
g_value_array_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_insert
  .p2align 4
  .type g_value_array_insert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_insert
#endif
g_value_array_insert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_new
  .p2align 4
  .type g_value_array_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_new
#endif
g_value_array_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_prepend
  .p2align 4
  .type g_value_array_prepend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_prepend
#endif
g_value_array_prepend:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_remove
  .p2align 4
  .type g_value_array_remove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_remove
#endif
g_value_array_remove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_sort
  .p2align 4
  .type g_value_array_sort, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_sort
#endif
g_value_array_sort:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_array_sort_with_data
  .p2align 4
  .type g_value_array_sort_with_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_array_sort_with_data
#endif
g_value_array_sort_with_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_copy
  .p2align 4
  .type g_value_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_copy
#endif
g_value_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_dup_boxed
  .p2align 4
  .type g_value_dup_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_dup_boxed
#endif
g_value_dup_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_dup_object
  .p2align 4
  .type g_value_dup_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_dup_object
#endif
g_value_dup_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_dup_param
  .p2align 4
  .type g_value_dup_param, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_dup_param
#endif
g_value_dup_param:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_dup_string
  .p2align 4
  .type g_value_dup_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_dup_string
#endif
g_value_dup_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_dup_variant
  .p2align 4
  .type g_value_dup_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_dup_variant
#endif
g_value_dup_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_fits_pointer
  .p2align 4
  .type g_value_fits_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_fits_pointer
#endif
g_value_fits_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_boolean
  .p2align 4
  .type g_value_get_boolean, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_boolean
#endif
g_value_get_boolean:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_boxed
  .p2align 4
  .type g_value_get_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_boxed
#endif
g_value_get_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_char
  .p2align 4
  .type g_value_get_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_char
#endif
g_value_get_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_double
  .p2align 4
  .type g_value_get_double, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_double
#endif
g_value_get_double:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_enum
  .p2align 4
  .type g_value_get_enum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_enum
#endif
g_value_get_enum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_flags
  .p2align 4
  .type g_value_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_flags
#endif
g_value_get_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_float
  .p2align 4
  .type g_value_get_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_float
#endif
g_value_get_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_gtype
  .p2align 4
  .type g_value_get_gtype, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_gtype
#endif
g_value_get_gtype:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_int
  .p2align 4
  .type g_value_get_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_int
#endif
g_value_get_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_int64
  .p2align 4
  .type g_value_get_int64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_int64
#endif
g_value_get_int64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_long
  .p2align 4
  .type g_value_get_long, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_long
#endif
g_value_get_long:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_object
  .p2align 4
  .type g_value_get_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_object
#endif
g_value_get_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_param
  .p2align 4
  .type g_value_get_param, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_param
#endif
g_value_get_param:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_pointer
  .p2align 4
  .type g_value_get_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_pointer
#endif
g_value_get_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_schar
  .p2align 4
  .type g_value_get_schar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_schar
#endif
g_value_get_schar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_string
  .p2align 4
  .type g_value_get_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_string
#endif
g_value_get_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_type
  .p2align 4
  .type g_value_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_type
#endif
g_value_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_uchar
  .p2align 4
  .type g_value_get_uchar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_uchar
#endif
g_value_get_uchar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_uint
  .p2align 4
  .type g_value_get_uint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_uint
#endif
g_value_get_uint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_uint64
  .p2align 4
  .type g_value_get_uint64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_uint64
#endif
g_value_get_uint64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_ulong
  .p2align 4
  .type g_value_get_ulong, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_ulong
#endif
g_value_get_ulong:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_get_variant
  .p2align 4
  .type g_value_get_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_get_variant
#endif
g_value_get_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_init
  .p2align 4
  .type g_value_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_init
#endif
g_value_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_init_from_instance
  .p2align 4
  .type g_value_init_from_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_init_from_instance
#endif
g_value_init_from_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_peek_pointer
  .p2align 4
  .type g_value_peek_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_peek_pointer
#endif
g_value_peek_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_register_transform_func
  .p2align 4
  .type g_value_register_transform_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_register_transform_func
#endif
g_value_register_transform_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_reset
  .p2align 4
  .type g_value_reset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_reset
#endif
g_value_reset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_boolean
  .p2align 4
  .type g_value_set_boolean, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_boolean
#endif
g_value_set_boolean:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_boxed
  .p2align 4
  .type g_value_set_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_boxed
#endif
g_value_set_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_boxed_take_ownership
  .p2align 4
  .type g_value_set_boxed_take_ownership, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_boxed_take_ownership
#endif
g_value_set_boxed_take_ownership:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_char
  .p2align 4
  .type g_value_set_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_char
#endif
g_value_set_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_double
  .p2align 4
  .type g_value_set_double, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_double
#endif
g_value_set_double:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_enum
  .p2align 4
  .type g_value_set_enum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_enum
#endif
g_value_set_enum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_flags
  .p2align 4
  .type g_value_set_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_flags
#endif
g_value_set_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_float
  .p2align 4
  .type g_value_set_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_float
#endif
g_value_set_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_gtype
  .p2align 4
  .type g_value_set_gtype, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_gtype
#endif
g_value_set_gtype:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_instance
  .p2align 4
  .type g_value_set_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_instance
#endif
g_value_set_instance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_int
  .p2align 4
  .type g_value_set_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_int
#endif
g_value_set_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_int64
  .p2align 4
  .type g_value_set_int64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_int64
#endif
g_value_set_int64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_interned_string
  .p2align 4
  .type g_value_set_interned_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_interned_string
#endif
g_value_set_interned_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_long
  .p2align 4
  .type g_value_set_long, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_long
#endif
g_value_set_long:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_object
  .p2align 4
  .type g_value_set_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_object
#endif
g_value_set_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_object_take_ownership
  .p2align 4
  .type g_value_set_object_take_ownership, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_object_take_ownership
#endif
g_value_set_object_take_ownership:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_param
  .p2align 4
  .type g_value_set_param, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_param
#endif
g_value_set_param:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_param_take_ownership
  .p2align 4
  .type g_value_set_param_take_ownership, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_param_take_ownership
#endif
g_value_set_param_take_ownership:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3592(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3592(%rip)
2:
  pushq $449
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_pointer
  .p2align 4
  .type g_value_set_pointer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_pointer
#endif
g_value_set_pointer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3600(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3600(%rip)
2:
  pushq $450
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_schar
  .p2align 4
  .type g_value_set_schar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_schar
#endif
g_value_set_schar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3608(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3608(%rip)
2:
  pushq $451
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_static_boxed
  .p2align 4
  .type g_value_set_static_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_static_boxed
#endif
g_value_set_static_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3616(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3616(%rip)
2:
  pushq $452
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_static_string
  .p2align 4
  .type g_value_set_static_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_static_string
#endif
g_value_set_static_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3624(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3624(%rip)
2:
  pushq $453
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_string
  .p2align 4
  .type g_value_set_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_string
#endif
g_value_set_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3632(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3632(%rip)
2:
  pushq $454
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_string_take_ownership
  .p2align 4
  .type g_value_set_string_take_ownership, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_string_take_ownership
#endif
g_value_set_string_take_ownership:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3640(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3640(%rip)
2:
  pushq $455
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_uchar
  .p2align 4
  .type g_value_set_uchar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_uchar
#endif
g_value_set_uchar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3648(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3648(%rip)
2:
  pushq $456
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_uint
  .p2align 4
  .type g_value_set_uint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_uint
#endif
g_value_set_uint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3656(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3656(%rip)
2:
  pushq $457
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_uint64
  .p2align 4
  .type g_value_set_uint64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_uint64
#endif
g_value_set_uint64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3664(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3664(%rip)
2:
  pushq $458
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_ulong
  .p2align 4
  .type g_value_set_ulong, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_ulong
#endif
g_value_set_ulong:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3672(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3672(%rip)
2:
  pushq $459
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_set_variant
  .p2align 4
  .type g_value_set_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_set_variant
#endif
g_value_set_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3680(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3680(%rip)
2:
  pushq $460
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_steal_string
  .p2align 4
  .type g_value_steal_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_steal_string
#endif
g_value_steal_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3688(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3688(%rip)
2:
  pushq $461
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_take_boxed
  .p2align 4
  .type g_value_take_boxed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_take_boxed
#endif
g_value_take_boxed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3696(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3696(%rip)
2:
  pushq $462
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_take_object
  .p2align 4
  .type g_value_take_object, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_take_object
#endif
g_value_take_object:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3704(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3704(%rip)
2:
  pushq $463
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_take_param
  .p2align 4
  .type g_value_take_param, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_take_param
#endif
g_value_take_param:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3712(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3712(%rip)
2:
  pushq $464
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_take_string
  .p2align 4
  .type g_value_take_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_take_string
#endif
g_value_take_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3720(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3720(%rip)
2:
  pushq $465
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_take_variant
  .p2align 4
  .type g_value_take_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_take_variant
#endif
g_value_take_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3728(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3728(%rip)
2:
  pushq $466
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_transform
  .p2align 4
  .type g_value_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_transform
#endif
g_value_transform:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3736(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3736(%rip)
2:
  pushq $467
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_type_compatible
  .p2align 4
  .type g_value_type_compatible, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_type_compatible
#endif
g_value_type_compatible:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3744(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3744(%rip)
2:
  pushq $468
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_type_transformable
  .p2align 4
  .type g_value_type_transformable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_type_transformable
#endif
g_value_type_transformable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3752(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3752(%rip)
2:
  pushq $469
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_value_unset
  .p2align 4
  .type g_value_unset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_value_unset
#endif
g_value_unset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3760(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3760(%rip)
2:
  pushq $470
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_variant_builder_get_type
  .p2align 4
  .type g_variant_builder_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_variant_builder_get_type
#endif
g_variant_builder_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3768(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3768(%rip)
2:
  pushq $471
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_variant_dict_get_type
  .p2align 4
  .type g_variant_dict_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_variant_dict_get_type
#endif
g_variant_dict_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3776(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3776(%rip)
2:
  pushq $472
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_variant_get_gtype
  .p2align 4
  .type g_variant_get_gtype, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_variant_get_gtype
#endif
g_variant_get_gtype:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3784(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3784(%rip)
2:
  pushq $473
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_variant_type_get_gtype
  .p2align 4
  .type g_variant_type_get_gtype, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_variant_type_get_gtype
#endif
g_variant_type_get_gtype:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3792(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3792(%rip)
2:
  pushq $474
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_weak_ref_clear
  .p2align 4
  .type g_weak_ref_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_weak_ref_clear
#endif
g_weak_ref_clear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3800(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3800(%rip)
2:
  pushq $475
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_weak_ref_get
  .p2align 4
  .type g_weak_ref_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_weak_ref_get
#endif
g_weak_ref_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3808(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3808(%rip)
2:
  pushq $476
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_weak_ref_init
  .p2align 4
  .type g_weak_ref_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_weak_ref_init
#endif
g_weak_ref_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3816(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3816(%rip)
2:
  pushq $477
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl g_weak_ref_set
  .p2align 4
  .type g_weak_ref_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_weak_ref_set
#endif
g_weak_ref_set:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgobject_2_0_so_tramp_table+3824(%rip)
  je 2f
1:
  jmp *_libgobject_2_0_so_tramp_table+3824(%rip)
2:
  pushq $478
  .cfi_adjust_cfa_offset 8
  call _libgobject_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

