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
      fprintf(stderr, "implib-gen: libgdk_pixbuf-2.0.so.0: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libgdk_pixbuf-2.0.so.0");
  CHECK(lib_handle, "failed to load library 'libgdk_pixbuf-2.0.so.0' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libgdk_pixbuf-2.0.so.0", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libgdk_pixbuf-2.0.so.0' via dlopen: %s", dlerror());
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
  "gdk_colorspace_get_type",
  "gdk_interp_type_get_type",
  "gdk_pixbuf_add_alpha",
  "gdk_pixbuf_alpha_mode_get_type",
  "gdk_pixbuf_animation_get_height",
  "gdk_pixbuf_animation_get_iter",
  "gdk_pixbuf_animation_get_static_image",
  "gdk_pixbuf_animation_get_type",
  "gdk_pixbuf_animation_get_width",
  "gdk_pixbuf_animation_is_static_image",
  "gdk_pixbuf_animation_iter_advance",
  "gdk_pixbuf_animation_iter_get_delay_time",
  "gdk_pixbuf_animation_iter_get_pixbuf",
  "gdk_pixbuf_animation_iter_get_type",
  "gdk_pixbuf_animation_iter_on_currently_loading_frame",
  "gdk_pixbuf_animation_new_from_file",
  "gdk_pixbuf_animation_new_from_resource",
  "gdk_pixbuf_animation_new_from_stream",
  "gdk_pixbuf_animation_new_from_stream_async",
  "gdk_pixbuf_animation_new_from_stream_finish",
  "gdk_pixbuf_animation_ref",
  "gdk_pixbuf_animation_unref",
  "gdk_pixbuf_apply_embedded_orientation",
  "gdk_pixbuf_calculate_rowstride",
  "gdk_pixbuf_composite",
  "gdk_pixbuf_composite_color",
  "gdk_pixbuf_composite_color_simple",
  "gdk_pixbuf_copy",
  "gdk_pixbuf_copy_area",
  "gdk_pixbuf_copy_options",
  "gdk_pixbuf_error_get_type",
  "gdk_pixbuf_error_quark",
  "gdk_pixbuf_fill",
  "gdk_pixbuf_flip",
  "gdk_pixbuf_format_copy",
  "gdk_pixbuf_format_free",
  "gdk_pixbuf_format_get_description",
  "gdk_pixbuf_format_get_extensions",
  "gdk_pixbuf_format_get_license",
  "gdk_pixbuf_format_get_mime_types",
  "gdk_pixbuf_format_get_name",
  "gdk_pixbuf_format_get_type",
  "gdk_pixbuf_format_is_disabled",
  "gdk_pixbuf_format_is_save_option_supported",
  "gdk_pixbuf_format_is_scalable",
  "gdk_pixbuf_format_is_writable",
  "gdk_pixbuf_format_set_disabled",
  "gdk_pixbuf_from_pixdata",
  "gdk_pixbuf_get_bits_per_sample",
  "gdk_pixbuf_get_byte_length",
  "gdk_pixbuf_get_colorspace",
  "gdk_pixbuf_get_file_info",
  "gdk_pixbuf_get_file_info_async",
  "gdk_pixbuf_get_file_info_finish",
  "gdk_pixbuf_get_formats",
  "gdk_pixbuf_get_has_alpha",
  "gdk_pixbuf_get_height",
  "gdk_pixbuf_get_n_channels",
  "gdk_pixbuf_get_option",
  "gdk_pixbuf_get_options",
  "gdk_pixbuf_get_pixels",
  "gdk_pixbuf_get_pixels_with_length",
  "gdk_pixbuf_get_rowstride",
  "gdk_pixbuf_get_type",
  "gdk_pixbuf_get_width",
  "gdk_pixbuf_init_modules",
  "gdk_pixbuf_loader_close",
  "gdk_pixbuf_loader_get_animation",
  "gdk_pixbuf_loader_get_format",
  "gdk_pixbuf_loader_get_pixbuf",
  "gdk_pixbuf_loader_get_type",
  "gdk_pixbuf_loader_new",
  "gdk_pixbuf_loader_new_with_mime_type",
  "gdk_pixbuf_loader_new_with_type",
  "gdk_pixbuf_loader_set_size",
  "gdk_pixbuf_loader_write",
  "gdk_pixbuf_loader_write_bytes",
  "gdk_pixbuf_new",
  "gdk_pixbuf_new_from_bytes",
  "gdk_pixbuf_new_from_data",
  "gdk_pixbuf_new_from_file",
  "gdk_pixbuf_new_from_file_at_scale",
  "gdk_pixbuf_new_from_file_at_size",
  "gdk_pixbuf_new_from_inline",
  "gdk_pixbuf_new_from_resource",
  "gdk_pixbuf_new_from_resource_at_scale",
  "gdk_pixbuf_new_from_stream",
  "gdk_pixbuf_new_from_stream_async",
  "gdk_pixbuf_new_from_stream_at_scale",
  "gdk_pixbuf_new_from_stream_at_scale_async",
  "gdk_pixbuf_new_from_stream_finish",
  "gdk_pixbuf_new_from_xpm_data",
  "gdk_pixbuf_new_subpixbuf",
  "gdk_pixbuf_non_anim_get_type",
  "gdk_pixbuf_non_anim_new",
  "gdk_pixbuf_read_pixel_bytes",
  "gdk_pixbuf_read_pixels",
  "gdk_pixbuf_ref",
  "gdk_pixbuf_remove_option",
  "gdk_pixbuf_rotate_simple",
  "gdk_pixbuf_rotation_get_type",
  "gdk_pixbuf_saturate_and_pixelate",
  "gdk_pixbuf_save",
  "gdk_pixbuf_save_to_buffer",
  "gdk_pixbuf_save_to_bufferv",
  "gdk_pixbuf_save_to_callback",
  "gdk_pixbuf_save_to_callbackv",
  "gdk_pixbuf_save_to_stream",
  "gdk_pixbuf_save_to_stream_async",
  "gdk_pixbuf_save_to_stream_finish",
  "gdk_pixbuf_save_to_streamv",
  "gdk_pixbuf_save_to_streamv_async",
  "gdk_pixbuf_savev",
  "gdk_pixbuf_scale",
  "gdk_pixbuf_scale_simple",
  "gdk_pixbuf_set_option",
  "gdk_pixbuf_simple_anim_add_frame",
  "gdk_pixbuf_simple_anim_get_loop",
  "gdk_pixbuf_simple_anim_get_type",
  "gdk_pixbuf_simple_anim_iter_get_type",
  "gdk_pixbuf_simple_anim_new",
  "gdk_pixbuf_simple_anim_set_loop",
  "gdk_pixbuf_unref",
  "gdk_pixdata_deserialize",
  "gdk_pixdata_from_pixbuf",
  "gdk_pixdata_serialize",
  "gdk_pixdata_to_csource",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libgdk_pixbuf_2_0_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libgdk_pixbuf_2_0_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libgdk_pixbuf_2_0_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libgdk_pixbuf_2_0_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libgdk_pixbuf_2_0_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libgdk_pixbuf_2_0_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libgdk_pixbuf_2_0_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libgdk_pixbuf_2_0_so_tramp_table, 0, SYM_COUNT * sizeof(_libgdk_pixbuf_2_0_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
