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

  bl _libgraphene_1_0_so_tramp_resolve
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

  .globl graphene_box_alloc
  .p2align 4
  .type graphene_box_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden graphene_box_alloc
#endif
graphene_box_alloc:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+0]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+8]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+16]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+24]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+32]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+40]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+48]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+56]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+64]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+72]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+80]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+88]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+96]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+104]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+112]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+120]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+128]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+136]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+144]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+152]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+160]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+168]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+176]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+184]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+192]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+200]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+208]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+216]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+224]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+232]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+240]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+248]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+256]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+264]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+272]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+280]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+288]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+296]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+304]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+312]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+320]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+328]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+336]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+344]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+352]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+360]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+368]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+376]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+384]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+392]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+400]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+408]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+416]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+424]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+432]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+440]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+448]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+456]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+464]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+472]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+480]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+488]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+496]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+504]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+512]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+520]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+528]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+536]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+544]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+552]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+560]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+568]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+576]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+584]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+592]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+600]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+608]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+616]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+624]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+632]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+640]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+648]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+656]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+664]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+672]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+680]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+688]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+696]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+704]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+712]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+720]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+728]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+736]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+744]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+752]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+760]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+768]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+776]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+784]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+792]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+800]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+808]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+816]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+824]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+832]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+840]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+848]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+856]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+864]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+872]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+880]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+888]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+896]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+904]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+912]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+920]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+928]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+936]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+944]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+952]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+960]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+968]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+976]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+984]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+992]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1000]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1008]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1016
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1016]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1024
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1024]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1032
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1032]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1040
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1040]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1048
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1048]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1056
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1056]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1064
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1064]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1072
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1072]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1080
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1080]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1088
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1088]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1096
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1096]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1104
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1104]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1112
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1112]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1120
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1120]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1128
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1128]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1136
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1136]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1144
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1144]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1152
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1152]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1160
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1160]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1168
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1168]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1176
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1176]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1184
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1184]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1192
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1192]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1200
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1200]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1208
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1208]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1216
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1216]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1224
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1224]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1232
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1232]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1240
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1240]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1248
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1248]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1256
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1256]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1264
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1264]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1272
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1272]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1280
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1280]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1288
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1288]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1296
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1296]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1304
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1304]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1312
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1312]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1320
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1320]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1328
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1328]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1336
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1336]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1344
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1344]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1352
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1352]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1360
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1360]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1368
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1368]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1376
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1376]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1384
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1384]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1392
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1392]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1400
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1400]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1408
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1408]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1416
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1416]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1424
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1424]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1432
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1432]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1440
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1440]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1448
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1448]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1456
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1456]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1464
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1464]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1472
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1472]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1480
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1480]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1488
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1488]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1496
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1496]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1504
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1504]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1512
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1512]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1520
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1520]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1528
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1528]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1536
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1536]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1544
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1544]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1552
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1552]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1560
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1560]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1568
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1568]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1576
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1576]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1584
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1584]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1592
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1592]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1600
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1600]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1608
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1608]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1616
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1616]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1624
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1624]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1632
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1632]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1640
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1640]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1648
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1648]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1656
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1656]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1664
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1664]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1672
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1672]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1680
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1680]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1688
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1688]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1696
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1696]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1704
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1704]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1712
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1712]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1720
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1720]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1728
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1728]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1736
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1736]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1744
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1744]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1752
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1752]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1760
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1760]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1768
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1768]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1776
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1776]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1784
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1784]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1792
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1792]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1800
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1800]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1808
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1808]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1816
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1816]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1824
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1824]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1832
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1832]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1840
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1840]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1848
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1848]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1856
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1856]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1864
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1864]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1872
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1872]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1880
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1880]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1888
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1888]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1896
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1896]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1904
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1904]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1912
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1912]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1920
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1920]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1928
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1928]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1936
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1936]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1944
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1944]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1952
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1952]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1960
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1960]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1968
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1968]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1976
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1976]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1984
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1984]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+1992
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+1992]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2000
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2000]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2008
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2008]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2016
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2016]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2024
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2024]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2032
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2032]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2040
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2040]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2048
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2048]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2056
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2056]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2064
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2064]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2072
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2072]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2080
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2080]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2088
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2088]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2096
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2096]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2104
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2104]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2112
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2112]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2120
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2120]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2128
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2128]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2136
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2136]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2144
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2144]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2152
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2152]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2160
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2160]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2168
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2168]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2176
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2176]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2184
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2184]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2192
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2192]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2200
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2200]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2208
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2208]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2216
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2216]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2224
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2224]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2232
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2232]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2240
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2240]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2248
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2248]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2256
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2256]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2264
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2264]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2272
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2272]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2280
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2280]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2288
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2288]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2296
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2296]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2304
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2304]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2312
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2312]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2320
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2320]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2328
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2328]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2336
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2336]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2344
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2344]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2352
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2352]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2360
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2360]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2368
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2368]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2376
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2376]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2384
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2384]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2392
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2392]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2400
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2400]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2408
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2408]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2416
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2416]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2424
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2424]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2432
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2432]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2440
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2440]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2448
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2448]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2456
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2456]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2464
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2464]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2472
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2472]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2480
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2480]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2488
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2488]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2496
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2496]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2504
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2504]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2512
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2512]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2520
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2520]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2528
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2528]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2536
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2536]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2544
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2544]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2552
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2552]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2560
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2560]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2568
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2568]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2576
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2576]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2584
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2584]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2592
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2592]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2600
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2600]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2608
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2608]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2616
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2616]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2624
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2624]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2632
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2632]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2640
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2640]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2648
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2648]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2656
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2656]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2664
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2664]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2672
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2672]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2680
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2680]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2688
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2688]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2696
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2696]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2704
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2704]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2712
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2712]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2720
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2720]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2728
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2728]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2736
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2736]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2744
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2744]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2752
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2752]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2760
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2760]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2768
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2768]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2776
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2776]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2784
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2784]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2792
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2792]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2800
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2800]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2808
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2808]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2816
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2816]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2824
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2824]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2832
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2832]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2840
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2840]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2848
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2848]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2856
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2856]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2864
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2864]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2872
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2872]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2880
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2880]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2888
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2888]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2896
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2896]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2904
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2904]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2912
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2912]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2920
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2920]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2928
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2928]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2936
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2936]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2944
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2944]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2952
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2952]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2960
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2960]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2968
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2968]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2976
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2976]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2984
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2984]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+2992
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+2992]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3000
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3000]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3008
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3008]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3016
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3016]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3024
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3024]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3032
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3032]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3040
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3040]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3048
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3048]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3056
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3056]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3064
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3064]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3072
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3072]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3080
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3080]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3088
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3088]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3096
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3096]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3104
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3104]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3112
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3112]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3120
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3120]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3128
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3128]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3136
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3136]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3144
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3144]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3152
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3152]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3160
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3160]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3168
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3168]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3176
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3176]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3184
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3184]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3192
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3192]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3200
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3200]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3208
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3208]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3216
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3216]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3224
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3224]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3232
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3232]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3240
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3240]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3248
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3248]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3256
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3256]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3264
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3264]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3272
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3272]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3280
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3280]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3288
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3288]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3296
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3296]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3304
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3304]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3312
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3312]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3320
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3320]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3328
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3328]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3336
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3336]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3344
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3344]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3352
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3352]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3360
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3360]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3368
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3368]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3376
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3376]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3384
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3384]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3392
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3392]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3400
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3400]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3408
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3408]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3416
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3416]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3424
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3424]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3432
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3432]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3440
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3440]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3448
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3448]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3456
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3456]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3464
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3464]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3472
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3472]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3480
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3480]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3488
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3488]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3496
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3496]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3504
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3504]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3512
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3512]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3520
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3520]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3528
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3528]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3536
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3536]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3544
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3544]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3552
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3552]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3560
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3560]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3568
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3568]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3576
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3576]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgraphene_1_0_so_tramp_table+3584
  ldr ip0, [ip0, #:lo12:_libgraphene_1_0_so_tramp_table+3584]
 
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
  bl _libgraphene_1_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

