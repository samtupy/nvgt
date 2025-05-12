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

  .globl _libpango_1_0_so_tramp_table
  .hidden _libpango_1_0_so_tramp_table
  .align 4
_libpango_1_0_so_tramp_table:
  .zero 2020

  .text

  .globl _libpango_1_0_so_tramp_resolve
  .hidden _libpango_1_0_so_tramp_resolve

  .globl _libpango_1_0_so_save_regs_and_resolve
  .hidden _libpango_1_0_so_save_regs_and_resolve
  .type _libpango_1_0_so_save_regs_and_resolve, %function
_libpango_1_0_so_save_regs_and_resolve:
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

  bl _libpango_1_0_so_tramp_resolve(PLT)
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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 0

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 4

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 8

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 12

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 16

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 20

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 24

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 28

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 32

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 36

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 40

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 44

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 48

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 52

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 56

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 60

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 64

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 68

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 72

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 76

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 80

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 84

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 88

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 92

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 96

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 100

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 104

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 108

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 112

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 116

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 120

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 124

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 128

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 132

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 136

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 140

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 144

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 148

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 152

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 156

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 160

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 164

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 168

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 172

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 176

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 180

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 184

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 188

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 192

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 196

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 200

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 204

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 208

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 212

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 216

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 220

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 224

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 228

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 232

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 236

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 240

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 244

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 248

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 252

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 256

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 260

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 264

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 268

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 272

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 276

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 280

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 284

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 288

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 292

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 296

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 300

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 304

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 308

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 312

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 316

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 320

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 324

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 328

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 332

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 336

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 340

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 344

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 348

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 352

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 356

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 360

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 364

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 368

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 372

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 376

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 380

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 384

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 388

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 392

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 396

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 400

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 404

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 408

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 412

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 416

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 420

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 424

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 428

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 432

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 436

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 440

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 444

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 448

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 452

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 456

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 460

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 464

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 468

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 472

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 476

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 480

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 484

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 488

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 492

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 496

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 500

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 504

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 508

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 512

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 516

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 520

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 524

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 528

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 532

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 536

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 540

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 544

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 548

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 552

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 556

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 560

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 564

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 568

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 572

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 576

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 580

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 584

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 588

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 592

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 596

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 600

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 604

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 608

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 612

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 616

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 620

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 624

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 628

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 632

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 636

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 640

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 644

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 648

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 652

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 656

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 660

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 664

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 668

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 672

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 676

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 680

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 684

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 688

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 692

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 696

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 700

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 704

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 708

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 712

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 716

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 720

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 724

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 728

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 732

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 736

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 740

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 744

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 748

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 752

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 756

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 760

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 764

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 768

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 772

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 776

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 780

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 784

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 788

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 792

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 796

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 800

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 804

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 808

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 812

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 816

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 820

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 824

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 828

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 832

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 836

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 840

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 844

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 848

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 852

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 856

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 860

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 864

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 868

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 872

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 876

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 880

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 884

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 888

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 892

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 896

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 900

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 904

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 908

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 912

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 916

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 920

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 924

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 928

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 932

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 936

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 940

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 944

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 948

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 952

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 956

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 960

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 964

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 968

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 972

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 976

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 980

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 984

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 988

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 992

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 996

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1000

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1004

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1008

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1012

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1016

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1020

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1024

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1028

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1032

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1036

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1040

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1044

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1048

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1052

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1056

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1060

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1064

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1068

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1072

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1076

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1080

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1084

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1088

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1092

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1096

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1100

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1104

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1108

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1112

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1116

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1120

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1124

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1128

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1132

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1136

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1140

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1144

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1148

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1152

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1156

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1160

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1164

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1168

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1172

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1176

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1180

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1184

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1188

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1192

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1196

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1200

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1204

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1208

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1212

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1216

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1220

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1224

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1228

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1232

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1236

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1240

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1244

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1248

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1252

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1256

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1260

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1264

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1268

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1272

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1276

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1280

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1284

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1288

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1292

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1296

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1300

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1304

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1308

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1312

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1316

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1320

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1324

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1328

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1332

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1336

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1340

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1344

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1348

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1352

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1356

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1360

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1364

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1368

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1372

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1376

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1380

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1384

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1388

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1392

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1396

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1400

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1404

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1408

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1412

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1416

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1420

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1424

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1428

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1432

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1436

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1440

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1444

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1448

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1452

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1456

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1460

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1464

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1468

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1472

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1476

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1480

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1484

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1488

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1492

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1496

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1500

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1504

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1508

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1512

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1516

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1520

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1524

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1528

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1532

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1536

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1540

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1544

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1548

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1552

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1556

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1560

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1564

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1568

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1572

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1576

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1580

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1584

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1588

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1592

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1596

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1600

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1604

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1608

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1612

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1616

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1620

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1624

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1628

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1632

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1636

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1640

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1644

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1648

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1652

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1656

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1660

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1664

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1668

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1672

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
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1676

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =420
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1680

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =421
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1684

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =422
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1688

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =423
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1692

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =424
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1696

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =425
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1700

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =426
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1704

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =427
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1708

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =428
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1712

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =429
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1716

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =430
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1720

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =431
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1724

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =432
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1728

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =433
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1732

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =434
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1736

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =435
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1740

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =436
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1744

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =437
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1748

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =438
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1752

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =439
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1756

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =440
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1760

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =441
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1764

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =442
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1768

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =443
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1772

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =444
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1776

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =445
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1780

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =446
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1784

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =447
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1788

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =448
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1792

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =449
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1796

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =450
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1800

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =451
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1804

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =452
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1808

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =453
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1812

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =454
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1816

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =455
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1820

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =456
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1824

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =457
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1828

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =458
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1832

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =459
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1836

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =460
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1840

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =461
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1844

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =462
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1848

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =463
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1852

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =464
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1856

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =465
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1860

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =466
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1864

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =467
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1868

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =468
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1872

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =469
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1876

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =470
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1880

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =471
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1884

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =472
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1888

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =473
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1892

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =474
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1896

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =475
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1900

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =476
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1904

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =477
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1908

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =478
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1912

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =479
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1916

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =480
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1920

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =481
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1924

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =482
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1928

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =483
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1932

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =484
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1936

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =485
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1940

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =486
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1944

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =487
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1948

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =488
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1952

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =489
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1956

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =490
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1960

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =491
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1964

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =492
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1968

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =493
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1972

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =494
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1976

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =495
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1980

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =496
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1984

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =497
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1988

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =498
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1992

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =499
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 1996

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =500
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 2000

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =501
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 2004

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =502
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 2008

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
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =503
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libpango_1_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libpango_1_0_so_tramp_table - (2b + 8) + 2012

