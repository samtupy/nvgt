vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ValveSoftware/steam-audio/releases/download/v${VERSION}/steamaudio_${VERSION}.zip"
    FILENAME "steamaudio_${VERSION}.zip"
    SHA512 7f28262a5076f21c31a194796ceb438457995ff833dbc4f0d9f6ace64fc325d66f494234c920e70ac1b8095fef5d9ba508c903a23df41cae3595af3ac53cd8f0
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
