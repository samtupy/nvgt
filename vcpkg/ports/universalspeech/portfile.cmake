vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtupy/UniversalSpeechMSVCStatic
    REF 8aea220de691cc2b3c3df604b7973f9119c8b994
    SHA512 78916702e7bd98183340286ba82d3b4be6055abe0aa64f095b67bca0b2c2198aaefadbfb8904879492e1dc79cd7df011c30c14a2e8f1844f0f123966a623cb2b
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

file(GLOB DLLS "${SOURCE_PATH}/bin/*.dll")
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
