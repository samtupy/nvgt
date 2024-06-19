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
#include <SDL2/SDL.h>
#include "nvgt.h"
#include "nvgt_plugin.h"
#include "UI.h"
#include "monocypher.h"
#include <cstdint>
#include <array>
#ifdef _WIN32
#include <bcrypt.h>
#elif defined(__APPLE__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
#include <stdlib.h>
#elif defined(__linux__)
#include <sys/random.h>
#include <errno.h>
#else
#error Unsupported target platform
#endif
#include <filesystem>
#include <Poco/Util/Application.h>
#include <Poco/FileStream.h>
#include <vector>

std::unordered_map<std::string, void*> loaded_plugins; // Contains handles to sdl objects.
std::unordered_map<std::string, nvgt_plugin_entry*>* static_plugins = NULL; // Contains pointers to static plugin entry points. This doesn't contain entry points for plugins loaded from a dll, rather those that have been linked statically into the executable produced by a custom build of nvgt. This is a pointer because the map is initialized the first time register_static_plugin is called so that we are not trusting in global initialization order.

bool load_nvgt_plugin(const std::string& name, void* user) {
	nvgt_plugin_entry* entry = NULL;
	void* obj = NULL;
	if (loaded_plugins.contains(name)) return true; // plugin already loaded
	if (static_plugins && static_plugins->contains(name))
		entry = (nvgt_plugin_entry*)(*static_plugins)[name];
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

template <typename T, typename F> constexpr inline T to_from_cast(const F &val) {
  return reinterpret_cast<T>(static_cast<F>(val));
}

bool verify_plugin_signature(const std::array<char, 64>& signature, const std::array<char, 32>& public_key, const std::string& name) {
auto plugin_path = std::filesystem::path(Poco::Util::Application::instance().config().getString("application.dir"));
#if defined(_WIN32) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
plugin_path /= "lib";
#elif defined(__APPLE__)
plugin_path = plugin_path.parent_path() / "frameworks";
#endif
		std::string dllname = name;
		#ifdef _WIN32
		dllname += ".dll";
		#elif defined(__APPLE__)
		dllname += ".dylib";
		#else
		dllname += ".so";
		#endif
		plugin_path /= dllname;
Poco::FileInputStream fileStream(plugin_path.string());
if (!fileStream.good()) {
throw std::runtime_error("Internal error: file stream is broken in verify_plugin_signature!");
}
Poco::BinaryReader br(fileStream);
std::vector<char> bytes;
bytes.reserve(br.available());
br.readRaw(bytes.data(), bytes.size());
return crypto_eddsa_check(to_from_cast<const std::uint8_t*>(signature.data()), to_from_cast<const std::uint8_t*>(public_key.data()), to_from_cast<const std::uint8_t*>(bytes.data()), bytes.size()) == 0;
}

std::array<char, 64> sign_plugin(std::array<char, 64>& sk, const std::string& name) {
auto plugin_path = std::filesystem::path(Poco::Util::Application::instance().config().getString("application.dir"));
#if defined(_WIN32) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
plugin_path /= "lib";
#elif defined(__APPLE__)
plugin_path = plugin_path.parent_path() / "frameworks";
#endif
		std::string dllname = name;
		#ifdef _WIN32
		dllname += ".dll";
		#elif defined(__APPLE__)
		dllname += ".dylib";
		#else
		dllname += ".so";
		#endif
		plugin_path /= dllname;
Poco::FileInputStream fileStream(plugin_path.string());
if (!fileStream.good()) {
crypto_wipe(sk.data(), sk.size());
throw std::runtime_error("Internal error: file stream is broken in sign_plugin!");
}
Poco::BinaryReader br(fileStream);
std::vector<char> bytes;
bytes.reserve(br.available());
br.readRaw(bytes.data(), bytes.size());
std::array<char, 64> signature;
crypto_eddsa_sign(to_from_cast<std::uint8_t*>(signature.data()), to_from_cast<std::uint8_t*>(sk.data()), to_from_cast<std::uint8_t*>(bytes.data()), bytes.size());
crypto_wipe(sk.data(), sk.size());
return signature;
}

bool load_serialized_nvgt_plugins(Poco::BinaryReader& br) {
	unsigned short count;
	br >> count;
	if (!count) return true;
	for (int i = 0; i < count; i++) {
		std::string name;
		br >> name;
		std::array<char, 64> signature;
		br.readRaw(signature.data(), signature.size());
		std::array<char, 32> public_key;
		br.readRaw(public_key.data(), public_key.size());
		if (!verify_plugin_signature(signature, public_key, name)) {
            message(Poco::format("Unable to verify %s, exiting.", name), "error");
            return false;
        }
		if (!load_nvgt_plugin(name)) {
			message(Poco::format("Unable to load %s, exiting.", name), "error");
			return false;
		}
	}
	return true;
}

void serialize_nvgt_plugins(Poco::BinaryWriter& bw) {
	unsigned short count = loaded_plugins.size();
	bw << count;
	for (const auto& i : loaded_plugins) {
		bw << i.first;
		std::array<std::uint8_t, 32> seed;
		// We must be careful to only use this seed once
		// We use the platform-provided CSPRNG here instead of pocos because Pocos cannot be trusted.
		// Reasoning: on Windows Poco's CSPRNG behaves correctly, but on non-windows platforms the behavior varies (i.e., reading /dev/random which is dangerous to use correctly and opens file-based attacks, and on other platforms it uses a digest hash to generate the key, which risks security degredation).
#ifdef _WIN32
    if (const auto res = BCryptGenRandom(NULL, seed.data(), seed.size(), BCRYPT_USE_SYSTEM_PREFERRED_RNG); res != 0) {
        throw std::runtime_error("Cannot generate seed for plugin signing!");
    }
#elif defined(__APPLE__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
    arc4random_buf(seed.data(), seed.size());
#elif defined(__linux__)
    ssize_t bytes_written = getrandom(seed.data(), seed.size(), 0);
    if (bytes_written == -1 && errno != ENOSYS) {
        throw std::runtime_error("Error generating random data with getrandom(2)");
    }
    while (bytes_written != seed.size()) {
        if (bytes_written == -1) {
            throw std::runtime_error("Error generating random data with getrandom(2)");
        }
        bytes_written = getrandom(seed.data() + bytes_written, seed.size() - bytes_written, 0);
    }
#endif
std::array<char, 64> sk;
std::array<char, 32> pk;
crypto_eddsa_key_pair(to_from_cast<std::uint8_t*>(sk.data()), to_from_cast<std::uint8_t*>(pk.data()), seed.data());
crypto_wipe(seed.data(), seed.size());
std::array<char, 64> signature = sign_plugin(sk, i.first);
crypto_wipe(sk.data(), sk.size());
bw.writeRaw(signature.data(), signature.size());
bw.writeRaw(pk.data(), pk.size());
}
}

void unload_nvgt_plugins() {
	for (const auto& i : loaded_plugins) {
		if (i.second) SDL_UnloadObject(i.second);
	}
	loaded_plugins.clear();
}
