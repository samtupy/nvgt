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

  .globl _libpangocairo_1_0_so_tramp_table
  .hidden _libpangocairo_1_0_so_tramp_table
  .align 8
_libpangocairo_1_0_so_tramp_table:
  .zero 272

  .text

  .globl _libpangocairo_1_0_so_tramp_resolve
  .hidden _libpangocairo_1_0_so_tramp_resolve

  .globl _libpangocairo_1_0_so_save_regs_and_resolve
  .hidden _libpangocairo_1_0_so_save_regs_and_resolve
  .type _libpangocairo_1_0_so_save_regs_and_resolve, %function
_libpangocairo_1_0_so_save_regs_and_resolve:
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
  call _libpangocairo_1_0_so_tramp_resolve

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

  .globl pango_cairo_context_get_font_options
  .p2align 4
  .type pango_cairo_context_get_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_get_font_options
#endif
pango_cairo_context_get_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_context_get_resolution
  .p2align 4
  .type pango_cairo_context_get_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_get_resolution
#endif
pango_cairo_context_get_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_context_get_shape_renderer
  .p2align 4
  .type pango_cairo_context_get_shape_renderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_get_shape_renderer
#endif
pango_cairo_context_get_shape_renderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_context_set_font_options
  .p2align 4
  .type pango_cairo_context_set_font_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_set_font_options
#endif
pango_cairo_context_set_font_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_context_set_resolution
  .p2align 4
  .type pango_cairo_context_set_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_set_resolution
#endif
pango_cairo_context_set_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_context_set_shape_renderer
  .p2align 4
  .type pango_cairo_context_set_shape_renderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_context_set_shape_renderer
#endif
pango_cairo_context_set_shape_renderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_create_context
  .p2align 4
  .type pango_cairo_create_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_create_context
#endif
pango_cairo_create_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_create_layout
  .p2align 4
  .type pango_cairo_create_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_create_layout
#endif
pango_cairo_create_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_error_underline_path
  .p2align 4
  .type pango_cairo_error_underline_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_error_underline_path
#endif
pango_cairo_error_underline_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_fc_font_get_type
  .p2align 4
  .type pango_cairo_fc_font_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_fc_font_get_type
#endif
pango_cairo_fc_font_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_fc_font_map_get_type
  .p2align 4
  .type pango_cairo_fc_font_map_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_fc_font_map_get_type
#endif
pango_cairo_fc_font_map_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_get_scaled_font
  .p2align 4
  .type pango_cairo_font_get_scaled_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_get_scaled_font
#endif
pango_cairo_font_get_scaled_font:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_get_type
  .p2align 4
  .type pango_cairo_font_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_get_type
#endif
pango_cairo_font_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_create_context
  .p2align 4
  .type pango_cairo_font_map_create_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_create_context
#endif
pango_cairo_font_map_create_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_get_default
  .p2align 4
  .type pango_cairo_font_map_get_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_get_default
#endif
pango_cairo_font_map_get_default:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_get_font_type
  .p2align 4
  .type pango_cairo_font_map_get_font_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_get_font_type
#endif
pango_cairo_font_map_get_font_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_get_resolution
  .p2align 4
  .type pango_cairo_font_map_get_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_get_resolution
#endif
pango_cairo_font_map_get_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_get_type
  .p2align 4
  .type pango_cairo_font_map_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_get_type
#endif
pango_cairo_font_map_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_new
  .p2align 4
  .type pango_cairo_font_map_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_new
#endif
pango_cairo_font_map_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_new_for_font_type
  .p2align 4
  .type pango_cairo_font_map_new_for_font_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_new_for_font_type
#endif
pango_cairo_font_map_new_for_font_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_set_default
  .p2align 4
  .type pango_cairo_font_map_set_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_set_default
#endif
pango_cairo_font_map_set_default:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_font_map_set_resolution
  .p2align 4
  .type pango_cairo_font_map_set_resolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_font_map_set_resolution
#endif
pango_cairo_font_map_set_resolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_glyph_string_path
  .p2align 4
  .type pango_cairo_glyph_string_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_glyph_string_path
#endif
pango_cairo_glyph_string_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_layout_line_path
  .p2align 4
  .type pango_cairo_layout_line_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_layout_line_path
#endif
pango_cairo_layout_line_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_layout_path
  .p2align 4
  .type pango_cairo_layout_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_layout_path
#endif
pango_cairo_layout_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_renderer_get_type
  .p2align 4
  .type pango_cairo_renderer_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_renderer_get_type
#endif
pango_cairo_renderer_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_show_error_underline
  .p2align 4
  .type pango_cairo_show_error_underline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_show_error_underline
#endif
pango_cairo_show_error_underline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_show_glyph_item
  .p2align 4
  .type pango_cairo_show_glyph_item, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_show_glyph_item
#endif
pango_cairo_show_glyph_item:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_show_glyph_string
  .p2align 4
  .type pango_cairo_show_glyph_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_show_glyph_string
#endif
pango_cairo_show_glyph_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_show_layout
  .p2align 4
  .type pango_cairo_show_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_show_layout
#endif
pango_cairo_show_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_show_layout_line
  .p2align 4
  .type pango_cairo_show_layout_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_show_layout_line
#endif
pango_cairo_show_layout_line:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_update_context
  .p2align 4
  .type pango_cairo_update_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_update_context
#endif
pango_cairo_update_context:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl pango_cairo_update_layout
  .p2align 4
  .type pango_cairo_update_layout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden pango_cairo_update_layout
#endif
pango_cairo_update_layout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libpangocairo_1_0_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libpangocairo_1_0_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libpangocairo_1_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

