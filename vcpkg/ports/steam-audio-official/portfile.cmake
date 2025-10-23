vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ValveSoftware/steam-audio/releases/download/v${VERSION}/steamaudio_${VERSION}.zip"
    FILENAME "steamaudio_${VERSION}.zip"
    SHA512 6d198ad139f84ca39c3731469c227bb159325b81f4ab65b4bed58dfaaa42cca785a6e9c99dc8dd3d3732ab8861cbf850929e127df85d1980055773019a9b53ea
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
