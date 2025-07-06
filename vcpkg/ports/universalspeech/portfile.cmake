vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtupy/UniversalSpeechMSVCStatic
    REF de5cdf112a34f4974a587e5d83297b7f767b3f01
    SHA512 6e2164200bb784ddd30534b5c2bec2338938afe756427fc7f12d1d56c0b2e7c0be885ad27561eb131101e06dad82c728f4bbbc2d66031c96e5daa244c41c4adf
    HEAD_REF master
)

set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_execute_build_process(
    COMMAND ${SCONS}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build
)

file(GLOB DLLS "${SOURCE_PATH}/bin/*.dll")
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

if(EXISTS "${SOURCE_PATH}/include")
    file(INSTALL "${SOURCE_PATH}/include/" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

file(GLOB LIBS "${SOURCE_PATH}/*.lib" "${SOURCE_PATH}/*.a")
if(LIBS)
    file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
