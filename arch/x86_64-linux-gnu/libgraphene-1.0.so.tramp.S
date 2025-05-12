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

  .globl _libgraphene_1_0_so_tramp_table
  .hidden _libgraphene_1_0_so_tramp_table
  .align 8
_libgraphene_1_0_so_tramp_table:
  .zero 3600

  .text

  .globl _libgraphene_1_0_so_tramp_resolve
  .hidden _libgraphene_1_0_so_tramp_resolve

  .globl _libgraphene_1_0_so_save_regs_and_resolve
  .hidden _libgraphene_1_0_so_save_regs_and_resolve
  .type _libgraphene_1_0_so_save_regs_and_resolve, %function
_libgraphene_1_0_so_save_regs_and_resolve:
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
  call _libgraphene_1_0_so_tramp_resolve

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

  .globl graphene_box_alloc
  .p2align 4
  .type graphene_box_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_alloc
#endif
graphene_box_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_contains_box
  .p2align 4
  .type graphene_box_contains_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_contains_box
#endif
graphene_box_contains_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_contains_point
  .p2align 4
  .type graphene_box_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_contains_point
#endif
graphene_box_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_empty
  .p2align 4
  .type graphene_box_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_empty
#endif
graphene_box_empty:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_equal
  .p2align 4
  .type graphene_box_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_equal
#endif
graphene_box_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_expand
  .p2align 4
  .type graphene_box_expand, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_expand
#endif
graphene_box_expand:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_expand_scalar
  .p2align 4
  .type graphene_box_expand_scalar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_expand_scalar
#endif
graphene_box_expand_scalar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_expand_vec3
  .p2align 4
  .type graphene_box_expand_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_expand_vec3
#endif
graphene_box_expand_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_free
  .p2align 4
  .type graphene_box_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_free
#endif
graphene_box_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_bounding_sphere
  .p2align 4
  .type graphene_box_get_bounding_sphere, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_bounding_sphere
#endif
graphene_box_get_bounding_sphere:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_center
  .p2align 4
  .type graphene_box_get_center, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_center
#endif
graphene_box_get_center:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_depth
  .p2align 4
  .type graphene_box_get_depth, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_depth
#endif
graphene_box_get_depth:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_height
  .p2align 4
  .type graphene_box_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_height
#endif
graphene_box_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_max
  .p2align 4
  .type graphene_box_get_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_max
#endif
graphene_box_get_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_min
  .p2align 4
  .type graphene_box_get_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_min
#endif
graphene_box_get_min:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_size
  .p2align 4
  .type graphene_box_get_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_size
#endif
graphene_box_get_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_type
  .p2align 4
  .type graphene_box_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_type
#endif
graphene_box_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_vertices
  .p2align 4
  .type graphene_box_get_vertices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_vertices
#endif
graphene_box_get_vertices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_get_width
  .p2align 4
  .type graphene_box_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_get_width
#endif
graphene_box_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_infinite
  .p2align 4
  .type graphene_box_infinite, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_infinite
#endif
graphene_box_infinite:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_init
  .p2align 4
  .type graphene_box_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_init
#endif
graphene_box_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_init_from_box
  .p2align 4
  .type graphene_box_init_from_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_init_from_box
#endif
graphene_box_init_from_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_init_from_points
  .p2align 4
  .type graphene_box_init_from_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_init_from_points
#endif
graphene_box_init_from_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_init_from_vec3
  .p2align 4
  .type graphene_box_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_init_from_vec3
#endif
graphene_box_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_init_from_vectors
  .p2align 4
  .type graphene_box_init_from_vectors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_init_from_vectors
#endif
graphene_box_init_from_vectors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_intersection
  .p2align 4
  .type graphene_box_intersection, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_intersection
#endif
graphene_box_intersection:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_minus_one
  .p2align 4
  .type graphene_box_minus_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_minus_one
#endif
graphene_box_minus_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_one
  .p2align 4
  .type graphene_box_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_one
#endif
graphene_box_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_one_minus_one
  .p2align 4
  .type graphene_box_one_minus_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_one_minus_one
#endif
graphene_box_one_minus_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_union
  .p2align 4
  .type graphene_box_union, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_union
#endif
graphene_box_union:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_box_zero
  .p2align 4
  .type graphene_box_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_zero
#endif
graphene_box_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_alloc
  .p2align 4
  .type graphene_euler_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_alloc
#endif
graphene_euler_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_equal
  .p2align 4
  .type graphene_euler_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_equal
#endif
graphene_euler_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_free
  .p2align 4
  .type graphene_euler_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_free
#endif
graphene_euler_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_alpha
  .p2align 4
  .type graphene_euler_get_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_alpha
#endif
graphene_euler_get_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_beta
  .p2align 4
  .type graphene_euler_get_beta, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_beta
#endif
graphene_euler_get_beta:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_gamma
  .p2align 4
  .type graphene_euler_get_gamma, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_gamma
#endif
graphene_euler_get_gamma:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_order
  .p2align 4
  .type graphene_euler_get_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_order
#endif
graphene_euler_get_order:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_type
  .p2align 4
  .type graphene_euler_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_type
#endif
graphene_euler_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_x
  .p2align 4
  .type graphene_euler_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_x
#endif
graphene_euler_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_y
  .p2align 4
  .type graphene_euler_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_y
#endif
graphene_euler_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_get_z
  .p2align 4
  .type graphene_euler_get_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_get_z
#endif
graphene_euler_get_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init
  .p2align 4
  .type graphene_euler_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init
#endif
graphene_euler_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_from_euler
  .p2align 4
  .type graphene_euler_init_from_euler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_from_euler
#endif
graphene_euler_init_from_euler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_from_matrix
  .p2align 4
  .type graphene_euler_init_from_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_from_matrix
#endif
graphene_euler_init_from_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_from_quaternion
  .p2align 4
  .type graphene_euler_init_from_quaternion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_from_quaternion
#endif
graphene_euler_init_from_quaternion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_from_radians
  .p2align 4
  .type graphene_euler_init_from_radians, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_from_radians
#endif
graphene_euler_init_from_radians:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_from_vec3
  .p2align 4
  .type graphene_euler_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_from_vec3
#endif
graphene_euler_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_init_with_order
  .p2align 4
  .type graphene_euler_init_with_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_init_with_order
#endif
graphene_euler_init_with_order:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_reorder
  .p2align 4
  .type graphene_euler_reorder, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_reorder
#endif
graphene_euler_reorder:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_to_matrix
  .p2align 4
  .type graphene_euler_to_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_to_matrix
#endif
graphene_euler_to_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_to_quaternion
  .p2align 4
  .type graphene_euler_to_quaternion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_to_quaternion
#endif
graphene_euler_to_quaternion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_euler_to_vec3
  .p2align 4
  .type graphene_euler_to_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_euler_to_vec3
#endif
graphene_euler_to_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_alloc
  .p2align 4
  .type graphene_frustum_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_alloc
#endif
graphene_frustum_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_contains_point
  .p2align 4
  .type graphene_frustum_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_contains_point
#endif
graphene_frustum_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_equal
  .p2align 4
  .type graphene_frustum_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_equal
#endif
graphene_frustum_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_free
  .p2align 4
  .type graphene_frustum_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_free
#endif
graphene_frustum_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_get_planes
  .p2align 4
  .type graphene_frustum_get_planes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_get_planes
#endif
graphene_frustum_get_planes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_get_type
  .p2align 4
  .type graphene_frustum_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_get_type
#endif
graphene_frustum_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_init
  .p2align 4
  .type graphene_frustum_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_init
#endif
graphene_frustum_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_init_from_frustum
  .p2align 4
  .type graphene_frustum_init_from_frustum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_init_from_frustum
#endif
graphene_frustum_init_from_frustum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_init_from_matrix
  .p2align 4
  .type graphene_frustum_init_from_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_init_from_matrix
#endif
graphene_frustum_init_from_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_intersects_box
  .p2align 4
  .type graphene_frustum_intersects_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_intersects_box
#endif
graphene_frustum_intersects_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_frustum_intersects_sphere
  .p2align 4
  .type graphene_frustum_intersects_sphere, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_frustum_intersects_sphere
#endif
graphene_frustum_intersects_sphere:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_alloc
  .p2align 4
  .type graphene_matrix_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_alloc
#endif
graphene_matrix_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_decompose
  .p2align 4
  .type graphene_matrix_decompose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_decompose
#endif
graphene_matrix_decompose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_determinant
  .p2align 4
  .type graphene_matrix_determinant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_determinant
#endif
graphene_matrix_determinant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_equal
  .p2align 4
  .type graphene_matrix_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_equal
#endif
graphene_matrix_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_equal_fast
  .p2align 4
  .type graphene_matrix_equal_fast, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_equal_fast
#endif
graphene_matrix_equal_fast:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_free
  .p2align 4
  .type graphene_matrix_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_free
#endif
graphene_matrix_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_row
  .p2align 4
  .type graphene_matrix_get_row, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_row
#endif
graphene_matrix_get_row:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_type
  .p2align 4
  .type graphene_matrix_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_type
#endif
graphene_matrix_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_value
  .p2align 4
  .type graphene_matrix_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_value
#endif
graphene_matrix_get_value:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_x_scale
  .p2align 4
  .type graphene_matrix_get_x_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_x_scale
#endif
graphene_matrix_get_x_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_x_translation
  .p2align 4
  .type graphene_matrix_get_x_translation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_x_translation
#endif
graphene_matrix_get_x_translation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_y_scale
  .p2align 4
  .type graphene_matrix_get_y_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_y_scale
#endif
graphene_matrix_get_y_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_y_translation
  .p2align 4
  .type graphene_matrix_get_y_translation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_y_translation
#endif
graphene_matrix_get_y_translation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_z_scale
  .p2align 4
  .type graphene_matrix_get_z_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_z_scale
#endif
graphene_matrix_get_z_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_get_z_translation
  .p2align 4
  .type graphene_matrix_get_z_translation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_get_z_translation
#endif
graphene_matrix_get_z_translation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_from_2d
  .p2align 4
  .type graphene_matrix_init_from_2d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_from_2d
#endif
graphene_matrix_init_from_2d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_from_float
  .p2align 4
  .type graphene_matrix_init_from_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_from_float
#endif
graphene_matrix_init_from_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_from_matrix
  .p2align 4
  .type graphene_matrix_init_from_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_from_matrix
#endif
graphene_matrix_init_from_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_from_vec4
  .p2align 4
  .type graphene_matrix_init_from_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_from_vec4
#endif
graphene_matrix_init_from_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_frustum
  .p2align 4
  .type graphene_matrix_init_frustum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_frustum
#endif
graphene_matrix_init_frustum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_identity
  .p2align 4
  .type graphene_matrix_init_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_identity
#endif
graphene_matrix_init_identity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_look_at
  .p2align 4
  .type graphene_matrix_init_look_at, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_look_at
#endif
graphene_matrix_init_look_at:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_ortho
  .p2align 4
  .type graphene_matrix_init_ortho, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_ortho
#endif
graphene_matrix_init_ortho:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_perspective
  .p2align 4
  .type graphene_matrix_init_perspective, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_perspective
#endif
graphene_matrix_init_perspective:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_rotate
  .p2align 4
  .type graphene_matrix_init_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_rotate
#endif
graphene_matrix_init_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_scale
  .p2align 4
  .type graphene_matrix_init_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_scale
#endif
graphene_matrix_init_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_skew
  .p2align 4
  .type graphene_matrix_init_skew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_skew
#endif
graphene_matrix_init_skew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_init_translate
  .p2align 4
  .type graphene_matrix_init_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_init_translate
#endif
graphene_matrix_init_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_interpolate
  .p2align 4
  .type graphene_matrix_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_interpolate
#endif
graphene_matrix_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_inverse
  .p2align 4
  .type graphene_matrix_inverse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_inverse
#endif
graphene_matrix_inverse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_is_2d
  .p2align 4
  .type graphene_matrix_is_2d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_is_2d
#endif
graphene_matrix_is_2d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_is_backface_visible
  .p2align 4
  .type graphene_matrix_is_backface_visible, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_is_backface_visible
#endif
graphene_matrix_is_backface_visible:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_is_identity
  .p2align 4
  .type graphene_matrix_is_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_is_identity
#endif
graphene_matrix_is_identity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_is_singular
  .p2align 4
  .type graphene_matrix_is_singular, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_is_singular
#endif
graphene_matrix_is_singular:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_multiply
  .p2align 4
  .type graphene_matrix_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_multiply
#endif
graphene_matrix_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_near
  .p2align 4
  .type graphene_matrix_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_near
#endif
graphene_matrix_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_normalize
  .p2align 4
  .type graphene_matrix_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_normalize
#endif
graphene_matrix_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_perspective
  .p2align 4
  .type graphene_matrix_perspective, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_perspective
#endif
graphene_matrix_perspective:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_print
  .p2align 4
  .type graphene_matrix_print, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_print
#endif
graphene_matrix_print:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_project_point
  .p2align 4
  .type graphene_matrix_project_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_project_point
#endif
graphene_matrix_project_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_project_rect
  .p2align 4
  .type graphene_matrix_project_rect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_project_rect
#endif
graphene_matrix_project_rect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_project_rect_bounds
  .p2align 4
  .type graphene_matrix_project_rect_bounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_project_rect_bounds
#endif
graphene_matrix_project_rect_bounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate
  .p2align 4
  .type graphene_matrix_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate
#endif
graphene_matrix_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate_euler
  .p2align 4
  .type graphene_matrix_rotate_euler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate_euler
#endif
graphene_matrix_rotate_euler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate_quaternion
  .p2align 4
  .type graphene_matrix_rotate_quaternion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate_quaternion
#endif
graphene_matrix_rotate_quaternion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate_x
  .p2align 4
  .type graphene_matrix_rotate_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate_x
#endif
graphene_matrix_rotate_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate_y
  .p2align 4
  .type graphene_matrix_rotate_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate_y
#endif
graphene_matrix_rotate_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_rotate_z
  .p2align 4
  .type graphene_matrix_rotate_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_rotate_z
#endif
graphene_matrix_rotate_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_scale
  .p2align 4
  .type graphene_matrix_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_scale
#endif
graphene_matrix_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_skew_xy
  .p2align 4
  .type graphene_matrix_skew_xy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_skew_xy
#endif
graphene_matrix_skew_xy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_skew_xz
  .p2align 4
  .type graphene_matrix_skew_xz, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_skew_xz
#endif
graphene_matrix_skew_xz:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_skew_yz
  .p2align 4
  .type graphene_matrix_skew_yz, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_skew_yz
#endif
graphene_matrix_skew_yz:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_to_2d
  .p2align 4
  .type graphene_matrix_to_2d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_to_2d
#endif
graphene_matrix_to_2d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_to_float
  .p2align 4
  .type graphene_matrix_to_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_to_float
#endif
graphene_matrix_to_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_bounds
  .p2align 4
  .type graphene_matrix_transform_bounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_bounds
#endif
graphene_matrix_transform_bounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_box
  .p2align 4
  .type graphene_matrix_transform_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_box
#endif
graphene_matrix_transform_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_point
  .p2align 4
  .type graphene_matrix_transform_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_point
#endif
graphene_matrix_transform_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_point3d
  .p2align 4
  .type graphene_matrix_transform_point3d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_point3d
#endif
graphene_matrix_transform_point3d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_ray
  .p2align 4
  .type graphene_matrix_transform_ray, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_ray
#endif
graphene_matrix_transform_ray:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_rect
  .p2align 4
  .type graphene_matrix_transform_rect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_rect
#endif
graphene_matrix_transform_rect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_sphere
  .p2align 4
  .type graphene_matrix_transform_sphere, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_sphere
#endif
graphene_matrix_transform_sphere:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_vec3
  .p2align 4
  .type graphene_matrix_transform_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_vec3
#endif
graphene_matrix_transform_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transform_vec4
  .p2align 4
  .type graphene_matrix_transform_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transform_vec4
#endif
graphene_matrix_transform_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_translate
  .p2align 4
  .type graphene_matrix_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_translate
#endif
graphene_matrix_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_transpose
  .p2align 4
  .type graphene_matrix_transpose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_transpose
#endif
graphene_matrix_transpose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_unproject_point3d
  .p2align 4
  .type graphene_matrix_unproject_point3d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_unproject_point3d
#endif
graphene_matrix_unproject_point3d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_untransform_bounds
  .p2align 4
  .type graphene_matrix_untransform_bounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_untransform_bounds
#endif
graphene_matrix_untransform_bounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_matrix_untransform_point
  .p2align 4
  .type graphene_matrix_untransform_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_matrix_untransform_point
#endif
graphene_matrix_untransform_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_alloc
  .p2align 4
  .type graphene_plane_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_alloc
#endif
graphene_plane_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_distance
  .p2align 4
  .type graphene_plane_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_distance
#endif
graphene_plane_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_equal
  .p2align 4
  .type graphene_plane_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_equal
#endif
graphene_plane_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_free
  .p2align 4
  .type graphene_plane_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_free
#endif
graphene_plane_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_get_constant
  .p2align 4
  .type graphene_plane_get_constant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_get_constant
#endif
graphene_plane_get_constant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_get_normal
  .p2align 4
  .type graphene_plane_get_normal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_get_normal
#endif
graphene_plane_get_normal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_get_type
  .p2align 4
  .type graphene_plane_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_get_type
#endif
graphene_plane_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_init
  .p2align 4
  .type graphene_plane_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_init
#endif
graphene_plane_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_init_from_plane
  .p2align 4
  .type graphene_plane_init_from_plane, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_init_from_plane
#endif
graphene_plane_init_from_plane:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_init_from_point
  .p2align 4
  .type graphene_plane_init_from_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_init_from_point
#endif
graphene_plane_init_from_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_init_from_points
  .p2align 4
  .type graphene_plane_init_from_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_init_from_points
#endif
graphene_plane_init_from_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_init_from_vec4
  .p2align 4
  .type graphene_plane_init_from_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_init_from_vec4
#endif
graphene_plane_init_from_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_negate
  .p2align 4
  .type graphene_plane_negate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_negate
#endif
graphene_plane_negate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_normalize
  .p2align 4
  .type graphene_plane_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_normalize
#endif
graphene_plane_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_plane_transform
  .p2align 4
  .type graphene_plane_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_plane_transform
#endif
graphene_plane_transform:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_alloc
  .p2align 4
  .type graphene_point3d_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_alloc
#endif
graphene_point3d_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_cross
  .p2align 4
  .type graphene_point3d_cross, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_cross
#endif
graphene_point3d_cross:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_distance
  .p2align 4
  .type graphene_point3d_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_distance
#endif
graphene_point3d_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_dot
  .p2align 4
  .type graphene_point3d_dot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_dot
#endif
graphene_point3d_dot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_equal
  .p2align 4
  .type graphene_point3d_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_equal
#endif
graphene_point3d_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_free
  .p2align 4
  .type graphene_point3d_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_free
#endif
graphene_point3d_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_get_type
  .p2align 4
  .type graphene_point3d_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_get_type
#endif
graphene_point3d_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_init
  .p2align 4
  .type graphene_point3d_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_init
#endif
graphene_point3d_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_init_from_point
  .p2align 4
  .type graphene_point3d_init_from_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_init_from_point
#endif
graphene_point3d_init_from_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_init_from_vec3
  .p2align 4
  .type graphene_point3d_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_init_from_vec3
#endif
graphene_point3d_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_interpolate
  .p2align 4
  .type graphene_point3d_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_interpolate
#endif
graphene_point3d_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_length
  .p2align 4
  .type graphene_point3d_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_length
#endif
graphene_point3d_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_near
  .p2align 4
  .type graphene_point3d_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_near
#endif
graphene_point3d_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_normalize
  .p2align 4
  .type graphene_point3d_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_normalize
#endif
graphene_point3d_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_normalize_viewport
  .p2align 4
  .type graphene_point3d_normalize_viewport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_normalize_viewport
#endif
graphene_point3d_normalize_viewport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_scale
  .p2align 4
  .type graphene_point3d_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_scale
#endif
graphene_point3d_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_to_vec3
  .p2align 4
  .type graphene_point3d_to_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_to_vec3
#endif
graphene_point3d_to_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point3d_zero
  .p2align 4
  .type graphene_point3d_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point3d_zero
#endif
graphene_point3d_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_alloc
  .p2align 4
  .type graphene_point_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_alloc
#endif
graphene_point_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_distance
  .p2align 4
  .type graphene_point_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_distance
#endif
graphene_point_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_equal
  .p2align 4
  .type graphene_point_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_equal
#endif
graphene_point_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_free
  .p2align 4
  .type graphene_point_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_free
#endif
graphene_point_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_get_type
  .p2align 4
  .type graphene_point_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_get_type
#endif
graphene_point_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_init
  .p2align 4
  .type graphene_point_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_init
#endif
graphene_point_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_init_from_point
  .p2align 4
  .type graphene_point_init_from_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_init_from_point
#endif
graphene_point_init_from_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_init_from_vec2
  .p2align 4
  .type graphene_point_init_from_vec2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_init_from_vec2
#endif
graphene_point_init_from_vec2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_interpolate
  .p2align 4
  .type graphene_point_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_interpolate
#endif
graphene_point_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_near
  .p2align 4
  .type graphene_point_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_near
#endif
graphene_point_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_to_vec2
  .p2align 4
  .type graphene_point_to_vec2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_to_vec2
#endif
graphene_point_to_vec2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_point_zero
  .p2align 4
  .type graphene_point_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_point_zero
#endif
graphene_point_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_alloc
  .p2align 4
  .type graphene_quad_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_alloc
#endif
graphene_quad_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_bounds
  .p2align 4
  .type graphene_quad_bounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_bounds
#endif
graphene_quad_bounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_contains
  .p2align 4
  .type graphene_quad_contains, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_contains
#endif
graphene_quad_contains:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_free
  .p2align 4
  .type graphene_quad_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_free
#endif
graphene_quad_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_get_point
  .p2align 4
  .type graphene_quad_get_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_get_point
#endif
graphene_quad_get_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_get_type
  .p2align 4
  .type graphene_quad_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_get_type
#endif
graphene_quad_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_init
  .p2align 4
  .type graphene_quad_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_init
#endif
graphene_quad_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_init_from_points
  .p2align 4
  .type graphene_quad_init_from_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_init_from_points
#endif
graphene_quad_init_from_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quad_init_from_rect
  .p2align 4
  .type graphene_quad_init_from_rect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quad_init_from_rect
#endif
graphene_quad_init_from_rect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_add
  .p2align 4
  .type graphene_quaternion_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_add
#endif
graphene_quaternion_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_alloc
  .p2align 4
  .type graphene_quaternion_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_alloc
#endif
graphene_quaternion_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_dot
  .p2align 4
  .type graphene_quaternion_dot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_dot
#endif
graphene_quaternion_dot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_equal
  .p2align 4
  .type graphene_quaternion_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_equal
#endif
graphene_quaternion_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_free
  .p2align 4
  .type graphene_quaternion_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_free
#endif
graphene_quaternion_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_get_type
  .p2align 4
  .type graphene_quaternion_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_get_type
#endif
graphene_quaternion_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init
  .p2align 4
  .type graphene_quaternion_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init
#endif
graphene_quaternion_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_angle_vec3
  .p2align 4
  .type graphene_quaternion_init_from_angle_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_angle_vec3
#endif
graphene_quaternion_init_from_angle_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_angles
  .p2align 4
  .type graphene_quaternion_init_from_angles, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_angles
#endif
graphene_quaternion_init_from_angles:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_euler
  .p2align 4
  .type graphene_quaternion_init_from_euler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_euler
#endif
graphene_quaternion_init_from_euler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_matrix
  .p2align 4
  .type graphene_quaternion_init_from_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_matrix
#endif
graphene_quaternion_init_from_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_quaternion
  .p2align 4
  .type graphene_quaternion_init_from_quaternion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_quaternion
#endif
graphene_quaternion_init_from_quaternion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_radians
  .p2align 4
  .type graphene_quaternion_init_from_radians, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_radians
#endif
graphene_quaternion_init_from_radians:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_from_vec4
  .p2align 4
  .type graphene_quaternion_init_from_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_from_vec4
#endif
graphene_quaternion_init_from_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_init_identity
  .p2align 4
  .type graphene_quaternion_init_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_init_identity
#endif
graphene_quaternion_init_identity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_invert
  .p2align 4
  .type graphene_quaternion_invert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_invert
#endif
graphene_quaternion_invert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_multiply
  .p2align 4
  .type graphene_quaternion_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_multiply
#endif
graphene_quaternion_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_normalize
  .p2align 4
  .type graphene_quaternion_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_normalize
#endif
graphene_quaternion_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_scale
  .p2align 4
  .type graphene_quaternion_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_scale
#endif
graphene_quaternion_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_slerp
  .p2align 4
  .type graphene_quaternion_slerp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_slerp
#endif
graphene_quaternion_slerp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_to_angle_vec3
  .p2align 4
  .type graphene_quaternion_to_angle_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_to_angle_vec3
#endif
graphene_quaternion_to_angle_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_to_angles
  .p2align 4
  .type graphene_quaternion_to_angles, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_to_angles
#endif
graphene_quaternion_to_angles:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_to_matrix
  .p2align 4
  .type graphene_quaternion_to_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_to_matrix
#endif
graphene_quaternion_to_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_to_radians
  .p2align 4
  .type graphene_quaternion_to_radians, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_to_radians
#endif
graphene_quaternion_to_radians:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_quaternion_to_vec4
  .p2align 4
  .type graphene_quaternion_to_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_quaternion_to_vec4
#endif
graphene_quaternion_to_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_alloc
  .p2align 4
  .type graphene_ray_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_alloc
#endif
graphene_ray_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_equal
  .p2align 4
  .type graphene_ray_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_equal
#endif
graphene_ray_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_free
  .p2align 4
  .type graphene_ray_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_free
#endif
graphene_ray_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_closest_point_to_point
  .p2align 4
  .type graphene_ray_get_closest_point_to_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_closest_point_to_point
#endif
graphene_ray_get_closest_point_to_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_direction
  .p2align 4
  .type graphene_ray_get_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_direction
#endif
graphene_ray_get_direction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_distance_to_plane
  .p2align 4
  .type graphene_ray_get_distance_to_plane, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_distance_to_plane
#endif
graphene_ray_get_distance_to_plane:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_distance_to_point
  .p2align 4
  .type graphene_ray_get_distance_to_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_distance_to_point
#endif
graphene_ray_get_distance_to_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_origin
  .p2align 4
  .type graphene_ray_get_origin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_origin
#endif
graphene_ray_get_origin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_position_at
  .p2align 4
  .type graphene_ray_get_position_at, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_position_at
#endif
graphene_ray_get_position_at:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_get_type
  .p2align 4
  .type graphene_ray_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_get_type
#endif
graphene_ray_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_init
  .p2align 4
  .type graphene_ray_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_init
#endif
graphene_ray_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_init_from_ray
  .p2align 4
  .type graphene_ray_init_from_ray, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_init_from_ray
#endif
graphene_ray_init_from_ray:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_init_from_vec3
  .p2align 4
  .type graphene_ray_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_init_from_vec3
#endif
graphene_ray_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersect_box
  .p2align 4
  .type graphene_ray_intersect_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersect_box
#endif
graphene_ray_intersect_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersect_sphere
  .p2align 4
  .type graphene_ray_intersect_sphere, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersect_sphere
#endif
graphene_ray_intersect_sphere:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersect_triangle
  .p2align 4
  .type graphene_ray_intersect_triangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersect_triangle
#endif
graphene_ray_intersect_triangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersects_box
  .p2align 4
  .type graphene_ray_intersects_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersects_box
#endif
graphene_ray_intersects_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersects_sphere
  .p2align 4
  .type graphene_ray_intersects_sphere, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersects_sphere
#endif
graphene_ray_intersects_sphere:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_ray_intersects_triangle
  .p2align 4
  .type graphene_ray_intersects_triangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_ray_intersects_triangle
#endif
graphene_ray_intersects_triangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_alloc
  .p2align 4
  .type graphene_rect_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_alloc
#endif
graphene_rect_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_contains_point
  .p2align 4
  .type graphene_rect_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_contains_point
#endif
graphene_rect_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_contains_rect
  .p2align 4
  .type graphene_rect_contains_rect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_contains_rect
#endif
graphene_rect_contains_rect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_equal
  .p2align 4
  .type graphene_rect_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_equal
#endif
graphene_rect_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_expand
  .p2align 4
  .type graphene_rect_expand, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_expand
#endif
graphene_rect_expand:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_free
  .p2align 4
  .type graphene_rect_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_free
#endif
graphene_rect_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_area
  .p2align 4
  .type graphene_rect_get_area, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_area
#endif
graphene_rect_get_area:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_bottom_left
  .p2align 4
  .type graphene_rect_get_bottom_left, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_bottom_left
#endif
graphene_rect_get_bottom_left:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_bottom_right
  .p2align 4
  .type graphene_rect_get_bottom_right, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_bottom_right
#endif
graphene_rect_get_bottom_right:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_center
  .p2align 4
  .type graphene_rect_get_center, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_center
#endif
graphene_rect_get_center:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_height
  .p2align 4
  .type graphene_rect_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_height
#endif
graphene_rect_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_top_left
  .p2align 4
  .type graphene_rect_get_top_left, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_top_left
#endif
graphene_rect_get_top_left:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_top_right
  .p2align 4
  .type graphene_rect_get_top_right, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_top_right
#endif
graphene_rect_get_top_right:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_type
  .p2align 4
  .type graphene_rect_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_type
#endif
graphene_rect_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_vertices
  .p2align 4
  .type graphene_rect_get_vertices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_vertices
#endif
graphene_rect_get_vertices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_width
  .p2align 4
  .type graphene_rect_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_width
#endif
graphene_rect_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_x
  .p2align 4
  .type graphene_rect_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_x
#endif
graphene_rect_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_get_y
  .p2align 4
  .type graphene_rect_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_get_y
#endif
graphene_rect_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_init
  .p2align 4
  .type graphene_rect_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_init
#endif
graphene_rect_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_init_from_rect
  .p2align 4
  .type graphene_rect_init_from_rect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_init_from_rect
#endif
graphene_rect_init_from_rect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_inset
  .p2align 4
  .type graphene_rect_inset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_inset
#endif
graphene_rect_inset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_inset_r
  .p2align 4
  .type graphene_rect_inset_r, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_inset_r
#endif
graphene_rect_inset_r:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_interpolate
  .p2align 4
  .type graphene_rect_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_interpolate
#endif
graphene_rect_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_intersection
  .p2align 4
  .type graphene_rect_intersection, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_intersection
#endif
graphene_rect_intersection:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_normalize
  .p2align 4
  .type graphene_rect_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_normalize
#endif
graphene_rect_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_normalize_r
  .p2align 4
  .type graphene_rect_normalize_r, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_normalize_r
#endif
graphene_rect_normalize_r:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_offset
  .p2align 4
  .type graphene_rect_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_offset
#endif
graphene_rect_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_offset_r
  .p2align 4
  .type graphene_rect_offset_r, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_offset_r
#endif
graphene_rect_offset_r:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_round
  .p2align 4
  .type graphene_rect_round, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_round
#endif
graphene_rect_round:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_round_extents
  .p2align 4
  .type graphene_rect_round_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_round_extents
#endif
graphene_rect_round_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_round_to_pixel
  .p2align 4
  .type graphene_rect_round_to_pixel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_round_to_pixel
#endif
graphene_rect_round_to_pixel:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_scale
  .p2align 4
  .type graphene_rect_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_scale
#endif
graphene_rect_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_union
  .p2align 4
  .type graphene_rect_union, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_union
#endif
graphene_rect_union:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_rect_zero
  .p2align 4
  .type graphene_rect_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_rect_zero
#endif
graphene_rect_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_add
  .p2align 4
  .type graphene_simd4f_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_add
#endif
graphene_simd4f_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_eq
  .p2align 4
  .type graphene_simd4f_cmp_eq, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_eq
#endif
graphene_simd4f_cmp_eq:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_ge
  .p2align 4
  .type graphene_simd4f_cmp_ge, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_ge
#endif
graphene_simd4f_cmp_ge:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_gt
  .p2align 4
  .type graphene_simd4f_cmp_gt, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_gt
#endif
graphene_simd4f_cmp_gt:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_le
  .p2align 4
  .type graphene_simd4f_cmp_le, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_le
#endif
graphene_simd4f_cmp_le:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_lt
  .p2align 4
  .type graphene_simd4f_cmp_lt, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_lt
#endif
graphene_simd4f_cmp_lt:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cmp_neq
  .p2align 4
  .type graphene_simd4f_cmp_neq, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cmp_neq
#endif
graphene_simd4f_cmp_neq:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_cross3
  .p2align 4
  .type graphene_simd4f_cross3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_cross3
#endif
graphene_simd4f_cross3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_div
  .p2align 4
  .type graphene_simd4f_div, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_div
#endif
graphene_simd4f_div:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_dot3
  .p2align 4
  .type graphene_simd4f_dot3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_dot3
#endif
graphene_simd4f_dot3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_dot3_scalar
  .p2align 4
  .type graphene_simd4f_dot3_scalar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_dot3_scalar
#endif
graphene_simd4f_dot3_scalar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_dup_2f
  .p2align 4
  .type graphene_simd4f_dup_2f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_dup_2f
#endif
graphene_simd4f_dup_2f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_dup_3f
  .p2align 4
  .type graphene_simd4f_dup_3f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_dup_3f
#endif
graphene_simd4f_dup_3f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_dup_4f
  .p2align 4
  .type graphene_simd4f_dup_4f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_dup_4f
#endif
graphene_simd4f_dup_4f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_flip_sign_0101
  .p2align 4
  .type graphene_simd4f_flip_sign_0101, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_flip_sign_0101
#endif
graphene_simd4f_flip_sign_0101:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_flip_sign_1010
  .p2align 4
  .type graphene_simd4f_flip_sign_1010, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_flip_sign_1010
#endif
graphene_simd4f_flip_sign_1010:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_get
  .p2align 4
  .type graphene_simd4f_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_get
#endif
graphene_simd4f_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_get_w
  .p2align 4
  .type graphene_simd4f_get_w, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_get_w
#endif
graphene_simd4f_get_w:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_get_x
  .p2align 4
  .type graphene_simd4f_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_get_x
#endif
graphene_simd4f_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_get_y
  .p2align 4
  .type graphene_simd4f_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_get_y
#endif
graphene_simd4f_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_get_z
  .p2align 4
  .type graphene_simd4f_get_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_get_z
#endif
graphene_simd4f_get_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_init
  .p2align 4
  .type graphene_simd4f_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_init
#endif
graphene_simd4f_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_init_2f
  .p2align 4
  .type graphene_simd4f_init_2f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_init_2f
#endif
graphene_simd4f_init_2f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_init_3f
  .p2align 4
  .type graphene_simd4f_init_3f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_init_3f
#endif
graphene_simd4f_init_3f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_init_4f
  .p2align 4
  .type graphene_simd4f_init_4f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_init_4f
#endif
graphene_simd4f_init_4f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_init_zero
  .p2align 4
  .type graphene_simd4f_init_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_init_zero
#endif
graphene_simd4f_init_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_max
  .p2align 4
  .type graphene_simd4f_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_max
#endif
graphene_simd4f_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_merge_high
  .p2align 4
  .type graphene_simd4f_merge_high, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_merge_high
#endif
graphene_simd4f_merge_high:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_merge_low
  .p2align 4
  .type graphene_simd4f_merge_low, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_merge_low
#endif
graphene_simd4f_merge_low:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_merge_w
  .p2align 4
  .type graphene_simd4f_merge_w, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_merge_w
#endif
graphene_simd4f_merge_w:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_min
  .p2align 4
  .type graphene_simd4f_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_min
#endif
graphene_simd4f_min:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_mul
  .p2align 4
  .type graphene_simd4f_mul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_mul
#endif
graphene_simd4f_mul:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_neg
  .p2align 4
  .type graphene_simd4f_neg, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_neg
#endif
graphene_simd4f_neg:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_reciprocal
  .p2align 4
  .type graphene_simd4f_reciprocal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_reciprocal
#endif
graphene_simd4f_reciprocal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_rsqrt
  .p2align 4
  .type graphene_simd4f_rsqrt, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_rsqrt
#endif
graphene_simd4f_rsqrt:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_shuffle_wxyz
  .p2align 4
  .type graphene_simd4f_shuffle_wxyz, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_shuffle_wxyz
#endif
graphene_simd4f_shuffle_wxyz:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_shuffle_yzwx
  .p2align 4
  .type graphene_simd4f_shuffle_yzwx, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_shuffle_yzwx
#endif
graphene_simd4f_shuffle_yzwx:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_shuffle_zwxy
  .p2align 4
  .type graphene_simd4f_shuffle_zwxy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_shuffle_zwxy
#endif
graphene_simd4f_shuffle_zwxy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_splat
  .p2align 4
  .type graphene_simd4f_splat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_splat
#endif
graphene_simd4f_splat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_splat_w
  .p2align 4
  .type graphene_simd4f_splat_w, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_splat_w
#endif
graphene_simd4f_splat_w:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_splat_x
  .p2align 4
  .type graphene_simd4f_splat_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_splat_x
#endif
graphene_simd4f_splat_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_splat_y
  .p2align 4
  .type graphene_simd4f_splat_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_splat_y
#endif
graphene_simd4f_splat_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_splat_z
  .p2align 4
  .type graphene_simd4f_splat_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_splat_z
#endif
graphene_simd4f_splat_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_sqrt
  .p2align 4
  .type graphene_simd4f_sqrt, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_sqrt
#endif
graphene_simd4f_sqrt:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_sub
  .p2align 4
  .type graphene_simd4f_sub, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_sub
#endif
graphene_simd4f_sub:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_zero_w
  .p2align 4
  .type graphene_simd4f_zero_w, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_zero_w
#endif
graphene_simd4f_zero_w:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4f_zero_zw
  .p2align 4
  .type graphene_simd4f_zero_zw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4f_zero_zw
#endif
graphene_simd4f_zero_zw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_simd4x4f_transpose_in_place
  .p2align 4
  .type graphene_simd4x4f_transpose_in_place, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_simd4x4f_transpose_in_place
#endif
graphene_simd4x4f_transpose_in_place:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_alloc
  .p2align 4
  .type graphene_size_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_alloc
#endif
graphene_size_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_equal
  .p2align 4
  .type graphene_size_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_equal
#endif
graphene_size_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_free
  .p2align 4
  .type graphene_size_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_free
#endif
graphene_size_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_get_type
  .p2align 4
  .type graphene_size_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_get_type
#endif
graphene_size_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_init
  .p2align 4
  .type graphene_size_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_init
#endif
graphene_size_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_init_from_size
  .p2align 4
  .type graphene_size_init_from_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_init_from_size
#endif
graphene_size_init_from_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_interpolate
  .p2align 4
  .type graphene_size_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_interpolate
#endif
graphene_size_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_scale
  .p2align 4
  .type graphene_size_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_scale
#endif
graphene_size_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_size_zero
  .p2align 4
  .type graphene_size_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_size_zero
#endif
graphene_size_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_alloc
  .p2align 4
  .type graphene_sphere_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_alloc
#endif
graphene_sphere_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_contains_point
  .p2align 4
  .type graphene_sphere_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_contains_point
#endif
graphene_sphere_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_distance
  .p2align 4
  .type graphene_sphere_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_distance
#endif
graphene_sphere_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_equal
  .p2align 4
  .type graphene_sphere_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_equal
#endif
graphene_sphere_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_free
  .p2align 4
  .type graphene_sphere_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_free
#endif
graphene_sphere_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_get_bounding_box
  .p2align 4
  .type graphene_sphere_get_bounding_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_get_bounding_box
#endif
graphene_sphere_get_bounding_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_get_center
  .p2align 4
  .type graphene_sphere_get_center, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_get_center
#endif
graphene_sphere_get_center:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_get_radius
  .p2align 4
  .type graphene_sphere_get_radius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_get_radius
#endif
graphene_sphere_get_radius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_get_type
  .p2align 4
  .type graphene_sphere_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_get_type
#endif
graphene_sphere_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_init
  .p2align 4
  .type graphene_sphere_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_init
#endif
graphene_sphere_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_init_from_points
  .p2align 4
  .type graphene_sphere_init_from_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_init_from_points
#endif
graphene_sphere_init_from_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_init_from_vectors
  .p2align 4
  .type graphene_sphere_init_from_vectors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_init_from_vectors
#endif
graphene_sphere_init_from_vectors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_is_empty
  .p2align 4
  .type graphene_sphere_is_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_is_empty
#endif
graphene_sphere_is_empty:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_sphere_translate
  .p2align 4
  .type graphene_sphere_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_sphere_translate
#endif
graphene_sphere_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_alloc
  .p2align 4
  .type graphene_triangle_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_alloc
#endif
graphene_triangle_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_contains_point
  .p2align 4
  .type graphene_triangle_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_contains_point
#endif
graphene_triangle_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_equal
  .p2align 4
  .type graphene_triangle_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_equal
#endif
graphene_triangle_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_free
  .p2align 4
  .type graphene_triangle_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_free
#endif
graphene_triangle_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_area
  .p2align 4
  .type graphene_triangle_get_area, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_area
#endif
graphene_triangle_get_area:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_barycoords
  .p2align 4
  .type graphene_triangle_get_barycoords, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_barycoords
#endif
graphene_triangle_get_barycoords:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_bounding_box
  .p2align 4
  .type graphene_triangle_get_bounding_box, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_bounding_box
#endif
graphene_triangle_get_bounding_box:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_midpoint
  .p2align 4
  .type graphene_triangle_get_midpoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_midpoint
#endif
graphene_triangle_get_midpoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_normal
  .p2align 4
  .type graphene_triangle_get_normal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_normal
#endif
graphene_triangle_get_normal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_plane
  .p2align 4
  .type graphene_triangle_get_plane, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_plane
#endif
graphene_triangle_get_plane:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_points
  .p2align 4
  .type graphene_triangle_get_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_points
#endif
graphene_triangle_get_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_type
  .p2align 4
  .type graphene_triangle_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_type
#endif
graphene_triangle_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_uv
  .p2align 4
  .type graphene_triangle_get_uv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_uv
#endif
graphene_triangle_get_uv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_get_vertices
  .p2align 4
  .type graphene_triangle_get_vertices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_get_vertices
#endif
graphene_triangle_get_vertices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_init_from_float
  .p2align 4
  .type graphene_triangle_init_from_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_init_from_float
#endif
graphene_triangle_init_from_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_init_from_point3d
  .p2align 4
  .type graphene_triangle_init_from_point3d, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_init_from_point3d
#endif
graphene_triangle_init_from_point3d:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_triangle_init_from_vec3
  .p2align 4
  .type graphene_triangle_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_triangle_init_from_vec3
#endif
graphene_triangle_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_add
  .p2align 4
  .type graphene_vec2_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_add
#endif
graphene_vec2_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_alloc
  .p2align 4
  .type graphene_vec2_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_alloc
#endif
graphene_vec2_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_divide
  .p2align 4
  .type graphene_vec2_divide, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_divide
#endif
graphene_vec2_divide:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_dot
  .p2align 4
  .type graphene_vec2_dot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_dot
#endif
graphene_vec2_dot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_equal
  .p2align 4
  .type graphene_vec2_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_equal
#endif
graphene_vec2_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_free
  .p2align 4
  .type graphene_vec2_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_free
#endif
graphene_vec2_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_get_type
  .p2align 4
  .type graphene_vec2_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_get_type
#endif
graphene_vec2_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_get_x
  .p2align 4
  .type graphene_vec2_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_get_x
#endif
graphene_vec2_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_get_y
  .p2align 4
  .type graphene_vec2_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_get_y
#endif
graphene_vec2_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_init
  .p2align 4
  .type graphene_vec2_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_init
#endif
graphene_vec2_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_init_from_float
  .p2align 4
  .type graphene_vec2_init_from_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_init_from_float
#endif
graphene_vec2_init_from_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_init_from_vec2
  .p2align 4
  .type graphene_vec2_init_from_vec2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_init_from_vec2
#endif
graphene_vec2_init_from_vec2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_interpolate
  .p2align 4
  .type graphene_vec2_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_interpolate
#endif
graphene_vec2_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_length
  .p2align 4
  .type graphene_vec2_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_length
#endif
graphene_vec2_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_max
  .p2align 4
  .type graphene_vec2_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_max
#endif
graphene_vec2_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_min
  .p2align 4
  .type graphene_vec2_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_min
#endif
graphene_vec2_min:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_multiply
  .p2align 4
  .type graphene_vec2_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_multiply
#endif
graphene_vec2_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_near
  .p2align 4
  .type graphene_vec2_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_near
#endif
graphene_vec2_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_negate
  .p2align 4
  .type graphene_vec2_negate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_negate
#endif
graphene_vec2_negate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_normalize
  .p2align 4
  .type graphene_vec2_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_normalize
#endif
graphene_vec2_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_one
  .p2align 4
  .type graphene_vec2_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_one
#endif
graphene_vec2_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_scale
  .p2align 4
  .type graphene_vec2_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_scale
#endif
graphene_vec2_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_subtract
  .p2align 4
  .type graphene_vec2_subtract, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_subtract
#endif
graphene_vec2_subtract:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_to_float
  .p2align 4
  .type graphene_vec2_to_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_to_float
#endif
graphene_vec2_to_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_x_axis
  .p2align 4
  .type graphene_vec2_x_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_x_axis
#endif
graphene_vec2_x_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_y_axis
  .p2align 4
  .type graphene_vec2_y_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_y_axis
#endif
graphene_vec2_y_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec2_zero
  .p2align 4
  .type graphene_vec2_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec2_zero
#endif
graphene_vec2_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_add
  .p2align 4
  .type graphene_vec3_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_add
#endif
graphene_vec3_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_alloc
  .p2align 4
  .type graphene_vec3_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_alloc
#endif
graphene_vec3_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_cross
  .p2align 4
  .type graphene_vec3_cross, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_cross
#endif
graphene_vec3_cross:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_divide
  .p2align 4
  .type graphene_vec3_divide, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_divide
#endif
graphene_vec3_divide:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_dot
  .p2align 4
  .type graphene_vec3_dot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_dot
#endif
graphene_vec3_dot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_equal
  .p2align 4
  .type graphene_vec3_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_equal
#endif
graphene_vec3_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_free
  .p2align 4
  .type graphene_vec3_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_free
#endif
graphene_vec3_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_type
  .p2align 4
  .type graphene_vec3_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_type
#endif
graphene_vec3_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_x
  .p2align 4
  .type graphene_vec3_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_x
#endif
graphene_vec3_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_xy
  .p2align 4
  .type graphene_vec3_get_xy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_xy
#endif
graphene_vec3_get_xy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_xy0
  .p2align 4
  .type graphene_vec3_get_xy0, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_xy0
#endif
graphene_vec3_get_xy0:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_xyz0
  .p2align 4
  .type graphene_vec3_get_xyz0, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_xyz0
#endif
graphene_vec3_get_xyz0:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_xyz1
  .p2align 4
  .type graphene_vec3_get_xyz1, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_xyz1
#endif
graphene_vec3_get_xyz1:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_xyzw
  .p2align 4
  .type graphene_vec3_get_xyzw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_xyzw
#endif
graphene_vec3_get_xyzw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_y
  .p2align 4
  .type graphene_vec3_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_y
#endif
graphene_vec3_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_get_z
  .p2align 4
  .type graphene_vec3_get_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_get_z
#endif
graphene_vec3_get_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_init
  .p2align 4
  .type graphene_vec3_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_init
#endif
graphene_vec3_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_init_from_float
  .p2align 4
  .type graphene_vec3_init_from_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_init_from_float
#endif
graphene_vec3_init_from_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_init_from_vec3
  .p2align 4
  .type graphene_vec3_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_init_from_vec3
#endif
graphene_vec3_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_interpolate
  .p2align 4
  .type graphene_vec3_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_interpolate
#endif
graphene_vec3_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_length
  .p2align 4
  .type graphene_vec3_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_length
#endif
graphene_vec3_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_max
  .p2align 4
  .type graphene_vec3_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_max
#endif
graphene_vec3_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_min
  .p2align 4
  .type graphene_vec3_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_min
#endif
graphene_vec3_min:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_multiply
  .p2align 4
  .type graphene_vec3_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_multiply
#endif
graphene_vec3_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_near
  .p2align 4
  .type graphene_vec3_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_near
#endif
graphene_vec3_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_negate
  .p2align 4
  .type graphene_vec3_negate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_negate
#endif
graphene_vec3_negate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_normalize
  .p2align 4
  .type graphene_vec3_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_normalize
#endif
graphene_vec3_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_one
  .p2align 4
  .type graphene_vec3_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_one
#endif
graphene_vec3_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_scale
  .p2align 4
  .type graphene_vec3_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_scale
#endif
graphene_vec3_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_subtract
  .p2align 4
  .type graphene_vec3_subtract, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_subtract
#endif
graphene_vec3_subtract:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_to_float
  .p2align 4
  .type graphene_vec3_to_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_to_float
#endif
graphene_vec3_to_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_x_axis
  .p2align 4
  .type graphene_vec3_x_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_x_axis
#endif
graphene_vec3_x_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_y_axis
  .p2align 4
  .type graphene_vec3_y_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_y_axis
#endif
graphene_vec3_y_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_z_axis
  .p2align 4
  .type graphene_vec3_z_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_z_axis
#endif
graphene_vec3_z_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec3_zero
  .p2align 4
  .type graphene_vec3_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec3_zero
#endif
graphene_vec3_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_add
  .p2align 4
  .type graphene_vec4_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_add
#endif
graphene_vec4_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_alloc
  .p2align 4
  .type graphene_vec4_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_alloc
#endif
graphene_vec4_alloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_divide
  .p2align 4
  .type graphene_vec4_divide, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_divide
#endif
graphene_vec4_divide:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_dot
  .p2align 4
  .type graphene_vec4_dot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_dot
#endif
graphene_vec4_dot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_equal
  .p2align 4
  .type graphene_vec4_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_equal
#endif
graphene_vec4_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_free
  .p2align 4
  .type graphene_vec4_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_free
#endif
graphene_vec4_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_type
  .p2align 4
  .type graphene_vec4_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_type
#endif
graphene_vec4_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_w
  .p2align 4
  .type graphene_vec4_get_w, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_w
#endif
graphene_vec4_get_w:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_x
  .p2align 4
  .type graphene_vec4_get_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_x
#endif
graphene_vec4_get_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_xy
  .p2align 4
  .type graphene_vec4_get_xy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_xy
#endif
graphene_vec4_get_xy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_xyz
  .p2align 4
  .type graphene_vec4_get_xyz, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_xyz
#endif
graphene_vec4_get_xyz:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_y
  .p2align 4
  .type graphene_vec4_get_y, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_y
#endif
graphene_vec4_get_y:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_get_z
  .p2align 4
  .type graphene_vec4_get_z, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_get_z
#endif
graphene_vec4_get_z:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_init
  .p2align 4
  .type graphene_vec4_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_init
#endif
graphene_vec4_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_init_from_float
  .p2align 4
  .type graphene_vec4_init_from_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_init_from_float
#endif
graphene_vec4_init_from_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_init_from_vec2
  .p2align 4
  .type graphene_vec4_init_from_vec2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_init_from_vec2
#endif
graphene_vec4_init_from_vec2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_init_from_vec3
  .p2align 4
  .type graphene_vec4_init_from_vec3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_init_from_vec3
#endif
graphene_vec4_init_from_vec3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_init_from_vec4
  .p2align 4
  .type graphene_vec4_init_from_vec4, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_init_from_vec4
#endif
graphene_vec4_init_from_vec4:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_interpolate
  .p2align 4
  .type graphene_vec4_interpolate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_interpolate
#endif
graphene_vec4_interpolate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_length
  .p2align 4
  .type graphene_vec4_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_length
#endif
graphene_vec4_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_max
  .p2align 4
  .type graphene_vec4_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_max
#endif
graphene_vec4_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_min
  .p2align 4
  .type graphene_vec4_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_min
#endif
graphene_vec4_min:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_multiply
  .p2align 4
  .type graphene_vec4_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_multiply
#endif
graphene_vec4_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_near
  .p2align 4
  .type graphene_vec4_near, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_near
#endif
graphene_vec4_near:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_negate
  .p2align 4
  .type graphene_vec4_negate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_negate
#endif
graphene_vec4_negate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_normalize
  .p2align 4
  .type graphene_vec4_normalize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_normalize
#endif
graphene_vec4_normalize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_one
  .p2align 4
  .type graphene_vec4_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_one
#endif
graphene_vec4_one:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_scale
  .p2align 4
  .type graphene_vec4_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_scale
#endif
graphene_vec4_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_subtract
  .p2align 4
  .type graphene_vec4_subtract, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_subtract
#endif
graphene_vec4_subtract:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_to_float
  .p2align 4
  .type graphene_vec4_to_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_to_float
#endif
graphene_vec4_to_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_w_axis
  .p2align 4
  .type graphene_vec4_w_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_w_axis
#endif
graphene_vec4_w_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_x_axis
  .p2align 4
  .type graphene_vec4_x_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_x_axis
#endif
graphene_vec4_x_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_y_axis
  .p2align 4
  .type graphene_vec4_y_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_y_axis
#endif
graphene_vec4_y_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_z_axis
  .p2align 4
  .type graphene_vec4_z_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_z_axis
#endif
graphene_vec4_z_axis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl graphene_vec4_zero
  .p2align 4
  .type graphene_vec4_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_vec4_zero
#endif
graphene_vec4_zero:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgraphene_1_0_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libgraphene_1_0_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libgraphene_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

