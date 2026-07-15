vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtupy/UniversalSpeechMSVCStatic
    REF 9bf2ed99e706e5eaa51744fcb9e348862b1583fe
    SHA512 3f1528ad9593e354f5079a61dcdaba1d3c1c51827ff12a2dde960de7c0e409a1d55d0b2bf688b84ea04245642fd57bf9c52cb418cc0ff96773910dd8a80362cb
    HEAD_REF master
)

set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

# debug build
vcpkg_execute_build_process(
    COMMAND ${SCONS} debug=1
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-dbg
)
file(INSTALL "${SOURCE_PATH}/UniversalSpeechStatic.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# release build
vcpkg_execute_build_process(
    COMMAND ${SCONS}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-rel
)
file(INSTALL "${SOURCE_PATH}/UniversalSpeechStatic.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(GLOB DLLS "${SOURCE_PATH}/bin-x64/*.dll")
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if(EXISTS "${SOURCE_PATH}/include")
    file(INSTALL "${SOURCE_PATH}/include/" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
