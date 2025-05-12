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

  .globl _libgdk_pixbuf_2_0_so_tramp_table
  .hidden _libgdk_pixbuf_2_0_so_tramp_table
  .align 8
_libgdk_pixbuf_2_0_so_tramp_table:
  .zero 1024

  .text

  .globl _libgdk_pixbuf_2_0_so_tramp_resolve
  .hidden _libgdk_pixbuf_2_0_so_tramp_resolve

  .globl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  .hidden _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  .type _libgdk_pixbuf_2_0_so_save_regs_and_resolve, %function
_libgdk_pixbuf_2_0_so_save_regs_and_resolve:
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
  call _libgdk_pixbuf_2_0_so_tramp_resolve

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

  .globl gdk_colorspace_get_type
  .p2align 4
  .type gdk_colorspace_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_colorspace_get_type
#endif
gdk_colorspace_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_interp_type_get_type
  .p2align 4
  .type gdk_interp_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_interp_type_get_type
#endif
gdk_interp_type_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_add_alpha
  .p2align 4
  .type gdk_pixbuf_add_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_add_alpha
#endif
gdk_pixbuf_add_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_alpha_mode_get_type
  .p2align 4
  .type gdk_pixbuf_alpha_mode_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_alpha_mode_get_type
#endif
gdk_pixbuf_alpha_mode_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_get_height
  .p2align 4
  .type gdk_pixbuf_animation_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_get_height
#endif
gdk_pixbuf_animation_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_get_iter
  .p2align 4
  .type gdk_pixbuf_animation_get_iter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_get_iter
#endif
gdk_pixbuf_animation_get_iter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_get_static_image
  .p2align 4
  .type gdk_pixbuf_animation_get_static_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_get_static_image
#endif
gdk_pixbuf_animation_get_static_image:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_get_type
  .p2align 4
  .type gdk_pixbuf_animation_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_get_type
#endif
gdk_pixbuf_animation_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_get_width
  .p2align 4
  .type gdk_pixbuf_animation_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_get_width
#endif
gdk_pixbuf_animation_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_is_static_image
  .p2align 4
  .type gdk_pixbuf_animation_is_static_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_is_static_image
#endif
gdk_pixbuf_animation_is_static_image:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_iter_advance
  .p2align 4
  .type gdk_pixbuf_animation_iter_advance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_iter_advance
#endif
gdk_pixbuf_animation_iter_advance:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_iter_get_delay_time
  .p2align 4
  .type gdk_pixbuf_animation_iter_get_delay_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_iter_get_delay_time
#endif
gdk_pixbuf_animation_iter_get_delay_time:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_iter_get_pixbuf
  .p2align 4
  .type gdk_pixbuf_animation_iter_get_pixbuf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_iter_get_pixbuf
#endif
gdk_pixbuf_animation_iter_get_pixbuf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_iter_get_type
  .p2align 4
  .type gdk_pixbuf_animation_iter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_iter_get_type
#endif
gdk_pixbuf_animation_iter_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_iter_on_currently_loading_frame
  .p2align 4
  .type gdk_pixbuf_animation_iter_on_currently_loading_frame, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_iter_on_currently_loading_frame
#endif
gdk_pixbuf_animation_iter_on_currently_loading_frame:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_new_from_file
  .p2align 4
  .type gdk_pixbuf_animation_new_from_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_new_from_file
#endif
gdk_pixbuf_animation_new_from_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_new_from_resource
  .p2align 4
  .type gdk_pixbuf_animation_new_from_resource, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_new_from_resource
#endif
gdk_pixbuf_animation_new_from_resource:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_new_from_stream
  .p2align 4
  .type gdk_pixbuf_animation_new_from_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_new_from_stream
#endif
gdk_pixbuf_animation_new_from_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_new_from_stream_async
  .p2align 4
  .type gdk_pixbuf_animation_new_from_stream_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_new_from_stream_async
#endif
gdk_pixbuf_animation_new_from_stream_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_new_from_stream_finish
  .p2align 4
  .type gdk_pixbuf_animation_new_from_stream_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_new_from_stream_finish
#endif
gdk_pixbuf_animation_new_from_stream_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_ref
  .p2align 4
  .type gdk_pixbuf_animation_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_ref
#endif
gdk_pixbuf_animation_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_animation_unref
  .p2align 4
  .type gdk_pixbuf_animation_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_animation_unref
#endif
gdk_pixbuf_animation_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_apply_embedded_orientation
  .p2align 4
  .type gdk_pixbuf_apply_embedded_orientation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_apply_embedded_orientation
#endif
gdk_pixbuf_apply_embedded_orientation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_calculate_rowstride
  .p2align 4
  .type gdk_pixbuf_calculate_rowstride, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_calculate_rowstride
#endif
gdk_pixbuf_calculate_rowstride:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_composite
  .p2align 4
  .type gdk_pixbuf_composite, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_composite
#endif
gdk_pixbuf_composite:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_composite_color
  .p2align 4
  .type gdk_pixbuf_composite_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_composite_color
#endif
gdk_pixbuf_composite_color:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_composite_color_simple
  .p2align 4
  .type gdk_pixbuf_composite_color_simple, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_composite_color_simple
#endif
gdk_pixbuf_composite_color_simple:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_copy
  .p2align 4
  .type gdk_pixbuf_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_copy
#endif
gdk_pixbuf_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_copy_area
  .p2align 4
  .type gdk_pixbuf_copy_area, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_copy_area
#endif
gdk_pixbuf_copy_area:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_copy_options
  .p2align 4
  .type gdk_pixbuf_copy_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_copy_options
#endif
gdk_pixbuf_copy_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_error_get_type
  .p2align 4
  .type gdk_pixbuf_error_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_error_get_type
#endif
gdk_pixbuf_error_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_error_quark
  .p2align 4
  .type gdk_pixbuf_error_quark, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_error_quark
#endif
gdk_pixbuf_error_quark:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_fill
  .p2align 4
  .type gdk_pixbuf_fill, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_fill
#endif
gdk_pixbuf_fill:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_flip
  .p2align 4
  .type gdk_pixbuf_flip, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_flip
#endif
gdk_pixbuf_flip:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_copy
  .p2align 4
  .type gdk_pixbuf_format_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_copy
#endif
gdk_pixbuf_format_copy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_free
  .p2align 4
  .type gdk_pixbuf_format_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_free
#endif
gdk_pixbuf_format_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_description
  .p2align 4
  .type gdk_pixbuf_format_get_description, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_description
#endif
gdk_pixbuf_format_get_description:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_extensions
  .p2align 4
  .type gdk_pixbuf_format_get_extensions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_extensions
#endif
gdk_pixbuf_format_get_extensions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_license
  .p2align 4
  .type gdk_pixbuf_format_get_license, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_license
#endif
gdk_pixbuf_format_get_license:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_mime_types
  .p2align 4
  .type gdk_pixbuf_format_get_mime_types, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_mime_types
#endif
gdk_pixbuf_format_get_mime_types:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_name
  .p2align 4
  .type gdk_pixbuf_format_get_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_name
#endif
gdk_pixbuf_format_get_name:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_get_type
  .p2align 4
  .type gdk_pixbuf_format_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_get_type
#endif
gdk_pixbuf_format_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_is_disabled
  .p2align 4
  .type gdk_pixbuf_format_is_disabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_is_disabled
#endif
gdk_pixbuf_format_is_disabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_is_save_option_supported
  .p2align 4
  .type gdk_pixbuf_format_is_save_option_supported, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_is_save_option_supported
#endif
gdk_pixbuf_format_is_save_option_supported:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_is_scalable
  .p2align 4
  .type gdk_pixbuf_format_is_scalable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_is_scalable
#endif
gdk_pixbuf_format_is_scalable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_is_writable
  .p2align 4
  .type gdk_pixbuf_format_is_writable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_is_writable
#endif
gdk_pixbuf_format_is_writable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_format_set_disabled
  .p2align 4
  .type gdk_pixbuf_format_set_disabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_format_set_disabled
#endif
gdk_pixbuf_format_set_disabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_from_pixdata
  .p2align 4
  .type gdk_pixbuf_from_pixdata, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_from_pixdata
#endif
gdk_pixbuf_from_pixdata:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_bits_per_sample
  .p2align 4
  .type gdk_pixbuf_get_bits_per_sample, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_bits_per_sample
#endif
gdk_pixbuf_get_bits_per_sample:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_byte_length
  .p2align 4
  .type gdk_pixbuf_get_byte_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_byte_length
#endif
gdk_pixbuf_get_byte_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_colorspace
  .p2align 4
  .type gdk_pixbuf_get_colorspace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_colorspace
#endif
gdk_pixbuf_get_colorspace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_file_info
  .p2align 4
  .type gdk_pixbuf_get_file_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_file_info
#endif
gdk_pixbuf_get_file_info:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_file_info_async
  .p2align 4
  .type gdk_pixbuf_get_file_info_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_file_info_async
#endif
gdk_pixbuf_get_file_info_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_file_info_finish
  .p2align 4
  .type gdk_pixbuf_get_file_info_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_file_info_finish
#endif
gdk_pixbuf_get_file_info_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_formats
  .p2align 4
  .type gdk_pixbuf_get_formats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_formats
#endif
gdk_pixbuf_get_formats:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_has_alpha
  .p2align 4
  .type gdk_pixbuf_get_has_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_has_alpha
#endif
gdk_pixbuf_get_has_alpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_height
  .p2align 4
  .type gdk_pixbuf_get_height, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_height
#endif
gdk_pixbuf_get_height:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_n_channels
  .p2align 4
  .type gdk_pixbuf_get_n_channels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_n_channels
#endif
gdk_pixbuf_get_n_channels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_option
  .p2align 4
  .type gdk_pixbuf_get_option, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_option
#endif
gdk_pixbuf_get_option:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_options
  .p2align 4
  .type gdk_pixbuf_get_options, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_options
#endif
gdk_pixbuf_get_options:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_pixels
  .p2align 4
  .type gdk_pixbuf_get_pixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_pixels
#endif
gdk_pixbuf_get_pixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_pixels_with_length
  .p2align 4
  .type gdk_pixbuf_get_pixels_with_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_pixels_with_length
#endif
gdk_pixbuf_get_pixels_with_length:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_rowstride
  .p2align 4
  .type gdk_pixbuf_get_rowstride, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_rowstride
#endif
gdk_pixbuf_get_rowstride:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_type
  .p2align 4
  .type gdk_pixbuf_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_type
#endif
gdk_pixbuf_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_get_width
  .p2align 4
  .type gdk_pixbuf_get_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_get_width
#endif
gdk_pixbuf_get_width:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_init_modules
  .p2align 4
  .type gdk_pixbuf_init_modules, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_init_modules
#endif
gdk_pixbuf_init_modules:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_close
  .p2align 4
  .type gdk_pixbuf_loader_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_close
#endif
gdk_pixbuf_loader_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_get_animation
  .p2align 4
  .type gdk_pixbuf_loader_get_animation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_get_animation
#endif
gdk_pixbuf_loader_get_animation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_get_format
  .p2align 4
  .type gdk_pixbuf_loader_get_format, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_get_format
#endif
gdk_pixbuf_loader_get_format:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_get_pixbuf
  .p2align 4
  .type gdk_pixbuf_loader_get_pixbuf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_get_pixbuf
#endif
gdk_pixbuf_loader_get_pixbuf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_get_type
  .p2align 4
  .type gdk_pixbuf_loader_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_get_type
#endif
gdk_pixbuf_loader_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_new
  .p2align 4
  .type gdk_pixbuf_loader_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_new
#endif
gdk_pixbuf_loader_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_new_with_mime_type
  .p2align 4
  .type gdk_pixbuf_loader_new_with_mime_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_new_with_mime_type
#endif
gdk_pixbuf_loader_new_with_mime_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_new_with_type
  .p2align 4
  .type gdk_pixbuf_loader_new_with_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_new_with_type
#endif
gdk_pixbuf_loader_new_with_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_set_size
  .p2align 4
  .type gdk_pixbuf_loader_set_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_set_size
#endif
gdk_pixbuf_loader_set_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_write
  .p2align 4
  .type gdk_pixbuf_loader_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_write
#endif
gdk_pixbuf_loader_write:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_loader_write_bytes
  .p2align 4
  .type gdk_pixbuf_loader_write_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_loader_write_bytes
#endif
gdk_pixbuf_loader_write_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new
  .p2align 4
  .type gdk_pixbuf_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new
#endif
gdk_pixbuf_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_bytes
  .p2align 4
  .type gdk_pixbuf_new_from_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_bytes
#endif
gdk_pixbuf_new_from_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_data
  .p2align 4
  .type gdk_pixbuf_new_from_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_data
#endif
gdk_pixbuf_new_from_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_file
  .p2align 4
  .type gdk_pixbuf_new_from_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_file
#endif
gdk_pixbuf_new_from_file:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_file_at_scale
  .p2align 4
  .type gdk_pixbuf_new_from_file_at_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_file_at_scale
#endif
gdk_pixbuf_new_from_file_at_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_file_at_size
  .p2align 4
  .type gdk_pixbuf_new_from_file_at_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_file_at_size
#endif
gdk_pixbuf_new_from_file_at_size:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_inline
  .p2align 4
  .type gdk_pixbuf_new_from_inline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_inline
#endif
gdk_pixbuf_new_from_inline:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_resource
  .p2align 4
  .type gdk_pixbuf_new_from_resource, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_resource
#endif
gdk_pixbuf_new_from_resource:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_resource_at_scale
  .p2align 4
  .type gdk_pixbuf_new_from_resource_at_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_resource_at_scale
#endif
gdk_pixbuf_new_from_resource_at_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_stream
  .p2align 4
  .type gdk_pixbuf_new_from_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_stream
#endif
gdk_pixbuf_new_from_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_stream_async
  .p2align 4
  .type gdk_pixbuf_new_from_stream_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_stream_async
#endif
gdk_pixbuf_new_from_stream_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_stream_at_scale
  .p2align 4
  .type gdk_pixbuf_new_from_stream_at_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_stream_at_scale
#endif
gdk_pixbuf_new_from_stream_at_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_stream_at_scale_async
  .p2align 4
  .type gdk_pixbuf_new_from_stream_at_scale_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_stream_at_scale_async
#endif
gdk_pixbuf_new_from_stream_at_scale_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_stream_finish
  .p2align 4
  .type gdk_pixbuf_new_from_stream_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_stream_finish
#endif
gdk_pixbuf_new_from_stream_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_from_xpm_data
  .p2align 4
  .type gdk_pixbuf_new_from_xpm_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_from_xpm_data
#endif
gdk_pixbuf_new_from_xpm_data:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_new_subpixbuf
  .p2align 4
  .type gdk_pixbuf_new_subpixbuf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_new_subpixbuf
#endif
gdk_pixbuf_new_subpixbuf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_non_anim_get_type
  .p2align 4
  .type gdk_pixbuf_non_anim_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_non_anim_get_type
#endif
gdk_pixbuf_non_anim_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_non_anim_new
  .p2align 4
  .type gdk_pixbuf_non_anim_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_non_anim_new
#endif
gdk_pixbuf_non_anim_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_read_pixel_bytes
  .p2align 4
  .type gdk_pixbuf_read_pixel_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_read_pixel_bytes
#endif
gdk_pixbuf_read_pixel_bytes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_read_pixels
  .p2align 4
  .type gdk_pixbuf_read_pixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_read_pixels
#endif
gdk_pixbuf_read_pixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_ref
  .p2align 4
  .type gdk_pixbuf_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_ref
#endif
gdk_pixbuf_ref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_remove_option
  .p2align 4
  .type gdk_pixbuf_remove_option, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_remove_option
#endif
gdk_pixbuf_remove_option:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_rotate_simple
  .p2align 4
  .type gdk_pixbuf_rotate_simple, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_rotate_simple
#endif
gdk_pixbuf_rotate_simple:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_rotation_get_type
  .p2align 4
  .type gdk_pixbuf_rotation_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_rotation_get_type
#endif
gdk_pixbuf_rotation_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_saturate_and_pixelate
  .p2align 4
  .type gdk_pixbuf_saturate_and_pixelate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_saturate_and_pixelate
#endif
gdk_pixbuf_saturate_and_pixelate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save
  .p2align 4
  .type gdk_pixbuf_save, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save
#endif
gdk_pixbuf_save:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_buffer
  .p2align 4
  .type gdk_pixbuf_save_to_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_buffer
#endif
gdk_pixbuf_save_to_buffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_bufferv
  .p2align 4
  .type gdk_pixbuf_save_to_bufferv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_bufferv
#endif
gdk_pixbuf_save_to_bufferv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_callback
  .p2align 4
  .type gdk_pixbuf_save_to_callback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_callback
#endif
gdk_pixbuf_save_to_callback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_callbackv
  .p2align 4
  .type gdk_pixbuf_save_to_callbackv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_callbackv
#endif
gdk_pixbuf_save_to_callbackv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_stream
  .p2align 4
  .type gdk_pixbuf_save_to_stream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_stream
#endif
gdk_pixbuf_save_to_stream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_stream_async
  .p2align 4
  .type gdk_pixbuf_save_to_stream_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_stream_async
#endif
gdk_pixbuf_save_to_stream_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_stream_finish
  .p2align 4
  .type gdk_pixbuf_save_to_stream_finish, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_stream_finish
#endif
gdk_pixbuf_save_to_stream_finish:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_streamv
  .p2align 4
  .type gdk_pixbuf_save_to_streamv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_streamv
#endif
gdk_pixbuf_save_to_streamv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_save_to_streamv_async
  .p2align 4
  .type gdk_pixbuf_save_to_streamv_async, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_save_to_streamv_async
#endif
gdk_pixbuf_save_to_streamv_async:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_savev
  .p2align 4
  .type gdk_pixbuf_savev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_savev
#endif
gdk_pixbuf_savev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_scale
  .p2align 4
  .type gdk_pixbuf_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_scale
#endif
gdk_pixbuf_scale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_scale_simple
  .p2align 4
  .type gdk_pixbuf_scale_simple, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_scale_simple
#endif
gdk_pixbuf_scale_simple:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_set_option
  .p2align 4
  .type gdk_pixbuf_set_option, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_set_option
#endif
gdk_pixbuf_set_option:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_add_frame
  .p2align 4
  .type gdk_pixbuf_simple_anim_add_frame, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_add_frame
#endif
gdk_pixbuf_simple_anim_add_frame:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_get_loop
  .p2align 4
  .type gdk_pixbuf_simple_anim_get_loop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_get_loop
#endif
gdk_pixbuf_simple_anim_get_loop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_get_type
  .p2align 4
  .type gdk_pixbuf_simple_anim_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_get_type
#endif
gdk_pixbuf_simple_anim_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_iter_get_type
  .p2align 4
  .type gdk_pixbuf_simple_anim_iter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_iter_get_type
#endif
gdk_pixbuf_simple_anim_iter_get_type:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_new
  .p2align 4
  .type gdk_pixbuf_simple_anim_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_new
#endif
gdk_pixbuf_simple_anim_new:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_simple_anim_set_loop
  .p2align 4
  .type gdk_pixbuf_simple_anim_set_loop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_simple_anim_set_loop
#endif
gdk_pixbuf_simple_anim_set_loop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixbuf_unref
  .p2align 4
  .type gdk_pixbuf_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixbuf_unref
#endif
gdk_pixbuf_unref:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixdata_deserialize
  .p2align 4
  .type gdk_pixdata_deserialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixdata_deserialize
#endif
gdk_pixdata_deserialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixdata_from_pixbuf
  .p2align 4
  .type gdk_pixdata_from_pixbuf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixdata_from_pixbuf
#endif
gdk_pixdata_from_pixbuf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixdata_serialize
  .p2align 4
  .type gdk_pixdata_serialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixdata_serialize
#endif
gdk_pixdata_serialize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl gdk_pixdata_to_csource
  .p2align 4
  .type gdk_pixdata_to_csource, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_pixdata_to_csource
#endif
gdk_pixdata_to_csource:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libgdk_pixbuf_2_0_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libgdk_pixbuf_2_0_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

