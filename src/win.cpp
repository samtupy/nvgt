/* win.cpp - code that only gets built when compiling for windows, things like SAPI, keyhooks etc
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

#ifdef _WIN32 // Never include win.h outside of windows builds and this file can be lazy wildcarded into builds.
#define VC_EXTRALEAN

#define NOMINMAX
#include <windows.h>
#include <winuser.h>
#include <windows_process_watcher.h>
#include <thread>
#include <memory>
#include <atomic>
#include <chrono>
#include <fstream>
#include <ctime>
#include <iomanip>
#include <stdexcept>
#include <Poco/AtomicFlag.h>
#include <Poco/UnicodeConverter.h>
#include <UniversalSpeech.h>
#include "win.h"

using namespace std;

void register_native_tts() { tts_engine_register("sapi5", []() -> shared_ptr<tts_engine> { return make_shared<sapi5_engine>(); }); }

sapi5_engine::sapi5_engine() : tts_engine_impl("SAPI5") {
	inst = (sb_sapi *)malloc(sizeof(sb_sapi));
	if (!inst) throw runtime_error("Failed to allocate SAPI5 instance");
	memset(inst, 0, sizeof(sb_sapi));
	if (!sb_sapi_initialise(inst)) {
		free(inst);
		throw runtime_error("Failed to initialize SAPI5 engine");
	}
}
sapi5_engine::~sapi5_engine() {
	if (inst) {
		sb_sapi_cleanup(inst);
		free(inst);
	}
}
bool sapi5_engine::is_available() { return true; }
tts_pcm_generation_state sapi5_engine::get_pcm_generation_state() { return PCM_PREFERRED; }
tts_audio_data* sapi5_engine::speak_to_pcm(const string &text) {
	if (text.empty()) return nullptr;
	void *temp = nullptr;
	int bufsize = 0;
	if (!sb_sapi_speak_to_memory(inst, const_cast<char*>(text.c_str()), &temp, &bufsize)) return nullptr;
	if (!temp || bufsize <= 0) return nullptr;
	return new tts_audio_data(this, temp, bufsize, sb_sapi_get_sample_rate(inst), sb_sapi_get_channels(inst), sb_sapi_get_bit_depth(inst));
}
float sapi5_engine::get_rate() { return sb_sapi_get_rate(inst); }
float sapi5_engine::get_pitch() { return sb_sapi_get_pitch(inst); }
float sapi5_engine::get_volume() { return sb_sapi_get_volume(inst); }
void sapi5_engine::set_rate(float rate) { sb_sapi_set_rate(inst, rate); }
void sapi5_engine::set_pitch(float pitch) { sb_sapi_set_pitch(inst, pitch); }
void sapi5_engine::set_volume(float volume) { sb_sapi_set_volume(inst, volume); }
bool sapi5_engine::get_rate_range(float& minimum, float& midpoint, float& maximum) { minimum = -10; midpoint = 0; maximum = 10; return true; }
bool sapi5_engine::get_pitch_range(float& minimum, float& midpoint, float& maximum) { minimum = -10; midpoint = 0; maximum = 10; return true; }
bool sapi5_engine::get_volume_range(float& minimum, float& midpoint, float& maximum) { minimum = 0; midpoint = 50; maximum = 100; return true; }
int sapi5_engine::get_voice_count() { return inst->voice_count; }
string sapi5_engine::get_voice_name(int index) {
	if (index < 0 || index >= inst->voice_count) return "";
	char *result = sb_sapi_get_voice_name(inst, index);
	return result? string(result) : "";
}
string sapi5_engine::get_voice_language(int index) {
	if (!inst || index < 0 || index >= get_voice_count()) return "";
	char *lang = sb_sapi_get_voice_language(inst, index);
	if (!lang) return "";
	string result(lang);
	free(lang);
	return result;
}
bool sapi5_engine::set_voice(int voice) {
	if (voice < 0 || voice >= inst->voice_count) return false;
	if (!sb_sapi_set_voice(inst, voice)) return false;
	return true;
}
int sapi5_engine::get_current_voice() { return sb_sapi_get_voice(inst); }

static Poco::AtomicFlag g_sr_loaded;
static Poco::AtomicFlag g_sr_available;
bool screen_reader_load() {
	if (g_sr_loaded) return true;
	speechSetValue(SP_ENABLE_NATIVE_SPEECH, 0);
	g_sr_available.set();
	g_sr_loaded.set();
	return true;
}
void screen_reader_unload() {
	if (g_sr_loaded) g_sr_loaded.reset();
}
std::string screen_reader_detect() {
	if (!screen_reader_load()) return "";
	int engine = speechGetValue(SP_ENGINE);
	if (engine < 0) return "";
	const std::wstring srname = speechGetString(SP_ENGINE + engine);
	std::string result;
	Poco::UnicodeConverter::convert(srname, result);
	return result;
}
bool screen_reader_has_speech() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_ENGINE) > -1;
}
bool screen_reader_has_braille() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_ENGINE) > -1;
}
bool screen_reader_is_speaking() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_BUSY) != 0;
}
bool screen_reader_output(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0 && brailleDisplay(textW.c_str()) != 0;
}
bool screen_reader_speak(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0;
}
bool screen_reader_braille(const std::string& text) {
	if (!screen_reader_load()) return false;
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return brailleDisplay(textW.c_str()) != 0;
}
bool screen_reader_silence() {
	if (!screen_reader_load()) return false;
	return speechStop();
}

// Thanks Quentin Cosendey (Universal Speech) for this jaws keyboard hook code as well as to male-srdiecko and silak for various improvements and fixes that have taken place since initial implementation.
bool altPressed = false;
bool capsPressed = false;
bool insertPressed = false;
static HHOOK g_keyhook_hHook = nullptr;
bool g_keyhook_active = false;
static std::unique_ptr<ProcessWatcher> g_process_watcher = nullptr;
static std::thread g_process_watcher_thread;
static std::atomic<bool> g_process_watcher_running{false};
static std::atomic<bool> g_window_focused{false};
static std::atomic<bool> g_jhookldr_process_running{false};
static bool g_keyhook_needs_uninstall = false;
static bool g_keyhook_needs_install = false;
// Used to control/reset various keys, usually insert, when toggling keyhook.
void send_keyboard_input(WORD vk_code, bool key_up) {
	INPUT input = {};
	input.type = INPUT_KEYBOARD;
	input.ki.wVk = vk_code;
	input.ki.dwFlags = key_up ? KEYEVENTF_KEYUP : 0;
	input.ki.time = 0;
	input.ki.dwExtraInfo = 0;
	SendInput(1, &input, sizeof(INPUT));
}
LRESULT CALLBACK HookKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
	if (nCode != HC_ACTION)
		return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
	bool window_focused = g_window_focused.load();
	bool process_running = g_jhookldr_process_running.load();
	// Block keys only if both conditions are met:
	// 1. Our NVGT window is focused
	// 2. jhookldr.exe process is running
	if (!window_focused || !process_running)
		return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
	PKBDLLHOOKSTRUCT p = reinterpret_cast<PKBDLLHOOKSTRUCT>(lParam);
	UINT vkCode = p->vkCode;
	bool altDown = p->flags & LLKHF_ALTDOWN;
	bool keyDown = (p->flags & LLKHF_UP) == 0;
	altPressed = altDown;
	if (vkCode != VK_CAPITAL && vkCode != VK_INSERT && (capsPressed || insertPressed))
		return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
	switch (vkCode) {
		case VK_INSERT:
			insertPressed = keyDown;
			return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
		case VK_CAPITAL:
			capsPressed = keyDown;
			return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
		case VK_NUMLOCK:
		case VK_LCONTROL:
		case VK_RCONTROL:
		case VK_LSHIFT:
		case VK_RSHIFT:
			return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
		default:
			return 0; // Block other keys when window is focused
	}
	return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
}
void process_watcher_thread_func(const std::string& process_name) {
	g_process_watcher = std::make_unique<ProcessWatcher>(process_name);
	int elapsed_time = 10; // Start with fast checking
	bool found_process = false;
	while (g_process_watcher_running.load()) {
		std::this_thread::sleep_for(std::chrono::milliseconds(elapsed_time));
		// Check if hook is still installed.
		if (!g_keyhook_active) break;
		// Process watcher runs independently but only sends commands when window is focused
		if (!g_window_focused.load()) continue;
		// Check if process died.
		if (found_process && !g_process_watcher->monitor()) {
			elapsed_time = 60; // Slow down checking when process is dead
			found_process = false;
			g_jhookldr_process_running.store(false);
			g_keyhook_needs_uninstall = true;
			continue;
		} else if (!found_process) {
			if (g_process_watcher->find()) {
				found_process = true;
				elapsed_time = 10; // Speed up checking when process is found
				g_jhookldr_process_running.store(true);
				g_keyhook_needs_install = true;
			} else g_jhookldr_process_running.store(false);
		} else g_jhookldr_process_running.store(true);
	}
}
bool start_process_watcher(const std::string& process_name) {
	if (g_process_watcher_running.load()) {
		return false; // Already running
	}
	g_process_watcher_running.store(true);
	g_process_watcher_thread = std::thread(process_watcher_thread_func, process_name);
	return true;
}
void stop_process_watcher() {
	if (g_process_watcher_running.load()) {
		g_process_watcher_running.store(false);
		if (g_process_watcher_thread.joinable())
			g_process_watcher_thread.join();
		g_process_watcher.reset();
		g_jhookldr_process_running.store(false);
	}
}
// Function to only reinstall keyhook without affecting process watcher
bool reinstall_keyhook_only() {
	// Remove existing hook
	if (g_keyhook_hHook) {
		UnhookWindowsHookEx(g_keyhook_hHook);
		g_keyhook_hHook = nullptr;
	}
	// Install new hook
	g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
	g_keyhook_active = true;
	if (g_keyhook_hHook) {
		send_keyboard_input(VK_INSERT, true);
		return true;
	} else {
		g_keyhook_active = false;
		return false;
	}
}
bool install_keyhook() {
	if (g_keyhook_hHook)
		uninstall_keyhook();
	g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
	g_keyhook_active = true;
	if (g_keyhook_hHook) {
		send_keyboard_input(VK_INSERT, true);
		// Automatically start process watcher for jhookldr.exe (only on first install)
		if (!g_process_watcher_running.load())
			start_process_watcher("jhookldr.exe");
		return true;
	} else
		return false;
}
void remove_keyhook() {
	if (!g_keyhook_hHook)
		return;
	UnhookWindowsHookEx(g_keyhook_hHook);
	g_keyhook_hHook = nullptr;
}
void uninstall_keyhook() {
	remove_keyhook();
	stop_process_watcher();
	g_keyhook_active = false;
}
// Function to process keyhook commands in main thread.
void process_keyhook_commands() {
	if (g_keyhook_needs_uninstall) {
		g_keyhook_needs_uninstall = false;
		// Process died - actually uninstall hook via WinAPI to prevent JAWS from replacing it
		if (g_keyhook_hHook) {
			UnhookWindowsHookEx(g_keyhook_hHook);
			g_keyhook_hHook = nullptr;
		}
	}
	if (g_keyhook_needs_install) {
		g_keyhook_needs_install = false;
		// Process found - if window is focused and hook not installed, install it
		if (!g_keyhook_hHook && g_window_focused.load()) {
			g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
			if (g_keyhook_hHook)
				send_keyboard_input(VK_INSERT, true);
		}
	}
}
void lost_window_focus_platform() {
	g_window_focused.store(false);
	if (g_keyhook_hHook) {
		UnhookWindowsHookEx(g_keyhook_hHook);
		g_keyhook_hHook = nullptr;
	}
}
void regained_window_focus_platform() {
	g_window_focused.store(true);
	if (!g_keyhook_hHook && g_keyhook_active) {
		g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
		if (g_keyhook_hHook)
			send_keyboard_input(VK_INSERT, true);
	}
}

#endif
