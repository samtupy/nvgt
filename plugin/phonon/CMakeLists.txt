# nvgt_phonon: Steam Audio's HRTF, phonon_binaural_node and sound_environment. Steam Audio is linked into the plugin rather than into NVGT.
set(libraries phonon pffft mysofa)
if(NVGT_TARGET STREQUAL "windows")
	list(APPEND libraries zs)
	# NVGT's headers pull in Jolt's inline math, whose assertions in debug builds call JPH::AssertFailed from Jolt's library. Other platforms resolve it from the NVGT executable when the plugin loads, but a Windows DLL must link it, which only adds Jolt's small issue reporting object.
	set(shared_libraries Jolt)
else()
	list(APPEND libraries z)
endif()
if(NVGT_TARGET STREQUAL "android")
	list(APPEND libraries log) # Steam Audio's logger writes to logcat.
endif()
nvgt_add_plugin(nvgt_phonon
	SOURCES nvgt_phonon.cpp nodes.cpp environment.cpp environment_script.cpp
	ADDONS scripthandle
	LIBRARIES ${libraries}
	SHARED_LIBRARIES ${shared_libraries}
)
