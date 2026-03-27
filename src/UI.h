/* UI.h - header for sdl window management functions and other user interface related routines
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

#pragma once
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#define VC_EXTRALEAN
	#include <windows.h>
#endif
#ifndef NVGT_NATIVE_WINDOW_DEFINED
#define NVGT_NATIVE_WINDOW_DEFINED
#ifdef _WIN32
typedef HWND native_window_t;
#define NATIVE_WINDOW_SDL_PROP SDL_PROP_WINDOW_WIN32_HWND_POINTER
#elif defined(__APPLE__)
#ifndef NVGT_MOBILE
typedef void* native_window_t; // NSWindow*, cast in .mm code
#define NATIVE_WINDOW_SDL_PROP SDL_PROP_WINDOW_COCOA_WINDOW_POINTER
#else
typedef void* native_window_t; // UIWindow*, cast in .mm code
#define NATIVE_WINDOW_SDL_PROP SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER
#endif
#elif defined(__ANDROID__)
typedef void* native_window_t; // ANativeWindow*
#define NATIVE_WINDOW_SDL_PROP SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER
#else
typedef void* native_window_t;
#endif
#endif
#include <angelscript.h>
#include <scriptarray.h>
#include <Poco/AutoPtr.h>
#include <string>
#include <vector>
#include <SDL3/SDL.h>
#include "graphics.h"

int message_box(const std::string& title, const std::string& text, const std::vector < std::string > & buttons, unsigned int mb_flags = 0);
int alert(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
int question(const std::string& title, const std::string& text, bool can_cancel = false, unsigned int flags = 0);
void message(const std::string& text, const std::string& header);
bool info_box(const std::string& title, const std::string& text, const std::string& value);
bool ClipboardSetText(const std::string& text);
std::string simple_file_open_dialog(const std::string& filters = "All files:*", const std::string& default_location = "");
bool urlopen(const std::string& url);
bool is_console_available();

class game_window {
	SDL_Window* _window;
	bool _owns_window; // Set to true if we create window and false otherwise, if false destructor does not destroy SDL_Window.
	native_window_t _native_window;
	Poco::AutoPtr<graphics_renderer> _renderer;
	Poco::AutoPtr<text_font> _font;
	mutable int _refcount;
public:
	game_window(const std::string& title, unsigned int w, unsigned int h, unsigned int flags);
	game_window(SDL_Window* window);
	~game_window();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	SDL_Window* get_sdl_window() const { return _window; }
	native_window_t get_native_window() const { return _native_window; }
	graphics_renderer* get_renderer() { return _renderer.get(); }
	text_font* get_font() { return _font.get(); }
	bool show() { return SDL_ShowWindow(_window); }
	bool hide() { return SDL_HideWindow(_window); }
	bool raise() { return SDL_RaiseWindow(_window); }
	bool maximize() { return SDL_MaximizeWindow(_window); }
	bool minimize() { return SDL_MinimizeWindow(_window); }
	bool restore() { return SDL_RestoreWindow(_window); }
	bool sync() { return SDL_SyncWindow(_window); }
	bool set_fullscreen(bool fullscreen) { return SDL_SetWindowFullscreen(_window, fullscreen); }
	bool set_title(const std::string& title) { return SDL_SetWindowTitle(_window, title.c_str()); }
	std::string get_title() const { return from_cstr(SDL_GetWindowTitle(_window)); }
	unsigned int get_id() const { return SDL_GetWindowID(_window); }
	uint64_t get_flags() const { return SDL_GetWindowFlags(_window); }
	float get_pixel_density() const { return SDL_GetWindowPixelDensity(_window); }
	float get_display_scale() const { return SDL_GetWindowDisplayScale(_window); }
	unsigned int get_pixel_format() const { return (unsigned int)SDL_GetWindowPixelFormat(_window); }
	bool set_bordered(bool bordered) { return SDL_SetWindowBordered(_window, bordered); }
	bool set_resizable(bool resizable) { return SDL_SetWindowResizable(_window, resizable); }
	bool set_always_on_top(bool on_top) { return SDL_SetWindowAlwaysOnTop(_window, on_top); }
	bool set_fill_document(bool fill) { return SDL_SetWindowFillDocument(_window, fill); }
	bool set_modal(bool modal) { return SDL_SetWindowModal(_window, modal); }
	bool set_focusable(bool focusable) { return SDL_SetWindowFocusable(_window, focusable); }
	bool set_keyboard_grab(bool grabbed) { return SDL_SetWindowKeyboardGrab(_window, grabbed); }
	bool get_keyboard_grab() const { return SDL_GetWindowKeyboardGrab(_window); }
	bool set_mouse_grab(bool grabbed) { return SDL_SetWindowMouseGrab(_window, grabbed); }
	bool get_mouse_grab() const { return SDL_GetWindowMouseGrab(_window); }
	bool set_opacity(float opacity) { return SDL_SetWindowOpacity(_window, opacity); }
	float get_opacity() const { return SDL_GetWindowOpacity(_window); }
	bool flash(unsigned int operation) { return SDL_FlashWindow(_window, (SDL_FlashOperation)operation); }
	bool show_system_menu(int x, int y) { return SDL_ShowWindowSystemMenu(_window, x, y); }
	bool set_icon(graphic* icon) { return icon && SDL_SetWindowIcon(_window, icon->get_surface()); }
	bool get_position(int& x, int& y) const { return SDL_GetWindowPosition(_window, &x, &y); }
	bool set_position(int x, int y) { return SDL_SetWindowPosition(_window, x, y); }
	bool get_size(int& w, int& h) const { return SDL_GetWindowSize(_window, &w, &h); }
	bool set_size(int w, int h) { return SDL_SetWindowSize(_window, w, h); }
	bool get_size_in_pixels(int& w, int& h) const { return SDL_GetWindowSizeInPixels(_window, &w, &h); }
	bool get_minimum_size(int& w, int& h) const { return SDL_GetWindowMinimumSize(_window, &w, &h); }
	bool set_minimum_size(int w, int h) { return SDL_SetWindowMinimumSize(_window, w, h); }
	bool get_maximum_size(int& w, int& h) const { return SDL_GetWindowMaximumSize(_window, &w, &h); }
	bool set_maximum_size(int w, int h) { return SDL_SetWindowMaximumSize(_window, w, h); }
	bool get_aspect_ratio(float& min_aspect, float& max_aspect) const { return SDL_GetWindowAspectRatio(_window, &min_aspect, &max_aspect); }
	bool set_aspect_ratio(float min_aspect, float max_aspect) { return SDL_SetWindowAspectRatio(_window, min_aspect, max_aspect); }
	bool get_borders_size(int& top, int& left, int& bottom, int& right) const { return SDL_GetWindowBordersSize(_window, &top, &left, &bottom, &right); }
	bool has_surface() const { return SDL_WindowHasSurface(_window); }
	bool update_surface() { return SDL_UpdateWindowSurface(_window); }
	bool destroy_surface() { return SDL_DestroyWindowSurface(_window); }
	bool set_surface_vsync(int vsync) { return SDL_SetWindowSurfaceVSync(_window, vsync); }
	bool get_surface_vsync(int& vsync) const { return SDL_GetWindowSurfaceVSync(_window, &vsync); }
	bool set_progress_state(unsigned int state) { return SDL_SetWindowProgressState(_window, (SDL_ProgressState)state); }
	unsigned int get_progress_state() const { return (unsigned int)SDL_GetWindowProgressState(_window); }
	bool set_progress_value(float value) { return SDL_SetWindowProgressValue(_window, value); }
	float get_progress_value() const { return SDL_GetWindowProgressValue(_window); }
	void set_font(text_font* font) { if (font) font->duplicate(); _font = font; }
	// high-level drawing, Much of this is heavily enspired and/or copied with permission from @aryanchoudharypro's NVGT graphics plugin at https://github.com/aryanchoudharypro/power-plugins-for-nvgt
	bool clear(unsigned int r, unsigned int g, unsigned int b);
	bool present() { return _renderer && _renderer->present(); }
	void draw_text(const std::string& text, float x, float y, unsigned int r, unsigned int g, unsigned int b);
	uint64_t measure_text(const std::string& text) const;
	void draw_text_wrapped(const std::string& text, float x, float y, int wrap_width, unsigned int r, unsigned int g, unsigned int b);
	uint64_t measure_text_wrapped(const std::string& text, int wrap_width) const;
	void draw_rect(float x, float y, float w, float h, unsigned int r, unsigned int g, unsigned int b, bool filled = false);
	void draw_circle(float cx, float cy, int radius, unsigned int r, unsigned int g, unsigned int b, bool filled = false);
	void draw_line(float x1, float y1, float x2, float y2, unsigned int r, unsigned int g, unsigned int b);
	bool render_graphic(graphic* gfx, float x, float y) { return _renderer && _renderer->render_graphic(gfx, x, y); }
	void draw_menu(CScriptArray* items, float x, float y);
};

extern Poco::AutoPtr<game_window> g_window;

enum system_tray_menu_item_type { SYSTEM_TRAY_ITEM, SYSTEM_TRAY_CHECKBOX, SYSTEM_TRAY_SEPARATOR, SYSTEM_TRAY_SUBMENU };

class system_tray_menu_item;
class system_tray_menu;
class system_tray;

class system_tray_menu_item {
	SDL_TrayEntry* _entry;
	Poco::AutoPtr<system_tray_menu> _submenu; // lazily created when get_submenu() is first called on a SYSTEM_TRAY_SUBMENU item
	asIScriptFunction* _callback;
	system_tray_menu_item_type _type;
	mutable int _refcount;
public:
	system_tray_menu_item(SDL_TrayEntry* entry, system_tray_menu_item_type type);
	~system_tray_menu_item(); // defined in .cpp so that system_tray_menu is complete there
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	SDL_TrayEntry* get_sdl_entry() const { return _entry; }
	bool is_valid() const { return _entry != nullptr; }
	void invalidate() { _entry = nullptr; } // called by system_tray_menu::remove_entry
	system_tray_menu_item_type get_type() const { return _type; }
	void set_label(const std::string& label) { if (_entry) SDL_SetTrayEntryLabel(_entry, label.c_str()); }
	std::string get_label() const { return _entry ? from_cstr(SDL_GetTrayEntryLabel(_entry)) : ""; }
	void set_checked(bool checked) { if (_entry) SDL_SetTrayEntryChecked(_entry, checked); }
	bool get_checked() const { return _entry && SDL_GetTrayEntryChecked(_entry); }
	void set_enabled(bool enabled) { if (_entry) SDL_SetTrayEntryEnabled(_entry, enabled); }
	bool get_enabled() const { return _entry && SDL_GetTrayEntryEnabled(_entry); }
	void click() { if (_entry) SDL_ClickTrayEntry(_entry); }
	void set_callback(asIScriptFunction* func);
	void invoke_callback();
	system_tray_menu* get_submenu(); // returns nullptr unless type is SYSTEM_TRAY_SUBMENU
};

class system_tray_menu {
	SDL_TrayMenu* _menu;
	std::vector<Poco::AutoPtr<system_tray_menu_item>> _items;
	mutable int _refcount;
	system_tray_menu_item* make_entry(int pos, const char* label, SDL_TrayEntryFlags flags, system_tray_menu_item_type type);
public:
	system_tray_menu(SDL_TrayMenu* menu);
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	SDL_TrayMenu* get_sdl_menu() const { return _menu; }
	system_tray_menu_item* insert_item(const std::string& label, asIScriptFunction* callback = nullptr, bool disabled = false, int pos = -1);
	system_tray_menu_item* insert_checkbox(const std::string& label, bool checked = false, asIScriptFunction* callback = nullptr, bool disabled = false, int pos = -1);
	system_tray_menu_item* insert_submenu(const std::string& label, bool disabled = false, int pos = -1);
	system_tray_menu_item* insert_separator(int pos = -1);
	system_tray_menu_item* find_item(SDL_TrayEntry* entry);
	void remove_entry(system_tray_menu_item* item);
	int get_entry_count() const;
	CScriptArray* get_entries();
};

class system_tray {
	SDL_Tray* _tray;
	Poco::AutoPtr<system_tray_menu> _menu; // lazily created when get_menu() is first called
	mutable int _refcount;
public:
	system_tray(const std::string& tooltip, graphic* icon);
	~system_tray();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	bool is_valid() const { return _tray != nullptr; }
	void set_icon(graphic* icon) { if (_tray) SDL_SetTrayIcon(_tray, icon ? icon->get_surface() : nullptr); }
	void set_tooltip(const std::string& tooltip) { if (_tray) SDL_SetTrayTooltip(_tray, tooltip.empty() ? nullptr : tooltip.c_str()); }
	system_tray_menu* get_menu();
};

game_window* ShowNVGTWindow(const std::string& window_title, unsigned int flags = 0);
bool DestroyNVGTWindow();
bool WindowIsFocused();
int get_window_width();
int get_window_height();
void refresh_window();
void wait(int ms);
void RegisterUI(asIScriptEngine* engine);
