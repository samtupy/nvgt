/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

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

#define PUSH_REG(reg) pushq %reg ; .cfi_adjust_cfa_offset 8; .cfi_rel_offset reg, 0
#define POP_REG(reg) popq %reg ; .cfi_adjust_cfa_offset -8; .cfi_restore reg

#define DEC_STACK(d) subq $d, %rsp; .cfi_adjust_cfa_offset d
#define INC_STACK(d) addq $d, %rsp; .cfi_adjust_cfa_offset -d

#define PUSH_MMX_REG(reg) DEC_STACK(8); movq %reg, (%rsp); .cfi_rel_offset reg, 0
#define POP_MMX_REG(reg) movq (%rsp), %reg; .cfi_restore reg; INC_STACK(8)

#define PUSH_XMM_REG(reg) DEC_STACK(16); movdqa %reg, (%rsp); .cfi_rel_offset reg, 0
#define POP_XMM_REG(reg) movdqa (%rsp), %reg; .cfi_restore reg; INC_STACK(16)

// TODO: cfi_offset/cfi_restore
#define PUSH_YMM_REG(reg) DEC_STACK(32); vmovdqu %reg, (%rsp)
#define POP_YMM_REG(reg) vmovdqu (%rsp), %reg; INC_STACK(32)

// TODO: cfi_offset/cfi_restore
#define PUSH_ZMM_REG(reg) DEC_STACK(64); vmovdqu32 %reg, (%rsp)
#define POP_ZMM_REG(reg) vmovdqu32 (%rsp), %reg; INC_STACK(64)

  // Slow path which calls dlsym, taken only on first call.
  // All registers are stored to handle arbitrary calling conventions
  // (except x87 FPU registers which do not have to be preserved).
  // For Dwarf directives, read https://www.imperialviolet.org/2017/01/18/cfi.html.

  .cfi_def_cfa_offset 8  // Return address

  PUSH_REG(rdi)  // 16
  mov 0x10(%rsp), %rdi
  PUSH_REG(rbx)
  PUSH_REG(rbx)  // 16
  PUSH_REG(rcx)
  PUSH_REG(rdx)  // 16
  PUSH_REG(rbp)
  PUSH_REG(rsi)  // 16
  PUSH_REG(r8)
  PUSH_REG(r9)  // 16
  PUSH_REG(r10)
  PUSH_REG(r11)  // 16
  PUSH_REG(r12)
  PUSH_REG(r13)  // 16
  PUSH_REG(r14)
  PUSH_REG(r15)  // 16

  // Maybe use cpuid instead of macro to detect current vector size...
#ifdef __AVX512F__
  PUSH_ZMM_REG(zmm0)
  PUSH_ZMM_REG(zmm1)
  PUSH_ZMM_REG(zmm2)
  PUSH_ZMM_REG(zmm3)
  PUSH_ZMM_REG(zmm4)
  PUSH_ZMM_REG(zmm5)
  PUSH_ZMM_REG(zmm6)
  PUSH_ZMM_REG(zmm7)
#elif defined __AVX__
  PUSH_YMM_REG(ymm0)
  PUSH_YMM_REG(ymm1)
  PUSH_YMM_REG(ymm2)
  PUSH_YMM_REG(ymm3)
  PUSH_YMM_REG(ymm4)
  PUSH_YMM_REG(ymm5)
  PUSH_YMM_REG(ymm6)
  PUSH_YMM_REG(ymm7)
#elif defined __SSE__
  PUSH_XMM_REG(xmm0)
  PUSH_XMM_REG(xmm1)
  PUSH_XMM_REG(xmm2)
  PUSH_XMM_REG(xmm3)
  PUSH_XMM_REG(xmm4)
  PUSH_XMM_REG(xmm5)
  PUSH_XMM_REG(xmm6)
  PUSH_XMM_REG(xmm7)
#endif

  // MMX registers are not used to pass arguments so we do not save them

  // Stack is just 8-byte aligned but callee will re-align to 16
  call _libharfbuzz_so_tramp_resolve

#ifdef __AVX512F__
  POP_ZMM_REG(zmm7)
  POP_ZMM_REG(zmm6)
  POP_ZMM_REG(zmm5)
  POP_ZMM_REG(zmm4)
  POP_ZMM_REG(zmm3)
  POP_ZMM_REG(zmm2)
  POP_ZMM_REG(zmm1)
  POP_ZMM_REG(zmm0)  // 16
#elif defined __AVX__
  POP_YMM_REG(ymm7)
  POP_YMM_REG(ymm6)
  POP_YMM_REG(ymm5)
  POP_YMM_REG(ymm4)
  POP_YMM_REG(ymm3)
  POP_YMM_REG(ymm2)
  POP_YMM_REG(ymm1)
  POP_YMM_REG(ymm0)  // 16
#elif defined __SSE__
  POP_XMM_REG(xmm7)
  POP_XMM_REG(xmm6)
  POP_XMM_REG(xmm5)
  POP_XMM_REG(xmm4)
  POP_XMM_REG(xmm3)
  POP_XMM_REG(xmm2)
  POP_XMM_REG(xmm1)
  POP_XMM_REG(xmm0)  // 16
#endif

  POP_REG(r15)
  POP_REG(r14)  // 16
  POP_REG(r13)
  POP_REG(r12)  // 16
  POP_REG(r11)
  POP_REG(r10)  // 16
  POP_REG(r9)
  POP_REG(r8)  // 16
  POP_REG(rsi)
  POP_REG(rbp)  // 16
  POP_REG(rdx)
  POP_REG(rcx)  // 16
  POP_REG(rbx)
  POP_REG(rbx)  // 16
  POP_REG(rdi)

  ret

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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3592(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3592(%rip)
2:
  pushq $449
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3600(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3600(%rip)
2:
  pushq $450
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3608(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3608(%rip)
2:
  pushq $451
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3616(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3616(%rip)
2:
  pushq $452
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3624(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3624(%rip)
2:
  pushq $453
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3632(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3632(%rip)
2:
  pushq $454
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3640(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3640(%rip)
2:
  pushq $455
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3648(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3648(%rip)
2:
  pushq $456
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3656(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3656(%rip)
2:
  pushq $457
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3664(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3664(%rip)
2:
  pushq $458
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3672(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3672(%rip)
2:
  pushq $459
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3680(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3680(%rip)
2:
  pushq $460
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3688(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3688(%rip)
2:
  pushq $461
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3696(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3696(%rip)
2:
  pushq $462
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3704(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3704(%rip)
2:
  pushq $463
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3712(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3712(%rip)
2:
  pushq $464
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3720(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3720(%rip)
2:
  pushq $465
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3728(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3728(%rip)
2:
  pushq $466
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3736(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3736(%rip)
2:
  pushq $467
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3744(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3744(%rip)
2:
  pushq $468
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3752(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3752(%rip)
2:
  pushq $469
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3760(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3760(%rip)
2:
  pushq $470
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3768(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3768(%rip)
2:
  pushq $471
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3776(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3776(%rip)
2:
  pushq $472
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3784(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3784(%rip)
2:
  pushq $473
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3792(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3792(%rip)
2:
  pushq $474
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3800(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3800(%rip)
2:
  pushq $475
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3808(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3808(%rip)
2:
  pushq $476
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3816(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3816(%rip)
2:
  pushq $477
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3824(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3824(%rip)
2:
  pushq $478
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3832(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3832(%rip)
2:
  pushq $479
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3840(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3840(%rip)
2:
  pushq $480
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3848(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3848(%rip)
2:
  pushq $481
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3856(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3856(%rip)
2:
  pushq $482
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3864(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3864(%rip)
2:
  pushq $483
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3872(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3872(%rip)
2:
  pushq $484
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3880(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3880(%rip)
2:
  pushq $485
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3888(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3888(%rip)
2:
  pushq $486
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3896(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3896(%rip)
2:
  pushq $487
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3904(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3904(%rip)
2:
  pushq $488
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3912(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3912(%rip)
2:
  pushq $489
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3920(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3920(%rip)
2:
  pushq $490
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3928(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3928(%rip)
2:
  pushq $491
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3936(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3936(%rip)
2:
  pushq $492
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3944(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3944(%rip)
2:
  pushq $493
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3952(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3952(%rip)
2:
  pushq $494
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3960(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3960(%rip)
2:
  pushq $495
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3968(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3968(%rip)
2:
  pushq $496
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3976(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3976(%rip)
2:
  pushq $497
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3984(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3984(%rip)
2:
  pushq $498
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+3992(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+3992(%rip)
2:
  pushq $499
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4000(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4000(%rip)
2:
  pushq $500
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4008(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4008(%rip)
2:
  pushq $501
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4016(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4016(%rip)
2:
  pushq $502
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4024(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4024(%rip)
2:
  pushq $503
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4032(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4032(%rip)
2:
  pushq $504
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4040(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4040(%rip)
2:
  pushq $505
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4048(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4048(%rip)
2:
  pushq $506
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4056(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4056(%rip)
2:
  pushq $507
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4064(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4064(%rip)
2:
  pushq $508
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4072(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4072(%rip)
2:
  pushq $509
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4080(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4080(%rip)
2:
  pushq $510
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4088(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4088(%rip)
2:
  pushq $511
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4096(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4096(%rip)
2:
  pushq $512
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4104(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4104(%rip)
2:
  pushq $513
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4112(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4112(%rip)
2:
  pushq $514
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4120(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4120(%rip)
2:
  pushq $515
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4128(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4128(%rip)
2:
  pushq $516
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4136(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4136(%rip)
2:
  pushq $517
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4144(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4144(%rip)
2:
  pushq $518
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4152(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4152(%rip)
2:
  pushq $519
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4160(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4160(%rip)
2:
  pushq $520
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4168(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4168(%rip)
2:
  pushq $521
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4176(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4176(%rip)
2:
  pushq $522
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4184(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4184(%rip)
2:
  pushq $523
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4192(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4192(%rip)
2:
  pushq $524
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4200(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4200(%rip)
2:
  pushq $525
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4208(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4208(%rip)
2:
  pushq $526
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4216(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4216(%rip)
2:
  pushq $527
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
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
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libharfbuzz_so_tramp_table+4224(%rip)
  je 2f
1:
  jmp *_libharfbuzz_so_tramp_table+4224(%rip)
2:
  pushq $528
  .cfi_adjust_cfa_offset 8
  call _libharfbuzz_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

