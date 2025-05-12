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
      fprintf(stderr, "implib-gen: libpango-1.0.so.0: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libpango-1.0.so.0");
  CHECK(lib_handle, "failed to load library 'libpango-1.0.so.0' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libpango-1.0.so.0", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libpango-1.0.so.0' via dlopen: %s", dlerror());
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
  "pango_alignment_get_type",
  "pango_attr_allow_breaks_new",
  "pango_attr_background_alpha_new",
  "pango_attr_background_new",
  "pango_attr_baseline_shift_new",
  "pango_attr_break",
  "pango_attr_fallback_new",
  "pango_attr_family_new",
  "pango_attr_font_desc_new",
  "pango_attr_font_features_new",
  "pango_attr_font_scale_new",
  "pango_attr_foreground_alpha_new",
  "pango_attr_foreground_new",
  "pango_attr_gravity_hint_new",
  "pango_attr_gravity_new",
  "pango_attr_insert_hyphens_new",
  "pango_attr_iterator_copy",
  "pango_attr_iterator_destroy",
  "pango_attr_iterator_get",
  "pango_attr_iterator_get_attrs",
  "pango_attr_iterator_get_font",
  "pango_attr_iterator_get_type",
  "pango_attr_iterator_next",
  "pango_attr_iterator_range",
  "pango_attr_language_new",
  "pango_attr_letter_spacing_new",
  "pango_attr_line_height_new",
  "pango_attr_line_height_new_absolute",
  "pango_attr_list_change",
  "pango_attr_list_copy",
  "pango_attr_list_equal",
  "pango_attr_list_filter",
  "pango_attr_list_from_string",
  "pango_attr_list_get_attributes",
  "pango_attr_list_get_iterator",
  "pango_attr_list_get_type",
  "pango_attr_list_insert",
  "pango_attr_list_insert_before",
  "pango_attr_list_new",
  "pango_attr_list_ref",
  "pango_attr_list_splice",
  "pango_attr_list_to_string",
  "pango_attr_list_unref",
  "pango_attr_list_update",
  "pango_attr_overline_color_new",
  "pango_attr_overline_new",
  "pango_attr_rise_new",
  "pango_attr_scale_new",
  "pango_attr_sentence_new",
  "pango_attr_shape_new",
  "pango_attr_shape_new_with_data",
  "pango_attr_show_new",
  "pango_attr_size_new",
  "pango_attr_size_new_absolute",
  "pango_attr_stretch_new",
  "pango_attr_strikethrough_color_new",
  "pango_attr_strikethrough_new",
  "pango_attr_style_new",
  "pango_attr_text_transform_new",
  "pango_attr_type_get_name",
  "pango_attr_type_get_type",
  "pango_attr_type_register",
  "pango_attr_underline_color_new",
  "pango_attr_underline_new",
  "pango_attr_variant_new",
  "pango_attr_weight_new",
  "pango_attr_word_new",
  "pango_attribute_as_color",
  "pango_attribute_as_float",
  "pango_attribute_as_font_desc",
  "pango_attribute_as_font_features",
  "pango_attribute_as_int",
  "pango_attribute_as_language",
  "pango_attribute_as_shape",
  "pango_attribute_as_size",
  "pango_attribute_as_string",
  "pango_attribute_copy",
  "pango_attribute_destroy",
  "pango_attribute_equal",
  "pango_attribute_get_type",
  "pango_attribute_init",
  "pango_baseline_shift_get_type",
  "pango_bidi_type_for_unichar",
  "pango_bidi_type_get_type",
  "pango_break",
  "pango_color_copy",
  "pango_color_free",
  "pango_color_get_type",
  "pango_color_parse",
  "pango_color_parse_with_alpha",
  "pango_color_to_string",
  "pango_config_key_get",
  "pango_config_key_get_system",
  "pango_context_changed",
  "pango_context_get_base_dir",
  "pango_context_get_base_gravity",
  "pango_context_get_font_description",
  "pango_context_get_font_map",
  "pango_context_get_gravity",
  "pango_context_get_gravity_hint",
  "pango_context_get_language",
  "pango_context_get_matrix",
  "pango_context_get_metrics",
  "pango_context_get_round_glyph_positions",
  "pango_context_get_serial",
  "pango_context_get_type",
  "pango_context_list_families",
  "pango_context_load_font",
  "pango_context_load_fontset",
  "pango_context_new",
  "pango_context_set_base_dir",
  "pango_context_set_base_gravity",
  "pango_context_set_font_description",
  "pango_context_set_font_map",
  "pango_context_set_gravity_hint",
  "pango_context_set_language",
  "pango_context_set_matrix",
  "pango_context_set_round_glyph_positions",
  "pango_coverage_copy",
  "pango_coverage_from_bytes",
  "pango_coverage_get",
  "pango_coverage_get_type",
  "pango_coverage_level_get_type",
  "pango_coverage_max",
  "pango_coverage_new",
  "pango_coverage_ref",
  "pango_coverage_set",
  "pango_coverage_to_bytes",
  "pango_coverage_unref",
  "pango_default_break",
  "pango_direction_get_type",
  "pango_ellipsize_mode_get_type",
  "pango_engine_get_type",
  "pango_engine_lang_get_type",
  "pango_engine_shape_get_type",
  "pango_extents_to_pixels",
  "pango_find_base_dir",
  "pango_find_map",
  "pango_find_paragraph_boundary",
  "pango_font_describe",
  "pango_font_describe_with_absolute_size",
  "pango_font_description_better_match",
  "pango_font_description_copy",
  "pango_font_description_copy_static",
  "pango_font_description_equal",
  "pango_font_description_free",
  "pango_font_description_from_string",
  "pango_font_description_get_family",
  "pango_font_description_get_features",
  "pango_font_description_get_gravity",
  "pango_font_description_get_set_fields",
  "pango_font_description_get_size",
  "pango_font_description_get_size_is_absolute",
  "pango_font_description_get_stretch",
  "pango_font_description_get_style",
  "pango_font_description_get_type",
  "pango_font_description_get_variant",
  "pango_font_description_get_variations",
  "pango_font_description_get_weight",
  "pango_font_description_hash",
  "pango_font_description_merge",
  "pango_font_description_merge_static",
  "pango_font_description_new",
  "pango_font_description_set_absolute_size",
  "pango_font_description_set_family",
  "pango_font_description_set_family_static",
  "pango_font_description_set_features",
  "pango_font_description_set_features_static",
  "pango_font_description_set_gravity",
  "pango_font_description_set_size",
  "pango_font_description_set_stretch",
  "pango_font_description_set_style",
  "pango_font_description_set_variant",
  "pango_font_description_set_variations",
  "pango_font_description_set_variations_static",
  "pango_font_description_set_weight",
  "pango_font_description_to_filename",
  "pango_font_description_to_string",
  "pango_font_description_unset_fields",
  "pango_font_descriptions_free",
  "pango_font_deserialize",
  "pango_font_face_describe",
  "pango_font_face_get_face_name",
  "pango_font_face_get_family",
  "pango_font_face_get_type",
  "pango_font_face_is_synthesized",
  "pango_font_face_list_sizes",
  "pango_font_family_get_face",
  "pango_font_family_get_name",
  "pango_font_family_get_type",
  "pango_font_family_is_monospace",
  "pango_font_family_is_variable",
  "pango_font_family_list_faces",
  "pango_font_find_shaper",
  "pango_font_get_coverage",
  "pango_font_get_face",
  "pango_font_get_features",
  "pango_font_get_font_map",
  "pango_font_get_glyph_extents",
  "pango_font_get_hb_font",
  "pango_font_get_languages",
  "pango_font_get_metrics",
  "pango_font_get_type",
  "pango_font_has_char",
  "pango_font_map_add_font_file",
  "pango_font_map_changed",
  "pango_font_map_create_context",
  "pango_font_map_get_family",
  "pango_font_map_get_serial",
  "pango_font_map_get_shape_engine_type",
  "pango_font_map_get_type",
  "pango_font_map_list_families",
  "pango_font_map_load_font",
  "pango_font_map_load_fontset",
  "pango_font_map_reload_font",
  "pango_font_mask_get_type",
  "pango_font_metrics_get_approximate_char_width",
  "pango_font_metrics_get_approximate_digit_width",
  "pango_font_metrics_get_ascent",
  "pango_font_metrics_get_descent",
  "pango_font_metrics_get_height",
  "pango_font_metrics_get_strikethrough_position",
  "pango_font_metrics_get_strikethrough_thickness",
  "pango_font_metrics_get_type",
  "pango_font_metrics_get_underline_position",
  "pango_font_metrics_get_underline_thickness",
  "pango_font_metrics_new",
  "pango_font_metrics_ref",
  "pango_font_metrics_unref",
  "pango_font_scale_get_type",
  "pango_font_serialize",
  "pango_fontset_foreach",
  "pango_fontset_get_font",
  "pango_fontset_get_metrics",
  "pango_fontset_get_type",
  "pango_fontset_simple_append",
  "pango_fontset_simple_get_type",
  "pango_fontset_simple_new",
  "pango_fontset_simple_size",
  "pango_get_lib_subdirectory",
  "pango_get_log_attrs",
  "pango_get_mirror_char",
  "pango_get_sysconf_subdirectory",
  "pango_glyph_item_apply_attrs",
  "pango_glyph_item_copy",
  "pango_glyph_item_free",
  "pango_glyph_item_get_logical_widths",
  "pango_glyph_item_get_type",
  "pango_glyph_item_iter_copy",
  "pango_glyph_item_iter_free",
  "pango_glyph_item_iter_get_type",
  "pango_glyph_item_iter_init_end",
  "pango_glyph_item_iter_init_start",
  "pango_glyph_item_iter_next_cluster",
  "pango_glyph_item_iter_prev_cluster",
  "pango_glyph_item_letter_space",
  "pango_glyph_item_split",
  "pango_glyph_string_copy",
  "pango_glyph_string_extents",
  "pango_glyph_string_extents_range",
  "pango_glyph_string_free",
  "pango_glyph_string_get_logical_widths",
  "pango_glyph_string_get_type",
  "pango_glyph_string_get_width",
  "pango_glyph_string_index_to_x",
  "pango_glyph_string_index_to_x_full",
  "pango_glyph_string_new",
  "pango_glyph_string_set_size",
  "pango_glyph_string_x_to_index",
  "pango_gravity_get_for_matrix",
  "pango_gravity_get_for_script",
  "pango_gravity_get_for_script_and_width",
  "pango_gravity_get_type",
  "pango_gravity_hint_get_type",
  "pango_gravity_to_rotation",
  "pango_is_zero_width",
  "pango_item_apply_attrs",
  "pango_item_copy",
  "pango_item_free",
  "pango_item_get_char_offset",
  "pango_item_get_type",
  "pango_item_new",
  "pango_item_split",
  "pango_itemize",
  "pango_itemize_with_base_dir",
  "pango_language_from_string",
  "pango_language_get_default",
  "pango_language_get_preferred",
  "pango_language_get_sample_string",
  "pango_language_get_scripts",
  "pango_language_get_type",
  "pango_language_includes_script",
  "pango_language_matches",
  "pango_language_to_string",
  "pango_layout_context_changed",
  "pango_layout_copy",
  "pango_layout_deserialize",
  "pango_layout_deserialize_error_get_type",
  "pango_layout_deserialize_error_quark",
  "pango_layout_deserialize_flags_get_type",
  "pango_layout_get_alignment",
  "pango_layout_get_attributes",
  "pango_layout_get_auto_dir",
  "pango_layout_get_baseline",
  "pango_layout_get_caret_pos",
  "pango_layout_get_character_count",
  "pango_layout_get_context",
  "pango_layout_get_cursor_pos",
  "pango_layout_get_direction",
  "pango_layout_get_ellipsize",
  "pango_layout_get_extents",
  "pango_layout_get_font_description",
  "pango_layout_get_height",
  "pango_layout_get_indent",
  "pango_layout_get_iter",
  "pango_layout_get_justify",
  "pango_layout_get_justify_last_line",
  "pango_layout_get_line",
  "pango_layout_get_line_count",
  "pango_layout_get_line_readonly",
  "pango_layout_get_line_spacing",
  "pango_layout_get_lines",
  "pango_layout_get_lines_readonly",
  "pango_layout_get_log_attrs",
  "pango_layout_get_log_attrs_readonly",
  "pango_layout_get_pixel_extents",
  "pango_layout_get_pixel_size",
  "pango_layout_get_serial",
  "pango_layout_get_single_paragraph_mode",
  "pango_layout_get_size",
  "pango_layout_get_spacing",
  "pango_layout_get_tabs",
  "pango_layout_get_text",
  "pango_layout_get_type",
  "pango_layout_get_unknown_glyphs_count",
  "pango_layout_get_width",
  "pango_layout_get_wrap",
  "pango_layout_index_to_line_x",
  "pango_layout_index_to_pos",
  "pango_layout_is_ellipsized",
  "pango_layout_is_wrapped",
  "pango_layout_iter_at_last_line",
  "pango_layout_iter_copy",
  "pango_layout_iter_free",
  "pango_layout_iter_get_baseline",
  "pango_layout_iter_get_char_extents",
  "pango_layout_iter_get_cluster_extents",
  "pango_layout_iter_get_index",
  "pango_layout_iter_get_layout",
  "pango_layout_iter_get_layout_extents",
  "pango_layout_iter_get_line",
  "pango_layout_iter_get_line_extents",
  "pango_layout_iter_get_line_readonly",
  "pango_layout_iter_get_line_yrange",
  "pango_layout_iter_get_run",
  "pango_layout_iter_get_run_baseline",
  "pango_layout_iter_get_run_extents",
  "pango_layout_iter_get_run_readonly",
  "pango_layout_iter_get_type",
  "pango_layout_iter_next_char",
  "pango_layout_iter_next_cluster",
  "pango_layout_iter_next_line",
  "pango_layout_iter_next_run",
  "pango_layout_line_get_extents",
  "pango_layout_line_get_height",
  "pango_layout_line_get_length",
  "pango_layout_line_get_pixel_extents",
  "pango_layout_line_get_resolved_direction",
  "pango_layout_line_get_start_index",
  "pango_layout_line_get_type",
  "pango_layout_line_get_x_ranges",
  "pango_layout_line_index_to_x",
  "pango_layout_line_is_paragraph_start",
  "pango_layout_line_ref",
  "pango_layout_line_unref",
  "pango_layout_line_x_to_index",
  "pango_layout_move_cursor_visually",
  "pango_layout_new",
  "pango_layout_serialize",
  "pango_layout_serialize_flags_get_type",
  "pango_layout_set_alignment",
  "pango_layout_set_attributes",
  "pango_layout_set_auto_dir",
  "pango_layout_set_ellipsize",
  "pango_layout_set_font_description",
  "pango_layout_set_height",
  "pango_layout_set_indent",
  "pango_layout_set_justify",
  "pango_layout_set_justify_last_line",
  "pango_layout_set_line_spacing",
  "pango_layout_set_markup",
  "pango_layout_set_markup_with_accel",
  "pango_layout_set_single_paragraph_mode",
  "pango_layout_set_spacing",
  "pango_layout_set_tabs",
  "pango_layout_set_text",
  "pango_layout_set_width",
  "pango_layout_set_wrap",
  "pango_layout_write_to_file",
  "pango_layout_xy_to_index",
  "pango_log2vis_get_embedding_levels",
  "pango_lookup_aliases",
  "pango_map_get_engine",
  "pango_map_get_engines",
  "pango_markup_parser_finish",
  "pango_markup_parser_new",
  "pango_matrix_concat",
  "pango_matrix_copy",
  "pango_matrix_free",
  "pango_matrix_get_font_scale_factor",
  "pango_matrix_get_font_scale_factors",
  "pango_matrix_get_slant_ratio",
  "pango_matrix_get_type",
  "pango_matrix_rotate",
  "pango_matrix_scale",
  "pango_matrix_transform_distance",
  "pango_matrix_transform_pixel_rectangle",
  "pango_matrix_transform_point",
  "pango_matrix_transform_rectangle",
  "pango_matrix_translate",
  "pango_module_register",
  "pango_overline_get_type",
  "pango_parse_enum",
  "pango_parse_markup",
  "pango_parse_stretch",
  "pango_parse_style",
  "pango_parse_variant",
  "pango_parse_weight",
  "pango_quantize_line_geometry",
  "pango_read_line",
  "pango_render_part_get_type",
  "pango_renderer_activate",
  "pango_renderer_deactivate",
  "pango_renderer_draw_error_underline",
  "pango_renderer_draw_glyph",
  "pango_renderer_draw_glyph_item",
  "pango_renderer_draw_glyphs",
  "pango_renderer_draw_layout",
  "pango_renderer_draw_layout_line",
  "pango_renderer_draw_rectangle",
  "pango_renderer_draw_trapezoid",
  "pango_renderer_get_alpha",
  "pango_renderer_get_color",
  "pango_renderer_get_layout",
  "pango_renderer_get_layout_line",
  "pango_renderer_get_matrix",
  "pango_renderer_get_type",
  "pango_renderer_part_changed",
  "pango_renderer_set_alpha",
  "pango_renderer_set_color",
  "pango_renderer_set_matrix",
  "pango_reorder_items",
  "pango_scan_int",
  "pango_scan_string",
  "pango_scan_word",
  "pango_script_for_unichar",
  "pango_script_get_sample_language",
  "pango_script_get_type",
  "pango_script_iter_free",
  "pango_script_iter_get_range",
  "pango_script_iter_get_type",
  "pango_script_iter_new",
  "pango_script_iter_next",
  "pango_shape",
  "pango_shape_flags_get_type",
  "pango_shape_full",
  "pango_shape_item",
  "pango_shape_with_flags",
  "pango_show_flags_get_type",
  "pango_skip_space",
  "pango_split_file_list",
  "pango_stretch_get_type",
  "pango_style_get_type",
  "pango_tab_align_get_type",
  "pango_tab_array_copy",
  "pango_tab_array_free",
  "pango_tab_array_from_string",
  "pango_tab_array_get_decimal_point",
  "pango_tab_array_get_positions_in_pixels",
  "pango_tab_array_get_size",
  "pango_tab_array_get_tab",
  "pango_tab_array_get_tabs",
  "pango_tab_array_get_type",
  "pango_tab_array_new",
  "pango_tab_array_new_with_positions",
  "pango_tab_array_resize",
  "pango_tab_array_set_decimal_point",
  "pango_tab_array_set_positions_in_pixels",
  "pango_tab_array_set_tab",
  "pango_tab_array_sort",
  "pango_tab_array_to_string",
  "pango_tailor_break",
  "pango_text_transform_get_type",
  "pango_trim_string",
  "pango_underline_get_type",
  "pango_unichar_direction",
  "pango_units_from_double",
  "pango_units_to_double",
  "pango_variant_get_type",
  "pango_version",
  "pango_version_check",
  "pango_version_string",
  "pango_weight_get_type",
  "pango_wrap_mode_get_type",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libpango_1_0_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libpango_1_0_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libpango_1_0_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libpango_1_0_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libpango_1_0_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libpango_1_0_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libpango_1_0_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libpango_1_0_so_tramp_table, 0, SYM_COUNT * sizeof(_libpango_1_0_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
