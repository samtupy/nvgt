/*
 * Copyright 2018-2025 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE // For RTLD_DEFAULT
#endif

#define HAS_DLOPEN_CALLBACK 1
#define HAS_DLSYM_CALLBACK 1
#define NO_DLOPEN 0
#define LAZY_LOAD 1
#define THREAD_SAFE 1

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#if THREAD_SAFE
#include <pthread.h>
#endif

// Sanity check for ARM to avoid puzzling runtime crashes
#ifdef __arm__
# if defined __thumb__ && ! defined __THUMB_INTERWORK__
#   error "ARM trampolines need -mthumb-interwork to work in Thumb mode"
# endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(cond, fmt, ...) do { \
    if(!(cond)) { \
      fprintf(stderr, "implib-gen: libphonon.so: " fmt "\n", ##__VA_ARGS__); \
      assert(0 && "Assertion in generated code"); \
      abort(); \
    } \
  } while(0)

static void *lib_handle;
static int dlopened;

#if ! NO_DLOPEN

#if THREAD_SAFE

// We need to consider two cases:
// - different threads calling intercepted APIs in parallel
// - same thread calling 2 intercepted APIs recursively
//   due to dlopen calling library constructors
//   (usually happens only under IMPLIB_EXPORT_SHIMS)

// Current recursive mutex approach will deadlock
// if library constructor starts and joins a new thread
// which (directly or indirectly) calls another library function.
// Such situations should be very rare (although chances
// are higher when -DIMLIB_EXPORT_SHIMS are enabled).
//
// Similar issue is present in Glibc so hopefully it's
// not a big deal: // http://sourceware.org/bugzilla/show_bug.cgi?id=15686
// (also google for "dlopen deadlock).

static pthread_mutex_t mtx;
static int rec_count;

static void init_lock(void) {
  // We need recursive lock because dlopen will call library constructors
  // which may call other intercepted APIs that will call load_library again.
  // PTHREAD_RECURSIVE_MUTEX_INITIALIZER is not portable
  // so we do it hard way.

  pthread_mutexattr_t attr;
  CHECK(0 == pthread_mutexattr_init(&attr), "failed to init mutex");
  CHECK(0 == pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE), "failed to init mutex");

  CHECK(0 == pthread_mutex_init(&mtx, &attr), "failed to init mutex");
}

static int lock(void) {
  static pthread_once_t once = PTHREAD_ONCE_INIT;
  CHECK(0 == pthread_once(&once, init_lock), "failed to init lock");

  CHECK(0 == pthread_mutex_lock(&mtx), "failed to lock mutex");

  return 0 == __sync_fetch_and_add(&rec_count, 1);
}

static void unlock(void) {
  __sync_fetch_and_add(&rec_count, -1);
  CHECK(0 == pthread_mutex_unlock(&mtx), "failed to unlock mutex");
}
#else
static int lock(void) {
  return 1;
}
static void unlock(void) {}
#endif

static int load_library(void) {
  int publish = lock();

  if (lib_handle) {
    unlock();
    return publish;
  }

#if HAS_DLOPEN_CALLBACK
  extern void *nvgt_dlopen(const char *lib_name);
  lib_handle = nvgt_dlopen("libphonon.so");
  CHECK(lib_handle, "failed to load library 'libphonon.so' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libphonon.so", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libphonon.so' via dlopen: %s", dlerror());
#endif

  // With (non-default) IMPLIB_EXPORT_SHIMS we may call dlopen more than once
  // so dlclose it if we are not the first ones
  if (__sync_val_compare_and_swap(&dlopened, 0, 1)) {
    dlclose(lib_handle);
  }

  unlock();

  return publish;
}

// Run dtor as late as possible in case library functions are
// called in other global dtors
// FIXME: this may crash if one thread is calling into library
// while some other thread executes exit(). It's no clear
// how to fix this besides simply NOT dlclosing library at all.
static void __attribute__((destructor(101))) unload_lib(void) {
  if (dlopened) {
    dlclose(lib_handle);
    lib_handle = 0;
    dlopened = 0;
  }
}
#endif

#if ! NO_DLOPEN && ! LAZY_LOAD
static void __attribute__((constructor(101))) load_lib(void) {
  load_library();
}
#endif

// TODO: convert to single 0-separated string
static const char *const sym_names[] = {
  "_ZNSt11unique_lockISt5mutexE6unlockEv",
  "_ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE10_M_releaseEv",
  "_ZNSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE24_M_release_last_use_coldEv",
  "_ZNSt23mersenne_twister_engineImLm32ELm624ELm397ELm31ELm2567483615ELm11ELm4294967295ELm7ELm2636928640ELm15ELm4022730752ELm18ELm1812433253EE11_M_gen_randEv",
  "_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEE6_M_runEv",
  "_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED0Ev",
  "_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED1Ev",
  "_ZNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEED2Ev",
  "_ZNSt6thread24_M_thread_deps_never_runEv",
  "_ZNSt6vectorIdSaIdEED1Ev",
  "_ZNSt6vectorIdSaIdEED2Ev",
  "_ZNSt7__cxx119to_stringEi",
  "iplAirAbsorptionCalculate",
  "iplAmbisonicsBinauralEffectApply",
  "iplAmbisonicsBinauralEffectCreate",
  "iplAmbisonicsBinauralEffectRelease",
  "iplAmbisonicsBinauralEffectReset",
  "iplAmbisonicsBinauralEffectRetain",
  "iplAmbisonicsDecodeEffectApply",
  "iplAmbisonicsDecodeEffectCreate",
  "iplAmbisonicsDecodeEffectRelease",
  "iplAmbisonicsDecodeEffectReset",
  "iplAmbisonicsDecodeEffectRetain",
  "iplAmbisonicsEncodeEffectApply",
  "iplAmbisonicsEncodeEffectCreate",
  "iplAmbisonicsEncodeEffectRelease",
  "iplAmbisonicsEncodeEffectReset",
  "iplAmbisonicsEncodeEffectRetain",
  "iplAmbisonicsPanningEffectApply",
  "iplAmbisonicsPanningEffectCreate",
  "iplAmbisonicsPanningEffectRelease",
  "iplAmbisonicsPanningEffectReset",
  "iplAmbisonicsPanningEffectRetain",
  "iplAmbisonicsRotationEffectApply",
  "iplAmbisonicsRotationEffectCreate",
  "iplAmbisonicsRotationEffectRelease",
  "iplAmbisonicsRotationEffectReset",
  "iplAmbisonicsRotationEffectRetain",
  "iplAudioBufferAllocate",
  "iplAudioBufferConvertAmbisonics",
  "iplAudioBufferDeinterleave",
  "iplAudioBufferDownmix",
  "iplAudioBufferFree",
  "iplAudioBufferInterleave",
  "iplAudioBufferMix",
  "iplBinauralEffectApply",
  "iplBinauralEffectCreate",
  "iplBinauralEffectRelease",
  "iplBinauralEffectReset",
  "iplBinauralEffectRetain",
  "iplCalculateRelativeDirection",
  "iplContextCreate",
  "iplContextRelease",
  "iplContextRetain",
  "iplDirectEffectApply",
  "iplDirectEffectCreate",
  "iplDirectEffectRelease",
  "iplDirectEffectReset",
  "iplDirectEffectRetain",
  "iplDirectivityCalculate",
  "iplDistanceAttenuationCalculate",
  "iplEmbreeDeviceCreate",
  "iplEmbreeDeviceRelease",
  "iplEmbreeDeviceRetain",
  "iplHRTFCreate",
  "iplHRTFRelease",
  "iplHRTFRetain",
  "iplInstancedMeshAdd",
  "iplInstancedMeshCreate",
  "iplInstancedMeshRelease",
  "iplInstancedMeshRemove",
  "iplInstancedMeshRetain",
  "iplInstancedMeshUpdateTransform",
  "iplOpenCLDeviceCreate",
  "iplOpenCLDeviceCreateFromExisting",
  "iplOpenCLDeviceListCreate",
  "iplOpenCLDeviceListGetDeviceDesc",
  "iplOpenCLDeviceListGetNumDevices",
  "iplOpenCLDeviceListRelease",
  "iplOpenCLDeviceListRetain",
  "iplOpenCLDeviceRelease",
  "iplOpenCLDeviceRetain",
  "iplPanningEffectApply",
  "iplPanningEffectCreate",
  "iplPanningEffectRelease",
  "iplPanningEffectReset",
  "iplPanningEffectRetain",
  "iplPathBakerBake",
  "iplPathBakerCancelBake",
  "iplPathEffectApply",
  "iplPathEffectCreate",
  "iplPathEffectRelease",
  "iplPathEffectReset",
  "iplPathEffectRetain",
  "iplProbeArrayCreate",
  "iplProbeArrayGenerateProbes",
  "iplProbeArrayGetNumProbes",
  "iplProbeArrayGetProbe",
  "iplProbeArrayRelease",
  "iplProbeArrayRetain",
  "iplProbeBatchAddProbe",
  "iplProbeBatchAddProbeArray",
  "iplProbeBatchCommit",
  "iplProbeBatchCreate",
  "iplProbeBatchGetDataSize",
  "iplProbeBatchGetNumProbes",
  "iplProbeBatchLoad",
  "iplProbeBatchRelease",
  "iplProbeBatchRemoveData",
  "iplProbeBatchRemoveProbe",
  "iplProbeBatchRetain",
  "iplProbeBatchSave",
  "iplRadeonRaysDeviceCreate",
  "iplRadeonRaysDeviceRelease",
  "iplRadeonRaysDeviceRetain",
  "iplReflectionEffectApply",
  "iplReflectionEffectCreate",
  "iplReflectionEffectRelease",
  "iplReflectionEffectReset",
  "iplReflectionEffectRetain",
  "iplReflectionMixerApply",
  "iplReflectionMixerCreate",
  "iplReflectionMixerRelease",
  "iplReflectionMixerReset",
  "iplReflectionMixerRetain",
  "iplReflectionsBakerBake",
  "iplReflectionsBakerCancelBake",
  "iplSceneCommit",
  "iplSceneCreate",
  "iplSceneLoad",
  "iplSceneRelease",
  "iplSceneRetain",
  "iplSceneSave",
  "iplSceneSaveOBJ",
  "iplSerializedObjectCreate",
  "iplSerializedObjectGetData",
  "iplSerializedObjectGetSize",
  "iplSerializedObjectRelease",
  "iplSerializedObjectRetain",
  "iplSimulatorAddProbeBatch",
  "iplSimulatorCommit",
  "iplSimulatorCreate",
  "iplSimulatorRelease",
  "iplSimulatorRemoveProbeBatch",
  "iplSimulatorRetain",
  "iplSimulatorRunDirect",
  "iplSimulatorRunPathing",
  "iplSimulatorRunReflections",
  "iplSimulatorSetScene",
  "iplSimulatorSetSharedInputs",
  "iplSourceAdd",
  "iplSourceCreate",
  "iplSourceGetOutputs",
  "iplSourceRelease",
  "iplSourceRemove",
  "iplSourceRetain",
  "iplSourceSetInputs",
  "iplStaticMeshAdd",
  "iplStaticMeshCreate",
  "iplStaticMeshLoad",
  "iplStaticMeshRelease",
  "iplStaticMeshRemove",
  "iplStaticMeshRetain",
  "iplStaticMeshSave",
  "iplTrueAudioNextDeviceCreate",
  "iplTrueAudioNextDeviceRelease",
  "iplTrueAudioNextDeviceRetain",
  "iplVirtualSurroundEffectApply",
  "iplVirtualSurroundEffectCreate",
  "iplVirtualSurroundEffectRelease",
  "iplVirtualSurroundEffectReset",
  "iplVirtualSurroundEffectRetain",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libphonon_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libphonon_so_tramp_resolve(size_t i) {
  assert(i < SYM_COUNT);

  int publish = 1;

  void *h = 0;
#if NO_DLOPEN
  // Library with implementations must have already been loaded.
  if (lib_handle) {
    // User has specified loaded library
    h = lib_handle;
  } else {
    // User hasn't provided us the loaded library so search the global namespace.
#   ifndef IMPLIB_EXPORT_SHIMS
    // If shim symbols are hidden we should search
    // for first available definition of symbol in library list
    h = RTLD_DEFAULT;
#   else
    // Otherwise look for next available definition
    h = RTLD_NEXT;
#   endif
  }
#else
  publish = load_library();
  h = lib_handle;
  CHECK(h, "failed to resolve symbol '%s', library failed to load", sym_names[i]);
#endif

  void *addr;
#if HAS_DLSYM_CALLBACK
  extern void *nvgt_dlsym(void *handle, const char *sym_name);
  addr = nvgt_dlsym(h, sym_names[i]);
  CHECK(addr, "failed to resolve symbol '%s' via callback nvgt_dlsym", sym_names[i]);
#else
  // Dlsym is thread-safe so don't need to protect it.
  addr = dlsym(h, sym_names[i]);
  CHECK(addr, "failed to resolve symbol '%s' via dlsym: %s", sym_names[i], dlerror());
#endif

  if (publish) {
    // Use atomic to please Tsan and ensure that preceeding writes
    // in library ctors have been delivered before publishing address
    (void)__sync_val_compare_and_swap(&_libphonon_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libphonon_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libphonon_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libphonon_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libphonon_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libphonon_so_tramp_table, 0, SYM_COUNT * sizeof(_libphonon_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
#ifdef __cplusplus
extern "C" {
#endif

typedef const struct { size_t field_0; size_t field_1; size_t field_2; size_t field_3; size_t field_4; size_t field_5; } _ZTINSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type;
extern __attribute__((weak)) _ZTINSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTINSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE;
typedef const struct { size_t field_0; size_t field_1; size_t field_2; size_t field_3; } _ZTISt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type;
extern __attribute__((weak)) _ZTISt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTISt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE;
typedef const struct { size_t field_0; size_t field_1; size_t field_2; size_t field_3; size_t field_4; size_t field_5; } _ZTISt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type;
extern __attribute__((weak)) _ZTISt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTISt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE;
typedef const unsigned char _ZTSNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type[];
extern __attribute__((weak)) _ZTSNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTSNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE;
typedef const unsigned char _ZTSSt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type[];
extern __attribute__((weak)) _ZTSSt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTSSt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE;
typedef const unsigned char _ZTSSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type[];
extern __attribute__((weak)) _ZTSSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTSSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE;
typedef const unsigned char _ZTSSt19_Sp_make_shared_tag_type[];
extern __attribute__((weak)) _ZTSSt19_Sp_make_shared_tag_type _ZTSSt19_Sp_make_shared_tag;
typedef const struct { size_t field_0; size_t field_1; size_t field_2; size_t field_3; size_t field_4; size_t field_5; size_t field_6; size_t field_7; size_t field_8; size_t field_9; } _ZTVNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type;
extern __attribute__((weak)) _ZTVNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTVNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE;
const _ZTINSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTINSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE = { 950594UL, 0UL, 0UL, 0UL, 0UL, 0UL };
const _ZTISt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTISt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE = { 950594UL, 0UL, 0UL, 0UL };
const _ZTISt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTISt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE = { 950594UL, 0UL, 0UL, 0UL, 0UL, 0UL };
const _ZTSNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTSNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE = { 87UL, 97UL, 114UL, 110UL, 105UL, 110UL, 103UL, 58UL, 32UL, 0UL, 69UL, 82UL, 82UL, 79UL, 82UL, 58UL, 32UL, 0UL, 40UL, 100UL, 101UL, 98UL, 117UL, 103UL, 41UL, 32UL, 0UL, 37UL, 115UL, 37UL, 115UL, 10UL, 0UL, 47UL, 112UL, 114UL, 111UL, 99UL, 47UL, 115UL, 101UL, 108UL, 102UL, 47UL, 109UL, 97UL, 112UL, 115UL, 0UL, 108UL, 105UL, 98UL, 112UL, 104UL, 111UL, 110UL, 111UL, 110UL, 46UL, 115UL, 111UL, 0UL, 112UL, 104UL, 111UL, 110UL, 111UL, 110UL, 95UL, 116UL, 101UL, 115UL, 116UL, 0UL, 112UL, 104UL, 111UL, 110UL, 111UL, 110UL, 95UL, 112UL };
const _ZTSSt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTSSt11_Mutex_baseILN9__gnu_cxx12_Lock_policyE2EE = { 87UL, 97UL, 114UL, 110UL, 105UL, 110UL, 103UL, 58UL, 32UL, 0UL, 69UL, 82UL, 82UL, 79UL, 82UL, 58UL, 32UL, 0UL, 40UL, 100UL, 101UL, 98UL, 117UL, 103UL, 41UL, 32UL, 0UL, 37UL, 115UL, 37UL, 115UL, 10UL, 0UL, 47UL, 112UL, 114UL, 111UL, 99UL, 47UL, 115UL, 101UL, 108UL, 102UL, 47UL, 109UL, 97UL, 112UL };
const _ZTSSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE_type _ZTSSt16_Sp_counted_baseILN9__gnu_cxx12_Lock_policyE2EE = { 87UL, 97UL, 114UL, 110UL, 105UL, 110UL, 103UL, 58UL, 32UL, 0UL, 69UL, 82UL, 82UL, 79UL, 82UL, 58UL, 32UL, 0UL, 40UL, 100UL, 101UL, 98UL, 117UL, 103UL, 41UL, 32UL, 0UL, 37UL, 115UL, 37UL, 115UL, 10UL, 0UL, 47UL, 112UL, 114UL, 111UL, 99UL, 47UL, 115UL, 101UL, 108UL, 102UL, 47UL, 109UL, 97UL, 112UL, 115UL, 0UL, 108UL, 105UL, 98UL };
const _ZTSSt19_Sp_make_shared_tag_type _ZTSSt19_Sp_make_shared_tag = { 87UL, 97UL, 114UL, 110UL, 105UL, 110UL, 103UL, 58UL, 32UL, 0UL, 69UL, 82UL, 82UL, 79UL, 82UL, 58UL, 32UL, 0UL, 40UL, 100UL, 101UL, 98UL, 117UL, 103UL };
const _ZTVNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE_type _ZTVNSt6thread11_State_implINS_8_InvokerISt5tupleIJMN3ipl10ThreadPoolEFviEPS4_iEEEEEE = { 950594UL, 0UL, 89040UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
#ifdef __cplusplus
}  // extern "C"
#endif
