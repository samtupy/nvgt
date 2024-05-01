#include <string>
#include "../../src/nvgt_plugin.h"
#ifdef __linux__
#include <systemd/sd-daemon.h>
#endif

int systemd_notify(const std::string& state) {
	#ifdef __linux__
		return sd_notify(0, state.c_str());
	#else
		return 0;
	#endif
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
	shared->script_engine->RegisterGlobalFunction("int systemd_notify(const string&in state)", asFUNCTION(systemd_notify), asCALL_CDECL);
	return true;
}
