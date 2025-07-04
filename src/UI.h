/* UI.h - header for sdl window management functions and other user interface related routines
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
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#define VC_EXTRALEAN
	#include <windows.h>
	extern HWND g_OSWindowHandle;
#elif defined(__APPLE__)
	typedef struct _NSWindow NSWindow;
	extern NSWindow* g_OSWindowHandle;
#elif defined(__ANDROID__)
	#include <android/native_window.h>
	extern ANativeWindow* g_OSWindowHandle;
#else
	extern void* g_OSWindowHandle;
#endif
#include <angelscript.h>
#include <string>
#include <vector>
#include <SDL3/SDL.h>

extern SDL_Window* g_WindowHandle;

int message_box(const std::string& title, const std::string& text, const std::vector<std::string>& buttons, unsigned int mb_flags = 0);
int alert(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
int question(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
void message(const std::string& text, const std::string& header);
bool info_box(const std::string& title, const std::string& text, const std::string& value);
bool ClipboardSetText(const std::string& text);
std::string simple_file_open_dialog(const std::string& filters = "All files:*", const std::string& default_location = "");
bool urlopen(const std::string& url);

bool ShowNVGTWindow(const std::string& window_title);
bool DestroyNVGTWindow();
bool WindowIsFocused();
void refresh_window();
void wait(int ms);
void RegisterUI(asIScriptEngine* engine);
