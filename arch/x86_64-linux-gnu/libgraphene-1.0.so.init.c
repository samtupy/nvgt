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
      fprintf(stderr, "implib-gen: libgraphene-1.0.so.0: " fmt "\n", ##__VA_ARGS__); \
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
  lib_handle = nvgt_dlopen("libgraphene-1.0.so.0");
  CHECK(lib_handle, "failed to load library 'libgraphene-1.0.so.0' via callback 'nvgt_dlopen'");
#else
  lib_handle = dlopen("libgraphene-1.0.so.0", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libgraphene-1.0.so.0' via dlopen: %s", dlerror());
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
  "graphene_box_alloc",
  "graphene_box_contains_box",
  "graphene_box_contains_point",
  "graphene_box_empty",
  "graphene_box_equal",
  "graphene_box_expand",
  "graphene_box_expand_scalar",
  "graphene_box_expand_vec3",
  "graphene_box_free",
  "graphene_box_get_bounding_sphere",
  "graphene_box_get_center",
  "graphene_box_get_depth",
  "graphene_box_get_height",
  "graphene_box_get_max",
  "graphene_box_get_min",
  "graphene_box_get_size",
  "graphene_box_get_type",
  "graphene_box_get_vertices",
  "graphene_box_get_width",
  "graphene_box_infinite",
  "graphene_box_init",
  "graphene_box_init_from_box",
  "graphene_box_init_from_points",
  "graphene_box_init_from_vec3",
  "graphene_box_init_from_vectors",
  "graphene_box_intersection",
  "graphene_box_minus_one",
  "graphene_box_one",
  "graphene_box_one_minus_one",
  "graphene_box_union",
  "graphene_box_zero",
  "graphene_euler_alloc",
  "graphene_euler_equal",
  "graphene_euler_free",
  "graphene_euler_get_alpha",
  "graphene_euler_get_beta",
  "graphene_euler_get_gamma",
  "graphene_euler_get_order",
  "graphene_euler_get_type",
  "graphene_euler_get_x",
  "graphene_euler_get_y",
  "graphene_euler_get_z",
  "graphene_euler_init",
  "graphene_euler_init_from_euler",
  "graphene_euler_init_from_matrix",
  "graphene_euler_init_from_quaternion",
  "graphene_euler_init_from_radians",
  "graphene_euler_init_from_vec3",
  "graphene_euler_init_with_order",
  "graphene_euler_reorder",
  "graphene_euler_to_matrix",
  "graphene_euler_to_quaternion",
  "graphene_euler_to_vec3",
  "graphene_frustum_alloc",
  "graphene_frustum_contains_point",
  "graphene_frustum_equal",
  "graphene_frustum_free",
  "graphene_frustum_get_planes",
  "graphene_frustum_get_type",
  "graphene_frustum_init",
  "graphene_frustum_init_from_frustum",
  "graphene_frustum_init_from_matrix",
  "graphene_frustum_intersects_box",
  "graphene_frustum_intersects_sphere",
  "graphene_matrix_alloc",
  "graphene_matrix_decompose",
  "graphene_matrix_determinant",
  "graphene_matrix_equal",
  "graphene_matrix_equal_fast",
  "graphene_matrix_free",
  "graphene_matrix_get_row",
  "graphene_matrix_get_type",
  "graphene_matrix_get_value",
  "graphene_matrix_get_x_scale",
  "graphene_matrix_get_x_translation",
  "graphene_matrix_get_y_scale",
  "graphene_matrix_get_y_translation",
  "graphene_matrix_get_z_scale",
  "graphene_matrix_get_z_translation",
  "graphene_matrix_init_from_2d",
  "graphene_matrix_init_from_float",
  "graphene_matrix_init_from_matrix",
  "graphene_matrix_init_from_vec4",
  "graphene_matrix_init_frustum",
  "graphene_matrix_init_identity",
  "graphene_matrix_init_look_at",
  "graphene_matrix_init_ortho",
  "graphene_matrix_init_perspective",
  "graphene_matrix_init_rotate",
  "graphene_matrix_init_scale",
  "graphene_matrix_init_skew",
  "graphene_matrix_init_translate",
  "graphene_matrix_interpolate",
  "graphene_matrix_inverse",
  "graphene_matrix_is_2d",
  "graphene_matrix_is_backface_visible",
  "graphene_matrix_is_identity",
  "graphene_matrix_is_singular",
  "graphene_matrix_multiply",
  "graphene_matrix_near",
  "graphene_matrix_normalize",
  "graphene_matrix_perspective",
  "graphene_matrix_print",
  "graphene_matrix_project_point",
  "graphene_matrix_project_rect",
  "graphene_matrix_project_rect_bounds",
  "graphene_matrix_rotate",
  "graphene_matrix_rotate_euler",
  "graphene_matrix_rotate_quaternion",
  "graphene_matrix_rotate_x",
  "graphene_matrix_rotate_y",
  "graphene_matrix_rotate_z",
  "graphene_matrix_scale",
  "graphene_matrix_skew_xy",
  "graphene_matrix_skew_xz",
  "graphene_matrix_skew_yz",
  "graphene_matrix_to_2d",
  "graphene_matrix_to_float",
  "graphene_matrix_transform_bounds",
  "graphene_matrix_transform_box",
  "graphene_matrix_transform_point",
  "graphene_matrix_transform_point3d",
  "graphene_matrix_transform_ray",
  "graphene_matrix_transform_rect",
  "graphene_matrix_transform_sphere",
  "graphene_matrix_transform_vec3",
  "graphene_matrix_transform_vec4",
  "graphene_matrix_translate",
  "graphene_matrix_transpose",
  "graphene_matrix_unproject_point3d",
  "graphene_matrix_untransform_bounds",
  "graphene_matrix_untransform_point",
  "graphene_plane_alloc",
  "graphene_plane_distance",
  "graphene_plane_equal",
  "graphene_plane_free",
  "graphene_plane_get_constant",
  "graphene_plane_get_normal",
  "graphene_plane_get_type",
  "graphene_plane_init",
  "graphene_plane_init_from_plane",
  "graphene_plane_init_from_point",
  "graphene_plane_init_from_points",
  "graphene_plane_init_from_vec4",
  "graphene_plane_negate",
  "graphene_plane_normalize",
  "graphene_plane_transform",
  "graphene_point3d_alloc",
  "graphene_point3d_cross",
  "graphene_point3d_distance",
  "graphene_point3d_dot",
  "graphene_point3d_equal",
  "graphene_point3d_free",
  "graphene_point3d_get_type",
  "graphene_point3d_init",
  "graphene_point3d_init_from_point",
  "graphene_point3d_init_from_vec3",
  "graphene_point3d_interpolate",
  "graphene_point3d_length",
  "graphene_point3d_near",
  "graphene_point3d_normalize",
  "graphene_point3d_normalize_viewport",
  "graphene_point3d_scale",
  "graphene_point3d_to_vec3",
  "graphene_point3d_zero",
  "graphene_point_alloc",
  "graphene_point_distance",
  "graphene_point_equal",
  "graphene_point_free",
  "graphene_point_get_type",
  "graphene_point_init",
  "graphene_point_init_from_point",
  "graphene_point_init_from_vec2",
  "graphene_point_interpolate",
  "graphene_point_near",
  "graphene_point_to_vec2",
  "graphene_point_zero",
  "graphene_quad_alloc",
  "graphene_quad_bounds",
  "graphene_quad_contains",
  "graphene_quad_free",
  "graphene_quad_get_point",
  "graphene_quad_get_type",
  "graphene_quad_init",
  "graphene_quad_init_from_points",
  "graphene_quad_init_from_rect",
  "graphene_quaternion_add",
  "graphene_quaternion_alloc",
  "graphene_quaternion_dot",
  "graphene_quaternion_equal",
  "graphene_quaternion_free",
  "graphene_quaternion_get_type",
  "graphene_quaternion_init",
  "graphene_quaternion_init_from_angle_vec3",
  "graphene_quaternion_init_from_angles",
  "graphene_quaternion_init_from_euler",
  "graphene_quaternion_init_from_matrix",
  "graphene_quaternion_init_from_quaternion",
  "graphene_quaternion_init_from_radians",
  "graphene_quaternion_init_from_vec4",
  "graphene_quaternion_init_identity",
  "graphene_quaternion_invert",
  "graphene_quaternion_multiply",
  "graphene_quaternion_normalize",
  "graphene_quaternion_scale",
  "graphene_quaternion_slerp",
  "graphene_quaternion_to_angle_vec3",
  "graphene_quaternion_to_angles",
  "graphene_quaternion_to_matrix",
  "graphene_quaternion_to_radians",
  "graphene_quaternion_to_vec4",
  "graphene_ray_alloc",
  "graphene_ray_equal",
  "graphene_ray_free",
  "graphene_ray_get_closest_point_to_point",
  "graphene_ray_get_direction",
  "graphene_ray_get_distance_to_plane",
  "graphene_ray_get_distance_to_point",
  "graphene_ray_get_origin",
  "graphene_ray_get_position_at",
  "graphene_ray_get_type",
  "graphene_ray_init",
  "graphene_ray_init_from_ray",
  "graphene_ray_init_from_vec3",
  "graphene_ray_intersect_box",
  "graphene_ray_intersect_sphere",
  "graphene_ray_intersect_triangle",
  "graphene_ray_intersects_box",
  "graphene_ray_intersects_sphere",
  "graphene_ray_intersects_triangle",
  "graphene_rect_alloc",
  "graphene_rect_contains_point",
  "graphene_rect_contains_rect",
  "graphene_rect_equal",
  "graphene_rect_expand",
  "graphene_rect_free",
  "graphene_rect_get_area",
  "graphene_rect_get_bottom_left",
  "graphene_rect_get_bottom_right",
  "graphene_rect_get_center",
  "graphene_rect_get_height",
  "graphene_rect_get_top_left",
  "graphene_rect_get_top_right",
  "graphene_rect_get_type",
  "graphene_rect_get_vertices",
  "graphene_rect_get_width",
  "graphene_rect_get_x",
  "graphene_rect_get_y",
  "graphene_rect_init",
  "graphene_rect_init_from_rect",
  "graphene_rect_inset",
  "graphene_rect_inset_r",
  "graphene_rect_interpolate",
  "graphene_rect_intersection",
  "graphene_rect_normalize",
  "graphene_rect_normalize_r",
  "graphene_rect_offset",
  "graphene_rect_offset_r",
  "graphene_rect_round",
  "graphene_rect_round_extents",
  "graphene_rect_round_to_pixel",
  "graphene_rect_scale",
  "graphene_rect_union",
  "graphene_rect_zero",
  "graphene_simd4f_add",
  "graphene_simd4f_cmp_eq",
  "graphene_simd4f_cmp_ge",
  "graphene_simd4f_cmp_gt",
  "graphene_simd4f_cmp_le",
  "graphene_simd4f_cmp_lt",
  "graphene_simd4f_cmp_neq",
  "graphene_simd4f_cross3",
  "graphene_simd4f_div",
  "graphene_simd4f_dot3",
  "graphene_simd4f_dot3_scalar",
  "graphene_simd4f_dup_2f",
  "graphene_simd4f_dup_3f",
  "graphene_simd4f_dup_4f",
  "graphene_simd4f_flip_sign_0101",
  "graphene_simd4f_flip_sign_1010",
  "graphene_simd4f_get",
  "graphene_simd4f_get_w",
  "graphene_simd4f_get_x",
  "graphene_simd4f_get_y",
  "graphene_simd4f_get_z",
  "graphene_simd4f_init",
  "graphene_simd4f_init_2f",
  "graphene_simd4f_init_3f",
  "graphene_simd4f_init_4f",
  "graphene_simd4f_init_zero",
  "graphene_simd4f_max",
  "graphene_simd4f_merge_high",
  "graphene_simd4f_merge_low",
  "graphene_simd4f_merge_w",
  "graphene_simd4f_min",
  "graphene_simd4f_mul",
  "graphene_simd4f_neg",
  "graphene_simd4f_reciprocal",
  "graphene_simd4f_rsqrt",
  "graphene_simd4f_shuffle_wxyz",
  "graphene_simd4f_shuffle_yzwx",
  "graphene_simd4f_shuffle_zwxy",
  "graphene_simd4f_splat",
  "graphene_simd4f_splat_w",
  "graphene_simd4f_splat_x",
  "graphene_simd4f_splat_y",
  "graphene_simd4f_splat_z",
  "graphene_simd4f_sqrt",
  "graphene_simd4f_sub",
  "graphene_simd4f_zero_w",
  "graphene_simd4f_zero_zw",
  "graphene_simd4x4f_transpose_in_place",
  "graphene_size_alloc",
  "graphene_size_equal",
  "graphene_size_free",
  "graphene_size_get_type",
  "graphene_size_init",
  "graphene_size_init_from_size",
  "graphene_size_interpolate",
  "graphene_size_scale",
  "graphene_size_zero",
  "graphene_sphere_alloc",
  "graphene_sphere_contains_point",
  "graphene_sphere_distance",
  "graphene_sphere_equal",
  "graphene_sphere_free",
  "graphene_sphere_get_bounding_box",
  "graphene_sphere_get_center",
  "graphene_sphere_get_radius",
  "graphene_sphere_get_type",
  "graphene_sphere_init",
  "graphene_sphere_init_from_points",
  "graphene_sphere_init_from_vectors",
  "graphene_sphere_is_empty",
  "graphene_sphere_translate",
  "graphene_triangle_alloc",
  "graphene_triangle_contains_point",
  "graphene_triangle_equal",
  "graphene_triangle_free",
  "graphene_triangle_get_area",
  "graphene_triangle_get_barycoords",
  "graphene_triangle_get_bounding_box",
  "graphene_triangle_get_midpoint",
  "graphene_triangle_get_normal",
  "graphene_triangle_get_plane",
  "graphene_triangle_get_points",
  "graphene_triangle_get_type",
  "graphene_triangle_get_uv",
  "graphene_triangle_get_vertices",
  "graphene_triangle_init_from_float",
  "graphene_triangle_init_from_point3d",
  "graphene_triangle_init_from_vec3",
  "graphene_vec2_add",
  "graphene_vec2_alloc",
  "graphene_vec2_divide",
  "graphene_vec2_dot",
  "graphene_vec2_equal",
  "graphene_vec2_free",
  "graphene_vec2_get_type",
  "graphene_vec2_get_x",
  "graphene_vec2_get_y",
  "graphene_vec2_init",
  "graphene_vec2_init_from_float",
  "graphene_vec2_init_from_vec2",
  "graphene_vec2_interpolate",
  "graphene_vec2_length",
  "graphene_vec2_max",
  "graphene_vec2_min",
  "graphene_vec2_multiply",
  "graphene_vec2_near",
  "graphene_vec2_negate",
  "graphene_vec2_normalize",
  "graphene_vec2_one",
  "graphene_vec2_scale",
  "graphene_vec2_subtract",
  "graphene_vec2_to_float",
  "graphene_vec2_x_axis",
  "graphene_vec2_y_axis",
  "graphene_vec2_zero",
  "graphene_vec3_add",
  "graphene_vec3_alloc",
  "graphene_vec3_cross",
  "graphene_vec3_divide",
  "graphene_vec3_dot",
  "graphene_vec3_equal",
  "graphene_vec3_free",
  "graphene_vec3_get_type",
  "graphene_vec3_get_x",
  "graphene_vec3_get_xy",
  "graphene_vec3_get_xy0",
  "graphene_vec3_get_xyz0",
  "graphene_vec3_get_xyz1",
  "graphene_vec3_get_xyzw",
  "graphene_vec3_get_y",
  "graphene_vec3_get_z",
  "graphene_vec3_init",
  "graphene_vec3_init_from_float",
  "graphene_vec3_init_from_vec3",
  "graphene_vec3_interpolate",
  "graphene_vec3_length",
  "graphene_vec3_max",
  "graphene_vec3_min",
  "graphene_vec3_multiply",
  "graphene_vec3_near",
  "graphene_vec3_negate",
  "graphene_vec3_normalize",
  "graphene_vec3_one",
  "graphene_vec3_scale",
  "graphene_vec3_subtract",
  "graphene_vec3_to_float",
  "graphene_vec3_x_axis",
  "graphene_vec3_y_axis",
  "graphene_vec3_z_axis",
  "graphene_vec3_zero",
  "graphene_vec4_add",
  "graphene_vec4_alloc",
  "graphene_vec4_divide",
  "graphene_vec4_dot",
  "graphene_vec4_equal",
  "graphene_vec4_free",
  "graphene_vec4_get_type",
  "graphene_vec4_get_w",
  "graphene_vec4_get_x",
  "graphene_vec4_get_xy",
  "graphene_vec4_get_xyz",
  "graphene_vec4_get_y",
  "graphene_vec4_get_z",
  "graphene_vec4_init",
  "graphene_vec4_init_from_float",
  "graphene_vec4_init_from_vec2",
  "graphene_vec4_init_from_vec3",
  "graphene_vec4_init_from_vec4",
  "graphene_vec4_interpolate",
  "graphene_vec4_length",
  "graphene_vec4_max",
  "graphene_vec4_min",
  "graphene_vec4_multiply",
  "graphene_vec4_near",
  "graphene_vec4_negate",
  "graphene_vec4_normalize",
  "graphene_vec4_one",
  "graphene_vec4_scale",
  "graphene_vec4_subtract",
  "graphene_vec4_to_float",
  "graphene_vec4_w_axis",
  "graphene_vec4_x_axis",
  "graphene_vec4_y_axis",
  "graphene_vec4_z_axis",
  "graphene_vec4_zero",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libgraphene_1_0_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void *_libgraphene_1_0_so_tramp_resolve(size_t i) {
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
    (void)__sync_val_compare_and_swap(&_libgraphene_1_0_so_tramp_table[i], 0, addr);
  }

  return addr;
}

// Below APIs are not thread-safe
// and it's not clear how make them such
// (we can not know if some other thread is
// currently executing library code).

// Helper for user to resolve all symbols
void _libgraphene_1_0_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libgraphene_1_0_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libgraphene_1_0_so_tramp_set_handle(void *handle) {
  // TODO: call unload_lib ?
  lib_handle = handle;
  dlopened = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libgraphene_1_0_so_tramp_reset(void) {
  // TODO: call unload_lib ?
  memset(_libgraphene_1_0_so_tramp_table, 0, SYM_COUNT * sizeof(_libgraphene_1_0_so_tramp_table[0]));
  lib_handle = 0;
  dlopened = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
