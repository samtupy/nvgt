set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
if(PORT MATCHES "libgit" OR PORT MATCHES "libplist" OR PORT MATCHES "libarchive")
	set(VCPKG_LIBRARY_LINKAGE dynamic)
	set(VCPKG_FIXUP_ELF_RPATH ON)
else()
	set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
# Each function and variable gets its own section so that NVGT's --gc-sections link can drop the parts of the dependencies it doesn't use.
set(VCPKG_C_FLAGS "-ffunction-sections -fdata-sections")
set(VCPKG_CXX_FLAGS "-ffunction-sections -fdata-sections")
if(NOT PORT MATCHES "^(openssl|flatbuffers)$")
	set(VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE -DCMAKE_BUILD_TYPE=MinSizeRel)
endif()

# Prism needs C++23 headers that the default GCC on the Ubuntu 22.04 build machines lacks, and its LTO output must stay readable by the older GCC that links NVGT.
if(PORT STREQUAL "ethindp-prism")
	set(VCPKG_CMAKE_CONFIGURE_OPTIONS -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 -DPRISM_IPO=OFF)
endif()
