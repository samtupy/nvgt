vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samtupy/UniversalSpeechMSVCStatic
    REF 6973b7d718ed88a3db52ca412f18080cf5490b89
    SHA512 34a6563ffa4dc75709ba871f926af4708940be7b78ab04181105cce39291f8ca88f9ea28513c781a495338a06a578edb9416dc555c757bf7427a519066eadfc3
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
