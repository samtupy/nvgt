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
      fprintf(stderr, "implib-gen: libgobject-2.0.so.0: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libgobject-2.0.so.0");
  CHECK(lib_handle, "failed to load library 'libgobject-2.0.so.0' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libgobject-2.0.so.0", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libgobject-2.0.so.0' via dlopen: %s", dlerror());
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
  "g_array_get_type",
  "g_binding_dup_source",
  "g_binding_dup_target",
  "g_binding_flags_get_type",
  "g_binding_get_flags",
  "g_binding_get_source",
  "g_binding_get_source_property",
  "g_binding_get_target",
  "g_binding_get_target_property",
  "g_binding_get_type",
  "g_binding_group_bind",
  "g_binding_group_bind_full",
  "g_binding_group_bind_with_closures",
  "g_binding_group_dup_source",
  "g_binding_group_get_type",
  "g_binding_group_new",
  "g_binding_group_set_source",
  "g_binding_unbind",
  "g_bookmark_file_get_type",
  "g_boxed_copy",
  "g_boxed_free",
  "g_boxed_type_register_static",
  "g_byte_array_get_type",
  "g_bytes_get_type",
  "g_cclosure_marshal_BOOLEAN__BOXED_BOXED",
  "g_cclosure_marshal_BOOLEAN__BOXED_BOXEDv",
  "g_cclosure_marshal_BOOLEAN__FLAGS",
  "g_cclosure_marshal_BOOLEAN__FLAGSv",
  "g_cclosure_marshal_STRING__OBJECT_POINTER",
  "g_cclosure_marshal_STRING__OBJECT_POINTERv",
  "g_cclosure_marshal_VOID__BOOLEAN",
  "g_cclosure_marshal_VOID__BOOLEANv",
  "g_cclosure_marshal_VOID__BOXED",
  "g_cclosure_marshal_VOID__BOXEDv",
  "g_cclosure_marshal_VOID__CHAR",
  "g_cclosure_marshal_VOID__CHARv",
  "g_cclosure_marshal_VOID__DOUBLE",
  "g_cclosure_marshal_VOID__DOUBLEv",
  "g_cclosure_marshal_VOID__ENUM",
  "g_cclosure_marshal_VOID__ENUMv",
  "g_cclosure_marshal_VOID__FLAGS",
  "g_cclosure_marshal_VOID__FLAGSv",
  "g_cclosure_marshal_VOID__FLOAT",
  "g_cclosure_marshal_VOID__FLOATv",
  "g_cclosure_marshal_VOID__INT",
  "g_cclosure_marshal_VOID__INTv",
  "g_cclosure_marshal_VOID__LONG",
  "g_cclosure_marshal_VOID__LONGv",
  "g_cclosure_marshal_VOID__OBJECT",
  "g_cclosure_marshal_VOID__OBJECTv",
  "g_cclosure_marshal_VOID__PARAM",
  "g_cclosure_marshal_VOID__PARAMv",
  "g_cclosure_marshal_VOID__POINTER",
  "g_cclosure_marshal_VOID__POINTERv",
  "g_cclosure_marshal_VOID__STRING",
  "g_cclosure_marshal_VOID__STRINGv",
  "g_cclosure_marshal_VOID__UCHAR",
  "g_cclosure_marshal_VOID__UCHARv",
  "g_cclosure_marshal_VOID__UINT",
  "g_cclosure_marshal_VOID__UINT_POINTER",
  "g_cclosure_marshal_VOID__UINT_POINTERv",
  "g_cclosure_marshal_VOID__UINTv",
  "g_cclosure_marshal_VOID__ULONG",
  "g_cclosure_marshal_VOID__ULONGv",
  "g_cclosure_marshal_VOID__VARIANT",
  "g_cclosure_marshal_VOID__VARIANTv",
  "g_cclosure_marshal_VOID__VOID",
  "g_cclosure_marshal_VOID__VOIDv",
  "g_cclosure_marshal_generic",
  "g_cclosure_marshal_generic_va",
  "g_cclosure_new",
  "g_cclosure_new_object",
  "g_cclosure_new_object_swap",
  "g_cclosure_new_swap",
  "g_checksum_get_type",
  "g_clear_object",
  "g_clear_signal_handler",
  "g_closure_add_finalize_notifier",
  "g_closure_add_invalidate_notifier",
  "g_closure_add_marshal_guards",
  "g_closure_get_type",
  "g_closure_invalidate",
  "g_closure_invoke",
  "g_closure_new_object",
  "g_closure_new_simple",
  "g_closure_ref",
  "g_closure_remove_finalize_notifier",
  "g_closure_remove_invalidate_notifier",
  "g_closure_set_marshal",
  "g_closure_set_meta_marshal",
  "g_closure_sink",
  "g_closure_unref",
  "g_date_get_type",
  "g_date_time_get_type",
  "g_dir_get_type",
  "g_enum_complete_type_info",
  "g_enum_get_value",
  "g_enum_get_value_by_name",
  "g_enum_get_value_by_nick",
  "g_enum_register_static",
  "g_enum_to_string",
  "g_error_get_type",
  "g_flags_complete_type_info",
  "g_flags_get_first_value",
  "g_flags_get_value_by_name",
  "g_flags_get_value_by_nick",
  "g_flags_register_static",
  "g_flags_to_string",
  "g_gstring_get_type",
  "g_gtype_get_type",
  "g_hash_table_get_type",
  "g_hmac_get_type",
  "g_initially_unowned_get_type",
  "g_io_channel_get_type",
  "g_io_condition_get_type",
  "g_key_file_get_type",
  "g_main_context_get_type",
  "g_main_loop_get_type",
  "g_mapped_file_get_type",
  "g_markup_parse_context_get_type",
  "g_match_info_get_type",
  "g_normalize_mode_get_type",
  "g_object_add_toggle_ref",
  "g_object_add_weak_pointer",
  "g_object_bind_property",
  "g_object_bind_property_full",
  "g_object_bind_property_with_closures",
  "g_object_class_find_property",
  "g_object_class_install_properties",
  "g_object_class_install_property",
  "g_object_class_list_properties",
  "g_object_class_override_property",
  "g_object_compat_control",
  "g_object_connect",
  "g_object_disconnect",
  "g_object_dup_data",
  "g_object_dup_qdata",
  "g_object_force_floating",
  "g_object_freeze_notify",
  "g_object_get",
  "g_object_get_data",
  "g_object_get_property",
  "g_object_get_qdata",
  "g_object_get_type",
  "g_object_get_valist",
  "g_object_getv",
  "g_object_interface_find_property",
  "g_object_interface_install_property",
  "g_object_interface_list_properties",
  "g_object_is_floating",
  "g_object_new",
  "g_object_new_valist",
  "g_object_new_with_properties",
  "g_object_newv",
  "g_object_notify",
  "g_object_notify_by_pspec",
  "g_object_ref",
  "g_object_ref_sink",
  "g_object_remove_toggle_ref",
  "g_object_remove_weak_pointer",
  "g_object_replace_data",
  "g_object_replace_qdata",
  "g_object_run_dispose",
  "g_object_set",
  "g_object_set_data",
  "g_object_set_data_full",
  "g_object_set_property",
  "g_object_set_qdata",
  "g_object_set_qdata_full",
  "g_object_set_valist",
  "g_object_setv",
  "g_object_steal_data",
  "g_object_steal_qdata",
  "g_object_take_ref",
  "g_object_thaw_notify",
  "g_object_unref",
  "g_object_watch_closure",
  "g_object_weak_ref",
  "g_object_weak_unref",
  "g_option_group_get_type",
  "g_param_spec_boolean",
  "g_param_spec_boxed",
  "g_param_spec_char",
  "g_param_spec_double",
  "g_param_spec_enum",
  "g_param_spec_flags",
  "g_param_spec_float",
  "g_param_spec_get_blurb",
  "g_param_spec_get_default_value",
  "g_param_spec_get_name",
  "g_param_spec_get_name_quark",
  "g_param_spec_get_nick",
  "g_param_spec_get_qdata",
  "g_param_spec_get_redirect_target",
  "g_param_spec_gtype",
  "g_param_spec_int",
  "g_param_spec_int64",
  "g_param_spec_internal",
  "g_param_spec_is_valid_name",
  "g_param_spec_long",
  "g_param_spec_object",
  "g_param_spec_override",
  "g_param_spec_param",
  "g_param_spec_pointer",
  "g_param_spec_pool_free",
  "g_param_spec_pool_insert",
  "g_param_spec_pool_list",
  "g_param_spec_pool_list_owned",
  "g_param_spec_pool_lookup",
  "g_param_spec_pool_new",
  "g_param_spec_pool_remove",
  "g_param_spec_ref",
  "g_param_spec_ref_sink",
  "g_param_spec_set_qdata",
  "g_param_spec_set_qdata_full",
  "g_param_spec_sink",
  "g_param_spec_steal_qdata",
  "g_param_spec_string",
  "g_param_spec_uchar",
  "g_param_spec_uint",
  "g_param_spec_uint64",
  "g_param_spec_ulong",
  "g_param_spec_unichar",
  "g_param_spec_unref",
  "g_param_spec_value_array",
  "g_param_spec_variant",
  "g_param_type_register_static",
  "g_param_value_convert",
  "g_param_value_defaults",
  "g_param_value_is_valid",
  "g_param_value_set_default",
  "g_param_value_validate",
  "g_param_values_cmp",
  "g_pattern_spec_get_type",
  "g_pointer_type_register_static",
  "g_pollfd_get_type",
  "g_ptr_array_get_type",
  "g_rand_get_type",
  "g_regex_get_type",
  "g_signal_accumulator_first_wins",
  "g_signal_accumulator_true_handled",
  "g_signal_add_emission_hook",
  "g_signal_chain_from_overridden",
  "g_signal_chain_from_overridden_handler",
  "g_signal_connect_closure",
  "g_signal_connect_closure_by_id",
  "g_signal_connect_data",
  "g_signal_connect_object",
  "g_signal_emit",
  "g_signal_emit_by_name",
  "g_signal_emit_valist",
  "g_signal_emitv",
  "g_signal_get_invocation_hint",
  "g_signal_group_block",
  "g_signal_group_connect",
  "g_signal_group_connect_after",
  "g_signal_group_connect_closure",
  "g_signal_group_connect_data",
  "g_signal_group_connect_object",
  "g_signal_group_connect_swapped",
  "g_signal_group_dup_target",
  "g_signal_group_get_type",
  "g_signal_group_new",
  "g_signal_group_set_target",
  "g_signal_group_unblock",
  "g_signal_handler_block",
  "g_signal_handler_disconnect",
  "g_signal_handler_find",
  "g_signal_handler_is_connected",
  "g_signal_handler_unblock",
  "g_signal_handlers_block_matched",
  "g_signal_handlers_destroy",
  "g_signal_handlers_disconnect_matched",
  "g_signal_handlers_unblock_matched",
  "g_signal_has_handler_pending",
  "g_signal_is_valid_name",
  "g_signal_list_ids",
  "g_signal_lookup",
  "g_signal_name",
  "g_signal_new",
  "g_signal_new_class_handler",
  "g_signal_new_valist",
  "g_signal_newv",
  "g_signal_override_class_closure",
  "g_signal_override_class_handler",
  "g_signal_parse_name",
  "g_signal_query",
  "g_signal_remove_emission_hook",
  "g_signal_set_va_marshaller",
  "g_signal_stop_emission",
  "g_signal_stop_emission_by_name",
  "g_signal_type_cclosure_new",
  "g_source_get_type",
  "g_source_set_closure",
  "g_source_set_dummy_callback",
  "g_strdup_value_contents",
  "g_strv_builder_get_type",
  "g_strv_get_type",
  "g_thread_get_type",
  "g_time_zone_get_type",
  "g_tree_get_type",
  "g_type_add_class_cache_func",
  "g_type_add_class_private",
  "g_type_add_instance_private",
  "g_type_add_interface_check",
  "g_type_add_interface_dynamic",
  "g_type_add_interface_static",
  "g_type_check_class_cast",
  "g_type_check_class_is_a",
  "g_type_check_instance",
  "g_type_check_instance_cast",
  "g_type_check_instance_is_a",
  "g_type_check_instance_is_fundamentally_a",
  "g_type_check_is_value_type",
  "g_type_check_value",
  "g_type_check_value_holds",
  "g_type_children",
  "g_type_class_add_private",
  "g_type_class_adjust_private_offset",
  "g_type_class_get",
  "g_type_class_get_instance_private_offset",
  "g_type_class_get_private",
  "g_type_class_peek",
  "g_type_class_peek_parent",
  "g_type_class_peek_static",
  "g_type_class_ref",
  "g_type_class_unref",
  "g_type_class_unref_uncached",
  "g_type_create_instance",
  "g_type_default_interface_get",
  "g_type_default_interface_peek",
  "g_type_default_interface_ref",
  "g_type_default_interface_unref",
  "g_type_depth",
  "g_type_ensure",
  "g_type_free_instance",
  "g_type_from_name",
  "g_type_fundamental",
  "g_type_fundamental_next",
  "g_type_get_instance_count",
  "g_type_get_plugin",
  "g_type_get_qdata",
  "g_type_get_type_registration_serial",
  "g_type_init",
  "g_type_init_with_debug_flags",
  "g_type_instance_get_private",
  "g_type_interface_add_prerequisite",
  "g_type_interface_get_plugin",
  "g_type_interface_instantiatable_prerequisite",
  "g_type_interface_peek",
  "g_type_interface_peek_parent",
  "g_type_interface_prerequisites",
  "g_type_interfaces",
  "g_type_is_a",
  "g_type_module_add_interface",
  "g_type_module_get_type",
  "g_type_module_register_enum",
  "g_type_module_register_flags",
  "g_type_module_register_type",
  "g_type_module_set_name",
  "g_type_module_unuse",
  "g_type_module_use",
  "g_type_name",
  "g_type_name_from_class",
  "g_type_name_from_instance",
  "g_type_next_base",
  "g_type_parent",
  "g_type_plugin_complete_interface_info",
  "g_type_plugin_complete_type_info",
  "g_type_plugin_get_type",
  "g_type_plugin_unuse",
  "g_type_plugin_use",
  "g_type_qname",
  "g_type_query",
  "g_type_register_dynamic",
  "g_type_register_fundamental",
  "g_type_register_static",
  "g_type_register_static_simple",
  "g_type_remove_class_cache_func",
  "g_type_remove_interface_check",
  "g_type_set_qdata",
  "g_type_test_flags",
  "g_type_value_table_peek",
  "g_unicode_break_type_get_type",
  "g_unicode_script_get_type",
  "g_unicode_type_get_type",
  "g_uri_get_type",
  "g_value_array_append",
  "g_value_array_copy",
  "g_value_array_free",
  "g_value_array_get_nth",
  "g_value_array_get_type",
  "g_value_array_insert",
  "g_value_array_new",
  "g_value_array_prepend",
  "g_value_array_remove",
  "g_value_array_sort",
  "g_value_array_sort_with_data",
  "g_value_copy",
  "g_value_dup_boxed",
  "g_value_dup_object",
  "g_value_dup_param",
  "g_value_dup_string",
  "g_value_dup_variant",
  "g_value_fits_pointer",
  "g_value_get_boolean",
  "g_value_get_boxed",
  "g_value_get_char",
  "g_value_get_double",
  "g_value_get_enum",
  "g_value_get_flags",
  "g_value_get_float",
  "g_value_get_gtype",
  "g_value_get_int",
  "g_value_get_int64",
  "g_value_get_long",
  "g_value_get_object",
  "g_value_get_param",
  "g_value_get_pointer",
  "g_value_get_schar",
  "g_value_get_string",
  "g_value_get_type",
  "g_value_get_uchar",
  "g_value_get_uint",
  "g_value_get_uint64",
  "g_value_get_ulong",
  "g_value_get_variant",
  "g_value_init",
  "g_value_init_from_instance",
  "g_value_peek_pointer",
  "g_value_register_transform_func",
  "g_value_reset",
  "g_value_set_boolean",
  "g_value_set_boxed",
  "g_value_set_boxed_take_ownership",
  "g_value_set_char",
  "g_value_set_double",
  "g_value_set_enum",
  "g_value_set_flags",
  "g_value_set_float",
  "g_value_set_gtype",
  "g_value_set_instance",
  "g_value_set_int",
  "g_value_set_int64",
  "g_value_set_interned_string",
  "g_value_set_long",
  "g_value_set_object",
  "g_value_set_object_take_ownership",
  "g_value_set_param",
  "g_value_set_param_take_ownership",
  "g_value_set_pointer",
  "g_value_set_schar",
  "g_value_set_static_boxed",
  "g_value_set_static_string",
  "g_value_set_string",
  "g_value_set_string_take_ownership",
  "g_value_set_uchar",
  "g_value_set_uint",
  "g_value_set_uint64",
  "g_value_set_ulong",
  "g_value_set_variant",
  "g_value_steal_string",
  "g_value_take_boxed",
  "g_value_take_object",
  "g_value_take_param",
  "g_value_take_string",
  "g_value_take_variant",
  "g_value_transform",
  "g_value_type_compatible",
  "g_value_type_transformable",
  "g_value_unset",
  "g_variant_builder_get_type",
  "g_variant_dict_get_type",
  "g_variant_get_gtype",
  "g_variant_type_get_gtype",
  "g_weak_ref_clear",
  "g_weak_ref_get",
  "g_weak_ref_init",
  "g_weak_ref_set",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libgobject_2_0_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libgobject_2_0_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libgobject_2_0_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libgobject_2_0_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libgobject_2_0_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libgobject_2_0_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libgobject_2_0_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libgobject_2_0_so_tramp_table, 0, SYM_COUNT * sizeof(_libgobject_2_0_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
