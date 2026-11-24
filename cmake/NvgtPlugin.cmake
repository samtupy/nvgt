# nvgt_add_plugin() builds a plugin both as a shared library that NVGT loads at runtime and as a static library that can be linked into NVGT.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib
#
# nvgt_add_plugin(<name>
#   [STATIC_NAME <name>] # The name the plugin registers itself under when linked statically, the NVGT_PLUGIN_STATIC define. Defaults to <name>.
#   [SOURCES <file>...] # Compiled into both the shared and the static plugin.
#   [OBJECTS <object library>...] # Object libraries whose objects go into both, for sources that need settings of their own.
#   [ADDONS <addon>...] # Angelscript addons from ASAddon/plugin, such as scriptarray, linked into the shared plugin.
#   [LIBRARIES <library>...] # Linked by the shared plugin, and by NVGT when the plugin is linked statically.
#   [SHARED_LIBRARIES <library>...] # Linked only by the shared plugin.
#   [STATIC_LIBRARIES <library>...] # Linked only by NVGT when the plugin is linked statically.
#   [DEFINITIONS <define>...]
#   [INCLUDE_DIRECTORIES <dir>...]
#   [COMPILE_OPTIONS <option>...]
#   [SHARED_LINK_OPTIONS <option>...] # Link options for the shared plugin.
#   [FRAMEWORKS <framework>...] # Apple frameworks the shared plugin links weakly on macOS and iOS, ignored elsewhere.
# )
#
# The shared plugin is the target <name> and is copied to release/lib, or release/lib_android. The static one is <name>_static and is only built when NVGT links it, which it does for plugins named in NVGT_STATIC_PLUGINS or user/static_plugins by their directory name, <name> or STATIC_NAME. Libraries are names from the dependencies folder, system libraries or targets, see nvgt_dep_libraries().
# Every plugin also links the nvgt_plugin_options interface target, which a user/CMakeLists.txt can add settings to.

add_library(nvgt_plugin_options INTERFACE)

function(nvgt_add_plugin name)
	cmake_parse_arguments(PARSE_ARGV 1 arg "" "STATIC_NAME" "SOURCES;OBJECTS;ADDONS;LIBRARIES;SHARED_LIBRARIES;STATIC_LIBRARIES;DEFINITIONS;INCLUDE_DIRECTORIES;COMPILE_OPTIONS;SHARED_LINK_OPTIONS;FRAMEWORKS")
	if(arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "nvgt_add_plugin(${name}) was given unknown arguments: ${arg_UNPARSED_ARGUMENTS}")
	endif()
	if(NOT arg_STATIC_NAME)
		set(arg_STATIC_NAME ${name})
	endif()
	set(objects)
	foreach(object IN LISTS arg_OBJECTS)
		list(APPEND objects $<TARGET_OBJECTS:${object}>)
	endforeach()
	if(NVGT_SHARED_PLUGINS)
		set(addons)
		foreach(addon IN LISTS arg_ADDONS)
			list(APPEND addons $<TARGET_OBJECTS:nvgt_addon_${addon}>)
		endforeach()
		add_library(${name} SHARED ${arg_SOURCES} ${objects} ${addons})
		_nvgt_plugin_settings(${name})
		nvgt_dep_libraries(libraries ${arg_LIBRARIES} ${arg_SHARED_LIBRARIES})
		target_link_libraries(${name} PRIVATE ${libraries})
		target_link_options(${name} PRIVATE ${arg_SHARED_LINK_OPTIONS})
		if(APPLE)
			foreach(framework IN LISTS arg_FRAMEWORKS)
				target_link_options(${name} PRIVATE "SHELL:-weak_framework ${framework}")
			endforeach()
		endif()
		set_target_properties(${name} PROPERTIES DEFINE_SYMBOL "" LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins" RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins")
		if(ANDROID)
			set_target_properties(${name} PROPERTIES PREFIX "")
		endif()
		nvgt_publish(${name} "${NVGT_PLUGIN_DIR}")
		set_property(GLOBAL APPEND PROPERTY NVGT_SHARED_PLUGIN_TARGETS ${name}_publish)
	endif()
	add_library(${name}_static STATIC EXCLUDE_FROM_ALL ${arg_SOURCES} ${objects})
	_nvgt_plugin_settings(${name}_static)
	target_compile_definitions(${name}_static PRIVATE NVGT_PLUGIN_STATIC=${arg_STATIC_NAME})
	set_target_properties(${name}_static PROPERTIES OUTPUT_NAME ${name} ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
	nvgt_dep_libraries(libraries ${arg_LIBRARIES} ${arg_STATIC_LIBRARIES})
	target_link_libraries(${name}_static INTERFACE ${libraries})
	get_filename_component(directory "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
	set_property(GLOBAL APPEND PROPERTY NVGT_PLUGINS "${directory}|${name}|${arg_STATIC_NAME}")
endfunction()

function(_nvgt_plugin_settings target)
	target_link_libraries(${target} PRIVATE nvgt_plugin_options)
	target_include_directories(${target} PRIVATE ${arg_INCLUDE_DIRECTORIES})
	target_compile_definitions(${target} PRIVATE ${arg_DEFINITIONS})
	target_compile_options(${target} PRIVATE ${arg_COMPILE_OPTIONS})
endfunction()

# Works out which plugins to link statically from NVGT_STATIC_PLUGINS and user/static_plugins, sets NVGT_STATIC_PLUGIN_TARGETS to the static libraries to link, and generates nvgt_plugins.cpp registering them, setting NVGT_STATIC_PLUGINS_SOURCE to its path. A name that matches no plugin is still registered, for a plugin whose library is linked some other way.
function(nvgt_resolve_static_plugins)
	set(requested ${NVGT_STATIC_PLUGINS})
	if(NVGT_USER AND EXISTS "${CMAKE_SOURCE_DIR}/user/static_plugins")
		file(STRINGS "${CMAKE_SOURCE_DIR}/user/static_plugins" lines)
		set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/user/static_plugins")
		foreach(line IN LISTS lines)
			string(STRIP "${line}" line)
			if(line AND NOT line MATCHES "^#")
				list(APPEND requested "${line}")
			endif()
		endforeach()
	endif()
	get_property(plugins GLOBAL PROPERTY NVGT_PLUGINS)
	set(names)
	set(targets)
	foreach(request IN LISTS requested)
		set(registration "${request}")
		foreach(plugin IN LISTS plugins)
			string(REPLACE "|" ";" fields "${plugin}")
			if(request IN_LIST fields)
				list(GET fields 1 target)
				list(GET fields 2 registration)
				list(APPEND targets ${target}_static)
				break()
			endif()
		endforeach()
		list(APPEND names "${registration}")
	endforeach()
	list(REMOVE_DUPLICATES names)
	list(REMOVE_DUPLICATES targets)
	set(NVGT_STATIC_PLUGIN_TARGETS "${targets}" PARENT_SCOPE)
	set(NVGT_STATIC_PLUGINS_SOURCE "" PARENT_SCOPE)
	if(NOT names)
		return()
	endif()
	set(content "#define NVGT_LOAD_STATIC_PLUGINS\n#include <nvgt_plugin.h>\n")
	foreach(name IN LISTS names)
		string(APPEND content "static_plugin(${name})\n")
	endforeach()
	set(path "${CMAKE_BINARY_DIR}/generated/nvgt_plugins.cpp")
	file(WRITE "${path}.tmp" "${content}")
	configure_file("${path}.tmp" "${path}" COPYONLY)
	set(NVGT_STATIC_PLUGINS_SOURCE "${path}" PARENT_SCOPE)
endfunction()
