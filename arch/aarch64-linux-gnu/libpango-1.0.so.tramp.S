/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

#define lr x30
#define ip0 x16

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

  // Slow path which calls dlsym, taken only on first call.
  // Registers are saved according to "Procedure Call Standard for the Arm® 64-bit Architecture".
  // For DWARF directives, read https://www.imperialviolet.org/2017/01/18/cfi.html.

  // Stack is aligned at 16 bytes

#define PUSH_PAIR(reg1, reg2) stp reg1, reg2, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset reg1, 0; .cfi_rel_offset reg2, 8
#define POP_PAIR(reg1, reg2) ldp reg1, reg2, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore reg2; .cfi_restore reg1

#define PUSH_WIDE_PAIR(reg1, reg2) stp reg1, reg2, [sp, #-32]!; .cfi_adjust_cfa_offset 32; .cfi_rel_offset reg1, 0; .cfi_rel_offset reg2, 16
#define POP_WIDE_PAIR(reg1, reg2) ldp reg1, reg2, [sp], #32; .cfi_adjust_cfa_offset -32; .cfi_restore reg2; .cfi_restore reg1

  // Save only arguments (and lr)
  PUSH_PAIR(x0, x1)
  PUSH_PAIR(x2, x3)
  PUSH_PAIR(x4, x5)
  PUSH_PAIR(x6, x7)
  PUSH_PAIR(x8, lr)

  ldr x0, [sp, #80]  // 16*5

  PUSH_WIDE_PAIR(q0, q1)
  PUSH_WIDE_PAIR(q2, q3)
  PUSH_WIDE_PAIR(q4, q5)
  PUSH_WIDE_PAIR(q6, q7)

  // Stack is aligned at 16 bytes

  bl _libpango_1_0_so_tramp_resolve
  mov ip0, x0

  // TODO: pop pc?

  POP_WIDE_PAIR(q6, q7)
  POP_WIDE_PAIR(q4, q5)
  POP_WIDE_PAIR(q2, q3)
  POP_WIDE_PAIR(q0, q1)

  POP_PAIR(x8, lr)
  POP_PAIR(x6, x7)
  POP_PAIR(x4, x5)
  POP_PAIR(x2, x3)
  POP_PAIR(x0, x1)

  br lr

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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+0]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 0 & 0xffff
#if 0 > 0xffff
  movk ip0, 0 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+8]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 1 & 0xffff
#if 1 > 0xffff
  movk ip0, 1 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+16]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 2 & 0xffff
#if 2 > 0xffff
  movk ip0, 2 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+24]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 3 & 0xffff
#if 3 > 0xffff
  movk ip0, 3 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+32]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 4 & 0xffff
#if 4 > 0xffff
  movk ip0, 4 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+40]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 5 & 0xffff
#if 5 > 0xffff
  movk ip0, 5 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+48]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 6 & 0xffff
#if 6 > 0xffff
  movk ip0, 6 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+56]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 7 & 0xffff
#if 7 > 0xffff
  movk ip0, 7 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+64]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 8 & 0xffff
#if 8 > 0xffff
  movk ip0, 8 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+72]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 9 & 0xffff
#if 9 > 0xffff
  movk ip0, 9 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+80]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 10 & 0xffff
#if 10 > 0xffff
  movk ip0, 10 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+88]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 11 & 0xffff
#if 11 > 0xffff
  movk ip0, 11 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+96]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 12 & 0xffff
#if 12 > 0xffff
  movk ip0, 12 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+104]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 13 & 0xffff
#if 13 > 0xffff
  movk ip0, 13 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+112]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 14 & 0xffff
#if 14 > 0xffff
  movk ip0, 14 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+120]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 15 & 0xffff
#if 15 > 0xffff
  movk ip0, 15 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+128]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 16 & 0xffff
#if 16 > 0xffff
  movk ip0, 16 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+136]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 17 & 0xffff
#if 17 > 0xffff
  movk ip0, 17 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+144]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 18 & 0xffff
#if 18 > 0xffff
  movk ip0, 18 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+152]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 19 & 0xffff
#if 19 > 0xffff
  movk ip0, 19 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+160]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 20 & 0xffff
#if 20 > 0xffff
  movk ip0, 20 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+168]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 21 & 0xffff
#if 21 > 0xffff
  movk ip0, 21 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+176]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 22 & 0xffff
#if 22 > 0xffff
  movk ip0, 22 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+184]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 23 & 0xffff
#if 23 > 0xffff
  movk ip0, 23 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+192]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 24 & 0xffff
#if 24 > 0xffff
  movk ip0, 24 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+200]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 25 & 0xffff
#if 25 > 0xffff
  movk ip0, 25 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+208]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 26 & 0xffff
#if 26 > 0xffff
  movk ip0, 26 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+216]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 27 & 0xffff
#if 27 > 0xffff
  movk ip0, 27 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+224]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 28 & 0xffff
#if 28 > 0xffff
  movk ip0, 28 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+232]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 29 & 0xffff
#if 29 > 0xffff
  movk ip0, 29 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+240]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 30 & 0xffff
#if 30 > 0xffff
  movk ip0, 30 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+248]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 31 & 0xffff
#if 31 > 0xffff
  movk ip0, 31 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+256]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 32 & 0xffff
#if 32 > 0xffff
  movk ip0, 32 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+264]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 33 & 0xffff
#if 33 > 0xffff
  movk ip0, 33 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+272]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 34 & 0xffff
#if 34 > 0xffff
  movk ip0, 34 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+280]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 35 & 0xffff
#if 35 > 0xffff
  movk ip0, 35 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+288]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 36 & 0xffff
#if 36 > 0xffff
  movk ip0, 36 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+296]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 37 & 0xffff
#if 37 > 0xffff
  movk ip0, 37 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+304]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 38 & 0xffff
#if 38 > 0xffff
  movk ip0, 38 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+312]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 39 & 0xffff
#if 39 > 0xffff
  movk ip0, 39 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+320]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 40 & 0xffff
#if 40 > 0xffff
  movk ip0, 40 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+328]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 41 & 0xffff
#if 41 > 0xffff
  movk ip0, 41 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+336]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 42 & 0xffff
#if 42 > 0xffff
  movk ip0, 42 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+344]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 43 & 0xffff
#if 43 > 0xffff
  movk ip0, 43 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+352]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 44 & 0xffff
#if 44 > 0xffff
  movk ip0, 44 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+360]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 45 & 0xffff
#if 45 > 0xffff
  movk ip0, 45 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+368]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 46 & 0xffff
#if 46 > 0xffff
  movk ip0, 46 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+376]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 47 & 0xffff
#if 47 > 0xffff
  movk ip0, 47 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+384]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 48 & 0xffff
#if 48 > 0xffff
  movk ip0, 48 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+392]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 49 & 0xffff
#if 49 > 0xffff
  movk ip0, 49 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+400]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 50 & 0xffff
#if 50 > 0xffff
  movk ip0, 50 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+408]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 51 & 0xffff
#if 51 > 0xffff
  movk ip0, 51 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+416]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 52 & 0xffff
#if 52 > 0xffff
  movk ip0, 52 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+424]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 53 & 0xffff
#if 53 > 0xffff
  movk ip0, 53 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+432]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 54 & 0xffff
#if 54 > 0xffff
  movk ip0, 54 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+440]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 55 & 0xffff
#if 55 > 0xffff
  movk ip0, 55 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+448]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 56 & 0xffff
#if 56 > 0xffff
  movk ip0, 56 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+456]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 57 & 0xffff
#if 57 > 0xffff
  movk ip0, 57 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+464]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 58 & 0xffff
#if 58 > 0xffff
  movk ip0, 58 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+472]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 59 & 0xffff
#if 59 > 0xffff
  movk ip0, 59 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+480]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 60 & 0xffff
#if 60 > 0xffff
  movk ip0, 60 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+488]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 61 & 0xffff
#if 61 > 0xffff
  movk ip0, 61 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+496]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 62 & 0xffff
#if 62 > 0xffff
  movk ip0, 62 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+504]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 63 & 0xffff
#if 63 > 0xffff
  movk ip0, 63 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+512]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 64 & 0xffff
#if 64 > 0xffff
  movk ip0, 64 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+520]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 65 & 0xffff
#if 65 > 0xffff
  movk ip0, 65 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+528]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 66 & 0xffff
#if 66 > 0xffff
  movk ip0, 66 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+536]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 67 & 0xffff
#if 67 > 0xffff
  movk ip0, 67 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+544]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 68 & 0xffff
#if 68 > 0xffff
  movk ip0, 68 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+552]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 69 & 0xffff
#if 69 > 0xffff
  movk ip0, 69 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+560]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 70 & 0xffff
#if 70 > 0xffff
  movk ip0, 70 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+568]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 71 & 0xffff
#if 71 > 0xffff
  movk ip0, 71 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+576]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 72 & 0xffff
#if 72 > 0xffff
  movk ip0, 72 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+584]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 73 & 0xffff
#if 73 > 0xffff
  movk ip0, 73 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+592]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 74 & 0xffff
#if 74 > 0xffff
  movk ip0, 74 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+600]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 75 & 0xffff
#if 75 > 0xffff
  movk ip0, 75 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+608]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 76 & 0xffff
#if 76 > 0xffff
  movk ip0, 76 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+616]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 77 & 0xffff
#if 77 > 0xffff
  movk ip0, 77 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+624]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 78 & 0xffff
#if 78 > 0xffff
  movk ip0, 78 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+632]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 79 & 0xffff
#if 79 > 0xffff
  movk ip0, 79 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+640]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 80 & 0xffff
#if 80 > 0xffff
  movk ip0, 80 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+648]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 81 & 0xffff
#if 81 > 0xffff
  movk ip0, 81 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+656]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 82 & 0xffff
#if 82 > 0xffff
  movk ip0, 82 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+664]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 83 & 0xffff
#if 83 > 0xffff
  movk ip0, 83 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+672]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 84 & 0xffff
#if 84 > 0xffff
  movk ip0, 84 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+680]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 85 & 0xffff
#if 85 > 0xffff
  movk ip0, 85 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+688]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 86 & 0xffff
#if 86 > 0xffff
  movk ip0, 86 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+696]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 87 & 0xffff
#if 87 > 0xffff
  movk ip0, 87 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+704]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 88 & 0xffff
#if 88 > 0xffff
  movk ip0, 88 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+712]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 89 & 0xffff
#if 89 > 0xffff
  movk ip0, 89 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+720]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 90 & 0xffff
#if 90 > 0xffff
  movk ip0, 90 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+728]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 91 & 0xffff
#if 91 > 0xffff
  movk ip0, 91 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+736]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 92 & 0xffff
#if 92 > 0xffff
  movk ip0, 92 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+744]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 93 & 0xffff
#if 93 > 0xffff
  movk ip0, 93 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+752]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 94 & 0xffff
#if 94 > 0xffff
  movk ip0, 94 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+760]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 95 & 0xffff
#if 95 > 0xffff
  movk ip0, 95 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+768]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 96 & 0xffff
#if 96 > 0xffff
  movk ip0, 96 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+776]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 97 & 0xffff
#if 97 > 0xffff
  movk ip0, 97 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+784]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 98 & 0xffff
#if 98 > 0xffff
  movk ip0, 98 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+792]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 99 & 0xffff
#if 99 > 0xffff
  movk ip0, 99 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+800]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 100 & 0xffff
#if 100 > 0xffff
  movk ip0, 100 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+808]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 101 & 0xffff
#if 101 > 0xffff
  movk ip0, 101 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+816]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 102 & 0xffff
#if 102 > 0xffff
  movk ip0, 102 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+824]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 103 & 0xffff
#if 103 > 0xffff
  movk ip0, 103 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+832]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 104 & 0xffff
#if 104 > 0xffff
  movk ip0, 104 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+840]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 105 & 0xffff
#if 105 > 0xffff
  movk ip0, 105 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+848]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 106 & 0xffff
#if 106 > 0xffff
  movk ip0, 106 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+856]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 107 & 0xffff
#if 107 > 0xffff
  movk ip0, 107 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+864]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 108 & 0xffff
#if 108 > 0xffff
  movk ip0, 108 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+872]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 109 & 0xffff
#if 109 > 0xffff
  movk ip0, 109 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+880]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 110 & 0xffff
#if 110 > 0xffff
  movk ip0, 110 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+888]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 111 & 0xffff
#if 111 > 0xffff
  movk ip0, 111 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+896]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 112 & 0xffff
#if 112 > 0xffff
  movk ip0, 112 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+904]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 113 & 0xffff
#if 113 > 0xffff
  movk ip0, 113 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+912]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 114 & 0xffff
#if 114 > 0xffff
  movk ip0, 114 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+920]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 115 & 0xffff
#if 115 > 0xffff
  movk ip0, 115 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+928]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 116 & 0xffff
#if 116 > 0xffff
  movk ip0, 116 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+936]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 117 & 0xffff
#if 117 > 0xffff
  movk ip0, 117 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+944]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 118 & 0xffff
#if 118 > 0xffff
  movk ip0, 118 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+952]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 119 & 0xffff
#if 119 > 0xffff
  movk ip0, 119 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+960]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 120 & 0xffff
#if 120 > 0xffff
  movk ip0, 120 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+968]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 121 & 0xffff
#if 121 > 0xffff
  movk ip0, 121 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+976]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 122 & 0xffff
#if 122 > 0xffff
  movk ip0, 122 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+984]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 123 & 0xffff
#if 123 > 0xffff
  movk ip0, 123 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+992]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 124 & 0xffff
#if 124 > 0xffff
  movk ip0, 124 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1000]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 125 & 0xffff
#if 125 > 0xffff
  movk ip0, 125 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1008]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 126 & 0xffff
#if 126 > 0xffff
  movk ip0, 126 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1016
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1016]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 127 & 0xffff
#if 127 > 0xffff
  movk ip0, 127 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1024
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1024]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 128 & 0xffff
#if 128 > 0xffff
  movk ip0, 128 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1032
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1032]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 129 & 0xffff
#if 129 > 0xffff
  movk ip0, 129 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1040
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1040]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 130 & 0xffff
#if 130 > 0xffff
  movk ip0, 130 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1048
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1048]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 131 & 0xffff
#if 131 > 0xffff
  movk ip0, 131 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1056
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1056]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 132 & 0xffff
#if 132 > 0xffff
  movk ip0, 132 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1064
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1064]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 133 & 0xffff
#if 133 > 0xffff
  movk ip0, 133 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1072
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1072]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 134 & 0xffff
#if 134 > 0xffff
  movk ip0, 134 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1080
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1080]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 135 & 0xffff
#if 135 > 0xffff
  movk ip0, 135 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1088
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1088]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 136 & 0xffff
#if 136 > 0xffff
  movk ip0, 136 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1096
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1096]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 137 & 0xffff
#if 137 > 0xffff
  movk ip0, 137 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1104
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1104]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 138 & 0xffff
#if 138 > 0xffff
  movk ip0, 138 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1112
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1112]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 139 & 0xffff
#if 139 > 0xffff
  movk ip0, 139 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1120
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1120]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 140 & 0xffff
#if 140 > 0xffff
  movk ip0, 140 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1128
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1128]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 141 & 0xffff
#if 141 > 0xffff
  movk ip0, 141 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1136
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1136]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 142 & 0xffff
#if 142 > 0xffff
  movk ip0, 142 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1144
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1144]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 143 & 0xffff
#if 143 > 0xffff
  movk ip0, 143 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1152
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1152]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 144 & 0xffff
#if 144 > 0xffff
  movk ip0, 144 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1160
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1160]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 145 & 0xffff
#if 145 > 0xffff
  movk ip0, 145 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1168
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1168]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 146 & 0xffff
#if 146 > 0xffff
  movk ip0, 146 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1176
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1176]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 147 & 0xffff
#if 147 > 0xffff
  movk ip0, 147 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1184
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1184]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 148 & 0xffff
#if 148 > 0xffff
  movk ip0, 148 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1192
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1192]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 149 & 0xffff
#if 149 > 0xffff
  movk ip0, 149 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1200
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1200]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 150 & 0xffff
#if 150 > 0xffff
  movk ip0, 150 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1208
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1208]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 151 & 0xffff
#if 151 > 0xffff
  movk ip0, 151 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1216
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1216]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 152 & 0xffff
#if 152 > 0xffff
  movk ip0, 152 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1224
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1224]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 153 & 0xffff
#if 153 > 0xffff
  movk ip0, 153 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1232
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1232]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 154 & 0xffff
#if 154 > 0xffff
  movk ip0, 154 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1240
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1240]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 155 & 0xffff
#if 155 > 0xffff
  movk ip0, 155 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1248
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1248]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 156 & 0xffff
#if 156 > 0xffff
  movk ip0, 156 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1256
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1256]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 157 & 0xffff
#if 157 > 0xffff
  movk ip0, 157 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1264
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1264]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 158 & 0xffff
#if 158 > 0xffff
  movk ip0, 158 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1272
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1272]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 159 & 0xffff
#if 159 > 0xffff
  movk ip0, 159 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1280
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1280]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 160 & 0xffff
#if 160 > 0xffff
  movk ip0, 160 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1288
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1288]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 161 & 0xffff
#if 161 > 0xffff
  movk ip0, 161 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1296
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1296]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 162 & 0xffff
#if 162 > 0xffff
  movk ip0, 162 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1304
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1304]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 163 & 0xffff
#if 163 > 0xffff
  movk ip0, 163 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1312
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1312]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 164 & 0xffff
#if 164 > 0xffff
  movk ip0, 164 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1320
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1320]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 165 & 0xffff
#if 165 > 0xffff
  movk ip0, 165 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1328
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1328]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 166 & 0xffff
#if 166 > 0xffff
  movk ip0, 166 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1336
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1336]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 167 & 0xffff
#if 167 > 0xffff
  movk ip0, 167 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1344
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1344]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 168 & 0xffff
#if 168 > 0xffff
  movk ip0, 168 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1352
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1352]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 169 & 0xffff
#if 169 > 0xffff
  movk ip0, 169 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1360
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1360]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 170 & 0xffff
#if 170 > 0xffff
  movk ip0, 170 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1368
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1368]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 171 & 0xffff
#if 171 > 0xffff
  movk ip0, 171 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1376
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1376]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 172 & 0xffff
#if 172 > 0xffff
  movk ip0, 172 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1384
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1384]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 173 & 0xffff
#if 173 > 0xffff
  movk ip0, 173 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1392
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1392]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 174 & 0xffff
#if 174 > 0xffff
  movk ip0, 174 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1400
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1400]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 175 & 0xffff
#if 175 > 0xffff
  movk ip0, 175 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1408
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1408]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 176 & 0xffff
#if 176 > 0xffff
  movk ip0, 176 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1416
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1416]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 177 & 0xffff
#if 177 > 0xffff
  movk ip0, 177 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1424
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1424]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 178 & 0xffff
#if 178 > 0xffff
  movk ip0, 178 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1432
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1432]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 179 & 0xffff
#if 179 > 0xffff
  movk ip0, 179 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1440
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1440]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 180 & 0xffff
#if 180 > 0xffff
  movk ip0, 180 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1448
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1448]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 181 & 0xffff
#if 181 > 0xffff
  movk ip0, 181 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1456
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1456]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 182 & 0xffff
#if 182 > 0xffff
  movk ip0, 182 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1464
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1464]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 183 & 0xffff
#if 183 > 0xffff
  movk ip0, 183 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1472
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1472]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 184 & 0xffff
#if 184 > 0xffff
  movk ip0, 184 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1480
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1480]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 185 & 0xffff
#if 185 > 0xffff
  movk ip0, 185 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1488
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1488]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 186 & 0xffff
#if 186 > 0xffff
  movk ip0, 186 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1496
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1496]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 187 & 0xffff
#if 187 > 0xffff
  movk ip0, 187 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1504
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1504]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 188 & 0xffff
#if 188 > 0xffff
  movk ip0, 188 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1512
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1512]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 189 & 0xffff
#if 189 > 0xffff
  movk ip0, 189 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1520
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1520]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 190 & 0xffff
#if 190 > 0xffff
  movk ip0, 190 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1528
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1528]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 191 & 0xffff
#if 191 > 0xffff
  movk ip0, 191 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1536
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1536]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 192 & 0xffff
#if 192 > 0xffff
  movk ip0, 192 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1544
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1544]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 193 & 0xffff
#if 193 > 0xffff
  movk ip0, 193 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1552
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1552]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 194 & 0xffff
#if 194 > 0xffff
  movk ip0, 194 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1560
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1560]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 195 & 0xffff
#if 195 > 0xffff
  movk ip0, 195 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1568
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1568]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 196 & 0xffff
#if 196 > 0xffff
  movk ip0, 196 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1576
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1576]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 197 & 0xffff
#if 197 > 0xffff
  movk ip0, 197 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1584
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1584]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 198 & 0xffff
#if 198 > 0xffff
  movk ip0, 198 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1592
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1592]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 199 & 0xffff
#if 199 > 0xffff
  movk ip0, 199 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1600
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1600]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 200 & 0xffff
#if 200 > 0xffff
  movk ip0, 200 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1608
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1608]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 201 & 0xffff
#if 201 > 0xffff
  movk ip0, 201 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1616
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1616]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 202 & 0xffff
#if 202 > 0xffff
  movk ip0, 202 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1624
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1624]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 203 & 0xffff
#if 203 > 0xffff
  movk ip0, 203 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1632
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1632]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 204 & 0xffff
#if 204 > 0xffff
  movk ip0, 204 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1640
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1640]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 205 & 0xffff
#if 205 > 0xffff
  movk ip0, 205 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1648
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1648]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 206 & 0xffff
#if 206 > 0xffff
  movk ip0, 206 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1656
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1656]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 207 & 0xffff
#if 207 > 0xffff
  movk ip0, 207 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1664
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1664]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 208 & 0xffff
#if 208 > 0xffff
  movk ip0, 208 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1672
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1672]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 209 & 0xffff
#if 209 > 0xffff
  movk ip0, 209 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1680
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1680]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 210 & 0xffff
#if 210 > 0xffff
  movk ip0, 210 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1688
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1688]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 211 & 0xffff
#if 211 > 0xffff
  movk ip0, 211 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1696
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1696]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 212 & 0xffff
#if 212 > 0xffff
  movk ip0, 212 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1704
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1704]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 213 & 0xffff
#if 213 > 0xffff
  movk ip0, 213 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1712
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1712]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 214 & 0xffff
#if 214 > 0xffff
  movk ip0, 214 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1720
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1720]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 215 & 0xffff
#if 215 > 0xffff
  movk ip0, 215 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1728
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1728]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 216 & 0xffff
#if 216 > 0xffff
  movk ip0, 216 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1736
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1736]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 217 & 0xffff
#if 217 > 0xffff
  movk ip0, 217 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1744
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1744]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 218 & 0xffff
#if 218 > 0xffff
  movk ip0, 218 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1752
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1752]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 219 & 0xffff
#if 219 > 0xffff
  movk ip0, 219 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1760
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1760]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 220 & 0xffff
#if 220 > 0xffff
  movk ip0, 220 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1768
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1768]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 221 & 0xffff
#if 221 > 0xffff
  movk ip0, 221 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1776
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1776]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 222 & 0xffff
#if 222 > 0xffff
  movk ip0, 222 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1784
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1784]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 223 & 0xffff
#if 223 > 0xffff
  movk ip0, 223 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1792
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1792]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 224 & 0xffff
#if 224 > 0xffff
  movk ip0, 224 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1800
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1800]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 225 & 0xffff
#if 225 > 0xffff
  movk ip0, 225 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1808
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1808]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 226 & 0xffff
#if 226 > 0xffff
  movk ip0, 226 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1816
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1816]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 227 & 0xffff
#if 227 > 0xffff
  movk ip0, 227 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1824
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1824]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 228 & 0xffff
#if 228 > 0xffff
  movk ip0, 228 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1832
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1832]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 229 & 0xffff
#if 229 > 0xffff
  movk ip0, 229 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1840
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1840]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 230 & 0xffff
#if 230 > 0xffff
  movk ip0, 230 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1848
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1848]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 231 & 0xffff
#if 231 > 0xffff
  movk ip0, 231 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1856
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1856]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 232 & 0xffff
#if 232 > 0xffff
  movk ip0, 232 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1864
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1864]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 233 & 0xffff
#if 233 > 0xffff
  movk ip0, 233 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1872
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1872]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 234 & 0xffff
#if 234 > 0xffff
  movk ip0, 234 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1880
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1880]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 235 & 0xffff
#if 235 > 0xffff
  movk ip0, 235 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1888
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1888]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 236 & 0xffff
#if 236 > 0xffff
  movk ip0, 236 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1896
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1896]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 237 & 0xffff
#if 237 > 0xffff
  movk ip0, 237 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1904
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1904]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 238 & 0xffff
#if 238 > 0xffff
  movk ip0, 238 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1912
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1912]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 239 & 0xffff
#if 239 > 0xffff
  movk ip0, 239 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1920
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1920]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 240 & 0xffff
#if 240 > 0xffff
  movk ip0, 240 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1928
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1928]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 241 & 0xffff
#if 241 > 0xffff
  movk ip0, 241 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1936
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1936]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 242 & 0xffff
#if 242 > 0xffff
  movk ip0, 242 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1944
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1944]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 243 & 0xffff
#if 243 > 0xffff
  movk ip0, 243 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1952
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1952]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 244 & 0xffff
#if 244 > 0xffff
  movk ip0, 244 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1960
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1960]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 245 & 0xffff
#if 245 > 0xffff
  movk ip0, 245 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1968
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1968]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 246 & 0xffff
#if 246 > 0xffff
  movk ip0, 246 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1976
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1976]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 247 & 0xffff
#if 247 > 0xffff
  movk ip0, 247 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1984
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1984]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 248 & 0xffff
#if 248 > 0xffff
  movk ip0, 248 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+1992
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+1992]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 249 & 0xffff
#if 249 > 0xffff
  movk ip0, 249 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2000
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2000]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 250 & 0xffff
#if 250 > 0xffff
  movk ip0, 250 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2008
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2008]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 251 & 0xffff
#if 251 > 0xffff
  movk ip0, 251 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2016
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2016]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 252 & 0xffff
#if 252 > 0xffff
  movk ip0, 252 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2024
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2024]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 253 & 0xffff
#if 253 > 0xffff
  movk ip0, 253 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2032
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2032]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 254 & 0xffff
#if 254 > 0xffff
  movk ip0, 254 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2040
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2040]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 255 & 0xffff
#if 255 > 0xffff
  movk ip0, 255 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2048
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2048]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 256 & 0xffff
#if 256 > 0xffff
  movk ip0, 256 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2056
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2056]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 257 & 0xffff
#if 257 > 0xffff
  movk ip0, 257 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2064
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2064]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 258 & 0xffff
#if 258 > 0xffff
  movk ip0, 258 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2072
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2072]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 259 & 0xffff
#if 259 > 0xffff
  movk ip0, 259 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2080
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2080]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 260 & 0xffff
#if 260 > 0xffff
  movk ip0, 260 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2088
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2088]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 261 & 0xffff
#if 261 > 0xffff
  movk ip0, 261 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2096
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2096]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 262 & 0xffff
#if 262 > 0xffff
  movk ip0, 262 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2104
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2104]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 263 & 0xffff
#if 263 > 0xffff
  movk ip0, 263 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2112
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2112]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 264 & 0xffff
#if 264 > 0xffff
  movk ip0, 264 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2120
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2120]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 265 & 0xffff
#if 265 > 0xffff
  movk ip0, 265 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2128
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2128]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 266 & 0xffff
#if 266 > 0xffff
  movk ip0, 266 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2136
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2136]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 267 & 0xffff
#if 267 > 0xffff
  movk ip0, 267 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2144
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2144]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 268 & 0xffff
#if 268 > 0xffff
  movk ip0, 268 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2152
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2152]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 269 & 0xffff
#if 269 > 0xffff
  movk ip0, 269 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2160
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2160]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 270 & 0xffff
#if 270 > 0xffff
  movk ip0, 270 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2168
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2168]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 271 & 0xffff
#if 271 > 0xffff
  movk ip0, 271 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2176
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2176]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 272 & 0xffff
#if 272 > 0xffff
  movk ip0, 272 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2184
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2184]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 273 & 0xffff
#if 273 > 0xffff
  movk ip0, 273 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2192
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2192]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 274 & 0xffff
#if 274 > 0xffff
  movk ip0, 274 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2200
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2200]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 275 & 0xffff
#if 275 > 0xffff
  movk ip0, 275 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2208
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2208]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 276 & 0xffff
#if 276 > 0xffff
  movk ip0, 276 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2216
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2216]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 277 & 0xffff
#if 277 > 0xffff
  movk ip0, 277 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2224
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2224]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 278 & 0xffff
#if 278 > 0xffff
  movk ip0, 278 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2232
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2232]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 279 & 0xffff
#if 279 > 0xffff
  movk ip0, 279 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2240
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2240]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 280 & 0xffff
#if 280 > 0xffff
  movk ip0, 280 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2248
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2248]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 281 & 0xffff
#if 281 > 0xffff
  movk ip0, 281 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2256
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2256]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 282 & 0xffff
#if 282 > 0xffff
  movk ip0, 282 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2264
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2264]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 283 & 0xffff
#if 283 > 0xffff
  movk ip0, 283 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2272
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2272]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 284 & 0xffff
#if 284 > 0xffff
  movk ip0, 284 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2280
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2280]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 285 & 0xffff
#if 285 > 0xffff
  movk ip0, 285 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2288
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2288]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 286 & 0xffff
#if 286 > 0xffff
  movk ip0, 286 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2296
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2296]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 287 & 0xffff
#if 287 > 0xffff
  movk ip0, 287 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2304
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2304]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 288 & 0xffff
#if 288 > 0xffff
  movk ip0, 288 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2312
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2312]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 289 & 0xffff
#if 289 > 0xffff
  movk ip0, 289 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2320
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2320]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 290 & 0xffff
#if 290 > 0xffff
  movk ip0, 290 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2328
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2328]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 291 & 0xffff
#if 291 > 0xffff
  movk ip0, 291 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2336
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2336]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 292 & 0xffff
#if 292 > 0xffff
  movk ip0, 292 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2344
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2344]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 293 & 0xffff
#if 293 > 0xffff
  movk ip0, 293 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2352
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2352]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 294 & 0xffff
#if 294 > 0xffff
  movk ip0, 294 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2360
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2360]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 295 & 0xffff
#if 295 > 0xffff
  movk ip0, 295 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2368
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2368]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 296 & 0xffff
#if 296 > 0xffff
  movk ip0, 296 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2376
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2376]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 297 & 0xffff
#if 297 > 0xffff
  movk ip0, 297 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2384
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2384]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 298 & 0xffff
#if 298 > 0xffff
  movk ip0, 298 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2392
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2392]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 299 & 0xffff
#if 299 > 0xffff
  movk ip0, 299 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2400
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2400]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 300 & 0xffff
#if 300 > 0xffff
  movk ip0, 300 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2408
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2408]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 301 & 0xffff
#if 301 > 0xffff
  movk ip0, 301 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2416
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2416]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 302 & 0xffff
#if 302 > 0xffff
  movk ip0, 302 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2424
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2424]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 303 & 0xffff
#if 303 > 0xffff
  movk ip0, 303 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2432
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2432]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 304 & 0xffff
#if 304 > 0xffff
  movk ip0, 304 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2440
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2440]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 305 & 0xffff
#if 305 > 0xffff
  movk ip0, 305 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2448
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2448]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 306 & 0xffff
#if 306 > 0xffff
  movk ip0, 306 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2456
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2456]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 307 & 0xffff
#if 307 > 0xffff
  movk ip0, 307 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2464
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2464]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 308 & 0xffff
#if 308 > 0xffff
  movk ip0, 308 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2472
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2472]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 309 & 0xffff
#if 309 > 0xffff
  movk ip0, 309 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2480
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2480]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 310 & 0xffff
#if 310 > 0xffff
  movk ip0, 310 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2488
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2488]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 311 & 0xffff
#if 311 > 0xffff
  movk ip0, 311 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2496
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2496]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 312 & 0xffff
#if 312 > 0xffff
  movk ip0, 312 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2504
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2504]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 313 & 0xffff
#if 313 > 0xffff
  movk ip0, 313 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2512
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2512]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 314 & 0xffff
#if 314 > 0xffff
  movk ip0, 314 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2520
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2520]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 315 & 0xffff
#if 315 > 0xffff
  movk ip0, 315 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2528
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2528]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 316 & 0xffff
#if 316 > 0xffff
  movk ip0, 316 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2536
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2536]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 317 & 0xffff
#if 317 > 0xffff
  movk ip0, 317 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2544
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2544]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 318 & 0xffff
#if 318 > 0xffff
  movk ip0, 318 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2552
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2552]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 319 & 0xffff
#if 319 > 0xffff
  movk ip0, 319 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2560
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2560]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 320 & 0xffff
#if 320 > 0xffff
  movk ip0, 320 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2568
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2568]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 321 & 0xffff
#if 321 > 0xffff
  movk ip0, 321 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2576
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2576]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 322 & 0xffff
#if 322 > 0xffff
  movk ip0, 322 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2584
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2584]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 323 & 0xffff
#if 323 > 0xffff
  movk ip0, 323 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2592
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2592]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 324 & 0xffff
#if 324 > 0xffff
  movk ip0, 324 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2600
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2600]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 325 & 0xffff
#if 325 > 0xffff
  movk ip0, 325 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2608
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2608]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 326 & 0xffff
#if 326 > 0xffff
  movk ip0, 326 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2616
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2616]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 327 & 0xffff
#if 327 > 0xffff
  movk ip0, 327 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2624
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2624]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 328 & 0xffff
#if 328 > 0xffff
  movk ip0, 328 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2632
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2632]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 329 & 0xffff
#if 329 > 0xffff
  movk ip0, 329 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2640
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2640]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 330 & 0xffff
#if 330 > 0xffff
  movk ip0, 330 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2648
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2648]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 331 & 0xffff
#if 331 > 0xffff
  movk ip0, 331 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2656
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2656]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 332 & 0xffff
#if 332 > 0xffff
  movk ip0, 332 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2664
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2664]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 333 & 0xffff
#if 333 > 0xffff
  movk ip0, 333 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2672
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2672]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 334 & 0xffff
#if 334 > 0xffff
  movk ip0, 334 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2680
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2680]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 335 & 0xffff
#if 335 > 0xffff
  movk ip0, 335 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2688
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2688]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 336 & 0xffff
#if 336 > 0xffff
  movk ip0, 336 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2696
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2696]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 337 & 0xffff
#if 337 > 0xffff
  movk ip0, 337 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2704
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2704]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 338 & 0xffff
#if 338 > 0xffff
  movk ip0, 338 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2712
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2712]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 339 & 0xffff
#if 339 > 0xffff
  movk ip0, 339 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2720
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2720]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 340 & 0xffff
#if 340 > 0xffff
  movk ip0, 340 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2728
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2728]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 341 & 0xffff
#if 341 > 0xffff
  movk ip0, 341 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2736
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2736]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 342 & 0xffff
#if 342 > 0xffff
  movk ip0, 342 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2744
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2744]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 343 & 0xffff
#if 343 > 0xffff
  movk ip0, 343 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2752
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2752]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 344 & 0xffff
#if 344 > 0xffff
  movk ip0, 344 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2760
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2760]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 345 & 0xffff
#if 345 > 0xffff
  movk ip0, 345 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2768
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2768]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 346 & 0xffff
#if 346 > 0xffff
  movk ip0, 346 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2776
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2776]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 347 & 0xffff
#if 347 > 0xffff
  movk ip0, 347 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2784
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2784]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 348 & 0xffff
#if 348 > 0xffff
  movk ip0, 348 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2792
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2792]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 349 & 0xffff
#if 349 > 0xffff
  movk ip0, 349 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2800
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2800]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 350 & 0xffff
#if 350 > 0xffff
  movk ip0, 350 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2808
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2808]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 351 & 0xffff
#if 351 > 0xffff
  movk ip0, 351 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2816
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2816]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 352 & 0xffff
#if 352 > 0xffff
  movk ip0, 352 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2824
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2824]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 353 & 0xffff
#if 353 > 0xffff
  movk ip0, 353 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2832
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2832]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 354 & 0xffff
#if 354 > 0xffff
  movk ip0, 354 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2840
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2840]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 355 & 0xffff
#if 355 > 0xffff
  movk ip0, 355 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2848
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2848]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 356 & 0xffff
#if 356 > 0xffff
  movk ip0, 356 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2856
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2856]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 357 & 0xffff
#if 357 > 0xffff
  movk ip0, 357 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2864
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2864]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 358 & 0xffff
#if 358 > 0xffff
  movk ip0, 358 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2872
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2872]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 359 & 0xffff
#if 359 > 0xffff
  movk ip0, 359 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2880
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2880]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 360 & 0xffff
#if 360 > 0xffff
  movk ip0, 360 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2888
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2888]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 361 & 0xffff
#if 361 > 0xffff
  movk ip0, 361 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2896
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2896]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 362 & 0xffff
#if 362 > 0xffff
  movk ip0, 362 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2904
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2904]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 363 & 0xffff
#if 363 > 0xffff
  movk ip0, 363 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2912
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2912]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 364 & 0xffff
#if 364 > 0xffff
  movk ip0, 364 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2920
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2920]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 365 & 0xffff
#if 365 > 0xffff
  movk ip0, 365 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2928
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2928]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 366 & 0xffff
#if 366 > 0xffff
  movk ip0, 366 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2936
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2936]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 367 & 0xffff
#if 367 > 0xffff
  movk ip0, 367 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2944
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2944]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 368 & 0xffff
#if 368 > 0xffff
  movk ip0, 368 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2952
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2952]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 369 & 0xffff
#if 369 > 0xffff
  movk ip0, 369 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2960
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2960]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 370 & 0xffff
#if 370 > 0xffff
  movk ip0, 370 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2968
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2968]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 371 & 0xffff
#if 371 > 0xffff
  movk ip0, 371 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2976
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2976]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 372 & 0xffff
#if 372 > 0xffff
  movk ip0, 372 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2984
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2984]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 373 & 0xffff
#if 373 > 0xffff
  movk ip0, 373 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+2992
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+2992]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 374 & 0xffff
#if 374 > 0xffff
  movk ip0, 374 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3000
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3000]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 375 & 0xffff
#if 375 > 0xffff
  movk ip0, 375 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3008
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3008]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 376 & 0xffff
#if 376 > 0xffff
  movk ip0, 376 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3016
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3016]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 377 & 0xffff
#if 377 > 0xffff
  movk ip0, 377 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3024
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3024]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 378 & 0xffff
#if 378 > 0xffff
  movk ip0, 378 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3032
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3032]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 379 & 0xffff
#if 379 > 0xffff
  movk ip0, 379 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3040
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3040]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 380 & 0xffff
#if 380 > 0xffff
  movk ip0, 380 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3048
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3048]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 381 & 0xffff
#if 381 > 0xffff
  movk ip0, 381 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3056
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3056]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 382 & 0xffff
#if 382 > 0xffff
  movk ip0, 382 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3064
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3064]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 383 & 0xffff
#if 383 > 0xffff
  movk ip0, 383 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3072
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3072]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 384 & 0xffff
#if 384 > 0xffff
  movk ip0, 384 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3080
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3080]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 385 & 0xffff
#if 385 > 0xffff
  movk ip0, 385 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3088
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3088]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 386 & 0xffff
#if 386 > 0xffff
  movk ip0, 386 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3096
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3096]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 387 & 0xffff
#if 387 > 0xffff
  movk ip0, 387 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3104
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3104]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 388 & 0xffff
#if 388 > 0xffff
  movk ip0, 388 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3112
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3112]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 389 & 0xffff
#if 389 > 0xffff
  movk ip0, 389 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3120
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3120]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 390 & 0xffff
#if 390 > 0xffff
  movk ip0, 390 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3128
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3128]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 391 & 0xffff
#if 391 > 0xffff
  movk ip0, 391 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3136
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3136]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 392 & 0xffff
#if 392 > 0xffff
  movk ip0, 392 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3144
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3144]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 393 & 0xffff
#if 393 > 0xffff
  movk ip0, 393 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3152
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3152]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 394 & 0xffff
#if 394 > 0xffff
  movk ip0, 394 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3160
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3160]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 395 & 0xffff
#if 395 > 0xffff
  movk ip0, 395 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3168
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3168]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 396 & 0xffff
#if 396 > 0xffff
  movk ip0, 396 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3176
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3176]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 397 & 0xffff
#if 397 > 0xffff
  movk ip0, 397 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3184
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3184]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 398 & 0xffff
#if 398 > 0xffff
  movk ip0, 398 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3192
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3192]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 399 & 0xffff
#if 399 > 0xffff
  movk ip0, 399 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3200
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3200]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 400 & 0xffff
#if 400 > 0xffff
  movk ip0, 400 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3208
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3208]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 401 & 0xffff
#if 401 > 0xffff
  movk ip0, 401 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3216
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3216]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 402 & 0xffff
#if 402 > 0xffff
  movk ip0, 402 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3224
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3224]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 403 & 0xffff
#if 403 > 0xffff
  movk ip0, 403 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3232
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3232]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 404 & 0xffff
#if 404 > 0xffff
  movk ip0, 404 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3240
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3240]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 405 & 0xffff
#if 405 > 0xffff
  movk ip0, 405 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3248
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3248]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 406 & 0xffff
#if 406 > 0xffff
  movk ip0, 406 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3256
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3256]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 407 & 0xffff
#if 407 > 0xffff
  movk ip0, 407 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3264
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3264]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 408 & 0xffff
#if 408 > 0xffff
  movk ip0, 408 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3272
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3272]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 409 & 0xffff
#if 409 > 0xffff
  movk ip0, 409 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3280
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3280]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 410 & 0xffff
#if 410 > 0xffff
  movk ip0, 410 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3288
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3288]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 411 & 0xffff
#if 411 > 0xffff
  movk ip0, 411 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3296
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3296]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 412 & 0xffff
#if 412 > 0xffff
  movk ip0, 412 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3304
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3304]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 413 & 0xffff
#if 413 > 0xffff
  movk ip0, 413 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3312
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3312]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 414 & 0xffff
#if 414 > 0xffff
  movk ip0, 414 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3320
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3320]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 415 & 0xffff
#if 415 > 0xffff
  movk ip0, 415 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3328
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3328]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 416 & 0xffff
#if 416 > 0xffff
  movk ip0, 416 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3336
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3336]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 417 & 0xffff
#if 417 > 0xffff
  movk ip0, 417 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3344
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3344]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 418 & 0xffff
#if 418 > 0xffff
  movk ip0, 418 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3352
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3352]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 419 & 0xffff
#if 419 > 0xffff
  movk ip0, 419 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3360
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3360]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 420 & 0xffff
#if 420 > 0xffff
  movk ip0, 420 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3368
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3368]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 421 & 0xffff
#if 421 > 0xffff
  movk ip0, 421 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3376
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3376]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 422 & 0xffff
#if 422 > 0xffff
  movk ip0, 422 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3384
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3384]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 423 & 0xffff
#if 423 > 0xffff
  movk ip0, 423 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3392
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3392]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 424 & 0xffff
#if 424 > 0xffff
  movk ip0, 424 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3400
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3400]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 425 & 0xffff
#if 425 > 0xffff
  movk ip0, 425 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3408
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3408]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 426 & 0xffff
#if 426 > 0xffff
  movk ip0, 426 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3416
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3416]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 427 & 0xffff
#if 427 > 0xffff
  movk ip0, 427 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3424
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3424]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 428 & 0xffff
#if 428 > 0xffff
  movk ip0, 428 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3432
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3432]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 429 & 0xffff
#if 429 > 0xffff
  movk ip0, 429 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3440
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3440]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 430 & 0xffff
#if 430 > 0xffff
  movk ip0, 430 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3448
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3448]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 431 & 0xffff
#if 431 > 0xffff
  movk ip0, 431 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3456
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3456]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 432 & 0xffff
#if 432 > 0xffff
  movk ip0, 432 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3464
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3464]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 433 & 0xffff
#if 433 > 0xffff
  movk ip0, 433 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3472
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3472]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 434 & 0xffff
#if 434 > 0xffff
  movk ip0, 434 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3480
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3480]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 435 & 0xffff
#if 435 > 0xffff
  movk ip0, 435 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3488
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3488]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 436 & 0xffff
#if 436 > 0xffff
  movk ip0, 436 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3496
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3496]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 437 & 0xffff
#if 437 > 0xffff
  movk ip0, 437 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3504
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3504]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 438 & 0xffff
#if 438 > 0xffff
  movk ip0, 438 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3512
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3512]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 439 & 0xffff
#if 439 > 0xffff
  movk ip0, 439 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3520
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3520]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 440 & 0xffff
#if 440 > 0xffff
  movk ip0, 440 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3528
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3528]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 441 & 0xffff
#if 441 > 0xffff
  movk ip0, 441 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3536
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3536]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 442 & 0xffff
#if 442 > 0xffff
  movk ip0, 442 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3544
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3544]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 443 & 0xffff
#if 443 > 0xffff
  movk ip0, 443 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3552
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3552]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 444 & 0xffff
#if 444 > 0xffff
  movk ip0, 444 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3560
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3560]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 445 & 0xffff
#if 445 > 0xffff
  movk ip0, 445 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3568
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3568]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 446 & 0xffff
#if 446 > 0xffff
  movk ip0, 446 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3576
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3576]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 447 & 0xffff
#if 447 > 0xffff
  movk ip0, 447 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3584
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3584]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 448 & 0xffff
#if 448 > 0xffff
  movk ip0, 448 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3592
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3592]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 449 & 0xffff
#if 449 > 0xffff
  movk ip0, 449 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3600
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3600]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 450 & 0xffff
#if 450 > 0xffff
  movk ip0, 450 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3608
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3608]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 451 & 0xffff
#if 451 > 0xffff
  movk ip0, 451 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3616
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3616]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 452 & 0xffff
#if 452 > 0xffff
  movk ip0, 452 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3624
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3624]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 453 & 0xffff
#if 453 > 0xffff
  movk ip0, 453 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3632
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3632]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 454 & 0xffff
#if 454 > 0xffff
  movk ip0, 454 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3640
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3640]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 455 & 0xffff
#if 455 > 0xffff
  movk ip0, 455 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3648
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3648]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 456 & 0xffff
#if 456 > 0xffff
  movk ip0, 456 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3656
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3656]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 457 & 0xffff
#if 457 > 0xffff
  movk ip0, 457 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3664
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3664]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 458 & 0xffff
#if 458 > 0xffff
  movk ip0, 458 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3672
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3672]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 459 & 0xffff
#if 459 > 0xffff
  movk ip0, 459 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3680
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3680]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 460 & 0xffff
#if 460 > 0xffff
  movk ip0, 460 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3688
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3688]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 461 & 0xffff
#if 461 > 0xffff
  movk ip0, 461 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3696
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3696]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 462 & 0xffff
#if 462 > 0xffff
  movk ip0, 462 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3704
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3704]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 463 & 0xffff
#if 463 > 0xffff
  movk ip0, 463 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3712
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3712]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 464 & 0xffff
#if 464 > 0xffff
  movk ip0, 464 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3720
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3720]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 465 & 0xffff
#if 465 > 0xffff
  movk ip0, 465 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3728
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3728]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 466 & 0xffff
#if 466 > 0xffff
  movk ip0, 466 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3736
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3736]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 467 & 0xffff
#if 467 > 0xffff
  movk ip0, 467 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3744
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3744]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 468 & 0xffff
#if 468 > 0xffff
  movk ip0, 468 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3752
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3752]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 469 & 0xffff
#if 469 > 0xffff
  movk ip0, 469 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3760
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3760]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 470 & 0xffff
#if 470 > 0xffff
  movk ip0, 470 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3768
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3768]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 471 & 0xffff
#if 471 > 0xffff
  movk ip0, 471 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3776
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3776]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 472 & 0xffff
#if 472 > 0xffff
  movk ip0, 472 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3784
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3784]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 473 & 0xffff
#if 473 > 0xffff
  movk ip0, 473 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3792
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3792]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 474 & 0xffff
#if 474 > 0xffff
  movk ip0, 474 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3800
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3800]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 475 & 0xffff
#if 475 > 0xffff
  movk ip0, 475 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3808
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3808]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 476 & 0xffff
#if 476 > 0xffff
  movk ip0, 476 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3816
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3816]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 477 & 0xffff
#if 477 > 0xffff
  movk ip0, 477 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3824
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3824]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 478 & 0xffff
#if 478 > 0xffff
  movk ip0, 478 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3832
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3832]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 479 & 0xffff
#if 479 > 0xffff
  movk ip0, 479 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3840
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3840]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 480 & 0xffff
#if 480 > 0xffff
  movk ip0, 480 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3848
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3848]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 481 & 0xffff
#if 481 > 0xffff
  movk ip0, 481 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3856
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3856]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 482 & 0xffff
#if 482 > 0xffff
  movk ip0, 482 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3864
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3864]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 483 & 0xffff
#if 483 > 0xffff
  movk ip0, 483 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3872
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3872]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 484 & 0xffff
#if 484 > 0xffff
  movk ip0, 484 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3880
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3880]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 485 & 0xffff
#if 485 > 0xffff
  movk ip0, 485 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3888
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3888]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 486 & 0xffff
#if 486 > 0xffff
  movk ip0, 486 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3896
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3896]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 487 & 0xffff
#if 487 > 0xffff
  movk ip0, 487 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3904
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3904]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 488 & 0xffff
#if 488 > 0xffff
  movk ip0, 488 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3912
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3912]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 489 & 0xffff
#if 489 > 0xffff
  movk ip0, 489 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3920
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3920]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 490 & 0xffff
#if 490 > 0xffff
  movk ip0, 490 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3928
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3928]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 491 & 0xffff
#if 491 > 0xffff
  movk ip0, 491 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3936
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3936]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 492 & 0xffff
#if 492 > 0xffff
  movk ip0, 492 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3944
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3944]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 493 & 0xffff
#if 493 > 0xffff
  movk ip0, 493 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3952
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3952]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 494 & 0xffff
#if 494 > 0xffff
  movk ip0, 494 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3960
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3960]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 495 & 0xffff
#if 495 > 0xffff
  movk ip0, 495 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3968
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3968]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 496 & 0xffff
#if 496 > 0xffff
  movk ip0, 496 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3976
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3976]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 497 & 0xffff
#if 497 > 0xffff
  movk ip0, 497 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3984
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3984]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 498 & 0xffff
#if 498 > 0xffff
  movk ip0, 498 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+3992
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+3992]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 499 & 0xffff
#if 499 > 0xffff
  movk ip0, 499 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+4000
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+4000]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 500 & 0xffff
#if 500 > 0xffff
  movk ip0, 500 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+4008
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+4008]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 501 & 0xffff
#if 501 > 0xffff
  movk ip0, 501 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+4016
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+4016]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 502 & 0xffff
#if 502 > 0xffff
  movk ip0, 502 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libpango_1_0_so_tramp_table+4024
  ldr ip0, [ip0, #:lo12:_libpango_1_0_so_tramp_table+4024]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 503 & 0xffff
#if 503 > 0xffff
  movk ip0, 503 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libpango_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

