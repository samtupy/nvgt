vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtupy/angelscript
    REF 9d2c181444395b38a4c2691690546df05686bcef
    SHA512 248a5e8d45d393f859a9e95bb8fe684417119ea3aca3583248cce17d36467914c104737df17672426c398b84706c23dd57d68e15da78dbaa25375aea35b2e630
    HEAD_REF master
    PATCHES
        add-no-compiler.patch
        mark-threads-private.patch
        fix-dependency.patch
        fix-double-literal-precision.patch
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
