set(libraries)
if(NVGT_TARGET STREQUAL "linux")
	find_library(SYSTEMD_LIBRARY systemd)
	if(SYSTEMD_LIBRARY)
		set(libraries systemd)
	endif()
endif()
nvgt_add_plugin(systemd_notify
	SOURCES sd_notify.cpp
	LIBRARIES ${libraries}
)
