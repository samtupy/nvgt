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

  bl _libgobject_2_0_so_tramp_resolve
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

  .globl g_array_get_type
  .p2align 4
  .type g_array_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden g_array_get_type
#endif
g_array_get_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+0]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+8]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+16]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+24]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+32]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+40]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+48]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+56]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+64]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+72]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+80]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+88]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+96]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+104]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+112]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+120]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+128]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+136]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+144]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+152]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+160]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+168]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+176]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+184]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+192]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+200]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+208]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+216]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+224]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+232]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+240]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+248]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+256]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+264]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+272]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+280]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+288]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+296]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+304]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+312]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+320]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+328]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+336]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+344]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+352]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+360]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+368]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+376]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+384]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+392]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+400]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+408]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+416]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+424]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+432]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+440]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+448]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+456]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+464]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+472]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+480]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+488]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+496]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+504]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+512]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+520]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+528]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+536]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+544]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+552]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+560]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+568]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+576]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+584]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+592]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+600]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+608]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+616]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+624]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+632]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+640]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+648]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+656]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+664]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+672]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+680]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+688]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+696]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+704]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+712]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+720]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+728]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+736]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+744]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+752]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+760]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+768]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+776]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+784]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+792]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+800]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+808]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+816]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+824]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+832]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+840]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+848]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+856]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+864]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+872]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+880]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+888]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+896]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+904]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+912]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+920]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+928]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+936]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+944]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+952]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+960]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+968]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+976]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+984]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+992]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1000]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1008]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1016
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1016]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1024
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1024]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1032
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1032]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1040
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1040]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1048
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1048]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1056
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1056]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1064
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1064]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1072
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1072]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1080
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1080]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1088
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1088]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1096
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1096]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1104
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1104]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1112
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1112]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1120
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1120]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1128
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1128]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1136
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1136]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1144
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1144]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1152
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1152]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1160
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1160]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1168
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1168]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1176
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1176]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1184
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1184]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1192
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1192]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1200
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1200]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1208
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1208]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1216
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1216]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1224
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1224]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1232
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1232]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1240
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1240]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1248
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1248]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1256
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1256]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1264
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1264]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1272
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1272]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1280
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1280]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1288
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1288]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1296
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1296]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1304
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1304]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1312
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1312]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1320
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1320]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1328
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1328]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1336
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1336]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1344
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1344]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1352
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1352]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1360
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1360]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1368
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1368]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1376
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1376]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1384
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1384]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1392
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1392]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1400
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1400]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1408
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1408]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1416
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1416]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1424
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1424]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1432
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1432]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1440
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1440]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1448
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1448]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1456
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1456]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1464
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1464]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1472
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1472]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1480
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1480]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1488
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1488]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1496
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1496]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1504
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1504]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1512
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1512]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1520
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1520]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1528
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1528]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1536
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1536]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1544
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1544]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1552
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1552]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1560
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1560]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1568
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1568]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1576
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1576]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1584
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1584]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1592
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1592]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1600
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1600]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1608
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1608]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1616
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1616]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1624
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1624]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1632
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1632]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1640
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1640]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1648
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1648]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1656
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1656]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1664
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1664]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1672
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1672]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1680
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1680]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1688
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1688]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1696
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1696]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1704
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1704]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1712
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1712]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1720
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1720]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1728
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1728]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1736
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1736]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1744
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1744]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1752
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1752]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1760
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1760]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1768
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1768]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1776
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1776]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1784
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1784]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1792
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1792]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1800
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1800]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1808
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1808]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1816
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1816]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1824
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1824]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1832
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1832]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1840
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1840]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1848
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1848]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1856
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1856]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1864
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1864]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1872
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1872]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1880
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1880]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1888
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1888]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1896
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1896]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1904
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1904]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1912
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1912]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1920
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1920]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1928
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1928]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1936
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1936]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1944
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1944]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1952
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1952]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1960
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1960]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1968
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1968]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1976
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1976]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1984
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1984]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+1992
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+1992]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2000
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2000]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2008
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2008]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2016
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2016]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2024
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2024]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2032
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2032]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2040
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2040]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2048
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2048]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2056
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2056]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2064
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2064]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2072
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2072]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2080
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2080]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2088
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2088]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2096
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2096]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2104
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2104]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2112
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2112]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2120
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2120]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2128
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2128]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2136
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2136]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2144
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2144]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2152
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2152]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2160
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2160]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2168
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2168]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2176
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2176]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2184
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2184]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2192
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2192]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2200
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2200]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2208
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2208]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2216
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2216]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2224
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2224]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2232
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2232]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2240
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2240]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2248
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2248]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2256
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2256]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2264
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2264]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2272
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2272]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2280
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2280]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2288
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2288]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2296
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2296]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2304
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2304]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2312
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2312]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2320
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2320]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2328
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2328]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2336
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2336]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2344
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2344]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2352
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2352]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2360
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2360]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2368
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2368]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2376
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2376]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2384
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2384]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2392
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2392]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2400
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2400]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2408
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2408]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2416
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2416]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2424
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2424]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2432
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2432]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2440
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2440]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2448
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2448]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2456
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2456]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2464
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2464]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2472
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2472]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2480
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2480]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2488
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2488]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2496
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2496]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2504
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2504]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2512
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2512]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2520
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2520]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2528
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2528]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2536
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2536]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2544
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2544]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2552
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2552]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2560
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2560]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2568
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2568]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2576
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2576]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2584
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2584]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2592
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2592]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2600
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2600]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2608
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2608]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2616
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2616]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2624
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2624]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2632
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2632]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2640
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2640]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2648
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2648]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2656
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2656]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2664
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2664]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2672
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2672]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2680
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2680]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2688
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2688]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2696
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2696]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2704
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2704]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2712
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2712]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2720
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2720]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2728
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2728]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2736
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2736]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2744
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2744]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2752
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2752]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2760
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2760]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2768
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2768]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2776
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2776]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2784
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2784]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2792
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2792]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2800
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2800]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2808
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2808]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2816
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2816]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2824
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2824]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2832
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2832]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2840
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2840]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2848
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2848]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2856
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2856]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2864
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2864]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2872
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2872]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2880
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2880]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2888
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2888]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2896
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2896]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2904
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2904]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2912
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2912]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2920
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2920]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2928
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2928]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2936
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2936]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2944
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2944]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2952
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2952]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2960
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2960]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2968
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2968]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2976
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2976]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2984
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2984]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+2992
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+2992]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3000
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3000]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3008
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3008]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3016
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3016]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3024
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3024]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3032
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3032]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3040
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3040]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3048
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3048]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3056
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3056]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3064
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3064]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3072
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3072]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3080
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3080]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3088
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3088]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3096
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3096]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3104
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3104]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3112
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3112]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3120
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3120]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3128
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3128]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3136
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3136]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3144
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3144]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3152
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3152]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3160
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3160]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3168
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3168]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3176
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3176]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3184
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3184]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3192
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3192]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3200
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3200]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3208
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3208]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3216
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3216]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3224
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3224]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3232
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3232]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3240
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3240]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3248
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3248]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3256
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3256]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3264
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3264]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3272
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3272]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3280
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3280]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3288
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3288]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3296
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3296]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3304
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3304]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3312
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3312]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3320
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3320]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3328
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3328]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3336
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3336]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3344
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3344]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3352
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3352]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3360
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3360]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3368
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3368]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3376
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3376]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3384
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3384]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3392
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3392]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3400
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3400]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3408
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3408]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3416
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3416]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3424
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3424]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3432
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3432]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3440
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3440]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3448
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3448]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3456
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3456]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3464
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3464]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3472
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3472]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3480
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3480]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3488
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3488]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3496
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3496]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3504
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3504]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3512
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3512]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3520
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3520]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3528
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3528]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3536
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3536]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3544
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3544]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3552
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3552]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3560
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3560]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3568
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3568]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3576
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3576]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3584
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3584]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3592
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3592]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3600
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3600]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3608
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3608]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3616
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3616]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3624
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3624]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3632
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3632]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3640
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3640]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3648
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3648]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3656
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3656]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3664
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3664]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3672
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3672]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3680
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3680]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3688
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3688]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3696
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3696]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3704
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3704]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3712
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3712]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3720
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3720]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3728
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3728]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3736
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3736]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3744
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3744]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3752
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3752]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3760
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3760]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3768
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3768]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3776
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3776]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3784
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3784]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3792
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3792]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3800
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3800]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3808
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3808]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3816
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3816]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
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

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libgobject_2_0_so_tramp_table+3824
  ldr ip0, [ip0, #:lo12:_libgobject_2_0_so_tramp_table+3824]
 
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

