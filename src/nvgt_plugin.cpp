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
std::unordered_map < std::string, void* > loaded_plugins; // Contains handles to sdl objects.
std::unordered_map < std::string, static_plugin_vtable > * static_plugins = NULL; // Contains pointers to static plugin entry points. This doesn't contain entry points for plugins loaded from a dll, rather those that have been linked statically into the executable produced by a custom build of nvgt. This is a pointer because the map is initialized the first time register_static_plugin is called so that we are not trusting in global initialization order.

// Thread-local storage for tracking current plugin context
// This is good enough for now but might cause problems if multiple threads load plugins
static thread_local std::string* current_plugin_name = nullptr;

class plugin_context_guard {
	std::string* old_name;
public:
	plugin_context_guard(const std::string& name) {
		old_name = current_plugin_name;
		current_plugin_name = new std::string(name);
	}
	~plugin_context_guard() {
		delete current_plugin_name;
		current_plugin_name = old_name;
	}
};

void cleanup_all_plugin_resources();
void cleanup_all_services();
void cleanup_plugin_resources(const std::string& plugin_name);
void cleanup_plugin_services(const std::string& plugin_name);

bool load_nvgt_plugin(const std::string& name, std::string* errmsg, void* user) {
	nvgt_plugin_entry* entry = NULL;
	nvgt_plugin_version_func* version = NULL;
	void* obj = NULL;
	if (loaded_plugins.contains(name)) return true; // plugin already loaded
	if (static_plugins && static_plugins->contains(name)) {
		entry = (*static_plugins)[name].e;
		version = (*static_plugins)[name].v;
	} else {
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
	} else if (version() != NVGT_PLUGIN_API_VERSION) {
		if (errmsg) (*errmsg) = Poco::format("Failed API version check for plugin %s, plugin was compiled with API version %d while NVGT is using version %d. A compatible version of the plugin must be used.", name, version(), NVGT_PLUGIN_API_VERSION);
		return false;
	}
	nvgt_plugin_shared* shared = (nvgt_plugin_shared*)malloc(sizeof(nvgt_plugin_shared));
	prepare_plugin_shared(shared, g_ScriptEngine, user);
	plugin_context_guard context(name);
	if (!entry || !entry(shared)) {
		free(shared);
		if (obj) SDL_UnloadObject(obj);
		return false;
	}
	if (obj) {
		loaded_plugins[name] = obj;
		nvgt_bundle_shared_library(name);
	} else loaded_plugins[name] = NULL;
	free(shared);
	return true;
}

bool register_static_plugin(const std::string& name, nvgt_plugin_entry* e, nvgt_plugin_version_func* v) {
	if (!static_plugins) static_plugins = new std::unordered_map < std::string, static_plugin_vtable >;
	static_plugins->insert(std::make_pair(name, static_plugin_vtable {e, v}));
	return true;
}
void list_loaded_nvgt_plugins(std::vector < std::string > & output) {
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
	cleanup_all_plugin_resources();
	cleanup_all_services();
	for (const auto& i : loaded_plugins) {
		if (i.second) SDL_UnloadObject(i.second);
	}
	loaded_plugins.clear();
}

#include <unordered_set>
#include <fstream>
#include <memory>
#include <cstring>
#include <functional>
#include <Poco/Mutex.h>

struct resource_info {
	nvgt_resource_handle handle;
	std::unique_ptr < void, std::function < void(void*)>> cleanup;
};

static std::unordered_map < nvgt_resource_handle*, std::unique_ptr < resource_info>> active_resources;
static std::unordered_map < std::string, std::unordered_set < nvgt_resource_handle*>> plugin_resources;
static Poco::FastMutex resource_mutex;

void cleanup_plugin_resources(const std::string& plugin_name) {
	std::vector < nvgt_resource_handle* > handles_to_release;
	{
		Poco::FastMutex::ScopedLock lock(resource_mutex);
		auto it = plugin_resources.find(plugin_name);
		if (it == plugin_resources.end()) return;
		handles_to_release = std::vector < nvgt_resource_handle* > (it->second.begin(), it->second.end());
		plugin_resources.erase(it);
	}
	for (auto handle : handles_to_release)
		nvgt_release_resource(handle);
}

void cleanup_all_plugin_resources() {
	Poco::FastMutex::ScopedLock lock(resource_mutex);
	active_resources.clear();
	plugin_resources.clear();
}

// Silly demonstration of resource functionality
nvgt_resource_handle* nvgt_request_resource(const nvgt_resource_request* request) {
	if (!request) return nullptr;
	Poco::FastMutex::ScopedLock lock(resource_mutex);
	std::string plugin_name = current_plugin_name ? *current_plugin_name : "core";
	auto info = std::make_unique < resource_info > ();
	info->handle.type = request->type;
	info->handle.resource = nullptr;
	info->handle.internal_data = nullptr;
	info->handle.on_release_callback = nullptr;
	info->handle.callback_user_data = nullptr;
	info->handle.plugin_name = plugin_name;
	switch (request->type) {
		case NVGT_RESOURCE_FILESYSTEM: {
			if (request->identifier.empty()) return nullptr;
			auto* file = new std::ifstream(request->identifier, std::ios::binary);
			if (!file->is_open()) {
				delete file;
				return nullptr;
			}
			info->handle.resource = file;
			info->cleanup = std::unique_ptr < void, std::function < void(void*)>>(
			file, [](void* f) { delete static_cast < std::ifstream* > (f); }
			                );
			break;
		}
		case NVGT_RESOURCE_MEMORY: {
			size_t size = request->size_hint;
			if (size == 0) size = 1024;
			void* mem = std::malloc(size);
			if (!mem) return nullptr;
			info->handle.resource = mem;
			info->cleanup = std::unique_ptr < void, std::function < void(void*)>>(
			mem, [](void* m) { std::free(m); }
			                );
			break;
		}
		default:
			return nullptr;
	}
	nvgt_resource_handle* handle = &info->handle;
	active_resources[handle] = std::move(info);
	plugin_resources[plugin_name].insert(handle);
	return handle;
}

void nvgt_release_resource(nvgt_resource_handle* handle) {
	if (!handle) return;
	nvgt_resource_callback callback = nullptr;
	void* callback_data = nullptr;
	uint32_t resource_type = 0;
	{
		Poco::FastMutex::ScopedLock lock(resource_mutex);
		auto it = active_resources.find(handle);
		if (it == active_resources.end())
			return;
		callback = handle->on_release_callback;
		callback_data = handle->callback_user_data;
		resource_type = handle->type;
		if (!handle->plugin_name.empty()) {
			auto plugin_it = plugin_resources.find(handle->plugin_name);
			if (plugin_it != plugin_resources.end()) {
				plugin_it->second.erase(handle);
				if (plugin_it->second.empty())
					plugin_resources.erase(plugin_it);
			}
		}
		active_resources.erase(it);
	}
	if (callback)
		callback(resource_type, callback_data);
}


// Global resource limit showcase
size_t nvgt_get_resource_limit(uint32_t resource_type) {
	switch (resource_type) {
		case NVGT_RESOURCE_FILESYSTEM:
			return 100;
		case NVGT_RESOURCE_MEMORY:
			return 100 * 1024 * 1024; // 100MB per plugin
		default:
			return 0;
	}
}

struct service_info {
	void* service;
	std::string plugin_name;
};

static std::unordered_map < std::string, service_info > service_registry;
static std::unordered_map < std::string, std::unordered_set < std::string>> plugin_services;
static Poco::FastMutex service_mutex;

void* nvgt_get_service(const std::string& service_name) {
	if (service_name.empty()) return nullptr;
	Poco::FastMutex::ScopedLock lock(service_mutex);
	auto it = service_registry.find(service_name);
	if (it != service_registry.end())
		return it->second.service;
	return nullptr;
}

bool nvgt_register_service(const std::string& service_name, void* service, const std::string& plugin_name) {
	if (service_name.empty() || !service) return false;
	Poco::FastMutex::ScopedLock lock(service_mutex);
	if (service_registry.find(service_name) != service_registry.end())
		return false;
	service_info info;
	info.service = service;
	if (!plugin_name.empty())
		info.plugin_name = plugin_name;
	else if (current_plugin_name)
		info.plugin_name = *current_plugin_name;
	else
		info.plugin_name = "core";
	service_registry[service_name] = info;
	plugin_services[info.plugin_name].insert(service_name);
	return true;
}

bool nvgt_unregister_service(const std::string& service_name) {
	if (service_name.empty()) return false;
	Poco::FastMutex::ScopedLock lock(service_mutex);
	auto it = service_registry.find(service_name);
	if (it == service_registry.end())
		return false;
	const std::string& plugin_name = it->second.plugin_name;
	auto plugin_it = plugin_services.find(plugin_name);
	if (plugin_it != plugin_services.end()) {
		plugin_it->second.erase(service_name);
		if (plugin_it->second.empty())
			plugin_services.erase(plugin_it);
	}
	service_registry.erase(it);
	return true;
}

void nvgt_enumerate_services(void* callback_context, void (*callback)(void* context, const char* service_name)) {
	if (!callback) return;
	Poco::FastMutex::ScopedLock lock(service_mutex);
	for (const auto& pair : service_registry)
		callback(callback_context, pair.first.c_str());
}

bool nvgt_set_resource_callback(nvgt_resource_handle* handle, nvgt_resource_callback on_release, void* user_data) {
	if (!handle) return false;
	Poco::FastMutex::ScopedLock lock(resource_mutex);
	auto it = active_resources.find(handle);
	if (it == active_resources.end())
		return false;
	handle->on_release_callback = on_release;
	handle->callback_user_data = user_data;
	return true;
}

void cleanup_plugin_services(const std::string& plugin_name) {
	Poco::FastMutex::ScopedLock lock(service_mutex);
	auto it = plugin_services.find(plugin_name);
	if (it == plugin_services.end()) return;
	std::vector < std::string > services_to_remove(it->second.begin(), it->second.end());
	for (const auto& service_name : services_to_remove)
		service_registry.erase(service_name);
	plugin_services.erase(it);
}

void cleanup_all_services() {
	Poco::FastMutex::ScopedLock lock(service_mutex);
	service_registry.clear();
	plugin_services.clear();
}
