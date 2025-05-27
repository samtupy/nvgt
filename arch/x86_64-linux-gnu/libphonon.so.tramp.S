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

  .globl _libphonon_so_tramp_table
  .hidden _libphonon_so_tramp_table
  .align 8
_libphonon_so_tramp_table:
  .zero 1384

  .text

  .globl _libphonon_so_tramp_resolve
  .hidden _libphonon_so_tramp_resolve

  .globl _libphonon_so_save_regs_and_resolve
  .hidden _libphonon_so_save_regs_and_resolve
  .type _libphonon_so_save_regs_and_resolve, %function
_libphonon_so_save_regs_and_resolve:
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
  call _libphonon_so_tramp_resolve

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

  .globl _ZNSt11unique_lockISt5mutexE6unlockEv
  .p2align 4
  .type _ZNSt11unique_lockISt5mutexE6unlockEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt11unique_lockISt5mutexE6unlockEv
#endif
_ZNSt11unique_lockISt5mutexE6unlockEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE10_M_releaseEv
  .p2align 4
  .type _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE10_M_releaseEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE10_M_releaseEv
#endif
_ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE10_M_releaseEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE24_M_release_last_use_coldEv
  .p2align 4
  .type _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE24_M_release_last_use_coldEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE24_M_release_last_use_coldEv
#endif
_ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE24_M_release_last_use_coldEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv
  .p2align 4
  .type _ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv
#endif
_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEE6_M_runEv
  .p2align 4
  .type _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEE6_M_runEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEE6_M_runEv
#endif
_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEE6_M_runEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED0Ev
  .p2align 4
  .type _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED0Ev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED0Ev
#endif
_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED0Ev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED1Ev
  .p2align 4
  .type _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED1Ev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED1Ev
#endif
_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED1Ev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED2Ev
  .p2align 4
  .type _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED2Ev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED2Ev
#endif
_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED2Ev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6thread24_M_thread_deps_never_runEv
  .p2align 4
  .type _ZNSt6thread24_M_thread_deps_never_runEv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6thread24_M_thread_deps_never_runEv
#endif
_ZNSt6thread24_M_thread_deps_never_runEv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6vectorIdSaIdEED1Ev
  .p2align 4
  .type _ZNSt6vectorIdSaIdEED1Ev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6vectorIdSaIdEED1Ev
#endif
_ZNSt6vectorIdSaIdEED1Ev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt6vectorIdSaIdEED2Ev
  .p2align 4
  .type _ZNSt6vectorIdSaIdEED2Ev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt6vectorIdSaIdEED2Ev
#endif
_ZNSt6vectorIdSaIdEED2Ev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl _ZNSt7__cxx119to_stringEi
  .p2align 4
  .type _ZNSt7__cxx119to_stringEi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden _ZNSt7__cxx119to_stringEi
#endif
_ZNSt7__cxx119to_stringEi:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAirAbsorptionCalculate
  .p2align 4
  .type iplAirAbsorptionCalculate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAirAbsorptionCalculate
#endif
iplAirAbsorptionCalculate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsBinauralEffectApply
  .p2align 4
  .type iplAmbisonicsBinauralEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsBinauralEffectApply
#endif
iplAmbisonicsBinauralEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsBinauralEffectCreate
  .p2align 4
  .type iplAmbisonicsBinauralEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsBinauralEffectCreate
#endif
iplAmbisonicsBinauralEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsBinauralEffectRelease
  .p2align 4
  .type iplAmbisonicsBinauralEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsBinauralEffectRelease
#endif
iplAmbisonicsBinauralEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsBinauralEffectReset
  .p2align 4
  .type iplAmbisonicsBinauralEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsBinauralEffectReset
#endif
iplAmbisonicsBinauralEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsBinauralEffectRetain
  .p2align 4
  .type iplAmbisonicsBinauralEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsBinauralEffectRetain
#endif
iplAmbisonicsBinauralEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsDecodeEffectApply
  .p2align 4
  .type iplAmbisonicsDecodeEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsDecodeEffectApply
#endif
iplAmbisonicsDecodeEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsDecodeEffectCreate
  .p2align 4
  .type iplAmbisonicsDecodeEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsDecodeEffectCreate
#endif
iplAmbisonicsDecodeEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsDecodeEffectRelease
  .p2align 4
  .type iplAmbisonicsDecodeEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsDecodeEffectRelease
#endif
iplAmbisonicsDecodeEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsDecodeEffectReset
  .p2align 4
  .type iplAmbisonicsDecodeEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsDecodeEffectReset
#endif
iplAmbisonicsDecodeEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsDecodeEffectRetain
  .p2align 4
  .type iplAmbisonicsDecodeEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsDecodeEffectRetain
#endif
iplAmbisonicsDecodeEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsEncodeEffectApply
  .p2align 4
  .type iplAmbisonicsEncodeEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsEncodeEffectApply
#endif
iplAmbisonicsEncodeEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsEncodeEffectCreate
  .p2align 4
  .type iplAmbisonicsEncodeEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsEncodeEffectCreate
#endif
iplAmbisonicsEncodeEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsEncodeEffectRelease
  .p2align 4
  .type iplAmbisonicsEncodeEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsEncodeEffectRelease
#endif
iplAmbisonicsEncodeEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsEncodeEffectReset
  .p2align 4
  .type iplAmbisonicsEncodeEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsEncodeEffectReset
#endif
iplAmbisonicsEncodeEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsEncodeEffectRetain
  .p2align 4
  .type iplAmbisonicsEncodeEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsEncodeEffectRetain
#endif
iplAmbisonicsEncodeEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsPanningEffectApply
  .p2align 4
  .type iplAmbisonicsPanningEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsPanningEffectApply
#endif
iplAmbisonicsPanningEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsPanningEffectCreate
  .p2align 4
  .type iplAmbisonicsPanningEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsPanningEffectCreate
#endif
iplAmbisonicsPanningEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsPanningEffectRelease
  .p2align 4
  .type iplAmbisonicsPanningEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsPanningEffectRelease
#endif
iplAmbisonicsPanningEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsPanningEffectReset
  .p2align 4
  .type iplAmbisonicsPanningEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsPanningEffectReset
#endif
iplAmbisonicsPanningEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsPanningEffectRetain
  .p2align 4
  .type iplAmbisonicsPanningEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsPanningEffectRetain
#endif
iplAmbisonicsPanningEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsRotationEffectApply
  .p2align 4
  .type iplAmbisonicsRotationEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsRotationEffectApply
#endif
iplAmbisonicsRotationEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsRotationEffectCreate
  .p2align 4
  .type iplAmbisonicsRotationEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsRotationEffectCreate
#endif
iplAmbisonicsRotationEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsRotationEffectRelease
  .p2align 4
  .type iplAmbisonicsRotationEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsRotationEffectRelease
#endif
iplAmbisonicsRotationEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsRotationEffectReset
  .p2align 4
  .type iplAmbisonicsRotationEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsRotationEffectReset
#endif
iplAmbisonicsRotationEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAmbisonicsRotationEffectRetain
  .p2align 4
  .type iplAmbisonicsRotationEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAmbisonicsRotationEffectRetain
#endif
iplAmbisonicsRotationEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferAllocate
  .p2align 4
  .type iplAudioBufferAllocate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferAllocate
#endif
iplAudioBufferAllocate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferConvertAmbisonics
  .p2align 4
  .type iplAudioBufferConvertAmbisonics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferConvertAmbisonics
#endif
iplAudioBufferConvertAmbisonics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferDeinterleave
  .p2align 4
  .type iplAudioBufferDeinterleave, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferDeinterleave
#endif
iplAudioBufferDeinterleave:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferDownmix
  .p2align 4
  .type iplAudioBufferDownmix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferDownmix
#endif
iplAudioBufferDownmix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferFree
  .p2align 4
  .type iplAudioBufferFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferFree
#endif
iplAudioBufferFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferInterleave
  .p2align 4
  .type iplAudioBufferInterleave, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferInterleave
#endif
iplAudioBufferInterleave:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplAudioBufferMix
  .p2align 4
  .type iplAudioBufferMix, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplAudioBufferMix
#endif
iplAudioBufferMix:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplBinauralEffectApply
  .p2align 4
  .type iplBinauralEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplBinauralEffectApply
#endif
iplBinauralEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplBinauralEffectCreate
  .p2align 4
  .type iplBinauralEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplBinauralEffectCreate
#endif
iplBinauralEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplBinauralEffectRelease
  .p2align 4
  .type iplBinauralEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplBinauralEffectRelease
#endif
iplBinauralEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplBinauralEffectReset
  .p2align 4
  .type iplBinauralEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplBinauralEffectReset
#endif
iplBinauralEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplBinauralEffectRetain
  .p2align 4
  .type iplBinauralEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplBinauralEffectRetain
#endif
iplBinauralEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplCalculateRelativeDirection
  .p2align 4
  .type iplCalculateRelativeDirection, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplCalculateRelativeDirection
#endif
iplCalculateRelativeDirection:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplContextCreate
  .p2align 4
  .type iplContextCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplContextCreate
#endif
iplContextCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplContextRelease
  .p2align 4
  .type iplContextRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplContextRelease
#endif
iplContextRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplContextRetain
  .p2align 4
  .type iplContextRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplContextRetain
#endif
iplContextRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectEffectApply
  .p2align 4
  .type iplDirectEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectEffectApply
#endif
iplDirectEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectEffectCreate
  .p2align 4
  .type iplDirectEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectEffectCreate
#endif
iplDirectEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectEffectRelease
  .p2align 4
  .type iplDirectEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectEffectRelease
#endif
iplDirectEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectEffectReset
  .p2align 4
  .type iplDirectEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectEffectReset
#endif
iplDirectEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectEffectRetain
  .p2align 4
  .type iplDirectEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectEffectRetain
#endif
iplDirectEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDirectivityCalculate
  .p2align 4
  .type iplDirectivityCalculate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDirectivityCalculate
#endif
iplDirectivityCalculate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplDistanceAttenuationCalculate
  .p2align 4
  .type iplDistanceAttenuationCalculate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplDistanceAttenuationCalculate
#endif
iplDistanceAttenuationCalculate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplEmbreeDeviceCreate
  .p2align 4
  .type iplEmbreeDeviceCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplEmbreeDeviceCreate
#endif
iplEmbreeDeviceCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplEmbreeDeviceRelease
  .p2align 4
  .type iplEmbreeDeviceRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplEmbreeDeviceRelease
#endif
iplEmbreeDeviceRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplEmbreeDeviceRetain
  .p2align 4
  .type iplEmbreeDeviceRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplEmbreeDeviceRetain
#endif
iplEmbreeDeviceRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplHRTFCreate
  .p2align 4
  .type iplHRTFCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplHRTFCreate
#endif
iplHRTFCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplHRTFRelease
  .p2align 4
  .type iplHRTFRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplHRTFRelease
#endif
iplHRTFRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplHRTFRetain
  .p2align 4
  .type iplHRTFRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplHRTFRetain
#endif
iplHRTFRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshAdd
  .p2align 4
  .type iplInstancedMeshAdd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshAdd
#endif
iplInstancedMeshAdd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshCreate
  .p2align 4
  .type iplInstancedMeshCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshCreate
#endif
iplInstancedMeshCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshRelease
  .p2align 4
  .type iplInstancedMeshRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshRelease
#endif
iplInstancedMeshRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshRemove
  .p2align 4
  .type iplInstancedMeshRemove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshRemove
#endif
iplInstancedMeshRemove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshRetain
  .p2align 4
  .type iplInstancedMeshRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshRetain
#endif
iplInstancedMeshRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplInstancedMeshUpdateTransform
  .p2align 4
  .type iplInstancedMeshUpdateTransform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplInstancedMeshUpdateTransform
#endif
iplInstancedMeshUpdateTransform:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceCreate
  .p2align 4
  .type iplOpenCLDeviceCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceCreate
#endif
iplOpenCLDeviceCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceCreateFromExisting
  .p2align 4
  .type iplOpenCLDeviceCreateFromExisting, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceCreateFromExisting
#endif
iplOpenCLDeviceCreateFromExisting:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceListCreate
  .p2align 4
  .type iplOpenCLDeviceListCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceListCreate
#endif
iplOpenCLDeviceListCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceListGetDeviceDesc
  .p2align 4
  .type iplOpenCLDeviceListGetDeviceDesc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceListGetDeviceDesc
#endif
iplOpenCLDeviceListGetDeviceDesc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceListGetNumDevices
  .p2align 4
  .type iplOpenCLDeviceListGetNumDevices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceListGetNumDevices
#endif
iplOpenCLDeviceListGetNumDevices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceListRelease
  .p2align 4
  .type iplOpenCLDeviceListRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceListRelease
#endif
iplOpenCLDeviceListRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceListRetain
  .p2align 4
  .type iplOpenCLDeviceListRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceListRetain
#endif
iplOpenCLDeviceListRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceRelease
  .p2align 4
  .type iplOpenCLDeviceRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceRelease
#endif
iplOpenCLDeviceRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplOpenCLDeviceRetain
  .p2align 4
  .type iplOpenCLDeviceRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplOpenCLDeviceRetain
#endif
iplOpenCLDeviceRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPanningEffectApply
  .p2align 4
  .type iplPanningEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPanningEffectApply
#endif
iplPanningEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPanningEffectCreate
  .p2align 4
  .type iplPanningEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPanningEffectCreate
#endif
iplPanningEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPanningEffectRelease
  .p2align 4
  .type iplPanningEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPanningEffectRelease
#endif
iplPanningEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPanningEffectReset
  .p2align 4
  .type iplPanningEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPanningEffectReset
#endif
iplPanningEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPanningEffectRetain
  .p2align 4
  .type iplPanningEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPanningEffectRetain
#endif
iplPanningEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathBakerBake
  .p2align 4
  .type iplPathBakerBake, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathBakerBake
#endif
iplPathBakerBake:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathBakerCancelBake
  .p2align 4
  .type iplPathBakerCancelBake, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathBakerCancelBake
#endif
iplPathBakerCancelBake:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathEffectApply
  .p2align 4
  .type iplPathEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathEffectApply
#endif
iplPathEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathEffectCreate
  .p2align 4
  .type iplPathEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathEffectCreate
#endif
iplPathEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathEffectRelease
  .p2align 4
  .type iplPathEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathEffectRelease
#endif
iplPathEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathEffectReset
  .p2align 4
  .type iplPathEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathEffectReset
#endif
iplPathEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplPathEffectRetain
  .p2align 4
  .type iplPathEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplPathEffectRetain
#endif
iplPathEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayCreate
  .p2align 4
  .type iplProbeArrayCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayCreate
#endif
iplProbeArrayCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayGenerateProbes
  .p2align 4
  .type iplProbeArrayGenerateProbes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayGenerateProbes
#endif
iplProbeArrayGenerateProbes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayGetNumProbes
  .p2align 4
  .type iplProbeArrayGetNumProbes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayGetNumProbes
#endif
iplProbeArrayGetNumProbes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayGetProbe
  .p2align 4
  .type iplProbeArrayGetProbe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayGetProbe
#endif
iplProbeArrayGetProbe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayRelease
  .p2align 4
  .type iplProbeArrayRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayRelease
#endif
iplProbeArrayRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeArrayRetain
  .p2align 4
  .type iplProbeArrayRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeArrayRetain
#endif
iplProbeArrayRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchAddProbe
  .p2align 4
  .type iplProbeBatchAddProbe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchAddProbe
#endif
iplProbeBatchAddProbe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchAddProbeArray
  .p2align 4
  .type iplProbeBatchAddProbeArray, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchAddProbeArray
#endif
iplProbeBatchAddProbeArray:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchCommit
  .p2align 4
  .type iplProbeBatchCommit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchCommit
#endif
iplProbeBatchCommit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchCreate
  .p2align 4
  .type iplProbeBatchCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchCreate
#endif
iplProbeBatchCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchGetDataSize
  .p2align 4
  .type iplProbeBatchGetDataSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchGetDataSize
#endif
iplProbeBatchGetDataSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchGetNumProbes
  .p2align 4
  .type iplProbeBatchGetNumProbes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchGetNumProbes
#endif
iplProbeBatchGetNumProbes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchLoad
  .p2align 4
  .type iplProbeBatchLoad, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchLoad
#endif
iplProbeBatchLoad:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchRelease
  .p2align 4
  .type iplProbeBatchRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchRelease
#endif
iplProbeBatchRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchRemoveData
  .p2align 4
  .type iplProbeBatchRemoveData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchRemoveData
#endif
iplProbeBatchRemoveData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchRemoveProbe
  .p2align 4
  .type iplProbeBatchRemoveProbe, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchRemoveProbe
#endif
iplProbeBatchRemoveProbe:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchRetain
  .p2align 4
  .type iplProbeBatchRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchRetain
#endif
iplProbeBatchRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplProbeBatchSave
  .p2align 4
  .type iplProbeBatchSave, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplProbeBatchSave
#endif
iplProbeBatchSave:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplRadeonRaysDeviceCreate
  .p2align 4
  .type iplRadeonRaysDeviceCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplRadeonRaysDeviceCreate
#endif
iplRadeonRaysDeviceCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplRadeonRaysDeviceRelease
  .p2align 4
  .type iplRadeonRaysDeviceRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplRadeonRaysDeviceRelease
#endif
iplRadeonRaysDeviceRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplRadeonRaysDeviceRetain
  .p2align 4
  .type iplRadeonRaysDeviceRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplRadeonRaysDeviceRetain
#endif
iplRadeonRaysDeviceRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionEffectApply
  .p2align 4
  .type iplReflectionEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionEffectApply
#endif
iplReflectionEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionEffectCreate
  .p2align 4
  .type iplReflectionEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionEffectCreate
#endif
iplReflectionEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionEffectRelease
  .p2align 4
  .type iplReflectionEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionEffectRelease
#endif
iplReflectionEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionEffectReset
  .p2align 4
  .type iplReflectionEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionEffectReset
#endif
iplReflectionEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionEffectRetain
  .p2align 4
  .type iplReflectionEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionEffectRetain
#endif
iplReflectionEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionMixerApply
  .p2align 4
  .type iplReflectionMixerApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionMixerApply
#endif
iplReflectionMixerApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionMixerCreate
  .p2align 4
  .type iplReflectionMixerCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionMixerCreate
#endif
iplReflectionMixerCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionMixerRelease
  .p2align 4
  .type iplReflectionMixerRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionMixerRelease
#endif
iplReflectionMixerRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionMixerReset
  .p2align 4
  .type iplReflectionMixerReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionMixerReset
#endif
iplReflectionMixerReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionMixerRetain
  .p2align 4
  .type iplReflectionMixerRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionMixerRetain
#endif
iplReflectionMixerRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionsBakerBake
  .p2align 4
  .type iplReflectionsBakerBake, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionsBakerBake
#endif
iplReflectionsBakerBake:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplReflectionsBakerCancelBake
  .p2align 4
  .type iplReflectionsBakerCancelBake, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplReflectionsBakerCancelBake
#endif
iplReflectionsBakerCancelBake:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneCommit
  .p2align 4
  .type iplSceneCommit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneCommit
#endif
iplSceneCommit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneCreate
  .p2align 4
  .type iplSceneCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneCreate
#endif
iplSceneCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneLoad
  .p2align 4
  .type iplSceneLoad, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneLoad
#endif
iplSceneLoad:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneRelease
  .p2align 4
  .type iplSceneRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneRelease
#endif
iplSceneRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneRetain
  .p2align 4
  .type iplSceneRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneRetain
#endif
iplSceneRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneSave
  .p2align 4
  .type iplSceneSave, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneSave
#endif
iplSceneSave:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSceneSaveOBJ
  .p2align 4
  .type iplSceneSaveOBJ, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSceneSaveOBJ
#endif
iplSceneSaveOBJ:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSerializedObjectCreate
  .p2align 4
  .type iplSerializedObjectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSerializedObjectCreate
#endif
iplSerializedObjectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSerializedObjectGetData
  .p2align 4
  .type iplSerializedObjectGetData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSerializedObjectGetData
#endif
iplSerializedObjectGetData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSerializedObjectGetSize
  .p2align 4
  .type iplSerializedObjectGetSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSerializedObjectGetSize
#endif
iplSerializedObjectGetSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSerializedObjectRelease
  .p2align 4
  .type iplSerializedObjectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSerializedObjectRelease
#endif
iplSerializedObjectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSerializedObjectRetain
  .p2align 4
  .type iplSerializedObjectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSerializedObjectRetain
#endif
iplSerializedObjectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorAddProbeBatch
  .p2align 4
  .type iplSimulatorAddProbeBatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorAddProbeBatch
#endif
iplSimulatorAddProbeBatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorCommit
  .p2align 4
  .type iplSimulatorCommit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorCommit
#endif
iplSimulatorCommit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorCreate
  .p2align 4
  .type iplSimulatorCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorCreate
#endif
iplSimulatorCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRelease
  .p2align 4
  .type iplSimulatorRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRelease
#endif
iplSimulatorRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRemoveProbeBatch
  .p2align 4
  .type iplSimulatorRemoveProbeBatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRemoveProbeBatch
#endif
iplSimulatorRemoveProbeBatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRetain
  .p2align 4
  .type iplSimulatorRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRetain
#endif
iplSimulatorRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRunDirect
  .p2align 4
  .type iplSimulatorRunDirect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRunDirect
#endif
iplSimulatorRunDirect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRunPathing
  .p2align 4
  .type iplSimulatorRunPathing, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRunPathing
#endif
iplSimulatorRunPathing:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorRunReflections
  .p2align 4
  .type iplSimulatorRunReflections, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorRunReflections
#endif
iplSimulatorRunReflections:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorSetScene
  .p2align 4
  .type iplSimulatorSetScene, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorSetScene
#endif
iplSimulatorSetScene:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSimulatorSetSharedInputs
  .p2align 4
  .type iplSimulatorSetSharedInputs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSimulatorSetSharedInputs
#endif
iplSimulatorSetSharedInputs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceAdd
  .p2align 4
  .type iplSourceAdd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceAdd
#endif
iplSourceAdd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceCreate
  .p2align 4
  .type iplSourceCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceCreate
#endif
iplSourceCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceGetOutputs
  .p2align 4
  .type iplSourceGetOutputs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceGetOutputs
#endif
iplSourceGetOutputs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceRelease
  .p2align 4
  .type iplSourceRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceRelease
#endif
iplSourceRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceRemove
  .p2align 4
  .type iplSourceRemove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceRemove
#endif
iplSourceRemove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceRetain
  .p2align 4
  .type iplSourceRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceRetain
#endif
iplSourceRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplSourceSetInputs
  .p2align 4
  .type iplSourceSetInputs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplSourceSetInputs
#endif
iplSourceSetInputs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshAdd
  .p2align 4
  .type iplStaticMeshAdd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshAdd
#endif
iplStaticMeshAdd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshCreate
  .p2align 4
  .type iplStaticMeshCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshCreate
#endif
iplStaticMeshCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshLoad
  .p2align 4
  .type iplStaticMeshLoad, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshLoad
#endif
iplStaticMeshLoad:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshRelease
  .p2align 4
  .type iplStaticMeshRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshRelease
#endif
iplStaticMeshRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshRemove
  .p2align 4
  .type iplStaticMeshRemove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshRemove
#endif
iplStaticMeshRemove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshRetain
  .p2align 4
  .type iplStaticMeshRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshRetain
#endif
iplStaticMeshRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplStaticMeshSave
  .p2align 4
  .type iplStaticMeshSave, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplStaticMeshSave
#endif
iplStaticMeshSave:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplTrueAudioNextDeviceCreate
  .p2align 4
  .type iplTrueAudioNextDeviceCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplTrueAudioNextDeviceCreate
#endif
iplTrueAudioNextDeviceCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplTrueAudioNextDeviceRelease
  .p2align 4
  .type iplTrueAudioNextDeviceRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplTrueAudioNextDeviceRelease
#endif
iplTrueAudioNextDeviceRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplTrueAudioNextDeviceRetain
  .p2align 4
  .type iplTrueAudioNextDeviceRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplTrueAudioNextDeviceRetain
#endif
iplTrueAudioNextDeviceRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplVirtualSurroundEffectApply
  .p2align 4
  .type iplVirtualSurroundEffectApply, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplVirtualSurroundEffectApply
#endif
iplVirtualSurroundEffectApply:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplVirtualSurroundEffectCreate
  .p2align 4
  .type iplVirtualSurroundEffectCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplVirtualSurroundEffectCreate
#endif
iplVirtualSurroundEffectCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplVirtualSurroundEffectRelease
  .p2align 4
  .type iplVirtualSurroundEffectRelease, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplVirtualSurroundEffectRelease
#endif
iplVirtualSurroundEffectRelease:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplVirtualSurroundEffectReset
  .p2align 4
  .type iplVirtualSurroundEffectReset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplVirtualSurroundEffectReset
#endif
iplVirtualSurroundEffectReset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl iplVirtualSurroundEffectRetain
  .p2align 4
  .type iplVirtualSurroundEffectRetain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden iplVirtualSurroundEffectRetain
#endif
iplVirtualSurroundEffectRetain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libphonon_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libphonon_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libphonon_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp *%rax
  .cfi_endproc

