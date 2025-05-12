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

  .globl _libcairo_gobject_so_tramp_table
  .hidden _libcairo_gobject_so_tramp_table
  .align 4
_libcairo_gobject_so_tramp_table:
  .zero 144

  .text

  .globl _libcairo_gobject_so_tramp_resolve
  .hidden _libcairo_gobject_so_tramp_resolve

  .globl _libcairo_gobject_so_save_regs_and_resolve
  .hidden _libcairo_gobject_so_save_regs_and_resolve
  .type _libcairo_gobject_so_save_regs_and_resolve, %function
_libcairo_gobject_so_save_regs_and_resolve:
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

  bl _libcairo_gobject_so_tramp_resolve(PLT)
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

  .globl cairo_gobject_antialias_get_type
  .p2align 4
  .type cairo_gobject_antialias_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_antialias_get_type
#endif
cairo_gobject_antialias_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 0

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_content_get_type
  .p2align 4
  .type cairo_gobject_content_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_content_get_type
#endif
cairo_gobject_content_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 4

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_context_get_type
  .p2align 4
  .type cairo_gobject_context_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_context_get_type
#endif
cairo_gobject_context_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 8

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_device_get_type
  .p2align 4
  .type cairo_gobject_device_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_device_get_type
#endif
cairo_gobject_device_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 12

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_device_type_get_type
  .p2align 4
  .type cairo_gobject_device_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_device_type_get_type
#endif
cairo_gobject_device_type_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 16

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_extend_get_type
  .p2align 4
  .type cairo_gobject_extend_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_extend_get_type
#endif
cairo_gobject_extend_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 20

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_fill_rule_get_type
  .p2align 4
  .type cairo_gobject_fill_rule_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_fill_rule_get_type
#endif
cairo_gobject_fill_rule_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 24

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_filter_get_type
  .p2align 4
  .type cairo_gobject_filter_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_filter_get_type
#endif
cairo_gobject_filter_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 28

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_font_face_get_type
  .p2align 4
  .type cairo_gobject_font_face_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_font_face_get_type
#endif
cairo_gobject_font_face_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 32

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_font_options_get_type
  .p2align 4
  .type cairo_gobject_font_options_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_font_options_get_type
#endif
cairo_gobject_font_options_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 36

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_font_slant_get_type
  .p2align 4
  .type cairo_gobject_font_slant_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_font_slant_get_type
#endif
cairo_gobject_font_slant_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 40

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_font_type_get_type
  .p2align 4
  .type cairo_gobject_font_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_font_type_get_type
#endif
cairo_gobject_font_type_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 44

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_font_weight_get_type
  .p2align 4
  .type cairo_gobject_font_weight_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_font_weight_get_type
#endif
cairo_gobject_font_weight_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 48

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_format_get_type
  .p2align 4
  .type cairo_gobject_format_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_format_get_type
#endif
cairo_gobject_format_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 52

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_glyph_get_type
  .p2align 4
  .type cairo_gobject_glyph_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_glyph_get_type
#endif
cairo_gobject_glyph_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 56

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_hint_metrics_get_type
  .p2align 4
  .type cairo_gobject_hint_metrics_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_hint_metrics_get_type
#endif
cairo_gobject_hint_metrics_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 60

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_hint_style_get_type
  .p2align 4
  .type cairo_gobject_hint_style_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_hint_style_get_type
#endif
cairo_gobject_hint_style_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 64

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_line_cap_get_type
  .p2align 4
  .type cairo_gobject_line_cap_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_line_cap_get_type
#endif
cairo_gobject_line_cap_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 68

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_line_join_get_type
  .p2align 4
  .type cairo_gobject_line_join_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_line_join_get_type
#endif
cairo_gobject_line_join_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 72

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_matrix_get_type
  .p2align 4
  .type cairo_gobject_matrix_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_matrix_get_type
#endif
cairo_gobject_matrix_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 76

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_operator_get_type
  .p2align 4
  .type cairo_gobject_operator_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_operator_get_type
#endif
cairo_gobject_operator_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 80

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_path_data_type_get_type
  .p2align 4
  .type cairo_gobject_path_data_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_path_data_type_get_type
#endif
cairo_gobject_path_data_type_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 84

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_pattern_get_type
  .p2align 4
  .type cairo_gobject_pattern_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_pattern_get_type
#endif
cairo_gobject_pattern_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 88

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_pattern_type_get_type
  .p2align 4
  .type cairo_gobject_pattern_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_pattern_type_get_type
#endif
cairo_gobject_pattern_type_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 92

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_rectangle_get_type
  .p2align 4
  .type cairo_gobject_rectangle_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_rectangle_get_type
#endif
cairo_gobject_rectangle_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 96

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_rectangle_int_get_type
  .p2align 4
  .type cairo_gobject_rectangle_int_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_rectangle_int_get_type
#endif
cairo_gobject_rectangle_int_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 100

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_region_get_type
  .p2align 4
  .type cairo_gobject_region_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_region_get_type
#endif
cairo_gobject_region_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 104

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_region_overlap_get_type
  .p2align 4
  .type cairo_gobject_region_overlap_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_region_overlap_get_type
#endif
cairo_gobject_region_overlap_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 108

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_scaled_font_get_type
  .p2align 4
  .type cairo_gobject_scaled_font_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_scaled_font_get_type
#endif
cairo_gobject_scaled_font_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 112

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_status_get_type
  .p2align 4
  .type cairo_gobject_status_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_status_get_type
#endif
cairo_gobject_status_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 116

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_subpixel_order_get_type
  .p2align 4
  .type cairo_gobject_subpixel_order_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_subpixel_order_get_type
#endif
cairo_gobject_subpixel_order_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 120

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_surface_get_type
  .p2align 4
  .type cairo_gobject_surface_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_surface_get_type
#endif
cairo_gobject_surface_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 124

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_surface_type_get_type
  .p2align 4
  .type cairo_gobject_surface_type_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_surface_type_get_type
#endif
cairo_gobject_surface_type_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 128

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_text_cluster_flags_get_type
  .p2align 4
  .type cairo_gobject_text_cluster_flags_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_text_cluster_flags_get_type
#endif
cairo_gobject_text_cluster_flags_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 132

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cairo_gobject_text_cluster_get_type
  .p2align 4
  .type cairo_gobject_text_cluster_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cairo_gobject_text_cluster_get_type
#endif
cairo_gobject_text_cluster_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libcairo_gobject_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libcairo_gobject_so_tramp_table - (2b + 8) + 136

