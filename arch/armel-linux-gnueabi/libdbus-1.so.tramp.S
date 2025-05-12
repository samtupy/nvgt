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

  .globl _libdbus_1_so_tramp_table
  .hidden _libdbus_1_so_tramp_table
  .align 4
_libdbus_1_so_tramp_table:
  .zero 2284

  .text

  .globl _libdbus_1_so_tramp_resolve
  .hidden _libdbus_1_so_tramp_resolve

  .globl _libdbus_1_so_save_regs_and_resolve
  .hidden _libdbus_1_so_save_regs_and_resolve
  .type _libdbus_1_so_save_regs_and_resolve, %function
_libdbus_1_so_save_regs_and_resolve:
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

  bl _libdbus_1_so_tramp_resolve(PLT)
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

  .globl _dbus_abort
  .p2align 4
  .type _dbus_abort, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_abort
#endif
_dbus_abort:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 0

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_address_append_escaped
  .p2align 4
  .type _dbus_address_append_escaped, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_address_append_escaped
#endif
_dbus_address_append_escaped:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 4

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_append_user_from_current_process
  .p2align 4
  .type _dbus_append_user_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_append_user_from_current_process
#endif
_dbus_append_user_from_current_process:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 8

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_atomic_dec
  .p2align 4
  .type _dbus_atomic_dec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_dec
#endif
_dbus_atomic_dec:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 12

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_atomic_get
  .p2align 4
  .type _dbus_atomic_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_get
#endif
_dbus_atomic_get:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 16

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_atomic_inc
  .p2align 4
  .type _dbus_atomic_inc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_inc
#endif
_dbus_atomic_inc:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 20

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_atomic_set_nonzero
  .p2align 4
  .type _dbus_atomic_set_nonzero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_set_nonzero
#endif
_dbus_atomic_set_nonzero:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 24

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_atomic_set_zero
  .p2align 4
  .type _dbus_atomic_set_zero, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_atomic_set_zero
#endif
_dbus_atomic_set_zero:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 28

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_bytes_sent
  .p2align 4
  .type _dbus_auth_bytes_sent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_bytes_sent
#endif
_dbus_auth_bytes_sent:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 32

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_client_new
  .p2align 4
  .type _dbus_auth_client_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_client_new
#endif
_dbus_auth_client_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 36

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_delete_unused_bytes
  .p2align 4
  .type _dbus_auth_delete_unused_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_delete_unused_bytes
#endif
_dbus_auth_delete_unused_bytes:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 40

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_do_work
  .p2align 4
  .type _dbus_auth_do_work, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_do_work
#endif
_dbus_auth_do_work:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 44

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_dump_supported_mechanisms
  .p2align 4
  .type _dbus_auth_dump_supported_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_dump_supported_mechanisms
#endif
_dbus_auth_dump_supported_mechanisms:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 48

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_get_buffer
  .p2align 4
  .type _dbus_auth_get_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_buffer
#endif
_dbus_auth_get_buffer:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 52

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_get_bytes_to_send
  .p2align 4
  .type _dbus_auth_get_bytes_to_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_bytes_to_send
#endif
_dbus_auth_get_bytes_to_send:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 56

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_get_identity
  .p2align 4
  .type _dbus_auth_get_identity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_identity
#endif
_dbus_auth_get_identity:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 60

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_get_unused_bytes
  .p2align 4
  .type _dbus_auth_get_unused_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_get_unused_bytes
#endif
_dbus_auth_get_unused_bytes:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 64

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_is_supported_mechanism
  .p2align 4
  .type _dbus_auth_is_supported_mechanism, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_is_supported_mechanism
#endif
_dbus_auth_is_supported_mechanism:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 68

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_ref
  .p2align 4
  .type _dbus_auth_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_ref
#endif
_dbus_auth_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 72

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_return_buffer
  .p2align 4
  .type _dbus_auth_return_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_return_buffer
#endif
_dbus_auth_return_buffer:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 76

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_server_new
  .p2align 4
  .type _dbus_auth_server_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_server_new
#endif
_dbus_auth_server_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 80

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_set_context
  .p2align 4
  .type _dbus_auth_set_context, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_context
#endif
_dbus_auth_set_context:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 84

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_set_credentials
  .p2align 4
  .type _dbus_auth_set_credentials, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_credentials
#endif
_dbus_auth_set_credentials:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 88

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_set_mechanisms
  .p2align 4
  .type _dbus_auth_set_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_set_mechanisms
#endif
_dbus_auth_set_mechanisms:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 92

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_auth_unref
  .p2align 4
  .type _dbus_auth_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_auth_unref
#endif
_dbus_auth_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 96

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_clearenv
  .p2align 4
  .type _dbus_clearenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_clearenv
#endif
_dbus_clearenv:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 100

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_close
  .p2align 4
  .type _dbus_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close
#endif
_dbus_close:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 104

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_close_all
  .p2align 4
  .type _dbus_close_all, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close_all
#endif
_dbus_close_all:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 108

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_close_socket
  .p2align 4
  .type _dbus_close_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_close_socket
#endif
_dbus_close_socket:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 112

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_concat_dir_and_file
  .p2align 4
  .type _dbus_concat_dir_and_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_concat_dir_and_file
#endif
_dbus_concat_dir_and_file:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 116

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_get_credentials
  .p2align 4
  .type _dbus_connection_get_credentials, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_credentials
#endif
_dbus_connection_get_credentials:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 120

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_get_linux_security_label
  .p2align 4
  .type _dbus_connection_get_linux_security_label, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_linux_security_label
#endif
_dbus_connection_get_linux_security_label:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 124

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_get_next_client_serial
  .p2align 4
  .type _dbus_connection_get_next_client_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_next_client_serial
#endif
_dbus_connection_get_next_client_serial:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 128

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_get_pending_fds_count
  .p2align 4
  .type _dbus_connection_get_pending_fds_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_pending_fds_count
#endif
_dbus_connection_get_pending_fds_count:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 132

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_get_stats
  .p2align 4
  .type _dbus_connection_get_stats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_get_stats
#endif
_dbus_connection_get_stats:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 136

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_lock
  .p2align 4
  .type _dbus_connection_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_lock
#endif
_dbus_connection_lock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 140

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_ref_unlocked
  .p2align 4
  .type _dbus_connection_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_ref_unlocked
#endif
_dbus_connection_ref_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 144

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_set_pending_fds_function
  .p2align 4
  .type _dbus_connection_set_pending_fds_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_set_pending_fds_function
#endif
_dbus_connection_set_pending_fds_function:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 148

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_unlock
  .p2align 4
  .type _dbus_connection_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_unlock
#endif
_dbus_connection_unlock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 152

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_connection_unref_unlocked
  .p2align 4
  .type _dbus_connection_unref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_connection_unref_unlocked
#endif
_dbus_connection_unref_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 156

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_create_directory
  .p2align 4
  .type _dbus_create_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_create_directory
#endif
_dbus_create_directory:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 160

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_create_uuid
  .p2align 4
  .type _dbus_create_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_create_uuid
#endif
_dbus_create_uuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 164

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_add_pid
  .p2align 4
  .type _dbus_credentials_add_pid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_pid
#endif
_dbus_credentials_add_pid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 168

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_add_unix_uid
  .p2align 4
  .type _dbus_credentials_add_unix_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_unix_uid
#endif
_dbus_credentials_add_unix_uid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 172

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_add_windows_sid
  .p2align 4
  .type _dbus_credentials_add_windows_sid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_add_windows_sid
#endif
_dbus_credentials_add_windows_sid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 176

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_are_anonymous
  .p2align 4
  .type _dbus_credentials_are_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_anonymous
#endif
_dbus_credentials_are_anonymous:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 180

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_are_empty
  .p2align 4
  .type _dbus_credentials_are_empty, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_empty
#endif
_dbus_credentials_are_empty:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 184

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_are_superset
  .p2align 4
  .type _dbus_credentials_are_superset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_are_superset
#endif
_dbus_credentials_are_superset:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 188

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_clear
  .p2align 4
  .type _dbus_credentials_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_clear
#endif
_dbus_credentials_clear:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 192

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_copy
  .p2align 4
  .type _dbus_credentials_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_copy
#endif
_dbus_credentials_copy:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 196

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_linux_security_label
  .p2align 4
  .type _dbus_credentials_get_linux_security_label, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_linux_security_label
#endif
_dbus_credentials_get_linux_security_label:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 200

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_pid
  .p2align 4
  .type _dbus_credentials_get_pid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_pid
#endif
_dbus_credentials_get_pid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 204

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_pid_fd
  .p2align 4
  .type _dbus_credentials_get_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_pid_fd
#endif
_dbus_credentials_get_pid_fd:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 208

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_unix_gids
  .p2align 4
  .type _dbus_credentials_get_unix_gids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_unix_gids
#endif
_dbus_credentials_get_unix_gids:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 212

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_unix_uid
  .p2align 4
  .type _dbus_credentials_get_unix_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_unix_uid
#endif
_dbus_credentials_get_unix_uid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 216

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_get_windows_sid
  .p2align 4
  .type _dbus_credentials_get_windows_sid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_get_windows_sid
#endif
_dbus_credentials_get_windows_sid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 220

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_include
  .p2align 4
  .type _dbus_credentials_include, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_include
#endif
_dbus_credentials_include:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 224

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_new
  .p2align 4
  .type _dbus_credentials_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_new
#endif
_dbus_credentials_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 228

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_new_from_current_process
  .p2align 4
  .type _dbus_credentials_new_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_new_from_current_process
#endif
_dbus_credentials_new_from_current_process:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 232

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_ref
  .p2align 4
  .type _dbus_credentials_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_ref
#endif
_dbus_credentials_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 236

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_same_user
  .p2align 4
  .type _dbus_credentials_same_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_same_user
#endif
_dbus_credentials_same_user:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 240

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_take_pid_fd
  .p2align 4
  .type _dbus_credentials_take_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_take_pid_fd
#endif
_dbus_credentials_take_pid_fd:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 244

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_take_unix_gids
  .p2align 4
  .type _dbus_credentials_take_unix_gids, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_take_unix_gids
#endif
_dbus_credentials_take_unix_gids:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 248

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_to_string_append
  .p2align 4
  .type _dbus_credentials_to_string_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_to_string_append
#endif
_dbus_credentials_to_string_append:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 252

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_credentials_unref
  .p2align 4
  .type _dbus_credentials_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_credentials_unref
#endif
_dbus_credentials_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 256

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_delete_directory
  .p2align 4
  .type _dbus_delete_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_delete_directory
#endif
_dbus_delete_directory:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 260

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_delete_file
  .p2align 4
  .type _dbus_delete_file, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_delete_file
#endif
_dbus_delete_file:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 264

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_dup
  .p2align 4
  .type _dbus_dup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_dup
#endif
_dbus_dup:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 268

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_ensure_directory
  .p2align 4
  .type _dbus_ensure_directory, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_ensure_directory
#endif
_dbus_ensure_directory:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 272

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_ensure_standard_fds
  .p2align 4
  .type _dbus_ensure_standard_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_ensure_standard_fds
#endif
_dbus_ensure_standard_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 276

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_error_from_errno
  .p2align 4
  .type _dbus_error_from_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_error_from_errno
#endif
_dbus_error_from_errno:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 280

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_error_from_system_errno
  .p2align 4
  .type _dbus_error_from_system_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_error_from_system_errno
#endif
_dbus_error_from_system_errno:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 284

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_exit
  .p2align 4
  .type _dbus_exit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_exit
#endif
_dbus_exit:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 288

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_fd_clear_close_on_exec
  .p2align 4
  .type _dbus_fd_clear_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_clear_close_on_exec
#endif
_dbus_fd_clear_close_on_exec:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 292

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_fd_set_all_close_on_exec
  .p2align 4
  .type _dbus_fd_set_all_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_set_all_close_on_exec
#endif
_dbus_fd_set_all_close_on_exec:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 296

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_fd_set_close_on_exec
  .p2align 4
  .type _dbus_fd_set_close_on_exec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_fd_set_close_on_exec
#endif
_dbus_fd_set_close_on_exec:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 300

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_file_get_contents
  .p2align 4
  .type _dbus_file_get_contents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_file_get_contents
#endif
_dbus_file_get_contents:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 304

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_first_type_in_signature
  .p2align 4
  .type _dbus_first_type_in_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_first_type_in_signature
#endif
_dbus_first_type_in_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 308

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_flush_caches
  .p2align 4
  .type _dbus_flush_caches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_flush_caches
#endif
_dbus_flush_caches:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 312

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_generate_random_ascii
  .p2align 4
  .type _dbus_generate_random_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_generate_random_ascii
#endif
_dbus_generate_random_ascii:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 316

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_generate_uuid
  .p2align 4
  .type _dbus_generate_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_generate_uuid
#endif
_dbus_generate_uuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 320

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_get_local_machine_uuid_encoded
  .p2align 4
  .type _dbus_get_local_machine_uuid_encoded, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_local_machine_uuid_encoded
#endif
_dbus_get_local_machine_uuid_encoded:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 324

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_get_monotonic_time
  .p2align 4
  .type _dbus_get_monotonic_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_monotonic_time
#endif
_dbus_get_monotonic_time:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 328

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_get_real_time
  .p2align 4
  .type _dbus_get_real_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_real_time
#endif
_dbus_get_real_time:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 332

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_get_tmpdir
  .p2align 4
  .type _dbus_get_tmpdir, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_tmpdir
#endif
_dbus_get_tmpdir:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 336

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_get_uuid
  .p2align 4
  .type _dbus_get_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_get_uuid
#endif
_dbus_get_uuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 340

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_getenv
  .p2align 4
  .type _dbus_getenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getenv
#endif
_dbus_getenv:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 344

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_geteuid
  .p2align 4
  .type _dbus_geteuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_geteuid
#endif
_dbus_geteuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 348

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_getpid
  .p2align 4
  .type _dbus_getpid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getpid
#endif
_dbus_getpid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 352

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_getuid
  .p2align 4
  .type _dbus_getuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_getuid
#endif
_dbus_getuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 356

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_group_info_unref
  .p2align 4
  .type _dbus_group_info_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_group_info_unref
#endif
_dbus_group_info_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 360

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_get_int_key
  .p2align 4
  .type _dbus_hash_iter_get_int_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_int_key
#endif
_dbus_hash_iter_get_int_key:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 364

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_get_string_key
  .p2align 4
  .type _dbus_hash_iter_get_string_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_string_key
#endif
_dbus_hash_iter_get_string_key:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 368

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_get_uintptr_key
  .p2align 4
  .type _dbus_hash_iter_get_uintptr_key, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_uintptr_key
#endif
_dbus_hash_iter_get_uintptr_key:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 372

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_get_value
  .p2align 4
  .type _dbus_hash_iter_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_get_value
#endif
_dbus_hash_iter_get_value:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 376

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_init
  .p2align 4
  .type _dbus_hash_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_init
#endif
_dbus_hash_iter_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 380

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_lookup
  .p2align 4
  .type _dbus_hash_iter_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_lookup
#endif
_dbus_hash_iter_lookup:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 384

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_next
  .p2align 4
  .type _dbus_hash_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_next
#endif
_dbus_hash_iter_next:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 388

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_remove_entry
  .p2align 4
  .type _dbus_hash_iter_remove_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_remove_entry
#endif
_dbus_hash_iter_remove_entry:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 392

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_iter_set_value
  .p2align 4
  .type _dbus_hash_iter_set_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_iter_set_value
#endif
_dbus_hash_iter_set_value:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 396

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_free_preallocated_entry
  .p2align 4
  .type _dbus_hash_table_free_preallocated_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_free_preallocated_entry
#endif
_dbus_hash_table_free_preallocated_entry:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 400

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_from_array
  .p2align 4
  .type _dbus_hash_table_from_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_from_array
#endif
_dbus_hash_table_from_array:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 404

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_get_n_entries
  .p2align 4
  .type _dbus_hash_table_get_n_entries, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_get_n_entries
#endif
_dbus_hash_table_get_n_entries:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 408

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_insert_int
  .p2align 4
  .type _dbus_hash_table_insert_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_int
#endif
_dbus_hash_table_insert_int:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 412

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_insert_string
  .p2align 4
  .type _dbus_hash_table_insert_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_string
#endif
_dbus_hash_table_insert_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 416

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_insert_string_preallocated
  .p2align 4
  .type _dbus_hash_table_insert_string_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_string_preallocated
#endif
_dbus_hash_table_insert_string_preallocated:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 420

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_insert_uintptr
  .p2align 4
  .type _dbus_hash_table_insert_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_insert_uintptr
#endif
_dbus_hash_table_insert_uintptr:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 424

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_lookup_int
  .p2align 4
  .type _dbus_hash_table_lookup_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_int
#endif
_dbus_hash_table_lookup_int:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 428

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_lookup_string
  .p2align 4
  .type _dbus_hash_table_lookup_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_string
#endif
_dbus_hash_table_lookup_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 432

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_lookup_uintptr
  .p2align 4
  .type _dbus_hash_table_lookup_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_lookup_uintptr
#endif
_dbus_hash_table_lookup_uintptr:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 436

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_new
  .p2align 4
  .type _dbus_hash_table_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_new
#endif
_dbus_hash_table_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 440

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_preallocate_entry
  .p2align 4
  .type _dbus_hash_table_preallocate_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_preallocate_entry
#endif
_dbus_hash_table_preallocate_entry:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 444

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_ref
  .p2align 4
  .type _dbus_hash_table_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_ref
#endif
_dbus_hash_table_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 448

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_remove_int
  .p2align 4
  .type _dbus_hash_table_remove_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_int
#endif
_dbus_hash_table_remove_int:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 452

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_remove_string
  .p2align 4
  .type _dbus_hash_table_remove_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_string
#endif
_dbus_hash_table_remove_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 456

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_remove_uintptr
  .p2align 4
  .type _dbus_hash_table_remove_uintptr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_remove_uintptr
#endif
_dbus_hash_table_remove_uintptr:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 460

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_to_array
  .p2align 4
  .type _dbus_hash_table_to_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_to_array
#endif
_dbus_hash_table_to_array:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 464

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_hash_table_unref
  .p2align 4
  .type _dbus_hash_table_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_hash_table_unref
#endif
_dbus_hash_table_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 468

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_header_delete_field
  .p2align 4
  .type _dbus_header_delete_field, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_delete_field
#endif
_dbus_header_delete_field:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 472

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_header_get_byte_order
  .p2align 4
  .type _dbus_header_get_byte_order, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_get_byte_order
#endif
_dbus_header_get_byte_order:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 476

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_header_get_field_raw
  .p2align 4
  .type _dbus_header_get_field_raw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_get_field_raw
#endif
_dbus_header_get_field_raw:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 480

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_header_set_field_basic
  .p2align 4
  .type _dbus_header_set_field_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_header_set_field_basic
#endif
_dbus_header_set_field_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 484

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_homedir_from_current_process
  .p2align 4
  .type _dbus_homedir_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_homedir_from_current_process
#endif
_dbus_homedir_from_current_process:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 488

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_init_system_log
  .p2align 4
  .type _dbus_init_system_log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_init_system_log
#endif
_dbus_init_system_log:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 492

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_is_a_number
  .p2align 4
  .type _dbus_is_a_number, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_is_a_number
#endif
_dbus_is_a_number:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 496

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_alloc_link
  .p2align 4
  .type _dbus_list_alloc_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_alloc_link
#endif
_dbus_list_alloc_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 500

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_append
  .p2align 4
  .type _dbus_list_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_append
#endif
_dbus_list_append:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 504

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_append_link
  .p2align 4
  .type _dbus_list_append_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_append_link
#endif
_dbus_list_append_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 508

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_clear
  .p2align 4
  .type _dbus_list_clear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_clear
#endif
_dbus_list_clear:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 512

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_clear_full
  .p2align 4
  .type _dbus_list_clear_full, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_clear_full
#endif
_dbus_list_clear_full:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 516

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_copy
  .p2align 4
  .type _dbus_list_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_copy
#endif
_dbus_list_copy:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 520

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_find_last
  .p2align 4
  .type _dbus_list_find_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_find_last
#endif
_dbus_list_find_last:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 524

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_foreach
  .p2align 4
  .type _dbus_list_foreach, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_foreach
#endif
_dbus_list_foreach:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 528

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_free_link
  .p2align 4
  .type _dbus_list_free_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_free_link
#endif
_dbus_list_free_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 532

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_first
  .p2align 4
  .type _dbus_list_get_first, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_first
#endif
_dbus_list_get_first:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 536

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_first_link
  .p2align 4
  .type _dbus_list_get_first_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_first_link
#endif
_dbus_list_get_first_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 540

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_last
  .p2align 4
  .type _dbus_list_get_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_last
#endif
_dbus_list_get_last:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 544

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_last_link
  .p2align 4
  .type _dbus_list_get_last_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_last_link
#endif
_dbus_list_get_last_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 548

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_length
  .p2align 4
  .type _dbus_list_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_length
#endif
_dbus_list_get_length:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 552

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_get_stats
  .p2align 4
  .type _dbus_list_get_stats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_get_stats
#endif
_dbus_list_get_stats:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 556

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_insert_after
  .p2align 4
  .type _dbus_list_insert_after, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_after
#endif
_dbus_list_insert_after:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 560

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_insert_after_link
  .p2align 4
  .type _dbus_list_insert_after_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_after_link
#endif
_dbus_list_insert_after_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 564

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_insert_before_link
  .p2align 4
  .type _dbus_list_insert_before_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_insert_before_link
#endif
_dbus_list_insert_before_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 568

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_length_is_one
  .p2align 4
  .type _dbus_list_length_is_one, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_length_is_one
#endif
_dbus_list_length_is_one:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 572

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_pop_first
  .p2align 4
  .type _dbus_list_pop_first, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_first
#endif
_dbus_list_pop_first:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 576

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_pop_first_link
  .p2align 4
  .type _dbus_list_pop_first_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_first_link
#endif
_dbus_list_pop_first_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 580

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_pop_last
  .p2align 4
  .type _dbus_list_pop_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_pop_last
#endif
_dbus_list_pop_last:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 584

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_prepend
  .p2align 4
  .type _dbus_list_prepend, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_prepend
#endif
_dbus_list_prepend:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 588

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_prepend_link
  .p2align 4
  .type _dbus_list_prepend_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_prepend_link
#endif
_dbus_list_prepend_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 592

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_remove
  .p2align 4
  .type _dbus_list_remove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove
#endif
_dbus_list_remove:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 596

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_remove_last
  .p2align 4
  .type _dbus_list_remove_last, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove_last
#endif
_dbus_list_remove_last:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 600

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_remove_link
  .p2align 4
  .type _dbus_list_remove_link, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_remove_link
#endif
_dbus_list_remove_link:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 604

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_list_unlink
  .p2align 4
  .type _dbus_list_unlink, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_list_unlink
#endif
_dbus_list_unlink:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 608

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_log
  .p2align 4
  .type _dbus_log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_log
#endif
_dbus_log:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 612

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_logv
  .p2align 4
  .type _dbus_logv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_logv
#endif
_dbus_logv:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 616

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_lookup_session_address
  .p2align 4
  .type _dbus_lookup_session_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_lookup_session_address
#endif
_dbus_lookup_session_address:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 620

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_marshal_byteswap
  .p2align 4
  .type _dbus_marshal_byteswap, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_byteswap
#endif
_dbus_marshal_byteswap:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 624

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_marshal_read_uint32
  .p2align 4
  .type _dbus_marshal_read_uint32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_read_uint32
#endif
_dbus_marshal_read_uint32:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 628

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_marshal_set_uint32
  .p2align 4
  .type _dbus_marshal_set_uint32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_marshal_set_uint32
#endif
_dbus_marshal_set_uint32:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 632

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_mem_pool_alloc
  .p2align 4
  .type _dbus_mem_pool_alloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_alloc
#endif
_dbus_mem_pool_alloc:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 636

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_mem_pool_dealloc
  .p2align 4
  .type _dbus_mem_pool_dealloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_dealloc
#endif
_dbus_mem_pool_dealloc:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 640

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_mem_pool_free
  .p2align 4
  .type _dbus_mem_pool_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_free
#endif
_dbus_mem_pool_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 644

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_mem_pool_new
  .p2align 4
  .type _dbus_mem_pool_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_mem_pool_new
#endif
_dbus_mem_pool_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 648

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_get_unix_fds
  .p2align 4
  .type _dbus_message_get_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_get_unix_fds
#endif
_dbus_message_get_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 652

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_iter_get_args_valist
  .p2align 4
  .type _dbus_message_iter_get_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_iter_get_args_valist
#endif
_dbus_message_iter_get_args_valist:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 656

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_get_buffer
  .p2align 4
  .type _dbus_message_loader_get_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_buffer
#endif
_dbus_message_loader_get_buffer:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 660

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_get_is_corrupted
  .p2align 4
  .type _dbus_message_loader_get_is_corrupted, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_is_corrupted
#endif
_dbus_message_loader_get_is_corrupted:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 664

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_get_max_message_size
  .p2align 4
  .type _dbus_message_loader_get_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_max_message_size
#endif
_dbus_message_loader_get_max_message_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 668

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_get_unix_fds
  .p2align 4
  .type _dbus_message_loader_get_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_get_unix_fds
#endif
_dbus_message_loader_get_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 672

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_new
  .p2align 4
  .type _dbus_message_loader_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_new
#endif
_dbus_message_loader_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 676

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_pop_message
  .p2align 4
  .type _dbus_message_loader_pop_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_pop_message
#endif
_dbus_message_loader_pop_message:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 680

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_queue_messages
  .p2align 4
  .type _dbus_message_loader_queue_messages, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_queue_messages
#endif
_dbus_message_loader_queue_messages:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 684

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_ref
  .p2align 4
  .type _dbus_message_loader_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_ref
#endif
_dbus_message_loader_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 688

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_return_buffer
  .p2align 4
  .type _dbus_message_loader_return_buffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_return_buffer
#endif
_dbus_message_loader_return_buffer:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 692

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_return_unix_fds
  .p2align 4
  .type _dbus_message_loader_return_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_return_unix_fds
#endif
_dbus_message_loader_return_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 696

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_loader_unref
  .p2align 4
  .type _dbus_message_loader_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_loader_unref
#endif
_dbus_message_loader_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 700

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_message_remove_unknown_fields
  .p2align 4
  .type _dbus_message_remove_unknown_fields, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_message_remove_unknown_fields
#endif
_dbus_message_remove_unknown_fields:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 704

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pending_call_new_unlocked
  .p2align 4
  .type _dbus_pending_call_new_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_new_unlocked
#endif
_dbus_pending_call_new_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 708

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pending_call_ref_unlocked
  .p2align 4
  .type _dbus_pending_call_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_ref_unlocked
#endif
_dbus_pending_call_ref_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 712

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pending_call_unref_and_unlock
  .p2align 4
  .type _dbus_pending_call_unref_and_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pending_call_unref_and_unlock
#endif
_dbus_pending_call_unref_and_unlock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 716

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_close
  .p2align 4
  .type _dbus_pipe_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_close
#endif
_dbus_pipe_close:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 720

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_init
  .p2align 4
  .type _dbus_pipe_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_init
#endif
_dbus_pipe_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 724

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_init_stdout
  .p2align 4
  .type _dbus_pipe_init_stdout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_init_stdout
#endif
_dbus_pipe_init_stdout:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 728

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_invalidate
  .p2align 4
  .type _dbus_pipe_invalidate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_invalidate
#endif
_dbus_pipe_invalidate:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 732

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_is_stdout_or_stderr
  .p2align 4
  .type _dbus_pipe_is_stdout_or_stderr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_is_stdout_or_stderr
#endif
_dbus_pipe_is_stdout_or_stderr:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 736

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_is_valid
  .p2align 4
  .type _dbus_pipe_is_valid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_is_valid
#endif
_dbus_pipe_is_valid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 740

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_pipe_write
  .p2align 4
  .type _dbus_pipe_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_pipe_write
#endif
_dbus_pipe_write:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 744

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_poll
  .p2align 4
  .type _dbus_poll, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_poll
#endif
_dbus_poll:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 748

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_print_backtrace
  .p2align 4
  .type _dbus_print_backtrace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_print_backtrace
#endif
_dbus_print_backtrace:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 752

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_printf_string_upper_bound
  .p2align 4
  .type _dbus_printf_string_upper_bound, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_printf_string_upper_bound
#endif
_dbus_printf_string_upper_bound:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 756

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_read
  .p2align 4
  .type _dbus_read, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read
#endif
_dbus_read:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 760

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_read_local_machine_uuid
  .p2align 4
  .type _dbus_read_local_machine_uuid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read_local_machine_uuid
#endif
_dbus_read_local_machine_uuid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 764

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_read_socket
  .p2align 4
  .type _dbus_read_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_read_socket
#endif
_dbus_read_socket:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 768

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_register_shutdown_func
  .p2align 4
  .type _dbus_register_shutdown_func, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_register_shutdown_func
#endif
_dbus_register_shutdown_func:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 772

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_resolve_pid_fd
  .p2align 4
  .type _dbus_resolve_pid_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_resolve_pid_fd
#endif
_dbus_resolve_pid_fd:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 776

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_rmutex_lock
  .p2align 4
  .type _dbus_rmutex_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_rmutex_lock
#endif
_dbus_rmutex_lock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 780

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_rmutex_unlock
  .p2align 4
  .type _dbus_rmutex_unlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_rmutex_unlock
#endif
_dbus_rmutex_unlock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 784

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_server_new_for_tcp_socket
  .p2align 4
  .type _dbus_server_new_for_tcp_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_new_for_tcp_socket
#endif
_dbus_server_new_for_tcp_socket:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 788

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_server_ref_unlocked
  .p2align 4
  .type _dbus_server_ref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_ref_unlocked
#endif
_dbus_server_ref_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 792

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_server_toggle_all_watches
  .p2align 4
  .type _dbus_server_toggle_all_watches, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_toggle_all_watches
#endif
_dbus_server_toggle_all_watches:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 796

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_server_unref_unlocked
  .p2align 4
  .type _dbus_server_unref_unlocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_server_unref_unlocked
#endif
_dbus_server_unref_unlocked:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 800

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_set_error_valist
  .p2align 4
  .type _dbus_set_error_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_set_error_valist
#endif
_dbus_set_error_valist:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 804

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_sleep_milliseconds
  .p2align 4
  .type _dbus_sleep_milliseconds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_sleep_milliseconds
#endif
_dbus_sleep_milliseconds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 808

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_socketpair
  .p2align 4
  .type _dbus_socketpair, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_socketpair
#endif
_dbus_socketpair:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 812

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_split_paths_and_append
  .p2align 4
  .type _dbus_split_paths_and_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_split_paths_and_append
#endif
_dbus_split_paths_and_append:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 816

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_strdup
  .p2align 4
  .type _dbus_strdup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strdup
#endif
_dbus_strdup:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 820

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_strerror
  .p2align 4
  .type _dbus_strerror, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strerror
#endif
_dbus_strerror:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 824

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_strerror_from_errno
  .p2align 4
  .type _dbus_strerror_from_errno, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_strerror_from_errno
#endif
_dbus_strerror_from_errno:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 828

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append
  .p2align 4
  .type _dbus_string_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append
#endif
_dbus_string_append:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 832

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append_byte
  .p2align 4
  .type _dbus_string_append_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_byte
#endif
_dbus_string_append_byte:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 836

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append_len
  .p2align 4
  .type _dbus_string_append_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_len
#endif
_dbus_string_append_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 840

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append_printf
  .p2align 4
  .type _dbus_string_append_printf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_printf
#endif
_dbus_string_append_printf:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 844

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append_printf_valist
  .p2align 4
  .type _dbus_string_append_printf_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_printf_valist
#endif
_dbus_string_append_printf_valist:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 848

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_append_strings
  .p2align 4
  .type _dbus_string_append_strings, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_append_strings
#endif
_dbus_string_append_strings:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 852

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_array_contains
  .p2align 4
  .type _dbus_string_array_contains, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_array_contains
#endif
_dbus_string_array_contains:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 856

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_array_length
  .p2align 4
  .type _dbus_string_array_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_array_length
#endif
_dbus_string_array_length:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 860

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_chop_white
  .p2align 4
  .type _dbus_string_chop_white, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_chop_white
#endif
_dbus_string_chop_white:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 864

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_compact
  .p2align 4
  .type _dbus_string_compact, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_compact
#endif
_dbus_string_compact:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 868

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_copy
  .p2align 4
  .type _dbus_string_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy
#endif
_dbus_string_copy:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 872

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_copy_data
  .p2align 4
  .type _dbus_string_copy_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_data
#endif
_dbus_string_copy_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 876

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_copy_len
  .p2align 4
  .type _dbus_string_copy_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_len
#endif
_dbus_string_copy_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 880

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_copy_to_buffer_with_nul
  .p2align 4
  .type _dbus_string_copy_to_buffer_with_nul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_copy_to_buffer_with_nul
#endif
_dbus_string_copy_to_buffer_with_nul:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 884

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_delete
  .p2align 4
  .type _dbus_string_delete, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_delete
#endif
_dbus_string_delete:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 888

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_equal
  .p2align 4
  .type _dbus_string_equal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal
#endif
_dbus_string_equal:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 892

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_equal_c_str
  .p2align 4
  .type _dbus_string_equal_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_c_str
#endif
_dbus_string_equal_c_str:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 896

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_equal_len
  .p2align 4
  .type _dbus_string_equal_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_len
#endif
_dbus_string_equal_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 900

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_equal_substring
  .p2align 4
  .type _dbus_string_equal_substring, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_equal_substring
#endif
_dbus_string_equal_substring:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 904

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_find
  .p2align 4
  .type _dbus_string_find, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find
#endif
_dbus_string_find:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 908

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_find_blank
  .p2align 4
  .type _dbus_string_find_blank, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_blank
#endif
_dbus_string_find_blank:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 912

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_find_eol
  .p2align 4
  .type _dbus_string_find_eol, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_eol
#endif
_dbus_string_find_eol:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 916

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_find_to
  .p2align 4
  .type _dbus_string_find_to, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_find_to
#endif
_dbus_string_find_to:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 920

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_free
  .p2align 4
  .type _dbus_string_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_free
#endif
_dbus_string_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 924

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_get_allocated_size
  .p2align 4
  .type _dbus_string_get_allocated_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_get_allocated_size
#endif
_dbus_string_get_allocated_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 928

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_get_data_len
  .p2align 4
  .type _dbus_string_get_data_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_get_data_len
#endif
_dbus_string_get_data_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 932

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_hex_decode
  .p2align 4
  .type _dbus_string_hex_decode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_hex_decode
#endif
_dbus_string_hex_decode:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 936

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_hex_encode
  .p2align 4
  .type _dbus_string_hex_encode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_hex_encode
#endif
_dbus_string_hex_encode:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 940

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_init
  .p2align 4
  .type _dbus_string_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init
#endif
_dbus_string_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 944

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_init_const
  .p2align 4
  .type _dbus_string_init_const, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_const
#endif
_dbus_string_init_const:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 948

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_init_const_len
  .p2align 4
  .type _dbus_string_init_const_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_const_len
#endif
_dbus_string_init_const_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 952

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_init_from_string
  .p2align 4
  .type _dbus_string_init_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_from_string
#endif
_dbus_string_init_from_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 956

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_init_preallocated
  .p2align 4
  .type _dbus_string_init_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_init_preallocated
#endif
_dbus_string_init_preallocated:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 960

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_insert_8_aligned
  .p2align 4
  .type _dbus_string_insert_8_aligned, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_8_aligned
#endif
_dbus_string_insert_8_aligned:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 964

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_insert_byte
  .p2align 4
  .type _dbus_string_insert_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_byte
#endif
_dbus_string_insert_byte:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 968

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_insert_bytes
  .p2align 4
  .type _dbus_string_insert_bytes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_insert_bytes
#endif
_dbus_string_insert_bytes:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 972

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_lengthen
  .p2align 4
  .type _dbus_string_lengthen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_lengthen
#endif
_dbus_string_lengthen:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 976

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_move
  .p2align 4
  .type _dbus_string_move, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_move
#endif
_dbus_string_move:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 980

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_parse_int
  .p2align 4
  .type _dbus_string_parse_int, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_int
#endif
_dbus_string_parse_int:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 984

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_parse_int64
  .p2align 4
  .type _dbus_string_parse_int64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_int64
#endif
_dbus_string_parse_int64:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 988

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_parse_uint
  .p2align 4
  .type _dbus_string_parse_uint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_parse_uint
#endif
_dbus_string_parse_uint:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 992

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_pop_line
  .p2align 4
  .type _dbus_string_pop_line, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_pop_line
#endif
_dbus_string_pop_line:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 996

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_replace_len
  .p2align 4
  .type _dbus_string_replace_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_replace_len
#endif
_dbus_string_replace_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1000

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_set_length
  .p2align 4
  .type _dbus_string_set_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_set_length
#endif
_dbus_string_set_length:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1004

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_shorten
  .p2align 4
  .type _dbus_string_shorten, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_shorten
#endif
_dbus_string_shorten:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1008

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_skip_blank
  .p2align 4
  .type _dbus_string_skip_blank, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_skip_blank
#endif
_dbus_string_skip_blank:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1012

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_skip_white
  .p2align 4
  .type _dbus_string_skip_white, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_skip_white
#endif
_dbus_string_skip_white:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1016

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_split_on_byte
  .p2align 4
  .type _dbus_string_split_on_byte, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_split_on_byte
#endif
_dbus_string_split_on_byte:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1020

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_starts_with_c_str
  .p2align 4
  .type _dbus_string_starts_with_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_starts_with_c_str
#endif
_dbus_string_starts_with_c_str:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1024

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_starts_with_words_c_str
  .p2align 4
  .type _dbus_string_starts_with_words_c_str, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_starts_with_words_c_str
#endif
_dbus_string_starts_with_words_c_str:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1028

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_steal_data
  .p2align 4
  .type _dbus_string_steal_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_steal_data
#endif
_dbus_string_steal_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1032

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_tolower_ascii
  .p2align 4
  .type _dbus_string_tolower_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_tolower_ascii
#endif
_dbus_string_tolower_ascii:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1036

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_toupper_ascii
  .p2align 4
  .type _dbus_string_toupper_ascii, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_toupper_ascii
#endif
_dbus_string_toupper_ascii:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1040

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_validate_nul
  .p2align 4
  .type _dbus_string_validate_nul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_validate_nul
#endif
_dbus_string_validate_nul:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1044

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_string_validate_utf8
  .p2align 4
  .type _dbus_string_validate_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_string_validate_utf8
#endif
_dbus_string_validate_utf8:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1048

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_disable
  .p2align 4
  .type _dbus_timeout_disable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_disable
#endif
_dbus_timeout_disable:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1052

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_needs_restart
  .p2align 4
  .type _dbus_timeout_needs_restart, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_needs_restart
#endif
_dbus_timeout_needs_restart:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1056

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_new
  .p2align 4
  .type _dbus_timeout_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_new
#endif
_dbus_timeout_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1060

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_restart
  .p2align 4
  .type _dbus_timeout_restart, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_restart
#endif
_dbus_timeout_restart:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1064

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_restarted
  .p2align 4
  .type _dbus_timeout_restarted, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_restarted
#endif
_dbus_timeout_restarted:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1068

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_timeout_unref
  .p2align 4
  .type _dbus_timeout_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_timeout_unref
#endif
_dbus_timeout_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1072

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_delete
  .p2align 4
  .type _dbus_type_reader_delete, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_delete
#endif
_dbus_type_reader_delete:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1076

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_get_current_type
  .p2align 4
  .type _dbus_type_reader_get_current_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_current_type
#endif
_dbus_type_reader_get_current_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1080

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_get_element_type
  .p2align 4
  .type _dbus_type_reader_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_element_type
#endif
_dbus_type_reader_get_element_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1084

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_get_signature
  .p2align 4
  .type _dbus_type_reader_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_signature
#endif
_dbus_type_reader_get_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1088

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_get_value_pos
  .p2align 4
  .type _dbus_type_reader_get_value_pos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_get_value_pos
#endif
_dbus_type_reader_get_value_pos:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1092

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_init
  .p2align 4
  .type _dbus_type_reader_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_init
#endif
_dbus_type_reader_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1096

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_init_types_only
  .p2align 4
  .type _dbus_type_reader_init_types_only, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_init_types_only
#endif
_dbus_type_reader_init_types_only:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1100

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_next
  .p2align 4
  .type _dbus_type_reader_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_next
#endif
_dbus_type_reader_next:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1104

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_read_basic
  .p2align 4
  .type _dbus_type_reader_read_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_read_basic
#endif
_dbus_type_reader_read_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1108

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_read_fixed_multi
  .p2align 4
  .type _dbus_type_reader_read_fixed_multi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_read_fixed_multi
#endif
_dbus_type_reader_read_fixed_multi:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1112

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_recurse
  .p2align 4
  .type _dbus_type_reader_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_recurse
#endif
_dbus_type_reader_recurse:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1116

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_reader_set_basic
  .p2align 4
  .type _dbus_type_reader_set_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_reader_set_basic
#endif
_dbus_type_reader_set_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1120

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_to_string
  .p2align 4
  .type _dbus_type_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_to_string
#endif
_dbus_type_to_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1124

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_init
  .p2align 4
  .type _dbus_type_writer_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_init
#endif
_dbus_type_writer_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1128

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_init_values_only
  .p2align 4
  .type _dbus_type_writer_init_values_only, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_init_values_only
#endif
_dbus_type_writer_init_values_only:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1132

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_recurse
  .p2align 4
  .type _dbus_type_writer_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_recurse
#endif
_dbus_type_writer_recurse:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1136

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_unrecurse
  .p2align 4
  .type _dbus_type_writer_unrecurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_unrecurse
#endif
_dbus_type_writer_unrecurse:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1140

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_write_basic
  .p2align 4
  .type _dbus_type_writer_write_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_basic
#endif
_dbus_type_writer_write_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1144

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_write_fixed_multi
  .p2align 4
  .type _dbus_type_writer_write_fixed_multi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_fixed_multi
#endif
_dbus_type_writer_write_fixed_multi:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1148

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_type_writer_write_reader
  .p2align 4
  .type _dbus_type_writer_write_reader, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_type_writer_write_reader
#endif
_dbus_type_writer_write_reader:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1152

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_get_system
  .p2align 4
  .type _dbus_user_database_get_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_system
#endif
_dbus_user_database_get_system:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1156

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_get_uid
  .p2align 4
  .type _dbus_user_database_get_uid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_uid
#endif
_dbus_user_database_get_uid:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1160

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_get_username
  .p2align 4
  .type _dbus_user_database_get_username, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_get_username
#endif
_dbus_user_database_get_username:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1164

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_lock_system
  .p2align 4
  .type _dbus_user_database_lock_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_lock_system
#endif
_dbus_user_database_lock_system:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1168

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_lookup
  .p2align 4
  .type _dbus_user_database_lookup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_lookup
#endif
_dbus_user_database_lookup:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1172

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_user_database_unlock_system
  .p2align 4
  .type _dbus_user_database_unlock_system, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_user_database_unlock_system
#endif
_dbus_user_database_unlock_system:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1176

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_username_from_current_process
  .p2align 4
  .type _dbus_username_from_current_process, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_username_from_current_process
#endif
_dbus_username_from_current_process:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1180

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_uuid_encode
  .p2align 4
  .type _dbus_uuid_encode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_uuid_encode
#endif
_dbus_uuid_encode:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1184

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_body_with_reason
  .p2align 4
  .type _dbus_validate_body_with_reason, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_body_with_reason
#endif
_dbus_validate_body_with_reason:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1188

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_bus_name
  .p2align 4
  .type _dbus_validate_bus_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_bus_name
#endif
_dbus_validate_bus_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1192

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_bus_namespace
  .p2align 4
  .type _dbus_validate_bus_namespace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_bus_namespace
#endif
_dbus_validate_bus_namespace:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1196

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_error_name
  .p2align 4
  .type _dbus_validate_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_error_name
#endif
_dbus_validate_error_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1200

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_interface
  .p2align 4
  .type _dbus_validate_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_interface
#endif
_dbus_validate_interface:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1204

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_member
  .p2align 4
  .type _dbus_validate_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_member
#endif
_dbus_validate_member:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1208

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_path
  .p2align 4
  .type _dbus_validate_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_path
#endif
_dbus_validate_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1212

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_validate_signature_with_reason
  .p2align 4
  .type _dbus_validate_signature_with_reason, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_validate_signature_with_reason
#endif
_dbus_validate_signature_with_reason:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1216

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_free
  .p2align 4
  .type _dbus_variant_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_free
#endif
_dbus_variant_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1220

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_get_length
  .p2align 4
  .type _dbus_variant_get_length, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_get_length
#endif
_dbus_variant_get_length:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1224

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_get_signature
  .p2align 4
  .type _dbus_variant_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_get_signature
#endif
_dbus_variant_get_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1228

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_peek
  .p2align 4
  .type _dbus_variant_peek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_peek
#endif
_dbus_variant_peek:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1232

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_read
  .p2align 4
  .type _dbus_variant_read, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_read
#endif
_dbus_variant_read:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1236

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_variant_write
  .p2align 4
  .type _dbus_variant_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_variant_write
#endif
_dbus_variant_write:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1240

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_verbose_bytes_of_string
  .p2align 4
  .type _dbus_verbose_bytes_of_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_verbose_bytes_of_string
#endif
_dbus_verbose_bytes_of_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1244

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_warn
  .p2align 4
  .type _dbus_warn, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn
#endif
_dbus_warn:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1248

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_warn_check_failed
  .p2align 4
  .type _dbus_warn_check_failed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn_check_failed
#endif
_dbus_warn_check_failed:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1252

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_warn_return_if_fail
  .p2align 4
  .type _dbus_warn_return_if_fail, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_warn_return_if_fail
#endif
_dbus_warn_return_if_fail:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1256

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_get_oom_last_time
  .p2align 4
  .type _dbus_watch_get_oom_last_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_get_oom_last_time
#endif
_dbus_watch_get_oom_last_time:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1260

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_get_pollable
  .p2align 4
  .type _dbus_watch_get_pollable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_get_pollable
#endif
_dbus_watch_get_pollable:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1264

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_invalidate
  .p2align 4
  .type _dbus_watch_invalidate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_invalidate
#endif
_dbus_watch_invalidate:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1268

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_list_add_watch
  .p2align 4
  .type _dbus_watch_list_add_watch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_add_watch
#endif
_dbus_watch_list_add_watch:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1272

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_list_free
  .p2align 4
  .type _dbus_watch_list_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_free
#endif
_dbus_watch_list_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1276

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_list_new
  .p2align 4
  .type _dbus_watch_list_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_new
#endif
_dbus_watch_list_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1280

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_list_remove_watch
  .p2align 4
  .type _dbus_watch_list_remove_watch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_remove_watch
#endif
_dbus_watch_list_remove_watch:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1284

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_list_set_functions
  .p2align 4
  .type _dbus_watch_list_set_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_list_set_functions
#endif
_dbus_watch_list_set_functions:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1288

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_new
  .p2align 4
  .type _dbus_watch_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_new
#endif
_dbus_watch_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1292

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_ref
  .p2align 4
  .type _dbus_watch_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_ref
#endif
_dbus_watch_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1296

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_set_oom_last_time
  .p2align 4
  .type _dbus_watch_set_oom_last_time, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_set_oom_last_time
#endif
_dbus_watch_set_oom_last_time:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1300

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_watch_unref
  .p2align 4
  .type _dbus_watch_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_watch_unref
#endif
_dbus_watch_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1304

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_write_socket
  .p2align 4
  .type _dbus_write_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_write_socket
#endif
_dbus_write_socket:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1308

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _dbus_write_socket_with_unix_fds
  .p2align 4
  .type _dbus_write_socket_with_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _dbus_write_socket_with_unix_fds
#endif
_dbus_write_socket_with_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1312

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_address_entries_free
  .p2align 4
  .type dbus_address_entries_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entries_free
#endif
dbus_address_entries_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1316

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_address_entry_get_method
  .p2align 4
  .type dbus_address_entry_get_method, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entry_get_method
#endif
dbus_address_entry_get_method:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1320

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_address_entry_get_value
  .p2align 4
  .type dbus_address_entry_get_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_entry_get_value
#endif
dbus_address_entry_get_value:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1324

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_address_escape_value
  .p2align 4
  .type dbus_address_escape_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_escape_value
#endif
dbus_address_escape_value:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1328

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_address_unescape_value
  .p2align 4
  .type dbus_address_unescape_value, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_address_unescape_value
#endif
dbus_address_unescape_value:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1332

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_add_match
  .p2align 4
  .type dbus_bus_add_match, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_add_match
#endif
dbus_bus_add_match:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1336

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_get
  .p2align 4
  .type dbus_bus_get, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get
#endif
dbus_bus_get:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1340

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_get_id
  .p2align 4
  .type dbus_bus_get_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_id
#endif
dbus_bus_get_id:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1344

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_get_private
  .p2align 4
  .type dbus_bus_get_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_private
#endif
dbus_bus_get_private:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1348

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_get_unique_name
  .p2align 4
  .type dbus_bus_get_unique_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_unique_name
#endif
dbus_bus_get_unique_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1352

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_get_unix_user
  .p2align 4
  .type dbus_bus_get_unix_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_get_unix_user
#endif
dbus_bus_get_unix_user:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1356

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_name_has_owner
  .p2align 4
  .type dbus_bus_name_has_owner, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_name_has_owner
#endif
dbus_bus_name_has_owner:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1360

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_register
  .p2align 4
  .type dbus_bus_register, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_register
#endif
dbus_bus_register:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1364

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_release_name
  .p2align 4
  .type dbus_bus_release_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_release_name
#endif
dbus_bus_release_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1368

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_remove_match
  .p2align 4
  .type dbus_bus_remove_match, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_remove_match
#endif
dbus_bus_remove_match:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1372

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_request_name
  .p2align 4
  .type dbus_bus_request_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_request_name
#endif
dbus_bus_request_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1376

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_set_unique_name
  .p2align 4
  .type dbus_bus_set_unique_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_set_unique_name
#endif
dbus_bus_set_unique_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1380

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_bus_start_service_by_name
  .p2align 4
  .type dbus_bus_start_service_by_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_bus_start_service_by_name
#endif
dbus_bus_start_service_by_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1384

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_add_filter
  .p2align 4
  .type dbus_connection_add_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_add_filter
#endif
dbus_connection_add_filter:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1388

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_allocate_data_slot
  .p2align 4
  .type dbus_connection_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_allocate_data_slot
#endif
dbus_connection_allocate_data_slot:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1392

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_borrow_message
  .p2align 4
  .type dbus_connection_borrow_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_borrow_message
#endif
dbus_connection_borrow_message:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1396

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_can_send_type
  .p2align 4
  .type dbus_connection_can_send_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_can_send_type
#endif
dbus_connection_can_send_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1400

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_close
  .p2align 4
  .type dbus_connection_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_close
#endif
dbus_connection_close:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1404

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_dispatch
  .p2align 4
  .type dbus_connection_dispatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_dispatch
#endif
dbus_connection_dispatch:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1408

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_flush
  .p2align 4
  .type dbus_connection_flush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_flush
#endif
dbus_connection_flush:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1412

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_free_data_slot
  .p2align 4
  .type dbus_connection_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_free_data_slot
#endif
dbus_connection_free_data_slot:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1416

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_free_preallocated_send
  .p2align 4
  .type dbus_connection_free_preallocated_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_free_preallocated_send
#endif
dbus_connection_free_preallocated_send:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1420

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_adt_audit_session_data
  .p2align 4
  .type dbus_connection_get_adt_audit_session_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_adt_audit_session_data
#endif
dbus_connection_get_adt_audit_session_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1424

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_data
  .p2align 4
  .type dbus_connection_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_data
#endif
dbus_connection_get_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1428

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_dispatch_status
  .p2align 4
  .type dbus_connection_get_dispatch_status, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_dispatch_status
#endif
dbus_connection_get_dispatch_status:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1432

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_is_anonymous
  .p2align 4
  .type dbus_connection_get_is_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_anonymous
#endif
dbus_connection_get_is_anonymous:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1436

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_is_authenticated
  .p2align 4
  .type dbus_connection_get_is_authenticated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_authenticated
#endif
dbus_connection_get_is_authenticated:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1440

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_is_connected
  .p2align 4
  .type dbus_connection_get_is_connected, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_is_connected
#endif
dbus_connection_get_is_connected:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1444

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_max_message_size
  .p2align 4
  .type dbus_connection_get_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_message_size
#endif
dbus_connection_get_max_message_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1448

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_max_message_unix_fds
  .p2align 4
  .type dbus_connection_get_max_message_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_message_unix_fds
#endif
dbus_connection_get_max_message_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1452

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_max_received_size
  .p2align 4
  .type dbus_connection_get_max_received_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_received_size
#endif
dbus_connection_get_max_received_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1456

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_max_received_unix_fds
  .p2align 4
  .type dbus_connection_get_max_received_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_max_received_unix_fds
#endif
dbus_connection_get_max_received_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1460

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_object_path_data
  .p2align 4
  .type dbus_connection_get_object_path_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_object_path_data
#endif
dbus_connection_get_object_path_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1464

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_outgoing_size
  .p2align 4
  .type dbus_connection_get_outgoing_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_outgoing_size
#endif
dbus_connection_get_outgoing_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1468

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_outgoing_unix_fds
  .p2align 4
  .type dbus_connection_get_outgoing_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_outgoing_unix_fds
#endif
dbus_connection_get_outgoing_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1472

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_server_id
  .p2align 4
  .type dbus_connection_get_server_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_server_id
#endif
dbus_connection_get_server_id:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1476

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_socket
  .p2align 4
  .type dbus_connection_get_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_socket
#endif
dbus_connection_get_socket:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1480

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_unix_fd
  .p2align 4
  .type dbus_connection_get_unix_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_fd
#endif
dbus_connection_get_unix_fd:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1484

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_unix_process_id
  .p2align 4
  .type dbus_connection_get_unix_process_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_process_id
#endif
dbus_connection_get_unix_process_id:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1488

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_unix_user
  .p2align 4
  .type dbus_connection_get_unix_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_unix_user
#endif
dbus_connection_get_unix_user:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1492

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_get_windows_user
  .p2align 4
  .type dbus_connection_get_windows_user, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_get_windows_user
#endif
dbus_connection_get_windows_user:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1496

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_has_messages_to_send
  .p2align 4
  .type dbus_connection_has_messages_to_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_has_messages_to_send
#endif
dbus_connection_has_messages_to_send:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1500

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_list_registered
  .p2align 4
  .type dbus_connection_list_registered, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_list_registered
#endif
dbus_connection_list_registered:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1504

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_open
  .p2align 4
  .type dbus_connection_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_open
#endif
dbus_connection_open:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1508

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_open_private
  .p2align 4
  .type dbus_connection_open_private, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_open_private
#endif
dbus_connection_open_private:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1512

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_pop_message
  .p2align 4
  .type dbus_connection_pop_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_pop_message
#endif
dbus_connection_pop_message:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1516

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_preallocate_send
  .p2align 4
  .type dbus_connection_preallocate_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_preallocate_send
#endif
dbus_connection_preallocate_send:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1520

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_read_write
  .p2align 4
  .type dbus_connection_read_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_read_write
#endif
dbus_connection_read_write:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1524

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_read_write_dispatch
  .p2align 4
  .type dbus_connection_read_write_dispatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_read_write_dispatch
#endif
dbus_connection_read_write_dispatch:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1528

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_ref
  .p2align 4
  .type dbus_connection_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_ref
#endif
dbus_connection_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1532

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_register_fallback
  .p2align 4
  .type dbus_connection_register_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_register_fallback
#endif
dbus_connection_register_fallback:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1536

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_register_object_path
  .p2align 4
  .type dbus_connection_register_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_register_object_path
#endif
dbus_connection_register_object_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1540

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_remove_filter
  .p2align 4
  .type dbus_connection_remove_filter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_remove_filter
#endif
dbus_connection_remove_filter:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1544

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_return_message
  .p2align 4
  .type dbus_connection_return_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_return_message
#endif
dbus_connection_return_message:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1548

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_send
  .p2align 4
  .type dbus_connection_send, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send
#endif
dbus_connection_send:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1552

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_send_preallocated
  .p2align 4
  .type dbus_connection_send_preallocated, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_preallocated
#endif
dbus_connection_send_preallocated:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1556

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_send_with_reply
  .p2align 4
  .type dbus_connection_send_with_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_with_reply
#endif
dbus_connection_send_with_reply:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1560

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_send_with_reply_and_block
  .p2align 4
  .type dbus_connection_send_with_reply_and_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_send_with_reply_and_block
#endif
dbus_connection_send_with_reply_and_block:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1564

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_allow_anonymous
  .p2align 4
  .type dbus_connection_set_allow_anonymous, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_allow_anonymous
#endif
dbus_connection_set_allow_anonymous:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1568

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_builtin_filters_enabled
  .p2align 4
  .type dbus_connection_set_builtin_filters_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_builtin_filters_enabled
#endif
dbus_connection_set_builtin_filters_enabled:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1572

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_change_sigpipe
  .p2align 4
  .type dbus_connection_set_change_sigpipe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_change_sigpipe
#endif
dbus_connection_set_change_sigpipe:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1576

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_data
  .p2align 4
  .type dbus_connection_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_data
#endif
dbus_connection_set_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1580

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_dispatch_status_function
  .p2align 4
  .type dbus_connection_set_dispatch_status_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_dispatch_status_function
#endif
dbus_connection_set_dispatch_status_function:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1584

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_exit_on_disconnect
  .p2align 4
  .type dbus_connection_set_exit_on_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_exit_on_disconnect
#endif
dbus_connection_set_exit_on_disconnect:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1588

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_max_message_size
  .p2align 4
  .type dbus_connection_set_max_message_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_message_size
#endif
dbus_connection_set_max_message_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1592

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_max_message_unix_fds
  .p2align 4
  .type dbus_connection_set_max_message_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_message_unix_fds
#endif
dbus_connection_set_max_message_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1596

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_max_received_size
  .p2align 4
  .type dbus_connection_set_max_received_size, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_received_size
#endif
dbus_connection_set_max_received_size:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1600

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_max_received_unix_fds
  .p2align 4
  .type dbus_connection_set_max_received_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_max_received_unix_fds
#endif
dbus_connection_set_max_received_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1604

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_route_peer_messages
  .p2align 4
  .type dbus_connection_set_route_peer_messages, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_route_peer_messages
#endif
dbus_connection_set_route_peer_messages:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1608

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_timeout_functions
  .p2align 4
  .type dbus_connection_set_timeout_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_timeout_functions
#endif
dbus_connection_set_timeout_functions:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1612

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_unix_user_function
  .p2align 4
  .type dbus_connection_set_unix_user_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_unix_user_function
#endif
dbus_connection_set_unix_user_function:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1616

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_wakeup_main_function
  .p2align 4
  .type dbus_connection_set_wakeup_main_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_wakeup_main_function
#endif
dbus_connection_set_wakeup_main_function:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1620

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_watch_functions
  .p2align 4
  .type dbus_connection_set_watch_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_watch_functions
#endif
dbus_connection_set_watch_functions:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1624

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_set_windows_user_function
  .p2align 4
  .type dbus_connection_set_windows_user_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_set_windows_user_function
#endif
dbus_connection_set_windows_user_function:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1628

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_steal_borrowed_message
  .p2align 4
  .type dbus_connection_steal_borrowed_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_steal_borrowed_message
#endif
dbus_connection_steal_borrowed_message:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1632

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_try_register_fallback
  .p2align 4
  .type dbus_connection_try_register_fallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_try_register_fallback
#endif
dbus_connection_try_register_fallback:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1636

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_try_register_object_path
  .p2align 4
  .type dbus_connection_try_register_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_try_register_object_path
#endif
dbus_connection_try_register_object_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1640

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_unref
  .p2align 4
  .type dbus_connection_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_unref
#endif
dbus_connection_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1644

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_connection_unregister_object_path
  .p2align 4
  .type dbus_connection_unregister_object_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_connection_unregister_object_path
#endif
dbus_connection_unregister_object_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1648

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_error_free
  .p2align 4
  .type dbus_error_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_free
#endif
dbus_error_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1652

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_error_has_name
  .p2align 4
  .type dbus_error_has_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_has_name
#endif
dbus_error_has_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1656

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_error_init
  .p2align 4
  .type dbus_error_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_init
#endif
dbus_error_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1660

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_error_is_set
  .p2align 4
  .type dbus_error_is_set, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_error_is_set
#endif
dbus_error_is_set:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1664

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_free
  .p2align 4
  .type dbus_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_free
#endif
dbus_free:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1668

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_free_string_array
  .p2align 4
  .type dbus_free_string_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_free_string_array
#endif
dbus_free_string_array:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1672

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_get_local_machine_id
  .p2align 4
  .type dbus_get_local_machine_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_get_local_machine_id
#endif
dbus_get_local_machine_id:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1676

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_get_version
  .p2align 4
  .type dbus_get_version, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_get_version
#endif
dbus_get_version:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1680

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_malloc
  .p2align 4
  .type dbus_malloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_malloc
#endif
dbus_malloc:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1684

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_malloc0
  .p2align 4
  .type dbus_malloc0, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_malloc0
#endif
dbus_malloc0:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1688

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_allocate_data_slot
  .p2align 4
  .type dbus_message_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_allocate_data_slot
#endif
dbus_message_allocate_data_slot:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1692

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_append_args
  .p2align 4
  .type dbus_message_append_args, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_append_args
#endif
dbus_message_append_args:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1696

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_append_args_valist
  .p2align 4
  .type dbus_message_append_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_append_args_valist
#endif
dbus_message_append_args_valist:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1700

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_contains_unix_fds
  .p2align 4
  .type dbus_message_contains_unix_fds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_contains_unix_fds
#endif
dbus_message_contains_unix_fds:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1704

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_copy
  .p2align 4
  .type dbus_message_copy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_copy
#endif
dbus_message_copy:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1708

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_demarshal
  .p2align 4
  .type dbus_message_demarshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_demarshal
#endif
dbus_message_demarshal:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1712

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_demarshal_bytes_needed
  .p2align 4
  .type dbus_message_demarshal_bytes_needed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_demarshal_bytes_needed
#endif
dbus_message_demarshal_bytes_needed:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1716

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_free_data_slot
  .p2align 4
  .type dbus_message_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_free_data_slot
#endif
dbus_message_free_data_slot:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1720

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_allow_interactive_authorization
  .p2align 4
  .type dbus_message_get_allow_interactive_authorization, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_allow_interactive_authorization
#endif
dbus_message_get_allow_interactive_authorization:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1724

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_args
  .p2align 4
  .type dbus_message_get_args, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_args
#endif
dbus_message_get_args:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1728

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_args_valist
  .p2align 4
  .type dbus_message_get_args_valist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_args_valist
#endif
dbus_message_get_args_valist:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1732

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_auto_start
  .p2align 4
  .type dbus_message_get_auto_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_auto_start
#endif
dbus_message_get_auto_start:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1736

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_container_instance
  .p2align 4
  .type dbus_message_get_container_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_container_instance
#endif
dbus_message_get_container_instance:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1740

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_data
  .p2align 4
  .type dbus_message_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_data
#endif
dbus_message_get_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1744

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_destination
  .p2align 4
  .type dbus_message_get_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_destination
#endif
dbus_message_get_destination:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1748

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_error_name
  .p2align 4
  .type dbus_message_get_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_error_name
#endif
dbus_message_get_error_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1752

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_interface
  .p2align 4
  .type dbus_message_get_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_interface
#endif
dbus_message_get_interface:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1756

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_member
  .p2align 4
  .type dbus_message_get_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_member
#endif
dbus_message_get_member:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1760

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_no_reply
  .p2align 4
  .type dbus_message_get_no_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_no_reply
#endif
dbus_message_get_no_reply:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1764

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_path
  .p2align 4
  .type dbus_message_get_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_path
#endif
dbus_message_get_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1768

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_path_decomposed
  .p2align 4
  .type dbus_message_get_path_decomposed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_path_decomposed
#endif
dbus_message_get_path_decomposed:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1772

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_reply_serial
  .p2align 4
  .type dbus_message_get_reply_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_reply_serial
#endif
dbus_message_get_reply_serial:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1776

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_sender
  .p2align 4
  .type dbus_message_get_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_sender
#endif
dbus_message_get_sender:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1780

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_serial
  .p2align 4
  .type dbus_message_get_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_serial
#endif
dbus_message_get_serial:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1784

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_signature
  .p2align 4
  .type dbus_message_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_signature
#endif
dbus_message_get_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1788

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_get_type
  .p2align 4
  .type dbus_message_get_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_get_type
#endif
dbus_message_get_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1792

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_destination
  .p2align 4
  .type dbus_message_has_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_destination
#endif
dbus_message_has_destination:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1796

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_interface
  .p2align 4
  .type dbus_message_has_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_interface
#endif
dbus_message_has_interface:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1800

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_member
  .p2align 4
  .type dbus_message_has_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_member
#endif
dbus_message_has_member:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1804

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_path
  .p2align 4
  .type dbus_message_has_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_path
#endif
dbus_message_has_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1808

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_sender
  .p2align 4
  .type dbus_message_has_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_sender
#endif
dbus_message_has_sender:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1812

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_has_signature
  .p2align 4
  .type dbus_message_has_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_has_signature
#endif
dbus_message_has_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1816

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_is_error
  .p2align 4
  .type dbus_message_is_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_error
#endif
dbus_message_is_error:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1820

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_is_method_call
  .p2align 4
  .type dbus_message_is_method_call, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_method_call
#endif
dbus_message_is_method_call:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1824

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_is_signal
  .p2align 4
  .type dbus_message_is_signal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_is_signal
#endif
dbus_message_is_signal:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1828

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_abandon_container
  .p2align 4
  .type dbus_message_iter_abandon_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_abandon_container
#endif
dbus_message_iter_abandon_container:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1832

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_abandon_container_if_open
  .p2align 4
  .type dbus_message_iter_abandon_container_if_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_abandon_container_if_open
#endif
dbus_message_iter_abandon_container_if_open:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1836

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_append_basic
  .p2align 4
  .type dbus_message_iter_append_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_append_basic
#endif
dbus_message_iter_append_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1840

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_append_fixed_array
  .p2align 4
  .type dbus_message_iter_append_fixed_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_append_fixed_array
#endif
dbus_message_iter_append_fixed_array:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1844

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_close_container
  .p2align 4
  .type dbus_message_iter_close_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_close_container
#endif
dbus_message_iter_close_container:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1848

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_arg_type
  .p2align 4
  .type dbus_message_iter_get_arg_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_arg_type
#endif
dbus_message_iter_get_arg_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1852

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_array_len
  .p2align 4
  .type dbus_message_iter_get_array_len, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_array_len
#endif
dbus_message_iter_get_array_len:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1856

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_basic
  .p2align 4
  .type dbus_message_iter_get_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_basic
#endif
dbus_message_iter_get_basic:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1860

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_element_count
  .p2align 4
  .type dbus_message_iter_get_element_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_element_count
#endif
dbus_message_iter_get_element_count:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1864

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_element_type
  .p2align 4
  .type dbus_message_iter_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_element_type
#endif
dbus_message_iter_get_element_type:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1868

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_fixed_array
  .p2align 4
  .type dbus_message_iter_get_fixed_array, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_fixed_array
#endif
dbus_message_iter_get_fixed_array:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1872

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_get_signature
  .p2align 4
  .type dbus_message_iter_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_get_signature
#endif
dbus_message_iter_get_signature:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1876

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_has_next
  .p2align 4
  .type dbus_message_iter_has_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_has_next
#endif
dbus_message_iter_has_next:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1880

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_init
  .p2align 4
  .type dbus_message_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init
#endif
dbus_message_iter_init:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1884

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_init_append
  .p2align 4
  .type dbus_message_iter_init_append, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init_append
#endif
dbus_message_iter_init_append:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1888

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_init_closed
  .p2align 4
  .type dbus_message_iter_init_closed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_init_closed
#endif
dbus_message_iter_init_closed:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1892

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_next
  .p2align 4
  .type dbus_message_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_next
#endif
dbus_message_iter_next:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1896

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_open_container
  .p2align 4
  .type dbus_message_iter_open_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_open_container
#endif
dbus_message_iter_open_container:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1900

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_iter_recurse
  .p2align 4
  .type dbus_message_iter_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_iter_recurse
#endif
dbus_message_iter_recurse:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1904

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_lock
  .p2align 4
  .type dbus_message_lock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_lock
#endif
dbus_message_lock:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1908

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_marshal
  .p2align 4
  .type dbus_message_marshal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_marshal
#endif
dbus_message_marshal:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1912

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new
  .p2align 4
  .type dbus_message_new, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new
#endif
dbus_message_new:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1916

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new_error
  .p2align 4
  .type dbus_message_new_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_error
#endif
dbus_message_new_error:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1920

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new_error_printf
  .p2align 4
  .type dbus_message_new_error_printf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_error_printf
#endif
dbus_message_new_error_printf:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1924

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new_method_call
  .p2align 4
  .type dbus_message_new_method_call, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_method_call
#endif
dbus_message_new_method_call:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1928

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new_method_return
  .p2align 4
  .type dbus_message_new_method_return, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_method_return
#endif
dbus_message_new_method_return:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1932

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_new_signal
  .p2align 4
  .type dbus_message_new_signal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_new_signal
#endif
dbus_message_new_signal:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1936

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_ref
  .p2align 4
  .type dbus_message_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_ref
#endif
dbus_message_ref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1940

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_allow_interactive_authorization
  .p2align 4
  .type dbus_message_set_allow_interactive_authorization, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_allow_interactive_authorization
#endif
dbus_message_set_allow_interactive_authorization:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1944

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_auto_start
  .p2align 4
  .type dbus_message_set_auto_start, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_auto_start
#endif
dbus_message_set_auto_start:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1948

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_container_instance
  .p2align 4
  .type dbus_message_set_container_instance, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_container_instance
#endif
dbus_message_set_container_instance:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1952

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_data
  .p2align 4
  .type dbus_message_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_data
#endif
dbus_message_set_data:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1956

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_destination
  .p2align 4
  .type dbus_message_set_destination, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_destination
#endif
dbus_message_set_destination:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1960

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_error_name
  .p2align 4
  .type dbus_message_set_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_error_name
#endif
dbus_message_set_error_name:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1964

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_interface
  .p2align 4
  .type dbus_message_set_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_interface
#endif
dbus_message_set_interface:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1968

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_member
  .p2align 4
  .type dbus_message_set_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_member
#endif
dbus_message_set_member:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1972

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_no_reply
  .p2align 4
  .type dbus_message_set_no_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_no_reply
#endif
dbus_message_set_no_reply:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1976

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_path
  .p2align 4
  .type dbus_message_set_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_path
#endif
dbus_message_set_path:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1980

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_reply_serial
  .p2align 4
  .type dbus_message_set_reply_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_reply_serial
#endif
dbus_message_set_reply_serial:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1984

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_sender
  .p2align 4
  .type dbus_message_set_sender, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_sender
#endif
dbus_message_set_sender:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1988

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_set_serial
  .p2align 4
  .type dbus_message_set_serial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_set_serial
#endif
dbus_message_set_serial:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1992

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_type_from_string
  .p2align 4
  .type dbus_message_type_from_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_type_from_string
#endif
dbus_message_type_from_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 1996

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_type_to_string
  .p2align 4
  .type dbus_message_type_to_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_type_to_string
#endif
dbus_message_type_to_string:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2000

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_message_unref
  .p2align 4
  .type dbus_message_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_message_unref
#endif
dbus_message_unref:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2004

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_move_error
  .p2align 4
  .type dbus_move_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_move_error
#endif
dbus_move_error:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2008

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_parse_address
  .p2align 4
  .type dbus_parse_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_parse_address
#endif
dbus_parse_address:
  .cfi_startproc

1:
  // Load address
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
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2012

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_allocate_data_slot
  .p2align 4
  .type dbus_pending_call_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_allocate_data_slot
#endif
dbus_pending_call_allocate_data_slot:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =504
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2016

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_block
  .p2align 4
  .type dbus_pending_call_block, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_block
#endif
dbus_pending_call_block:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =505
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2020

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_cancel
  .p2align 4
  .type dbus_pending_call_cancel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_cancel
#endif
dbus_pending_call_cancel:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =506
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2024

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_free_data_slot
  .p2align 4
  .type dbus_pending_call_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_free_data_slot
#endif
dbus_pending_call_free_data_slot:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =507
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2028

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_get_completed
  .p2align 4
  .type dbus_pending_call_get_completed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_get_completed
#endif
dbus_pending_call_get_completed:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =508
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2032

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_get_data
  .p2align 4
  .type dbus_pending_call_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_get_data
#endif
dbus_pending_call_get_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =509
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2036

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_ref
  .p2align 4
  .type dbus_pending_call_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_ref
#endif
dbus_pending_call_ref:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =510
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2040

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_set_data
  .p2align 4
  .type dbus_pending_call_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_set_data
#endif
dbus_pending_call_set_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =511
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2044

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_set_notify
  .p2align 4
  .type dbus_pending_call_set_notify, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_set_notify
#endif
dbus_pending_call_set_notify:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =512
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2048

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_steal_reply
  .p2align 4
  .type dbus_pending_call_steal_reply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_steal_reply
#endif
dbus_pending_call_steal_reply:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =513
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2052

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_pending_call_unref
  .p2align 4
  .type dbus_pending_call_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_pending_call_unref
#endif
dbus_pending_call_unref:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =514
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2056

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_realloc
  .p2align 4
  .type dbus_realloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_realloc
#endif
dbus_realloc:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =515
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2060

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_allocate_data_slot
  .p2align 4
  .type dbus_server_allocate_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_allocate_data_slot
#endif
dbus_server_allocate_data_slot:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =516
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2064

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_disconnect
  .p2align 4
  .type dbus_server_disconnect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_disconnect
#endif
dbus_server_disconnect:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =517
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2068

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_free_data_slot
  .p2align 4
  .type dbus_server_free_data_slot, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_free_data_slot
#endif
dbus_server_free_data_slot:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =518
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2072

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_get_address
  .p2align 4
  .type dbus_server_get_address, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_address
#endif
dbus_server_get_address:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =519
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2076

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_get_data
  .p2align 4
  .type dbus_server_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_data
#endif
dbus_server_get_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =520
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2080

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_get_id
  .p2align 4
  .type dbus_server_get_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_id
#endif
dbus_server_get_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =521
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2084

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_get_is_connected
  .p2align 4
  .type dbus_server_get_is_connected, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_get_is_connected
#endif
dbus_server_get_is_connected:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =522
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2088

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_listen
  .p2align 4
  .type dbus_server_listen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_listen
#endif
dbus_server_listen:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =523
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2092

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_ref
  .p2align 4
  .type dbus_server_ref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_ref
#endif
dbus_server_ref:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =524
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2096

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_set_auth_mechanisms
  .p2align 4
  .type dbus_server_set_auth_mechanisms, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_auth_mechanisms
#endif
dbus_server_set_auth_mechanisms:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =525
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2100

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_set_data
  .p2align 4
  .type dbus_server_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_data
#endif
dbus_server_set_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =526
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2104

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_set_new_connection_function
  .p2align 4
  .type dbus_server_set_new_connection_function, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_new_connection_function
#endif
dbus_server_set_new_connection_function:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =527
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2108

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_set_timeout_functions
  .p2align 4
  .type dbus_server_set_timeout_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_timeout_functions
#endif
dbus_server_set_timeout_functions:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =528
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2112

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_set_watch_functions
  .p2align 4
  .type dbus_server_set_watch_functions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_set_watch_functions
#endif
dbus_server_set_watch_functions:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =529
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2116

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_server_unref
  .p2align 4
  .type dbus_server_unref, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_server_unref
#endif
dbus_server_unref:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =530
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2120

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_set_error
  .p2align 4
  .type dbus_set_error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error
#endif
dbus_set_error:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =531
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2124

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_set_error_const
  .p2align 4
  .type dbus_set_error_const, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error_const
#endif
dbus_set_error_const:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =532
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2128

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_set_error_from_message
  .p2align 4
  .type dbus_set_error_from_message, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_set_error_from_message
#endif
dbus_set_error_from_message:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =533
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2132

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_setenv
  .p2align 4
  .type dbus_setenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_setenv
#endif
dbus_setenv:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =534
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2136

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_shutdown
  .p2align 4
  .type dbus_shutdown, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_shutdown
#endif
dbus_shutdown:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =535
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2140

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_get_current_type
  .p2align 4
  .type dbus_signature_iter_get_current_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_current_type
#endif
dbus_signature_iter_get_current_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =536
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2144

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_get_element_type
  .p2align 4
  .type dbus_signature_iter_get_element_type, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_element_type
#endif
dbus_signature_iter_get_element_type:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =537
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2148

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_get_signature
  .p2align 4
  .type dbus_signature_iter_get_signature, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_get_signature
#endif
dbus_signature_iter_get_signature:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =538
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2152

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_init
  .p2align 4
  .type dbus_signature_iter_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_init
#endif
dbus_signature_iter_init:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =539
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2156

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_next
  .p2align 4
  .type dbus_signature_iter_next, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_next
#endif
dbus_signature_iter_next:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =540
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2160

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_iter_recurse
  .p2align 4
  .type dbus_signature_iter_recurse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_iter_recurse
#endif
dbus_signature_iter_recurse:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =541
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2164

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_validate
  .p2align 4
  .type dbus_signature_validate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_validate
#endif
dbus_signature_validate:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =542
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2168

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_signature_validate_single
  .p2align 4
  .type dbus_signature_validate_single, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_signature_validate_single
#endif
dbus_signature_validate_single:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =543
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2172

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_threads_init
  .p2align 4
  .type dbus_threads_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_threads_init
#endif
dbus_threads_init:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =544
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2176

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_threads_init_default
  .p2align 4
  .type dbus_threads_init_default, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_threads_init_default
#endif
dbus_threads_init_default:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =545
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2180

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_timeout_get_data
  .p2align 4
  .type dbus_timeout_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_data
#endif
dbus_timeout_get_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =546
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2184

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_timeout_get_enabled
  .p2align 4
  .type dbus_timeout_get_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_enabled
#endif
dbus_timeout_get_enabled:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =547
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2188

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_timeout_get_interval
  .p2align 4
  .type dbus_timeout_get_interval, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_get_interval
#endif
dbus_timeout_get_interval:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =548
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2192

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_timeout_handle
  .p2align 4
  .type dbus_timeout_handle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_handle
#endif
dbus_timeout_handle:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =549
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2196

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_timeout_set_data
  .p2align 4
  .type dbus_timeout_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_timeout_set_data
#endif
dbus_timeout_set_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =550
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2200

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_try_get_local_machine_id
  .p2align 4
  .type dbus_try_get_local_machine_id, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_try_get_local_machine_id
#endif
dbus_try_get_local_machine_id:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =551
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2204

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_type_is_basic
  .p2align 4
  .type dbus_type_is_basic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_basic
#endif
dbus_type_is_basic:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =552
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2208

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_type_is_container
  .p2align 4
  .type dbus_type_is_container, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_container
#endif
dbus_type_is_container:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =553
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2212

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_type_is_fixed
  .p2align 4
  .type dbus_type_is_fixed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_fixed
#endif
dbus_type_is_fixed:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =554
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2216

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_type_is_valid
  .p2align 4
  .type dbus_type_is_valid, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_type_is_valid
#endif
dbus_type_is_valid:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =555
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2220

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_bus_name
  .p2align 4
  .type dbus_validate_bus_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_bus_name
#endif
dbus_validate_bus_name:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =556
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2224

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_error_name
  .p2align 4
  .type dbus_validate_error_name, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_error_name
#endif
dbus_validate_error_name:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =557
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2228

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_interface
  .p2align 4
  .type dbus_validate_interface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_interface
#endif
dbus_validate_interface:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =558
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2232

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_member
  .p2align 4
  .type dbus_validate_member, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_member
#endif
dbus_validate_member:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =559
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2236

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_path
  .p2align 4
  .type dbus_validate_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_path
#endif
dbus_validate_path:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =560
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2240

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_validate_utf8
  .p2align 4
  .type dbus_validate_utf8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_validate_utf8
#endif
dbus_validate_utf8:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =561
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2244

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_data
  .p2align 4
  .type dbus_watch_get_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_data
#endif
dbus_watch_get_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =562
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2248

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_enabled
  .p2align 4
  .type dbus_watch_get_enabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_enabled
#endif
dbus_watch_get_enabled:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =563
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2252

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_fd
  .p2align 4
  .type dbus_watch_get_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_fd
#endif
dbus_watch_get_fd:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =564
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2256

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_flags
  .p2align 4
  .type dbus_watch_get_flags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_flags
#endif
dbus_watch_get_flags:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =565
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2260

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_socket
  .p2align 4
  .type dbus_watch_get_socket, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_socket
#endif
dbus_watch_get_socket:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =566
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2264

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_get_unix_fd
  .p2align 4
  .type dbus_watch_get_unix_fd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_get_unix_fd
#endif
dbus_watch_get_unix_fd:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =567
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2268

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_handle
  .p2align 4
  .type dbus_watch_handle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_handle
#endif
dbus_watch_handle:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =568
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2272

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl dbus_watch_set_data
  .p2align 4
  .type dbus_watch_set_data, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden dbus_watch_set_data
#endif
dbus_watch_set_data:
  .cfi_startproc

1:
  // Load address
  // TODO: can we do this faster on newer ARMs?
  ldr ip, 3f
2:
  add ip, pc, ip
  ldr ip, [ip]

  cmp ip, #0

  // Fast path
  bxne ip

  // Slow path
  ldr ip, =569
  push {ip}
  .cfi_adjust_cfa_offset 4
  PUSH_REG(lr)
  bl _libdbus_1_so_save_regs_and_resolve
  POP_REG(lr)
  add sp, #4
  .cfi_adjust_cfa_offset -4
  bx ip

  // Force constant pool for ldr above
  .ltorg

  .cfi_endproc

3:
  .word _libdbus_1_so_tramp_table - (2b + 8) + 2276

