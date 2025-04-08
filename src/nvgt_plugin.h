/* nvgt_plugin.h - public header for nvgt plugins
 * This header is used both by nvgt to load plugins as well as by plugins themselves.
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

#pragma once

#if !defined(NVGT_BUILDING) && !defined(NVGT_PLUGIN_STATIC) // this is a plugin, not nvgt itself
	#define ANGELSCRIPT_DLL_MANUAL_IMPORT
#endif
#include <angelscript.h>
#include <iostream>

#define NVGT_PLUGIN_API_VERSION 1

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
	NVGT_SUBSYSTEM_UNCLASSIFIED = 0x80000000,
	NVGT_SUBSYSTEM_EVERYTHING = 0xffffffff,
	NVGT_SUBSYSTEM_SCRIPTING_SANDBOX = NVGT_SUBSYSTEM_GENERAL | NVGT_SUBSYSTEM_DATA | NVGT_SUBSYSTEM_DATETIME
};

// Angelscript function prototypes:
typedef const char* t_asGetLibraryVersion();
typedef const char* t_asGetLibraryOptions();
typedef asIScriptContext* t_asGetActiveContext();
typedef int t_asPrepareMultithread(asIThreadManager*);
typedef void t_asAcquireExclusiveLock();
typedef void t_asReleaseExclusiveLock();
typedef void t_asAcquireSharedLock();
typedef void t_asReleaseSharedLock();
typedef int t_asAtomicInc(int&);
typedef int t_asAtomicDec(int&);
typedef int t_asThreadCleanup();
typedef void* t_asAllocMem(size_t);
typedef void t_asFreeMem(void*);
typedef void AS_CALL(void*);
typedef void* t_nvgt_datastream_create(std::ios* stream, const std::string& encoding, int byteorder);
typedef std::ios* t_nvgt_datastream_get_ios(void* stream);

typedef struct {
	int version;
	t_asGetLibraryVersion* f_asGetLibraryVersion;
	t_asGetLibraryOptions* f_asGetLibraryOptions;
	t_asGetActiveContext* f_asGetActiveContext;
	t_asPrepareMultithread* f_asPrepareMultithread;
	t_asAcquireExclusiveLock* f_asAcquireExclusiveLock;
	t_asReleaseExclusiveLock* f_asReleaseExclusiveLock;
	t_asAcquireSharedLock* f_asAcquireSharedLock;
	t_asReleaseSharedLock* f_asReleaseSharedLock;
	t_asAtomicInc* f_asAtomicInc;
	t_asAtomicDec* f_asAtomicDec;
	t_asThreadCleanup* f_asThreadCleanup;
	t_asAllocMem* f_asAllocMem;
	t_asFreeMem* f_asFreeMem;
	t_nvgt_datastream_create* f_nvgt_datastream_create;
	t_nvgt_datastream_get_ios* f_nvgt_datastream_get_ios;
	asIScriptEngine* script_engine;
	asIThreadManager* script_thread_manager;
	void* user;
} nvgt_plugin_shared;

// Function prototype for a plugin's entry point.
typedef bool nvgt_plugin_entry(nvgt_plugin_shared*);

#ifndef NVGT_BUILDING
// If this macro is not defined, this header is being included from within a plugin that will receive pointers to needed angelscript functions from the main NVGT application.
#ifndef NVGT_PLUGIN_STATIC // Code that only executes for dll plugins.
	#if !defined(NVGT_PLUGIN_INCLUDE)
		t_asGetLibraryVersion* asGetLibraryVersion = NULL;
		t_asGetLibraryOptions* asGetLibraryOptions = NULL;
		t_asGetActiveContext* asGetActiveContext = NULL;
		t_asPrepareMultithread* asPrepareMultithread = NULL;
		t_asAcquireExclusiveLock* asAcquireExclusiveLock = NULL;
		t_asReleaseExclusiveLock* asReleaseExclusiveLock = NULL;
		t_asAcquireSharedLock* asAcquireSharedLock = NULL;
		t_asReleaseSharedLock* asReleaseSharedLock = NULL;
		t_asAtomicInc* asAtomicInc = NULL;
		t_asAtomicDec* asAtomicDec = NULL;
		t_asThreadCleanup* asThreadCleanup = NULL;
		t_asAllocMem* asAllocMem = NULL;
		t_asFreeMem* asFreeMem = NULL;
		t_nvgt_datastream_create* nvgt_datastream_create = NULL;
		t_nvgt_datastream_get_ios* nvgt_datastream_get_ios = NULL;
	#else // If an angelscript addon includes nvgt_plugin.h, set NVGT_PLUGIN_INCLUDE to prevent these symbols from being defined multiple times.
		extern t_asGetLibraryVersion* asGetLibraryVersion;
		extern t_asGetLibraryOptions* asGetLibraryOptions;
		extern t_asGetActiveContext* asGetActiveContext;
		extern t_asPrepareMultithread* asPrepareMultithread;
		extern t_asAcquireExclusiveLock* asAcquireExclusiveLock;
		extern t_asReleaseExclusiveLock* asReleaseExclusiveLock;
		extern t_asAcquireSharedLock* asAcquireSharedLock;
		extern t_asReleaseSharedLock* asReleaseSharedLock;
		extern t_asAtomicInc* asAtomicInc;
		extern t_asAtomicDec* asAtomicDec;
		extern t_asThreadCleanup* asThreadCleanup;
		extern t_asAllocMem* asAllocMem;
		extern t_asFreeMem* asFreeMem;
		extern t_nvgt_datastream_create* nvgt_datastream_create;
		extern t_nvgt_datastream_get_ios* nvgt_datastream_get_ios;
	#endif
#endif
// Macro to ease the definition of a plugin's entry point. If this plugin is compiled as a static library then the entry point is called nvgt_plugin_%plugname% where as a dll just calls it nvgt_plugin and externs it.
#ifndef plugin_main
	#ifdef NVGT_PLUGIN_STATIC
		#define CONCAT(x, y) x##y
		#define XCONCAT(x, y) CONCAT(x, y) // Yes both CONCAT functions are needed for correct macro expansion below.
		#define plugin_main bool XCONCAT(nvgt_plugin_, NVGT_PLUGIN_STATIC)
	#else
		#ifdef _WIN32
			#define plugin_export __declspec(dllexport)
		#elif defined(__GNUC__)
			#define plugin_export __attribute__((visibility ("default")))
		#else
			#define plugin_export
		#endif
		#define plugin_main extern "C" plugin_export bool nvgt_plugin
	#endif
#endif
// Pass a pointer to an nvgt_plugin_shared structure to this function, making Angelscript available for use in any file that includes nvgt_plugin.h after calling this function.
inline bool prepare_plugin(nvgt_plugin_shared* shared) {
	if (shared->version != NVGT_PLUGIN_API_VERSION) return false;
	#ifndef NVGT_PLUGIN_STATIC // If a static plugin, the following symbols are available by default as well as the thread manager.
	asGetLibraryVersion = shared->f_asGetLibraryVersion;
	asGetLibraryOptions = shared->f_asGetLibraryOptions;
	asGetActiveContext = shared->f_asGetActiveContext;
	asPrepareMultithread = shared->f_asPrepareMultithread;
	asAcquireExclusiveLock = shared->f_asAcquireExclusiveLock;
	asReleaseExclusiveLock = shared->f_asReleaseExclusiveLock;
	asAcquireSharedLock = shared->f_asAcquireSharedLock;
	asReleaseSharedLock = shared->f_asReleaseSharedLock;
	asAtomicInc = shared->f_asAtomicInc;
	asAtomicDec = shared->f_asAtomicDec;
	asThreadCleanup = shared->f_asThreadCleanup;
	asAllocMem = shared->f_asAllocMem;
	asFreeMem = shared->f_asFreeMem;
	nvgt_datastream_create = shared->f_nvgt_datastream_create;
	nvgt_datastream_get_ios = shared->f_nvgt_datastream_get_ios;
	asPrepareMultithread(shared->script_thread_manager);
	#endif
	return true;
}
#else
#include <ios>
#include <string>
#include <stdio.h>
void* nvgt_datastream_create(std::ios* stream, const std::string& encoding, int byteorder);
std::ios* nvgt_datastream_get_ios(void* stream);

// This function prepares an nvgt_plugin_shared structure for passing to a plugins entry point. Sane input expected, no error checking.
inline void prepare_plugin_shared(nvgt_plugin_shared* shared, asIScriptEngine* engine, void* user = NULL) {
	shared->version = NVGT_PLUGIN_API_VERSION;
	shared->f_asGetLibraryVersion = asGetLibraryVersion;
	shared->f_asGetLibraryOptions = asGetLibraryOptions;
	shared->f_asGetActiveContext = asGetActiveContext;
	shared->f_asPrepareMultithread = asPrepareMultithread;
	shared->f_asAcquireExclusiveLock = asAcquireExclusiveLock;
	shared->f_asReleaseExclusiveLock = asReleaseExclusiveLock;
	shared->f_asAcquireSharedLock = asAcquireSharedLock;
	shared->f_asReleaseSharedLock = asReleaseSharedLock;
	shared->f_asAtomicInc = asAtomicInc;
	shared->f_asAtomicDec = asAtomicDec;
	shared->f_asThreadCleanup = asThreadCleanup;
	shared->f_asAllocMem = asAllocMem;
	shared->f_asFreeMem = asFreeMem;
	shared->f_nvgt_datastream_create = nvgt_datastream_create;
	shared->f_nvgt_datastream_get_ios = nvgt_datastream_get_ios;
	shared->script_engine = engine;
	shared->script_thread_manager = asGetThreadManager();
	shared->user = user;
}
// Forward declarations only needed when compiling for nvgt and not for a plugin, thus the following functions are in nvgt_plugin.cpp.
namespace Poco { class BinaryReader; class BinaryWriter; }
bool load_nvgt_plugin(const std::string& name, void* user = NULL);
bool register_static_plugin(const std::string& name, nvgt_plugin_entry* e);
bool load_serialized_nvgt_plugins(Poco::BinaryReader& br);
void serialize_nvgt_plugins(Poco::BinaryWriter& bw);
void unload_nvgt_plugins();
// Boilerplate to make registering a static plugin in the nvgt_config.h file consist of a single pretty looking line.
#ifndef static_plugin
#ifndef NVGT_LOAD_STATIC_PLUGINS // This is defined in nvggt.cpp before including nvgt_config.h which includes this file, so that static plugins load once in one place.
#define static_plugin(name)
#else
class static_plugin_loader {
public:
	static_plugin_loader(const std::string& name, nvgt_plugin_entry* e) {
		register_static_plugin(name, e);
	}
};
#define static_plugin(name) \
	extern bool nvgt_plugin_##name(nvgt_plugin_shared*); \
	static_plugin_loader nvgt_plugin_static_##name(#name, &nvgt_plugin_##name);
#endif
#endif

#endif // NVGT_BUILDING

