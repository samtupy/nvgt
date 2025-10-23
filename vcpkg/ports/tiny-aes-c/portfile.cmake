vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokke/tiny-AES-c
    REF 23856752fbd139da0b8ca6e471a13d5bcc99a08d
    SHA512 3ab9f41a43be3d3af171917177fa39d3691b345fbfc4ff10d0dee367ae99fbe054656fc67ef875afd3737ded2e098d8f9172027d5f24da9aff6ae789ae2c55e7
    HEAD_REF master
    PATCHES aes256.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/unlicense.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
