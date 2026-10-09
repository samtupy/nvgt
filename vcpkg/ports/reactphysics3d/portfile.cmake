vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DanielChappuis/reactphysics3d/archive/refs/tags/v0.10.2.zip"
    FILENAME "v0.10.2.zip"
    SHA512 647ce2bb3915244c779673047b9198bc6633b48499585bb493b1fe11b4686174b7274845914330760ea632e8e6cc99eed65eab11654bf3d488b6f76c5b420a28
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-system_clock.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRP3D_COMPILE_TESTBED=OFF
        -DRP3D_COMPILE_TESTS=OFF
        -DRP3D_GENERATE_DOCUMENTATION=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
