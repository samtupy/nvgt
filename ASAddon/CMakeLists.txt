# Build angelscript addons
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

file(GLOB sources CONFIGURE_DEPENDS src/*.cpp)
add_library(ASAddon STATIC ${sources})
target_compile_definitions(ASAddon PRIVATE NO_OBFUSCATE _LIB AS_WRITE_OPS=1 AS_USE_STLNAMES)
target_link_libraries(ASAddon PRIVATE nvgt_core_options)

# The versions of some addons in the plugin directory call Angelscript through the plugin interface. Each is compiled once and linked into whichever plugins list it in ADDONS.
file(GLOB plugin_addons CONFIGURE_DEPENDS plugin/*.cpp)
foreach(source IN LISTS plugin_addons)
	get_filename_component(addon "${source}" NAME_WE)
	add_library(nvgt_addon_${addon} OBJECT EXCLUDE_FROM_ALL "${source}")
	set_target_properties(nvgt_addon_${addon} PROPERTIES POSITION_INDEPENDENT_CODE ON)
	target_link_libraries(nvgt_addon_${addon} PRIVATE nvgt_plugin_options)
endforeach()
