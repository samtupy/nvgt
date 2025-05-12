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
      fprintf(stderr, "implib-gen: libdbus-1.so.3: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libdbus-1.so.3");
  CHECK(lib_handle, "failed to load library 'libdbus-1.so.3' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libdbus-1.so.3", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libdbus-1.so.3' via dlopen: %s", dlerror());
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
  "_dbus_abort",
  "_dbus_address_append_escaped",
  "_dbus_append_user_from_current_process",
  "_dbus_atomic_dec",
  "_dbus_atomic_get",
  "_dbus_atomic_inc",
  "_dbus_atomic_set_nonzero",
  "_dbus_atomic_set_zero",
  "_dbus_auth_bytes_sent",
  "_dbus_auth_client_new",
  "_dbus_auth_delete_unused_bytes",
  "_dbus_auth_do_work",
  "_dbus_auth_dump_supported_mechanisms",
  "_dbus_auth_get_buffer",
  "_dbus_auth_get_bytes_to_send",
  "_dbus_auth_get_identity",
  "_dbus_auth_get_unused_bytes",
  "_dbus_auth_is_supported_mechanism",
  "_dbus_auth_ref",
  "_dbus_auth_return_buffer",
  "_dbus_auth_server_new",
  "_dbus_auth_set_context",
  "_dbus_auth_set_credentials",
  "_dbus_auth_set_mechanisms",
  "_dbus_auth_unref",
  "_dbus_clearenv",
  "_dbus_close",
  "_dbus_close_all",
  "_dbus_close_socket",
  "_dbus_concat_dir_and_file",
  "_dbus_connection_get_credentials",
  "_dbus_connection_get_linux_security_label",
  "_dbus_connection_get_next_client_serial",
  "_dbus_connection_get_pending_fds_count",
  "_dbus_connection_get_stats",
  "_dbus_connection_lock",
  "_dbus_connection_ref_unlocked",
  "_dbus_connection_set_pending_fds_function",
  "_dbus_connection_unlock",
  "_dbus_connection_unref_unlocked",
  "_dbus_create_directory",
  "_dbus_create_uuid",
  "_dbus_credentials_add_pid",
  "_dbus_credentials_add_unix_uid",
  "_dbus_credentials_add_windows_sid",
  "_dbus_credentials_are_anonymous",
  "_dbus_credentials_are_empty",
  "_dbus_credentials_are_superset",
  "_dbus_credentials_clear",
  "_dbus_credentials_copy",
  "_dbus_credentials_get_linux_security_label",
  "_dbus_credentials_get_pid",
  "_dbus_credentials_get_pid_fd",
  "_dbus_credentials_get_unix_gids",
  "_dbus_credentials_get_unix_uid",
  "_dbus_credentials_get_windows_sid",
  "_dbus_credentials_include",
  "_dbus_credentials_new",
  "_dbus_credentials_new_from_current_process",
  "_dbus_credentials_ref",
  "_dbus_credentials_same_user",
  "_dbus_credentials_take_pid_fd",
  "_dbus_credentials_take_unix_gids",
  "_dbus_credentials_to_string_append",
  "_dbus_credentials_unref",
  "_dbus_delete_directory",
  "_dbus_delete_file",
  "_dbus_dup",
  "_dbus_ensure_directory",
  "_dbus_ensure_standard_fds",
  "_dbus_error_from_errno",
  "_dbus_error_from_system_errno",
  "_dbus_exit",
  "_dbus_fd_clear_close_on_exec",
  "_dbus_fd_set_all_close_on_exec",
  "_dbus_fd_set_close_on_exec",
  "_dbus_file_get_contents",
  "_dbus_first_type_in_signature",
  "_dbus_flush_caches",
  "_dbus_generate_random_ascii",
  "_dbus_generate_uuid",
  "_dbus_get_local_machine_uuid_encoded",
  "_dbus_get_monotonic_time",
  "_dbus_get_real_time",
  "_dbus_get_tmpdir",
  "_dbus_get_uuid",
  "_dbus_getenv",
  "_dbus_geteuid",
  "_dbus_getpid",
  "_dbus_getuid",
  "_dbus_group_info_unref",
  "_dbus_hash_iter_get_int_key",
  "_dbus_hash_iter_get_string_key",
  "_dbus_hash_iter_get_uintptr_key",
  "_dbus_hash_iter_get_value",
  "_dbus_hash_iter_init",
  "_dbus_hash_iter_lookup",
  "_dbus_hash_iter_next",
  "_dbus_hash_iter_remove_entry",
  "_dbus_hash_iter_set_value",
  "_dbus_hash_table_free_preallocated_entry",
  "_dbus_hash_table_from_array",
  "_dbus_hash_table_get_n_entries",
  "_dbus_hash_table_insert_int",
  "_dbus_hash_table_insert_string",
  "_dbus_hash_table_insert_string_preallocated",
  "_dbus_hash_table_insert_uintptr",
  "_dbus_hash_table_lookup_int",
  "_dbus_hash_table_lookup_string",
  "_dbus_hash_table_lookup_uintptr",
  "_dbus_hash_table_new",
  "_dbus_hash_table_preallocate_entry",
  "_dbus_hash_table_ref",
  "_dbus_hash_table_remove_int",
  "_dbus_hash_table_remove_string",
  "_dbus_hash_table_remove_uintptr",
  "_dbus_hash_table_to_array",
  "_dbus_hash_table_unref",
  "_dbus_header_delete_field",
  "_dbus_header_get_byte_order",
  "_dbus_header_get_field_raw",
  "_dbus_header_set_field_basic",
  "_dbus_homedir_from_current_process",
  "_dbus_init_system_log",
  "_dbus_is_a_number",
  "_dbus_list_alloc_link",
  "_dbus_list_append",
  "_dbus_list_append_link",
  "_dbus_list_clear",
  "_dbus_list_clear_full",
  "_dbus_list_copy",
  "_dbus_list_find_last",
  "_dbus_list_foreach",
  "_dbus_list_free_link",
  "_dbus_list_get_first",
  "_dbus_list_get_first_link",
  "_dbus_list_get_last",
  "_dbus_list_get_last_link",
  "_dbus_list_get_length",
  "_dbus_list_get_stats",
  "_dbus_list_insert_after",
  "_dbus_list_insert_after_link",
  "_dbus_list_insert_before_link",
  "_dbus_list_length_is_one",
  "_dbus_list_pop_first",
  "_dbus_list_pop_first_link",
  "_dbus_list_pop_last",
  "_dbus_list_prepend",
  "_dbus_list_prepend_link",
  "_dbus_list_remove",
  "_dbus_list_remove_last",
  "_dbus_list_remove_link",
  "_dbus_list_unlink",
  "_dbus_log",
  "_dbus_logv",
  "_dbus_lookup_session_address",
  "_dbus_marshal_byteswap",
  "_dbus_marshal_read_uint32",
  "_dbus_marshal_set_uint32",
  "_dbus_mem_pool_alloc",
  "_dbus_mem_pool_dealloc",
  "_dbus_mem_pool_free",
  "_dbus_mem_pool_new",
  "_dbus_message_get_unix_fds",
  "_dbus_message_iter_get_args_valist",
  "_dbus_message_loader_get_buffer",
  "_dbus_message_loader_get_is_corrupted",
  "_dbus_message_loader_get_max_message_size",
  "_dbus_message_loader_get_unix_fds",
  "_dbus_message_loader_new",
  "_dbus_message_loader_pop_message",
  "_dbus_message_loader_queue_messages",
  "_dbus_message_loader_ref",
  "_dbus_message_loader_return_buffer",
  "_dbus_message_loader_return_unix_fds",
  "_dbus_message_loader_unref",
  "_dbus_message_remove_unknown_fields",
  "_dbus_pending_call_new_unlocked",
  "_dbus_pending_call_ref_unlocked",
  "_dbus_pending_call_unref_and_unlock",
  "_dbus_pipe_close",
  "_dbus_pipe_init",
  "_dbus_pipe_init_stdout",
  "_dbus_pipe_invalidate",
  "_dbus_pipe_is_stdout_or_stderr",
  "_dbus_pipe_is_valid",
  "_dbus_pipe_write",
  "_dbus_poll",
  "_dbus_print_backtrace",
  "_dbus_printf_string_upper_bound",
  "_dbus_read",
  "_dbus_read_local_machine_uuid",
  "_dbus_read_socket",
  "_dbus_register_shutdown_func",
  "_dbus_resolve_pid_fd",
  "_dbus_rmutex_lock",
  "_dbus_rmutex_unlock",
  "_dbus_server_new_for_tcp_socket",
  "_dbus_server_ref_unlocked",
  "_dbus_server_toggle_all_watches",
  "_dbus_server_unref_unlocked",
  "_dbus_set_error_valist",
  "_dbus_sleep_milliseconds",
  "_dbus_socketpair",
  "_dbus_split_paths_and_append",
  "_dbus_strdup",
  "_dbus_strerror",
  "_dbus_strerror_from_errno",
  "_dbus_string_append",
  "_dbus_string_append_byte",
  "_dbus_string_append_len",
  "_dbus_string_append_printf",
  "_dbus_string_append_printf_valist",
  "_dbus_string_append_strings",
  "_dbus_string_array_contains",
  "_dbus_string_array_length",
  "_dbus_string_chop_white",
  "_dbus_string_compact",
  "_dbus_string_copy",
  "_dbus_string_copy_data",
  "_dbus_string_copy_len",
  "_dbus_string_copy_to_buffer_with_nul",
  "_dbus_string_delete",
  "_dbus_string_equal",
  "_dbus_string_equal_c_str",
  "_dbus_string_equal_len",
  "_dbus_string_equal_substring",
  "_dbus_string_find",
  "_dbus_string_find_blank",
  "_dbus_string_find_eol",
  "_dbus_string_find_to",
  "_dbus_string_free",
  "_dbus_string_get_allocated_size",
  "_dbus_string_get_data_len",
  "_dbus_string_hex_decode",
  "_dbus_string_hex_encode",
  "_dbus_string_init",
  "_dbus_string_init_const",
  "_dbus_string_init_const_len",
  "_dbus_string_init_from_string",
  "_dbus_string_init_preallocated",
  "_dbus_string_insert_8_aligned",
  "_dbus_string_insert_byte",
  "_dbus_string_insert_bytes",
  "_dbus_string_lengthen",
  "_dbus_string_move",
  "_dbus_string_parse_int",
  "_dbus_string_parse_int64",
  "_dbus_string_parse_uint",
  "_dbus_string_pop_line",
  "_dbus_string_replace_len",
  "_dbus_string_set_length",
  "_dbus_string_shorten",
  "_dbus_string_skip_blank",
  "_dbus_string_skip_white",
  "_dbus_string_split_on_byte",
  "_dbus_string_starts_with_c_str",
  "_dbus_string_starts_with_words_c_str",
  "_dbus_string_steal_data",
  "_dbus_string_tolower_ascii",
  "_dbus_string_toupper_ascii",
  "_dbus_string_validate_nul",
  "_dbus_string_validate_utf8",
  "_dbus_timeout_disable",
  "_dbus_timeout_needs_restart",
  "_dbus_timeout_new",
  "_dbus_timeout_restart",
  "_dbus_timeout_restarted",
  "_dbus_timeout_unref",
  "_dbus_type_reader_delete",
  "_dbus_type_reader_get_current_type",
  "_dbus_type_reader_get_element_type",
  "_dbus_type_reader_get_signature",
  "_dbus_type_reader_get_value_pos",
  "_dbus_type_reader_init",
  "_dbus_type_reader_init_types_only",
  "_dbus_type_reader_next",
  "_dbus_type_reader_read_basic",
  "_dbus_type_reader_read_fixed_multi",
  "_dbus_type_reader_recurse",
  "_dbus_type_reader_set_basic",
  "_dbus_type_to_string",
  "_dbus_type_writer_init",
  "_dbus_type_writer_init_values_only",
  "_dbus_type_writer_recurse",
  "_dbus_type_writer_unrecurse",
  "_dbus_type_writer_write_basic",
  "_dbus_type_writer_write_fixed_multi",
  "_dbus_type_writer_write_reader",
  "_dbus_user_database_get_system",
  "_dbus_user_database_get_uid",
  "_dbus_user_database_get_username",
  "_dbus_user_database_lock_system",
  "_dbus_user_database_lookup",
  "_dbus_user_database_unlock_system",
  "_dbus_username_from_current_process",
  "_dbus_uuid_encode",
  "_dbus_validate_body_with_reason",
  "_dbus_validate_bus_name",
  "_dbus_validate_bus_namespace",
  "_dbus_validate_error_name",
  "_dbus_validate_interface",
  "_dbus_validate_member",
  "_dbus_validate_path",
  "_dbus_validate_signature_with_reason",
  "_dbus_variant_free",
  "_dbus_variant_get_length",
  "_dbus_variant_get_signature",
  "_dbus_variant_peek",
  "_dbus_variant_read",
  "_dbus_variant_write",
  "_dbus_verbose_bytes_of_string",
  "_dbus_warn",
  "_dbus_warn_check_failed",
  "_dbus_warn_return_if_fail",
  "_dbus_watch_get_oom_last_time",
  "_dbus_watch_get_pollable",
  "_dbus_watch_invalidate",
  "_dbus_watch_list_add_watch",
  "_dbus_watch_list_free",
  "_dbus_watch_list_new",
  "_dbus_watch_list_remove_watch",
  "_dbus_watch_list_set_functions",
  "_dbus_watch_new",
  "_dbus_watch_ref",
  "_dbus_watch_set_oom_last_time",
  "_dbus_watch_unref",
  "_dbus_write_socket",
  "_dbus_write_socket_with_unix_fds",
  "dbus_address_entries_free",
  "dbus_address_entry_get_method",
  "dbus_address_entry_get_value",
  "dbus_address_escape_value",
  "dbus_address_unescape_value",
  "dbus_bus_add_match",
  "dbus_bus_get",
  "dbus_bus_get_id",
  "dbus_bus_get_private",
  "dbus_bus_get_unique_name",
  "dbus_bus_get_unix_user",
  "dbus_bus_name_has_owner",
  "dbus_bus_register",
  "dbus_bus_release_name",
  "dbus_bus_remove_match",
  "dbus_bus_request_name",
  "dbus_bus_set_unique_name",
  "dbus_bus_start_service_by_name",
  "dbus_connection_add_filter",
  "dbus_connection_allocate_data_slot",
  "dbus_connection_borrow_message",
  "dbus_connection_can_send_type",
  "dbus_connection_close",
  "dbus_connection_dispatch",
  "dbus_connection_flush",
  "dbus_connection_free_data_slot",
  "dbus_connection_free_preallocated_send",
  "dbus_connection_get_adt_audit_session_data",
  "dbus_connection_get_data",
  "dbus_connection_get_dispatch_status",
  "dbus_connection_get_is_anonymous",
  "dbus_connection_get_is_authenticated",
  "dbus_connection_get_is_connected",
  "dbus_connection_get_max_message_size",
  "dbus_connection_get_max_message_unix_fds",
  "dbus_connection_get_max_received_size",
  "dbus_connection_get_max_received_unix_fds",
  "dbus_connection_get_object_path_data",
  "dbus_connection_get_outgoing_size",
  "dbus_connection_get_outgoing_unix_fds",
  "dbus_connection_get_server_id",
  "dbus_connection_get_socket",
  "dbus_connection_get_unix_fd",
  "dbus_connection_get_unix_process_id",
  "dbus_connection_get_unix_user",
  "dbus_connection_get_windows_user",
  "dbus_connection_has_messages_to_send",
  "dbus_connection_list_registered",
  "dbus_connection_open",
  "dbus_connection_open_private",
  "dbus_connection_pop_message",
  "dbus_connection_preallocate_send",
  "dbus_connection_read_write",
  "dbus_connection_read_write_dispatch",
  "dbus_connection_ref",
  "dbus_connection_register_fallback",
  "dbus_connection_register_object_path",
  "dbus_connection_remove_filter",
  "dbus_connection_return_message",
  "dbus_connection_send",
  "dbus_connection_send_preallocated",
  "dbus_connection_send_with_reply",
  "dbus_connection_send_with_reply_and_block",
  "dbus_connection_set_allow_anonymous",
  "dbus_connection_set_builtin_filters_enabled",
  "dbus_connection_set_change_sigpipe",
  "dbus_connection_set_data",
  "dbus_connection_set_dispatch_status_function",
  "dbus_connection_set_exit_on_disconnect",
  "dbus_connection_set_max_message_size",
  "dbus_connection_set_max_message_unix_fds",
  "dbus_connection_set_max_received_size",
  "dbus_connection_set_max_received_unix_fds",
  "dbus_connection_set_route_peer_messages",
  "dbus_connection_set_timeout_functions",
  "dbus_connection_set_unix_user_function",
  "dbus_connection_set_wakeup_main_function",
  "dbus_connection_set_watch_functions",
  "dbus_connection_set_windows_user_function",
  "dbus_connection_steal_borrowed_message",
  "dbus_connection_try_register_fallback",
  "dbus_connection_try_register_object_path",
  "dbus_connection_unref",
  "dbus_connection_unregister_object_path",
  "dbus_error_free",
  "dbus_error_has_name",
  "dbus_error_init",
  "dbus_error_is_set",
  "dbus_free",
  "dbus_free_string_array",
  "dbus_get_local_machine_id",
  "dbus_get_version",
  "dbus_malloc",
  "dbus_malloc0",
  "dbus_message_allocate_data_slot",
  "dbus_message_append_args",
  "dbus_message_append_args_valist",
  "dbus_message_contains_unix_fds",
  "dbus_message_copy",
  "dbus_message_demarshal",
  "dbus_message_demarshal_bytes_needed",
  "dbus_message_free_data_slot",
  "dbus_message_get_allow_interactive_authorization",
  "dbus_message_get_args",
  "dbus_message_get_args_valist",
  "dbus_message_get_auto_start",
  "dbus_message_get_container_instance",
  "dbus_message_get_data",
  "dbus_message_get_destination",
  "dbus_message_get_error_name",
  "dbus_message_get_interface",
  "dbus_message_get_member",
  "dbus_message_get_no_reply",
  "dbus_message_get_path",
  "dbus_message_get_path_decomposed",
  "dbus_message_get_reply_serial",
  "dbus_message_get_sender",
  "dbus_message_get_serial",
  "dbus_message_get_signature",
  "dbus_message_get_type",
  "dbus_message_has_destination",
  "dbus_message_has_interface",
  "dbus_message_has_member",
  "dbus_message_has_path",
  "dbus_message_has_sender",
  "dbus_message_has_signature",
  "dbus_message_is_error",
  "dbus_message_is_method_call",
  "dbus_message_is_signal",
  "dbus_message_iter_abandon_container",
  "dbus_message_iter_abandon_container_if_open",
  "dbus_message_iter_append_basic",
  "dbus_message_iter_append_fixed_array",
  "dbus_message_iter_close_container",
  "dbus_message_iter_get_arg_type",
  "dbus_message_iter_get_array_len",
  "dbus_message_iter_get_basic",
  "dbus_message_iter_get_element_count",
  "dbus_message_iter_get_element_type",
  "dbus_message_iter_get_fixed_array",
  "dbus_message_iter_get_signature",
  "dbus_message_iter_has_next",
  "dbus_message_iter_init",
  "dbus_message_iter_init_append",
  "dbus_message_iter_init_closed",
  "dbus_message_iter_next",
  "dbus_message_iter_open_container",
  "dbus_message_iter_recurse",
  "dbus_message_lock",
  "dbus_message_marshal",
  "dbus_message_new",
  "dbus_message_new_error",
  "dbus_message_new_error_printf",
  "dbus_message_new_method_call",
  "dbus_message_new_method_return",
  "dbus_message_new_signal",
  "dbus_message_ref",
  "dbus_message_set_allow_interactive_authorization",
  "dbus_message_set_auto_start",
  "dbus_message_set_container_instance",
  "dbus_message_set_data",
  "dbus_message_set_destination",
  "dbus_message_set_error_name",
  "dbus_message_set_interface",
  "dbus_message_set_member",
  "dbus_message_set_no_reply",
  "dbus_message_set_path",
  "dbus_message_set_reply_serial",
  "dbus_message_set_sender",
  "dbus_message_set_serial",
  "dbus_message_type_from_string",
  "dbus_message_type_to_string",
  "dbus_message_unref",
  "dbus_move_error",
  "dbus_parse_address",
  "dbus_pending_call_allocate_data_slot",
  "dbus_pending_call_block",
  "dbus_pending_call_cancel",
  "dbus_pending_call_free_data_slot",
  "dbus_pending_call_get_completed",
  "dbus_pending_call_get_data",
  "dbus_pending_call_ref",
  "dbus_pending_call_set_data",
  "dbus_pending_call_set_notify",
  "dbus_pending_call_steal_reply",
  "dbus_pending_call_unref",
  "dbus_realloc",
  "dbus_server_allocate_data_slot",
  "dbus_server_disconnect",
  "dbus_server_free_data_slot",
  "dbus_server_get_address",
  "dbus_server_get_data",
  "dbus_server_get_id",
  "dbus_server_get_is_connected",
  "dbus_server_listen",
  "dbus_server_ref",
  "dbus_server_set_auth_mechanisms",
  "dbus_server_set_data",
  "dbus_server_set_new_connection_function",
  "dbus_server_set_timeout_functions",
  "dbus_server_set_watch_functions",
  "dbus_server_unref",
  "dbus_set_error",
  "dbus_set_error_const",
  "dbus_set_error_from_message",
  "dbus_setenv",
  "dbus_shutdown",
  "dbus_signature_iter_get_current_type",
  "dbus_signature_iter_get_element_type",
  "dbus_signature_iter_get_signature",
  "dbus_signature_iter_init",
  "dbus_signature_iter_next",
  "dbus_signature_iter_recurse",
  "dbus_signature_validate",
  "dbus_signature_validate_single",
  "dbus_threads_init",
  "dbus_threads_init_default",
  "dbus_timeout_get_data",
  "dbus_timeout_get_enabled",
  "dbus_timeout_get_interval",
  "dbus_timeout_handle",
  "dbus_timeout_set_data",
  "dbus_try_get_local_machine_id",
  "dbus_type_is_basic",
  "dbus_type_is_container",
  "dbus_type_is_fixed",
  "dbus_type_is_valid",
  "dbus_validate_bus_name",
  "dbus_validate_error_name",
  "dbus_validate_interface",
  "dbus_validate_member",
  "dbus_validate_path",
  "dbus_validate_utf8",
  "dbus_watch_get_data",
  "dbus_watch_get_enabled",
  "dbus_watch_get_fd",
  "dbus_watch_get_flags",
  "dbus_watch_get_socket",
  "dbus_watch_get_unix_fd",
  "dbus_watch_handle",
  "dbus_watch_set_data",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libdbus_1_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libdbus_1_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libdbus_1_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libdbus_1_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libdbus_1_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libdbus_1_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libdbus_1_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libdbus_1_so_tramp_table, 0, SYM_COUNT * sizeof(_libdbus_1_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
