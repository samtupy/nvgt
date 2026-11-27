# Build miscellaneous dependencies
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

set(sources entities.cpp ma_reverb_node.c micropather.cpp miniaudio_libopus.c miniaudio_libvorbis.c miniaudio_wdl_resampler.cpp monocypher.c resample.cpp rng_get_bytes.c singleheader.cpp sonic.c uncompr.c tonar.c)
if(NVGT_TARGET STREQUAL "windows")
	list(APPEND sources InputBox.cpp sapibridge.c vs_version.cpp windows_process_watcher.cpp)
endif()
add_library(deps STATIC ${sources})
target_compile_definitions(deps PRIVATE NO_OBFUSCATE _LIB)
target_link_libraries(deps PRIVATE nvgt_core_options)
