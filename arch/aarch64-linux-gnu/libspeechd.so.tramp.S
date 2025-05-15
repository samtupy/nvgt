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

  .globl _libspeechd_so_tramp_table
  .hidden _libspeechd_so_tramp_table
  .align 8
_libspeechd_so_tramp_table:
  .zero 696

  .text

  .globl _libspeechd_so_tramp_resolve
  .hidden _libspeechd_so_tramp_resolve

  .globl _libspeechd_so_save_regs_and_resolve
  .hidden _libspeechd_so_save_regs_and_resolve
  .type _libspeechd_so_save_regs_and_resolve, %function
_libspeechd_so_save_regs_and_resolve:
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

  bl _libspeechd_so_tramp_resolve
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

  .globl SPDConnectionAddress__free
  .p2align 4
  .type SPDConnectionAddress__free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SPDConnectionAddress__free
#endif
SPDConnectionAddress__free:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+0
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+0]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_modules
  .p2align 4
  .type free_spd_modules, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_modules
#endif
free_spd_modules:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+8
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+8]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_symbolic_voices
  .p2align 4
  .type free_spd_symbolic_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_symbolic_voices
#endif
free_spd_symbolic_voices:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+16
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+16]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl free_spd_voices
  .p2align 4
  .type free_spd_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden free_spd_voices
#endif
free_spd_voices:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+24
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+24]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel
  .p2align 4
  .type spd_cancel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel
#endif
spd_cancel:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+32
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+32]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel_all
  .p2align 4
  .type spd_cancel_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel_all
#endif
spd_cancel_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+40
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+40]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_cancel_uid
  .p2align 4
  .type spd_cancel_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_cancel_uid
#endif
spd_cancel_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+48
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+48]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_char
  .p2align 4
  .type spd_char, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_char
#endif
spd_char:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+56
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+56]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_close
  .p2align 4
  .type spd_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_close
#endif
spd_close:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+64
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+64]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command
  .p2align 4
  .type spd_execute_command, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command
#endif
spd_execute_command:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+72
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+72]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_with_list_reply
  .p2align 4
  .type spd_execute_command_with_list_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_with_list_reply
#endif
spd_execute_command_with_list_reply:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+80
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+80]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_with_reply
  .p2align 4
  .type spd_execute_command_with_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_with_reply
#endif
spd_execute_command_with_reply:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+88
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+88]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_execute_command_wo_mutex
  .p2align 4
  .type spd_execute_command_wo_mutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_execute_command_wo_mutex
#endif
spd_execute_command_wo_mutex:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+96
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+96]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_fd
  .p2align 4
  .type spd_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_fd
#endif
spd_fd:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+104
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+104]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_client_id
  .p2align 4
  .type spd_get_client_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_client_id
#endif
spd_get_client_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+112
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+112]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_default_address
  .p2align 4
  .type spd_get_default_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_default_address
#endif
spd_get_default_address:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+120
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+120]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_language
  .p2align 4
  .type spd_get_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_language
#endif
spd_get_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+128
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+128]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_message_list_fd
  .p2align 4
  .type spd_get_message_list_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_message_list_fd
#endif
spd_get_message_list_fd:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+136
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+136]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_output_module
  .p2align 4
  .type spd_get_output_module, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_output_module
#endif
spd_get_output_module:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+144
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+144]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_pitch
  .p2align 4
  .type spd_get_voice_pitch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_pitch
#endif
spd_get_voice_pitch:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+152
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+152]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_rate
  .p2align 4
  .type spd_get_voice_rate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_rate
#endif
spd_get_voice_rate:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+160
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+160]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_voice_type
  .p2align 4
  .type spd_get_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_voice_type
#endif
spd_get_voice_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+168
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+168]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_get_volume
  .p2align 4
  .type spd_get_volume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_get_volume
#endif
spd_get_volume:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+176
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+176]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_key
  .p2align 4
  .type spd_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_key
#endif
spd_key:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+184
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+184]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_modules
  .p2align 4
  .type spd_list_modules, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_modules
#endif
spd_list_modules:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+192
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+192]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_synthesis_voices
  .p2align 4
  .type spd_list_synthesis_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_synthesis_voices
#endif
spd_list_synthesis_voices:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+200
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+200]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_synthesis_voices2
  .p2align 4
  .type spd_list_synthesis_voices2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_synthesis_voices2
#endif
spd_list_synthesis_voices2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+208
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+208]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_list_voices
  .p2align 4
  .type spd_list_voices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_list_voices
#endif
spd_list_voices:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+216
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+216]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_open
  .p2align 4
  .type spd_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_open
#endif
spd_open:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+224
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+224]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_open2
  .p2align 4
  .type spd_open2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_open2
#endif
spd_open2:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+232
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+232]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause
  .p2align 4
  .type spd_pause, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause
#endif
spd_pause:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+240
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+240]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause_all
  .p2align 4
  .type spd_pause_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause_all
#endif
spd_pause_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+248
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+248]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_pause_uid
  .p2align 4
  .type spd_pause_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_pause_uid
#endif
spd_pause_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+256
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+256]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume
  .p2align 4
  .type spd_resume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume
#endif
spd_resume:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+264
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+264]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume_all
  .p2align 4
  .type spd_resume_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume_all
#endif
spd_resume_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+272
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+272]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_resume_uid
  .p2align 4
  .type spd_resume_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_resume_uid
#endif
spd_resume_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+280
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+280]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_say
  .p2align 4
  .type spd_say, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_say
#endif
spd_say:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+288
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+288]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_sayf
  .p2align 4
  .type spd_sayf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_sayf
#endif
spd_sayf:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+296
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+296]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_send_data
  .p2align 4
  .type spd_send_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_send_data
#endif
spd_send_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+304
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+304]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_send_data_wo_mutex
  .p2align 4
  .type spd_send_data_wo_mutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_send_data_wo_mutex
#endif
spd_send_data_wo_mutex:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+312
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+312]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters
  .p2align 4
  .type spd_set_capital_letters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters
#endif
spd_set_capital_letters:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+320
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+320]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters_all
  .p2align 4
  .type spd_set_capital_letters_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters_all
#endif
spd_set_capital_letters_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+328
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+328]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_capital_letters_uid
  .p2align 4
  .type spd_set_capital_letters_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_capital_letters_uid
#endif
spd_set_capital_letters_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+336
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+336]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_data_mode
  .p2align 4
  .type spd_set_data_mode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_data_mode
#endif
spd_set_data_mode:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+344
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+344]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language
  .p2align 4
  .type spd_set_language, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language
#endif
spd_set_language:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+352
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+352]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language_all
  .p2align 4
  .type spd_set_language_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language_all
#endif
spd_set_language_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+360
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+360]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_language_uid
  .p2align 4
  .type spd_set_language_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_language_uid
#endif
spd_set_language_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+368
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+368]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification
  .p2align 4
  .type spd_set_notification, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification
#endif
spd_set_notification:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+376
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+376]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification_off
  .p2align 4
  .type spd_set_notification_off, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification_off
#endif
spd_set_notification_off:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+384
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+384]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_notification_on
  .p2align 4
  .type spd_set_notification_on, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_notification_on
#endif
spd_set_notification_on:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+392
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+392]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module
  .p2align 4
  .type spd_set_output_module, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module
#endif
spd_set_output_module:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+400
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+400]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module_all
  .p2align 4
  .type spd_set_output_module_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module_all
#endif
spd_set_output_module_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+408
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+408]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_output_module_uid
  .p2align 4
  .type spd_set_output_module_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_output_module_uid
#endif
spd_set_output_module_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+416
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+416]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation
  .p2align 4
  .type spd_set_punctuation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation
#endif
spd_set_punctuation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+424
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+424]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation_all
  .p2align 4
  .type spd_set_punctuation_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation_all
#endif
spd_set_punctuation_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+432
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+432]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_punctuation_uid
  .p2align 4
  .type spd_set_punctuation_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_punctuation_uid
#endif
spd_set_punctuation_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+440
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+440]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling
  .p2align 4
  .type spd_set_spelling, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling
#endif
spd_set_spelling:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+448
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+448]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling_all
  .p2align 4
  .type spd_set_spelling_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling_all
#endif
spd_set_spelling_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+456
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+456]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_spelling_uid
  .p2align 4
  .type spd_set_spelling_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_spelling_uid
#endif
spd_set_spelling_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+464
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+464]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice
  .p2align 4
  .type spd_set_synthesis_voice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice
#endif
spd_set_synthesis_voice:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+472
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+472]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice_all
  .p2align 4
  .type spd_set_synthesis_voice_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice_all
#endif
spd_set_synthesis_voice_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+480
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+480]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_synthesis_voice_uid
  .p2align 4
  .type spd_set_synthesis_voice_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_synthesis_voice_uid
#endif
spd_set_synthesis_voice_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+488
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+488]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch
  .p2align 4
  .type spd_set_voice_pitch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch
#endif
spd_set_voice_pitch:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+496
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+496]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_all
  .p2align 4
  .type spd_set_voice_pitch_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_all
#endif
spd_set_voice_pitch_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+504
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+504]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range
  .p2align 4
  .type spd_set_voice_pitch_range, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range
#endif
spd_set_voice_pitch_range:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+512
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+512]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range_all
  .p2align 4
  .type spd_set_voice_pitch_range_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range_all
#endif
spd_set_voice_pitch_range_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+520
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+520]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_range_uid
  .p2align 4
  .type spd_set_voice_pitch_range_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_range_uid
#endif
spd_set_voice_pitch_range_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+528
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+528]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_pitch_uid
  .p2align 4
  .type spd_set_voice_pitch_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_pitch_uid
#endif
spd_set_voice_pitch_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+536
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+536]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate
  .p2align 4
  .type spd_set_voice_rate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate
#endif
spd_set_voice_rate:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+544
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+544]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate_all
  .p2align 4
  .type spd_set_voice_rate_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate_all
#endif
spd_set_voice_rate_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+552
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+552]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_rate_uid
  .p2align 4
  .type spd_set_voice_rate_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_rate_uid
#endif
spd_set_voice_rate_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+560
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+560]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type
  .p2align 4
  .type spd_set_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type
#endif
spd_set_voice_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+568
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+568]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type_all
  .p2align 4
  .type spd_set_voice_type_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type_all
#endif
spd_set_voice_type_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+576
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+576]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_voice_type_uid
  .p2align 4
  .type spd_set_voice_type_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_voice_type_uid
#endif
spd_set_voice_type_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+584
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+584]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume
  .p2align 4
  .type spd_set_volume, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume
#endif
spd_set_volume:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+592
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+592]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume_all
  .p2align 4
  .type spd_set_volume_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume_all
#endif
spd_set_volume_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+600
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+600]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_set_volume_uid
  .p2align 4
  .type spd_set_volume_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_set_volume_uid
#endif
spd_set_volume_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+608
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+608]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_sound_icon
  .p2align 4
  .type spd_sound_icon, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_sound_icon
#endif
spd_sound_icon:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+616
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+616]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop
  .p2align 4
  .type spd_stop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop
#endif
spd_stop:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+624
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+624]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop_all
  .p2align 4
  .type spd_stop_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop_all
#endif
spd_stop_all:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+632
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+632]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_stop_uid
  .p2align 4
  .type spd_stop_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_stop_uid
#endif
spd_stop_uid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+640
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+640]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_capital_letters
  .p2align 4
  .type spd_w_set_capital_letters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_capital_letters
#endif
spd_w_set_capital_letters:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+648
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+648]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_punctuation
  .p2align 4
  .type spd_w_set_punctuation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_punctuation
#endif
spd_w_set_punctuation:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+656
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+656]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_spelling
  .p2align 4
  .type spd_w_set_spelling, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_spelling
#endif
spd_w_set_spelling:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+664
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+664]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_w_set_voice_type
  .p2align 4
  .type spd_w_set_voice_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_w_set_voice_type
#endif
spd_w_set_voice_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+672
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+672]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl spd_wchar
  .p2align 4
  .type spd_wchar, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden spd_wchar
#endif
spd_wchar:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  adrp ip0, _libspeechd_so_tramp_table+680
  ldr ip0, [ip0, #:lo12:_libspeechd_so_tramp_table+680]
 
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
  bl _libspeechd_so_save_regs_and_resolve
  ldp xzr, lr, [sp], #16; .cfi_adjust_cfa_offset -16; .cfi_restore lr
  br ip0
  .cfi_endproc

