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

  bl _libcairo_so_tramp_resolve
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

  .globl cairo_append_path
  .p2align 4
  .type cairo_append_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_append_path
#endif
cairo_append_path:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+0]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+8]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+16]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+24]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+32]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+40]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+48]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+56]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+64]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+72]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+80]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+88]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+96]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+104]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+112]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+120]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+128]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+136]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+144]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+152]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+160]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+168]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+176]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+184]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+192]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+200]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+208]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+216]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+224]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+232]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+240]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+248]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+256]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+264]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+272]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+280]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+288]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+296]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+304]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+312]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+320]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+328]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+336]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+344]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+352]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+360]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+368]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+376]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+384]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+392]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+400]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+408]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+416]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+424]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+432]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+440]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+448]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+456]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+464]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+472]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+480]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+488]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+496]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+504]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+512]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+520]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+528]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+536]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+544]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+552]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+560]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+568]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+576]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+584]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+592]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+600]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+608]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+616]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+624]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+632]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+640]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+648]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+656]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+664]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+672]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+680]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+688]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+696]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+704]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+712]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+720]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+728]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+736]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+744]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+752]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+760]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+768]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+776]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+784]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+792]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+800]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+808]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+816]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+824]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+832]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+840]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+848]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+856]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+864]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+872]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+880]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+888]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+896]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+904]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+912]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+920]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+928]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+936]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+944]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+952]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+960]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+968]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+976]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+984]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+992]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1000]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1008]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1016
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1016]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1024
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1024]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1032
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1032]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1040
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1040]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1048
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1048]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1056
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1056]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1064
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1064]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1072
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1072]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1080
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1080]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1088
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1088]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1096
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1096]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1104
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1104]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1112
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1112]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1120
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1120]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1128
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1128]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1136
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1136]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1144
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1144]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1152
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1152]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1160
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1160]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1168
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1168]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1176
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1176]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1184
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1184]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1192
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1192]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1200
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1200]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1208
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1208]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1216
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1216]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1224
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1224]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1232
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1232]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1240
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1240]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1248
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1248]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1256
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1256]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1264
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1264]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1272
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1272]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1280
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1280]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1288
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1288]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1296
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1296]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1304
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1304]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1312
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1312]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1320
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1320]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1328
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1328]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1336
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1336]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1344
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1344]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1352
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1352]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1360
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1360]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1368
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1368]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1376
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1376]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1384
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1384]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1392
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1392]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1400
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1400]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1408
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1408]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1416
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1416]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1424
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1424]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1432
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1432]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1440
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1440]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1448
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1448]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1456
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1456]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1464
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1464]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1472
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1472]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1480
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1480]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1488
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1488]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1496
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1496]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1504
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1504]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1512
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1512]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1520
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1520]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1528
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1528]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1536
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1536]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1544
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1544]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1552
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1552]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1560
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1560]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1568
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1568]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1576
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1576]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1584
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1584]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1592
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1592]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1600
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1600]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1608
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1608]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1616
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1616]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1624
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1624]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1632
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1632]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1640
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1640]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1648
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1648]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1656
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1656]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1664
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1664]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1672
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1672]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1680
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1680]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1688
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1688]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1696
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1696]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1704
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1704]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1712
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1712]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1720
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1720]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1728
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1728]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1736
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1736]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1744
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1744]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1752
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1752]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1760
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1760]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1768
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1768]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1776
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1776]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1784
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1784]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1792
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1792]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1800
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1800]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1808
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1808]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1816
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1816]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1824
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1824]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1832
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1832]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1840
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1840]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1848
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1848]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1856
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1856]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1864
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1864]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1872
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1872]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1880
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1880]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1888
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1888]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1896
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1896]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1904
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1904]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1912
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1912]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1920
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1920]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1928
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1928]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1936
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1936]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1944
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1944]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1952
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1952]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1960
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1960]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1968
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1968]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1976
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1976]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1984
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1984]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+1992
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+1992]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2000
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2000]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2008
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2008]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2016
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2016]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2024
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2024]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2032
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2032]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2040
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2040]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2048
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2048]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2056
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2056]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2064
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2064]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2072
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2072]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2080
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2080]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2088
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2088]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2096
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2096]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2104
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2104]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2112
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2112]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2120
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2120]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2128
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2128]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2136
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2136]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2144
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2144]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2152
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2152]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2160
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2160]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2168
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2168]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2176
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2176]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2184
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2184]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2192
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2192]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2200
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2200]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2208
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2208]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2216
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2216]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2224
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2224]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2232
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2232]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2240
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2240]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2248
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2248]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2256
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2256]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2264
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2264]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2272
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2272]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2280
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2280]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2288
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2288]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2296
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2296]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2304
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2304]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2312
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2312]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2320
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2320]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2328
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2328]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2336
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2336]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2344
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2344]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2352
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2352]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2360
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2360]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2368
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2368]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2376
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2376]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2384
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2384]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2392
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2392]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2400
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2400]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2408
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2408]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2416
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2416]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2424
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2424]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2432
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2432]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2440
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2440]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2448
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2448]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2456
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2456]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2464
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2464]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2472
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2472]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2480
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2480]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2488
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2488]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2496
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2496]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2504
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2504]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2512
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2512]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2520
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2520]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2528
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2528]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2536
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2536]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2544
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2544]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2552
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2552]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2560
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2560]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2568
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2568]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2576
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2576]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2584
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2584]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2592
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2592]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2600
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2600]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2608
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2608]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2616
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2616]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2624
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2624]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2632
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2632]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2640
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2640]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2648
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2648]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2656
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2656]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2664
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2664]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2672
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2672]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2680
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2680]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2688
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2688]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2696
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2696]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2704
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2704]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2712
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2712]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2720
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2720]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2728
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2728]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2736
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2736]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2744
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2744]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2752
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2752]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2760
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2760]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2768
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2768]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2776
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2776]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2784
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2784]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2792
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2792]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2800
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2800]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2808
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2808]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2816
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2816]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2824
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2824]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2832
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2832]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2840
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2840]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2848
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2848]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2856
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2856]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2864
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2864]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2872
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2872]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2880
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2880]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2888
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2888]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2896
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2896]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2904
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2904]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2912
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2912]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2920
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2920]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2928
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2928]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2936
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2936]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2944
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2944]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2952
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2952]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2960
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2960]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2968
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2968]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2976
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2976]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2984
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2984]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+2992
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+2992]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3000
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3000]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3008
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3008]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3016
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3016]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3024
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3024]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3032
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3032]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3040
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3040]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3048
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3048]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3056
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3056]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3064
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3064]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3072
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3072]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3080
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3080]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3088
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3088]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3096
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3096]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3104
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3104]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3112
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3112]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3120
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3120]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3128
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3128]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3136
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3136]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3144
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3144]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3152
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3152]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3160
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3160]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3168
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3168]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3176
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3176]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3184
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3184]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3192
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3192]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3200
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3200]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3208
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3208]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3216
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3216]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3224
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3224]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3232
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3232]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3240
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3240]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3248
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3248]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3256
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3256]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3264
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3264]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3272
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3272]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3280
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3280]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3288
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3288]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3296
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3296]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3304
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3304]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3312
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3312]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3320
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3320]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3328
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3328]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3336
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3336]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3344
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3344]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libcairo_so_tramp_table+3352
  ldr ip0, [ip0, #:lo12:_libcairo_so_tramp_table+3352]
 
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
  bl _libcairo_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

