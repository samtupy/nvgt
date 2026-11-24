option(NVGT_TEST_PLUGIN "Build the test plugin" OFF)
if(NOT NVGT_TEST_PLUGIN)
	return()
endif()
nvgt_add_plugin(test_plugin
	SOURCES test_plugin.cpp
	SHARED_LIBRARIES user32
)
