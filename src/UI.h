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
#else
	extern void* g_OSWindowHandle;
#endif
#include <angelscript.h>
#include <string>
#include <SDL2/SDL.h>

extern SDL_Window* g_WindowHandle;

int alert(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
int question(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
void message(const std::string& text, const std::string& header);
bool info_box(const std::string& title, const std::string& text, const std::string& value);
bool ClipboardSetText(const std::string& text);

asINT64 ShowWindow(std::string& window_title);
void wait(int ms);
 std::string open_fileDialog(const std::string& title="");
 bool save_file_dialog(const std::string& title="");
void RegisterUI(asIScriptEngine* engine);
