/* UI.cpp - Various user interface routines and code for the management of an sdl window
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <angelscript.h>
#include "tts.h"
#include "xplatform.h"
#ifdef _WIN32
	#include "win.h"
	#include "InputBox.h"
#elif defined(__APPLE__)
	#include <IOKit/IOKitLib.h>
	#ifndef NVGT_MOBILE
	#include <IOKit/IOCFBundle.h>
	#endif
	#include <CoreFoundation/CoreFoundation.h>
	#include "apple.h"
#elif defined(__ANDROID__)
	#include <android/native_window.h>
	#include <jni.h>
	#include <stdexcept>
	#include "android.h"
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
#include <Poco/Environment.h>
#include <Poco/Platform.h>
#include <Poco/UnicodeConverter.h>
#include <Poco/Util/Application.h>
#include <Poco/Format.h>
#include "input.h"
#include "misc_functions.h"
#include "scriptstuff.h"
#include "timestuff.h"
#include "UI.h"
#if defined(__APPLE__) || (!defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))) || defined(__ANDROID__)
	#include <unistd.h>
	#include <cstdio>
#endif
#include "anticheat.h"

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
	SDL_MessageBoxData box = {mb_flags, g_window ? g_window->get_sdl_window() : nullptr, title.c_str(), text.c_str(), int(sdlbuttons.size()), sdlbuttons.data(), NULL};
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
	SDL_Window* parent_window = g_window ? g_window->get_sdl_window() : nullptr;
#ifdef _WIN32
	parent_window = nullptr; // Passing nullptr for the parent window on Windows prevents the OS from attaching the background thread's input queue to the main thread's, And it seems to fix the extreme lag in the open and save as dialogs As the wait(5); doesn't effect the dialogs. 
#endif
	if (type == DIALOG_TYPE_OPEN) SDL_ShowOpenFileDialog(nvgt_file_dialog_callback, &fdi, parent_window, filter_objects.data(), filter_objects.size() - 1, default_location.empty() ? nullptr : default_location.c_str(), false);
	else if (type == DIALOG_TYPE_SAVE) SDL_ShowSaveFileDialog(nvgt_file_dialog_callback, &fdi, parent_window, filter_objects.data(), filter_objects.size() - 1, default_location.empty() ? nullptr : default_location.c_str());
	else if (type == DIALOG_TYPE_FOLDER) SDL_ShowOpenFolderDialog(nvgt_file_dialog_callback, &fdi, parent_window, default_location.empty() ? nullptr : default_location.c_str(), false);
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
	if (g_window) g_window->raise();
	return resultA;
	#elif defined(__APPLE__)
	std::string r = apple_input_box(title, text, default_value, false, false);
	if (g_window) g_window->raise();
	if (r == "\xff") {
		g_LastError = -12;
		return "";
	}
	return r;
	#elif defined(__ANDROID__)
	return android_input_box(title, text, default_value);
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
	#elif defined(__ANDROID__)
	return android_info_box(title, text, value);
	#else
	return false;
	#endif
}

game_window::game_window(const std::string& title, unsigned int w, unsigned int h, unsigned int flags) : _window(nullptr), _owns_window(true), _native_window(nullptr), _refcount(1) {
	if (Poco::Environment::os() == POCO_OS_LINUX) flags |= SDL_WINDOW_FULLSCREEN;
	_window = SDL_CreateWindow(title.c_str(), (int)w, (int)h, flags);
	if (!_window) return;
	_renderer = new graphics_renderer(this);
	if (!SDL_HasScreenKeyboardSupport()) SDL_StartTextInput(_window);
	SDL_PropertiesID props = SDL_GetWindowProperties(_window);
	#ifdef NATIVE_WINDOW_SDL_PROP
	_native_window = (native_window_t)SDL_GetPointerProperty(props, NATIVE_WINDOW_SDL_PROP, nullptr);
	#endif
	#ifdef __APPLE__
	SDL_ShowWindow(_window);
	SDL_RaiseWindow(_window);
	voice_over_window_created(this);
	#endif
}
game_window::game_window(SDL_Window* window) : _window(window), _owns_window(false), _native_window(nullptr), _refcount(1) {
	if (!_window) return;
	_renderer = new graphics_renderer(this);
	SDL_PropertiesID props = SDL_GetWindowProperties(_window);
	#ifdef NATIVE_WINDOW_SDL_PROP
	_native_window = (native_window_t)SDL_GetPointerProperty(props, NATIVE_WINDOW_SDL_PROP, nullptr);
	#endif
}
game_window::~game_window() {
	_font = nullptr;
	_renderer = nullptr;
	if (_owns_window && _window) SDL_DestroyWindow(_window);
}
bool game_window::clear(unsigned int r, unsigned int g, unsigned int b) {
	if (!_renderer) return false;
	_renderer->set_draw_color(r, g, b, 255);
	return _renderer->clear();
}
void game_window::draw_text(const std::string& text, float x, float y, unsigned int r, unsigned int g, unsigned int b) {
	if (!_renderer || !_font || text.empty()) return;
	Poco::AutoPtr<graphic> surf(_font->render_text_blended(text, r, g, b));
	if (surf && surf->is_valid()) _renderer->render_graphic(surf.get(), x, y);
}
uint64_t game_window::measure_text(const std::string& text) const {
	if (!_font) return 0;
	int w = 0, h = 0;
	_font->get_string_size(text, w, h);
	return ((uint64_t)w << 32) | (uint32_t)h;
}
void game_window::draw_text_wrapped(const std::string& text, float x, float y, int wrap_width, unsigned int r, unsigned int g, unsigned int b) {
	if (!_renderer || !_font || text.empty()) return;
	Poco::AutoPtr<graphic> surf(_font->render_text_blended_wrapped(text, wrap_width, r, g, b));
	if (surf && surf->is_valid()) _renderer->render_graphic(surf.get(), x, y);
}
uint64_t game_window::measure_text_wrapped(const std::string& text, int wrap_width) const {
	if (!_font) return 0;
	int w = 0, h = 0;
	_font->get_string_size_wrapped(text, wrap_width, w, h);
	return ((uint64_t)w << 32) | (uint32_t)h;
}
void game_window::draw_rect(float x, float y, float w, float h, unsigned int r, unsigned int g, unsigned int b, bool filled) {
	if (!_renderer) return;
	_renderer->set_draw_color(r, g, b, 255);
	if (filled) _renderer->fill_rect(x, y, w, h);
	else _renderer->draw_rect(x, y, w, h);
}
void game_window::draw_line(float x1, float y1, float x2, float y2, unsigned int r, unsigned int g, unsigned int b) {
	if (!_renderer) return;
	_renderer->set_draw_color(r, g, b, 255);
	_renderer->draw_line(x1, y1, x2, y2);
}
void game_window::draw_circle(float cx, float cy, int radius, unsigned int r, unsigned int g, unsigned int b, bool filled) {
	if (!_renderer) return;
	_renderer->set_draw_color(r, g, b, 255);
	SDL_Renderer* rend = _renderer->get_renderer();
	int offsetx = 0, offsety = radius, d = radius - 1, status = 0;
	while (offsety >= offsetx) {
		if (filled) {
			SDL_RenderLine(rend, cx - offsety, cy + offsetx, cx + offsety, cy + offsetx);
			SDL_RenderLine(rend, cx - offsetx, cy + offsety, cx + offsetx, cy + offsety);
			SDL_RenderLine(rend, cx - offsetx, cy - offsety, cx + offsetx, cy - offsety);
			SDL_RenderLine(rend, cx - offsety, cy - offsetx, cx + offsety, cy - offsetx);
		} else {
			SDL_RenderPoint(rend, cx + offsetx, cy + offsety);
			SDL_RenderPoint(rend, cx + offsety, cy + offsetx);
			SDL_RenderPoint(rend, cx - offsetx, cy + offsety);
			SDL_RenderPoint(rend, cx - offsety, cy + offsetx);
			SDL_RenderPoint(rend, cx + offsetx, cy - offsety);
			SDL_RenderPoint(rend, cx + offsety, cy - offsetx);
			SDL_RenderPoint(rend, cx - offsetx, cy - offsety);
			SDL_RenderPoint(rend, cx - offsety, cy - offsetx);
		}
		if (status >= 2 * offsetx) { status -= 2 * offsetx + 1; offsetx++; }
		else if (d < 2 * radius) { status += 2 * offsety - 1; offsety--; }
		else { status -= 2 * (offsetx - offsety + 1); offsety--; offsetx++; }
	}
}
void game_window::draw_menu(CScriptArray* items, float x, float y) {
	if (!_renderer || !_font || !items) return;
	int w = 0, h = 0;
	_font->get_string_size("A", w, h);
	float line_height = (float)(h + 10);
	float current_y = y;
	for (unsigned int i = 0; i < items->GetSize(); i++) {
		std::string item = *(std::string*)items->At(i);
		bool selected = !item.empty() && item[0] == '*';
		if (selected) item = item.substr(1);
		_font->get_string_size(item, w, h);
		float text_x = x - (float)(w / 2);
		if (selected) {
			draw_rect(text_x - 10, current_y, (float)(w + 20), line_height, 50, 50, 50, true);
			draw_text(item, text_x, current_y + 5, 255, 255, 0);
		} else {
			draw_text(item, text_x, current_y + 5, 200, 200, 200);
		}
		current_y += line_height;
	}
}

Poco::AutoPtr<game_window> g_window;
thread_id_t g_WindowThreadId = 0;

static std::vector<SDL_Event> post_events; // holds events that should be processed after the next wait() call.
bool set_application_name(const std::string& name) {
	return SDL_SetHintWithPriority(SDL_HINT_APP_NAME, name.c_str(), SDL_HINT_OVERRIDE);
}
game_window* ShowNVGTWindow(const std::string& window_title, unsigned int flags) {
	if (g_window) {
		g_window->set_title(window_title);
		if (g_window->get_flags() & SDL_WINDOW_HIDDEN) {
			g_window->show();
			g_window->raise();
		}
		g_window->duplicate();
		return g_window.get();
	}
	InputInit();
	TTF_Init();
	g_window = new game_window(window_title, 640, 640, flags);
	if (!g_window->get_sdl_window()) {
		g_window = nullptr;
		return nullptr;
	}
	g_WindowThreadId = thread_current_thread_id();
	g_window->duplicate();
	return g_window.get();
}
bool DestroyNVGTWindow() {
	if (!g_window) return false;
	InputDestroy();
	TTF_Quit();	
	g_window = nullptr;
	return true;
}
bool HideNVGTWindow() {
	if (!g_window) return false;
	g_window->hide();
	return true;
}
bool FocusNVGTWindow() {
	if (!g_window) return false;
	g_window->raise();
	return true;
}
bool WindowIsFocused() {
#ifdef __ANDROID__
	return android_is_window_active();
#else
	return g_window && g_window->get_sdl_window() == SDL_GetKeyboardFocus();
#endif
}
bool WindowIsHidden() {
	return g_window && (g_window->get_flags() & SDL_WINDOW_HIDDEN) != 0;
}
bool set_window_fullscreen(bool fullscreen) {
	return g_window && g_window->set_fullscreen(fullscreen);
}
int get_window_width() {
	if (!g_window) return 0;
	int w, h;
	g_window->get_size(w, h);
	return w;
}
int get_window_height() {
	if (!g_window) return 0;
	int w, h;
	g_window->get_size(w, h);
	return h;
}
std::string get_window_text() {
	return g_window ? g_window->get_title() : "";
}
void* get_window_os_handle() {
	return g_window ? reinterpret_cast<void*>(g_window->get_native_window()) : nullptr;
}
game_window* get_window() { return g_window.get(); }
void handle_sdl_event(SDL_Event* evt) {
	if (InputEvent(evt)) return;
	else if (evt->type == SDL_EVENT_WINDOW_FOCUS_LOST) lost_window_focus();
	else if (evt->type == SDL_EVENT_WINDOW_FOCUS_GAINED) regained_window_focus();
}
void refresh_window() {
	anticheat_check();
	#ifdef _WIN32
	process_keyhook_commands();
	#endif
	SDL_PumpEvents();
	update_joysticks(); // Update all active joystick instances
	if (g_window && g_window->get_renderer()) g_window->get_renderer()->present();
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
	anticheat_check();
	if (!g_window || g_WindowThreadId != thread_current_thread_id()) {
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
	kern_return_t kr = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iter);
	if (kr != KERN_SUCCESS) return -1;
	entry = IOIteratorNext(iter);
	IOObjectRelease(iter);
	if (entry) {
		CFNumberRef obj = (CFNumberRef)IORegistryEntryCreateCFProperty(entry, CFSTR("HIDIdleTime"), kCFAllocatorDefault, 0);
		if (obj) {
			int64_t idleTimeNanoSeconds = 0;
			CFNumberGetValue(obj, kCFNumberSInt64Type, &idleTimeNanoSeconds);
			CFRelease(obj);
			return idleTimeNanoSeconds / 1000000;
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
	return Poco::Util::Application::instance().config().hasOption("application.gui") ? GetConsoleWindow() != nullptr : true;
	#else
	return isatty(fileno(stdin)) || isatty(fileno(stdout)) || isatty(fileno(stderr));
	#endif
}

bool sdl_set_hint(const std::string& hint, const std::string& value, int priority) {
	return SDL_SetHintWithPriority(hint.c_str(), value.c_str(), SDL_HintPriority(priority));
}
std::string sdl_get_hint(const std::string& hint) {
	return SDL_GetHint(hint.c_str());
}

static game_window* game_window_factory(const std::string& title, unsigned int w, unsigned int h, unsigned int flags) { return new game_window(title, w, h, flags); }

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
	engine->RegisterEnum("window_flags");
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_FULLSCREEN", SDL_WINDOW_FULLSCREEN);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_RESIZABLE", SDL_WINDOW_RESIZABLE);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_MAXIMIZED", SDL_WINDOW_MAXIMIZED);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_MINIMIZED", SDL_WINDOW_MINIMIZED);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_HIDDEN", SDL_WINDOW_HIDDEN);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_BORDERLESS", SDL_WINDOW_BORDERLESS);
	engine->RegisterEnumValue("window_flags", "WINDOW_FLAG_ALWAYS_ON_TOP", SDL_WINDOW_ALWAYS_ON_TOP);
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
	engine->RegisterEnum("window_flash_operation");
	engine->RegisterEnumValue("window_flash_operation", "FLASH_CANCEL", SDL_FLASH_CANCEL);
	engine->RegisterEnumValue("window_flash_operation", "FLASH_BRIEFLY", SDL_FLASH_BRIEFLY);
	engine->RegisterEnumValue("window_flash_operation", "FLASH_UNTIL_FOCUSED", SDL_FLASH_UNTIL_FOCUSED);
	engine->RegisterEnum("window_progress_state");
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_INVALID", SDL_PROGRESS_STATE_INVALID);
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_NONE", SDL_PROGRESS_STATE_NONE);
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_INDETERMINATE", SDL_PROGRESS_STATE_INDETERMINATE);
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_NORMAL", SDL_PROGRESS_STATE_NORMAL);
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_PAUSED", SDL_PROGRESS_STATE_PAUSED);
	engine->RegisterEnumValue("window_progress_state", "PROGRESS_STATE_ERROR", SDL_PROGRESS_STATE_ERROR);
	// game_window
	engine->RegisterObjectType("game_window", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("game_window", asBEHAVE_ADDREF, "void f()", asMETHOD(game_window, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("game_window", asBEHAVE_RELEASE, "void f()", asMETHOD(game_window, release), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("game_window", asBEHAVE_FACTORY, "game_window@ f(const string&in title, uint w, uint h, uint flags = 0)", asFUNCTION(game_window_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("game_window", "bool show()", asMETHOD(game_window, show), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool hide()", asMETHOD(game_window, hide), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool raise()", asMETHOD(game_window, raise), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool maximize()", asMETHOD(game_window, maximize), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool minimize()", asMETHOD(game_window, minimize), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool restore()", asMETHOD(game_window, restore), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool sync()", asMETHOD(game_window, sync), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_fullscreen(bool fullscreen)", asMETHOD(game_window, set_fullscreen), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_title(const string&in title)", asMETHOD(game_window, set_title), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "string get_title() const property", asMETHOD(game_window, get_title), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint get_id() const property", asMETHOD(game_window, get_id), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint64 get_flags() const property", asMETHOD(game_window, get_flags), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "float get_pixel_density() const property", asMETHOD(game_window, get_pixel_density), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "float get_display_scale() const property", asMETHOD(game_window, get_display_scale), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint get_pixel_format() const property", asMETHOD(game_window, get_pixel_format), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_bordered(bool bordered)", asMETHOD(game_window, set_bordered), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_resizable(bool resizable)", asMETHOD(game_window, set_resizable), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_always_on_top(bool on_top)", asMETHOD(game_window, set_always_on_top), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_fill_document(bool fill)", asMETHOD(game_window, set_fill_document), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_modal(bool modal)", asMETHOD(game_window, set_modal), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_focusable(bool focusable)", asMETHOD(game_window, set_focusable), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_keyboard_grab(bool grabbed)", asMETHOD(game_window, set_keyboard_grab), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_keyboard_grab() const property", asMETHOD(game_window, get_keyboard_grab), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_mouse_grab(bool grabbed)", asMETHOD(game_window, set_mouse_grab), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_mouse_grab() const property", asMETHOD(game_window, get_mouse_grab), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_opacity(float opacity)", asMETHOD(game_window, set_opacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "float get_opacity() const property", asMETHOD(game_window, get_opacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool flash(uint operation)", asMETHOD(game_window, flash), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool show_system_menu(int x, int y)", asMETHOD(game_window, show_system_menu), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_icon(graphic@+ icon)", asMETHOD(game_window, set_icon), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_position(int&out x, int&out y) const", asMETHOD(game_window, get_position), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_position(int x, int y)", asMETHOD(game_window, set_position), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_size(int&out w, int&out h) const", asMETHOD(game_window, get_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_size(int w, int h)", asMETHOD(game_window, set_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_size_in_pixels(int&out w, int&out h) const", asMETHOD(game_window, get_size_in_pixels), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_minimum_size(int&out w, int&out h) const", asMETHOD(game_window, get_minimum_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_minimum_size(int w, int h)", asMETHOD(game_window, set_minimum_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_maximum_size(int&out w, int&out h) const", asMETHOD(game_window, get_maximum_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_maximum_size(int w, int h)", asMETHOD(game_window, set_maximum_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_aspect_ratio(float&out min_aspect, float&out max_aspect) const", asMETHOD(game_window, get_aspect_ratio), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_aspect_ratio(float min_aspect, float max_aspect)", asMETHOD(game_window, set_aspect_ratio), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_borders_size(int&out top, int&out left, int&out bottom, int&out right) const", asMETHOD(game_window, get_borders_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_has_surface() const property", asMETHOD(game_window, has_surface), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool update_surface()", asMETHOD(game_window, update_surface), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool destroy_surface()", asMETHOD(game_window, destroy_surface), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_surface_vsync(int vsync)", asMETHOD(game_window, set_surface_vsync), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool get_surface_vsync(int&out vsync) const", asMETHOD(game_window, get_surface_vsync), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_progress_state(uint state)", asMETHOD(game_window, set_progress_state), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint get_progress_state() const property", asMETHOD(game_window, get_progress_state), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool set_progress_value(float value)", asMETHOD(game_window, set_progress_value), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "float get_progress_value() const property", asMETHOD(game_window, get_progress_value), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void set_font(text_font@+ font) property", asMETHOD(game_window, set_font), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "graphics_renderer@+ get_renderer() property", asMETHOD(game_window, get_renderer), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "text_font@+ get_font() property", asMETHOD(game_window, get_font), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool clear(uint r, uint g, uint b)", asMETHOD(game_window, clear), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool present()", asMETHOD(game_window, present), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_text(const string&in text, float x, float y, uint r, uint g, uint b)", asMETHOD(game_window, draw_text), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint64 measure_text(const string&in text) const", asMETHOD(game_window, measure_text), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_text_wrapped(const string&in text, float x, float y, int wrap_width, uint r, uint g, uint b)", asMETHOD(game_window, draw_text_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint64 measure_text_wrapped(const string&in text, int wrap_width) const", asMETHOD(game_window, measure_text_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_rect(float x, float y, float w, float h, uint r, uint g, uint b, bool filled = false)", asMETHOD(game_window, draw_rect), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_circle(float cx, float cy, int radius, uint r, uint g, uint b, bool filled = false)", asMETHOD(game_window, draw_circle), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_line(float x1, float y1, float x2, float y2, uint r, uint g, uint b)", asMETHOD(game_window, draw_line), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "bool render_graphic(graphic@+ gfx, float x, float y)", asMETHOD(game_window, render_graphic), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "void draw_menu(string[]@ items, float x, float y)", asMETHOD(game_window, draw_menu), asCALL_THISCALL);
	engine->RegisterObjectMethod("game_window", "uint64 get_native_window() const property", asMETHOD(game_window, get_native_window), asCALL_THISCALL);
	engine->RegisterGlobalFunction("game_window@ show_window(const string& in title, uint flags = 0)", asFUNCTION(ShowNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool destroy_window()", asFUNCTION(DestroyNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool hide_window()", asFUNCTION(HideNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool focus_window()", asFUNCTION(FocusNVGTWindow), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_window_active()", asFUNCTION(WindowIsFocused), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_window_hidden()", asFUNCTION(WindowIsHidden), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool set_window_fullscreen(bool fullscreen)", asFUNCTION(set_window_fullscreen), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_window_width()", asFUNCTION(get_window_width), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_window_height()", asFUNCTION(get_window_height), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_window_text()", asFUNCTION(get_window_text), asCALL_CDECL);
	engine->RegisterGlobalFunction("game_window@+ get_window() property", asFUNCTION(get_window), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint64 get_window_os_handle()", asFUNCTION(get_window_os_handle), asCALL_CDECL);
	engine->RegisterGlobalFunction("void refresh_window()", asFUNCTION(refresh_window), asCALL_CDECL);
	engine->RegisterGlobalFunction("void wait(int ms)", asFUNCTIONPR(wait, (int), void), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint64 idle_ticks()", asFUNCTION(idle_ticks), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_console_available()", asFUNCTION(is_console_available), asCALL_CDECL);
}
