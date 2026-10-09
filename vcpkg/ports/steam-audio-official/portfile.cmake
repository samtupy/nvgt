vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ValveSoftware/steam-audio/releases/download/v${VERSION}/steamaudio_${VERSION}.zip"
    FILENAME "steamaudio_${VERSION}.zip"
    SHA512 fa77d71de2080f3c5d75fbbc1345f1894abef9df7c2a1373331cb190ca214c8f48be7e7cda1f495aeab258395669cf8eddea8e1cab19ff43607cc2945a679b38
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
if(VCPKG_TARGET_IS_WINDOWS)
	file(INSTALL "${SOURCE_PATH}/lib/windows-x64/phonon.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${SOURCE_PATH}/lib/windows-x64/phonon.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${SOURCE_PATH}/lib/windows-x64/GPUUtilities.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${SOURCE_PATH}/lib/windows-x64/TrueAudioNext.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
elseif(VCPKG_TARGET_IS_OSX)
	file(INSTALL "${SOURCE_PATH}/lib/osx/libphonon.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
elseif(VCPKG_TARGET_IS_LINUX)
	file(INSTALL "${SOURCE_PATH}/lib/linux-x64/libphonon.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
elseif(VCPKG_TARGET_IS_ANDROID)
	file(INSTALL "${SOURCE_PATH}/lib/android-armv8/libphonon.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
elseif(VCPKG_TARGET_IS_IOS)
	file(INSTALL "${SOURCE_PATH}/lib/ios/libphonon.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()
