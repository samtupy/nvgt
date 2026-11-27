set(libraries PocoFoundation)
if(NVGT_TARGET STREQUAL "windows")
	list(APPEND libraries user32)
elseif(NVGT_TARGET STREQUAL "android")
	list(APPEND libraries log)
endif()
list(APPEND libraries bass bass_fx bassmix phonon mysofa pffft)
if(NVGT_TARGET STREQUAL "windows")
	list(APPEND libraries zs)
else()
	list(APPEND libraries z)
endif()
nvgt_add_plugin(legacy_sound
	SOURCES pack.cpp sound.cpp
	ADDONS scriptarray
	SHARED_LIBRARIES ${libraries}
	STATIC_LIBRARIES bass bass_fx bassmix
)
