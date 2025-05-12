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

  .globl _libcairo_so_tramp_table
  .hidden _libcairo_so_tramp_table
  .align 8
_libcairo_so_tramp_table:
  .zero 3368

  .text

  .globl _libcairo_so_tramp_resolve
  .hidden _libcairo_so_tramp_resolve

  .globl _libcairo_so_save_regs_and_resolve
  .hidden _libcairo_so_save_regs_and_resolve
  .type _libcairo_so_save_regs_and_resolve, %function
_libcairo_so_save_regs_and_resolve:
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
  call _libcairo_so_tramp_resolve

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

  .globl cairo_append_path
  .p2align 4
  .type cairo_append_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_append_path
#endif
cairo_append_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_arc
  .p2align 4
  .type cairo_arc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_arc
#endif
cairo_arc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_arc_negative
  .p2align 4
  .type cairo_arc_negative, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_arc_negative
#endif
cairo_arc_negative:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_clip
  .p2align 4
  .type cairo_clip, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_clip
#endif
cairo_clip:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_clip_extents
  .p2align 4
  .type cairo_clip_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_clip_extents
#endif
cairo_clip_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_clip_preserve
  .p2align 4
  .type cairo_clip_preserve, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_clip_preserve
#endif
cairo_clip_preserve:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_close_path
  .p2align 4
  .type cairo_close_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_close_path
#endif
cairo_close_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_copy_clip_rectangle_list
  .p2align 4
  .type cairo_copy_clip_rectangle_list, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_copy_clip_rectangle_list
#endif
cairo_copy_clip_rectangle_list:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_copy_page
  .p2align 4
  .type cairo_copy_page, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_copy_page
#endif
cairo_copy_page:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_copy_path
  .p2align 4
  .type cairo_copy_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_copy_path
#endif
cairo_copy_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_copy_path_flat
  .p2align 4
  .type cairo_copy_path_flat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_copy_path_flat
#endif
cairo_copy_path_flat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_create
  .p2align 4
  .type cairo_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_create
#endif
cairo_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_curve_to
  .p2align 4
  .type cairo_curve_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_curve_to
#endif
cairo_curve_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_debug_reset_static_data
  .p2align 4
  .type cairo_debug_reset_static_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_debug_reset_static_data
#endif
cairo_debug_reset_static_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_destroy
  .p2align 4
  .type cairo_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_destroy
#endif
cairo_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_acquire
  .p2align 4
  .type cairo_device_acquire, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_acquire
#endif
cairo_device_acquire:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_destroy
  .p2align 4
  .type cairo_device_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_destroy
#endif
cairo_device_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_finish
  .p2align 4
  .type cairo_device_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_finish
#endif
cairo_device_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_flush
  .p2align 4
  .type cairo_device_flush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_flush
#endif
cairo_device_flush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_get_reference_count
  .p2align 4
  .type cairo_device_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_get_reference_count
#endif
cairo_device_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_get_type
  .p2align 4
  .type cairo_device_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_get_type
#endif
cairo_device_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_get_user_data
  .p2align 4
  .type cairo_device_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_get_user_data
#endif
cairo_device_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_elapsed
  .p2align 4
  .type cairo_device_observer_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_elapsed
#endif
cairo_device_observer_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_fill_elapsed
  .p2align 4
  .type cairo_device_observer_fill_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_fill_elapsed
#endif
cairo_device_observer_fill_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_glyphs_elapsed
  .p2align 4
  .type cairo_device_observer_glyphs_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_glyphs_elapsed
#endif
cairo_device_observer_glyphs_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_mask_elapsed
  .p2align 4
  .type cairo_device_observer_mask_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_mask_elapsed
#endif
cairo_device_observer_mask_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_paint_elapsed
  .p2align 4
  .type cairo_device_observer_paint_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_paint_elapsed
#endif
cairo_device_observer_paint_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_print
  .p2align 4
  .type cairo_device_observer_print, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_print
#endif
cairo_device_observer_print:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_observer_stroke_elapsed
  .p2align 4
  .type cairo_device_observer_stroke_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_observer_stroke_elapsed
#endif
cairo_device_observer_stroke_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_reference
  .p2align 4
  .type cairo_device_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_reference
#endif
cairo_device_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_release
  .p2align 4
  .type cairo_device_release, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_release
#endif
cairo_device_release:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_set_user_data
  .p2align 4
  .type cairo_device_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_set_user_data
#endif
cairo_device_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_status
  .p2align 4
  .type cairo_device_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_status
#endif
cairo_device_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_to_user
  .p2align 4
  .type cairo_device_to_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_to_user
#endif
cairo_device_to_user:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_device_to_user_distance
  .p2align 4
  .type cairo_device_to_user_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_device_to_user_distance
#endif
cairo_device_to_user_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_fill
  .p2align 4
  .type cairo_fill, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_fill
#endif
cairo_fill:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_fill_extents
  .p2align 4
  .type cairo_fill_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_fill_extents
#endif
cairo_fill_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_fill_preserve
  .p2align 4
  .type cairo_fill_preserve, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_fill_preserve
#endif
cairo_fill_preserve:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_extents
  .p2align 4
  .type cairo_font_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_extents
#endif
cairo_font_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_destroy
  .p2align 4
  .type cairo_font_face_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_destroy
#endif
cairo_font_face_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_get_reference_count
  .p2align 4
  .type cairo_font_face_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_get_reference_count
#endif
cairo_font_face_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_get_type
  .p2align 4
  .type cairo_font_face_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_get_type
#endif
cairo_font_face_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_get_user_data
  .p2align 4
  .type cairo_font_face_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_get_user_data
#endif
cairo_font_face_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_reference
  .p2align 4
  .type cairo_font_face_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_reference
#endif
cairo_font_face_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_set_user_data
  .p2align 4
  .type cairo_font_face_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_set_user_data
#endif
cairo_font_face_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_face_status
  .p2align 4
  .type cairo_font_face_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_face_status
#endif
cairo_font_face_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_copy
  .p2align 4
  .type cairo_font_options_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_copy
#endif
cairo_font_options_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_create
  .p2align 4
  .type cairo_font_options_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_create
#endif
cairo_font_options_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_destroy
  .p2align 4
  .type cairo_font_options_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_destroy
#endif
cairo_font_options_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_equal
  .p2align 4
  .type cairo_font_options_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_equal
#endif
cairo_font_options_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_antialias
  .p2align 4
  .type cairo_font_options_get_antialias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_antialias
#endif
cairo_font_options_get_antialias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_color_mode
  .p2align 4
  .type cairo_font_options_get_color_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_color_mode
#endif
cairo_font_options_get_color_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_color_palette
  .p2align 4
  .type cairo_font_options_get_color_palette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_color_palette
#endif
cairo_font_options_get_color_palette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_custom_palette_color
  .p2align 4
  .type cairo_font_options_get_custom_palette_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_custom_palette_color
#endif
cairo_font_options_get_custom_palette_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_hint_metrics
  .p2align 4
  .type cairo_font_options_get_hint_metrics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_hint_metrics
#endif
cairo_font_options_get_hint_metrics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_hint_style
  .p2align 4
  .type cairo_font_options_get_hint_style, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_hint_style
#endif
cairo_font_options_get_hint_style:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_subpixel_order
  .p2align 4
  .type cairo_font_options_get_subpixel_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_subpixel_order
#endif
cairo_font_options_get_subpixel_order:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_get_variations
  .p2align 4
  .type cairo_font_options_get_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_get_variations
#endif
cairo_font_options_get_variations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_hash
  .p2align 4
  .type cairo_font_options_hash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_hash
#endif
cairo_font_options_hash:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_merge
  .p2align 4
  .type cairo_font_options_merge, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_merge
#endif
cairo_font_options_merge:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_antialias
  .p2align 4
  .type cairo_font_options_set_antialias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_antialias
#endif
cairo_font_options_set_antialias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_color_mode
  .p2align 4
  .type cairo_font_options_set_color_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_color_mode
#endif
cairo_font_options_set_color_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_color_palette
  .p2align 4
  .type cairo_font_options_set_color_palette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_color_palette
#endif
cairo_font_options_set_color_palette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_custom_palette_color
  .p2align 4
  .type cairo_font_options_set_custom_palette_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_custom_palette_color
#endif
cairo_font_options_set_custom_palette_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_hint_metrics
  .p2align 4
  .type cairo_font_options_set_hint_metrics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_hint_metrics
#endif
cairo_font_options_set_hint_metrics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_hint_style
  .p2align 4
  .type cairo_font_options_set_hint_style, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_hint_style
#endif
cairo_font_options_set_hint_style:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_subpixel_order
  .p2align 4
  .type cairo_font_options_set_subpixel_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_subpixel_order
#endif
cairo_font_options_set_subpixel_order:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_set_variations
  .p2align 4
  .type cairo_font_options_set_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_set_variations
#endif
cairo_font_options_set_variations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_font_options_status
  .p2align 4
  .type cairo_font_options_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_font_options_status
#endif
cairo_font_options_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_format_stride_for_width
  .p2align 4
  .type cairo_format_stride_for_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_format_stride_for_width
#endif
cairo_format_stride_for_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_face_create_for_ft_face
  .p2align 4
  .type cairo_ft_font_face_create_for_ft_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_face_create_for_ft_face
#endif
cairo_ft_font_face_create_for_ft_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_face_create_for_pattern
  .p2align 4
  .type cairo_ft_font_face_create_for_pattern, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_face_create_for_pattern
#endif
cairo_ft_font_face_create_for_pattern:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_face_get_synthesize
  .p2align 4
  .type cairo_ft_font_face_get_synthesize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_face_get_synthesize
#endif
cairo_ft_font_face_get_synthesize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_face_set_synthesize
  .p2align 4
  .type cairo_ft_font_face_set_synthesize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_face_set_synthesize
#endif
cairo_ft_font_face_set_synthesize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_face_unset_synthesize
  .p2align 4
  .type cairo_ft_font_face_unset_synthesize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_face_unset_synthesize
#endif
cairo_ft_font_face_unset_synthesize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_font_options_substitute
  .p2align 4
  .type cairo_ft_font_options_substitute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_font_options_substitute
#endif
cairo_ft_font_options_substitute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_scaled_font_lock_face
  .p2align 4
  .type cairo_ft_scaled_font_lock_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_scaled_font_lock_face
#endif
cairo_ft_scaled_font_lock_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ft_scaled_font_unlock_face
  .p2align 4
  .type cairo_ft_scaled_font_unlock_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ft_scaled_font_unlock_face
#endif
cairo_ft_scaled_font_unlock_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_antialias
  .p2align 4
  .type cairo_get_antialias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_antialias
#endif
cairo_get_antialias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_current_point
  .p2align 4
  .type cairo_get_current_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_current_point
#endif
cairo_get_current_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_dash
  .p2align 4
  .type cairo_get_dash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_dash
#endif
cairo_get_dash:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_dash_count
  .p2align 4
  .type cairo_get_dash_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_dash_count
#endif
cairo_get_dash_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_fill_rule
  .p2align 4
  .type cairo_get_fill_rule, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_fill_rule
#endif
cairo_get_fill_rule:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_font_face
  .p2align 4
  .type cairo_get_font_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_font_face
#endif
cairo_get_font_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_font_matrix
  .p2align 4
  .type cairo_get_font_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_font_matrix
#endif
cairo_get_font_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_font_options
  .p2align 4
  .type cairo_get_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_font_options
#endif
cairo_get_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_group_target
  .p2align 4
  .type cairo_get_group_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_group_target
#endif
cairo_get_group_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_hairline
  .p2align 4
  .type cairo_get_hairline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_hairline
#endif
cairo_get_hairline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_line_cap
  .p2align 4
  .type cairo_get_line_cap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_line_cap
#endif
cairo_get_line_cap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_line_join
  .p2align 4
  .type cairo_get_line_join, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_line_join
#endif
cairo_get_line_join:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_line_width
  .p2align 4
  .type cairo_get_line_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_line_width
#endif
cairo_get_line_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_matrix
  .p2align 4
  .type cairo_get_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_matrix
#endif
cairo_get_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_miter_limit
  .p2align 4
  .type cairo_get_miter_limit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_miter_limit
#endif
cairo_get_miter_limit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_operator
  .p2align 4
  .type cairo_get_operator, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_operator
#endif
cairo_get_operator:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_reference_count
  .p2align 4
  .type cairo_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_reference_count
#endif
cairo_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_scaled_font
  .p2align 4
  .type cairo_get_scaled_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_scaled_font
#endif
cairo_get_scaled_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_source
  .p2align 4
  .type cairo_get_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_source
#endif
cairo_get_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_target
  .p2align 4
  .type cairo_get_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_target
#endif
cairo_get_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_tolerance
  .p2align 4
  .type cairo_get_tolerance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_tolerance
#endif
cairo_get_tolerance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_get_user_data
  .p2align 4
  .type cairo_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_get_user_data
#endif
cairo_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_glyph_allocate
  .p2align 4
  .type cairo_glyph_allocate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_glyph_allocate
#endif
cairo_glyph_allocate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_glyph_extents
  .p2align 4
  .type cairo_glyph_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_glyph_extents
#endif
cairo_glyph_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_glyph_free
  .p2align 4
  .type cairo_glyph_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_glyph_free
#endif
cairo_glyph_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_glyph_path
  .p2align 4
  .type cairo_glyph_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_glyph_path
#endif
cairo_glyph_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_has_current_point
  .p2align 4
  .type cairo_has_current_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_has_current_point
#endif
cairo_has_current_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_identity_matrix
  .p2align 4
  .type cairo_identity_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_identity_matrix
#endif
cairo_identity_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_create
  .p2align 4
  .type cairo_image_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_create
#endif
cairo_image_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_create_for_data
  .p2align 4
  .type cairo_image_surface_create_for_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_create_for_data
#endif
cairo_image_surface_create_for_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_create_from_png
  .p2align 4
  .type cairo_image_surface_create_from_png, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_create_from_png
#endif
cairo_image_surface_create_from_png:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_create_from_png_stream
  .p2align 4
  .type cairo_image_surface_create_from_png_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_create_from_png_stream
#endif
cairo_image_surface_create_from_png_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_get_data
  .p2align 4
  .type cairo_image_surface_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_get_data
#endif
cairo_image_surface_get_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_get_format
  .p2align 4
  .type cairo_image_surface_get_format, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_get_format
#endif
cairo_image_surface_get_format:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_get_height
  .p2align 4
  .type cairo_image_surface_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_get_height
#endif
cairo_image_surface_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_get_stride
  .p2align 4
  .type cairo_image_surface_get_stride, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_get_stride
#endif
cairo_image_surface_get_stride:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_image_surface_get_width
  .p2align 4
  .type cairo_image_surface_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_image_surface_get_width
#endif
cairo_image_surface_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_in_clip
  .p2align 4
  .type cairo_in_clip, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_in_clip
#endif
cairo_in_clip:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_in_fill
  .p2align 4
  .type cairo_in_fill, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_in_fill
#endif
cairo_in_fill:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_in_stroke
  .p2align 4
  .type cairo_in_stroke, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_in_stroke
#endif
cairo_in_stroke:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_line_to
  .p2align 4
  .type cairo_line_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_line_to
#endif
cairo_line_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mask
  .p2align 4
  .type cairo_mask, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mask
#endif
cairo_mask:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mask_surface
  .p2align 4
  .type cairo_mask_surface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mask_surface
#endif
cairo_mask_surface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_init
  .p2align 4
  .type cairo_matrix_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_init
#endif
cairo_matrix_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_init_identity
  .p2align 4
  .type cairo_matrix_init_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_init_identity
#endif
cairo_matrix_init_identity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_init_rotate
  .p2align 4
  .type cairo_matrix_init_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_init_rotate
#endif
cairo_matrix_init_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_init_scale
  .p2align 4
  .type cairo_matrix_init_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_init_scale
#endif
cairo_matrix_init_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_init_translate
  .p2align 4
  .type cairo_matrix_init_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_init_translate
#endif
cairo_matrix_init_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_invert
  .p2align 4
  .type cairo_matrix_invert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_invert
#endif
cairo_matrix_invert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_multiply
  .p2align 4
  .type cairo_matrix_multiply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_multiply
#endif
cairo_matrix_multiply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_rotate
  .p2align 4
  .type cairo_matrix_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_rotate
#endif
cairo_matrix_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_scale
  .p2align 4
  .type cairo_matrix_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_scale
#endif
cairo_matrix_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_transform_distance
  .p2align 4
  .type cairo_matrix_transform_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_transform_distance
#endif
cairo_matrix_transform_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_transform_point
  .p2align 4
  .type cairo_matrix_transform_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_transform_point
#endif
cairo_matrix_transform_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_matrix_translate
  .p2align 4
  .type cairo_matrix_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_matrix_translate
#endif
cairo_matrix_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_begin_patch
  .p2align 4
  .type cairo_mesh_pattern_begin_patch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_begin_patch
#endif
cairo_mesh_pattern_begin_patch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_curve_to
  .p2align 4
  .type cairo_mesh_pattern_curve_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_curve_to
#endif
cairo_mesh_pattern_curve_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_end_patch
  .p2align 4
  .type cairo_mesh_pattern_end_patch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_end_patch
#endif
cairo_mesh_pattern_end_patch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_get_control_point
  .p2align 4
  .type cairo_mesh_pattern_get_control_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_get_control_point
#endif
cairo_mesh_pattern_get_control_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_get_corner_color_rgba
  .p2align 4
  .type cairo_mesh_pattern_get_corner_color_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_get_corner_color_rgba
#endif
cairo_mesh_pattern_get_corner_color_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_get_patch_count
  .p2align 4
  .type cairo_mesh_pattern_get_patch_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_get_patch_count
#endif
cairo_mesh_pattern_get_patch_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_get_path
  .p2align 4
  .type cairo_mesh_pattern_get_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_get_path
#endif
cairo_mesh_pattern_get_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_line_to
  .p2align 4
  .type cairo_mesh_pattern_line_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_line_to
#endif
cairo_mesh_pattern_line_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_move_to
  .p2align 4
  .type cairo_mesh_pattern_move_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_move_to
#endif
cairo_mesh_pattern_move_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_set_control_point
  .p2align 4
  .type cairo_mesh_pattern_set_control_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_set_control_point
#endif
cairo_mesh_pattern_set_control_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_set_corner_color_rgb
  .p2align 4
  .type cairo_mesh_pattern_set_corner_color_rgb, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_set_corner_color_rgb
#endif
cairo_mesh_pattern_set_corner_color_rgb:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_mesh_pattern_set_corner_color_rgba
  .p2align 4
  .type cairo_mesh_pattern_set_corner_color_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_mesh_pattern_set_corner_color_rgba
#endif
cairo_mesh_pattern_set_corner_color_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_move_to
  .p2align 4
  .type cairo_move_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_move_to
#endif
cairo_move_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_new_path
  .p2align 4
  .type cairo_new_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_new_path
#endif
cairo_new_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_new_sub_path
  .p2align 4
  .type cairo_new_sub_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_new_sub_path
#endif
cairo_new_sub_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_paint
  .p2align 4
  .type cairo_paint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_paint
#endif
cairo_paint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_paint_with_alpha
  .p2align 4
  .type cairo_paint_with_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_paint_with_alpha
#endif
cairo_paint_with_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_path_destroy
  .p2align 4
  .type cairo_path_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_path_destroy
#endif
cairo_path_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_path_extents
  .p2align 4
  .type cairo_path_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_path_extents
#endif
cairo_path_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_add_color_stop_rgb
  .p2align 4
  .type cairo_pattern_add_color_stop_rgb, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_add_color_stop_rgb
#endif
cairo_pattern_add_color_stop_rgb:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_add_color_stop_rgba
  .p2align 4
  .type cairo_pattern_add_color_stop_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_add_color_stop_rgba
#endif
cairo_pattern_add_color_stop_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_for_surface
  .p2align 4
  .type cairo_pattern_create_for_surface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_for_surface
#endif
cairo_pattern_create_for_surface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_linear
  .p2align 4
  .type cairo_pattern_create_linear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_linear
#endif
cairo_pattern_create_linear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_mesh
  .p2align 4
  .type cairo_pattern_create_mesh, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_mesh
#endif
cairo_pattern_create_mesh:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_radial
  .p2align 4
  .type cairo_pattern_create_radial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_radial
#endif
cairo_pattern_create_radial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_raster_source
  .p2align 4
  .type cairo_pattern_create_raster_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_raster_source
#endif
cairo_pattern_create_raster_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_rgb
  .p2align 4
  .type cairo_pattern_create_rgb, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_rgb
#endif
cairo_pattern_create_rgb:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_create_rgba
  .p2align 4
  .type cairo_pattern_create_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_create_rgba
#endif
cairo_pattern_create_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_destroy
  .p2align 4
  .type cairo_pattern_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_destroy
#endif
cairo_pattern_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_color_stop_count
  .p2align 4
  .type cairo_pattern_get_color_stop_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_color_stop_count
#endif
cairo_pattern_get_color_stop_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_color_stop_rgba
  .p2align 4
  .type cairo_pattern_get_color_stop_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_color_stop_rgba
#endif
cairo_pattern_get_color_stop_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_dither
  .p2align 4
  .type cairo_pattern_get_dither, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_dither
#endif
cairo_pattern_get_dither:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_extend
  .p2align 4
  .type cairo_pattern_get_extend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_extend
#endif
cairo_pattern_get_extend:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_filter
  .p2align 4
  .type cairo_pattern_get_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_filter
#endif
cairo_pattern_get_filter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_linear_points
  .p2align 4
  .type cairo_pattern_get_linear_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_linear_points
#endif
cairo_pattern_get_linear_points:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_matrix
  .p2align 4
  .type cairo_pattern_get_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_matrix
#endif
cairo_pattern_get_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_radial_circles
  .p2align 4
  .type cairo_pattern_get_radial_circles, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_radial_circles
#endif
cairo_pattern_get_radial_circles:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_reference_count
  .p2align 4
  .type cairo_pattern_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_reference_count
#endif
cairo_pattern_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_rgba
  .p2align 4
  .type cairo_pattern_get_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_rgba
#endif
cairo_pattern_get_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_surface
  .p2align 4
  .type cairo_pattern_get_surface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_surface
#endif
cairo_pattern_get_surface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_type
  .p2align 4
  .type cairo_pattern_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_type
#endif
cairo_pattern_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_get_user_data
  .p2align 4
  .type cairo_pattern_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_get_user_data
#endif
cairo_pattern_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_reference
  .p2align 4
  .type cairo_pattern_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_reference
#endif
cairo_pattern_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_set_dither
  .p2align 4
  .type cairo_pattern_set_dither, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_set_dither
#endif
cairo_pattern_set_dither:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_set_extend
  .p2align 4
  .type cairo_pattern_set_extend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_set_extend
#endif
cairo_pattern_set_extend:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_set_filter
  .p2align 4
  .type cairo_pattern_set_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_set_filter
#endif
cairo_pattern_set_filter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_set_matrix
  .p2align 4
  .type cairo_pattern_set_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_set_matrix
#endif
cairo_pattern_set_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_set_user_data
  .p2align 4
  .type cairo_pattern_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_set_user_data
#endif
cairo_pattern_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pattern_status
  .p2align 4
  .type cairo_pattern_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pattern_status
#endif
cairo_pattern_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_get_versions
  .p2align 4
  .type cairo_pdf_get_versions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_get_versions
#endif
cairo_pdf_get_versions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_add_outline
  .p2align 4
  .type cairo_pdf_surface_add_outline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_add_outline
#endif
cairo_pdf_surface_add_outline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_create
  .p2align 4
  .type cairo_pdf_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_create
#endif
cairo_pdf_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_create_for_stream
  .p2align 4
  .type cairo_pdf_surface_create_for_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_create_for_stream
#endif
cairo_pdf_surface_create_for_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_restrict_to_version
  .p2align 4
  .type cairo_pdf_surface_restrict_to_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_restrict_to_version
#endif
cairo_pdf_surface_restrict_to_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_set_custom_metadata
  .p2align 4
  .type cairo_pdf_surface_set_custom_metadata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_set_custom_metadata
#endif
cairo_pdf_surface_set_custom_metadata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_set_metadata
  .p2align 4
  .type cairo_pdf_surface_set_metadata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_set_metadata
#endif
cairo_pdf_surface_set_metadata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_set_page_label
  .p2align 4
  .type cairo_pdf_surface_set_page_label, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_set_page_label
#endif
cairo_pdf_surface_set_page_label:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_set_size
  .p2align 4
  .type cairo_pdf_surface_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_set_size
#endif
cairo_pdf_surface_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_surface_set_thumbnail_size
  .p2align 4
  .type cairo_pdf_surface_set_thumbnail_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_surface_set_thumbnail_size
#endif
cairo_pdf_surface_set_thumbnail_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pdf_version_to_string
  .p2align 4
  .type cairo_pdf_version_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pdf_version_to_string
#endif
cairo_pdf_version_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pop_group
  .p2align 4
  .type cairo_pop_group, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pop_group
#endif
cairo_pop_group:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_pop_group_to_source
  .p2align 4
  .type cairo_pop_group_to_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_pop_group_to_source
#endif
cairo_pop_group_to_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_get_levels
  .p2align 4
  .type cairo_ps_get_levels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_get_levels
#endif
cairo_ps_get_levels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_level_to_string
  .p2align 4
  .type cairo_ps_level_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_level_to_string
#endif
cairo_ps_level_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_create
  .p2align 4
  .type cairo_ps_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_create
#endif
cairo_ps_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_create_for_stream
  .p2align 4
  .type cairo_ps_surface_create_for_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_create_for_stream
#endif
cairo_ps_surface_create_for_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_dsc_begin_page_setup
  .p2align 4
  .type cairo_ps_surface_dsc_begin_page_setup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_dsc_begin_page_setup
#endif
cairo_ps_surface_dsc_begin_page_setup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_dsc_begin_setup
  .p2align 4
  .type cairo_ps_surface_dsc_begin_setup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_dsc_begin_setup
#endif
cairo_ps_surface_dsc_begin_setup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_dsc_comment
  .p2align 4
  .type cairo_ps_surface_dsc_comment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_dsc_comment
#endif
cairo_ps_surface_dsc_comment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_get_eps
  .p2align 4
  .type cairo_ps_surface_get_eps, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_get_eps
#endif
cairo_ps_surface_get_eps:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_restrict_to_level
  .p2align 4
  .type cairo_ps_surface_restrict_to_level, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_restrict_to_level
#endif
cairo_ps_surface_restrict_to_level:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_set_eps
  .p2align 4
  .type cairo_ps_surface_set_eps, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_set_eps
#endif
cairo_ps_surface_set_eps:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_ps_surface_set_size
  .p2align 4
  .type cairo_ps_surface_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_ps_surface_set_size
#endif
cairo_ps_surface_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_push_group
  .p2align 4
  .type cairo_push_group, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_push_group
#endif
cairo_push_group:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_push_group_with_content
  .p2align 4
  .type cairo_push_group_with_content, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_push_group_with_content
#endif
cairo_push_group_with_content:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_get_acquire
  .p2align 4
  .type cairo_raster_source_pattern_get_acquire, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_get_acquire
#endif
cairo_raster_source_pattern_get_acquire:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_get_callback_data
  .p2align 4
  .type cairo_raster_source_pattern_get_callback_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_get_callback_data
#endif
cairo_raster_source_pattern_get_callback_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_get_copy
  .p2align 4
  .type cairo_raster_source_pattern_get_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_get_copy
#endif
cairo_raster_source_pattern_get_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_get_finish
  .p2align 4
  .type cairo_raster_source_pattern_get_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_get_finish
#endif
cairo_raster_source_pattern_get_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_get_snapshot
  .p2align 4
  .type cairo_raster_source_pattern_get_snapshot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_get_snapshot
#endif
cairo_raster_source_pattern_get_snapshot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_set_acquire
  .p2align 4
  .type cairo_raster_source_pattern_set_acquire, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_set_acquire
#endif
cairo_raster_source_pattern_set_acquire:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_set_callback_data
  .p2align 4
  .type cairo_raster_source_pattern_set_callback_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_set_callback_data
#endif
cairo_raster_source_pattern_set_callback_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_set_copy
  .p2align 4
  .type cairo_raster_source_pattern_set_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_set_copy
#endif
cairo_raster_source_pattern_set_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_set_finish
  .p2align 4
  .type cairo_raster_source_pattern_set_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_set_finish
#endif
cairo_raster_source_pattern_set_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_raster_source_pattern_set_snapshot
  .p2align 4
  .type cairo_raster_source_pattern_set_snapshot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_raster_source_pattern_set_snapshot
#endif
cairo_raster_source_pattern_set_snapshot:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_recording_surface_create
  .p2align 4
  .type cairo_recording_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_recording_surface_create
#endif
cairo_recording_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_recording_surface_get_extents
  .p2align 4
  .type cairo_recording_surface_get_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_recording_surface_get_extents
#endif
cairo_recording_surface_get_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_recording_surface_ink_extents
  .p2align 4
  .type cairo_recording_surface_ink_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_recording_surface_ink_extents
#endif
cairo_recording_surface_ink_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rectangle
  .p2align 4
  .type cairo_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rectangle
#endif
cairo_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rectangle_list_destroy
  .p2align 4
  .type cairo_rectangle_list_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rectangle_list_destroy
#endif
cairo_rectangle_list_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_reference
  .p2align 4
  .type cairo_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_reference
#endif
cairo_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_contains_point
  .p2align 4
  .type cairo_region_contains_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_contains_point
#endif
cairo_region_contains_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_contains_rectangle
  .p2align 4
  .type cairo_region_contains_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_contains_rectangle
#endif
cairo_region_contains_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_copy
  .p2align 4
  .type cairo_region_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_copy
#endif
cairo_region_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_create
  .p2align 4
  .type cairo_region_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_create
#endif
cairo_region_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_create_rectangle
  .p2align 4
  .type cairo_region_create_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_create_rectangle
#endif
cairo_region_create_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_create_rectangles
  .p2align 4
  .type cairo_region_create_rectangles, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_create_rectangles
#endif
cairo_region_create_rectangles:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_destroy
  .p2align 4
  .type cairo_region_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_destroy
#endif
cairo_region_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_equal
  .p2align 4
  .type cairo_region_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_equal
#endif
cairo_region_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_get_extents
  .p2align 4
  .type cairo_region_get_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_get_extents
#endif
cairo_region_get_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_get_rectangle
  .p2align 4
  .type cairo_region_get_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_get_rectangle
#endif
cairo_region_get_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_intersect
  .p2align 4
  .type cairo_region_intersect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_intersect
#endif
cairo_region_intersect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_intersect_rectangle
  .p2align 4
  .type cairo_region_intersect_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_intersect_rectangle
#endif
cairo_region_intersect_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_is_empty
  .p2align 4
  .type cairo_region_is_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_is_empty
#endif
cairo_region_is_empty:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_num_rectangles
  .p2align 4
  .type cairo_region_num_rectangles, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_num_rectangles
#endif
cairo_region_num_rectangles:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_reference
  .p2align 4
  .type cairo_region_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_reference
#endif
cairo_region_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_status
  .p2align 4
  .type cairo_region_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_status
#endif
cairo_region_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_subtract
  .p2align 4
  .type cairo_region_subtract, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_subtract
#endif
cairo_region_subtract:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_subtract_rectangle
  .p2align 4
  .type cairo_region_subtract_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_subtract_rectangle
#endif
cairo_region_subtract_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_translate
  .p2align 4
  .type cairo_region_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_translate
#endif
cairo_region_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_union
  .p2align 4
  .type cairo_region_union, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_union
#endif
cairo_region_union:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_union_rectangle
  .p2align 4
  .type cairo_region_union_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_union_rectangle
#endif
cairo_region_union_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_xor
  .p2align 4
  .type cairo_region_xor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_xor
#endif
cairo_region_xor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_region_xor_rectangle
  .p2align 4
  .type cairo_region_xor_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_region_xor_rectangle
#endif
cairo_region_xor_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rel_curve_to
  .p2align 4
  .type cairo_rel_curve_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rel_curve_to
#endif
cairo_rel_curve_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rel_line_to
  .p2align 4
  .type cairo_rel_line_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rel_line_to
#endif
cairo_rel_line_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rel_move_to
  .p2align 4
  .type cairo_rel_move_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rel_move_to
#endif
cairo_rel_move_to:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_reset_clip
  .p2align 4
  .type cairo_reset_clip, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_reset_clip
#endif
cairo_reset_clip:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_restore
  .p2align 4
  .type cairo_restore, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_restore
#endif
cairo_restore:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_rotate
  .p2align 4
  .type cairo_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_rotate
#endif
cairo_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_save
  .p2align 4
  .type cairo_save, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_save
#endif
cairo_save:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scale
  .p2align 4
  .type cairo_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scale
#endif
cairo_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_create
  .p2align 4
  .type cairo_scaled_font_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_create
#endif
cairo_scaled_font_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_destroy
  .p2align 4
  .type cairo_scaled_font_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_destroy
#endif
cairo_scaled_font_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_extents
  .p2align 4
  .type cairo_scaled_font_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_extents
#endif
cairo_scaled_font_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_ctm
  .p2align 4
  .type cairo_scaled_font_get_ctm, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_ctm
#endif
cairo_scaled_font_get_ctm:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_font_face
  .p2align 4
  .type cairo_scaled_font_get_font_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_font_face
#endif
cairo_scaled_font_get_font_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_font_matrix
  .p2align 4
  .type cairo_scaled_font_get_font_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_font_matrix
#endif
cairo_scaled_font_get_font_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_font_options
  .p2align 4
  .type cairo_scaled_font_get_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_font_options
#endif
cairo_scaled_font_get_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_reference_count
  .p2align 4
  .type cairo_scaled_font_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_reference_count
#endif
cairo_scaled_font_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_scale_matrix
  .p2align 4
  .type cairo_scaled_font_get_scale_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_scale_matrix
#endif
cairo_scaled_font_get_scale_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_type
  .p2align 4
  .type cairo_scaled_font_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_type
#endif
cairo_scaled_font_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_get_user_data
  .p2align 4
  .type cairo_scaled_font_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_get_user_data
#endif
cairo_scaled_font_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_glyph_extents
  .p2align 4
  .type cairo_scaled_font_glyph_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_glyph_extents
#endif
cairo_scaled_font_glyph_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_reference
  .p2align 4
  .type cairo_scaled_font_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_reference
#endif
cairo_scaled_font_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_set_user_data
  .p2align 4
  .type cairo_scaled_font_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_set_user_data
#endif
cairo_scaled_font_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_status
  .p2align 4
  .type cairo_scaled_font_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_status
#endif
cairo_scaled_font_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_text_extents
  .p2align 4
  .type cairo_scaled_font_text_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_text_extents
#endif
cairo_scaled_font_text_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_scaled_font_text_to_glyphs
  .p2align 4
  .type cairo_scaled_font_text_to_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_scaled_font_text_to_glyphs
#endif
cairo_scaled_font_text_to_glyphs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_create
  .p2align 4
  .type cairo_script_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_create
#endif
cairo_script_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_create_for_stream
  .p2align 4
  .type cairo_script_create_for_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_create_for_stream
#endif
cairo_script_create_for_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_from_recording_surface
  .p2align 4
  .type cairo_script_from_recording_surface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_from_recording_surface
#endif
cairo_script_from_recording_surface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_get_mode
  .p2align 4
  .type cairo_script_get_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_get_mode
#endif
cairo_script_get_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_set_mode
  .p2align 4
  .type cairo_script_set_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_set_mode
#endif
cairo_script_set_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_surface_create
  .p2align 4
  .type cairo_script_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_surface_create
#endif
cairo_script_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_surface_create_for_target
  .p2align 4
  .type cairo_script_surface_create_for_target, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_surface_create_for_target
#endif
cairo_script_surface_create_for_target:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_script_write_comment
  .p2align 4
  .type cairo_script_write_comment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_script_write_comment
#endif
cairo_script_write_comment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_select_font_face
  .p2align 4
  .type cairo_select_font_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_select_font_face
#endif
cairo_select_font_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_antialias
  .p2align 4
  .type cairo_set_antialias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_antialias
#endif
cairo_set_antialias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_dash
  .p2align 4
  .type cairo_set_dash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_dash
#endif
cairo_set_dash:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_fill_rule
  .p2align 4
  .type cairo_set_fill_rule, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_fill_rule
#endif
cairo_set_fill_rule:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_font_face
  .p2align 4
  .type cairo_set_font_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_font_face
#endif
cairo_set_font_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_font_matrix
  .p2align 4
  .type cairo_set_font_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_font_matrix
#endif
cairo_set_font_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_font_options
  .p2align 4
  .type cairo_set_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_font_options
#endif
cairo_set_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_font_size
  .p2align 4
  .type cairo_set_font_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_font_size
#endif
cairo_set_font_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_hairline
  .p2align 4
  .type cairo_set_hairline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_hairline
#endif
cairo_set_hairline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_line_cap
  .p2align 4
  .type cairo_set_line_cap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_line_cap
#endif
cairo_set_line_cap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_line_join
  .p2align 4
  .type cairo_set_line_join, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_line_join
#endif
cairo_set_line_join:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_line_width
  .p2align 4
  .type cairo_set_line_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_line_width
#endif
cairo_set_line_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_matrix
  .p2align 4
  .type cairo_set_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_matrix
#endif
cairo_set_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_miter_limit
  .p2align 4
  .type cairo_set_miter_limit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_miter_limit
#endif
cairo_set_miter_limit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_operator
  .p2align 4
  .type cairo_set_operator, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_operator
#endif
cairo_set_operator:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_scaled_font
  .p2align 4
  .type cairo_set_scaled_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_scaled_font
#endif
cairo_set_scaled_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_source
  .p2align 4
  .type cairo_set_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_source
#endif
cairo_set_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_source_rgb
  .p2align 4
  .type cairo_set_source_rgb, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_source_rgb
#endif
cairo_set_source_rgb:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_source_rgba
  .p2align 4
  .type cairo_set_source_rgba, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_source_rgba
#endif
cairo_set_source_rgba:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_source_surface
  .p2align 4
  .type cairo_set_source_surface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_source_surface
#endif
cairo_set_source_surface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_tolerance
  .p2align 4
  .type cairo_set_tolerance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_tolerance
#endif
cairo_set_tolerance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_set_user_data
  .p2align 4
  .type cairo_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_set_user_data
#endif
cairo_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_show_glyphs
  .p2align 4
  .type cairo_show_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_show_glyphs
#endif
cairo_show_glyphs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_show_page
  .p2align 4
  .type cairo_show_page, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_show_page
#endif
cairo_show_page:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_show_text
  .p2align 4
  .type cairo_show_text, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_show_text
#endif
cairo_show_text:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_show_text_glyphs
  .p2align 4
  .type cairo_show_text_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_show_text_glyphs
#endif
cairo_show_text_glyphs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_status
  .p2align 4
  .type cairo_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_status
#endif
cairo_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_status_to_string
  .p2align 4
  .type cairo_status_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_status_to_string
#endif
cairo_status_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_stroke
  .p2align 4
  .type cairo_stroke, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_stroke
#endif
cairo_stroke:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_stroke_extents
  .p2align 4
  .type cairo_stroke_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_stroke_extents
#endif
cairo_stroke_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_stroke_preserve
  .p2align 4
  .type cairo_stroke_preserve, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_stroke_preserve
#endif
cairo_stroke_preserve:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_copy_page
  .p2align 4
  .type cairo_surface_copy_page, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_copy_page
#endif
cairo_surface_copy_page:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_create_for_rectangle
  .p2align 4
  .type cairo_surface_create_for_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_create_for_rectangle
#endif
cairo_surface_create_for_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_create_observer
  .p2align 4
  .type cairo_surface_create_observer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_create_observer
#endif
cairo_surface_create_observer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_create_similar
  .p2align 4
  .type cairo_surface_create_similar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_create_similar
#endif
cairo_surface_create_similar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_create_similar_image
  .p2align 4
  .type cairo_surface_create_similar_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_create_similar_image
#endif
cairo_surface_create_similar_image:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_destroy
  .p2align 4
  .type cairo_surface_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_destroy
#endif
cairo_surface_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_finish
  .p2align 4
  .type cairo_surface_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_finish
#endif
cairo_surface_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_flush
  .p2align 4
  .type cairo_surface_flush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_flush
#endif
cairo_surface_flush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_content
  .p2align 4
  .type cairo_surface_get_content, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_content
#endif
cairo_surface_get_content:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_device
  .p2align 4
  .type cairo_surface_get_device, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_device
#endif
cairo_surface_get_device:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_device_offset
  .p2align 4
  .type cairo_surface_get_device_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_device_offset
#endif
cairo_surface_get_device_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_device_scale
  .p2align 4
  .type cairo_surface_get_device_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_device_scale
#endif
cairo_surface_get_device_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_fallback_resolution
  .p2align 4
  .type cairo_surface_get_fallback_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_fallback_resolution
#endif
cairo_surface_get_fallback_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_font_options
  .p2align 4
  .type cairo_surface_get_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_font_options
#endif
cairo_surface_get_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_mime_data
  .p2align 4
  .type cairo_surface_get_mime_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_mime_data
#endif
cairo_surface_get_mime_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_reference_count
  .p2align 4
  .type cairo_surface_get_reference_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_reference_count
#endif
cairo_surface_get_reference_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_type
  .p2align 4
  .type cairo_surface_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_type
#endif
cairo_surface_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_get_user_data
  .p2align 4
  .type cairo_surface_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_get_user_data
#endif
cairo_surface_get_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_has_show_text_glyphs
  .p2align 4
  .type cairo_surface_has_show_text_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_has_show_text_glyphs
#endif
cairo_surface_has_show_text_glyphs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_map_to_image
  .p2align 4
  .type cairo_surface_map_to_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_map_to_image
#endif
cairo_surface_map_to_image:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_mark_dirty
  .p2align 4
  .type cairo_surface_mark_dirty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_mark_dirty
#endif
cairo_surface_mark_dirty:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_mark_dirty_rectangle
  .p2align 4
  .type cairo_surface_mark_dirty_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_mark_dirty_rectangle
#endif
cairo_surface_mark_dirty_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_fill_callback
  .p2align 4
  .type cairo_surface_observer_add_fill_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_fill_callback
#endif
cairo_surface_observer_add_fill_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_finish_callback
  .p2align 4
  .type cairo_surface_observer_add_finish_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_finish_callback
#endif
cairo_surface_observer_add_finish_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_flush_callback
  .p2align 4
  .type cairo_surface_observer_add_flush_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_flush_callback
#endif
cairo_surface_observer_add_flush_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_glyphs_callback
  .p2align 4
  .type cairo_surface_observer_add_glyphs_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_glyphs_callback
#endif
cairo_surface_observer_add_glyphs_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_mask_callback
  .p2align 4
  .type cairo_surface_observer_add_mask_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_mask_callback
#endif
cairo_surface_observer_add_mask_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_paint_callback
  .p2align 4
  .type cairo_surface_observer_add_paint_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_paint_callback
#endif
cairo_surface_observer_add_paint_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_add_stroke_callback
  .p2align 4
  .type cairo_surface_observer_add_stroke_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_add_stroke_callback
#endif
cairo_surface_observer_add_stroke_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_elapsed
  .p2align 4
  .type cairo_surface_observer_elapsed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_elapsed
#endif
cairo_surface_observer_elapsed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_observer_print
  .p2align 4
  .type cairo_surface_observer_print, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_observer_print
#endif
cairo_surface_observer_print:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_reference
  .p2align 4
  .type cairo_surface_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_reference
#endif
cairo_surface_reference:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_set_device_offset
  .p2align 4
  .type cairo_surface_set_device_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_set_device_offset
#endif
cairo_surface_set_device_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_set_device_scale
  .p2align 4
  .type cairo_surface_set_device_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_set_device_scale
#endif
cairo_surface_set_device_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_set_fallback_resolution
  .p2align 4
  .type cairo_surface_set_fallback_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_set_fallback_resolution
#endif
cairo_surface_set_fallback_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_set_mime_data
  .p2align 4
  .type cairo_surface_set_mime_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_set_mime_data
#endif
cairo_surface_set_mime_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_set_user_data
  .p2align 4
  .type cairo_surface_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_set_user_data
#endif
cairo_surface_set_user_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_show_page
  .p2align 4
  .type cairo_surface_show_page, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_show_page
#endif
cairo_surface_show_page:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_status
  .p2align 4
  .type cairo_surface_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_status
#endif
cairo_surface_status:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_supports_mime_type
  .p2align 4
  .type cairo_surface_supports_mime_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_supports_mime_type
#endif
cairo_surface_supports_mime_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_unmap_image
  .p2align 4
  .type cairo_surface_unmap_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_unmap_image
#endif
cairo_surface_unmap_image:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_write_to_png
  .p2align 4
  .type cairo_surface_write_to_png, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_write_to_png
#endif
cairo_surface_write_to_png:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_surface_write_to_png_stream
  .p2align 4
  .type cairo_surface_write_to_png_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_surface_write_to_png_stream
#endif
cairo_surface_write_to_png_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_get_versions
  .p2align 4
  .type cairo_svg_get_versions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_get_versions
#endif
cairo_svg_get_versions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_surface_create
  .p2align 4
  .type cairo_svg_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_surface_create
#endif
cairo_svg_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_surface_create_for_stream
  .p2align 4
  .type cairo_svg_surface_create_for_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_surface_create_for_stream
#endif
cairo_svg_surface_create_for_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_surface_get_document_unit
  .p2align 4
  .type cairo_svg_surface_get_document_unit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_surface_get_document_unit
#endif
cairo_svg_surface_get_document_unit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_surface_restrict_to_version
  .p2align 4
  .type cairo_svg_surface_restrict_to_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_surface_restrict_to_version
#endif
cairo_svg_surface_restrict_to_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_surface_set_document_unit
  .p2align 4
  .type cairo_svg_surface_set_document_unit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_surface_set_document_unit
#endif
cairo_svg_surface_set_document_unit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_svg_version_to_string
  .p2align 4
  .type cairo_svg_version_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_svg_version_to_string
#endif
cairo_svg_version_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tag_begin
  .p2align 4
  .type cairo_tag_begin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tag_begin
#endif
cairo_tag_begin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tag_end
  .p2align 4
  .type cairo_tag_end, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tag_end
#endif
cairo_tag_end:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tee_surface_add
  .p2align 4
  .type cairo_tee_surface_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tee_surface_add
#endif
cairo_tee_surface_add:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tee_surface_create
  .p2align 4
  .type cairo_tee_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tee_surface_create
#endif
cairo_tee_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tee_surface_index
  .p2align 4
  .type cairo_tee_surface_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tee_surface_index
#endif
cairo_tee_surface_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_tee_surface_remove
  .p2align 4
  .type cairo_tee_surface_remove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_tee_surface_remove
#endif
cairo_tee_surface_remove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_text_cluster_allocate
  .p2align 4
  .type cairo_text_cluster_allocate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_text_cluster_allocate
#endif
cairo_text_cluster_allocate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_text_cluster_free
  .p2align 4
  .type cairo_text_cluster_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_text_cluster_free
#endif
cairo_text_cluster_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_text_extents
  .p2align 4
  .type cairo_text_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_text_extents
#endif
cairo_text_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_text_path
  .p2align 4
  .type cairo_text_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_text_path
#endif
cairo_text_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_toy_font_face_create
  .p2align 4
  .type cairo_toy_font_face_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_toy_font_face_create
#endif
cairo_toy_font_face_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_toy_font_face_get_family
  .p2align 4
  .type cairo_toy_font_face_get_family, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_toy_font_face_get_family
#endif
cairo_toy_font_face_get_family:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_toy_font_face_get_slant
  .p2align 4
  .type cairo_toy_font_face_get_slant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_toy_font_face_get_slant
#endif
cairo_toy_font_face_get_slant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_toy_font_face_get_weight
  .p2align 4
  .type cairo_toy_font_face_get_weight, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_toy_font_face_get_weight
#endif
cairo_toy_font_face_get_weight:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_transform
  .p2align 4
  .type cairo_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_transform
#endif
cairo_transform:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_translate
  .p2align 4
  .type cairo_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_translate
#endif
cairo_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_create
  .p2align 4
  .type cairo_user_font_face_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_create
#endif
cairo_user_font_face_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_get_init_func
  .p2align 4
  .type cairo_user_font_face_get_init_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_get_init_func
#endif
cairo_user_font_face_get_init_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_get_render_color_glyph_func
  .p2align 4
  .type cairo_user_font_face_get_render_color_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_get_render_color_glyph_func
#endif
cairo_user_font_face_get_render_color_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_get_render_glyph_func
  .p2align 4
  .type cairo_user_font_face_get_render_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_get_render_glyph_func
#endif
cairo_user_font_face_get_render_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_get_text_to_glyphs_func
  .p2align 4
  .type cairo_user_font_face_get_text_to_glyphs_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_get_text_to_glyphs_func
#endif
cairo_user_font_face_get_text_to_glyphs_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_get_unicode_to_glyph_func
  .p2align 4
  .type cairo_user_font_face_get_unicode_to_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_get_unicode_to_glyph_func
#endif
cairo_user_font_face_get_unicode_to_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_set_init_func
  .p2align 4
  .type cairo_user_font_face_set_init_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_set_init_func
#endif
cairo_user_font_face_set_init_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_set_render_color_glyph_func
  .p2align 4
  .type cairo_user_font_face_set_render_color_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_set_render_color_glyph_func
#endif
cairo_user_font_face_set_render_color_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_set_render_glyph_func
  .p2align 4
  .type cairo_user_font_face_set_render_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_set_render_glyph_func
#endif
cairo_user_font_face_set_render_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_set_text_to_glyphs_func
  .p2align 4
  .type cairo_user_font_face_set_text_to_glyphs_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_set_text_to_glyphs_func
#endif
cairo_user_font_face_set_text_to_glyphs_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_font_face_set_unicode_to_glyph_func
  .p2align 4
  .type cairo_user_font_face_set_unicode_to_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_font_face_set_unicode_to_glyph_func
#endif
cairo_user_font_face_set_unicode_to_glyph_func:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_scaled_font_get_foreground_marker
  .p2align 4
  .type cairo_user_scaled_font_get_foreground_marker, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_scaled_font_get_foreground_marker
#endif
cairo_user_scaled_font_get_foreground_marker:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_scaled_font_get_foreground_source
  .p2align 4
  .type cairo_user_scaled_font_get_foreground_source, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_scaled_font_get_foreground_source
#endif
cairo_user_scaled_font_get_foreground_source:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_to_device
  .p2align 4
  .type cairo_user_to_device, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_to_device
#endif
cairo_user_to_device:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_user_to_device_distance
  .p2align 4
  .type cairo_user_to_device_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_user_to_device_distance
#endif
cairo_user_to_device_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_version
  .p2align 4
  .type cairo_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_version
#endif
cairo_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_version_string
  .p2align 4
  .type cairo_version_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_version_string
#endif
cairo_version_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_device_debug_cap_xrender_version
  .p2align 4
  .type cairo_xcb_device_debug_cap_xrender_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_device_debug_cap_xrender_version
#endif
cairo_xcb_device_debug_cap_xrender_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_device_debug_cap_xshm_version
  .p2align 4
  .type cairo_xcb_device_debug_cap_xshm_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_device_debug_cap_xshm_version
#endif
cairo_xcb_device_debug_cap_xshm_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_device_debug_get_precision
  .p2align 4
  .type cairo_xcb_device_debug_get_precision, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_device_debug_get_precision
#endif
cairo_xcb_device_debug_get_precision:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_device_debug_set_precision
  .p2align 4
  .type cairo_xcb_device_debug_set_precision, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_device_debug_set_precision
#endif
cairo_xcb_device_debug_set_precision:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_device_get_connection
  .p2align 4
  .type cairo_xcb_device_get_connection, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_device_get_connection
#endif
cairo_xcb_device_get_connection:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_surface_create
  .p2align 4
  .type cairo_xcb_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_surface_create
#endif
cairo_xcb_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_surface_create_for_bitmap
  .p2align 4
  .type cairo_xcb_surface_create_for_bitmap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_surface_create_for_bitmap
#endif
cairo_xcb_surface_create_for_bitmap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_surface_create_with_xrender_format
  .p2align 4
  .type cairo_xcb_surface_create_with_xrender_format, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_surface_create_with_xrender_format
#endif
cairo_xcb_surface_create_with_xrender_format:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_surface_set_drawable
  .p2align 4
  .type cairo_xcb_surface_set_drawable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_surface_set_drawable
#endif
cairo_xcb_surface_set_drawable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xcb_surface_set_size
  .p2align 4
  .type cairo_xcb_surface_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xcb_surface_set_size
#endif
cairo_xcb_surface_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_device_debug_cap_xrender_version
  .p2align 4
  .type cairo_xlib_device_debug_cap_xrender_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_device_debug_cap_xrender_version
#endif
cairo_xlib_device_debug_cap_xrender_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_device_debug_get_precision
  .p2align 4
  .type cairo_xlib_device_debug_get_precision, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_device_debug_get_precision
#endif
cairo_xlib_device_debug_get_precision:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_device_debug_set_precision
  .p2align 4
  .type cairo_xlib_device_debug_set_precision, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_device_debug_set_precision
#endif
cairo_xlib_device_debug_set_precision:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_create
  .p2align 4
  .type cairo_xlib_surface_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_create
#endif
cairo_xlib_surface_create:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_create_for_bitmap
  .p2align 4
  .type cairo_xlib_surface_create_for_bitmap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_create_for_bitmap
#endif
cairo_xlib_surface_create_for_bitmap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_create_with_xrender_format
  .p2align 4
  .type cairo_xlib_surface_create_with_xrender_format, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_create_with_xrender_format
#endif
cairo_xlib_surface_create_with_xrender_format:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_depth
  .p2align 4
  .type cairo_xlib_surface_get_depth, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_depth
#endif
cairo_xlib_surface_get_depth:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_display
  .p2align 4
  .type cairo_xlib_surface_get_display, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_display
#endif
cairo_xlib_surface_get_display:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_drawable
  .p2align 4
  .type cairo_xlib_surface_get_drawable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_drawable
#endif
cairo_xlib_surface_get_drawable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_height
  .p2align 4
  .type cairo_xlib_surface_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_height
#endif
cairo_xlib_surface_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_screen
  .p2align 4
  .type cairo_xlib_surface_get_screen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_screen
#endif
cairo_xlib_surface_get_screen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_visual
  .p2align 4
  .type cairo_xlib_surface_get_visual, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_visual
#endif
cairo_xlib_surface_get_visual:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_width
  .p2align 4
  .type cairo_xlib_surface_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_width
#endif
cairo_xlib_surface_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_get_xrender_format
  .p2align 4
  .type cairo_xlib_surface_get_xrender_format, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_get_xrender_format
#endif
cairo_xlib_surface_get_xrender_format:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_set_drawable
  .p2align 4
  .type cairo_xlib_surface_set_drawable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_set_drawable
#endif
cairo_xlib_surface_set_drawable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_xlib_surface_set_size
  .p2align 4
  .type cairo_xlib_surface_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_xlib_surface_set_size
#endif
cairo_xlib_surface_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libcairo_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libcairo_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libcairo_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

