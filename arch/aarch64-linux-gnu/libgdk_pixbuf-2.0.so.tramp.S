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

  bl _libgdk_pixbuf_2_0_so_tramp_resolve
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

  .globl gdk_colorspace_get_type
  .p2align 4
  .type gdk_colorspace_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden gdk_colorspace_get_type
#endif
gdk_colorspace_get_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+0]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+8]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+16]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+24]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+32]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+40]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+48]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+56]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+64]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+72]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+80]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+88]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+96]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+104]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+112]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+120]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+128]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+136]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+144]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+152]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+160]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+168]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+176]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+184]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+192]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+200]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+208]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+216]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+224]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+232]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+240]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+248]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+256]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+264]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+272]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+280]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+288]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+296]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+304]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+312]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+320]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+328]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+336]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+344]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+352]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+360]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+368]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+376]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+384]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+392]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+400]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+408]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+416]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+424]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+432]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+440]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+448]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+456]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+464]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+472]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+480]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+488]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+496]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+504]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+512]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+520]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+528]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+536]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+544]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+552]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+560]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+568]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+576]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+584]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+592]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+600]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+608]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+616]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+624]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+632]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+640]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+648]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+656]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+664]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+672]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+680]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+688]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+696]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+704]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+712]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+720]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+728]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+736]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+744]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+752]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+760]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+768]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+776]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+784]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+792]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+800]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+808]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+816]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+824]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+832]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+840]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+848]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+856]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+864]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+872]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+880]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+888]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+896]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+904]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+912]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+920]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+928]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+936]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+944]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+952]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+960]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+968]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+976]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+984]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+992]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+1000]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgdk_pixbuf_2_0_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libgdk_pixbuf_2_0_so_tramp_table+1008]
 
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
  bl _libgdk_pixbuf_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

