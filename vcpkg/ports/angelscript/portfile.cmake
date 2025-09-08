vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anjo76/angelscript
    REF 13fd18e7281d25b4c9327d7b7d128ffa4cffab8c
    SHA512 03164fdea56c066c2c744f8c91fab09e03e5a06d9c5baa3d3d50e451135af1f6931b106670f88133b86f9b742d6080fc13162ae0b1ea6e56e61ca96ee06af2d4
    HEAD_REF master
    PATCHES
        mark-threads-private.patch
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/angelscript/projects/cmake"
    OPTIONS
        "-DCMAKE_CXX_STANDARD=11"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/sdk/add_on/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/angelscript" FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()
