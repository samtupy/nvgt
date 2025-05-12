/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .section .note.GNU-stack,"",%progbits

  .data

  .globl _libcairo_so_tramp_table
  .hidden _libcairo_so_tramp_table
  .align 4
_libcairo_so_tramp_table:
  .zero 1684

  .text

  .globl _libcairo_so_tramp_resolve
  .hidden _libcairo_so_tramp_resolve

  .globl _libcairo_so_save_regs_and_resolve
  .hidden _libcairo_so_save_regs_and_resolve
  .type _libcairo_so_save_regs_and_resolve, %function
_libcairo_so_save_regs_and_resolve:
  .cfi_startproc

#define PUSH_REG(reg) push {reg}; .cfi_adjust_cfa_offset 4; .cfi_rel_offset reg, 0
#define POP_REG(reg) pop {reg} ; .cfi_adjust_cfa_offset -4; .cfi_restore reg

// Binutils 2.30 does not like q0 in .cfi_rel_offset
#define PUSH_DREG_PAIR(reg1, reg2) vpush {reg1, reg2}; .cfi_adjust_cfa_offset 16; .cfi_rel_offset reg1, 0; .cfi_rel_offset reg2, 8
#define POP_DREG_PAIR(reg1, reg2) vpop {reg1, reg2}; .cfi_adjust_cfa_offset -16; .cfi_restore reg1; .cfi_restore reg2

  // Slow path which calls dlsym, taken only on first call.
  // Registers are saved acc. to "Procedure Call Standard for the ARM Architecture".
  // For DWARF directives, read https://www.imperialviolet.org/2017/01/18/cfi.html.

  // Stack is aligned at 16 bytes at this point

  // Save only arguments (and lr)
  PUSH_REG(r0)
  ldr r0, [sp, #8]
  PUSH_REG(r1)
  PUSH_REG(r2)
  PUSH_REG(r3)
  PUSH_REG(lr)
  PUSH_REG(lr)  // Align to 8 bytes

  // Arguments can be passed in VFP registers only when hard-float ABI is used
  // for arm-gnueabihf target // (http://android-doc.github.io/ndk/guides/abis.html#v7a).
  // Use compiler macro to detect this case.
#ifdef __ARM_PCS_VFP
  PUSH_DREG_PAIR(d0, d1)
  PUSH_DREG_PAIR(d2, d3)
  PUSH_DREG_PAIR(d4, d5)
  PUSH_DREG_PAIR(d6, d7)
  PUSH_DREG_PAIR(d8, d9)
  PUSH_DREG_PAIR(d10, d11)
  PUSH_DREG_PAIR(d12, d13)
  PUSH_DREG_PAIR(d14, d15)
  // FIXME: NEON actually supports 32 D-registers but it's unclear how to detect this
#endif

  bl _libcairo_so_tramp_resolve(PLT)
  mov ip, r0

#ifdef __ARM_PCS_VFP
  POP_DREG_PAIR(d14, d15)
  POP_DREG_PAIR(d12, d13)
  POP_DREG_PAIR(d10, d11)
  POP_DREG_PAIR(d8, d9)
  POP_DREG_PAIR(d6, d7)
  POP_DREG_PAIR(d4, d5)
  POP_DREG_PAIR(d2, d3)
  POP_DREG_PAIR(d0, d1)
#endif

  POP_REG(lr)  // TODO: pop pc?
  POP_REG(lr)
  POP_REG(r3)
  POP_REG(r2)
  POP_REG(r1)
  POP_REG(r0)

  bx lr

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =0
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 0

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =1
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 4

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =2
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 8

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =3
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 12

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =4
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 16

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =5
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 20

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =6
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 24

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =7
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 28

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =8
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 32

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =9
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 36

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =10
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 40

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =11
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 44

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =12
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 48

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =13
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 52

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =14
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 56

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =15
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 60

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =16
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 64

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =17
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 68

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =18
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 72

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =19
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 76

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =20
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 80

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =21
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 84

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =22
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 88

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =23
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 92

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =24
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 96

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =25
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 100

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =26
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 104

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =27
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 108

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =28
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 112

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =29
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 116

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =30
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 120

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =31
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 124

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =32
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 128

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =33
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 132

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =34
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 136

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =35
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 140

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =36
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 144

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =37
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 148

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =38
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 152

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =39
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 156

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =40
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 160

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =41
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 164

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =42
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 168

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =43
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 172

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =44
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 176

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =45
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 180

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =46
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 184

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =47
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 188

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =48
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 192

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =49
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 196

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =50
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 200

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =51
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 204

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =52
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 208

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =53
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 212

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =54
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 216

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =55
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 220

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =56
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 224

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =57
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 228

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =58
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 232

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =59
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 236

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =60
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 240

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =61
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 244

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =62
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 248

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =63
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 252

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =64
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 256

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =65
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 260

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =66
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 264

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =67
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 268

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =68
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 272

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =69
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 276

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =70
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 280

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =71
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 284

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =72
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 288

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =73
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 292

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =74
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 296

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =75
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 300

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =76
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 304

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =77
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 308

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =78
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 312

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =79
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 316

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =80
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 320

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =81
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 324

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =82
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 328

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =83
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 332

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =84
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 336

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =85
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 340

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =86
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 344

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =87
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 348

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =88
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 352

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =89
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 356

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =90
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 360

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =91
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 364

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =92
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 368

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =93
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 372

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =94
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 376

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =95
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 380

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =96
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 384

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =97
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 388

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =98
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 392

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =99
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 396

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =100
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 400

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =101
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 404

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =102
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 408

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =103
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 412

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =104
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 416

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =105
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 420

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =106
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 424

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =107
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 428

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =108
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 432

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =109
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 436

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =110
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 440

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =111
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 444

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =112
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 448

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =113
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 452

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =114
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 456

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =115
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 460

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =116
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 464

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =117
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 468

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =118
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 472

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =119
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 476

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =120
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 480

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =121
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 484

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =122
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 488

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =123
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 492

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =124
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 496

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =125
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 500

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =126
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 504

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =127
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 508

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =128
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 512

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =129
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 516

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =130
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 520

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =131
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 524

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =132
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 528

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =133
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 532

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =134
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 536

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =135
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 540

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =136
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 544

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =137
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 548

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =138
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 552

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =139
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 556

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =140
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 560

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =141
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 564

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =142
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 568

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =143
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 572

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =144
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 576

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =145
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 580

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =146
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 584

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =147
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 588

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =148
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 592

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =149
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 596

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =150
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 600

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =151
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 604

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =152
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 608

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =153
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 612

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =154
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 616

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =155
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 620

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =156
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 624

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =157
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 628

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =158
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 632

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =159
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 636

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =160
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 640

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =161
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 644

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =162
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 648

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =163
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 652

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =164
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 656

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =165
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 660

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =166
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 664

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =167
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 668

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =168
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 672

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =169
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 676

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =170
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 680

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =171
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 684

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =172
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 688

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =173
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 692

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =174
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 696

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =175
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 700

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =176
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 704

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =177
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 708

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =178
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 712

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =179
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 716

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =180
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 720

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =181
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 724

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =182
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 728

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =183
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 732

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =184
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 736

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =185
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 740

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =186
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 744

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =187
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 748

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =188
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 752

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =189
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 756

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =190
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 760

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =191
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 764

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =192
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 768

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =193
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 772

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =194
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 776

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =195
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 780

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =196
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 784

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =197
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 788

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =198
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 792

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =199
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 796

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =200
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 800

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =201
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 804

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =202
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 808

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =203
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 812

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =204
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 816

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =205
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 820

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =206
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 824

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =207
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 828

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =208
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 832

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =209
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 836

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =210
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 840

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =211
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 844

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =212
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 848

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =213
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 852

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =214
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 856

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =215
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 860

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =216
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 864

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =217
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 868

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =218
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 872

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =219
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 876

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =220
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 880

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =221
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 884

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =222
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 888

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =223
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 892

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =224
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 896

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =225
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 900

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =226
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 904

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =227
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 908

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =228
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 912

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =229
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 916

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =230
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 920

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =231
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 924

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =232
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 928

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =233
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 932

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =234
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 936

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =235
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 940

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =236
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 944

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =237
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 948

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =238
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 952

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =239
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 956

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =240
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 960

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =241
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 964

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =242
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 968

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =243
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 972

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =244
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 976

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =245
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 980

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =246
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 984

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =247
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 988

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =248
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 992

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =249
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 996

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =250
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1000

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =251
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1004

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =252
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1008

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =253
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1012

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =254
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1016

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =255
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1020

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =256
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1024

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =257
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1028

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =258
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1032

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =259
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1036

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =260
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1040

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =261
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1044

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =262
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1048

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =263
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1052

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =264
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1056

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =265
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1060

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =266
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1064

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =267
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1068

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =268
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1072

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =269
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1076

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =270
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1080

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =271
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1084

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =272
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1088

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =273
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1092

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =274
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1096

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =275
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1100

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =276
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1104

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =277
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1108

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =278
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1112

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =279
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1116

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =280
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1120

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =281
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1124

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =282
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1128

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =283
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1132

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =284
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1136

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =285
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1140

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =286
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1144

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =287
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1148

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =288
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1152

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =289
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1156

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =290
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1160

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =291
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1164

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =292
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1168

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =293
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1172

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =294
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1176

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =295
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1180

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =296
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1184

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =297
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1188

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =298
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1192

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =299
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1196

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =300
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1200

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =301
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1204

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =302
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1208

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =303
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1212

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =304
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1216

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =305
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1220

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =306
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1224

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =307
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1228

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =308
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1232

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =309
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1236

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =310
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1240

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =311
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1244

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =312
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1248

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =313
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1252

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =314
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1256

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =315
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1260

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =316
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1264

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =317
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1268

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =318
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1272

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =319
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1276

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =320
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1280

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =321
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1284

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =322
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1288

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =323
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1292

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =324
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1296

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =325
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1300

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =326
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1304

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =327
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1308

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =328
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1312

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =329
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1316

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =330
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1320

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =331
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1324

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =332
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1328

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =333
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1332

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =334
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1336

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =335
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1340

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =336
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1344

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =337
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1348

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =338
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1352

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =339
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1356

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =340
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1360

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =341
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1364

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =342
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1368

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =343
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1372

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =344
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1376

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =345
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1380

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =346
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1384

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =347
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1388

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =348
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1392

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =349
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1396

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =350
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1400

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =351
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1404

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =352
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1408

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =353
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1412

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =354
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1416

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =355
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1420

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =356
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1424

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =357
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1428

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =358
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1432

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =359
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1436

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =360
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1440

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =361
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1444

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =362
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1448

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =363
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1452

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =364
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1456

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =365
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1460

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =366
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1464

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =367
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1468

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =368
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1472

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =369
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1476

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =370
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1480

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =371
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1484

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =372
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1488

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =373
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1492

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =374
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1496

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =375
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1500

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =376
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1504

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =377
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1508

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =378
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1512

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =379
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1516

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =380
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1520

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =381
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1524

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =382
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1528

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =383
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1532

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =384
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1536

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =385
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1540

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =386
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1544

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =387
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1548

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =388
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1552

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =389
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1556

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =390
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1560

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =391
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1564

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =392
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1568

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =393
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1572

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =394
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1576

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =395
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1580

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =396
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1584

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =397
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1588

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =398
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1592

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =399
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1596

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =400
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1600

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =401
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1604

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =402
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1608

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =403
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1612

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =404
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1616

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =405
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1620

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =406
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1624

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =407
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1628

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =408
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1632

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =409
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1636

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =410
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1640

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =411
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1644

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =412
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1648

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =413
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1652

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =414
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1656

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =415
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1660

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =416
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1664

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =417
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1668

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =418
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1672

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =419
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libcairo_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_so_tramp_table - (2b + 8) + 1676

