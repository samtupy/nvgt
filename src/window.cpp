/* window.cpp - code for the management of an sdl window
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

#define NOMINMAX
#include <angelscript.h>
#include "srspeech.h"
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#define VC_EXTRALEAN
	#include <windows.h>
	#include <wingdi.h>
	#include <comip.h>
	#include <comdef.h>
	#include <shlobj.h>
	#include <shellapi.h>
	_COM_SMARTPTR_TYPEDEF(ITaskbarList3, __uuidof(ITaskbarList3));
#endif
#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>
#include <thread.h>
#include <string>
#include <vector>
#include <Poco/UnicodeConverter.h>
#include "input.h"
#include "misc_functions.h"
#include "nvgt.h"
#include "scriptstuff.h"
#include "timestuff.h"
#include "window.h"

SDL_Window* g_WindowHandle = 0;
#ifdef _WIN32
	HWND g_OSWindowHandle = NULL;
#elif defined(__APPLE__)
	#include "apple.h"
	NSWindow* g_OSWindowHandle = NULL;
#else
	void* g_OSWindowHandle = NULL;
#endif
thread_id_t g_WindowThreadId = 0;
bool g_WindowHidden = false;

static std::vector<SDL_Event> post_events; // holds events that should be processed after the next wait() call.
#ifdef _WIN32
void sdl_windows_messages(void* udata, void* hwnd, unsigned int message, uint64_t wParam, int64_t lParam) {
	if (message == WM_KEYDOWN && wParam == 'V' && lParam == 1) {
		SDL_Event e{};
		e.type = SDL_KEYDOWN;
		e.key.timestamp = SDL_GetTicks();
		e.key.keysym.scancode = SDL_SCANCODE_PASTE;
		e.key.keysym.sym = SDLK_PASTE;
		SDL_PushEvent(&e);
		e.type = SDL_KEYUP;
		post_events.push_back(e);
	}
}
#endif
bool set_application_name(const std::string& name) {
	bool ret = SDL_SetHintWithPriority(SDL_HINT_APP_NAME, name.c_str(), SDL_HINT_OVERRIDE);
	#ifdef _WIN32
	if (!g_OSWindowHandle) return ret;
	std::wstring name_u;
	Poco::UnicodeConverter::convert(name, name_u);
	ITaskbarList3Ptr sptb3;
	sptb3.CreateInstance(CLSID_TaskbarList);
	sptb3->SetOverlayIcon(g_OSWindowHandle, NULL, name_u.c_str());
	#endif
	return ret;
}
bool ShowNVGTWindow(std::string& window_title) {
	if (g_WindowHandle) {
		SDL_SetWindowTitle(g_WindowHandle, window_title.c_str());
		if (g_WindowHidden) {
			g_WindowHidden = false;
			SDL_ShowWindow(g_WindowHandle);
			SDL_RaiseWindow(g_WindowHandle);
		}
		return true;
	}
	InputInit();
	#ifdef _WIN32
	SDL_SetWindowsMessageHook(sdl_windows_messages, NULL);
	#endif
	g_WindowHandle = SDL_CreateWindow(window_title.c_str(), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 640, 0);
	if (!g_WindowHandle) return false;
	SDL_SysWMinfo winf;
	SDL_VERSION(&winf.version);
	SDL_GetWindowWMInfo(g_WindowHandle, &winf);
	#ifdef _WIN32
	g_OSWindowHandle = winf.info.win.window;
	#elif defined(SDL_VIDEO_DRIVER_COCOA)
	g_OSWindowHandle = winf.info.cocoa.window;
	SDL_ShowWindow(g_WindowHandle);
	SDL_RaiseWindow(g_WindowHandle);
	voice_over_window_created();
	#endif
	g_WindowThreadId = thread_current_thread_id();
	return true;
}
bool DestroyNVGTWindow() {
	if (!g_WindowHandle) return false;
	SDL_DestroyWindow(g_WindowHandle);
	InputDestroy();
	g_WindowHandle = NULL;
	g_OSWindowHandle = NULL;
	return true;
}
BOOL HideNVGTWindow() {
	if (!g_WindowHandle) return false;
	SDL_HideWindow(g_WindowHandle);
	g_WindowHidden = true;
	return true;
}
BOOL FocusNVGTWindow() {
	if (!g_WindowHandle) return false;
	SDL_RaiseWindow(g_WindowHandle);
	return true;
}
BOOL WindowIsFocused() {
	if (!g_WindowHandle) return false;
	return g_WindowHandle == SDL_GetKeyboardFocus();
}
std::string get_window_text() {
	if (!g_WindowHandle) return "";
	return std::string(SDL_GetWindowTitle(g_WindowHandle));
}
std::string get_focused_window_text() {
	#ifdef _WIN32
	HWND win = GetForegroundWindow();
	int bytes = GetWindowTextLength(win) * 2;
	std::wstring text(bytes, '\0');
	int r = GetWindowTextW(win, &text[0], bytes);
	if (r < 1) return "";
	std::string textA;
	Poco::UnicodeConverter::convert(text, textA);
	return textA;
	#else
	return "";
	#endif
}
void handle_sdl_event(SDL_Event* evt) {
	if (evt->type == SDL_KEYDOWN || evt->type == SDL_KEYUP || evt->type == SDL_TEXTINPUT || evt->type == SDL_MOUSEMOTION || evt->type == SDL_MOUSEBUTTONDOWN || evt->type == SDL_MOUSEBUTTONUP || evt->type == SDL_MOUSEWHEEL)
		InputEvent(evt);
	else if (evt->type == SDL_WINDOWEVENT && evt->window.event == SDL_WINDOWEVENT_FOCUS_LOST)
		SDL_ResetKeyboard();
}
void wait(int ms) {
	if (!g_WindowHandle || g_WindowThreadId != thread_current_thread_id()) {
		Sleep(ms);
		return;
	}
	while (ms >= 0) {
		int MS = (ms > 25 ? 25 : ms);
		if (g_GCMode == 2)
			garbage_collect_action();
		Sleep(MS);
		SDL_PumpEvents();
		ms -= MS;
		if (ms < 1) break;
	}
	SDL_Event evt;
	#ifdef __APPLE__
	bool left_just_pressed = false, right_just_pressed = false;
	#endif
	while (SDL_PollEvent(&evt)) {
		#ifdef __APPLE__
		// Hack to fix voiceover's weird handling of the left and right arrow keys. If a left/right arrow down/up event get generated in the same frame, we need to move the up event to the next frame.
		bool evt_handled = false;
		if (evt.type == SDL_KEYDOWN) {
			if (evt.key.keysym.scancode == SDL_SCANCODE_LEFT) left_just_pressed = true;
			if (evt.key.keysym.scancode == SDL_SCANCODE_RIGHT) right_just_pressed = true;
		} else if ((left_just_pressed || right_just_pressed) && evt.type == SDL_KEYUP) {
			evt_handled = true;
			if (left_just_pressed && evt.key.keysym.scancode == SDL_SCANCODE_LEFT) post_events.push_back(evt);
			else if (right_just_pressed && evt.key.keysym.scancode == SDL_SCANCODE_RIGHT) post_events.push_back(evt);
			else evt_handled = false;
		}
		if (evt_handled) continue;
		#endif
		handle_sdl_event(&evt);
	}
	if (post_events.size() > 0) {
		for (SDL_Event& e : post_events)
			SDL_PushEvent(&e);
		post_events.clear();
	}
}
void RegisterWindow(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("bool set_application_name(const string& in)", asFUNCTION(set_application_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool show_window(const string& in)", asFUNCTION(ShowNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool destroy_window()", asFUNCTION(DestroyNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool hide_window()", asFUNCTION(HideNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool focus_window()", asFUNCTION(FocusNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_window_active()", asFUNCTION(WindowIsFocused), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_window_text()", asFUNCTION(get_window_text), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_focused_window_text()", asFUNCTION(get_focused_window_text), asCALL_CDECL);
	engine->RegisterGlobalFunction("void wait(int)", asFUNCTIONPR(wait, (int), void), asCALL_CDECL);
}
