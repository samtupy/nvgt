vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anjo76/angelscript
    REF 64b154faed7a8dd7e34da94621c9708f01e65b16
    SHA512 76924bc6a8040534769ec5f8da651764f45bee109907ce0184ae616ab0575ecfc2c998f7bd8ce2a78a67109cd958fc21dbca916e408509f81c98662f9b81189d
    HEAD_REF master
    PATCHES
        add-no-compiler.patch
        mark-threads-private.patch
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/angelscript/projects/cmake"
    OPTIONS
        "-DAS_NO_COMPILER=ON" "-DCMAKE_CXX_STANDARD=11"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Angelscript)

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/sdk/add_on/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/angelscript" FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/angelscript.h")
