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

  .globl _libpango_1_0_so_tramp_table
  .hidden _libpango_1_0_so_tramp_table
  .align 8
_libpango_1_0_so_tramp_table:
  .zero 4040

  .text

  .globl _libpango_1_0_so_tramp_resolve
  .hidden _libpango_1_0_so_tramp_resolve

  .globl _libpango_1_0_so_save_regs_and_resolve
  .hidden _libpango_1_0_so_save_regs_and_resolve
  .type _libpango_1_0_so_save_regs_and_resolve, %function
_libpango_1_0_so_save_regs_and_resolve:
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
  call _libpango_1_0_so_tramp_resolve

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

  .globl pango_alignment_get_type
  .p2align 4
  .type pango_alignment_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_alignment_get_type
#endif
pango_alignment_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_allow_breaks_new
  .p2align 4
  .type pango_attr_allow_breaks_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_allow_breaks_new
#endif
pango_attr_allow_breaks_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_background_alpha_new
  .p2align 4
  .type pango_attr_background_alpha_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_background_alpha_new
#endif
pango_attr_background_alpha_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_background_new
  .p2align 4
  .type pango_attr_background_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_background_new
#endif
pango_attr_background_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_baseline_shift_new
  .p2align 4
  .type pango_attr_baseline_shift_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_baseline_shift_new
#endif
pango_attr_baseline_shift_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_break
  .p2align 4
  .type pango_attr_break, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_break
#endif
pango_attr_break:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_fallback_new
  .p2align 4
  .type pango_attr_fallback_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_fallback_new
#endif
pango_attr_fallback_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_family_new
  .p2align 4
  .type pango_attr_family_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_family_new
#endif
pango_attr_family_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_font_desc_new
  .p2align 4
  .type pango_attr_font_desc_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_font_desc_new
#endif
pango_attr_font_desc_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_font_features_new
  .p2align 4
  .type pango_attr_font_features_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_font_features_new
#endif
pango_attr_font_features_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_font_scale_new
  .p2align 4
  .type pango_attr_font_scale_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_font_scale_new
#endif
pango_attr_font_scale_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_foreground_alpha_new
  .p2align 4
  .type pango_attr_foreground_alpha_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_foreground_alpha_new
#endif
pango_attr_foreground_alpha_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_foreground_new
  .p2align 4
  .type pango_attr_foreground_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_foreground_new
#endif
pango_attr_foreground_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_gravity_hint_new
  .p2align 4
  .type pango_attr_gravity_hint_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_gravity_hint_new
#endif
pango_attr_gravity_hint_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_gravity_new
  .p2align 4
  .type pango_attr_gravity_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_gravity_new
#endif
pango_attr_gravity_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_insert_hyphens_new
  .p2align 4
  .type pango_attr_insert_hyphens_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_insert_hyphens_new
#endif
pango_attr_insert_hyphens_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_copy
  .p2align 4
  .type pango_attr_iterator_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_copy
#endif
pango_attr_iterator_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_destroy
  .p2align 4
  .type pango_attr_iterator_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_destroy
#endif
pango_attr_iterator_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_get
  .p2align 4
  .type pango_attr_iterator_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_get
#endif
pango_attr_iterator_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_get_attrs
  .p2align 4
  .type pango_attr_iterator_get_attrs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_get_attrs
#endif
pango_attr_iterator_get_attrs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_get_font
  .p2align 4
  .type pango_attr_iterator_get_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_get_font
#endif
pango_attr_iterator_get_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_get_type
  .p2align 4
  .type pango_attr_iterator_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_get_type
#endif
pango_attr_iterator_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_next
  .p2align 4
  .type pango_attr_iterator_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_next
#endif
pango_attr_iterator_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_iterator_range
  .p2align 4
  .type pango_attr_iterator_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_iterator_range
#endif
pango_attr_iterator_range:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_language_new
  .p2align 4
  .type pango_attr_language_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_language_new
#endif
pango_attr_language_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_letter_spacing_new
  .p2align 4
  .type pango_attr_letter_spacing_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_letter_spacing_new
#endif
pango_attr_letter_spacing_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_line_height_new
  .p2align 4
  .type pango_attr_line_height_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_line_height_new
#endif
pango_attr_line_height_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_line_height_new_absolute
  .p2align 4
  .type pango_attr_line_height_new_absolute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_line_height_new_absolute
#endif
pango_attr_line_height_new_absolute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_change
  .p2align 4
  .type pango_attr_list_change, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_change
#endif
pango_attr_list_change:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_copy
  .p2align 4
  .type pango_attr_list_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_copy
#endif
pango_attr_list_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_equal
  .p2align 4
  .type pango_attr_list_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_equal
#endif
pango_attr_list_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_filter
  .p2align 4
  .type pango_attr_list_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_filter
#endif
pango_attr_list_filter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_from_string
  .p2align 4
  .type pango_attr_list_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_from_string
#endif
pango_attr_list_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_get_attributes
  .p2align 4
  .type pango_attr_list_get_attributes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_get_attributes
#endif
pango_attr_list_get_attributes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_get_iterator
  .p2align 4
  .type pango_attr_list_get_iterator, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_get_iterator
#endif
pango_attr_list_get_iterator:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_get_type
  .p2align 4
  .type pango_attr_list_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_get_type
#endif
pango_attr_list_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_insert
  .p2align 4
  .type pango_attr_list_insert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_insert
#endif
pango_attr_list_insert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_insert_before
  .p2align 4
  .type pango_attr_list_insert_before, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_insert_before
#endif
pango_attr_list_insert_before:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_new
  .p2align 4
  .type pango_attr_list_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_new
#endif
pango_attr_list_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_ref
  .p2align 4
  .type pango_attr_list_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_ref
#endif
pango_attr_list_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_splice
  .p2align 4
  .type pango_attr_list_splice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_splice
#endif
pango_attr_list_splice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_to_string
  .p2align 4
  .type pango_attr_list_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_to_string
#endif
pango_attr_list_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_unref
  .p2align 4
  .type pango_attr_list_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_unref
#endif
pango_attr_list_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_list_update
  .p2align 4
  .type pango_attr_list_update, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_list_update
#endif
pango_attr_list_update:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_overline_color_new
  .p2align 4
  .type pango_attr_overline_color_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_overline_color_new
#endif
pango_attr_overline_color_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_overline_new
  .p2align 4
  .type pango_attr_overline_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_overline_new
#endif
pango_attr_overline_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_rise_new
  .p2align 4
  .type pango_attr_rise_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_rise_new
#endif
pango_attr_rise_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_scale_new
  .p2align 4
  .type pango_attr_scale_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_scale_new
#endif
pango_attr_scale_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_sentence_new
  .p2align 4
  .type pango_attr_sentence_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_sentence_new
#endif
pango_attr_sentence_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_shape_new
  .p2align 4
  .type pango_attr_shape_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_shape_new
#endif
pango_attr_shape_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_shape_new_with_data
  .p2align 4
  .type pango_attr_shape_new_with_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_shape_new_with_data
#endif
pango_attr_shape_new_with_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_show_new
  .p2align 4
  .type pango_attr_show_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_show_new
#endif
pango_attr_show_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_size_new
  .p2align 4
  .type pango_attr_size_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_size_new
#endif
pango_attr_size_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_size_new_absolute
  .p2align 4
  .type pango_attr_size_new_absolute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_size_new_absolute
#endif
pango_attr_size_new_absolute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_stretch_new
  .p2align 4
  .type pango_attr_stretch_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_stretch_new
#endif
pango_attr_stretch_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_strikethrough_color_new
  .p2align 4
  .type pango_attr_strikethrough_color_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_strikethrough_color_new
#endif
pango_attr_strikethrough_color_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_strikethrough_new
  .p2align 4
  .type pango_attr_strikethrough_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_strikethrough_new
#endif
pango_attr_strikethrough_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_style_new
  .p2align 4
  .type pango_attr_style_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_style_new
#endif
pango_attr_style_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_text_transform_new
  .p2align 4
  .type pango_attr_text_transform_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_text_transform_new
#endif
pango_attr_text_transform_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_type_get_name
  .p2align 4
  .type pango_attr_type_get_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_type_get_name
#endif
pango_attr_type_get_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_type_get_type
  .p2align 4
  .type pango_attr_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_type_get_type
#endif
pango_attr_type_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_type_register
  .p2align 4
  .type pango_attr_type_register, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_type_register
#endif
pango_attr_type_register:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_underline_color_new
  .p2align 4
  .type pango_attr_underline_color_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_underline_color_new
#endif
pango_attr_underline_color_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_underline_new
  .p2align 4
  .type pango_attr_underline_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_underline_new
#endif
pango_attr_underline_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_variant_new
  .p2align 4
  .type pango_attr_variant_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_variant_new
#endif
pango_attr_variant_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_weight_new
  .p2align 4
  .type pango_attr_weight_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_weight_new
#endif
pango_attr_weight_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attr_word_new
  .p2align 4
  .type pango_attr_word_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attr_word_new
#endif
pango_attr_word_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_color
  .p2align 4
  .type pango_attribute_as_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_color
#endif
pango_attribute_as_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_float
  .p2align 4
  .type pango_attribute_as_float, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_float
#endif
pango_attribute_as_float:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_font_desc
  .p2align 4
  .type pango_attribute_as_font_desc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_font_desc
#endif
pango_attribute_as_font_desc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_font_features
  .p2align 4
  .type pango_attribute_as_font_features, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_font_features
#endif
pango_attribute_as_font_features:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_int
  .p2align 4
  .type pango_attribute_as_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_int
#endif
pango_attribute_as_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_language
  .p2align 4
  .type pango_attribute_as_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_language
#endif
pango_attribute_as_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_shape
  .p2align 4
  .type pango_attribute_as_shape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_shape
#endif
pango_attribute_as_shape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_size
  .p2align 4
  .type pango_attribute_as_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_size
#endif
pango_attribute_as_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_as_string
  .p2align 4
  .type pango_attribute_as_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_as_string
#endif
pango_attribute_as_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_copy
  .p2align 4
  .type pango_attribute_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_copy
#endif
pango_attribute_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_destroy
  .p2align 4
  .type pango_attribute_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_destroy
#endif
pango_attribute_destroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_equal
  .p2align 4
  .type pango_attribute_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_equal
#endif
pango_attribute_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_get_type
  .p2align 4
  .type pango_attribute_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_get_type
#endif
pango_attribute_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_attribute_init
  .p2align 4
  .type pango_attribute_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_attribute_init
#endif
pango_attribute_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_baseline_shift_get_type
  .p2align 4
  .type pango_baseline_shift_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_baseline_shift_get_type
#endif
pango_baseline_shift_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_bidi_type_for_unichar
  .p2align 4
  .type pango_bidi_type_for_unichar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_bidi_type_for_unichar
#endif
pango_bidi_type_for_unichar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_bidi_type_get_type
  .p2align 4
  .type pango_bidi_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_bidi_type_get_type
#endif
pango_bidi_type_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_break
  .p2align 4
  .type pango_break, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_break
#endif
pango_break:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_copy
  .p2align 4
  .type pango_color_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_copy
#endif
pango_color_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_free
  .p2align 4
  .type pango_color_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_free
#endif
pango_color_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_get_type
  .p2align 4
  .type pango_color_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_get_type
#endif
pango_color_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_parse
  .p2align 4
  .type pango_color_parse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_parse
#endif
pango_color_parse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_parse_with_alpha
  .p2align 4
  .type pango_color_parse_with_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_parse_with_alpha
#endif
pango_color_parse_with_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_color_to_string
  .p2align 4
  .type pango_color_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_color_to_string
#endif
pango_color_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_config_key_get
  .p2align 4
  .type pango_config_key_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_config_key_get
#endif
pango_config_key_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_config_key_get_system
  .p2align 4
  .type pango_config_key_get_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_config_key_get_system
#endif
pango_config_key_get_system:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_changed
  .p2align 4
  .type pango_context_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_changed
#endif
pango_context_changed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_base_dir
  .p2align 4
  .type pango_context_get_base_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_base_dir
#endif
pango_context_get_base_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_base_gravity
  .p2align 4
  .type pango_context_get_base_gravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_base_gravity
#endif
pango_context_get_base_gravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_font_description
  .p2align 4
  .type pango_context_get_font_description, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_font_description
#endif
pango_context_get_font_description:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_font_map
  .p2align 4
  .type pango_context_get_font_map, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_font_map
#endif
pango_context_get_font_map:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_gravity
  .p2align 4
  .type pango_context_get_gravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_gravity
#endif
pango_context_get_gravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_gravity_hint
  .p2align 4
  .type pango_context_get_gravity_hint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_gravity_hint
#endif
pango_context_get_gravity_hint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_language
  .p2align 4
  .type pango_context_get_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_language
#endif
pango_context_get_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_matrix
  .p2align 4
  .type pango_context_get_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_matrix
#endif
pango_context_get_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_metrics
  .p2align 4
  .type pango_context_get_metrics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_metrics
#endif
pango_context_get_metrics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_round_glyph_positions
  .p2align 4
  .type pango_context_get_round_glyph_positions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_round_glyph_positions
#endif
pango_context_get_round_glyph_positions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_serial
  .p2align 4
  .type pango_context_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_serial
#endif
pango_context_get_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_get_type
  .p2align 4
  .type pango_context_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_get_type
#endif
pango_context_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_list_families
  .p2align 4
  .type pango_context_list_families, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_list_families
#endif
pango_context_list_families:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_load_font
  .p2align 4
  .type pango_context_load_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_load_font
#endif
pango_context_load_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_load_fontset
  .p2align 4
  .type pango_context_load_fontset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_load_fontset
#endif
pango_context_load_fontset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_new
  .p2align 4
  .type pango_context_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_new
#endif
pango_context_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_base_dir
  .p2align 4
  .type pango_context_set_base_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_base_dir
#endif
pango_context_set_base_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_base_gravity
  .p2align 4
  .type pango_context_set_base_gravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_base_gravity
#endif
pango_context_set_base_gravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_font_description
  .p2align 4
  .type pango_context_set_font_description, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_font_description
#endif
pango_context_set_font_description:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_font_map
  .p2align 4
  .type pango_context_set_font_map, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_font_map
#endif
pango_context_set_font_map:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_gravity_hint
  .p2align 4
  .type pango_context_set_gravity_hint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_gravity_hint
#endif
pango_context_set_gravity_hint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_language
  .p2align 4
  .type pango_context_set_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_language
#endif
pango_context_set_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_matrix
  .p2align 4
  .type pango_context_set_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_matrix
#endif
pango_context_set_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_context_set_round_glyph_positions
  .p2align 4
  .type pango_context_set_round_glyph_positions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_context_set_round_glyph_positions
#endif
pango_context_set_round_glyph_positions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_copy
  .p2align 4
  .type pango_coverage_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_copy
#endif
pango_coverage_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_from_bytes
  .p2align 4
  .type pango_coverage_from_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_from_bytes
#endif
pango_coverage_from_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_get
  .p2align 4
  .type pango_coverage_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_get
#endif
pango_coverage_get:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_get_type
  .p2align 4
  .type pango_coverage_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_get_type
#endif
pango_coverage_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_level_get_type
  .p2align 4
  .type pango_coverage_level_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_level_get_type
#endif
pango_coverage_level_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_max
  .p2align 4
  .type pango_coverage_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_max
#endif
pango_coverage_max:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_new
  .p2align 4
  .type pango_coverage_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_new
#endif
pango_coverage_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_ref
  .p2align 4
  .type pango_coverage_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_ref
#endif
pango_coverage_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_set
  .p2align 4
  .type pango_coverage_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_set
#endif
pango_coverage_set:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_to_bytes
  .p2align 4
  .type pango_coverage_to_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_to_bytes
#endif
pango_coverage_to_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_coverage_unref
  .p2align 4
  .type pango_coverage_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_coverage_unref
#endif
pango_coverage_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_default_break
  .p2align 4
  .type pango_default_break, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_default_break
#endif
pango_default_break:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_direction_get_type
  .p2align 4
  .type pango_direction_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_direction_get_type
#endif
pango_direction_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_ellipsize_mode_get_type
  .p2align 4
  .type pango_ellipsize_mode_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_ellipsize_mode_get_type
#endif
pango_ellipsize_mode_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_engine_get_type
  .p2align 4
  .type pango_engine_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_engine_get_type
#endif
pango_engine_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_engine_lang_get_type
  .p2align 4
  .type pango_engine_lang_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_engine_lang_get_type
#endif
pango_engine_lang_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_engine_shape_get_type
  .p2align 4
  .type pango_engine_shape_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_engine_shape_get_type
#endif
pango_engine_shape_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_extents_to_pixels
  .p2align 4
  .type pango_extents_to_pixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_extents_to_pixels
#endif
pango_extents_to_pixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_find_base_dir
  .p2align 4
  .type pango_find_base_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_find_base_dir
#endif
pango_find_base_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_find_map
  .p2align 4
  .type pango_find_map, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_find_map
#endif
pango_find_map:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_find_paragraph_boundary
  .p2align 4
  .type pango_find_paragraph_boundary, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_find_paragraph_boundary
#endif
pango_find_paragraph_boundary:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_describe
  .p2align 4
  .type pango_font_describe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_describe
#endif
pango_font_describe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_describe_with_absolute_size
  .p2align 4
  .type pango_font_describe_with_absolute_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_describe_with_absolute_size
#endif
pango_font_describe_with_absolute_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_better_match
  .p2align 4
  .type pango_font_description_better_match, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_better_match
#endif
pango_font_description_better_match:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_copy
  .p2align 4
  .type pango_font_description_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_copy
#endif
pango_font_description_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_copy_static
  .p2align 4
  .type pango_font_description_copy_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_copy_static
#endif
pango_font_description_copy_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_equal
  .p2align 4
  .type pango_font_description_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_equal
#endif
pango_font_description_equal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_free
  .p2align 4
  .type pango_font_description_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_free
#endif
pango_font_description_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_from_string
  .p2align 4
  .type pango_font_description_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_from_string
#endif
pango_font_description_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_family
  .p2align 4
  .type pango_font_description_get_family, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_family
#endif
pango_font_description_get_family:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_features
  .p2align 4
  .type pango_font_description_get_features, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_features
#endif
pango_font_description_get_features:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_gravity
  .p2align 4
  .type pango_font_description_get_gravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_gravity
#endif
pango_font_description_get_gravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_set_fields
  .p2align 4
  .type pango_font_description_get_set_fields, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_set_fields
#endif
pango_font_description_get_set_fields:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_size
  .p2align 4
  .type pango_font_description_get_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_size
#endif
pango_font_description_get_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_size_is_absolute
  .p2align 4
  .type pango_font_description_get_size_is_absolute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_size_is_absolute
#endif
pango_font_description_get_size_is_absolute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_stretch
  .p2align 4
  .type pango_font_description_get_stretch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_stretch
#endif
pango_font_description_get_stretch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_style
  .p2align 4
  .type pango_font_description_get_style, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_style
#endif
pango_font_description_get_style:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_type
  .p2align 4
  .type pango_font_description_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_type
#endif
pango_font_description_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_variant
  .p2align 4
  .type pango_font_description_get_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_variant
#endif
pango_font_description_get_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_variations
  .p2align 4
  .type pango_font_description_get_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_variations
#endif
pango_font_description_get_variations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_get_weight
  .p2align 4
  .type pango_font_description_get_weight, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_get_weight
#endif
pango_font_description_get_weight:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_hash
  .p2align 4
  .type pango_font_description_hash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_hash
#endif
pango_font_description_hash:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_merge
  .p2align 4
  .type pango_font_description_merge, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_merge
#endif
pango_font_description_merge:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_merge_static
  .p2align 4
  .type pango_font_description_merge_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_merge_static
#endif
pango_font_description_merge_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_new
  .p2align 4
  .type pango_font_description_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_new
#endif
pango_font_description_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_absolute_size
  .p2align 4
  .type pango_font_description_set_absolute_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_absolute_size
#endif
pango_font_description_set_absolute_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_family
  .p2align 4
  .type pango_font_description_set_family, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_family
#endif
pango_font_description_set_family:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_family_static
  .p2align 4
  .type pango_font_description_set_family_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_family_static
#endif
pango_font_description_set_family_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_features
  .p2align 4
  .type pango_font_description_set_features, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_features
#endif
pango_font_description_set_features:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_features_static
  .p2align 4
  .type pango_font_description_set_features_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_features_static
#endif
pango_font_description_set_features_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_gravity
  .p2align 4
  .type pango_font_description_set_gravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_gravity
#endif
pango_font_description_set_gravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_size
  .p2align 4
  .type pango_font_description_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_size
#endif
pango_font_description_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_stretch
  .p2align 4
  .type pango_font_description_set_stretch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_stretch
#endif
pango_font_description_set_stretch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_style
  .p2align 4
  .type pango_font_description_set_style, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_style
#endif
pango_font_description_set_style:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_variant
  .p2align 4
  .type pango_font_description_set_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_variant
#endif
pango_font_description_set_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_variations
  .p2align 4
  .type pango_font_description_set_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_variations
#endif
pango_font_description_set_variations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_variations_static
  .p2align 4
  .type pango_font_description_set_variations_static, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_variations_static
#endif
pango_font_description_set_variations_static:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_set_weight
  .p2align 4
  .type pango_font_description_set_weight, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_set_weight
#endif
pango_font_description_set_weight:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_to_filename
  .p2align 4
  .type pango_font_description_to_filename, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_to_filename
#endif
pango_font_description_to_filename:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_to_string
  .p2align 4
  .type pango_font_description_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_to_string
#endif
pango_font_description_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_description_unset_fields
  .p2align 4
  .type pango_font_description_unset_fields, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_description_unset_fields
#endif
pango_font_description_unset_fields:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_descriptions_free
  .p2align 4
  .type pango_font_descriptions_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_descriptions_free
#endif
pango_font_descriptions_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_deserialize
  .p2align 4
  .type pango_font_deserialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_deserialize
#endif
pango_font_deserialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_describe
  .p2align 4
  .type pango_font_face_describe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_describe
#endif
pango_font_face_describe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_get_face_name
  .p2align 4
  .type pango_font_face_get_face_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_get_face_name
#endif
pango_font_face_get_face_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_get_family
  .p2align 4
  .type pango_font_face_get_family, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_get_family
#endif
pango_font_face_get_family:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_get_type
  .p2align 4
  .type pango_font_face_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_get_type
#endif
pango_font_face_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_is_synthesized
  .p2align 4
  .type pango_font_face_is_synthesized, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_is_synthesized
#endif
pango_font_face_is_synthesized:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_face_list_sizes
  .p2align 4
  .type pango_font_face_list_sizes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_face_list_sizes
#endif
pango_font_face_list_sizes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_get_face
  .p2align 4
  .type pango_font_family_get_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_get_face
#endif
pango_font_family_get_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_get_name
  .p2align 4
  .type pango_font_family_get_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_get_name
#endif
pango_font_family_get_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_get_type
  .p2align 4
  .type pango_font_family_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_get_type
#endif
pango_font_family_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_is_monospace
  .p2align 4
  .type pango_font_family_is_monospace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_is_monospace
#endif
pango_font_family_is_monospace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_is_variable
  .p2align 4
  .type pango_font_family_is_variable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_is_variable
#endif
pango_font_family_is_variable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_family_list_faces
  .p2align 4
  .type pango_font_family_list_faces, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_family_list_faces
#endif
pango_font_family_list_faces:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_find_shaper
  .p2align 4
  .type pango_font_find_shaper, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_find_shaper
#endif
pango_font_find_shaper:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_coverage
  .p2align 4
  .type pango_font_get_coverage, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_coverage
#endif
pango_font_get_coverage:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_face
  .p2align 4
  .type pango_font_get_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_face
#endif
pango_font_get_face:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_features
  .p2align 4
  .type pango_font_get_features, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_features
#endif
pango_font_get_features:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_font_map
  .p2align 4
  .type pango_font_get_font_map, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_font_map
#endif
pango_font_get_font_map:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_glyph_extents
  .p2align 4
  .type pango_font_get_glyph_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_glyph_extents
#endif
pango_font_get_glyph_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_hb_font
  .p2align 4
  .type pango_font_get_hb_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_hb_font
#endif
pango_font_get_hb_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_languages
  .p2align 4
  .type pango_font_get_languages, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_languages
#endif
pango_font_get_languages:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_metrics
  .p2align 4
  .type pango_font_get_metrics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_metrics
#endif
pango_font_get_metrics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_get_type
  .p2align 4
  .type pango_font_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_get_type
#endif
pango_font_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_has_char
  .p2align 4
  .type pango_font_has_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_has_char
#endif
pango_font_has_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_add_font_file
  .p2align 4
  .type pango_font_map_add_font_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_add_font_file
#endif
pango_font_map_add_font_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_changed
  .p2align 4
  .type pango_font_map_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_changed
#endif
pango_font_map_changed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_create_context
  .p2align 4
  .type pango_font_map_create_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_create_context
#endif
pango_font_map_create_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_get_family
  .p2align 4
  .type pango_font_map_get_family, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_get_family
#endif
pango_font_map_get_family:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_get_serial
  .p2align 4
  .type pango_font_map_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_get_serial
#endif
pango_font_map_get_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_get_shape_engine_type
  .p2align 4
  .type pango_font_map_get_shape_engine_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_get_shape_engine_type
#endif
pango_font_map_get_shape_engine_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_get_type
  .p2align 4
  .type pango_font_map_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_get_type
#endif
pango_font_map_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_list_families
  .p2align 4
  .type pango_font_map_list_families, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_list_families
#endif
pango_font_map_list_families:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_load_font
  .p2align 4
  .type pango_font_map_load_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_load_font
#endif
pango_font_map_load_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_load_fontset
  .p2align 4
  .type pango_font_map_load_fontset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_load_fontset
#endif
pango_font_map_load_fontset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_map_reload_font
  .p2align 4
  .type pango_font_map_reload_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_map_reload_font
#endif
pango_font_map_reload_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_mask_get_type
  .p2align 4
  .type pango_font_mask_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_mask_get_type
#endif
pango_font_mask_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_approximate_char_width
  .p2align 4
  .type pango_font_metrics_get_approximate_char_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_approximate_char_width
#endif
pango_font_metrics_get_approximate_char_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_approximate_digit_width
  .p2align 4
  .type pango_font_metrics_get_approximate_digit_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_approximate_digit_width
#endif
pango_font_metrics_get_approximate_digit_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_ascent
  .p2align 4
  .type pango_font_metrics_get_ascent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_ascent
#endif
pango_font_metrics_get_ascent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_descent
  .p2align 4
  .type pango_font_metrics_get_descent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_descent
#endif
pango_font_metrics_get_descent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_height
  .p2align 4
  .type pango_font_metrics_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_height
#endif
pango_font_metrics_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_strikethrough_position
  .p2align 4
  .type pango_font_metrics_get_strikethrough_position, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_strikethrough_position
#endif
pango_font_metrics_get_strikethrough_position:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_strikethrough_thickness
  .p2align 4
  .type pango_font_metrics_get_strikethrough_thickness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_strikethrough_thickness
#endif
pango_font_metrics_get_strikethrough_thickness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_type
  .p2align 4
  .type pango_font_metrics_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_type
#endif
pango_font_metrics_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_underline_position
  .p2align 4
  .type pango_font_metrics_get_underline_position, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_underline_position
#endif
pango_font_metrics_get_underline_position:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_get_underline_thickness
  .p2align 4
  .type pango_font_metrics_get_underline_thickness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_get_underline_thickness
#endif
pango_font_metrics_get_underline_thickness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_new
  .p2align 4
  .type pango_font_metrics_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_new
#endif
pango_font_metrics_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_ref
  .p2align 4
  .type pango_font_metrics_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_ref
#endif
pango_font_metrics_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_metrics_unref
  .p2align 4
  .type pango_font_metrics_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_metrics_unref
#endif
pango_font_metrics_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_scale_get_type
  .p2align 4
  .type pango_font_scale_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_scale_get_type
#endif
pango_font_scale_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_font_serialize
  .p2align 4
  .type pango_font_serialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_font_serialize
#endif
pango_font_serialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_foreach
  .p2align 4
  .type pango_fontset_foreach, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_foreach
#endif
pango_fontset_foreach:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_get_font
  .p2align 4
  .type pango_fontset_get_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_get_font
#endif
pango_fontset_get_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_get_metrics
  .p2align 4
  .type pango_fontset_get_metrics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_get_metrics
#endif
pango_fontset_get_metrics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_get_type
  .p2align 4
  .type pango_fontset_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_get_type
#endif
pango_fontset_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_simple_append
  .p2align 4
  .type pango_fontset_simple_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_simple_append
#endif
pango_fontset_simple_append:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_simple_get_type
  .p2align 4
  .type pango_fontset_simple_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_simple_get_type
#endif
pango_fontset_simple_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_simple_new
  .p2align 4
  .type pango_fontset_simple_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_simple_new
#endif
pango_fontset_simple_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_fontset_simple_size
  .p2align 4
  .type pango_fontset_simple_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_fontset_simple_size
#endif
pango_fontset_simple_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_get_lib_subdirectory
  .p2align 4
  .type pango_get_lib_subdirectory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_get_lib_subdirectory
#endif
pango_get_lib_subdirectory:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_get_log_attrs
  .p2align 4
  .type pango_get_log_attrs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_get_log_attrs
#endif
pango_get_log_attrs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_get_mirror_char
  .p2align 4
  .type pango_get_mirror_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_get_mirror_char
#endif
pango_get_mirror_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_get_sysconf_subdirectory
  .p2align 4
  .type pango_get_sysconf_subdirectory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_get_sysconf_subdirectory
#endif
pango_get_sysconf_subdirectory:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_apply_attrs
  .p2align 4
  .type pango_glyph_item_apply_attrs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_apply_attrs
#endif
pango_glyph_item_apply_attrs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_copy
  .p2align 4
  .type pango_glyph_item_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_copy
#endif
pango_glyph_item_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_free
  .p2align 4
  .type pango_glyph_item_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_free
#endif
pango_glyph_item_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_get_logical_widths
  .p2align 4
  .type pango_glyph_item_get_logical_widths, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_get_logical_widths
#endif
pango_glyph_item_get_logical_widths:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_get_type
  .p2align 4
  .type pango_glyph_item_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_get_type
#endif
pango_glyph_item_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_copy
  .p2align 4
  .type pango_glyph_item_iter_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_copy
#endif
pango_glyph_item_iter_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_free
  .p2align 4
  .type pango_glyph_item_iter_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_free
#endif
pango_glyph_item_iter_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_get_type
  .p2align 4
  .type pango_glyph_item_iter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_get_type
#endif
pango_glyph_item_iter_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_init_end
  .p2align 4
  .type pango_glyph_item_iter_init_end, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_init_end
#endif
pango_glyph_item_iter_init_end:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_init_start
  .p2align 4
  .type pango_glyph_item_iter_init_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_init_start
#endif
pango_glyph_item_iter_init_start:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_next_cluster
  .p2align 4
  .type pango_glyph_item_iter_next_cluster, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_next_cluster
#endif
pango_glyph_item_iter_next_cluster:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_iter_prev_cluster
  .p2align 4
  .type pango_glyph_item_iter_prev_cluster, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_iter_prev_cluster
#endif
pango_glyph_item_iter_prev_cluster:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_letter_space
  .p2align 4
  .type pango_glyph_item_letter_space, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_letter_space
#endif
pango_glyph_item_letter_space:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_item_split
  .p2align 4
  .type pango_glyph_item_split, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_item_split
#endif
pango_glyph_item_split:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_copy
  .p2align 4
  .type pango_glyph_string_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_copy
#endif
pango_glyph_string_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_extents
  .p2align 4
  .type pango_glyph_string_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_extents
#endif
pango_glyph_string_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_extents_range
  .p2align 4
  .type pango_glyph_string_extents_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_extents_range
#endif
pango_glyph_string_extents_range:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_free
  .p2align 4
  .type pango_glyph_string_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_free
#endif
pango_glyph_string_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_get_logical_widths
  .p2align 4
  .type pango_glyph_string_get_logical_widths, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_get_logical_widths
#endif
pango_glyph_string_get_logical_widths:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_get_type
  .p2align 4
  .type pango_glyph_string_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_get_type
#endif
pango_glyph_string_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_get_width
  .p2align 4
  .type pango_glyph_string_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_get_width
#endif
pango_glyph_string_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_index_to_x
  .p2align 4
  .type pango_glyph_string_index_to_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_index_to_x
#endif
pango_glyph_string_index_to_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_index_to_x_full
  .p2align 4
  .type pango_glyph_string_index_to_x_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_index_to_x_full
#endif
pango_glyph_string_index_to_x_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_new
  .p2align 4
  .type pango_glyph_string_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_new
#endif
pango_glyph_string_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_set_size
  .p2align 4
  .type pango_glyph_string_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_set_size
#endif
pango_glyph_string_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_glyph_string_x_to_index
  .p2align 4
  .type pango_glyph_string_x_to_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_glyph_string_x_to_index
#endif
pango_glyph_string_x_to_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_get_for_matrix
  .p2align 4
  .type pango_gravity_get_for_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_get_for_matrix
#endif
pango_gravity_get_for_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_get_for_script
  .p2align 4
  .type pango_gravity_get_for_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_get_for_script
#endif
pango_gravity_get_for_script:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_get_for_script_and_width
  .p2align 4
  .type pango_gravity_get_for_script_and_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_get_for_script_and_width
#endif
pango_gravity_get_for_script_and_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_get_type
  .p2align 4
  .type pango_gravity_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_get_type
#endif
pango_gravity_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_hint_get_type
  .p2align 4
  .type pango_gravity_hint_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_hint_get_type
#endif
pango_gravity_hint_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_gravity_to_rotation
  .p2align 4
  .type pango_gravity_to_rotation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_gravity_to_rotation
#endif
pango_gravity_to_rotation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_is_zero_width
  .p2align 4
  .type pango_is_zero_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_is_zero_width
#endif
pango_is_zero_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_apply_attrs
  .p2align 4
  .type pango_item_apply_attrs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_apply_attrs
#endif
pango_item_apply_attrs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_copy
  .p2align 4
  .type pango_item_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_copy
#endif
pango_item_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_free
  .p2align 4
  .type pango_item_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_free
#endif
pango_item_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_get_char_offset
  .p2align 4
  .type pango_item_get_char_offset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_get_char_offset
#endif
pango_item_get_char_offset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_get_type
  .p2align 4
  .type pango_item_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_get_type
#endif
pango_item_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_new
  .p2align 4
  .type pango_item_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_new
#endif
pango_item_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_item_split
  .p2align 4
  .type pango_item_split, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_item_split
#endif
pango_item_split:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_itemize
  .p2align 4
  .type pango_itemize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_itemize
#endif
pango_itemize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_itemize_with_base_dir
  .p2align 4
  .type pango_itemize_with_base_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_itemize_with_base_dir
#endif
pango_itemize_with_base_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_from_string
  .p2align 4
  .type pango_language_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_from_string
#endif
pango_language_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_get_default
  .p2align 4
  .type pango_language_get_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_get_default
#endif
pango_language_get_default:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_get_preferred
  .p2align 4
  .type pango_language_get_preferred, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_get_preferred
#endif
pango_language_get_preferred:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_get_sample_string
  .p2align 4
  .type pango_language_get_sample_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_get_sample_string
#endif
pango_language_get_sample_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_get_scripts
  .p2align 4
  .type pango_language_get_scripts, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_get_scripts
#endif
pango_language_get_scripts:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_get_type
  .p2align 4
  .type pango_language_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_get_type
#endif
pango_language_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_includes_script
  .p2align 4
  .type pango_language_includes_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_includes_script
#endif
pango_language_includes_script:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_matches
  .p2align 4
  .type pango_language_matches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_matches
#endif
pango_language_matches:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_language_to_string
  .p2align 4
  .type pango_language_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_language_to_string
#endif
pango_language_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_context_changed
  .p2align 4
  .type pango_layout_context_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_context_changed
#endif
pango_layout_context_changed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_copy
  .p2align 4
  .type pango_layout_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_copy
#endif
pango_layout_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_deserialize
  .p2align 4
  .type pango_layout_deserialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_deserialize
#endif
pango_layout_deserialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_deserialize_error_get_type
  .p2align 4
  .type pango_layout_deserialize_error_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_deserialize_error_get_type
#endif
pango_layout_deserialize_error_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_deserialize_error_quark
  .p2align 4
  .type pango_layout_deserialize_error_quark, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_deserialize_error_quark
#endif
pango_layout_deserialize_error_quark:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_deserialize_flags_get_type
  .p2align 4
  .type pango_layout_deserialize_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_deserialize_flags_get_type
#endif
pango_layout_deserialize_flags_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_alignment
  .p2align 4
  .type pango_layout_get_alignment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_alignment
#endif
pango_layout_get_alignment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_attributes
  .p2align 4
  .type pango_layout_get_attributes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_attributes
#endif
pango_layout_get_attributes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_auto_dir
  .p2align 4
  .type pango_layout_get_auto_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_auto_dir
#endif
pango_layout_get_auto_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_baseline
  .p2align 4
  .type pango_layout_get_baseline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_baseline
#endif
pango_layout_get_baseline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_caret_pos
  .p2align 4
  .type pango_layout_get_caret_pos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_caret_pos
#endif
pango_layout_get_caret_pos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_character_count
  .p2align 4
  .type pango_layout_get_character_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_character_count
#endif
pango_layout_get_character_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_context
  .p2align 4
  .type pango_layout_get_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_context
#endif
pango_layout_get_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_cursor_pos
  .p2align 4
  .type pango_layout_get_cursor_pos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_cursor_pos
#endif
pango_layout_get_cursor_pos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_direction
  .p2align 4
  .type pango_layout_get_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_direction
#endif
pango_layout_get_direction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_ellipsize
  .p2align 4
  .type pango_layout_get_ellipsize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_ellipsize
#endif
pango_layout_get_ellipsize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_extents
  .p2align 4
  .type pango_layout_get_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_extents
#endif
pango_layout_get_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_font_description
  .p2align 4
  .type pango_layout_get_font_description, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_font_description
#endif
pango_layout_get_font_description:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_height
  .p2align 4
  .type pango_layout_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_height
#endif
pango_layout_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_indent
  .p2align 4
  .type pango_layout_get_indent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_indent
#endif
pango_layout_get_indent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_iter
  .p2align 4
  .type pango_layout_get_iter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_iter
#endif
pango_layout_get_iter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_justify
  .p2align 4
  .type pango_layout_get_justify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_justify
#endif
pango_layout_get_justify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_justify_last_line
  .p2align 4
  .type pango_layout_get_justify_last_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_justify_last_line
#endif
pango_layout_get_justify_last_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_line
  .p2align 4
  .type pango_layout_get_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_line
#endif
pango_layout_get_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_line_count
  .p2align 4
  .type pango_layout_get_line_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_line_count
#endif
pango_layout_get_line_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_line_readonly
  .p2align 4
  .type pango_layout_get_line_readonly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_line_readonly
#endif
pango_layout_get_line_readonly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_line_spacing
  .p2align 4
  .type pango_layout_get_line_spacing, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_line_spacing
#endif
pango_layout_get_line_spacing:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_lines
  .p2align 4
  .type pango_layout_get_lines, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_lines
#endif
pango_layout_get_lines:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_lines_readonly
  .p2align 4
  .type pango_layout_get_lines_readonly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_lines_readonly
#endif
pango_layout_get_lines_readonly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_log_attrs
  .p2align 4
  .type pango_layout_get_log_attrs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_log_attrs
#endif
pango_layout_get_log_attrs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_log_attrs_readonly
  .p2align 4
  .type pango_layout_get_log_attrs_readonly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_log_attrs_readonly
#endif
pango_layout_get_log_attrs_readonly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_pixel_extents
  .p2align 4
  .type pango_layout_get_pixel_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_pixel_extents
#endif
pango_layout_get_pixel_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_pixel_size
  .p2align 4
  .type pango_layout_get_pixel_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_pixel_size
#endif
pango_layout_get_pixel_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_serial
  .p2align 4
  .type pango_layout_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_serial
#endif
pango_layout_get_serial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_single_paragraph_mode
  .p2align 4
  .type pango_layout_get_single_paragraph_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_single_paragraph_mode
#endif
pango_layout_get_single_paragraph_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_size
  .p2align 4
  .type pango_layout_get_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_size
#endif
pango_layout_get_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_spacing
  .p2align 4
  .type pango_layout_get_spacing, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_spacing
#endif
pango_layout_get_spacing:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_tabs
  .p2align 4
  .type pango_layout_get_tabs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_tabs
#endif
pango_layout_get_tabs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_text
  .p2align 4
  .type pango_layout_get_text, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_text
#endif
pango_layout_get_text:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_type
  .p2align 4
  .type pango_layout_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_type
#endif
pango_layout_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_unknown_glyphs_count
  .p2align 4
  .type pango_layout_get_unknown_glyphs_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_unknown_glyphs_count
#endif
pango_layout_get_unknown_glyphs_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_width
  .p2align 4
  .type pango_layout_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_width
#endif
pango_layout_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_get_wrap
  .p2align 4
  .type pango_layout_get_wrap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_get_wrap
#endif
pango_layout_get_wrap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_index_to_line_x
  .p2align 4
  .type pango_layout_index_to_line_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_index_to_line_x
#endif
pango_layout_index_to_line_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_index_to_pos
  .p2align 4
  .type pango_layout_index_to_pos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_index_to_pos
#endif
pango_layout_index_to_pos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_is_ellipsized
  .p2align 4
  .type pango_layout_is_ellipsized, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_is_ellipsized
#endif
pango_layout_is_ellipsized:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_is_wrapped
  .p2align 4
  .type pango_layout_is_wrapped, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_is_wrapped
#endif
pango_layout_is_wrapped:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_at_last_line
  .p2align 4
  .type pango_layout_iter_at_last_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_at_last_line
#endif
pango_layout_iter_at_last_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_copy
  .p2align 4
  .type pango_layout_iter_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_copy
#endif
pango_layout_iter_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_free
  .p2align 4
  .type pango_layout_iter_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_free
#endif
pango_layout_iter_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_baseline
  .p2align 4
  .type pango_layout_iter_get_baseline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_baseline
#endif
pango_layout_iter_get_baseline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_char_extents
  .p2align 4
  .type pango_layout_iter_get_char_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_char_extents
#endif
pango_layout_iter_get_char_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_cluster_extents
  .p2align 4
  .type pango_layout_iter_get_cluster_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_cluster_extents
#endif
pango_layout_iter_get_cluster_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_index
  .p2align 4
  .type pango_layout_iter_get_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_index
#endif
pango_layout_iter_get_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_layout
  .p2align 4
  .type pango_layout_iter_get_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_layout
#endif
pango_layout_iter_get_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_layout_extents
  .p2align 4
  .type pango_layout_iter_get_layout_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_layout_extents
#endif
pango_layout_iter_get_layout_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_line
  .p2align 4
  .type pango_layout_iter_get_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_line
#endif
pango_layout_iter_get_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_line_extents
  .p2align 4
  .type pango_layout_iter_get_line_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_line_extents
#endif
pango_layout_iter_get_line_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_line_readonly
  .p2align 4
  .type pango_layout_iter_get_line_readonly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_line_readonly
#endif
pango_layout_iter_get_line_readonly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_line_yrange
  .p2align 4
  .type pango_layout_iter_get_line_yrange, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_line_yrange
#endif
pango_layout_iter_get_line_yrange:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_run
  .p2align 4
  .type pango_layout_iter_get_run, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_run
#endif
pango_layout_iter_get_run:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_run_baseline
  .p2align 4
  .type pango_layout_iter_get_run_baseline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_run_baseline
#endif
pango_layout_iter_get_run_baseline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_run_extents
  .p2align 4
  .type pango_layout_iter_get_run_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_run_extents
#endif
pango_layout_iter_get_run_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_run_readonly
  .p2align 4
  .type pango_layout_iter_get_run_readonly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_run_readonly
#endif
pango_layout_iter_get_run_readonly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_get_type
  .p2align 4
  .type pango_layout_iter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_get_type
#endif
pango_layout_iter_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_next_char
  .p2align 4
  .type pango_layout_iter_next_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_next_char
#endif
pango_layout_iter_next_char:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_next_cluster
  .p2align 4
  .type pango_layout_iter_next_cluster, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_next_cluster
#endif
pango_layout_iter_next_cluster:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_next_line
  .p2align 4
  .type pango_layout_iter_next_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_next_line
#endif
pango_layout_iter_next_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_iter_next_run
  .p2align 4
  .type pango_layout_iter_next_run, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_iter_next_run
#endif
pango_layout_iter_next_run:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_extents
  .p2align 4
  .type pango_layout_line_get_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_extents
#endif
pango_layout_line_get_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_height
  .p2align 4
  .type pango_layout_line_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_height
#endif
pango_layout_line_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_length
  .p2align 4
  .type pango_layout_line_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_length
#endif
pango_layout_line_get_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_pixel_extents
  .p2align 4
  .type pango_layout_line_get_pixel_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_pixel_extents
#endif
pango_layout_line_get_pixel_extents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_resolved_direction
  .p2align 4
  .type pango_layout_line_get_resolved_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_resolved_direction
#endif
pango_layout_line_get_resolved_direction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_start_index
  .p2align 4
  .type pango_layout_line_get_start_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_start_index
#endif
pango_layout_line_get_start_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_type
  .p2align 4
  .type pango_layout_line_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_type
#endif
pango_layout_line_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_get_x_ranges
  .p2align 4
  .type pango_layout_line_get_x_ranges, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_get_x_ranges
#endif
pango_layout_line_get_x_ranges:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_index_to_x
  .p2align 4
  .type pango_layout_line_index_to_x, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_index_to_x
#endif
pango_layout_line_index_to_x:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_is_paragraph_start
  .p2align 4
  .type pango_layout_line_is_paragraph_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_is_paragraph_start
#endif
pango_layout_line_is_paragraph_start:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_ref
  .p2align 4
  .type pango_layout_line_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_ref
#endif
pango_layout_line_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_unref
  .p2align 4
  .type pango_layout_line_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_unref
#endif
pango_layout_line_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_line_x_to_index
  .p2align 4
  .type pango_layout_line_x_to_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_line_x_to_index
#endif
pango_layout_line_x_to_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_move_cursor_visually
  .p2align 4
  .type pango_layout_move_cursor_visually, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_move_cursor_visually
#endif
pango_layout_move_cursor_visually:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_new
  .p2align 4
  .type pango_layout_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_new
#endif
pango_layout_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_serialize
  .p2align 4
  .type pango_layout_serialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_serialize
#endif
pango_layout_serialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_serialize_flags_get_type
  .p2align 4
  .type pango_layout_serialize_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_serialize_flags_get_type
#endif
pango_layout_serialize_flags_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_alignment
  .p2align 4
  .type pango_layout_set_alignment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_alignment
#endif
pango_layout_set_alignment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_attributes
  .p2align 4
  .type pango_layout_set_attributes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_attributes
#endif
pango_layout_set_attributes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_auto_dir
  .p2align 4
  .type pango_layout_set_auto_dir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_auto_dir
#endif
pango_layout_set_auto_dir:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_ellipsize
  .p2align 4
  .type pango_layout_set_ellipsize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_ellipsize
#endif
pango_layout_set_ellipsize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_font_description
  .p2align 4
  .type pango_layout_set_font_description, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_font_description
#endif
pango_layout_set_font_description:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_height
  .p2align 4
  .type pango_layout_set_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_height
#endif
pango_layout_set_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_indent
  .p2align 4
  .type pango_layout_set_indent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_indent
#endif
pango_layout_set_indent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_justify
  .p2align 4
  .type pango_layout_set_justify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_justify
#endif
pango_layout_set_justify:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_justify_last_line
  .p2align 4
  .type pango_layout_set_justify_last_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_justify_last_line
#endif
pango_layout_set_justify_last_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_line_spacing
  .p2align 4
  .type pango_layout_set_line_spacing, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_line_spacing
#endif
pango_layout_set_line_spacing:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_markup
  .p2align 4
  .type pango_layout_set_markup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_markup
#endif
pango_layout_set_markup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_markup_with_accel
  .p2align 4
  .type pango_layout_set_markup_with_accel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_markup_with_accel
#endif
pango_layout_set_markup_with_accel:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_single_paragraph_mode
  .p2align 4
  .type pango_layout_set_single_paragraph_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_single_paragraph_mode
#endif
pango_layout_set_single_paragraph_mode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_spacing
  .p2align 4
  .type pango_layout_set_spacing, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_spacing
#endif
pango_layout_set_spacing:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_tabs
  .p2align 4
  .type pango_layout_set_tabs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_tabs
#endif
pango_layout_set_tabs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_text
  .p2align 4
  .type pango_layout_set_text, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_text
#endif
pango_layout_set_text:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_width
  .p2align 4
  .type pango_layout_set_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_width
#endif
pango_layout_set_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_set_wrap
  .p2align 4
  .type pango_layout_set_wrap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_set_wrap
#endif
pango_layout_set_wrap:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_write_to_file
  .p2align 4
  .type pango_layout_write_to_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_write_to_file
#endif
pango_layout_write_to_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_layout_xy_to_index
  .p2align 4
  .type pango_layout_xy_to_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_layout_xy_to_index
#endif
pango_layout_xy_to_index:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_log2vis_get_embedding_levels
  .p2align 4
  .type pango_log2vis_get_embedding_levels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_log2vis_get_embedding_levels
#endif
pango_log2vis_get_embedding_levels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_lookup_aliases
  .p2align 4
  .type pango_lookup_aliases, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_lookup_aliases
#endif
pango_lookup_aliases:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_map_get_engine
  .p2align 4
  .type pango_map_get_engine, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_map_get_engine
#endif
pango_map_get_engine:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_map_get_engines
  .p2align 4
  .type pango_map_get_engines, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_map_get_engines
#endif
pango_map_get_engines:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_markup_parser_finish
  .p2align 4
  .type pango_markup_parser_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_markup_parser_finish
#endif
pango_markup_parser_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_markup_parser_new
  .p2align 4
  .type pango_markup_parser_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_markup_parser_new
#endif
pango_markup_parser_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_concat
  .p2align 4
  .type pango_matrix_concat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_concat
#endif
pango_matrix_concat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_copy
  .p2align 4
  .type pango_matrix_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_copy
#endif
pango_matrix_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_free
  .p2align 4
  .type pango_matrix_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_free
#endif
pango_matrix_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_get_font_scale_factor
  .p2align 4
  .type pango_matrix_get_font_scale_factor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_get_font_scale_factor
#endif
pango_matrix_get_font_scale_factor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_get_font_scale_factors
  .p2align 4
  .type pango_matrix_get_font_scale_factors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_get_font_scale_factors
#endif
pango_matrix_get_font_scale_factors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_get_slant_ratio
  .p2align 4
  .type pango_matrix_get_slant_ratio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_get_slant_ratio
#endif
pango_matrix_get_slant_ratio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_get_type
  .p2align 4
  .type pango_matrix_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_get_type
#endif
pango_matrix_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_rotate
  .p2align 4
  .type pango_matrix_rotate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_rotate
#endif
pango_matrix_rotate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_scale
  .p2align 4
  .type pango_matrix_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_scale
#endif
pango_matrix_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_transform_distance
  .p2align 4
  .type pango_matrix_transform_distance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_transform_distance
#endif
pango_matrix_transform_distance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_transform_pixel_rectangle
  .p2align 4
  .type pango_matrix_transform_pixel_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_transform_pixel_rectangle
#endif
pango_matrix_transform_pixel_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_transform_point
  .p2align 4
  .type pango_matrix_transform_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_transform_point
#endif
pango_matrix_transform_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_transform_rectangle
  .p2align 4
  .type pango_matrix_transform_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_transform_rectangle
#endif
pango_matrix_transform_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_matrix_translate
  .p2align 4
  .type pango_matrix_translate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_matrix_translate
#endif
pango_matrix_translate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_module_register
  .p2align 4
  .type pango_module_register, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_module_register
#endif
pango_module_register:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_overline_get_type
  .p2align 4
  .type pango_overline_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_overline_get_type
#endif
pango_overline_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_enum
  .p2align 4
  .type pango_parse_enum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_enum
#endif
pango_parse_enum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_markup
  .p2align 4
  .type pango_parse_markup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_markup
#endif
pango_parse_markup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_stretch
  .p2align 4
  .type pango_parse_stretch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_stretch
#endif
pango_parse_stretch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_style
  .p2align 4
  .type pango_parse_style, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_style
#endif
pango_parse_style:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_variant
  .p2align 4
  .type pango_parse_variant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_variant
#endif
pango_parse_variant:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_parse_weight
  .p2align 4
  .type pango_parse_weight, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_parse_weight
#endif
pango_parse_weight:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_quantize_line_geometry
  .p2align 4
  .type pango_quantize_line_geometry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_quantize_line_geometry
#endif
pango_quantize_line_geometry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_read_line
  .p2align 4
  .type pango_read_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_read_line
#endif
pango_read_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_render_part_get_type
  .p2align 4
  .type pango_render_part_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_render_part_get_type
#endif
pango_render_part_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_activate
  .p2align 4
  .type pango_renderer_activate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_activate
#endif
pango_renderer_activate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_deactivate
  .p2align 4
  .type pango_renderer_deactivate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_deactivate
#endif
pango_renderer_deactivate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_error_underline
  .p2align 4
  .type pango_renderer_draw_error_underline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_error_underline
#endif
pango_renderer_draw_error_underline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_glyph
  .p2align 4
  .type pango_renderer_draw_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_glyph
#endif
pango_renderer_draw_glyph:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_glyph_item
  .p2align 4
  .type pango_renderer_draw_glyph_item, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_glyph_item
#endif
pango_renderer_draw_glyph_item:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_glyphs
  .p2align 4
  .type pango_renderer_draw_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_glyphs
#endif
pango_renderer_draw_glyphs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_layout
  .p2align 4
  .type pango_renderer_draw_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_layout
#endif
pango_renderer_draw_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_layout_line
  .p2align 4
  .type pango_renderer_draw_layout_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_layout_line
#endif
pango_renderer_draw_layout_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_rectangle
  .p2align 4
  .type pango_renderer_draw_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_rectangle
#endif
pango_renderer_draw_rectangle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_draw_trapezoid
  .p2align 4
  .type pango_renderer_draw_trapezoid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_draw_trapezoid
#endif
pango_renderer_draw_trapezoid:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_alpha
  .p2align 4
  .type pango_renderer_get_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_alpha
#endif
pango_renderer_get_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_color
  .p2align 4
  .type pango_renderer_get_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_color
#endif
pango_renderer_get_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_layout
  .p2align 4
  .type pango_renderer_get_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_layout
#endif
pango_renderer_get_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_layout_line
  .p2align 4
  .type pango_renderer_get_layout_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_layout_line
#endif
pango_renderer_get_layout_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_matrix
  .p2align 4
  .type pango_renderer_get_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_matrix
#endif
pango_renderer_get_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_get_type
  .p2align 4
  .type pango_renderer_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_get_type
#endif
pango_renderer_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_part_changed
  .p2align 4
  .type pango_renderer_part_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_part_changed
#endif
pango_renderer_part_changed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_set_alpha
  .p2align 4
  .type pango_renderer_set_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_set_alpha
#endif
pango_renderer_set_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_set_color
  .p2align 4
  .type pango_renderer_set_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_set_color
#endif
pango_renderer_set_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3592(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3592(%rip)
2:
  pushq $449
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_renderer_set_matrix
  .p2align 4
  .type pango_renderer_set_matrix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_renderer_set_matrix
#endif
pango_renderer_set_matrix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3600(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3600(%rip)
2:
  pushq $450
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_reorder_items
  .p2align 4
  .type pango_reorder_items, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_reorder_items
#endif
pango_reorder_items:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3608(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3608(%rip)
2:
  pushq $451
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_scan_int
  .p2align 4
  .type pango_scan_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_scan_int
#endif
pango_scan_int:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3616(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3616(%rip)
2:
  pushq $452
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_scan_string
  .p2align 4
  .type pango_scan_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_scan_string
#endif
pango_scan_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3624(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3624(%rip)
2:
  pushq $453
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_scan_word
  .p2align 4
  .type pango_scan_word, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_scan_word
#endif
pango_scan_word:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3632(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3632(%rip)
2:
  pushq $454
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_for_unichar
  .p2align 4
  .type pango_script_for_unichar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_for_unichar
#endif
pango_script_for_unichar:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3640(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3640(%rip)
2:
  pushq $455
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_get_sample_language
  .p2align 4
  .type pango_script_get_sample_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_get_sample_language
#endif
pango_script_get_sample_language:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3648(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3648(%rip)
2:
  pushq $456
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_get_type
  .p2align 4
  .type pango_script_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_get_type
#endif
pango_script_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3656(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3656(%rip)
2:
  pushq $457
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_iter_free
  .p2align 4
  .type pango_script_iter_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_iter_free
#endif
pango_script_iter_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3664(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3664(%rip)
2:
  pushq $458
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_iter_get_range
  .p2align 4
  .type pango_script_iter_get_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_iter_get_range
#endif
pango_script_iter_get_range:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3672(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3672(%rip)
2:
  pushq $459
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_iter_get_type
  .p2align 4
  .type pango_script_iter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_iter_get_type
#endif
pango_script_iter_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3680(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3680(%rip)
2:
  pushq $460
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_iter_new
  .p2align 4
  .type pango_script_iter_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_iter_new
#endif
pango_script_iter_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3688(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3688(%rip)
2:
  pushq $461
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_script_iter_next
  .p2align 4
  .type pango_script_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_script_iter_next
#endif
pango_script_iter_next:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3696(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3696(%rip)
2:
  pushq $462
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_shape
  .p2align 4
  .type pango_shape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_shape
#endif
pango_shape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3704(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3704(%rip)
2:
  pushq $463
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_shape_flags_get_type
  .p2align 4
  .type pango_shape_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_shape_flags_get_type
#endif
pango_shape_flags_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3712(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3712(%rip)
2:
  pushq $464
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_shape_full
  .p2align 4
  .type pango_shape_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_shape_full
#endif
pango_shape_full:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3720(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3720(%rip)
2:
  pushq $465
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_shape_item
  .p2align 4
  .type pango_shape_item, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_shape_item
#endif
pango_shape_item:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3728(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3728(%rip)
2:
  pushq $466
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_shape_with_flags
  .p2align 4
  .type pango_shape_with_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_shape_with_flags
#endif
pango_shape_with_flags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3736(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3736(%rip)
2:
  pushq $467
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_show_flags_get_type
  .p2align 4
  .type pango_show_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_show_flags_get_type
#endif
pango_show_flags_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3744(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3744(%rip)
2:
  pushq $468
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_skip_space
  .p2align 4
  .type pango_skip_space, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_skip_space
#endif
pango_skip_space:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3752(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3752(%rip)
2:
  pushq $469
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_split_file_list
  .p2align 4
  .type pango_split_file_list, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_split_file_list
#endif
pango_split_file_list:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3760(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3760(%rip)
2:
  pushq $470
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_stretch_get_type
  .p2align 4
  .type pango_stretch_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_stretch_get_type
#endif
pango_stretch_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3768(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3768(%rip)
2:
  pushq $471
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_style_get_type
  .p2align 4
  .type pango_style_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_style_get_type
#endif
pango_style_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3776(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3776(%rip)
2:
  pushq $472
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_align_get_type
  .p2align 4
  .type pango_tab_align_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_align_get_type
#endif
pango_tab_align_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3784(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3784(%rip)
2:
  pushq $473
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_copy
  .p2align 4
  .type pango_tab_array_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_copy
#endif
pango_tab_array_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3792(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3792(%rip)
2:
  pushq $474
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_free
  .p2align 4
  .type pango_tab_array_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_free
#endif
pango_tab_array_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3800(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3800(%rip)
2:
  pushq $475
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_from_string
  .p2align 4
  .type pango_tab_array_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_from_string
#endif
pango_tab_array_from_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3808(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3808(%rip)
2:
  pushq $476
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_decimal_point
  .p2align 4
  .type pango_tab_array_get_decimal_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_decimal_point
#endif
pango_tab_array_get_decimal_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3816(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3816(%rip)
2:
  pushq $477
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_positions_in_pixels
  .p2align 4
  .type pango_tab_array_get_positions_in_pixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_positions_in_pixels
#endif
pango_tab_array_get_positions_in_pixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3824(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3824(%rip)
2:
  pushq $478
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_size
  .p2align 4
  .type pango_tab_array_get_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_size
#endif
pango_tab_array_get_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3832(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3832(%rip)
2:
  pushq $479
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_tab
  .p2align 4
  .type pango_tab_array_get_tab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_tab
#endif
pango_tab_array_get_tab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3840(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3840(%rip)
2:
  pushq $480
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_tabs
  .p2align 4
  .type pango_tab_array_get_tabs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_tabs
#endif
pango_tab_array_get_tabs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3848(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3848(%rip)
2:
  pushq $481
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_get_type
  .p2align 4
  .type pango_tab_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_get_type
#endif
pango_tab_array_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3856(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3856(%rip)
2:
  pushq $482
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_new
  .p2align 4
  .type pango_tab_array_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_new
#endif
pango_tab_array_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3864(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3864(%rip)
2:
  pushq $483
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_new_with_positions
  .p2align 4
  .type pango_tab_array_new_with_positions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_new_with_positions
#endif
pango_tab_array_new_with_positions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3872(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3872(%rip)
2:
  pushq $484
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_resize
  .p2align 4
  .type pango_tab_array_resize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_resize
#endif
pango_tab_array_resize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3880(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3880(%rip)
2:
  pushq $485
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_set_decimal_point
  .p2align 4
  .type pango_tab_array_set_decimal_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_set_decimal_point
#endif
pango_tab_array_set_decimal_point:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3888(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3888(%rip)
2:
  pushq $486
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_set_positions_in_pixels
  .p2align 4
  .type pango_tab_array_set_positions_in_pixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_set_positions_in_pixels
#endif
pango_tab_array_set_positions_in_pixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3896(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3896(%rip)
2:
  pushq $487
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_set_tab
  .p2align 4
  .type pango_tab_array_set_tab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_set_tab
#endif
pango_tab_array_set_tab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3904(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3904(%rip)
2:
  pushq $488
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_sort
  .p2align 4
  .type pango_tab_array_sort, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_sort
#endif
pango_tab_array_sort:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3912(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3912(%rip)
2:
  pushq $489
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tab_array_to_string
  .p2align 4
  .type pango_tab_array_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tab_array_to_string
#endif
pango_tab_array_to_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3920(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3920(%rip)
2:
  pushq $490
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_tailor_break
  .p2align 4
  .type pango_tailor_break, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_tailor_break
#endif
pango_tailor_break:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3928(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3928(%rip)
2:
  pushq $491
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_text_transform_get_type
  .p2align 4
  .type pango_text_transform_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_text_transform_get_type
#endif
pango_text_transform_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3936(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3936(%rip)
2:
  pushq $492
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_trim_string
  .p2align 4
  .type pango_trim_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_trim_string
#endif
pango_trim_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3944(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3944(%rip)
2:
  pushq $493
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_underline_get_type
  .p2align 4
  .type pango_underline_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_underline_get_type
#endif
pango_underline_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3952(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3952(%rip)
2:
  pushq $494
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_unichar_direction
  .p2align 4
  .type pango_unichar_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_unichar_direction
#endif
pango_unichar_direction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3960(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3960(%rip)
2:
  pushq $495
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_units_from_double
  .p2align 4
  .type pango_units_from_double, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_units_from_double
#endif
pango_units_from_double:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3968(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3968(%rip)
2:
  pushq $496
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_units_to_double
  .p2align 4
  .type pango_units_to_double, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_units_to_double
#endif
pango_units_to_double:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3976(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3976(%rip)
2:
  pushq $497
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_variant_get_type
  .p2align 4
  .type pango_variant_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_variant_get_type
#endif
pango_variant_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3984(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3984(%rip)
2:
  pushq $498
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_version
  .p2align 4
  .type pango_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_version
#endif
pango_version:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+3992(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+3992(%rip)
2:
  pushq $499
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_version_check
  .p2align 4
  .type pango_version_check, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_version_check
#endif
pango_version_check:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+4000(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+4000(%rip)
2:
  pushq $500
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_version_string
  .p2align 4
  .type pango_version_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_version_string
#endif
pango_version_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+4008(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+4008(%rip)
2:
  pushq $501
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_weight_get_type
  .p2align 4
  .type pango_weight_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_weight_get_type
#endif
pango_weight_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+4016(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+4016(%rip)
2:
  pushq $502
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_wrap_mode_get_type
  .p2align 4
  .type pango_wrap_mode_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_wrap_mode_get_type
#endif
pango_wrap_mode_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpango_1_0_so_tramp_table+4024(%rip)
  je 2f
1:
  jmp *_libpango_1_0_so_tramp_table+4024(%rip)
2:
  pushq $503
  .cfi_adjust_cfa_offset 8
  call _libpango_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

