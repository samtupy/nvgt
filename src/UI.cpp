/* UI.cpp - Various user interface routines and code for the management of an sdl window
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
	#include "InputBox.h"
#elif defined(__APPLE__)
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFBundle.h>
#include <CoreFoundation/CoreFoundation.h>
	#include "apple.h"
#elif defined(__ANDROID__)
	#include <android/native_window.h>
#else
// Following commented includes are for determining user idle time using x11 screensaver extension. Disabled for now until viability of linking with this library is established or until we fix the idle_ticks() function to use dlopen/dlsym and friends.
//#include <X11/Xlib.h>
//#include <X11/extensions/scrnsaver.h>
#endif
#ifndef _WIN32
#include <sys/time.h>
#endif
#include <SDL3/SDL.h>
#include <obfuscate.h>
#include <thread.h>
#include <string>
#include <unordered_set>
#include <vector>
#include <Poco/StringTokenizer.h>
#include <Poco/SynchronizedObject.h>
#include <Poco/Thread.h>
#include <Poco/UnicodeConverter.h>
#include <Poco/Util/Application.h>
#include "input.h"
#include "misc_functions.h"
#include "scriptstuff.h"
#include "timestuff.h"
#include "UI.h"
#if defined(__APPLE__) || (!defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))) || defined(__ANDROID__)
#include <unistd.h>
#include <cstdio>
#endif

int message_box(const std::string& title, const std::string& text, const std::vector<std::string>& buttons, unsigned int mb_flags) {
	// Start with the buttons.
	std::vector<SDL_MessageBoxButtonData> sdlbuttons;
	for (int i = 0; i < buttons.size(); i++) {
		const std::string& btn = buttons[i];
		int skip = 0;
		unsigned int button_flag = 0;
		if (!btn.empty() && !btn[0]) continue; // Don't show this button while still increasing button ID, useful for disabling options without modifying result checking code that may contain magic button ID numbers.
		if (btn.substr(0, 1) == "`") {
			button_flag |= SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT;
			skip += 1;
		}
		if (btn.substr(skip, 1) == "~") {
			button_flag |= SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT;
			skip += 1;
		}
		SDL_MessageBoxButtonData& sdlbtn = sdlbuttons.emplace_back();
		sdlbtn.flags = button_flag;
		sdlbtn.buttonID = i + 1;
		sdlbtn.text = buttons[i].c_str() + skip;
	}
	SDL_MessageBoxData box = {mb_flags, g_WindowHandle, title.c_str(), text.c_str(), int(sdlbuttons.size()), sdlbuttons.data(), NULL};
	int ret;
	if (!SDL_ShowMessageBox(&box, &ret)) return -1;
	return ret;
}
int message_box_script(const std::string& title, const std::string& text, CScriptArray* buttons, unsigned int flags) {
	std::vector<std::string> v_buttons(buttons->GetSize());
	for (unsigned int i = 0; i < buttons->GetSize(); i++) v_buttons[i] = (*(std::string*)(buttons->At(i)));
	return message_box(title, text, v_buttons, flags);
}
int alert(const std::string& title, const std::string& text, bool can_cancel, unsigned int flags) {
	std::vector<std::string> buttons = {can_cancel ? "`OK" : "`~OK"};
	if (can_cancel) buttons.push_back("~Cancel");
	return message_box(title, text, buttons, flags);
}
int question(const std::string& title, const std::string& text, bool can_cancel, unsigned int flags) {
	std::vector<std::string> buttons = {"`Yes", "No"};
	if (can_cancel) buttons.push_back("~Cancel");
	return message_box(title, text, buttons, flags);
}
void message(const std::string& text, const std::string& header) { // Usually used internally by NVGT's c++ code to print an error first to stdout if that's available, then to a message box if that's enabled.
	std::string tmp = header;
	tmp += ": ";
	tmp += text;
	if (Poco::Util::Application::instance().config().hasOption("application.gui")) {
		alert(header, text);
		return;
	} else printf("%s\n", tmp.c_str());
}
std::string ClipboardGetText() {
	InputInit();
	char* r = SDL_GetClipboardText();
	std::string cb_text(r);
	SDL_free(r);
	return cb_text;
}
bool ClipboardSetText(const std::string& text) {
	InputInit();
	return SDL_SetClipboardText(text.c_str()) == 0;
}
bool ClipboardSetRawText(const std::string& text) {
	#ifdef _WIN32
	if (!OpenClipboard(nullptr))
		return false;
	EmptyClipboard();
	if (text == "") {
		CloseClipboard();
		return true;
	}
	HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, text.size() + 1);
	if (!hMem) {
		CloseClipboard();
		return false;
	}
	char* cbText = (char*)GlobalLock(hMem);
	memcpy(cbText, text.c_str(), text.size());
	cbText[text.size()] = 0;
	GlobalUnlock(hMem);
	SetClipboardData(CF_TEXT, hMem);
	CloseClipboard();
	return true;
	#else
	return FALSE;
	#endif
}
class nvgt_file_dialog_info : public Poco::SynchronizedObject {
public:
	std::string data;
};
void nvgt_file_dialog_callback(void* user, const char* const * files, int filter) {
	if (!files) alert("Open file error", SDL_GetError()); // This will probably change to silently setting an error string or something.
	nvgt_file_dialog_info* fdi = reinterpret_cast<nvgt_file_dialog_info*>(user);
	if (files && *files) fdi->data = *files;
	fdi->notify();
}
enum simple_file_dialog_type {DIALOG_TYPE_OPEN, DIALOG_TYPE_SAVE, DIALOG_TYPE_FOLDER};
std::string simple_file_dialog(const std::string& filters, const std::string& default_location, simple_file_dialog_type type) {
	// We need to parse the filters provided by the user. Format is name:extension_wildcard1;extension_wildcard2|name:ext1;ext2|etc files:etc
	Poco::StringTokenizer filterstrings(filters, "|");
	std::vector<SDL_DialogFileFilter> filter_objects;
	std::vector<std::string> filter_parts; // Welcome to low level programming/c++ communicating with c/Sam being dumb/whatever where we need to keep several null terminated string fragments in memory until this function returns, kinda wish SDL3 just did this parsing for us honestly.
	filter_parts.reserve(filterstrings.count() * 2); // avoid reallocation as items are added
	for (size_t i = 0; i < filterstrings.count(); i++) {
		if (filterstrings[i].find(":") == std::string::npos) continue; // Invalid filter, should we error here or something?
		SDL_DialogFileFilter& f = filter_objects.emplace_back();
		f.name = filter_parts.emplace_back(filterstrings[i].substr(0, filterstrings[i].rfind(":"))).c_str();
		f.pattern = filter_parts.emplace_back(filterstrings[i].substr(filterstrings[i].rfind(":") + 1)).c_str();
	}
	SDL_DialogFileFilter& end = filter_objects.emplace_back(); // Not doing this results in bogus filters at the end of the list in the dialog, I can see why at sdl_dialog_utils.c:62 and might open an issue on sdl's repo about it because either this or filter count, not both?
	end.name = nullptr;
	end.pattern = nullptr;
	nvgt_file_dialog_info fdi;
	if (type == DIALOG_TYPE_OPEN) SDL_ShowOpenFileDialog(nvgt_file_dialog_callback, &fdi, g_WindowHandle, filter_objects.data(), filter_objects.size() -1, default_location.empty()? nullptr : default_location.c_str(), false);
	else if (type == DIALOG_TYPE_SAVE) SDL_ShowSaveFileDialog(nvgt_file_dialog_callback, &fdi, g_WindowHandle, filter_objects.data(), filter_objects.size() -1, default_location.empty()? nullptr : default_location.c_str());
	else if (type == DIALOG_TYPE_FOLDER) SDL_ShowOpenFolderDialog(nvgt_file_dialog_callback, &fdi, g_WindowHandle, default_location.empty()? nullptr : default_location.c_str(), false);
	while (!fdi.tryWait(5)) SDL_PumpEvents();
	return fdi.data;
}
std::string simple_file_open_dialog(const std::string& filters, const std::string& default_location) {
	return simple_file_dialog(filters, default_location, DIALOG_TYPE_OPEN);
}
std::string simple_file_save_dialog(const std::string& filters, const std::string& default_location) {
	return simple_file_dialog(filters, default_location, DIALOG_TYPE_SAVE);
}
std::string simple_folder_select_dialog(const std::string& default_location) {
	return simple_file_dialog("", default_location, DIALOG_TYPE_FOLDER);
}
bool urlopen(const std::string& url) {
	return SDL_OpenURL(url.c_str());
}
void next_keyboard_layout() {
	#ifdef _WIN32
	ActivateKeyboardLayout((HKL)HKL_NEXT, 0);
	#endif
}
std::string input_box(const std::string& title, const std::string& text, const std::string& default_value) {
	#ifdef _WIN32
	std::wstring titleU, textU, defaultU;
	Poco::UnicodeConverter::convert(title, titleU);
	Poco::UnicodeConverter::convert(text, textU);
	Poco::UnicodeConverter::convert(default_value, defaultU);
	std::wstring r = InputBox(titleU, textU, defaultU);
	if (r == L"\xff") {
		g_LastError = -12;
		return "";
	}
	std::string resultA;
	Poco::UnicodeConverter::convert(r, resultA);
	if (g_WindowHandle) SDL_RaiseWindow(g_WindowHandle);
	return resultA;
	#elif defined(__APPLE__)
	std::string r = apple_input_box(title, text, default_value, false, false);
	if (g_WindowHandle) SDL_RaiseWindow(g_WindowHandle);
	if (r == "\xff") {
		g_LastError = -12;
		return "";
	}
	return r;
	#else
	return "";
	#endif
}
bool info_box(const std::string& title, const std::string& text, const std::string& value) {
	#ifdef _WIN32
	std::wstring titleU, textU, valueU;
	Poco::UnicodeConverter::convert(title, titleU);
	Poco::UnicodeConverter::convert(text, textU);
	Poco::UnicodeConverter::convert(value, valueU);
	return InfoBox(titleU, textU, valueU);
	#elif defined(__APPLE__)
	apple_input_box(title, text, value, false, false);
	return true;
	#else
	return false;
	#endif
}

SDL_Window* g_WindowHandle = 0;
#ifdef _WIN32
	HWND g_OSWindowHandle = NULL;
#elif defined(__APPLE__)
	#include "apple.h"
	NSWindow* g_OSWindowHandle = NULL;
#elif defined(__ANDROID__)
	ANativeWindow* g_OSWindowHandle = nullptr;
#else
	void* g_OSWindowHandle = NULL;
#endif
thread_id_t g_WindowThreadId = 0;
bool g_WindowHidden = false;

static std::vector<SDL_Event> post_events; // holds events that should be processed after the next wait() call.
bool set_application_name(const std::string& name) {
	return SDL_SetHintWithPriority(SDL_HINT_APP_NAME, name.c_str(), SDL_HINT_OVERRIDE);
}
bool ShowNVGTWindow(const std::string& window_title) {
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
	g_WindowHandle = SDL_CreateWindow(window_title.c_str(), 640, 640, 0);
	if (!g_WindowHandle) return false;
	if (!SDL_HasScreenKeyboardSupport()) SDL_StartTextInput(g_WindowHandle);
	SDL_PropertiesID window_props = SDL_GetWindowProperties(g_WindowHandle);
	#ifdef _WIN32
	g_OSWindowHandle = (HWND)SDL_GetPointerProperty(window_props, SDL_PROP_WINDOW_WIN32_HWND_POINTER, NULL);
	#elif defined(__APPLE__) // Will probably need to fix for IOS
	g_OSWindowHandle = (NSWindow*)SDL_GetPointerProperty(window_props, SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, NULL);
	SDL_ShowWindow(g_WindowHandle);
	SDL_RaiseWindow(g_WindowHandle);
	voice_over_window_created();
	#elif defined(__ANDROID__)
	g_OSWindowHandle = (ANativeWindow*)SDL_GetPointerProperty(window_props, SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER, NULL);
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
bool WindowIsFocused() {
	if (!g_WindowHandle) return false;
	return g_WindowHandle == SDL_GetKeyboardFocus();
}
bool WindowIsHidden() {
	if (!g_WindowHandle) return false;
	return (SDL_GetWindowFlags(g_WindowHandle) & SDL_WINDOW_HIDDEN) != 0;
}
bool set_window_fullscreen(bool fullscreen) {
	if (!g_WindowHandle) return false;
return SDL_SetWindowFullscreen(g_WindowHandle, fullscreen);
}
std::string get_window_text() {
	if (!g_WindowHandle) return "";
	return std::string(SDL_GetWindowTitle(g_WindowHandle));
}
void* get_window_os_handle() { return reinterpret_cast<void*>(g_OSWindowHandle); }
void handle_sdl_event(SDL_Event* evt) {
		if (InputEvent(evt)) return;
	else if (evt->type == SDL_EVENT_WINDOW_FOCUS_LOST)
		lost_window_focus();
	else if (evt->type == SDL_EVENT_WINDOW_FOCUS_GAINED)
		regained_window_focus();
}
void refresh_window() {
	SDL_PumpEvents();
	SDL_Event evt;
	std::unordered_set<int> keys_pressed_this_frame;
	while (SDL_PollEvent(&evt)) {
		bool evt_handled = false;
		// If a key_down and then a key_up from the same key gets received in one frame, we need to move the key_up to the next frame to make sure that nvgt code can detect the keydown between calls to wait.
		if (evt.type == SDL_EVENT_KEY_DOWN) keys_pressed_this_frame.insert(evt.key.scancode);
		else if (evt.type == SDL_EVENT_KEY_UP && keys_pressed_this_frame.find(evt.key.scancode) != keys_pressed_this_frame.end()) {
			evt_handled = true;
			post_events.push_back(evt);
		}
		if (!evt_handled) handle_sdl_event(&evt);
	}
	if (post_events.size() > 0) {
		for (SDL_Event& e : post_events)
			SDL_PushEvent(&e);
		post_events.clear();
	}
}
void wait(int ms) {
	if (!g_WindowHandle || g_WindowThreadId != thread_current_thread_id()) {
		Poco::Thread::sleep(ms);
		return;
	}
	while (ms >= 0) {
		int MS = (ms > 25 ? 25 : ms);
		if (g_GCMode == 2)
			garbage_collect_action();
		Poco::Thread::sleep(MS);
		SDL_PumpEvents();
		ms -= MS;
		if (ms < 1) break;
	}
	refresh_window();
}


// The following function contributed to NVGT by silak
uint64_t idle_ticks() {
	#ifdef _WIN32
		LASTINPUTINFO lii = { sizeof(LASTINPUTINFO) };
		GetLastInputInfo(&lii);
		DWORD currentTick = GetTickCount();
		return (currentTick - lii.dwTime);
	#elif __APPLE__
		io_iterator_t iter;
		io_registry_entry_t entry;
		CFMutableDictionaryRef matching = IOServiceMatching("IOHIDSystem");
		if (!matching) return -1;
		kern_return_t kr = IOServiceGetMatchingServices(                                                                kIOMainPortDefault, matching, &iter);
		if (kr != KERN_SUCCESS) return -1;
		entry = IOIteratorNext(iter);
		IOObjectRelease(iter);
		if (entry) {
			CFNumberRef obj = (CFNumberRef)IORegistryEntryCreateCFProperty(entry, CFSTR("HIDIdleTime"), kCFAllocatorDefault, 0);
			if (obj) {
				int64_t idleTimeNanoSeconds = 0;
				CFNumberGetValue(obj, kCFNumberSInt64Type, &idleTimeNanoSeconds);
				CFRelease(obj);
				return idleTimeNanoSeconds / 1000000; // Convert nanoseconds to milliseconds
			}
			IOObjectRelease(entry);
		}
		return -1;
	#else
		/* Probably switch this to use dlopen instead of direct linkage at least until we can verify that it safely does not compromise portability.
		Display* dpy = XOpenDisplay(NULL);
		if (!dpy) return -1;
		XScreenSaverInfo info;
		XScreenSaverQueryInfo(dpy, DefaultRootWindow(dpy), &info);
		uint64_t idleTime = info.idle;
		XCloseDisplay(dpy);
		return idleTime;
		*/
		return 0; // currently unsupported
	#endif
}

bool is_console_available() {
	#if defined (_WIN32)
		return Poco::Util::Application::instance().config().hasOption("application.gui")? GetConsoleWindow() != nullptr : true;
	#else
		return isatty(fileno(stdin)) || isatty(fileno(stdout)) || isatty(fileno(stderr));
	#endif
}

bool sdl_set_hint(const std::string& hint, const std::string& value, int priority) { return SDL_SetHintWithPriority(hint.c_str(), value.c_str(), SDL_HintPriority(priority)); }
std::string sdl_get_hint(const std::string& hint) { return SDL_GetHint(hint.c_str()); }

void RegisterUI(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UI);
	engine->RegisterEnum(_O("message_box_flags"));
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_ERROR"), SDL_MESSAGEBOX_ERROR);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_WARNING"), SDL_MESSAGEBOX_WARNING);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_INFORMATION"), SDL_MESSAGEBOX_INFORMATION);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_BUTTONS_LEFT_TO_RIGHT"), SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_BUTTONS_RIGHT_TO_LEFT"), SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT);
	engine->RegisterEnum("sdl_hint_priority");
	engine->RegisterEnumValue("sdl_hint_priority", "SDL_HINT_DEFAULT", SDL_HINT_DEFAULT);
	engine->RegisterEnumValue("sdl_hint_priority", "SDL_HINT_NORMAL", SDL_HINT_NORMAL);
	engine->RegisterEnumValue("sdl_hint_priority", "SDL_HINT_OVERRIDE", SDL_HINT_OVERRIDE);
	engine->RegisterGlobalFunction(_O("bool sdl_set_hint(const string&in hint, const string&in value, int priority = SDL_HINT_NORMAL)"), asFUNCTION(sdl_set_hint), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string sdl_get_hint(const string&in hint)"), asFUNCTION(sdl_get_hint), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int message_box(const string& in title, const string& in message, string[]@ buttons, uint flags = 0)"), asFUNCTION(message_box_script), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int alert(const string &in title, const string &in text, bool can_cancel = false, uint flags = 0)"), asFUNCTION(alert), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int question(const string& in title, const string& in text, bool can_cancel = false, uint flags = 0)"), asFUNCTION(question), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("string clipboard_get_text()"), asFUNCTION(ClipboardGetText), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool clipboard_set_text(const string& in text)"), asFUNCTION(ClipboardSetText), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool clipboard_set_raw_text(const string& in text)"), asFUNCTION(ClipboardSetRawText), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string open_file_dialog(const string &in filters = \"\", const string&in default_location = \"\")"), asFUNCTION(simple_file_open_dialog), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string save_file_dialog(const string &in filters = \"\", const string&in default_location = \"\")"), asFUNCTION(simple_file_save_dialog), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string select_folder_dialog(const string&in default_location = \"\")"), asFUNCTION(simple_folder_select_dialog), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool urlopen(const string &in url)"), asFUNCTION(urlopen), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UI);
	engine->RegisterGlobalFunction(_O("string input_box(const string& in title, const string& in caption, const string& in default_value = '', uint64 flags = 0)"), asFUNCTION(input_box), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool info_box(const string& in title, const string& in caption, const string& in text, uint64 flags = 0)"), asFUNCTION(info_box), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void next_keyboard_layout()"), asFUNCTION(next_keyboard_layout), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool set_application_name(const string& in name)", asFUNCTION(set_application_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool show_window(const string& in title)", asFUNCTION(ShowNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool destroy_window()", asFUNCTION(DestroyNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool hide_window()", asFUNCTION(HideNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool focus_window()", asFUNCTION(FocusNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_window_active()", asFUNCTION(WindowIsFocused), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_window_hidden()", asFUNCTION(WindowIsHidden), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool set_window_fullscreen(bool fullscreen)", asFUNCTION(set_window_fullscreen), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_window_text()", asFUNCTION(get_window_text), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint64 get_window_os_handle()", asFUNCTION(get_window_os_handle), asCALL_CDECL);
	engine->RegisterGlobalFunction("void refresh_window()", asFUNCTION(refresh_window), asCALL_CDECL);
	engine->RegisterGlobalFunction("void wait(int ms)", asFUNCTIONPR(wait, (int), void), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint64 idle_ticks()", asFUNCTION(idle_ticks), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_console_available()", asFUNCTION(is_console_available), asCALL_CDECL);
}
