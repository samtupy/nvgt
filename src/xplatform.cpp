/* xplatform.cpp - code and routines that compile on multiple platforms
 * The intent of this module is to reduce the number of preprocessor platform checks in other parts of NVGT's codebase, and to provide a common place for small bits of platform compatibility code that could otherwise cause clutter.
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

#include <SDL3/SDL.h>
#ifndef _WIN32
#include <dlfcn.h>
#endif
#include <Poco/Clock.h>
#include <Poco/Environment.h>
#include <Poco/File.h>
#include <Poco/Path.h>
#include <Poco/Thread.h>
#include "nvgt.h"
#include "xplatform.h"

using namespace Poco;

bool running_on_mobile() {
	#if defined(__ANDROID__) || defined(__APPLE__) && TARGET_OS_IPHONE
		return true;
	#else
		return false;
	#endif
}
#ifndef NVGT_STUB
void determine_compile_platform() {
	if (g_platform != "auto") return;
	#ifdef _WIN32
	g_platform = "windows";
	#elif defined(__linux__)
	g_platform = "linux";
	#elif defined(__APPLE__)
	g_platform = "mac"; // Todo: detect difference between IOS and macos (need to look up the correct macros).
	#elif defined(__ANDROID__)
	g_platform = "android";
	#endif
	// else compilation is not supported on this platform.
}
void xplatform_correct_path_to_stubs(Poco::Path& stubpath) {
	#ifdef __APPLE__ // Stub may be in Resources directory of an app bundle.
	if (!File(stubpath).exists() && stubpath[stubpath.depth() -2] == "MacOS" && stubpath[stubpath.depth() -3] == "Contents") stubpath.makeParent().makeParent().pushDirectory("Resources").pushDirectory("stub");
	#endif
}
std::string get_nvgt_lib_directory(const std::string& platform) {
	// The directory containing the libraries for the NVGT currently running is usually just called lib, while all other directories are lib_platform. In any case try to return an absolute path to the libraries given a platform.
	std::string dir;
	bool apple_bundle = File(Path(Path::self()).makeParent().makeParent().pushDirectory("Frameworks").toString()).exists();
	if (platform == "windows") dir = Poco::Environment::isWindows()? "lib" : "lib_windows";
	else if (platform == "mac") dir = Environment::os() == POCO_OS_MAC_OS_X? (apple_bundle? "Frameworks" : "lib") : "lib_mac";
	else if (platform == "linux") dir = Poco::Environment::os() == POCO_OS_LINUX? "lib" : "lib_linux";
	else return ""; // libs not applicable for this platform.
	Path result(Path::self());
	result.makeParent();
	#ifdef __APPLE__
		if (apple_bundle) {
			result.makeParent();
			if (platform != "mac") result.append("Resources");
		}
	#endif
	result.pushDirectory(dir);
	return result.toString();
}
#endif

#if defined(__APPLE__) || defined(__ANDROID__)
// The following code allows nvgt's compiler to open files sent to it from finder or other android apps. SDL handles the needed event for us, so we just need to snatch it from the event queue before our normal cross platform sdl event handling takes over after the nvgt script has begun executing.
void InputInit(); // Forward declared from input.cpp
void InputDestroy();
std::string event_requested_file() {
	#ifdef __APPLE__
		if (!Poco::Environment::has("MACOS_BUNDLED_APP")) return ""; // This will certainly not happen outside of the app bundle.
	#endif
	InputInit();
	std::string result;
	Poco::Clock timeout;
	bool old_dropfile_state = SDL_EventEnabled(SDL_EVENT_DROP_FILE);
	SDL_SetEventEnabled(SDL_EVENT_DROP_FILE, true);
	while (!timeout.isElapsed(50000)) {
		Poco::Thread::sleep(5);
		SDL_Event e;
		SDL_PumpEvents();
		if (SDL_PeepEvents(&e, 1, SDL_GETEVENT, SDL_EVENT_DROP_FILE, SDL_EVENT_DROP_FILE) < 1) continue;
		result = e.drop.data;
		break;
	}
	SDL_SetEventEnabled(SDL_EVENT_DROP_FILE, old_dropfile_state);
	InputDestroy();
	return result;
}
#endif
#ifdef __ANDROID__
std::string android_get_main_shared_object() {
	std::string p;
	Dl_info inf;
	if (dladdr((void*)android_get_main_shared_object, &inf)) p = inf.dli_fname;
	return p;
}
#endif
