# Generates version.cpp, holding NVGT's version and information about the build. Run in script mode: cmake -DSOURCE_DIR=<repository> -DOUTPUT=<version.cpp> -P NvgtVersion.cmake
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

set(git_hash "release")
if(EXISTS "${SOURCE_DIR}/.git")
	execute_process(COMMAND git rev-parse HEAD WORKING_DIRECTORY "${SOURCE_DIR}" OUTPUT_VARIABLE hash RESULT_VARIABLE result OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
	if(result EQUAL 0)
		set(git_hash "${hash}")
	endif()
endif()
string(TIMESTAMP timestamp "%s" UTC)
string(TIMESTAMP hour "%H" UTC)
math(EXPR hour12 "(${hour} + 11) % 12 + 1")
if(hour LESS 12)
	set(meridian AM)
else()
	set(meridian PM)
endif()
if(hour12 LESS 10)
	set(hour12 "0${hour12}")
endif()
string(TIMESTAMP build_time "%A, %B %d, %Y at ${hour12}:%M:%S ${meridian} UTC" UTC)
file(READ "${SOURCE_DIR}/version" version)
string(STRIP "${version}" version)
string(REPLACE "-" "." parts "${version}")
string(REPLACE "." ";" parts "${parts}")
list(GET parts 0 major)
list(GET parts 1 minor)
list(GET parts 2 patch)
list(GET parts 3 type)
file(WRITE "${OUTPUT}.tmp" "// Auto-generated code containing version information and other constants retrieved from the system at build time.

#include \"version.h\"
const std::string NVGT_VERSION = \"${version}\";
const std::string NVGT_VERSION_COMMIT_HASH = \"${git_hash}\";
const std::string NVGT_VERSION_BUILD_TIME = \"${build_time}\";
unsigned int NVGT_VERSION_BUILD_TIMESTAMP = ${timestamp};
int NVGT_VERSION_MAJOR = ${major};
int NVGT_VERSION_MINOR = ${minor};
int NVGT_VERSION_PATCH = ${patch};
const std::string NVGT_VERSION_TYPE = \"${type}\";
")
file(RENAME "${OUTPUT}.tmp" "${OUTPUT}")
