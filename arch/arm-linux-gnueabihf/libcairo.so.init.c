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
      fprintf(stderr, "implib-gen: libcairo.so.2: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libcairo.so.2");
  CHECK(lib_handle, "failed to load library 'libcairo.so.2' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libcairo.so.2", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libcairo.so.2' via dlopen: %s", dlerror());
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
  "cairo_append_path",
  "cairo_arc",
  "cairo_arc_negative",
  "cairo_clip",
  "cairo_clip_extents",
  "cairo_clip_preserve",
  "cairo_close_path",
  "cairo_copy_clip_rectangle_list",
  "cairo_copy_page",
  "cairo_copy_path",
  "cairo_copy_path_flat",
  "cairo_create",
  "cairo_curve_to",
  "cairo_debug_reset_static_data",
  "cairo_destroy",
  "cairo_device_acquire",
  "cairo_device_destroy",
  "cairo_device_finish",
  "cairo_device_flush",
  "cairo_device_get_reference_count",
  "cairo_device_get_type",
  "cairo_device_get_user_data",
  "cairo_device_observer_elapsed",
  "cairo_device_observer_fill_elapsed",
  "cairo_device_observer_glyphs_elapsed",
  "cairo_device_observer_mask_elapsed",
  "cairo_device_observer_paint_elapsed",
  "cairo_device_observer_print",
  "cairo_device_observer_stroke_elapsed",
  "cairo_device_reference",
  "cairo_device_release",
  "cairo_device_set_user_data",
  "cairo_device_status",
  "cairo_device_to_user",
  "cairo_device_to_user_distance",
  "cairo_fill",
  "cairo_fill_extents",
  "cairo_fill_preserve",
  "cairo_font_extents",
  "cairo_font_face_destroy",
  "cairo_font_face_get_reference_count",
  "cairo_font_face_get_type",
  "cairo_font_face_get_user_data",
  "cairo_font_face_reference",
  "cairo_font_face_set_user_data",
  "cairo_font_face_status",
  "cairo_font_options_copy",
  "cairo_font_options_create",
  "cairo_font_options_destroy",
  "cairo_font_options_equal",
  "cairo_font_options_get_antialias",
  "cairo_font_options_get_color_mode",
  "cairo_font_options_get_color_palette",
  "cairo_font_options_get_custom_palette_color",
  "cairo_font_options_get_hint_metrics",
  "cairo_font_options_get_hint_style",
  "cairo_font_options_get_subpixel_order",
  "cairo_font_options_get_variations",
  "cairo_font_options_hash",
  "cairo_font_options_merge",
  "cairo_font_options_set_antialias",
  "cairo_font_options_set_color_mode",
  "cairo_font_options_set_color_palette",
  "cairo_font_options_set_custom_palette_color",
  "cairo_font_options_set_hint_metrics",
  "cairo_font_options_set_hint_style",
  "cairo_font_options_set_subpixel_order",
  "cairo_font_options_set_variations",
  "cairo_font_options_status",
  "cairo_format_stride_for_width",
  "cairo_ft_font_face_create_for_ft_face",
  "cairo_ft_font_face_create_for_pattern",
  "cairo_ft_font_face_get_synthesize",
  "cairo_ft_font_face_set_synthesize",
  "cairo_ft_font_face_unset_synthesize",
  "cairo_ft_font_options_substitute",
  "cairo_ft_scaled_font_lock_face",
  "cairo_ft_scaled_font_unlock_face",
  "cairo_get_antialias",
  "cairo_get_current_point",
  "cairo_get_dash",
  "cairo_get_dash_count",
  "cairo_get_fill_rule",
  "cairo_get_font_face",
  "cairo_get_font_matrix",
  "cairo_get_font_options",
  "cairo_get_group_target",
  "cairo_get_hairline",
  "cairo_get_line_cap",
  "cairo_get_line_join",
  "cairo_get_line_width",
  "cairo_get_matrix",
  "cairo_get_miter_limit",
  "cairo_get_operator",
  "cairo_get_reference_count",
  "cairo_get_scaled_font",
  "cairo_get_source",
  "cairo_get_target",
  "cairo_get_tolerance",
  "cairo_get_user_data",
  "cairo_glyph_allocate",
  "cairo_glyph_extents",
  "cairo_glyph_free",
  "cairo_glyph_path",
  "cairo_has_current_point",
  "cairo_identity_matrix",
  "cairo_image_surface_create",
  "cairo_image_surface_create_for_data",
  "cairo_image_surface_create_from_png",
  "cairo_image_surface_create_from_png_stream",
  "cairo_image_surface_get_data",
  "cairo_image_surface_get_format",
  "cairo_image_surface_get_height",
  "cairo_image_surface_get_stride",
  "cairo_image_surface_get_width",
  "cairo_in_clip",
  "cairo_in_fill",
  "cairo_in_stroke",
  "cairo_line_to",
  "cairo_mask",
  "cairo_mask_surface",
  "cairo_matrix_init",
  "cairo_matrix_init_identity",
  "cairo_matrix_init_rotate",
  "cairo_matrix_init_scale",
  "cairo_matrix_init_translate",
  "cairo_matrix_invert",
  "cairo_matrix_multiply",
  "cairo_matrix_rotate",
  "cairo_matrix_scale",
  "cairo_matrix_transform_distance",
  "cairo_matrix_transform_point",
  "cairo_matrix_translate",
  "cairo_mesh_pattern_begin_patch",
  "cairo_mesh_pattern_curve_to",
  "cairo_mesh_pattern_end_patch",
  "cairo_mesh_pattern_get_control_point",
  "cairo_mesh_pattern_get_corner_color_rgba",
  "cairo_mesh_pattern_get_patch_count",
  "cairo_mesh_pattern_get_path",
  "cairo_mesh_pattern_line_to",
  "cairo_mesh_pattern_move_to",
  "cairo_mesh_pattern_set_control_point",
  "cairo_mesh_pattern_set_corner_color_rgb",
  "cairo_mesh_pattern_set_corner_color_rgba",
  "cairo_move_to",
  "cairo_new_path",
  "cairo_new_sub_path",
  "cairo_paint",
  "cairo_paint_with_alpha",
  "cairo_path_destroy",
  "cairo_path_extents",
  "cairo_pattern_add_color_stop_rgb",
  "cairo_pattern_add_color_stop_rgba",
  "cairo_pattern_create_for_surface",
  "cairo_pattern_create_linear",
  "cairo_pattern_create_mesh",
  "cairo_pattern_create_radial",
  "cairo_pattern_create_raster_source",
  "cairo_pattern_create_rgb",
  "cairo_pattern_create_rgba",
  "cairo_pattern_destroy",
  "cairo_pattern_get_color_stop_count",
  "cairo_pattern_get_color_stop_rgba",
  "cairo_pattern_get_dither",
  "cairo_pattern_get_extend",
  "cairo_pattern_get_filter",
  "cairo_pattern_get_linear_points",
  "cairo_pattern_get_matrix",
  "cairo_pattern_get_radial_circles",
  "cairo_pattern_get_reference_count",
  "cairo_pattern_get_rgba",
  "cairo_pattern_get_surface",
  "cairo_pattern_get_type",
  "cairo_pattern_get_user_data",
  "cairo_pattern_reference",
  "cairo_pattern_set_dither",
  "cairo_pattern_set_extend",
  "cairo_pattern_set_filter",
  "cairo_pattern_set_matrix",
  "cairo_pattern_set_user_data",
  "cairo_pattern_status",
  "cairo_pdf_get_versions",
  "cairo_pdf_surface_add_outline",
  "cairo_pdf_surface_create",
  "cairo_pdf_surface_create_for_stream",
  "cairo_pdf_surface_restrict_to_version",
  "cairo_pdf_surface_set_custom_metadata",
  "cairo_pdf_surface_set_metadata",
  "cairo_pdf_surface_set_page_label",
  "cairo_pdf_surface_set_size",
  "cairo_pdf_surface_set_thumbnail_size",
  "cairo_pdf_version_to_string",
  "cairo_pop_group",
  "cairo_pop_group_to_source",
  "cairo_ps_get_levels",
  "cairo_ps_level_to_string",
  "cairo_ps_surface_create",
  "cairo_ps_surface_create_for_stream",
  "cairo_ps_surface_dsc_begin_page_setup",
  "cairo_ps_surface_dsc_begin_setup",
  "cairo_ps_surface_dsc_comment",
  "cairo_ps_surface_get_eps",
  "cairo_ps_surface_restrict_to_level",
  "cairo_ps_surface_set_eps",
  "cairo_ps_surface_set_size",
  "cairo_push_group",
  "cairo_push_group_with_content",
  "cairo_raster_source_pattern_get_acquire",
  "cairo_raster_source_pattern_get_callback_data",
  "cairo_raster_source_pattern_get_copy",
  "cairo_raster_source_pattern_get_finish",
  "cairo_raster_source_pattern_get_snapshot",
  "cairo_raster_source_pattern_set_acquire",
  "cairo_raster_source_pattern_set_callback_data",
  "cairo_raster_source_pattern_set_copy",
  "cairo_raster_source_pattern_set_finish",
  "cairo_raster_source_pattern_set_snapshot",
  "cairo_recording_surface_create",
  "cairo_recording_surface_get_extents",
  "cairo_recording_surface_ink_extents",
  "cairo_rectangle",
  "cairo_rectangle_list_destroy",
  "cairo_reference",
  "cairo_region_contains_point",
  "cairo_region_contains_rectangle",
  "cairo_region_copy",
  "cairo_region_create",
  "cairo_region_create_rectangle",
  "cairo_region_create_rectangles",
  "cairo_region_destroy",
  "cairo_region_equal",
  "cairo_region_get_extents",
  "cairo_region_get_rectangle",
  "cairo_region_intersect",
  "cairo_region_intersect_rectangle",
  "cairo_region_is_empty",
  "cairo_region_num_rectangles",
  "cairo_region_reference",
  "cairo_region_status",
  "cairo_region_subtract",
  "cairo_region_subtract_rectangle",
  "cairo_region_translate",
  "cairo_region_union",
  "cairo_region_union_rectangle",
  "cairo_region_xor",
  "cairo_region_xor_rectangle",
  "cairo_rel_curve_to",
  "cairo_rel_line_to",
  "cairo_rel_move_to",
  "cairo_reset_clip",
  "cairo_restore",
  "cairo_rotate",
  "cairo_save",
  "cairo_scale",
  "cairo_scaled_font_create",
  "cairo_scaled_font_destroy",
  "cairo_scaled_font_extents",
  "cairo_scaled_font_get_ctm",
  "cairo_scaled_font_get_font_face",
  "cairo_scaled_font_get_font_matrix",
  "cairo_scaled_font_get_font_options",
  "cairo_scaled_font_get_reference_count",
  "cairo_scaled_font_get_scale_matrix",
  "cairo_scaled_font_get_type",
  "cairo_scaled_font_get_user_data",
  "cairo_scaled_font_glyph_extents",
  "cairo_scaled_font_reference",
  "cairo_scaled_font_set_user_data",
  "cairo_scaled_font_status",
  "cairo_scaled_font_text_extents",
  "cairo_scaled_font_text_to_glyphs",
  "cairo_script_create",
  "cairo_script_create_for_stream",
  "cairo_script_from_recording_surface",
  "cairo_script_get_mode",
  "cairo_script_set_mode",
  "cairo_script_surface_create",
  "cairo_script_surface_create_for_target",
  "cairo_script_write_comment",
  "cairo_select_font_face",
  "cairo_set_antialias",
  "cairo_set_dash",
  "cairo_set_fill_rule",
  "cairo_set_font_face",
  "cairo_set_font_matrix",
  "cairo_set_font_options",
  "cairo_set_font_size",
  "cairo_set_hairline",
  "cairo_set_line_cap",
  "cairo_set_line_join",
  "cairo_set_line_width",
  "cairo_set_matrix",
  "cairo_set_miter_limit",
  "cairo_set_operator",
  "cairo_set_scaled_font",
  "cairo_set_source",
  "cairo_set_source_rgb",
  "cairo_set_source_rgba",
  "cairo_set_source_surface",
  "cairo_set_tolerance",
  "cairo_set_user_data",
  "cairo_show_glyphs",
  "cairo_show_page",
  "cairo_show_text",
  "cairo_show_text_glyphs",
  "cairo_status",
  "cairo_status_to_string",
  "cairo_stroke",
  "cairo_stroke_extents",
  "cairo_stroke_preserve",
  "cairo_surface_copy_page",
  "cairo_surface_create_for_rectangle",
  "cairo_surface_create_observer",
  "cairo_surface_create_similar",
  "cairo_surface_create_similar_image",
  "cairo_surface_destroy",
  "cairo_surface_finish",
  "cairo_surface_flush",
  "cairo_surface_get_content",
  "cairo_surface_get_device",
  "cairo_surface_get_device_offset",
  "cairo_surface_get_device_scale",
  "cairo_surface_get_fallback_resolution",
  "cairo_surface_get_font_options",
  "cairo_surface_get_mime_data",
  "cairo_surface_get_reference_count",
  "cairo_surface_get_type",
  "cairo_surface_get_user_data",
  "cairo_surface_has_show_text_glyphs",
  "cairo_surface_map_to_image",
  "cairo_surface_mark_dirty",
  "cairo_surface_mark_dirty_rectangle",
  "cairo_surface_observer_add_fill_callback",
  "cairo_surface_observer_add_finish_callback",
  "cairo_surface_observer_add_flush_callback",
  "cairo_surface_observer_add_glyphs_callback",
  "cairo_surface_observer_add_mask_callback",
  "cairo_surface_observer_add_paint_callback",
  "cairo_surface_observer_add_stroke_callback",
  "cairo_surface_observer_elapsed",
  "cairo_surface_observer_print",
  "cairo_surface_reference",
  "cairo_surface_set_device_offset",
  "cairo_surface_set_device_scale",
  "cairo_surface_set_fallback_resolution",
  "cairo_surface_set_mime_data",
  "cairo_surface_set_user_data",
  "cairo_surface_show_page",
  "cairo_surface_status",
  "cairo_surface_supports_mime_type",
  "cairo_surface_unmap_image",
  "cairo_surface_write_to_png",
  "cairo_surface_write_to_png_stream",
  "cairo_svg_get_versions",
  "cairo_svg_surface_create",
  "cairo_svg_surface_create_for_stream",
  "cairo_svg_surface_get_document_unit",
  "cairo_svg_surface_restrict_to_version",
  "cairo_svg_surface_set_document_unit",
  "cairo_svg_version_to_string",
  "cairo_tag_begin",
  "cairo_tag_end",
  "cairo_tee_surface_add",
  "cairo_tee_surface_create",
  "cairo_tee_surface_index",
  "cairo_tee_surface_remove",
  "cairo_text_cluster_allocate",
  "cairo_text_cluster_free",
  "cairo_text_extents",
  "cairo_text_path",
  "cairo_toy_font_face_create",
  "cairo_toy_font_face_get_family",
  "cairo_toy_font_face_get_slant",
  "cairo_toy_font_face_get_weight",
  "cairo_transform",
  "cairo_translate",
  "cairo_user_font_face_create",
  "cairo_user_font_face_get_init_func",
  "cairo_user_font_face_get_render_color_glyph_func",
  "cairo_user_font_face_get_render_glyph_func",
  "cairo_user_font_face_get_text_to_glyphs_func",
  "cairo_user_font_face_get_unicode_to_glyph_func",
  "cairo_user_font_face_set_init_func",
  "cairo_user_font_face_set_render_color_glyph_func",
  "cairo_user_font_face_set_render_glyph_func",
  "cairo_user_font_face_set_text_to_glyphs_func",
  "cairo_user_font_face_set_unicode_to_glyph_func",
  "cairo_user_scaled_font_get_foreground_marker",
  "cairo_user_scaled_font_get_foreground_source",
  "cairo_user_to_device",
  "cairo_user_to_device_distance",
  "cairo_version",
  "cairo_version_string",
  "cairo_xcb_device_debug_cap_xrender_version",
  "cairo_xcb_device_debug_cap_xshm_version",
  "cairo_xcb_device_debug_get_precision",
  "cairo_xcb_device_debug_set_precision",
  "cairo_xcb_device_get_connection",
  "cairo_xcb_surface_create",
  "cairo_xcb_surface_create_for_bitmap",
  "cairo_xcb_surface_create_with_xrender_format",
  "cairo_xcb_surface_set_drawable",
  "cairo_xcb_surface_set_size",
  "cairo_xlib_device_debug_cap_xrender_version",
  "cairo_xlib_device_debug_get_precision",
  "cairo_xlib_device_debug_set_precision",
  "cairo_xlib_surface_create",
  "cairo_xlib_surface_create_for_bitmap",
  "cairo_xlib_surface_create_with_xrender_format",
  "cairo_xlib_surface_get_depth",
  "cairo_xlib_surface_get_display",
  "cairo_xlib_surface_get_drawable",
  "cairo_xlib_surface_get_height",
  "cairo_xlib_surface_get_screen",
  "cairo_xlib_surface_get_visual",
  "cairo_xlib_surface_get_width",
  "cairo_xlib_surface_get_xrender_format",
  "cairo_xlib_surface_set_drawable",
  "cairo_xlib_surface_set_size",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libcairo_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libcairo_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libcairo_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libcairo_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libcairo_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libcairo_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libcairo_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libcairo_so_tramp_table, 0, SYM_COUNT * sizeof(_libcairo_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
