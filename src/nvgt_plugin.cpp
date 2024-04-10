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
#include <Poco/Format.h>
#include <SDL.h>
#include "misc_functions.h"
#include "nvgt.h"
#include "nvgt_plugin.h"

std::unordered_map<std::string, void*> loaded_plugins; // Contains handles to sdl objects.
std::unordered_map<std::string, nvgt_plugin_entry*>* static_plugins = NULL; // Contains pointers to static plugin entry points. This doesn't contain entry points for plugins loaded from a dll, rather those that have been linked statically into the executable produced by a custom build of nvgt. This is a pointer because the map is initialized the first time register_static_plugin is called so that we are not trusting in global initialization order.

bool load_nvgt_plugin(const std::string& name, void* user) {
	nvgt_plugin_entry* entry = NULL;
	void* obj = NULL;
	if (static_plugins && static_plugins->find(name) != static_plugins->end())
		entry = (nvgt_plugin_entry*)(*static_plugins)[name];
	else {
		obj = SDL_LoadObject(name.c_str());
		if (!obj) return false;
		entry = (nvgt_plugin_entry*)SDL_LoadFunction(obj, "nvgt_plugin");
	}
	nvgt_plugin_shared* shared = (nvgt_plugin_shared*)malloc(sizeof(nvgt_plugin_shared));
	prepare_plugin_shared(shared, g_ScriptEngine, user);
	if (!entry || !entry(shared)) {
		free(shared);
		if (obj) SDL_UnloadObject(obj);
		return false;
	}
	if (obj) loaded_plugins[name] = obj;
	else loaded_plugins[name] = NULL;
	free(shared);
	return true;
}

bool register_static_plugin(const std::string& name, nvgt_plugin_entry* e) {
	if (!static_plugins) static_plugins = new std::unordered_map<std::string, nvgt_plugin_entry*>;
	static_plugins->insert(std::make_pair(name, e));
	return true;
}

bool load_serialized_nvgt_plugins(FILE* f) {
	unsigned short count;
	fread(&count, 1, 2, f);
	if (!count) return true;
	for (int i = 0; i < count; i++) {
		unsigned char len;
		fread(&len, 1, 1, f);
		std::string name(len, '\0');
		fread(&name[0], 1, len, f);
		if (!load_nvgt_plugin(name)) {
			alert("Error", Poco::format("Unable to load %s, exiting.", name));
			return false;
		}
	}
	return true;
}

void serialize_nvgt_plugins(FILE* f) {
	unsigned short count = loaded_plugins.size();
	fwrite(&count, 1, 2, f);
	for (const auto& i : loaded_plugins) {
		const std::string& name = i.first;
		unsigned char len = name.size();
		fwrite(&len, 1, 1, f);
		fwrite(name.c_str(), 1, len, f);
	}
}

void unload_nvgt_plugins() {
	for (const auto& i : loaded_plugins) {
		if (i.second) SDL_UnloadObject(i.second);
	}
	loaded_plugins.clear();
}
