if(VCPKG_TARGET_IS_UWP)
  vcpkg_check_linkage(ONLY_DYNAMIC_CRT) # also sets STEAMAUDIO_STATIC_RUNTIME=OFF
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ValveSoftware/steam-audio
  REF "d747565385a0a771f820f97f870ddc7cd0d21db2"
  SHA512 1fa0fe544cb58d1f80902517d7e4b4a7b8c0937261055e90099c6228555be6d1221637787fa2ec714c3a4efa3884436636d8934f5ed64ab93b124383f051b5ee
  HEAD_REF "v${VERSION}"
  PATCHES
    use-vcpkg-deps.patch
    fix-arm64-windows.patch
)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
    set(MACOS_ARCH "x86_64")
  elseif("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
    set(MACOS_ARCH "arm64")
  else()
    message(FATAL "Unsupported arch")
  endif()
  set(VCPKG_MACOS_ARCH "-DVCPKG_MACOS_ARCH=${MACOS_ARCH}")
endif()

# Set STEAMAUDIO_STATIC_RUNTIME, which is only used on Windows to set /M[TD]d?
if(VCPKG_TARGET_IS_WINDOWS)
  string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)
  set(WINDOWS_STATIC_RUNTIME "-DSTEAMAUDIO_STATIC_RUNTIME=${STATIC_CRT}")
endif()

# We need to find flatc for steam-audio
find_program(FlatBuffers_EXECUTABLE NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" "bin" NO_DEFAULT_PATHS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/core"
    OPTIONS
        -DFlatBuffers_EXECUTABLE=${FlatBuffers_EXECUTABLE}
        -DSTEAMAUDIO_BUILD_TESTS=OFF
        -DSTEAMAUDIO_BUILD_ITESTS=OFF
        -DSTEAMAUDIO_BUILD_SAMPLES=OFF
        -DSTEAMAUDIO_BUILD_BENCHMARKS=OFF
        -DSTEAMAUDIO_BUILD_DOCS=OFF
        -DSTEAMAUDIO_ENABLE_AVX=OFF # Windows only. Maybe expose as a feature?
        # Below features all require closed source third party dependencies
        ${WINDOWS_STATIC_RUNTIME}
        -DSTEAMAUDIO_ENABLE_IPP=OFF
        -DSTEAMAUDIO_ENABLE_FFTS=OFF
        -DSTEAMAUDIO_ENABLE_EMBREE=OFF
        -DSTEAMAUDIO_ENABLE_RADEONRAYS=OFF
        -DSTEAMAUDIO_ENABLE_TRUEAUDIONEXT=OFF
        ${VCPKG_MACOS_ARCH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()


file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/git" # readme/docs
  "${CURRENT_PACKAGES_DIR}/debug/git"
  "${CURRENT_PACKAGES_DIR}/root" # duplicate of THIRDPARTY.md
  )

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(COMMENT
[[steam-audio's license and third party notices are included below. In steam-audio's third party
notices, PFFT and MySOFA are provided by other ports upon which this one depends. IPP, FFTS,
Embree, RadeonRays, and TrueAudioNext are all disabled in this build. However, the CIPIC HRTF
Database and Google Spherical Harmonics library components may be used here.]]
  FILE_LIST "${SOURCE_PATH}/LICENSE.md" "${SOURCE_PATH}/core/THIRDPARTY.md")
