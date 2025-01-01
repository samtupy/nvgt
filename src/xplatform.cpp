/* xplatform.cpp - code and routines that compile on multiple platforms
 * The intent of this module is to reduce the number of preprocessor platform checks in other parts of NVGT's codebase, and to provide a common place for small bits of platform compatibility code that could otherwise cause clutter.
 * It also contains some function registrations (mostly from SDL3) to ease cross platform development. If a function's effect might dramatically change or even be available on certain platforms it is OK to register it here unless it fits better somewhere else.
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
#include <string>
#include <Poco/Clock.h>
#include <Poco/Environment.h>
#include <Poco/File.h>
#include <Poco/Path.h>
#include <Poco/Thread.h>
#include <obfuscate.h>
#include <angelscript.h>
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

// Anything below this point is function registrations.
// Usually this involves defining no-op versions of functions that are only available on certain platforms, though can sometimes include wrappers as well to get around char* and other things that we can't directly register.
#ifndef SDL_PLATFORM_LINUX
bool SDL_SetLinuxThreadPriority(Sint64 threadID, int priority) { return false; }
bool SDL_SetLinuxThreadPriorityAndPolicy(Sint64 threadID, int priority, int schedPolicy) { return false; }
#endif
#ifndef SDL_PLATFORM_ANDROID
int SDL_GetAndroidSDKVersion() { return -1; }
bool SDL_IsChromebook() { return false; }
bool SDL_IsDeXMode() { return false; }
void SDL_SendAndroidBackButton() {}
bool request_android_permission(const std::string& permission, asIScriptFunction* callback, const std::string& callback_data) {
	if (callback) callback->Release();
	return false;
}
bool show_android_toast(const std::string& message, int duration, int gravity, int x_offset, int y_offset) { return false; }
std::string get_directory_appdata() {
	return Path::configHome();
}
std::string get_directory_temp() {
	return Path::temp();
}
#else
struct android_permission_request_callback_data {
	asIScriptFunction* func;
	std::string callback_data;
	Event completed;
	bool was_granted;
	android_permission_request_callback_data(asIScriptFunction* func, const std::string& callback_data) : func(func), callback_data(callback_data), was_granted(false) {}
	void execute(std::string permission, bool granted) {
		was_granted = granted;
		if (!func) {
			completed.set();
			return;
		}
		asIScriptContext* ctx = g_ScriptEngine->RequestContext();
		if (!ctx || ctx->Prepare(func) < 0) goto done;
		if (ctx->SetArgObject(0, &permission) < 0 || ctx->SetArgByte(1, granted) < 0 || ctx->SetArgObject(2, &callback_data) < 0) goto done;
		ctx->Execute();
		done:
		g_ScriptEngine->ReturnContext(ctx);
		if (func) func->Release();
		completed.set();
	}
};
void android_permission_request_callback(void* raw_data, const char* permission, bool granted) {
	android_permission_request_callback_data* data = reinterpret_cast<android_permission_request_callback_data*>(raw_data);
	data->execute(permission, granted);
}
bool request_android_permission(const std::string& permission, asIScriptFunction* callback, const std::string& callback_data) {
	android_permission_request_callback_data* data = new android_permission_request_callback_data(callback, callback_data);
	bool result = SDL_RequestAndroidPermission(permission.c_str(), android_permission_request_callback, data);
	if (!callback) {
		data->completed.wait();
		result = data->was_granted;
		delete data;
	}
	return result;
}
bool show_android_toast(const std::string& message, int duration, int gravity, int x_offset, int y_offset) {
	return SDL_ShowAndroidToast(message.c_str(), duration, gravity, x_offset, y_offset);
}
std::string get_directory_appdata() {
	return SDL_GetAndroidInternalStoragePath();
}
std::string get_directory_temp() {
	return SDL_GetAndroidCachePath();
}
#endif
void RegisterXplatform(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction("string set_linux_thread_priority(int64 thread_id, int priority)", asFUNCTION(SDL_SetLinuxThreadPriority), asCALL_CDECL);
	engine->RegisterGlobalFunction("string set_linux_thread_priority_and_policy(int64 thread_id, int priority, int policy)", asFUNCTION(SDL_SetLinuxThreadPriorityAndPolicy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void android_send_back_button()", asFUNCTION(SDL_SendAndroidBackButton), asCALL_CDECL);
	engine->RegisterFuncdef("void android_permission_request_callback(string permission, bool granted, string user_data)");
	engine->RegisterGlobalFunction("bool android_request_permission(const string&in permission, android_permission_request_callback@ callback = null, const string&in callback_data = \"\")", asFUNCTION(request_android_permission), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool android_show_toast(const string&in message, int duration, int gravity = -1, int x_offset = 0, int y_offset = 0)", asFUNCTION(show_android_toast), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterGlobalFunction("int get_ANDROID_SDK_VERSION() property", asFUNCTION(SDL_GetAndroidSDKVersion), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_system_is_chromebook() property", asFUNCTION(SDL_IsChromebook), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_system_is_DeX_mode() property", asFUNCTION(SDL_IsDeXMode), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_system_is_tablet() property", asFUNCTION(SDL_IsTablet), asCALL_CDECL);
	//engine->RegisterGlobalFunction("bool get_system_is_tv() property", asFUNCTION(SDL_IsTV), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_DIRECTORY_APPDATA() property"), asFUNCTION(get_directory_appdata), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_DIRECTORY_TEMP() property"), asFUNCTION(get_directory_temp), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_system_is_mobile() property", asFUNCTION(running_on_mobile), asCALL_CDECL);
}
