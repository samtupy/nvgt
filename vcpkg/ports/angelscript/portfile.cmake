vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO codecat/angelscript-mirror
    REF 80268ecf8ddab683980c68924e909fb21957b21c
    SHA512 edeb11fd88268d8141078be01ac4f4a9ca92769ced50916d858c266e54291aa4f1ee4a94c1b5d59c6c3f944016eea4c9d877f923c5c20263671c4f033b205133
    HEAD_REF master
    PATCHES
        mark-threads-private.patch
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/angelscript/projects/cmake"
    OPTIONS
        "-DCMAKE_CXX_STANDARD=11" "-DMSVC_COMPILE_FLAGS=/MT"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/sdk/add_on/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/angelscript" FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()
