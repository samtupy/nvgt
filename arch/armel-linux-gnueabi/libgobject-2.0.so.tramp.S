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

  .globl _libgobject_2_0_so_tramp_table
  .hidden _libgobject_2_0_so_tramp_table
  .align 4
_libgobject_2_0_so_tramp_table:
  .zero 1920

  .text

  .globl _libgobject_2_0_so_tramp_resolve
  .hidden _libgobject_2_0_so_tramp_resolve

  .globl _libgobject_2_0_so_save_regs_and_resolve
  .hidden _libgobject_2_0_so_save_regs_and_resolve
  .type _libgobject_2_0_so_save_regs_and_resolve, %function
_libgobject_2_0_so_save_regs_and_resolve:
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

  bl _libgobject_2_0_so_tramp_resolve(PLT)
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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 0

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 4

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 8

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 12

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 16

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 20

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 24

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 28

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 32

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 36

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 40

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 44

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 48

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 52

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 56

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 60

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 64

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 68

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 72

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 76

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 80

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 84

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 88

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 92

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 96

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 100

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 104

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 108

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 112

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 116

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 120

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 124

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 128

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 132

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 136

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 140

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 144

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 148

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 152

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 156

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 160

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 164

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 168

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 172

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 176

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 180

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 184

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 188

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 192

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 196

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 200

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 204

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 208

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 212

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 216

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 220

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 224

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 228

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 232

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 236

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 240

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 244

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 248

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 252

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 256

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 260

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 264

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 268

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 272

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 276

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 280

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 284

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 288

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 292

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 296

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 300

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 304

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 308

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 312

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 316

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 320

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 324

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 328

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 332

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 336

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 340

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 344

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 348

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 352

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 356

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 360

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 364

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 368

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 372

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 376

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 380

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 384

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 388

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 392

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 396

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 400

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 404

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 408

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 412

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 416

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 420

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 424

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 428

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 432

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 436

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 440

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 444

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 448

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 452

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 456

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 460

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 464

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 468

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 472

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 476

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 480

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 484

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 488

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 492

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 496

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 500

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 504

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 508

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 512

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 516

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 520

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 524

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 528

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 532

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 536

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 540

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 544

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 548

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 552

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 556

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 560

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 564

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 568

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 572

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 576

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 580

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 584

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 588

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 592

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 596

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 600

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 604

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 608

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 612

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 616

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 620

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 624

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 628

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 632

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 636

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 640

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 644

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 648

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 652

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 656

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 660

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 664

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 668

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 672

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 676

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 680

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 684

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 688

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 692

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 696

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 700

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 704

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 708

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 712

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 716

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 720

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 724

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 728

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 732

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 736

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 740

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 744

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 748

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 752

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 756

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 760

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 764

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 768

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 772

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 776

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 780

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 784

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 788

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 792

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 796

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 800

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 804

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 808

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 812

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 816

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 820

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 824

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 828

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 832

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 836

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 840

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 844

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 848

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 852

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 856

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 860

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 864

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 868

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 872

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 876

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 880

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 884

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 888

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 892

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 896

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 900

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 904

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 908

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 912

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 916

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 920

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 924

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 928

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 932

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 936

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 940

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 944

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 948

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 952

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 956

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 960

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 964

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 968

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 972

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 976

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 980

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 984

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 988

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 992

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 996

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1000

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1004

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1008

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1012

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1016

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1020

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1024

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1028

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1032

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1036

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1040

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1044

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1048

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1052

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1056

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1060

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1064

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1068

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1072

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1076

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1080

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1084

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1088

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1092

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1096

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1100

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1104

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1108

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1112

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1116

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1120

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1124

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1128

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1132

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1136

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1140

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1144

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1148

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1152

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1156

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1160

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1164

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1168

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1172

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1176

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1180

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1184

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1188

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1192

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1196

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1200

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1204

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1208

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1212

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1216

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1220

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1224

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1228

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1232

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1236

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1240

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1244

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1248

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1252

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1256

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1260

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1264

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1268

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1272

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1276

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1280

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1284

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1288

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1292

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1296

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1300

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1304

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1308

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1312

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1316

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1320

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1324

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1328

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1332

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1336

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1340

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1344

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1348

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1352

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1356

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1360

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1364

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1368

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1372

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1376

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1380

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1384

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1388

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1392

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1396

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1400

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1404

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1408

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1412

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1416

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1420

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1424

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1428

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1432

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1436

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1440

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1444

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1448

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1452

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1456

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1460

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1464

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1468

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1472

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1476

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1480

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1484

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1488

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1492

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1496

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1500

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1504

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1508

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1512

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1516

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1520

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1524

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1528

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1532

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1536

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1540

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1544

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1548

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1552

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1556

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1560

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1564

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1568

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1572

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1576

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1580

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1584

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1588

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1592

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1596

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1600

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1604

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1608

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1612

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1616

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1620

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1624

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1628

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1632

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1636

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1640

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1644

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1648

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1652

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1656

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1660

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1664

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1668

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1672

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1676

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1680

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1684

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1688

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1692

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1696

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1700

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1704

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1708

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1712

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1716

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1720

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1724

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1728

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1732

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1736

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1740

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1744

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1748

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1752

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1756

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1760

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1764

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1768

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1772

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1776

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1780

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1784

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1788

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1792

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1796

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1800

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1804

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1808

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1812

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1816

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1820

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1824

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1828

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1832

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1836

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1840

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1844

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1848

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1852

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1856

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1860

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1864

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1868

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1872

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1876

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1880

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1884

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1888

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1892

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1896

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1900

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1904

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1908

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
  bl _libgobject_2_0_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libgobject_2_0_so_tramp_table - (2b + 8) + 1912

