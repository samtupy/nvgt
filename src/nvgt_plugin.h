/* nvgt_plugin.h - public header for nvgt plugins
 * This header is used both by nvgt to load plugins as well as by plugins themselves.
 * To export new functions from NVGT, increment NVGT_PLUGIN_API_VERSION and add to the NVGT_PLUGIN_FUNCTIONS macro before rebuilding the engine.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#pragma once

#if !defined(NVGT_BUILDING) && !defined(NVGT_PLUGIN_STATIC) // this is a plugin, not nvgt itself
	#define ANGELSCRIPT_DLL_MANUAL_IMPORT
#endif
#include <angelscript.h>
#include <iostream>
#include <string>

#define NVGT_PLUGIN_API_VERSION 4

// Subsystem flags, used for controling access to certain functions during development.
enum NVGT_SUBSYSTEM {
	NVGT_SUBSYSTEM_GENERAL = 0x01,
	NVGT_SUBSYSTEM_FS = 0x02,
	NVGT_SUBSYSTEM_DATA = 0x04,
	NVGT_SUBSYSTEM_SOUND = 0x08,
	NVGT_SUBSYSTEM_SPEECH = 0x10,
	NVGT_SUBSYSTEM_INPUT = 0x20,
	NVGT_SUBSYSTEM_NET = 0x40,
	NVGT_SUBSYSTEM_MAP = 0x80,
	NVGT_SUBSYSTEM_SCRIPTING = 0x100,
	NVGT_SUBSYSTEM_DATETIME = 0x200,
	NVGT_SUBSYSTEM_TMRQ = 0x400,
	NVGT_SUBSYSTEM_UI = 0x800,
	NVGT_SUBSYSTEM_OS = 0x1000,
	NVGT_SUBSYSTEM_PATHFINDER = 0x2000,
	NVGT_SUBSYSTEM_VC = 0x4000,
	NVGT_SUBSYSTEM_TERMINAL = 0x8000,
	NVGT_SUBSYSTEM_SQLITE3 = 0x10000,
	NVGT_SUBSYSTEM_GIT = 0x20000,
	NVGT_SUBSYSTEM_DLLCALL = 0x40000,
	NVGT_SUBSYSTEM_RAW_MEMORY = 0x80000,
	NVGT_SUBSYSTEM_UNCLASSIFIED = 0x80000000,
	NVGT_SUBSYSTEM_EVERYTHING = 0xffffffff,
	NVGT_SUBSYSTEM_SCRIPTING_SANDBOX = NVGT_SUBSYSTEM_GENERAL | NVGT_SUBSYSTEM_DATA | NVGT_SUBSYSTEM_DATETIME
};

// Exported external functions usually from Angelscript.h:
#define NVGT_PLUGIN_EXTERNAL_FUNCTIONS \
	X(const char*, asGetLibraryVersion, ()) \
	X(const char*, asGetLibraryOptions, ()) \
	X(asIScriptContext*, asGetActiveContext, ()) \
	X(int, asPrepareMultithread, (asIThreadManager*)) \
	X(void, asAcquireExclusiveLock, ()) \
	X(void, asReleaseExclusiveLock, ()) \
	X(void, asAcquireSharedLock, ()) \
	X(void, asReleaseSharedLock, ()) \
	X(int, asAtomicInc, (int&)) \
	X(int, asAtomicDec, (int&)) \
	X(int, asThreadCleanup, ()) \
	X(void*, asAllocMem, (size_t)) \
	X(void, asFreeMem, (void*))
// To export new functions from NVGT, add to this macro:
#define NVGT_PLUGIN_FUNCTIONS \
	X(void*, nvgt_datastream_create, (std::ios* stream, const std::string& encoding, int byteorder)) \
	X(std::ios*, nvgt_datastream_get_ios, (void* stream)) \
	X(void, nvgt_bundle_shared_library, (const std::string& libname)) \
	X(bool, find_embedded_pack, (std::string& filename, uint64_t& file_offset, uint64_t& file_size)) \
	X(void, nvgt_wait, (int ms)) \
	X(void, refresh_window, ()) \
	X(uint64_t, ticks, (bool secure)) \
	X(uint64_t, microticks, (bool secure)) \
	X(std::string, string_aes_encrypt, (const std::string& plaintext, std::string key)) \
	X(std::string, string_aes_decrypt, (const std::string& ciphertext, std::string key)) \
	X(bool, running_on_mobile, ())
// Add more functions here...

// Function typedefs:
#define X(ret, name, args) typedef ret t_##name args;
NVGT_PLUGIN_EXTERNAL_FUNCTIONS
NVGT_PLUGIN_FUNCTIONS
#undef X

typedef struct {
	int version;
	#define X(ret, name, args) t_##name* f_##name;
	NVGT_PLUGIN_EXTERNAL_FUNCTIONS
	NVGT_PLUGIN_FUNCTIONS
	#undef X
	asIScriptEngine* script_engine;
	asIThreadManager* script_thread_manager;
	void* user;
} nvgt_plugin_shared;

// Function prototype for a plugin's entry point.
typedef bool nvgt_plugin_entry(nvgt_plugin_shared*);
typedef int nvgt_plugin_version_func();

#ifndef NVGT_BUILDING
// If this macro is not defined, this header is being included from within a plugin that will receive pointers to needed functions from the main NVGT application.
#ifndef NVGT_PLUGIN_STATIC // Code that only executes for dll plugins.
	#if !defined(NVGT_PLUGIN_INCLUDE)
		#define X(ret, name, args) t_##name* name = nullptr;
		NVGT_PLUGIN_EXTERNAL_FUNCTIONS
		NVGT_PLUGIN_FUNCTIONS
		#undef X
	#else // If an angelscript addon includes nvgt_plugin.h, set NVGT_PLUGIN_INCLUDE to prevent these symbols from being defined multiple times.
		#define X(ret, name, args) extern t_##name* name;
		NVGT_PLUGIN_EXTERNAL_FUNCTIONS
		NVGT_PLUGIN_FUNCTIONS
		#undef X
	#endif
#elif (!defined(NVGT_BUILDING))
	// Any functions we want to expose from NVGT rather than Angelscript must be forward declared here, we only get to skip the Angelscript ones because we include angelscript.h. NVGT headers might not be available to a plugin developer.
	// Any functions we wish to export with a different name from NVGT's core must be inlined like this:
	void wait(int ms);
	inline void nvgt_wait(int ms) { wait(ms); }
	#define X(ret, name, args) ret name args;
	NVGT_PLUGIN_FUNCTIONS
	#undef X
#endif
// Macro to ease the definition of a plugin's entry point. If this plugin is compiled as a static library then the entry point is called nvgt_plugin_%plugname% where as a dll just calls it nvgt_plugin and externs it. We also define nvgt_plugin_version() here.
#ifndef plugin_main
	#ifdef NVGT_PLUGIN_STATIC
		#define CONCAT(x, y) x##y
		#define XCONCAT(x, y) CONCAT(x, y) // Yes both CONCAT functions are needed for correct macro expansion below.
		#define plugin_main bool XCONCAT(nvgt_plugin_, NVGT_PLUGIN_STATIC)
		#define plugin_version int XCONCAT(nvgt_plugin_version_, NVGT_PLUGIN_STATIC)
	#else
		#ifdef _WIN32
			#define plugin_export __declspec(dllexport)
		#elif defined(__GNUC__)
			#define plugin_export __attribute__((visibility ("default")))
		#else
			#define plugin_export
		#endif
		#define plugin_main extern "C" plugin_export bool nvgt_plugin
		#define plugin_version extern "C" plugin_export int nvgt_plugin_version
	#endif
	#ifndef NVGT_PLUGIN_INCLUDE
		plugin_version() { return NVGT_PLUGIN_API_VERSION; }
	#endif
#endif
// Pass a pointer to an nvgt_plugin_shared structure to this function, making Angelscript available for use in any file that includes nvgt_plugin.h after calling this function.
inline bool prepare_plugin(nvgt_plugin_shared* shared) {
	if (shared->version != NVGT_PLUGIN_API_VERSION) return false;
	#ifndef NVGT_PLUGIN_STATIC // If a static plugin, the following symbols are available by default as well as the thread manager.
	#define X(ret, name, args) name = shared->f_##name;
	NVGT_PLUGIN_EXTERNAL_FUNCTIONS
	NVGT_PLUGIN_FUNCTIONS
	#undef X
	asPrepareMultithread(shared->script_thread_manager);
	#endif
	return true;
}
#else
// We safely have access to NVGT headers here and can include function declarations we wish to export from any part of the project, functions existing in nvgt_plugin.cpp are directly forward declared here as well as inlines for any functions we wish to export with a different name than the internal such as nvgt_wait.
#include <ios>
#include <string>
#include <vector>
#include <stdio.h>
// Export wait with a different name because is risks clashing with unix symbols.
void wait(int ms);
inline void nvgt_wait(int ms) { wait(ms); }
#define X(ret, name, args) ret name args;
NVGT_PLUGIN_FUNCTIONS
#undef X

// This function prepares an nvgt_plugin_shared structure for passing to a plugins entry point. Sane input expected, no error checking.
inline void prepare_plugin_shared(nvgt_plugin_shared* shared, asIScriptEngine* engine, void* user = NULL) {
	shared->version = NVGT_PLUGIN_API_VERSION;
	#define X(ret, name, args) shared->f_##name = name;
	NVGT_PLUGIN_EXTERNAL_FUNCTIONS
	NVGT_PLUGIN_FUNCTIONS
	#undef X
	shared->script_engine = engine;
	shared->script_thread_manager = asGetThreadManager();
	shared->user = user;
}
// Forward declarations only needed when compiling for nvgt and not for a plugin, thus the following functions are in nvgt_plugin.cpp.
namespace Poco { class BinaryReader; class BinaryWriter; }
bool load_nvgt_plugin(const std::string& name, std::string* errmsg = nullptr, void* user = NULL);
bool register_static_plugin(const std::string& name, nvgt_plugin_entry* e, nvgt_plugin_version_func* v);
bool load_serialized_nvgt_plugins(Poco::BinaryReader& br);
void serialize_nvgt_plugins(Poco::BinaryWriter& bw);
void list_loaded_nvgt_plugins(std::vector<std::string>& output);
void unload_nvgt_plugins();
// Boilerplate to make registering a static plugin in the nvgt_config.h file consist of a single pretty looking line.
#ifndef static_plugin
#ifndef NVGT_LOAD_STATIC_PLUGINS // This is defined in nvggt.cpp before including nvgt_config.h which includes this file, so that static plugins load once in one place.
#define static_plugin(name)
#else
class static_plugin_loader {
public:
	static_plugin_loader(const std::string& name, nvgt_plugin_entry* e, nvgt_plugin_version_func* v) {
		register_static_plugin(name, e, v);
	}
};
#define static_plugin(name) \
	extern bool nvgt_plugin_##name(nvgt_plugin_shared*); \
	extern int nvgt_plugin_version_##name(); \
	static_plugin_loader nvgt_plugin_static_##name(#name, &nvgt_plugin_##name, &nvgt_plugin_version_##name);
#endif
#endif

#endif // NVGT_BUILDING

// This class must be derived from for any custom pack or vfs objects that wish to integrate with NVGT's sound system.
class pack_interface {
	mutable int refcount;
	public:
	pack_interface() : refcount(1) {}
	virtual ~pack_interface() = default;
	void duplicate() const { asAtomicInc(refcount); }
	void release() const { if (asAtomicDec(refcount) < 1) delete this; }
	virtual const pack_interface* make_immutable() const = 0;
	virtual const pack_interface* get_mutable() const = 0;
	virtual std::istream* get_file(const std::string& filename) const { return nullptr; }
	virtual const std::string get_pack_name() const { return ""; }
	template <class A, class B> static B* op_cast(A* from) {
		B* casted = dynamic_cast<B*>(from);
		if (!casted) return nullptr;
		casted->duplicate();
		return casted;
	}
};
