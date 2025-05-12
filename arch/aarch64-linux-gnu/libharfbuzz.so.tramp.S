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

  .globl _libharfbuzz_so_tramp_table
  .hidden _libharfbuzz_so_tramp_table
  .align 8
_libharfbuzz_so_tramp_table:
  .zero 4240

  .text

  .globl _libharfbuzz_so_tramp_resolve
  .hidden _libharfbuzz_so_tramp_resolve

  .globl _libharfbuzz_so_save_regs_and_resolve
  .hidden _libharfbuzz_so_save_regs_and_resolve
  .type _libharfbuzz_so_save_regs_and_resolve, %function
_libharfbuzz_so_save_regs_and_resolve:
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

  bl _libharfbuzz_so_tramp_resolve
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

  .globl hb_aat_layout_feature_type_get_name_id
  .p2align 4
  .type hb_aat_layout_feature_type_get_name_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_feature_type_get_name_id
#endif
hb_aat_layout_feature_type_get_name_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+0]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_aat_layout_feature_type_get_selector_infos
  .p2align 4
  .type hb_aat_layout_feature_type_get_selector_infos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_feature_type_get_selector_infos
#endif
hb_aat_layout_feature_type_get_selector_infos:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+8]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_aat_layout_get_feature_types
  .p2align 4
  .type hb_aat_layout_get_feature_types, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_get_feature_types
#endif
hb_aat_layout_get_feature_types:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+16]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_aat_layout_has_positioning
  .p2align 4
  .type hb_aat_layout_has_positioning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_has_positioning
#endif
hb_aat_layout_has_positioning:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+24]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_aat_layout_has_substitution
  .p2align 4
  .type hb_aat_layout_has_substitution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_has_substitution
#endif
hb_aat_layout_has_substitution:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+32]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_aat_layout_has_tracking
  .p2align 4
  .type hb_aat_layout_has_tracking, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_aat_layout_has_tracking
#endif
hb_aat_layout_has_tracking:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+40]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_copy_writable_or_fail
  .p2align 4
  .type hb_blob_copy_writable_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_copy_writable_or_fail
#endif
hb_blob_copy_writable_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+48]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_create
  .p2align 4
  .type hb_blob_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_create
#endif
hb_blob_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+56]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_create_from_file
  .p2align 4
  .type hb_blob_create_from_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_create_from_file
#endif
hb_blob_create_from_file:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+64]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_create_from_file_or_fail
  .p2align 4
  .type hb_blob_create_from_file_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_create_from_file_or_fail
#endif
hb_blob_create_from_file_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+72]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_create_or_fail
  .p2align 4
  .type hb_blob_create_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_create_or_fail
#endif
hb_blob_create_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+80]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_create_sub_blob
  .p2align 4
  .type hb_blob_create_sub_blob, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_create_sub_blob
#endif
hb_blob_create_sub_blob:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+88]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_destroy
  .p2align 4
  .type hb_blob_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_destroy
#endif
hb_blob_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+96]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_get_data
  .p2align 4
  .type hb_blob_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_get_data
#endif
hb_blob_get_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+104]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_get_data_writable
  .p2align 4
  .type hb_blob_get_data_writable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_get_data_writable
#endif
hb_blob_get_data_writable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+112]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_get_empty
  .p2align 4
  .type hb_blob_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_get_empty
#endif
hb_blob_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+120]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_get_length
  .p2align 4
  .type hb_blob_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_get_length
#endif
hb_blob_get_length:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+128]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_get_user_data
  .p2align 4
  .type hb_blob_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_get_user_data
#endif
hb_blob_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+136]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_is_immutable
  .p2align 4
  .type hb_blob_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_is_immutable
#endif
hb_blob_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+144]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_make_immutable
  .p2align 4
  .type hb_blob_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_make_immutable
#endif
hb_blob_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+152]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_reference
  .p2align 4
  .type hb_blob_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_reference
#endif
hb_blob_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+160]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_blob_set_user_data
  .p2align 4
  .type hb_blob_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_blob_set_user_data
#endif
hb_blob_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+168]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add
  .p2align 4
  .type hb_buffer_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add
#endif
hb_buffer_add:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+176]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add_codepoints
  .p2align 4
  .type hb_buffer_add_codepoints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add_codepoints
#endif
hb_buffer_add_codepoints:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+184]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add_latin1
  .p2align 4
  .type hb_buffer_add_latin1, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add_latin1
#endif
hb_buffer_add_latin1:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+192]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add_utf16
  .p2align 4
  .type hb_buffer_add_utf16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add_utf16
#endif
hb_buffer_add_utf16:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+200]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add_utf32
  .p2align 4
  .type hb_buffer_add_utf32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add_utf32
#endif
hb_buffer_add_utf32:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+208]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_add_utf8
  .p2align 4
  .type hb_buffer_add_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_add_utf8
#endif
hb_buffer_add_utf8:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+216]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_allocation_successful
  .p2align 4
  .type hb_buffer_allocation_successful, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_allocation_successful
#endif
hb_buffer_allocation_successful:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+224]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_append
  .p2align 4
  .type hb_buffer_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_append
#endif
hb_buffer_append:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+232]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_clear_contents
  .p2align 4
  .type hb_buffer_clear_contents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_clear_contents
#endif
hb_buffer_clear_contents:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+240]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_create
  .p2align 4
  .type hb_buffer_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_create
#endif
hb_buffer_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+248]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_create_similar
  .p2align 4
  .type hb_buffer_create_similar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_create_similar
#endif
hb_buffer_create_similar:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+256]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_deserialize_glyphs
  .p2align 4
  .type hb_buffer_deserialize_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_deserialize_glyphs
#endif
hb_buffer_deserialize_glyphs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+264]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_deserialize_unicode
  .p2align 4
  .type hb_buffer_deserialize_unicode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_deserialize_unicode
#endif
hb_buffer_deserialize_unicode:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+272]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_destroy
  .p2align 4
  .type hb_buffer_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_destroy
#endif
hb_buffer_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+280]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_diff
  .p2align 4
  .type hb_buffer_diff, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_diff
#endif
hb_buffer_diff:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+288]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_cluster_level
  .p2align 4
  .type hb_buffer_get_cluster_level, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_cluster_level
#endif
hb_buffer_get_cluster_level:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+296]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_content_type
  .p2align 4
  .type hb_buffer_get_content_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_content_type
#endif
hb_buffer_get_content_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+304]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_direction
  .p2align 4
  .type hb_buffer_get_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_direction
#endif
hb_buffer_get_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+312]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_empty
  .p2align 4
  .type hb_buffer_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_empty
#endif
hb_buffer_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+320]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_flags
  .p2align 4
  .type hb_buffer_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_flags
#endif
hb_buffer_get_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+328]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_glyph_infos
  .p2align 4
  .type hb_buffer_get_glyph_infos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_glyph_infos
#endif
hb_buffer_get_glyph_infos:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+336]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_glyph_positions
  .p2align 4
  .type hb_buffer_get_glyph_positions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_glyph_positions
#endif
hb_buffer_get_glyph_positions:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+344]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_invisible_glyph
  .p2align 4
  .type hb_buffer_get_invisible_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_invisible_glyph
#endif
hb_buffer_get_invisible_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+352]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_language
  .p2align 4
  .type hb_buffer_get_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_language
#endif
hb_buffer_get_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+360]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_length
  .p2align 4
  .type hb_buffer_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_length
#endif
hb_buffer_get_length:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+368]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_not_found_glyph
  .p2align 4
  .type hb_buffer_get_not_found_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_not_found_glyph
#endif
hb_buffer_get_not_found_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+376]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_not_found_variation_selector_glyph
  .p2align 4
  .type hb_buffer_get_not_found_variation_selector_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_not_found_variation_selector_glyph
#endif
hb_buffer_get_not_found_variation_selector_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+384]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_random_state
  .p2align 4
  .type hb_buffer_get_random_state, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_random_state
#endif
hb_buffer_get_random_state:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+392]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_replacement_codepoint
  .p2align 4
  .type hb_buffer_get_replacement_codepoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_replacement_codepoint
#endif
hb_buffer_get_replacement_codepoint:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+400]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_script
  .p2align 4
  .type hb_buffer_get_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_script
#endif
hb_buffer_get_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+408]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_segment_properties
  .p2align 4
  .type hb_buffer_get_segment_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_segment_properties
#endif
hb_buffer_get_segment_properties:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+416]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_unicode_funcs
  .p2align 4
  .type hb_buffer_get_unicode_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_unicode_funcs
#endif
hb_buffer_get_unicode_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+424]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_get_user_data
  .p2align 4
  .type hb_buffer_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_get_user_data
#endif
hb_buffer_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+432]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_guess_segment_properties
  .p2align 4
  .type hb_buffer_guess_segment_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_guess_segment_properties
#endif
hb_buffer_guess_segment_properties:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+440]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_has_positions
  .p2align 4
  .type hb_buffer_has_positions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_has_positions
#endif
hb_buffer_has_positions:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+448]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_normalize_glyphs
  .p2align 4
  .type hb_buffer_normalize_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_normalize_glyphs
#endif
hb_buffer_normalize_glyphs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+456]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_pre_allocate
  .p2align 4
  .type hb_buffer_pre_allocate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_pre_allocate
#endif
hb_buffer_pre_allocate:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+464]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_reference
  .p2align 4
  .type hb_buffer_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_reference
#endif
hb_buffer_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+472]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_reset
  .p2align 4
  .type hb_buffer_reset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_reset
#endif
hb_buffer_reset:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+480]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_reverse
  .p2align 4
  .type hb_buffer_reverse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_reverse
#endif
hb_buffer_reverse:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+488]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_reverse_clusters
  .p2align 4
  .type hb_buffer_reverse_clusters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_reverse_clusters
#endif
hb_buffer_reverse_clusters:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+496]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_reverse_range
  .p2align 4
  .type hb_buffer_reverse_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_reverse_range
#endif
hb_buffer_reverse_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+504]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize
  .p2align 4
  .type hb_buffer_serialize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize
#endif
hb_buffer_serialize:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+512]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize_format_from_string
  .p2align 4
  .type hb_buffer_serialize_format_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize_format_from_string
#endif
hb_buffer_serialize_format_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+520]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize_format_to_string
  .p2align 4
  .type hb_buffer_serialize_format_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize_format_to_string
#endif
hb_buffer_serialize_format_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+528]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize_glyphs
  .p2align 4
  .type hb_buffer_serialize_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize_glyphs
#endif
hb_buffer_serialize_glyphs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+536]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize_list_formats
  .p2align 4
  .type hb_buffer_serialize_list_formats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize_list_formats
#endif
hb_buffer_serialize_list_formats:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+544]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_serialize_unicode
  .p2align 4
  .type hb_buffer_serialize_unicode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_serialize_unicode
#endif
hb_buffer_serialize_unicode:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+552]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_cluster_level
  .p2align 4
  .type hb_buffer_set_cluster_level, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_cluster_level
#endif
hb_buffer_set_cluster_level:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+560]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_content_type
  .p2align 4
  .type hb_buffer_set_content_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_content_type
#endif
hb_buffer_set_content_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+568]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_direction
  .p2align 4
  .type hb_buffer_set_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_direction
#endif
hb_buffer_set_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+576]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_flags
  .p2align 4
  .type hb_buffer_set_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_flags
#endif
hb_buffer_set_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+584]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_invisible_glyph
  .p2align 4
  .type hb_buffer_set_invisible_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_invisible_glyph
#endif
hb_buffer_set_invisible_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+592]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_language
  .p2align 4
  .type hb_buffer_set_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_language
#endif
hb_buffer_set_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+600]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_length
  .p2align 4
  .type hb_buffer_set_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_length
#endif
hb_buffer_set_length:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+608]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_message_func
  .p2align 4
  .type hb_buffer_set_message_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_message_func
#endif
hb_buffer_set_message_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+616]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_not_found_glyph
  .p2align 4
  .type hb_buffer_set_not_found_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_not_found_glyph
#endif
hb_buffer_set_not_found_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+624]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_not_found_variation_selector_glyph
  .p2align 4
  .type hb_buffer_set_not_found_variation_selector_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_not_found_variation_selector_glyph
#endif
hb_buffer_set_not_found_variation_selector_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+632]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_random_state
  .p2align 4
  .type hb_buffer_set_random_state, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_random_state
#endif
hb_buffer_set_random_state:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+640]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_replacement_codepoint
  .p2align 4
  .type hb_buffer_set_replacement_codepoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_replacement_codepoint
#endif
hb_buffer_set_replacement_codepoint:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+648]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_script
  .p2align 4
  .type hb_buffer_set_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_script
#endif
hb_buffer_set_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+656]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_segment_properties
  .p2align 4
  .type hb_buffer_set_segment_properties, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_segment_properties
#endif
hb_buffer_set_segment_properties:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+664]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_unicode_funcs
  .p2align 4
  .type hb_buffer_set_unicode_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_unicode_funcs
#endif
hb_buffer_set_unicode_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+672]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_buffer_set_user_data
  .p2align 4
  .type hb_buffer_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_buffer_set_user_data
#endif
hb_buffer_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+680]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_calloc
  .p2align 4
  .type hb_calloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_calloc
#endif
hb_calloc:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+688
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+688]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_get_alpha
  .p2align 4
  .type hb_color_get_alpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_get_alpha
#endif
hb_color_get_alpha:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+696
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+696]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_get_blue
  .p2align 4
  .type hb_color_get_blue, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_get_blue
#endif
hb_color_get_blue:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+704
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+704]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_get_green
  .p2align 4
  .type hb_color_get_green, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_get_green
#endif
hb_color_get_green:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+712
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+712]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_get_red
  .p2align 4
  .type hb_color_get_red, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_get_red
#endif
hb_color_get_red:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+720
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+720]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_line_get_color_stops
  .p2align 4
  .type hb_color_line_get_color_stops, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_line_get_color_stops
#endif
hb_color_line_get_color_stops:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+728
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+728]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_color_line_get_extend
  .p2align 4
  .type hb_color_line_get_extend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_color_line_get_extend
#endif
hb_color_line_get_extend:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+736
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+736]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_direction_from_string
  .p2align 4
  .type hb_direction_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_direction_from_string
#endif
hb_direction_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+744
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+744]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_direction_to_string
  .p2align 4
  .type hb_direction_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_direction_to_string
#endif
hb_direction_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+752
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+752]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_close_path
  .p2align 4
  .type hb_draw_close_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_close_path
#endif
hb_draw_close_path:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+760
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+760]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_cubic_to
  .p2align 4
  .type hb_draw_cubic_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_cubic_to
#endif
hb_draw_cubic_to:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+768
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+768]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_create
  .p2align 4
  .type hb_draw_funcs_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_create
#endif
hb_draw_funcs_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+776
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+776]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_destroy
  .p2align 4
  .type hb_draw_funcs_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_destroy
#endif
hb_draw_funcs_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+784
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+784]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_get_empty
  .p2align 4
  .type hb_draw_funcs_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_get_empty
#endif
hb_draw_funcs_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+792
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+792]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_get_user_data
  .p2align 4
  .type hb_draw_funcs_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_get_user_data
#endif
hb_draw_funcs_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+800
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+800]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_is_immutable
  .p2align 4
  .type hb_draw_funcs_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_is_immutable
#endif
hb_draw_funcs_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+808
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+808]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_make_immutable
  .p2align 4
  .type hb_draw_funcs_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_make_immutable
#endif
hb_draw_funcs_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+816
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+816]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_reference
  .p2align 4
  .type hb_draw_funcs_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_reference
#endif
hb_draw_funcs_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+824
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+824]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_close_path_func
  .p2align 4
  .type hb_draw_funcs_set_close_path_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_close_path_func
#endif
hb_draw_funcs_set_close_path_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+832
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+832]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_cubic_to_func
  .p2align 4
  .type hb_draw_funcs_set_cubic_to_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_cubic_to_func
#endif
hb_draw_funcs_set_cubic_to_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+840
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+840]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_line_to_func
  .p2align 4
  .type hb_draw_funcs_set_line_to_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_line_to_func
#endif
hb_draw_funcs_set_line_to_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+848
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+848]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_move_to_func
  .p2align 4
  .type hb_draw_funcs_set_move_to_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_move_to_func
#endif
hb_draw_funcs_set_move_to_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+856
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+856]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_quadratic_to_func
  .p2align 4
  .type hb_draw_funcs_set_quadratic_to_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_quadratic_to_func
#endif
hb_draw_funcs_set_quadratic_to_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+864
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+864]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_funcs_set_user_data
  .p2align 4
  .type hb_draw_funcs_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_funcs_set_user_data
#endif
hb_draw_funcs_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+872
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+872]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_line_to
  .p2align 4
  .type hb_draw_line_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_line_to
#endif
hb_draw_line_to:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+880
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+880]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_move_to
  .p2align 4
  .type hb_draw_move_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_move_to
#endif
hb_draw_move_to:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+888
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+888]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_draw_quadratic_to
  .p2align 4
  .type hb_draw_quadratic_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_draw_quadratic_to
#endif
hb_draw_quadratic_to:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+896
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+896]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_builder_add_table
  .p2align 4
  .type hb_face_builder_add_table, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_builder_add_table
#endif
hb_face_builder_add_table:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+904
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+904]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_builder_create
  .p2align 4
  .type hb_face_builder_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_builder_create
#endif
hb_face_builder_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+912
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+912]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_builder_sort_tables
  .p2align 4
  .type hb_face_builder_sort_tables, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_builder_sort_tables
#endif
hb_face_builder_sort_tables:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+920
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+920]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_collect_nominal_glyph_mapping
  .p2align 4
  .type hb_face_collect_nominal_glyph_mapping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_collect_nominal_glyph_mapping
#endif
hb_face_collect_nominal_glyph_mapping:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+928
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+928]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_collect_unicodes
  .p2align 4
  .type hb_face_collect_unicodes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_collect_unicodes
#endif
hb_face_collect_unicodes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+936
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+936]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_collect_variation_selectors
  .p2align 4
  .type hb_face_collect_variation_selectors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_collect_variation_selectors
#endif
hb_face_collect_variation_selectors:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+944
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+944]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_collect_variation_unicodes
  .p2align 4
  .type hb_face_collect_variation_unicodes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_collect_variation_unicodes
#endif
hb_face_collect_variation_unicodes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+952
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+952]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_count
  .p2align 4
  .type hb_face_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_count
#endif
hb_face_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+960
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+960]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create
  .p2align 4
  .type hb_face_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create
#endif
hb_face_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+968
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+968]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create_for_tables
  .p2align 4
  .type hb_face_create_for_tables, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create_for_tables
#endif
hb_face_create_for_tables:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+976
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+976]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create_from_file_or_fail
  .p2align 4
  .type hb_face_create_from_file_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create_from_file_or_fail
#endif
hb_face_create_from_file_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+984
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+984]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create_from_file_or_fail_using
  .p2align 4
  .type hb_face_create_from_file_or_fail_using, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create_from_file_or_fail_using
#endif
hb_face_create_from_file_or_fail_using:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+992
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+992]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create_or_fail
  .p2align 4
  .type hb_face_create_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create_or_fail
#endif
hb_face_create_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1000
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1000]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_create_or_fail_using
  .p2align 4
  .type hb_face_create_or_fail_using, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_create_or_fail_using
#endif
hb_face_create_or_fail_using:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1008
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1008]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_destroy
  .p2align 4
  .type hb_face_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_destroy
#endif
hb_face_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1016
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1016]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_empty
  .p2align 4
  .type hb_face_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_empty
#endif
hb_face_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1024
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1024]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_glyph_count
  .p2align 4
  .type hb_face_get_glyph_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_glyph_count
#endif
hb_face_get_glyph_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1032
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1032]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_index
  .p2align 4
  .type hb_face_get_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_index
#endif
hb_face_get_index:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1040
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1040]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_table_tags
  .p2align 4
  .type hb_face_get_table_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_table_tags
#endif
hb_face_get_table_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1048
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1048]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_upem
  .p2align 4
  .type hb_face_get_upem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_upem
#endif
hb_face_get_upem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1056
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1056]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_get_user_data
  .p2align 4
  .type hb_face_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_get_user_data
#endif
hb_face_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1064
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1064]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_is_immutable
  .p2align 4
  .type hb_face_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_is_immutable
#endif
hb_face_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1072
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1072]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_list_loaders
  .p2align 4
  .type hb_face_list_loaders, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_list_loaders
#endif
hb_face_list_loaders:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1080
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1080]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_make_immutable
  .p2align 4
  .type hb_face_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_make_immutable
#endif
hb_face_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1088
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1088]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_reference
  .p2align 4
  .type hb_face_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_reference
#endif
hb_face_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1096
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1096]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_reference_blob
  .p2align 4
  .type hb_face_reference_blob, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_reference_blob
#endif
hb_face_reference_blob:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1104
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1104]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_reference_table
  .p2align 4
  .type hb_face_reference_table, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_reference_table
#endif
hb_face_reference_table:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1112
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1112]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_set_get_table_tags_func
  .p2align 4
  .type hb_face_set_get_table_tags_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_set_get_table_tags_func
#endif
hb_face_set_get_table_tags_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1120
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1120]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_set_glyph_count
  .p2align 4
  .type hb_face_set_glyph_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_set_glyph_count
#endif
hb_face_set_glyph_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1128
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1128]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_set_index
  .p2align 4
  .type hb_face_set_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_set_index
#endif
hb_face_set_index:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1136
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1136]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_set_upem
  .p2align 4
  .type hb_face_set_upem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_set_upem
#endif
hb_face_set_upem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1144
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1144]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_face_set_user_data
  .p2align 4
  .type hb_face_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_face_set_user_data
#endif
hb_face_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1152
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1152]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_feature_from_string
  .p2align 4
  .type hb_feature_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_feature_from_string
#endif
hb_feature_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1160
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1160]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_feature_to_string
  .p2align 4
  .type hb_feature_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_feature_to_string
#endif
hb_feature_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1168
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1168]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_add_glyph_origin_for_direction
  .p2align 4
  .type hb_font_add_glyph_origin_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_add_glyph_origin_for_direction
#endif
hb_font_add_glyph_origin_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1176
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1176]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_changed
  .p2align 4
  .type hb_font_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_changed
#endif
hb_font_changed:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1184
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1184]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_create
  .p2align 4
  .type hb_font_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_create
#endif
hb_font_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1192
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1192]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_create_sub_font
  .p2align 4
  .type hb_font_create_sub_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_create_sub_font
#endif
hb_font_create_sub_font:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1200
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1200]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_destroy
  .p2align 4
  .type hb_font_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_destroy
#endif
hb_font_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1208
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1208]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_draw_glyph
  .p2align 4
  .type hb_font_draw_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_draw_glyph
#endif
hb_font_draw_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1216
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1216]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_draw_glyph_or_fail
  .p2align 4
  .type hb_font_draw_glyph_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_draw_glyph_or_fail
#endif
hb_font_draw_glyph_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1224
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1224]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_create
  .p2align 4
  .type hb_font_funcs_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_create
#endif
hb_font_funcs_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1232
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1232]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_destroy
  .p2align 4
  .type hb_font_funcs_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_destroy
#endif
hb_font_funcs_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1240
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1240]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_get_empty
  .p2align 4
  .type hb_font_funcs_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_get_empty
#endif
hb_font_funcs_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1248
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1248]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_get_user_data
  .p2align 4
  .type hb_font_funcs_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_get_user_data
#endif
hb_font_funcs_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1256
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1256]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_is_immutable
  .p2align 4
  .type hb_font_funcs_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_is_immutable
#endif
hb_font_funcs_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1264
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1264]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_make_immutable
  .p2align 4
  .type hb_font_funcs_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_make_immutable
#endif
hb_font_funcs_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1272
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1272]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_reference
  .p2align 4
  .type hb_font_funcs_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_reference
#endif
hb_font_funcs_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1280
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1280]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_draw_glyph_func
  .p2align 4
  .type hb_font_funcs_set_draw_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_draw_glyph_func
#endif
hb_font_funcs_set_draw_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1288
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1288]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_draw_glyph_or_fail_func
  .p2align 4
  .type hb_font_funcs_set_draw_glyph_or_fail_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_draw_glyph_or_fail_func
#endif
hb_font_funcs_set_draw_glyph_or_fail_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1296
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1296]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_font_h_extents_func
  .p2align 4
  .type hb_font_funcs_set_font_h_extents_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_font_h_extents_func
#endif
hb_font_funcs_set_font_h_extents_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1304
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1304]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_font_v_extents_func
  .p2align 4
  .type hb_font_funcs_set_font_v_extents_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_font_v_extents_func
#endif
hb_font_funcs_set_font_v_extents_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1312
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1312]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_contour_point_func
  .p2align 4
  .type hb_font_funcs_set_glyph_contour_point_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_contour_point_func
#endif
hb_font_funcs_set_glyph_contour_point_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1320
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1320]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_extents_func
  .p2align 4
  .type hb_font_funcs_set_glyph_extents_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_extents_func
#endif
hb_font_funcs_set_glyph_extents_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1328
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1328]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_from_name_func
  .p2align 4
  .type hb_font_funcs_set_glyph_from_name_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_from_name_func
#endif
hb_font_funcs_set_glyph_from_name_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1336
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1336]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_func
  .p2align 4
  .type hb_font_funcs_set_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_func
#endif
hb_font_funcs_set_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1344
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1344]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_h_advance_func
  .p2align 4
  .type hb_font_funcs_set_glyph_h_advance_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_h_advance_func
#endif
hb_font_funcs_set_glyph_h_advance_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1352
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1352]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_h_advances_func
  .p2align 4
  .type hb_font_funcs_set_glyph_h_advances_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_h_advances_func
#endif
hb_font_funcs_set_glyph_h_advances_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1360
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1360]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_h_kerning_func
  .p2align 4
  .type hb_font_funcs_set_glyph_h_kerning_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_h_kerning_func
#endif
hb_font_funcs_set_glyph_h_kerning_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1368
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1368]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_h_origin_func
  .p2align 4
  .type hb_font_funcs_set_glyph_h_origin_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_h_origin_func
#endif
hb_font_funcs_set_glyph_h_origin_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1376
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1376]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_name_func
  .p2align 4
  .type hb_font_funcs_set_glyph_name_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_name_func
#endif
hb_font_funcs_set_glyph_name_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1384
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1384]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_shape_func
  .p2align 4
  .type hb_font_funcs_set_glyph_shape_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_shape_func
#endif
hb_font_funcs_set_glyph_shape_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1392
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1392]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_v_advance_func
  .p2align 4
  .type hb_font_funcs_set_glyph_v_advance_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_v_advance_func
#endif
hb_font_funcs_set_glyph_v_advance_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1400
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1400]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_v_advances_func
  .p2align 4
  .type hb_font_funcs_set_glyph_v_advances_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_v_advances_func
#endif
hb_font_funcs_set_glyph_v_advances_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1408
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1408]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_v_kerning_func
  .p2align 4
  .type hb_font_funcs_set_glyph_v_kerning_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_v_kerning_func
#endif
hb_font_funcs_set_glyph_v_kerning_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1416
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1416]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_glyph_v_origin_func
  .p2align 4
  .type hb_font_funcs_set_glyph_v_origin_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_glyph_v_origin_func
#endif
hb_font_funcs_set_glyph_v_origin_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1424
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1424]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_nominal_glyph_func
  .p2align 4
  .type hb_font_funcs_set_nominal_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_nominal_glyph_func
#endif
hb_font_funcs_set_nominal_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1432
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1432]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_nominal_glyphs_func
  .p2align 4
  .type hb_font_funcs_set_nominal_glyphs_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_nominal_glyphs_func
#endif
hb_font_funcs_set_nominal_glyphs_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1440
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1440]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_paint_glyph_func
  .p2align 4
  .type hb_font_funcs_set_paint_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_paint_glyph_func
#endif
hb_font_funcs_set_paint_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1448
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1448]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_paint_glyph_or_fail_func
  .p2align 4
  .type hb_font_funcs_set_paint_glyph_or_fail_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_paint_glyph_or_fail_func
#endif
hb_font_funcs_set_paint_glyph_or_fail_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1456
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1456]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_user_data
  .p2align 4
  .type hb_font_funcs_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_user_data
#endif
hb_font_funcs_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1464
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1464]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_funcs_set_variation_glyph_func
  .p2align 4
  .type hb_font_funcs_set_variation_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_funcs_set_variation_glyph_func
#endif
hb_font_funcs_set_variation_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1472
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1472]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_empty
  .p2align 4
  .type hb_font_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_empty
#endif
hb_font_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1480
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1480]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_extents_for_direction
  .p2align 4
  .type hb_font_get_extents_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_extents_for_direction
#endif
hb_font_get_extents_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1488
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1488]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_face
  .p2align 4
  .type hb_font_get_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_face
#endif
hb_font_get_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1496
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1496]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph
  .p2align 4
  .type hb_font_get_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph
#endif
hb_font_get_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1504
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1504]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_advance_for_direction
  .p2align 4
  .type hb_font_get_glyph_advance_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_advance_for_direction
#endif
hb_font_get_glyph_advance_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1512
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1512]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_advances_for_direction
  .p2align 4
  .type hb_font_get_glyph_advances_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_advances_for_direction
#endif
hb_font_get_glyph_advances_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1520
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1520]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_contour_point
  .p2align 4
  .type hb_font_get_glyph_contour_point, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_contour_point
#endif
hb_font_get_glyph_contour_point:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1528
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1528]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_contour_point_for_origin
  .p2align 4
  .type hb_font_get_glyph_contour_point_for_origin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_contour_point_for_origin
#endif
hb_font_get_glyph_contour_point_for_origin:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1536
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1536]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_extents
  .p2align 4
  .type hb_font_get_glyph_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_extents
#endif
hb_font_get_glyph_extents:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1544
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1544]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_extents_for_origin
  .p2align 4
  .type hb_font_get_glyph_extents_for_origin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_extents_for_origin
#endif
hb_font_get_glyph_extents_for_origin:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1552
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1552]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_from_name
  .p2align 4
  .type hb_font_get_glyph_from_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_from_name
#endif
hb_font_get_glyph_from_name:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1560
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1560]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_h_advance
  .p2align 4
  .type hb_font_get_glyph_h_advance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_h_advance
#endif
hb_font_get_glyph_h_advance:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1568
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1568]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_h_advances
  .p2align 4
  .type hb_font_get_glyph_h_advances, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_h_advances
#endif
hb_font_get_glyph_h_advances:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1576
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1576]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_h_kerning
  .p2align 4
  .type hb_font_get_glyph_h_kerning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_h_kerning
#endif
hb_font_get_glyph_h_kerning:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1584
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1584]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_h_origin
  .p2align 4
  .type hb_font_get_glyph_h_origin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_h_origin
#endif
hb_font_get_glyph_h_origin:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1592
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1592]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_kerning_for_direction
  .p2align 4
  .type hb_font_get_glyph_kerning_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_kerning_for_direction
#endif
hb_font_get_glyph_kerning_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1600
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1600]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_name
  .p2align 4
  .type hb_font_get_glyph_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_name
#endif
hb_font_get_glyph_name:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1608
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1608]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_origin_for_direction
  .p2align 4
  .type hb_font_get_glyph_origin_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_origin_for_direction
#endif
hb_font_get_glyph_origin_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1616
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1616]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_shape
  .p2align 4
  .type hb_font_get_glyph_shape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_shape
#endif
hb_font_get_glyph_shape:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1624
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1624]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_v_advance
  .p2align 4
  .type hb_font_get_glyph_v_advance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_v_advance
#endif
hb_font_get_glyph_v_advance:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1632
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1632]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_v_advances
  .p2align 4
  .type hb_font_get_glyph_v_advances, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_v_advances
#endif
hb_font_get_glyph_v_advances:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1640
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1640]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_v_kerning
  .p2align 4
  .type hb_font_get_glyph_v_kerning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_v_kerning
#endif
hb_font_get_glyph_v_kerning:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1648
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1648]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_glyph_v_origin
  .p2align 4
  .type hb_font_get_glyph_v_origin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_glyph_v_origin
#endif
hb_font_get_glyph_v_origin:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1656
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1656]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_h_extents
  .p2align 4
  .type hb_font_get_h_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_h_extents
#endif
hb_font_get_h_extents:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1664
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1664]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_nominal_glyph
  .p2align 4
  .type hb_font_get_nominal_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_nominal_glyph
#endif
hb_font_get_nominal_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1672
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1672]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_nominal_glyphs
  .p2align 4
  .type hb_font_get_nominal_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_nominal_glyphs
#endif
hb_font_get_nominal_glyphs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1680
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1680]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_parent
  .p2align 4
  .type hb_font_get_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_parent
#endif
hb_font_get_parent:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1688
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1688]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_ppem
  .p2align 4
  .type hb_font_get_ppem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_ppem
#endif
hb_font_get_ppem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1696
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1696]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_ptem
  .p2align 4
  .type hb_font_get_ptem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_ptem
#endif
hb_font_get_ptem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1704
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1704]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_scale
  .p2align 4
  .type hb_font_get_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_scale
#endif
hb_font_get_scale:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1712
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1712]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_serial
  .p2align 4
  .type hb_font_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_serial
#endif
hb_font_get_serial:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1720
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1720]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_synthetic_bold
  .p2align 4
  .type hb_font_get_synthetic_bold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_synthetic_bold
#endif
hb_font_get_synthetic_bold:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1728
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1728]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_synthetic_slant
  .p2align 4
  .type hb_font_get_synthetic_slant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_synthetic_slant
#endif
hb_font_get_synthetic_slant:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1736
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1736]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_user_data
  .p2align 4
  .type hb_font_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_user_data
#endif
hb_font_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1744
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1744]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_v_extents
  .p2align 4
  .type hb_font_get_v_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_v_extents
#endif
hb_font_get_v_extents:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1752
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1752]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_var_coords_design
  .p2align 4
  .type hb_font_get_var_coords_design, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_var_coords_design
#endif
hb_font_get_var_coords_design:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1760
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1760]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_var_coords_normalized
  .p2align 4
  .type hb_font_get_var_coords_normalized, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_var_coords_normalized
#endif
hb_font_get_var_coords_normalized:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1768
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1768]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_var_named_instance
  .p2align 4
  .type hb_font_get_var_named_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_var_named_instance
#endif
hb_font_get_var_named_instance:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1776
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1776]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_get_variation_glyph
  .p2align 4
  .type hb_font_get_variation_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_get_variation_glyph
#endif
hb_font_get_variation_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1784
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1784]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_glyph_from_string
  .p2align 4
  .type hb_font_glyph_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_glyph_from_string
#endif
hb_font_glyph_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1792
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1792]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_glyph_to_string
  .p2align 4
  .type hb_font_glyph_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_glyph_to_string
#endif
hb_font_glyph_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1800
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1800]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_is_immutable
  .p2align 4
  .type hb_font_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_is_immutable
#endif
hb_font_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1808
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1808]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_is_synthetic
  .p2align 4
  .type hb_font_is_synthetic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_is_synthetic
#endif
hb_font_is_synthetic:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1816
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1816]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_list_funcs
  .p2align 4
  .type hb_font_list_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_list_funcs
#endif
hb_font_list_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1824
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1824]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_make_immutable
  .p2align 4
  .type hb_font_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_make_immutable
#endif
hb_font_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1832
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1832]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_paint_glyph
  .p2align 4
  .type hb_font_paint_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_paint_glyph
#endif
hb_font_paint_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1840
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1840]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_paint_glyph_or_fail
  .p2align 4
  .type hb_font_paint_glyph_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_paint_glyph_or_fail
#endif
hb_font_paint_glyph_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1848
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1848]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_reference
  .p2align 4
  .type hb_font_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_reference
#endif
hb_font_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1856
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1856]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_face
  .p2align 4
  .type hb_font_set_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_face
#endif
hb_font_set_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1864
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1864]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_funcs
  .p2align 4
  .type hb_font_set_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_funcs
#endif
hb_font_set_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1872
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1872]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_funcs_data
  .p2align 4
  .type hb_font_set_funcs_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_funcs_data
#endif
hb_font_set_funcs_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1880
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1880]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_funcs_using
  .p2align 4
  .type hb_font_set_funcs_using, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_funcs_using
#endif
hb_font_set_funcs_using:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1888
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1888]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_parent
  .p2align 4
  .type hb_font_set_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_parent
#endif
hb_font_set_parent:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1896
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1896]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_ppem
  .p2align 4
  .type hb_font_set_ppem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_ppem
#endif
hb_font_set_ppem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1904
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1904]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_ptem
  .p2align 4
  .type hb_font_set_ptem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_ptem
#endif
hb_font_set_ptem:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1912
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1912]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_scale
  .p2align 4
  .type hb_font_set_scale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_scale
#endif
hb_font_set_scale:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1920
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1920]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_synthetic_bold
  .p2align 4
  .type hb_font_set_synthetic_bold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_synthetic_bold
#endif
hb_font_set_synthetic_bold:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1928
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1928]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_synthetic_slant
  .p2align 4
  .type hb_font_set_synthetic_slant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_synthetic_slant
#endif
hb_font_set_synthetic_slant:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1936
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1936]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_user_data
  .p2align 4
  .type hb_font_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_user_data
#endif
hb_font_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1944
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1944]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_var_coords_design
  .p2align 4
  .type hb_font_set_var_coords_design, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_var_coords_design
#endif
hb_font_set_var_coords_design:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1952
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1952]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_var_coords_normalized
  .p2align 4
  .type hb_font_set_var_coords_normalized, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_var_coords_normalized
#endif
hb_font_set_var_coords_normalized:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1960
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1960]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_var_named_instance
  .p2align 4
  .type hb_font_set_var_named_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_var_named_instance
#endif
hb_font_set_var_named_instance:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1968
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1968]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_variation
  .p2align 4
  .type hb_font_set_variation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_variation
#endif
hb_font_set_variation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1976
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1976]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_set_variations
  .p2align 4
  .type hb_font_set_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_set_variations
#endif
hb_font_set_variations:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1984
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1984]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_font_subtract_glyph_origin_for_direction
  .p2align 4
  .type hb_font_subtract_glyph_origin_for_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_font_subtract_glyph_origin_for_direction
#endif
hb_font_subtract_glyph_origin_for_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+1992
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+1992]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_free
  .p2align 4
  .type hb_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_free
#endif
hb_free:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2000
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2000]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_face_create
  .p2align 4
  .type hb_ft_face_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_face_create
#endif
hb_ft_face_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2008
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2008]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_face_create_cached
  .p2align 4
  .type hb_ft_face_create_cached, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_face_create_cached
#endif
hb_ft_face_create_cached:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2016
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2016]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_face_create_from_blob_or_fail
  .p2align 4
  .type hb_ft_face_create_from_blob_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_face_create_from_blob_or_fail
#endif
hb_ft_face_create_from_blob_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2024
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2024]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_face_create_from_file_or_fail
  .p2align 4
  .type hb_ft_face_create_from_file_or_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_face_create_from_file_or_fail
#endif
hb_ft_face_create_from_file_or_fail:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2032
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2032]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_face_create_referenced
  .p2align 4
  .type hb_ft_face_create_referenced, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_face_create_referenced
#endif
hb_ft_face_create_referenced:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2040
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2040]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_changed
  .p2align 4
  .type hb_ft_font_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_changed
#endif
hb_ft_font_changed:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2048
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2048]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_create
  .p2align 4
  .type hb_ft_font_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_create
#endif
hb_ft_font_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2056
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2056]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_create_referenced
  .p2align 4
  .type hb_ft_font_create_referenced, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_create_referenced
#endif
hb_ft_font_create_referenced:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2064
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2064]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_get_face
  .p2align 4
  .type hb_ft_font_get_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_get_face
#endif
hb_ft_font_get_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2072
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2072]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_get_ft_face
  .p2align 4
  .type hb_ft_font_get_ft_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_get_ft_face
#endif
hb_ft_font_get_ft_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2080
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2080]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_get_load_flags
  .p2align 4
  .type hb_ft_font_get_load_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_get_load_flags
#endif
hb_ft_font_get_load_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2088
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2088]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_lock_face
  .p2align 4
  .type hb_ft_font_lock_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_lock_face
#endif
hb_ft_font_lock_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2096
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2096]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_set_funcs
  .p2align 4
  .type hb_ft_font_set_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_set_funcs
#endif
hb_ft_font_set_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2104
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2104]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_set_load_flags
  .p2align 4
  .type hb_ft_font_set_load_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_set_load_flags
#endif
hb_ft_font_set_load_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2112
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2112]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_font_unlock_face
  .p2align 4
  .type hb_ft_font_unlock_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_font_unlock_face
#endif
hb_ft_font_unlock_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2120
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2120]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ft_hb_font_changed
  .p2align 4
  .type hb_ft_hb_font_changed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ft_hb_font_changed
#endif
hb_ft_hb_font_changed:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2128
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2128]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_glib_blob_create
  .p2align 4
  .type hb_glib_blob_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_glib_blob_create
#endif
hb_glib_blob_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2136
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2136]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_glib_get_unicode_funcs
  .p2align 4
  .type hb_glib_get_unicode_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_glib_get_unicode_funcs
#endif
hb_glib_get_unicode_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2144
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2144]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_glib_script_from_script
  .p2align 4
  .type hb_glib_script_from_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_glib_script_from_script
#endif
hb_glib_script_from_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2152
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2152]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_glib_script_to_script
  .p2align 4
  .type hb_glib_script_to_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_glib_script_to_script
#endif
hb_glib_script_to_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2160
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2160]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_glyph_info_get_glyph_flags
  .p2align 4
  .type hb_glyph_info_get_glyph_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_glyph_info_get_glyph_flags
#endif
hb_glyph_info_get_glyph_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2168
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2168]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_graphite2_face_get_gr_face
  .p2align 4
  .type hb_graphite2_face_get_gr_face, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_graphite2_face_get_gr_face
#endif
hb_graphite2_face_get_gr_face:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2176
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2176]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_graphite2_font_get_gr_font
  .p2align 4
  .type hb_graphite2_font_get_gr_font, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_graphite2_font_get_gr_font
#endif
hb_graphite2_font_get_gr_font:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2184
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2184]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_language_from_string
  .p2align 4
  .type hb_language_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_language_from_string
#endif
hb_language_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2192
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2192]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_language_get_default
  .p2align 4
  .type hb_language_get_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_language_get_default
#endif
hb_language_get_default:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2200
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2200]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_language_matches
  .p2align 4
  .type hb_language_matches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_language_matches
#endif
hb_language_matches:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2208
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2208]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_language_to_string
  .p2align 4
  .type hb_language_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_language_to_string
#endif
hb_language_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2216
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2216]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_malloc
  .p2align 4
  .type hb_malloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_malloc
#endif
hb_malloc:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2224
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2224]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_allocation_successful
  .p2align 4
  .type hb_map_allocation_successful, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_allocation_successful
#endif
hb_map_allocation_successful:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2232
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2232]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_clear
  .p2align 4
  .type hb_map_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_clear
#endif
hb_map_clear:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2240
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2240]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_copy
  .p2align 4
  .type hb_map_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_copy
#endif
hb_map_copy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2248
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2248]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_create
  .p2align 4
  .type hb_map_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_create
#endif
hb_map_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2256
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2256]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_del
  .p2align 4
  .type hb_map_del, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_del
#endif
hb_map_del:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2264
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2264]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_destroy
  .p2align 4
  .type hb_map_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_destroy
#endif
hb_map_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2272
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2272]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_get
  .p2align 4
  .type hb_map_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_get
#endif
hb_map_get:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2280
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2280]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_get_empty
  .p2align 4
  .type hb_map_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_get_empty
#endif
hb_map_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2288
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2288]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_get_population
  .p2align 4
  .type hb_map_get_population, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_get_population
#endif
hb_map_get_population:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2296
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2296]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_get_user_data
  .p2align 4
  .type hb_map_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_get_user_data
#endif
hb_map_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2304
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2304]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_has
  .p2align 4
  .type hb_map_has, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_has
#endif
hb_map_has:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2312
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2312]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_hash
  .p2align 4
  .type hb_map_hash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_hash
#endif
hb_map_hash:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2320
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2320]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_is_empty
  .p2align 4
  .type hb_map_is_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_is_empty
#endif
hb_map_is_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2328
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2328]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_is_equal
  .p2align 4
  .type hb_map_is_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_is_equal
#endif
hb_map_is_equal:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2336
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2336]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_keys
  .p2align 4
  .type hb_map_keys, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_keys
#endif
hb_map_keys:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2344
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2344]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_next
  .p2align 4
  .type hb_map_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_next
#endif
hb_map_next:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2352
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2352]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_reference
  .p2align 4
  .type hb_map_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_reference
#endif
hb_map_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2360
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2360]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_set
  .p2align 4
  .type hb_map_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_set
#endif
hb_map_set:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2368
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2368]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_set_user_data
  .p2align 4
  .type hb_map_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_set_user_data
#endif
hb_map_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2376
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2376]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_update
  .p2align 4
  .type hb_map_update, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_update
#endif
hb_map_update:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2384
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2384]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_map_values
  .p2align 4
  .type hb_map_values, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_map_values
#endif
hb_map_values:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2392
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2392]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_glyph_get_layers
  .p2align 4
  .type hb_ot_color_glyph_get_layers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_glyph_get_layers
#endif
hb_ot_color_glyph_get_layers:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2400
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2400]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_glyph_has_paint
  .p2align 4
  .type hb_ot_color_glyph_has_paint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_glyph_has_paint
#endif
hb_ot_color_glyph_has_paint:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2408
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2408]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_glyph_reference_png
  .p2align 4
  .type hb_ot_color_glyph_reference_png, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_glyph_reference_png
#endif
hb_ot_color_glyph_reference_png:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2416
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2416]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_glyph_reference_svg
  .p2align 4
  .type hb_ot_color_glyph_reference_svg, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_glyph_reference_svg
#endif
hb_ot_color_glyph_reference_svg:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2424
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2424]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_has_layers
  .p2align 4
  .type hb_ot_color_has_layers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_has_layers
#endif
hb_ot_color_has_layers:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2432
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2432]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_has_paint
  .p2align 4
  .type hb_ot_color_has_paint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_has_paint
#endif
hb_ot_color_has_paint:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2440
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2440]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_has_palettes
  .p2align 4
  .type hb_ot_color_has_palettes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_has_palettes
#endif
hb_ot_color_has_palettes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2448
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2448]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_has_png
  .p2align 4
  .type hb_ot_color_has_png, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_has_png
#endif
hb_ot_color_has_png:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2456
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2456]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_has_svg
  .p2align 4
  .type hb_ot_color_has_svg, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_has_svg
#endif
hb_ot_color_has_svg:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2464
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2464]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_palette_color_get_name_id
  .p2align 4
  .type hb_ot_color_palette_color_get_name_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_palette_color_get_name_id
#endif
hb_ot_color_palette_color_get_name_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2472
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2472]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_palette_get_colors
  .p2align 4
  .type hb_ot_color_palette_get_colors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_palette_get_colors
#endif
hb_ot_color_palette_get_colors:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2480
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2480]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_palette_get_count
  .p2align 4
  .type hb_ot_color_palette_get_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_palette_get_count
#endif
hb_ot_color_palette_get_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2488
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2488]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_palette_get_flags
  .p2align 4
  .type hb_ot_color_palette_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_palette_get_flags
#endif
hb_ot_color_palette_get_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2496
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2496]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_color_palette_get_name_id
  .p2align 4
  .type hb_ot_color_palette_get_name_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_color_palette_get_name_id
#endif
hb_ot_color_palette_get_name_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2504
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2504]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_font_set_funcs
  .p2align 4
  .type hb_ot_font_set_funcs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_font_set_funcs
#endif
hb_ot_font_set_funcs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2512
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2512]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_collect_features
  .p2align 4
  .type hb_ot_layout_collect_features, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_collect_features
#endif
hb_ot_layout_collect_features:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2520
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2520]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_collect_features_map
  .p2align 4
  .type hb_ot_layout_collect_features_map, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_collect_features_map
#endif
hb_ot_layout_collect_features_map:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2528
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2528]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_collect_lookups
  .p2align 4
  .type hb_ot_layout_collect_lookups, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_collect_lookups
#endif
hb_ot_layout_collect_lookups:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2536
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2536]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_feature_get_characters
  .p2align 4
  .type hb_ot_layout_feature_get_characters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_feature_get_characters
#endif
hb_ot_layout_feature_get_characters:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2544
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2544]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_feature_get_lookups
  .p2align 4
  .type hb_ot_layout_feature_get_lookups, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_feature_get_lookups
#endif
hb_ot_layout_feature_get_lookups:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2552
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2552]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_feature_get_name_ids
  .p2align 4
  .type hb_ot_layout_feature_get_name_ids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_feature_get_name_ids
#endif
hb_ot_layout_feature_get_name_ids:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2560
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2560]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_feature_with_variations_get_lookups
  .p2align 4
  .type hb_ot_layout_feature_with_variations_get_lookups, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_feature_with_variations_get_lookups
#endif
hb_ot_layout_feature_with_variations_get_lookups:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2568
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2568]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_attach_points
  .p2align 4
  .type hb_ot_layout_get_attach_points, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_attach_points
#endif
hb_ot_layout_get_attach_points:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2576
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2576]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_baseline
  .p2align 4
  .type hb_ot_layout_get_baseline, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_baseline
#endif
hb_ot_layout_get_baseline:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2584
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2584]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_baseline2
  .p2align 4
  .type hb_ot_layout_get_baseline2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_baseline2
#endif
hb_ot_layout_get_baseline2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2592
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2592]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_baseline_with_fallback
  .p2align 4
  .type hb_ot_layout_get_baseline_with_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_baseline_with_fallback
#endif
hb_ot_layout_get_baseline_with_fallback:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2600
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2600]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_baseline_with_fallback2
  .p2align 4
  .type hb_ot_layout_get_baseline_with_fallback2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_baseline_with_fallback2
#endif
hb_ot_layout_get_baseline_with_fallback2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2608
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2608]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_font_extents
  .p2align 4
  .type hb_ot_layout_get_font_extents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_font_extents
#endif
hb_ot_layout_get_font_extents:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2616
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2616]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_font_extents2
  .p2align 4
  .type hb_ot_layout_get_font_extents2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_font_extents2
#endif
hb_ot_layout_get_font_extents2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2624
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2624]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_glyph_class
  .p2align 4
  .type hb_ot_layout_get_glyph_class, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_glyph_class
#endif
hb_ot_layout_get_glyph_class:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2632
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2632]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_glyphs_in_class
  .p2align 4
  .type hb_ot_layout_get_glyphs_in_class, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_glyphs_in_class
#endif
hb_ot_layout_get_glyphs_in_class:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2640
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2640]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_horizontal_baseline_tag_for_script
  .p2align 4
  .type hb_ot_layout_get_horizontal_baseline_tag_for_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_horizontal_baseline_tag_for_script
#endif
hb_ot_layout_get_horizontal_baseline_tag_for_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2648
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2648]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_ligature_carets
  .p2align 4
  .type hb_ot_layout_get_ligature_carets, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_ligature_carets
#endif
hb_ot_layout_get_ligature_carets:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2656
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2656]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_get_size_params
  .p2align 4
  .type hb_ot_layout_get_size_params, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_get_size_params
#endif
hb_ot_layout_get_size_params:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2664
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2664]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_has_glyph_classes
  .p2align 4
  .type hb_ot_layout_has_glyph_classes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_has_glyph_classes
#endif
hb_ot_layout_has_glyph_classes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2672
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2672]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_has_positioning
  .p2align 4
  .type hb_ot_layout_has_positioning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_has_positioning
#endif
hb_ot_layout_has_positioning:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2680
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2680]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_has_substitution
  .p2align 4
  .type hb_ot_layout_has_substitution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_has_substitution
#endif
hb_ot_layout_has_substitution:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2688
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2688]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_language_find_feature
  .p2align 4
  .type hb_ot_layout_language_find_feature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_language_find_feature
#endif
hb_ot_layout_language_find_feature:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2696
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2696]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_language_get_feature_indexes
  .p2align 4
  .type hb_ot_layout_language_get_feature_indexes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_language_get_feature_indexes
#endif
hb_ot_layout_language_get_feature_indexes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2704
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2704]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_language_get_feature_tags
  .p2align 4
  .type hb_ot_layout_language_get_feature_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_language_get_feature_tags
#endif
hb_ot_layout_language_get_feature_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2712
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2712]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_language_get_required_feature
  .p2align 4
  .type hb_ot_layout_language_get_required_feature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_language_get_required_feature
#endif
hb_ot_layout_language_get_required_feature:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2720
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2720]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_language_get_required_feature_index
  .p2align 4
  .type hb_ot_layout_language_get_required_feature_index, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_language_get_required_feature_index
#endif
hb_ot_layout_language_get_required_feature_index:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2728
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2728]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookup_collect_glyphs
  .p2align 4
  .type hb_ot_layout_lookup_collect_glyphs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookup_collect_glyphs
#endif
hb_ot_layout_lookup_collect_glyphs:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2736
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2736]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookup_get_glyph_alternates
  .p2align 4
  .type hb_ot_layout_lookup_get_glyph_alternates, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookup_get_glyph_alternates
#endif
hb_ot_layout_lookup_get_glyph_alternates:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2744
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2744]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookup_get_optical_bound
  .p2align 4
  .type hb_ot_layout_lookup_get_optical_bound, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookup_get_optical_bound
#endif
hb_ot_layout_lookup_get_optical_bound:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2752
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2752]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookup_substitute_closure
  .p2align 4
  .type hb_ot_layout_lookup_substitute_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookup_substitute_closure
#endif
hb_ot_layout_lookup_substitute_closure:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2760
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2760]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookup_would_substitute
  .p2align 4
  .type hb_ot_layout_lookup_would_substitute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookup_would_substitute
#endif
hb_ot_layout_lookup_would_substitute:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2768
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2768]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_lookups_substitute_closure
  .p2align 4
  .type hb_ot_layout_lookups_substitute_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_lookups_substitute_closure
#endif
hb_ot_layout_lookups_substitute_closure:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2776
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2776]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_script_find_language
  .p2align 4
  .type hb_ot_layout_script_find_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_script_find_language
#endif
hb_ot_layout_script_find_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2784
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2784]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_script_get_language_tags
  .p2align 4
  .type hb_ot_layout_script_get_language_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_script_get_language_tags
#endif
hb_ot_layout_script_get_language_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2792
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2792]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_script_select_language
  .p2align 4
  .type hb_ot_layout_script_select_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_script_select_language
#endif
hb_ot_layout_script_select_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2800
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2800]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_script_select_language2
  .p2align 4
  .type hb_ot_layout_script_select_language2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_script_select_language2
#endif
hb_ot_layout_script_select_language2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2808
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2808]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_choose_script
  .p2align 4
  .type hb_ot_layout_table_choose_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_choose_script
#endif
hb_ot_layout_table_choose_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2816
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2816]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_find_feature_variations
  .p2align 4
  .type hb_ot_layout_table_find_feature_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_find_feature_variations
#endif
hb_ot_layout_table_find_feature_variations:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2824
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2824]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_find_script
  .p2align 4
  .type hb_ot_layout_table_find_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_find_script
#endif
hb_ot_layout_table_find_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2832
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2832]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_get_feature_tags
  .p2align 4
  .type hb_ot_layout_table_get_feature_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_get_feature_tags
#endif
hb_ot_layout_table_get_feature_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2840
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2840]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_get_lookup_count
  .p2align 4
  .type hb_ot_layout_table_get_lookup_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_get_lookup_count
#endif
hb_ot_layout_table_get_lookup_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2848
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2848]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_get_script_tags
  .p2align 4
  .type hb_ot_layout_table_get_script_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_get_script_tags
#endif
hb_ot_layout_table_get_script_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2856
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2856]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_layout_table_select_script
  .p2align 4
  .type hb_ot_layout_table_select_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_layout_table_select_script
#endif
hb_ot_layout_table_select_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2864
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2864]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_constant
  .p2align 4
  .type hb_ot_math_get_constant, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_constant
#endif
hb_ot_math_get_constant:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2872
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2872]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_assembly
  .p2align 4
  .type hb_ot_math_get_glyph_assembly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_assembly
#endif
hb_ot_math_get_glyph_assembly:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2880
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2880]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_italics_correction
  .p2align 4
  .type hb_ot_math_get_glyph_italics_correction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_italics_correction
#endif
hb_ot_math_get_glyph_italics_correction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2888
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2888]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_kerning
  .p2align 4
  .type hb_ot_math_get_glyph_kerning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_kerning
#endif
hb_ot_math_get_glyph_kerning:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2896
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2896]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_kernings
  .p2align 4
  .type hb_ot_math_get_glyph_kernings, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_kernings
#endif
hb_ot_math_get_glyph_kernings:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2904
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2904]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_top_accent_attachment
  .p2align 4
  .type hb_ot_math_get_glyph_top_accent_attachment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_top_accent_attachment
#endif
hb_ot_math_get_glyph_top_accent_attachment:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2912
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2912]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_glyph_variants
  .p2align 4
  .type hb_ot_math_get_glyph_variants, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_glyph_variants
#endif
hb_ot_math_get_glyph_variants:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2920
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2920]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_get_min_connector_overlap
  .p2align 4
  .type hb_ot_math_get_min_connector_overlap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_get_min_connector_overlap
#endif
hb_ot_math_get_min_connector_overlap:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2928
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2928]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_has_data
  .p2align 4
  .type hb_ot_math_has_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_has_data
#endif
hb_ot_math_has_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2936
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2936]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_math_is_glyph_extended_shape
  .p2align 4
  .type hb_ot_math_is_glyph_extended_shape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_math_is_glyph_extended_shape
#endif
hb_ot_math_is_glyph_extended_shape:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2944
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2944]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_meta_get_entry_tags
  .p2align 4
  .type hb_ot_meta_get_entry_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_meta_get_entry_tags
#endif
hb_ot_meta_get_entry_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2952
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2952]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_meta_reference_entry
  .p2align 4
  .type hb_ot_meta_reference_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_meta_reference_entry
#endif
hb_ot_meta_reference_entry:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2960
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2960]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_metrics_get_position
  .p2align 4
  .type hb_ot_metrics_get_position, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_metrics_get_position
#endif
hb_ot_metrics_get_position:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2968
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2968]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_metrics_get_position_with_fallback
  .p2align 4
  .type hb_ot_metrics_get_position_with_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_metrics_get_position_with_fallback
#endif
hb_ot_metrics_get_position_with_fallback:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2976
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2976]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_metrics_get_variation
  .p2align 4
  .type hb_ot_metrics_get_variation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_metrics_get_variation
#endif
hb_ot_metrics_get_variation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2984
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2984]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_metrics_get_x_variation
  .p2align 4
  .type hb_ot_metrics_get_x_variation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_metrics_get_x_variation
#endif
hb_ot_metrics_get_x_variation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+2992
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+2992]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_metrics_get_y_variation
  .p2align 4
  .type hb_ot_metrics_get_y_variation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_metrics_get_y_variation
#endif
hb_ot_metrics_get_y_variation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3000
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3000]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_name_get_utf16
  .p2align 4
  .type hb_ot_name_get_utf16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_name_get_utf16
#endif
hb_ot_name_get_utf16:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3008
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3008]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_name_get_utf32
  .p2align 4
  .type hb_ot_name_get_utf32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_name_get_utf32
#endif
hb_ot_name_get_utf32:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3016
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3016]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_name_get_utf8
  .p2align 4
  .type hb_ot_name_get_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_name_get_utf8
#endif
hb_ot_name_get_utf8:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3024
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3024]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_name_list_names
  .p2align 4
  .type hb_ot_name_list_names, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_name_list_names
#endif
hb_ot_name_list_names:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3032
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3032]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_shape_glyphs_closure
  .p2align 4
  .type hb_ot_shape_glyphs_closure, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_shape_glyphs_closure
#endif
hb_ot_shape_glyphs_closure:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3040
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3040]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_shape_plan_collect_lookups
  .p2align 4
  .type hb_ot_shape_plan_collect_lookups, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_shape_plan_collect_lookups
#endif
hb_ot_shape_plan_collect_lookups:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3048
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3048]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_shape_plan_get_feature_tags
  .p2align 4
  .type hb_ot_shape_plan_get_feature_tags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_shape_plan_get_feature_tags
#endif
hb_ot_shape_plan_get_feature_tags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3056
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3056]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tag_from_language
  .p2align 4
  .type hb_ot_tag_from_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tag_from_language
#endif
hb_ot_tag_from_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3064
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3064]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tag_to_language
  .p2align 4
  .type hb_ot_tag_to_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tag_to_language
#endif
hb_ot_tag_to_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3072
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3072]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tag_to_script
  .p2align 4
  .type hb_ot_tag_to_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tag_to_script
#endif
hb_ot_tag_to_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3080
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3080]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tags_from_script
  .p2align 4
  .type hb_ot_tags_from_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tags_from_script
#endif
hb_ot_tags_from_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3088
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3088]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tags_from_script_and_language
  .p2align 4
  .type hb_ot_tags_from_script_and_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tags_from_script_and_language
#endif
hb_ot_tags_from_script_and_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3096
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3096]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_tags_to_script_and_language
  .p2align 4
  .type hb_ot_tags_to_script_and_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_tags_to_script_and_language
#endif
hb_ot_tags_to_script_and_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3104
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3104]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_find_axis
  .p2align 4
  .type hb_ot_var_find_axis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_find_axis
#endif
hb_ot_var_find_axis:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3112
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3112]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_find_axis_info
  .p2align 4
  .type hb_ot_var_find_axis_info, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_find_axis_info
#endif
hb_ot_var_find_axis_info:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3120
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3120]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_get_axes
  .p2align 4
  .type hb_ot_var_get_axes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_get_axes
#endif
hb_ot_var_get_axes:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3128
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3128]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_get_axis_count
  .p2align 4
  .type hb_ot_var_get_axis_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_get_axis_count
#endif
hb_ot_var_get_axis_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3136
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3136]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_get_axis_infos
  .p2align 4
  .type hb_ot_var_get_axis_infos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_get_axis_infos
#endif
hb_ot_var_get_axis_infos:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3144
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3144]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_get_named_instance_count
  .p2align 4
  .type hb_ot_var_get_named_instance_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_get_named_instance_count
#endif
hb_ot_var_get_named_instance_count:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3152
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3152]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_has_data
  .p2align 4
  .type hb_ot_var_has_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_has_data
#endif
hb_ot_var_has_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3160
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3160]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_named_instance_get_design_coords
  .p2align 4
  .type hb_ot_var_named_instance_get_design_coords, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_named_instance_get_design_coords
#endif
hb_ot_var_named_instance_get_design_coords:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3168
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3168]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_named_instance_get_postscript_name_id
  .p2align 4
  .type hb_ot_var_named_instance_get_postscript_name_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_named_instance_get_postscript_name_id
#endif
hb_ot_var_named_instance_get_postscript_name_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3176
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3176]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_named_instance_get_subfamily_name_id
  .p2align 4
  .type hb_ot_var_named_instance_get_subfamily_name_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_named_instance_get_subfamily_name_id
#endif
hb_ot_var_named_instance_get_subfamily_name_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3184
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3184]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_normalize_coords
  .p2align 4
  .type hb_ot_var_normalize_coords, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_normalize_coords
#endif
hb_ot_var_normalize_coords:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3192
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3192]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_ot_var_normalize_variations
  .p2align 4
  .type hb_ot_var_normalize_variations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_ot_var_normalize_variations
#endif
hb_ot_var_normalize_variations:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3200
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3200]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_color
  .p2align 4
  .type hb_paint_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_color
#endif
hb_paint_color:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3208
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3208]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_color_glyph
  .p2align 4
  .type hb_paint_color_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_color_glyph
#endif
hb_paint_color_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3216
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3216]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_custom_palette_color
  .p2align 4
  .type hb_paint_custom_palette_color, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_custom_palette_color
#endif
hb_paint_custom_palette_color:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3224
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3224]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_create
  .p2align 4
  .type hb_paint_funcs_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_create
#endif
hb_paint_funcs_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3232
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3232]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_destroy
  .p2align 4
  .type hb_paint_funcs_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_destroy
#endif
hb_paint_funcs_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3240
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3240]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_get_empty
  .p2align 4
  .type hb_paint_funcs_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_get_empty
#endif
hb_paint_funcs_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3248
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3248]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_get_user_data
  .p2align 4
  .type hb_paint_funcs_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_get_user_data
#endif
hb_paint_funcs_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3256
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3256]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_is_immutable
  .p2align 4
  .type hb_paint_funcs_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_is_immutable
#endif
hb_paint_funcs_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3264
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3264]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_make_immutable
  .p2align 4
  .type hb_paint_funcs_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_make_immutable
#endif
hb_paint_funcs_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3272
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3272]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_reference
  .p2align 4
  .type hb_paint_funcs_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_reference
#endif
hb_paint_funcs_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3280
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3280]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_color_func
  .p2align 4
  .type hb_paint_funcs_set_color_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_color_func
#endif
hb_paint_funcs_set_color_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3288
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3288]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_color_glyph_func
  .p2align 4
  .type hb_paint_funcs_set_color_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_color_glyph_func
#endif
hb_paint_funcs_set_color_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3296
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3296]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_custom_palette_color_func
  .p2align 4
  .type hb_paint_funcs_set_custom_palette_color_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_custom_palette_color_func
#endif
hb_paint_funcs_set_custom_palette_color_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3304
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3304]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_image_func
  .p2align 4
  .type hb_paint_funcs_set_image_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_image_func
#endif
hb_paint_funcs_set_image_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3312
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3312]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_linear_gradient_func
  .p2align 4
  .type hb_paint_funcs_set_linear_gradient_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_linear_gradient_func
#endif
hb_paint_funcs_set_linear_gradient_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3320
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3320]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_pop_clip_func
  .p2align 4
  .type hb_paint_funcs_set_pop_clip_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_pop_clip_func
#endif
hb_paint_funcs_set_pop_clip_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3328
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3328]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_pop_group_func
  .p2align 4
  .type hb_paint_funcs_set_pop_group_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_pop_group_func
#endif
hb_paint_funcs_set_pop_group_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3336
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3336]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_pop_transform_func
  .p2align 4
  .type hb_paint_funcs_set_pop_transform_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_pop_transform_func
#endif
hb_paint_funcs_set_pop_transform_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3344
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3344]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_push_clip_glyph_func
  .p2align 4
  .type hb_paint_funcs_set_push_clip_glyph_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_push_clip_glyph_func
#endif
hb_paint_funcs_set_push_clip_glyph_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3352
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3352]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_push_clip_rectangle_func
  .p2align 4
  .type hb_paint_funcs_set_push_clip_rectangle_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_push_clip_rectangle_func
#endif
hb_paint_funcs_set_push_clip_rectangle_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3360
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3360]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_push_group_func
  .p2align 4
  .type hb_paint_funcs_set_push_group_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_push_group_func
#endif
hb_paint_funcs_set_push_group_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3368
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3368]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_push_transform_func
  .p2align 4
  .type hb_paint_funcs_set_push_transform_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_push_transform_func
#endif
hb_paint_funcs_set_push_transform_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3376
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3376]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_radial_gradient_func
  .p2align 4
  .type hb_paint_funcs_set_radial_gradient_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_radial_gradient_func
#endif
hb_paint_funcs_set_radial_gradient_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3384
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3384]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_sweep_gradient_func
  .p2align 4
  .type hb_paint_funcs_set_sweep_gradient_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_sweep_gradient_func
#endif
hb_paint_funcs_set_sweep_gradient_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3392
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3392]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_funcs_set_user_data
  .p2align 4
  .type hb_paint_funcs_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_funcs_set_user_data
#endif
hb_paint_funcs_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3400
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3400]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_image
  .p2align 4
  .type hb_paint_image, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_image
#endif
hb_paint_image:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3408
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3408]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_linear_gradient
  .p2align 4
  .type hb_paint_linear_gradient, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_linear_gradient
#endif
hb_paint_linear_gradient:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3416
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3416]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_pop_clip
  .p2align 4
  .type hb_paint_pop_clip, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_pop_clip
#endif
hb_paint_pop_clip:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3424
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3424]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_pop_group
  .p2align 4
  .type hb_paint_pop_group, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_pop_group
#endif
hb_paint_pop_group:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3432
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3432]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_pop_transform
  .p2align 4
  .type hb_paint_pop_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_pop_transform
#endif
hb_paint_pop_transform:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3440
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3440]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_clip_glyph
  .p2align 4
  .type hb_paint_push_clip_glyph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_clip_glyph
#endif
hb_paint_push_clip_glyph:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3448
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3448]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_clip_rectangle
  .p2align 4
  .type hb_paint_push_clip_rectangle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_clip_rectangle
#endif
hb_paint_push_clip_rectangle:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3456
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3456]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_font_transform
  .p2align 4
  .type hb_paint_push_font_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_font_transform
#endif
hb_paint_push_font_transform:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3464
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3464]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_group
  .p2align 4
  .type hb_paint_push_group, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_group
#endif
hb_paint_push_group:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3472
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3472]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_inverse_font_transform
  .p2align 4
  .type hb_paint_push_inverse_font_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_inverse_font_transform
#endif
hb_paint_push_inverse_font_transform:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3480
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3480]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_push_transform
  .p2align 4
  .type hb_paint_push_transform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_push_transform
#endif
hb_paint_push_transform:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3488
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3488]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_radial_gradient
  .p2align 4
  .type hb_paint_radial_gradient, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_radial_gradient
#endif
hb_paint_radial_gradient:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3496
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3496]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_paint_sweep_gradient
  .p2align 4
  .type hb_paint_sweep_gradient, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_paint_sweep_gradient
#endif
hb_paint_sweep_gradient:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3504
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3504]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_realloc
  .p2align 4
  .type hb_realloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_realloc
#endif
hb_realloc:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3512
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3512]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_script_from_iso15924_tag
  .p2align 4
  .type hb_script_from_iso15924_tag, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_script_from_iso15924_tag
#endif
hb_script_from_iso15924_tag:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3520
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3520]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_script_from_string
  .p2align 4
  .type hb_script_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_script_from_string
#endif
hb_script_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3528
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3528]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_script_get_horizontal_direction
  .p2align 4
  .type hb_script_get_horizontal_direction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_script_get_horizontal_direction
#endif
hb_script_get_horizontal_direction:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3536
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3536]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_script_to_iso15924_tag
  .p2align 4
  .type hb_script_to_iso15924_tag, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_script_to_iso15924_tag
#endif
hb_script_to_iso15924_tag:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3544
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3544]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_segment_properties_equal
  .p2align 4
  .type hb_segment_properties_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_segment_properties_equal
#endif
hb_segment_properties_equal:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3552
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3552]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_segment_properties_hash
  .p2align 4
  .type hb_segment_properties_hash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_segment_properties_hash
#endif
hb_segment_properties_hash:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3560
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3560]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_segment_properties_overlay
  .p2align 4
  .type hb_segment_properties_overlay, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_segment_properties_overlay
#endif
hb_segment_properties_overlay:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3568
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3568]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_add
  .p2align 4
  .type hb_set_add, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_add
#endif
hb_set_add:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3576
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3576]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_add_range
  .p2align 4
  .type hb_set_add_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_add_range
#endif
hb_set_add_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3584
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3584]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_add_sorted_array
  .p2align 4
  .type hb_set_add_sorted_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_add_sorted_array
#endif
hb_set_add_sorted_array:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3592
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3592]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_allocation_successful
  .p2align 4
  .type hb_set_allocation_successful, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_allocation_successful
#endif
hb_set_allocation_successful:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3600
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3600]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_clear
  .p2align 4
  .type hb_set_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_clear
#endif
hb_set_clear:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3608
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3608]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_copy
  .p2align 4
  .type hb_set_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_copy
#endif
hb_set_copy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3616
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3616]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_create
  .p2align 4
  .type hb_set_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_create
#endif
hb_set_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3624
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3624]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_del
  .p2align 4
  .type hb_set_del, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_del
#endif
hb_set_del:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3632
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3632]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_del_range
  .p2align 4
  .type hb_set_del_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_del_range
#endif
hb_set_del_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3640
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3640]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_destroy
  .p2align 4
  .type hb_set_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_destroy
#endif
hb_set_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3648
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3648]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_get_empty
  .p2align 4
  .type hb_set_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_get_empty
#endif
hb_set_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3656
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3656]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_get_max
  .p2align 4
  .type hb_set_get_max, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_get_max
#endif
hb_set_get_max:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3664
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3664]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_get_min
  .p2align 4
  .type hb_set_get_min, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_get_min
#endif
hb_set_get_min:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3672
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3672]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_get_population
  .p2align 4
  .type hb_set_get_population, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_get_population
#endif
hb_set_get_population:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3680
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3680]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_get_user_data
  .p2align 4
  .type hb_set_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_get_user_data
#endif
hb_set_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3688
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3688]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_has
  .p2align 4
  .type hb_set_has, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_has
#endif
hb_set_has:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3696
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3696]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_hash
  .p2align 4
  .type hb_set_hash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_hash
#endif
hb_set_hash:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3704
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3704]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_intersect
  .p2align 4
  .type hb_set_intersect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_intersect
#endif
hb_set_intersect:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3712
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3712]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_invert
  .p2align 4
  .type hb_set_invert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_invert
#endif
hb_set_invert:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3720
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3720]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_is_empty
  .p2align 4
  .type hb_set_is_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_is_empty
#endif
hb_set_is_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3728
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3728]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_is_equal
  .p2align 4
  .type hb_set_is_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_is_equal
#endif
hb_set_is_equal:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3736
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3736]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_is_inverted
  .p2align 4
  .type hb_set_is_inverted, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_is_inverted
#endif
hb_set_is_inverted:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3744
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3744]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_is_subset
  .p2align 4
  .type hb_set_is_subset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_is_subset
#endif
hb_set_is_subset:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3752
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3752]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_next
  .p2align 4
  .type hb_set_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_next
#endif
hb_set_next:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3760
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3760]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_next_many
  .p2align 4
  .type hb_set_next_many, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_next_many
#endif
hb_set_next_many:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3768
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3768]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_next_range
  .p2align 4
  .type hb_set_next_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_next_range
#endif
hb_set_next_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3776
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3776]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_previous
  .p2align 4
  .type hb_set_previous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_previous
#endif
hb_set_previous:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3784
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3784]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_previous_range
  .p2align 4
  .type hb_set_previous_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_previous_range
#endif
hb_set_previous_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3792
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3792]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_reference
  .p2align 4
  .type hb_set_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_reference
#endif
hb_set_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3800
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3800]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_set
  .p2align 4
  .type hb_set_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_set
#endif
hb_set_set:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3808
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3808]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_set_user_data
  .p2align 4
  .type hb_set_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_set_user_data
#endif
hb_set_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3816
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3816]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_subtract
  .p2align 4
  .type hb_set_subtract, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_subtract
#endif
hb_set_subtract:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3824
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3824]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_symmetric_difference
  .p2align 4
  .type hb_set_symmetric_difference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_symmetric_difference
#endif
hb_set_symmetric_difference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3832
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3832]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_set_union
  .p2align 4
  .type hb_set_union, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_set_union
#endif
hb_set_union:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3840
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3840]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape
  .p2align 4
  .type hb_shape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape
#endif
hb_shape:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3848
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3848]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_full
  .p2align 4
  .type hb_shape_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_full
#endif
hb_shape_full:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3856
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3856]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_list_shapers
  .p2align 4
  .type hb_shape_list_shapers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_list_shapers
#endif
hb_shape_list_shapers:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3864
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3864]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_create
  .p2align 4
  .type hb_shape_plan_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_create
#endif
hb_shape_plan_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3872
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3872]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_create2
  .p2align 4
  .type hb_shape_plan_create2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_create2
#endif
hb_shape_plan_create2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3880
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3880]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_create_cached
  .p2align 4
  .type hb_shape_plan_create_cached, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_create_cached
#endif
hb_shape_plan_create_cached:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3888
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3888]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_create_cached2
  .p2align 4
  .type hb_shape_plan_create_cached2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_create_cached2
#endif
hb_shape_plan_create_cached2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3896
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3896]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_destroy
  .p2align 4
  .type hb_shape_plan_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_destroy
#endif
hb_shape_plan_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3904
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3904]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_execute
  .p2align 4
  .type hb_shape_plan_execute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_execute
#endif
hb_shape_plan_execute:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3912
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3912]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_get_empty
  .p2align 4
  .type hb_shape_plan_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_get_empty
#endif
hb_shape_plan_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3920
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3920]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_get_shaper
  .p2align 4
  .type hb_shape_plan_get_shaper, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_get_shaper
#endif
hb_shape_plan_get_shaper:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3928
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3928]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_get_user_data
  .p2align 4
  .type hb_shape_plan_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_get_user_data
#endif
hb_shape_plan_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3936
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3936]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_reference
  .p2align 4
  .type hb_shape_plan_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_reference
#endif
hb_shape_plan_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3944
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3944]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_shape_plan_set_user_data
  .p2align 4
  .type hb_shape_plan_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_shape_plan_set_user_data
#endif
hb_shape_plan_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3952
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3952]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_style_get_value
  .p2align 4
  .type hb_style_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_style_get_value
#endif
hb_style_get_value:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3960
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3960]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_tag_from_string
  .p2align 4
  .type hb_tag_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_tag_from_string
#endif
hb_tag_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3968
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3968]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_tag_to_string
  .p2align 4
  .type hb_tag_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_tag_to_string
#endif
hb_tag_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3976
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3976]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_combining_class
  .p2align 4
  .type hb_unicode_combining_class, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_combining_class
#endif
hb_unicode_combining_class:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3984
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3984]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_compose
  .p2align 4
  .type hb_unicode_compose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_compose
#endif
hb_unicode_compose:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+3992
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+3992]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_decompose
  .p2align 4
  .type hb_unicode_decompose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_decompose
#endif
hb_unicode_decompose:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4000
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4000]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_decompose_compatibility
  .p2align 4
  .type hb_unicode_decompose_compatibility, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_decompose_compatibility
#endif
hb_unicode_decompose_compatibility:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4008
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4008]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_eastasian_width
  .p2align 4
  .type hb_unicode_eastasian_width, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_eastasian_width
#endif
hb_unicode_eastasian_width:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4016
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4016]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_create
  .p2align 4
  .type hb_unicode_funcs_create, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_create
#endif
hb_unicode_funcs_create:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4024
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4024]
 
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
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_destroy
  .p2align 4
  .type hb_unicode_funcs_destroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_destroy
#endif
hb_unicode_funcs_destroy:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4032
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4032]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 504 & 0xffff
#if 504 > 0xffff
  movk ip0, 504 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_get_default
  .p2align 4
  .type hb_unicode_funcs_get_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_get_default
#endif
hb_unicode_funcs_get_default:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4040
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4040]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 505 & 0xffff
#if 505 > 0xffff
  movk ip0, 505 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_get_empty
  .p2align 4
  .type hb_unicode_funcs_get_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_get_empty
#endif
hb_unicode_funcs_get_empty:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4048
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4048]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 506 & 0xffff
#if 506 > 0xffff
  movk ip0, 506 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_get_parent
  .p2align 4
  .type hb_unicode_funcs_get_parent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_get_parent
#endif
hb_unicode_funcs_get_parent:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4056
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4056]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 507 & 0xffff
#if 507 > 0xffff
  movk ip0, 507 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_get_user_data
  .p2align 4
  .type hb_unicode_funcs_get_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_get_user_data
#endif
hb_unicode_funcs_get_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4064
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4064]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 508 & 0xffff
#if 508 > 0xffff
  movk ip0, 508 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_is_immutable
  .p2align 4
  .type hb_unicode_funcs_is_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_is_immutable
#endif
hb_unicode_funcs_is_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4072
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4072]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 509 & 0xffff
#if 509 > 0xffff
  movk ip0, 509 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_make_immutable
  .p2align 4
  .type hb_unicode_funcs_make_immutable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_make_immutable
#endif
hb_unicode_funcs_make_immutable:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4080
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4080]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 510 & 0xffff
#if 510 > 0xffff
  movk ip0, 510 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_reference
  .p2align 4
  .type hb_unicode_funcs_reference, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_reference
#endif
hb_unicode_funcs_reference:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4088
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4088]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 511 & 0xffff
#if 511 > 0xffff
  movk ip0, 511 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_combining_class_func
  .p2align 4
  .type hb_unicode_funcs_set_combining_class_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_combining_class_func
#endif
hb_unicode_funcs_set_combining_class_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4096
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4096]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 512 & 0xffff
#if 512 > 0xffff
  movk ip0, 512 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_compose_func
  .p2align 4
  .type hb_unicode_funcs_set_compose_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_compose_func
#endif
hb_unicode_funcs_set_compose_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4104
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4104]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 513 & 0xffff
#if 513 > 0xffff
  movk ip0, 513 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_decompose_compatibility_func
  .p2align 4
  .type hb_unicode_funcs_set_decompose_compatibility_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_decompose_compatibility_func
#endif
hb_unicode_funcs_set_decompose_compatibility_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4112
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4112]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 514 & 0xffff
#if 514 > 0xffff
  movk ip0, 514 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_decompose_func
  .p2align 4
  .type hb_unicode_funcs_set_decompose_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_decompose_func
#endif
hb_unicode_funcs_set_decompose_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4120
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4120]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 515 & 0xffff
#if 515 > 0xffff
  movk ip0, 515 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_eastasian_width_func
  .p2align 4
  .type hb_unicode_funcs_set_eastasian_width_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_eastasian_width_func
#endif
hb_unicode_funcs_set_eastasian_width_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4128
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4128]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 516 & 0xffff
#if 516 > 0xffff
  movk ip0, 516 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_general_category_func
  .p2align 4
  .type hb_unicode_funcs_set_general_category_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_general_category_func
#endif
hb_unicode_funcs_set_general_category_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4136
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4136]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 517 & 0xffff
#if 517 > 0xffff
  movk ip0, 517 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_mirroring_func
  .p2align 4
  .type hb_unicode_funcs_set_mirroring_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_mirroring_func
#endif
hb_unicode_funcs_set_mirroring_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4144
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4144]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 518 & 0xffff
#if 518 > 0xffff
  movk ip0, 518 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_script_func
  .p2align 4
  .type hb_unicode_funcs_set_script_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_script_func
#endif
hb_unicode_funcs_set_script_func:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4152
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4152]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 519 & 0xffff
#if 519 > 0xffff
  movk ip0, 519 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_funcs_set_user_data
  .p2align 4
  .type hb_unicode_funcs_set_user_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_funcs_set_user_data
#endif
hb_unicode_funcs_set_user_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4160
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4160]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 520 & 0xffff
#if 520 > 0xffff
  movk ip0, 520 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_general_category
  .p2align 4
  .type hb_unicode_general_category, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_general_category
#endif
hb_unicode_general_category:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4168
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4168]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 521 & 0xffff
#if 521 > 0xffff
  movk ip0, 521 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_mirroring
  .p2align 4
  .type hb_unicode_mirroring, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_mirroring
#endif
hb_unicode_mirroring:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4176
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4176]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 522 & 0xffff
#if 522 > 0xffff
  movk ip0, 522 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_unicode_script
  .p2align 4
  .type hb_unicode_script, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_unicode_script
#endif
hb_unicode_script:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4184
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4184]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 523 & 0xffff
#if 523 > 0xffff
  movk ip0, 523 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_variation_from_string
  .p2align 4
  .type hb_variation_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_variation_from_string
#endif
hb_variation_from_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4192
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4192]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 524 & 0xffff
#if 524 > 0xffff
  movk ip0, 524 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_variation_to_string
  .p2align 4
  .type hb_variation_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_variation_to_string
#endif
hb_variation_to_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4200
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4200]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 525 & 0xffff
#if 525 > 0xffff
  movk ip0, 525 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_version
  .p2align 4
  .type hb_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_version
#endif
hb_version:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4208
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4208]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 526 & 0xffff
#if 526 > 0xffff
  movk ip0, 526 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_version_atleast
  .p2align 4
  .type hb_version_atleast, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_version_atleast
#endif
hb_version_atleast:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4216
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4216]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 527 & 0xffff
#if 527 > 0xffff
  movk ip0, 527 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl hb_version_string
  .p2align 4
  .type hb_version_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden hb_version_string
#endif
hb_version_string:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libharfbuzz_so_tramp_table+4224
  ldr ip0, [ip0, #:lo12:_libharfbuzz_so_tramp_table+4224]
 
  cbz ip0, 2f

  // Fast path
  br ip0

2:
  // Slow path
  mov ip0, 528 & 0xffff
#if 528 > 0xffff
  movk ip0, 528 >> 16, lsl #16
#endif
  stp ip0, lr, [sp, #-16]!; .cfi_adjust_cfa_offset 16; .cfi_rel_offset lr, 8
  bl _libharfbuzz_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

