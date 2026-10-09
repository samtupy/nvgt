vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/SirLynix/enet6/archive/refs/tags/v6.1.2.zip"
    FILENAME "v6.1.2.zip"
    SHA512 a0012a940d822e6178c4170b2bfda937514c377263adf6ccea49dac6608bcc12674f8f550ad58e761dbd1368f0f845e3dfec139aba5e7af126209866b1c0d10a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES         fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
