# Loaded through CMAKE_USER_MAKE_RULES_OVERRIDE so that CMake's and toolchain files' default compiler and linker flags start out empty. NVGT sets every flag it builds with itself in NvgtPlatform.cmake.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

foreach(lang C CXX)
	set(CMAKE_${lang}_FLAGS_INIT "")
	foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
		set(CMAKE_${lang}_FLAGS_${config}_INIT "")
	endforeach()
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		set(CMAKE_${lang}_STANDARD_LIBRARIES_INIT "")
	endif()
endforeach()
foreach(kind EXE SHARED MODULE STATIC)
	set(CMAKE_${kind}_LINKER_FLAGS_INIT "")
	foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
		set(CMAKE_${kind}_LINKER_FLAGS_${config}_INIT "")
	endforeach()
endforeach()
