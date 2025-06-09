/* nvgt_plugin.cpp - code for loading and serializing plugins
 * These are usually loaded with a "#pragma plugin pluginname" in nvgt code, and consist of either a dll file with an nvgt_plugin entry point or a static library.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <string>
#include <unordered_map>
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <Poco/Format.h>
#include <SDL3/SDL.h>
#include "datastreams.h"
#include "nvgt.h"
#include "nvgt_plugin.h"
#include "UI.h"
#include "xplatform.h"

// Helper functions that are shared with plugins.
void* nvgt_datastream_create(std::ios* stream, const std::string& encoding, int byteorder) { return new datastream(stream, encoding, byteorder); }
std::ios* nvgt_datastream_get_ios(void* stream) { return reinterpret_cast<datastream*>(stream)->get_iostr(); }
#if defined(NVGT_STUB) || defined(NVGT_MOBILE)
// We need a no-op wrapper for nvgt_bundle_shared_library which is only needed on script compilation and thus is not included in stubs or mobile platforms.
void nvgt_bundle_shared_library(const std::string& libname) {}
#endif
typedef struct {
	nvgt_plugin_entry* e;
	nvgt_plugin_version_func* v;
} static_plugin_vtable;
std::unordered_map<std::string, void*> loaded_plugins; // Contains handles to sdl objects.
std::unordered_map<std::string, static_plugin_vtable>* static_plugins = NULL; // Contains pointers to static plugin entry points. This doesn't contain entry points for plugins loaded from a dll, rather those that have been linked statically into the executable produced by a custom build of nvgt. This is a pointer because the map is initialized the first time register_static_plugin is called so that we are not trusting in global initialization order.

bool load_nvgt_plugin(const std::string& name, std::string* errmsg, void* user) {
	nvgt_plugin_entry* entry = NULL;
	nvgt_plugin_version_func* version = NULL;
	void* obj = NULL;
	if (loaded_plugins.contains(name)) return true; // plugin already loaded
	if (static_plugins && static_plugins->contains(name)) {
		entry = (*static_plugins)[name].e;
		version = (*static_plugins)[name].v;
	}
	else {
		std::string dllname = name;
		#ifdef _WIN32
		dllname += ".dll";
		#elif defined(__APPLE__)
		dllname += ".dylib";
		#else
		dllname += ".so";
		#endif
		obj = SDL_LoadObject(dllname.c_str());
		if (!obj) obj = SDL_LoadObject(Poco::format("lib%s", dllname).c_str());
		if (!obj) return false;
		entry = (nvgt_plugin_entry*)SDL_LoadFunction(obj, "nvgt_plugin");
		version = (nvgt_plugin_version_func*)SDL_LoadFunction(obj, "nvgt_plugin_version");
	}
	if (!version) {
		if (errmsg) *(errmsg) = Poco::format("Failed to determine API version used for plugin %s, the plugin is old or defective.", name);
		return false;
	}
	else if (version() != NVGT_PLUGIN_API_VERSION) {
		if (errmsg) (*errmsg) = Poco::format("Failed API version check for plugin %s, plugin was compiled with API version %d while NVGT is using version %d. A compatible version of the plugin must be used.", name, version(), NVGT_PLUGIN_API_VERSION);
		return false;
	}
	nvgt_plugin_shared* shared = (nvgt_plugin_shared*)malloc(sizeof(nvgt_plugin_shared));
	prepare_plugin_shared(shared, g_ScriptEngine, user);
	if (!entry || !entry(shared)) {
		free(shared);
		if (obj) SDL_UnloadObject(obj);
		return false;
	}
	if (obj) {
		loaded_plugins[name] = obj;
		nvgt_bundle_shared_library(name);
	}
	else loaded_plugins[name] = NULL;
	free(shared);
	return true;
}

bool register_static_plugin(const std::string& name, nvgt_plugin_entry* e, nvgt_plugin_version_func* v) {
	if (!static_plugins) static_plugins = new std::unordered_map<std::string, static_plugin_vtable>;
	static_plugins->insert(std::make_pair(name, static_plugin_vtable {e, v}));
	return true;
}
void list_loaded_nvgt_plugins(std::vector<std::string>& output) {
	for (auto kv : loaded_plugins) output.push_back(kv.first);
}

bool load_serialized_nvgt_plugins(Poco::BinaryReader& br) {
	unsigned short count;
	br >> count;
	if (!count) return true;
	for (int i = 0; i < count; i++) {
		std::string name;
		br >> name;
		std::string errmsg = Poco::format("Unable to load %s, exiting.", name);
		if (!load_nvgt_plugin(name, &errmsg)) {
			message(errmsg, "error");
			return false;
		}
	}
	return true;
}

void serialize_nvgt_plugins(Poco::BinaryWriter& bw) {
	unsigned short count = loaded_plugins.size();
	bw << count;
	for (const auto& i : loaded_plugins)
		bw << i.first;
}

void unload_nvgt_plugins() {
	for (const auto& i : loaded_plugins) {
		if (i.second) SDL_UnloadObject(i.second);
	}
	loaded_plugins.clear();
}
