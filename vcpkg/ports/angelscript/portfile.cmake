vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anjo76/angelscript
    REF 17703bb13cbcd15120b5bc59321c4ed9300ddf7b
    SHA512 c5a36ef5339b27e01ee23ae652af5ad0e36aef829103b89f38942e554eb5f9b2422faaeb31cdc48046a0e6a504f801ab7a5bccc7a921f3cc3fa18c14dbf567ae
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
