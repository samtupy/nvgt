#include <string>
#include "../../src/nvgt_plugin.h"
#if __has_include(<systemd/sd-daemon.h>)
#include <systemd/sd-daemon.h>
#define systemd_available
#endif

int systemd_notify(const std::string& state) {
	#ifdef systemd_available
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
