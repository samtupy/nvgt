/* input.cpp - human input handling code, or in otherwords an SDL2 wrapper
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

#if defined(_WIN32)
	#define VC_EXTRALEAN
	#include <windows.h>
	#include <winuser.h>
#else
	#include <cstring>
#endif
#include <SDL3/SDL.h>
#include <SDL3/SDL_power.h>
#include <angelscript.h>
#include <obfuscate.h>
#include <Poco/Mutex.h>
#include <sstream>
#include <string>
#include <unordered_map>
#include <functional>
#include <vector>
#include <algorithm>
#include "nvgt_angelscript.h"
#include "input.h"
#include "misc_functions.h"
#include "nvgt.h"
#include "UI.h"
#ifdef _WIN32
	#include <windows_process_watcher.h>
	#include <thread>
	#include <memory>
	#include <atomic>
	#include <chrono>
	#include <fstream>
	#include <ctime>
	#include <iomanip>
#endif

/*
 * @literary: Since SDL requires pointer to the key name stay till the program life span,
 * following map variable makes this possible.
 */
static std::unordered_map<unsigned int, std::string> g_KeyNames;
static unsigned char g_KeysPressed[SDL_SCANCODE_COUNT];
static unsigned char g_KeysRepeating[SDL_SCANCODE_COUNT];
static unsigned char g_KeysForced[SDL_SCANCODE_COUNT];
static const bool* g_KeysDown = NULL;
static int g_KeysDownArrayLen = 0;
static unsigned char g_KeysReleased[SDL_SCANCODE_COUNT];
static unsigned char g_MouseButtonsPressed[32];
static unsigned char g_MouseButtonsReleased[32];
std::string g_UserInput = "";
float g_MouseX = 0, g_MouseY = 0, g_MouseZ = 0;
float g_MouseAbsX = 0, g_MouseAbsY = 0, g_MouseAbsZ = 0;
float g_MousePrevX = 0, g_MousePrevY = 0, g_MousePrevZ = 0;
bool g_KeyboardStateChange = false;
SDL_TouchID g_TouchLastDevice = 0;
static asITypeInfo* key_code_array_type = nullptr;
static asITypeInfo* joystick_mapping_array_type = nullptr;
#ifdef _WIN32
// prerequisits for keyhook by Silak
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
#endif
// Wrapper function for sdl
// This function is useful for getting keyboard, mice and touch devices.
// Pass the callback with the signature `unsigned int*(int*)`
CScriptArray* GetDevices(std::function<uint32_t* (int*)> callback) {
	asITypeInfo* array_type = get_array_type("uint[]");
	if (!array_type)
		return nullptr;
	int device_count = 0;
	uint32_t* devices = callback(&device_count);
	if (!devices)
		return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) {
		SDL_free(devices);
		return nullptr;
	}
	array->Reserve(device_count);
	for (int i = 0; i < device_count; i++)
		array->InsertLast(devices + i);
	SDL_free(devices);
	return array;
}
void InputInit() {
	if (SDL_WasInit(0) & SDL_INIT_VIDEO)
		return;
	memset(g_KeysPressed, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysRepeating, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysForced, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysReleased, 0, SDL_SCANCODE_COUNT);
	// Initialize video and joystick/gamepad if not already initialized
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMEPAD | SDL_INIT_JOYSTICK);
	g_KeysDown = SDL_GetKeyboardState(&g_KeysDownArrayLen);
}
void InputDestroy() {
	if (!(SDL_WasInit(0) & SDL_INIT_VIDEO))
		return;
	#ifdef _WIN32
	uninstall_keyhook();
	#endif
	SDL_Quit();
	g_KeysDown = NULL;
}
bool InputEvent(SDL_Event* evt) {
	if (evt->type == SDL_EVENT_KEY_DOWN) {
		if (!evt->key.repeat)
			g_KeysPressed[evt->key.scancode] = 1;
		else
			g_KeysRepeating[evt->key.scancode] = 1;
		g_KeysReleased[evt->key.scancode] = 0;
		if (!evt->key.repeat)
			g_KeyboardStateChange = true;
	} else if (evt->type == SDL_EVENT_KEY_UP) {
		g_KeysPressed[evt->key.scancode] = 0;
		g_KeysRepeating[evt->key.scancode] = 0;
		g_KeysReleased[evt->key.scancode] = 1;
		g_KeyboardStateChange = true;
	} else if (evt->type == SDL_EVENT_TEXT_INPUT)
		g_UserInput += evt->text.text;
	else if (evt->type == SDL_EVENT_MOUSE_MOTION) {
		g_MouseAbsX = evt->motion.x;
		g_MouseAbsY = evt->motion.y;
	} else if (evt->type == SDL_EVENT_MOUSE_BUTTON_DOWN) {
		g_MouseButtonsPressed[evt->button.button] = 1;
		g_MouseButtonsReleased[evt->button.button] = 0;
	} else if (evt->type == SDL_EVENT_MOUSE_BUTTON_UP) {
		g_MouseButtonsPressed[evt->button.button] = 0;
		g_MouseButtonsReleased[evt->button.button] = 1;
	} else if (evt->type == SDL_EVENT_MOUSE_WHEEL)
		g_MouseAbsZ += evt->wheel.y;
	else if (evt->type == SDL_EVENT_FINGER_DOWN)
		g_TouchLastDevice = evt->tfinger.touchID;
	else
		return false;
	return true;
}

#ifdef _WIN32
	void remove_keyhook();
	bool install_keyhook();
	void uninstall_keyhook();
	bool reinstall_keyhook_only();
	void process_keyhook_commands();
	LRESULT CALLBACK HookKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
#endif
void lost_window_focus() {
	SDL_ResetKeyboard();
	#ifdef _WIN32
	g_window_focused.store(false);
	if (g_keyhook_hHook) {
		UnhookWindowsHookEx(g_keyhook_hHook);
		g_keyhook_hHook = nullptr;
	}
	#endif
}
void regained_window_focus() {
	#ifdef _WIN32
	g_window_focused.store(true);
	if (!g_keyhook_hHook && g_keyhook_active) {
		g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
		if (g_keyhook_hHook)
			send_keyboard_input(VK_INSERT, true);
	}
	#endif
}
bool ScreenKeyboardShown() {
	return SDL_ScreenKeyboardShown(g_WindowHandle);
}
int GetKeyCode(const std::string& name) {
	if (name.empty())
		return SDLK_UNKNOWN;
	return SDL_GetScancodeFromName(name.c_str());
}
std::string GetKeyName(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT)
		return "";
	const char* result = SDL_GetScancodeName(static_cast<SDL_Scancode>(key));
	if (!result)
		return "";
	return result;
}
bool SetKeyName(int key, const std::string& name) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT || name.empty())
		return false;
	g_KeyNames[key] = name;
	return SDL_SetScancodeName(static_cast<SDL_Scancode>(key), g_KeyNames[key].c_str());
}
bool KeyPressed(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT)
		return false;
	bool r = g_KeysPressed[key] == 1;
	g_KeysPressed[key] = 0;
	return r;
}
bool KeyRepeating(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT)
		return false;
	bool r = g_KeysPressed[key] == 1 || g_KeysRepeating[key] == 1;
	g_KeysPressed[key] = 0;
	g_KeysRepeating[key] = 0;
	return r;
}
bool key_down(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT || !g_KeysDown)
		return false;
	return g_KeysReleased[key] == 0 && (g_KeysDown[key] == 1 || g_KeysForced[key]);
}
bool KeyReleased(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT || !g_KeysDown)
		return false;
	bool r = g_KeysReleased[key] == 1;
	if (r && g_KeysDown[key] == 1)
		return false;
	g_KeysReleased[key] = 0;
	return r;
}
bool key_up(int key) {
	return !key_down(key);
}
bool insure_key_up(int key) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT || !g_KeysDown)
		return false;
	if (g_KeysDown[key] == 1)
		g_KeysReleased[key] = 1;
	else
		return false;
	g_KeysForced[key] = false;
	return true;
}
inline bool post_key_event(int key, SDL_EventType evt_type) {
	if (key < 0 || key >= SDL_SCANCODE_COUNT || !g_KeysDown)
		return false;
	SDL_Event e{};
	e.type = evt_type;
	e.common.timestamp = SDL_GetTicksNS();
	e.key.scancode = (SDL_Scancode)key;
	g_KeysForced[key] = evt_type == SDL_EVENT_KEY_DOWN;
	SDL_Keymod mods;
	switch (key) {
		case SDL_SCANCODE_LCTRL:
			mods = SDL_KMOD_LCTRL;
			break;
		case SDL_SCANCODE_RCTRL:
			mods = SDL_KMOD_RCTRL;
			break;
		case SDL_SCANCODE_LSHIFT:
			mods = SDL_KMOD_LSHIFT;
			break;
		case SDL_SCANCODE_RSHIFT:
			mods = SDL_KMOD_RSHIFT;
			break;
		case SDL_SCANCODE_LALT:
			mods = SDL_KMOD_LALT;
			break;
		case SDL_SCANCODE_RALT:
			mods = SDL_KMOD_RALT;
			break;
		case SDL_SCANCODE_LGUI:
			mods = SDL_KMOD_LGUI;
			break;
		case SDL_SCANCODE_RGUI:
			mods = SDL_KMOD_RGUI;
			break;
		case SDL_SCANCODE_MODE:
			mods = SDL_KMOD_MODE;
			break;
		default:
			mods = SDL_KMOD_NONE;
			break;
	}
	evt_type == SDL_EVENT_KEY_DOWN ? SDL_SetModState(SDL_GetModState() | mods) : SDL_SetModState(SDL_GetModState() & ~mods);
	e.key.key = SDL_GetKeyFromScancode(e.key.scancode, SDL_GetModState(), true);
	return SDL_PushEvent(&e);
}
bool simulate_key_down(int key) {
	return post_key_event(key, SDL_EVENT_KEY_DOWN);
}
bool simulate_key_up(int key) {
	return post_key_event(key, SDL_EVENT_KEY_UP);
}
CScriptArray* keys_pressed() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!key_code_array_type)
		key_code_array_type = engine->GetTypeInfoByDecl("array<int>");
	CScriptArray* array = CScriptArray::Create(key_code_array_type);
	for (int i = 0; i < SDL_SCANCODE_COUNT; i++) {
		int k = (int)i;
		if (KeyPressed(k))
			array->InsertLast(&k);
	}
	return array;
}
CScriptArray* keys_down() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!key_code_array_type)
		key_code_array_type = engine->GetTypeInfoByDecl("array<int>");
	CScriptArray* array = CScriptArray::Create(key_code_array_type);
	if (!g_KeysDown)
		return array;
	for (int i = 0; i < g_KeysDownArrayLen; i++) {
		if (g_KeysDown[i] == 1 || g_KeysForced[i])
			array->InsertLast(&i);
	}
	return array;
}
int g_TotalKeysDownCache = -1;
int total_keys_down() {
	if (!g_KeysDown)
		return 0;
	if (!g_KeyboardStateChange && g_TotalKeysDownCache > 0)
		return g_TotalKeysDownCache;
	int c = 0;
	for (int i = 0; i < g_KeysDownArrayLen; i++) {
		if (g_KeysDown[i] || g_KeysReleased[i])
			c++;
	}
	g_KeyboardStateChange = false;
	g_TotalKeysDownCache = c;
	return c;
}
CScriptArray* keys_released() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!key_code_array_type)
		key_code_array_type = engine->GetTypeInfoByDecl("array<int>");
	CScriptArray* array = CScriptArray::Create(key_code_array_type);
	for (int i = 0; i < g_KeysDownArrayLen; i++) {
		if (KeyReleased(i))
			array->InsertLast(&i);
	}
	return array;
}
std::string get_characters() {
	std::string tmp = g_UserInput;
	g_UserInput = "";
	return tmp;
}
bool MousePressed(unsigned char button) {
	if (button > 31)
		return false;
	bool r = g_MouseButtonsPressed[button] == 1;
	g_MouseButtonsPressed[button] = 0;
	return r;
}
bool mouse_down(unsigned char button) {
	if (button > 31)
		return false;
	if (!g_KeysDown)
		return false;
	return (SDL_GetMouseState(&g_MouseAbsX, &g_MouseAbsY) & SDL_BUTTON_MASK(button)) != 0;
}
bool MouseReleased(unsigned char button) {
	if (button > 31)
		return false;
	bool r = g_MouseButtonsReleased[button] == 1;
	g_MouseButtonsReleased[button] = 0;
	return r;
}
bool mouse_up(unsigned char button) {
	return !mouse_down(button);
}
void mouse_update() {
	g_MouseX = g_MouseAbsX - g_MousePrevX;
	g_MouseY = g_MouseAbsY - g_MousePrevY;
	g_MouseZ = g_MouseAbsZ - g_MousePrevZ;
	g_MousePrevX = g_MouseAbsX;
	g_MousePrevY = g_MouseAbsY;
	g_MousePrevZ = g_MouseAbsZ;
}
void SetCursorVisible(bool state) {
	state ? SDL_ShowCursor() : SDL_HideCursor();
}
bool GetMouseGrab() {
	return SDL_GetWindowMouseGrab(g_WindowHandle);
}
void SetMouseGrab(bool grabbed) {
	SDL_SetWindowMouseGrab(g_WindowHandle, grabbed);
}
CScriptArray* GetKeyboards() {
	return GetDevices(SDL_GetKeyboards);
}
std::string GetKeyboardName(unsigned int id) {
	const char* result = SDL_GetKeyboardNameForID((SDL_KeyboardID)id);
	if (!result)
		return "";
	return result;
}
CScriptArray* GetMice() {
	return GetDevices(SDL_GetMice);
}
std::string GetMouseName(unsigned int id) {
	const char* result = SDL_GetMouseNameForID((SDL_MouseID)id);
	if (!result)
		return "";
	return result;
}

// Static variable for preferred joystick index (BGT compatibility)
static int g_preferred_joystick = 0;

// Global list of active joystick instances for updating
static std::vector<joystick*> g_active_joysticks;
static Poco::FastMutex g_joysticks_mutex;

// Helper function to count joysticks
int joystick_count(bool gamepads_only) {
	InputInit();
	if (gamepads_only) {
		int count;
		SDL_JoystickID* joysticks = SDL_GetGamepads(&count);
		if (joysticks) SDL_free(joysticks);
		return count;
	} else {
		int count;
		SDL_JoystickID* joysticks = SDL_GetJoysticks(&count);
		if (joysticks) SDL_free(joysticks);
		return count;
	}
}

static joystick* joystick_factory() {
	return new joystick();
}

void update_joysticks() {
	Poco::FastMutex::ScopedLock lock(g_joysticks_mutex);
	for (joystick* js : g_active_joysticks) {
		if (js) js->update();
	}
}

joystick::joystick() : stick(nullptr), js_handle(nullptr), current_index(-1) {
	refresh_joystick_list();
	if (get_joysticks() > 0)
		set(g_preferred_joystick);
	Poco::FastMutex::ScopedLock lock(g_joysticks_mutex);
	g_active_joysticks.push_back(this);
}

joystick::~joystick() {
	{
		Poco::FastMutex::ScopedLock lock(g_joysticks_mutex);
		auto it = std::find(g_active_joysticks.begin(), g_active_joysticks.end(), this);
		if (it != g_active_joysticks.end())
			g_active_joysticks.erase(it);
	}
	if (stick) {
		SDL_CloseGamepad(stick);
		stick = nullptr;
	}
	js_handle = nullptr; // This is owned by gamepad, don't close separately
}

void joystick::update() {
	if (!stick) return;
	for (size_t i = 0; i < button_states.size(); i++) {
		bool current_state = SDL_GetGamepadButton(stick, (SDL_GamepadButton)i) != 0;
		if (current_state && !button_states[i])
			button_pressed_states[i] = true;
		else
			button_pressed_states[i] = false;
		if (!current_state && button_states[i])
			button_released_states[i] = true;
		else
			button_released_states[i] = false;
		button_states[i] = current_state;
	}
	for (int i = 0; i < SDL_GAMEPAD_AXIS_COUNT; i++)
		axis_values[i] = SDL_GetGamepadAxis(stick, (SDL_GamepadAxis)i);
	if (js_handle) {
		int num_hats = SDL_GetNumJoystickHats(js_handle);
		for (int i = 0; i < num_hats && i < 4; i++)
			hat_values[i] = SDL_GetJoystickHat(js_handle, i);
	}
}

// BGT compatibility property implementations
unsigned int joystick::get_joysticks() const {
	InputInit();
	int count;
	SDL_JoystickID* joysticks = SDL_GetGamepads(&count);
	if (joysticks) SDL_free(joysticks);
	return count;
}

bool joystick::get_has_x() const {
	return stick != nullptr;
}

bool joystick::get_has_y() const {
	return stick != nullptr;
}

bool joystick::get_has_z() const {
	return stick != nullptr; // Right stick Y axis can be used as Z
}

bool joystick::get_has_r_x() const {
	return stick != nullptr;
}

bool joystick::get_has_r_y() const {
	return stick != nullptr;
}

bool joystick::get_has_r_z() const {
	return false; // No direct mapping in standard gamepad
}

unsigned int joystick::get_buttons() const {
	if (!stick) return 0;
	// SDL gamepad has a fixed number of buttons
	return SDL_GAMEPAD_BUTTON_COUNT;
}

unsigned int joystick::get_sliders() const {
	if (!stick) return 0;
	// Triggers can be considered as sliders
	return 2;
}

unsigned int joystick::get_povs() const {
	if (!js_handle) return 0;
	return SDL_GetNumJoystickHats(js_handle);
}

std::string joystick::get_name() const {
	if (!stick) return "";
	const char* name = SDL_GetGamepadName(stick);
	return name ? name : "";
}

bool joystick::get_active() const {
	return stick && SDL_GamepadConnected(stick);
}

int joystick::get_preferred_joystick() const {
	return g_preferred_joystick;
}

void joystick::set_preferred_joystick(int index) {
	g_preferred_joystick = index;
}

int joystick::get_x() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_LEFTX) return 0;
	// Convert from SDL range (-32768 to 32767) to BGT range (0 to 65535)
	return axis_values[SDL_GAMEPAD_AXIS_LEFTX] + 32768;
}

int joystick::get_y() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_LEFTY) return 0;
	return axis_values[SDL_GAMEPAD_AXIS_LEFTY] + 32768;
}

int joystick::get_z() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_RIGHTY) return 0;
	// Use right stick Y as Z axis for BGT compatibility
	return axis_values[SDL_GAMEPAD_AXIS_RIGHTY] + 32768;
}

int joystick::get_r_x() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_RIGHTX) return 0;
	return axis_values[SDL_GAMEPAD_AXIS_RIGHTX] + 32768;
}

int joystick::get_r_y() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_RIGHTY) return 0;
	return axis_values[SDL_GAMEPAD_AXIS_RIGHTY] + 32768;
}

int joystick::get_r_z() const {
	// No direct mapping, return centered position
	return 32768;
}

int joystick::get_slider_1() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_LEFT_TRIGGER) return 0;
	// Triggers range from 0 to 32767, scale to 0 to 65535
	return axis_values[SDL_GAMEPAD_AXIS_LEFT_TRIGGER] * 2;
}

int joystick::get_slider_2() const {
	if (!stick || axis_values.size() <= SDL_GAMEPAD_AXIS_RIGHT_TRIGGER) return 0;
	return axis_values[SDL_GAMEPAD_AXIS_RIGHT_TRIGGER] * 2;
}

int joystick::get_pov_1() const {
	if (!js_handle || hat_values.empty()) return -1;
	return hat_values[0];
}

int joystick::get_pov_2() const {
	if (!js_handle || hat_values.size() < 2) return -1;
	return hat_values[1];
}

int joystick::get_pov_3() const {
	if (!js_handle || hat_values.size() < 3) return -1;
	return hat_values[2];
}

int joystick::get_pov_4() const {
	if (!js_handle || hat_values.size() < 4) return -1;
	return hat_values[3];
}

unsigned int joystick::type() const {
	if (!stick) return 0;
	return SDL_GetGamepadType(stick);
}

// joystick_power_info implementation
std::string joystick_power_info::get_state_name() const {
	switch (state) {
		case SDL_POWERSTATE_ERROR: return "Error";
		case SDL_POWERSTATE_UNKNOWN: return "Unknown";
		case SDL_POWERSTATE_ON_BATTERY: return "On Battery";
		case SDL_POWERSTATE_NO_BATTERY: return "No Battery";
		case SDL_POWERSTATE_CHARGING: return "Charging";
		case SDL_POWERSTATE_CHARGED: return "Charged";
		default: return "Invalid";
	}
}

std::string joystick_power_info::to_string() const {
	return get_state_name() + " (" + std::to_string(percentage) + "%)";
}

joystick_power_info joystick::get_power_info() const {
	if (!js_handle) return joystick_power_info();
	int percent = 0;
	SDL_PowerState state = SDL_GetJoystickPowerInfo(js_handle, &percent);
	return joystick_power_info(state, percent);
}

std::string joystick::serial() const {
	if (!stick) return "";
	const char* serial = SDL_GetGamepadSerial(stick);
	return serial ? serial : "";
}

bool joystick::has_led() const {
	// Only in SDL 3.2.0
	return false;
}

bool joystick::can_vibrate() const {
	// Only in SDL 3.2.0
	return stick != nullptr;
}

bool joystick::can_vibrate_triggers() const {
	// Only in SDL 3.2.0
	return false;
}

int joystick::touchpads() const {
	if (!stick) return 0;
	return SDL_GetNumGamepadTouchpads(stick);
}

bool joystick::button_down(int button) {
	if (!stick || button < 0 || button >= (int)button_states.size()) return false;
	return button_states[button];
}

bool joystick::button_pressed(int button) {
	if (!stick || button < 0 || button >= (int)button_pressed_states.size()) return false;
	bool result = button_pressed_states[button];
	button_pressed_states[button] = false; // Clear after reading
	return result;
}

bool joystick::button_released(int button) {
	if (!stick || button < 0 || button >= (int)button_released_states.size()) return false;
	bool result = button_released_states[button];
	button_released_states[button] = false; // Clear after reading
	return result;
}

bool joystick::button_up(int button) {
	return !button_down(button);
}

CScriptArray* joystick::buttons_down() {
	asITypeInfo* array_type = get_array_type("int[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array || !stick) return array;
	for (int i = 0; i < (int)button_states.size(); i++) {
		if (button_states[i])
			array->InsertLast(&i);
	}
	return array;
}

CScriptArray* joystick::buttons_pressed() {
	asITypeInfo* array_type = get_array_type("int[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array || !stick) return array;
	for (int i = 0; i < (int)button_pressed_states.size(); i++) {
		if (button_pressed_states[i]) {
			array->InsertLast(&i);
			button_pressed_states[i] = false; // Clear after reading
		}
	}
	return array;
}

CScriptArray* joystick::buttons_released() {
	asITypeInfo* array_type = get_array_type("int[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array || !stick) return array;
	for (int i = 0; i < (int)button_released_states.size(); i++) {
		if (button_released_states[i]) {
			array->InsertLast(&i);
			button_released_states[i] = false; // Clear after reading
		}
	}
	return array;
}

CScriptArray* joystick::buttons_up() {
	asITypeInfo* array_type = get_array_type("int[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array || !stick) return array;
	for (int i = 0; i < (int)button_states.size(); i++) {
		if (!button_states[i])
			array->InsertLast(&i);
	}
	return array;
}

CScriptArray* joystick::list_joysticks() {
	asITypeInfo* array_type = get_array_type("string[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) return array;
	int count;
	SDL_JoystickID* joysticks = SDL_GetGamepads(&count);
	if (!joysticks) return array;
	for (int i = 0; i < count; i++) {
		const char* name = SDL_GetGamepadNameForID(joysticks[i]);
		std::string name_str = name ? name : "Unknown Gamepad";
		array->InsertLast(&name_str);
	}
	SDL_free(joysticks);
	return array;
}

bool joystick::pov_centered(int pov) {
	if (!js_handle || pov < 0 || pov >= (int)hat_values.size()) return true;
	return hat_values[pov] == SDL_HAT_CENTERED;
}

bool joystick::refresh_joystick_list() {
	// SDL automatically detects joystick changes
	// This is here for BGT compatibility
	return true;
}

bool joystick::set(int index) {
	// Close current gamepad if open
	if (stick) {
		SDL_CloseGamepad(stick);
		stick = nullptr;
		js_handle = nullptr;
	}
	int count;
	SDL_JoystickID* joysticks = SDL_GetGamepads(&count);
	if (!joysticks || index < 0 || index >= count) {
		if (joysticks) SDL_free(joysticks);
		current_index = -1;
		return false;
	}
	stick = SDL_OpenGamepad(joysticks[index]);
	SDL_free(joysticks);
	if (!stick) {
		current_index = -1;
		return false;
	}
	js_handle = SDL_GetGamepadJoystick(stick);
	current_index = index;
	button_states.resize(SDL_GAMEPAD_BUTTON_COUNT, false);
	button_pressed_states.resize(SDL_GAMEPAD_BUTTON_COUNT, false);
	button_released_states.resize(SDL_GAMEPAD_BUTTON_COUNT, false);
	axis_values.resize(SDL_GAMEPAD_AXIS_COUNT, 0);
	if (js_handle) {
		int num_hats = SDL_GetNumJoystickHats(js_handle);
		hat_values.resize(num_hats < 4 ? num_hats : 4, SDL_HAT_CENTERED);
	}
	// Pump to get most up-to-date info
	SDL_PumpEvents();
	return true;
}

bool joystick::set_led(unsigned char red, unsigned char green, unsigned char blue) {
	if (!stick) return false;
	return SDL_SetGamepadLED(stick, red, green, blue);
}

bool joystick::vibrate(unsigned short low_frequency, unsigned short high_frequency, int duration) {
	if (!stick) return false;
	return SDL_RumbleGamepad(stick, low_frequency, high_frequency, duration);
}

bool joystick::vibrate_triggers(unsigned short left, unsigned short right, int duration) {
	if (!stick) return false;
	return SDL_RumbleGamepadTriggers(stick, left, right, duration);
}

#ifdef _WIN32
// Thanks Quentin Cosendey (Universal Speech) for this jaws keyboard hook code as well as to male-srdiecko and silak for various improvements and fixes that have taken place since initial implementation.
bool altPressed = false;
bool capsPressed = false;
bool insertPressed = false;
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
#else
// Dummy no-op keyhook functions.
bool install_keyhook() { return false; }
void uninstall_keyhook() {}
void process_keyhook_commands() {}
#endif

// Low level touch interface
CScriptArray* get_touch_devices() {
	asITypeInfo* array_type = get_array_type("uint64[]");
	if (!array_type)
		return nullptr;
	int device_count;
	SDL_TouchID* devices = SDL_GetTouchDevices(&device_count);
	if (!devices)
		return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) {
		SDL_free(devices);
		return nullptr;
		;
	}
	array->Reserve(device_count);
	for (int i = 0; i < device_count; i++)
		array->InsertLast(devices + i);
	SDL_free(devices);
	return array;
}
std::string get_touch_device_name(uint64_t device_id) {
	const char* result = SDL_GetTouchDeviceName((SDL_TouchID)device_id);
	if (!result)
		return "";
	return result;
}
int get_touch_device_type(uint64_t device_id) {
	return SDL_GetTouchDeviceType((SDL_TouchID)device_id);
}
CScriptArray* query_touch_device(uint64_t device_id) {
	asITypeInfo* array_type = get_array_type("touch_finger[]");
	if (!array_type)
		return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array)
		return nullptr;
	if (!device_id && g_TouchLastDevice)
		device_id = g_TouchLastDevice;
	if (!device_id)
		return array;
	int finger_count;
	SDL_Finger** fingers = SDL_GetTouchFingers(device_id, &finger_count);
	if (!fingers)
		return array;
	array->Reserve(finger_count);
	for (int i = 0; i < finger_count; i++)
		array->InsertLast(*(fingers + i));
	SDL_free(fingers);
	return array;
}

bool StartTextInput() {
	return SDL_StartTextInput(g_WindowHandle);
}

bool StopTextInput() {
	return SDL_StopTextInput(g_WindowHandle);
}

bool TextInputActive() {
	return SDL_TextInputActive(g_WindowHandle);
}

// Helper functions for joystick_power_info struct
void joystick_power_info_construct(void* mem) {
	new (mem) joystick_power_info();
}

void joystick_power_info_construct_params(void* mem, int state, int percentage) {
	new (mem) joystick_power_info(state, percentage);
}

void joystick_power_info_copy_construct(void* mem, const joystick_power_info& other) {
	new (mem) joystick_power_info(other);
}

void joystick_power_info_destruct(void* mem) {
	((joystick_power_info*)mem)->~joystick_power_info();
}

void RegisterInput(asIScriptEngine* engine) {
	engine->RegisterObjectType("touch_finger", sizeof(SDL_Finger), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<SDL_Finger>());
	engine->RegisterObjectProperty("touch_finger", "const uint64 id", asOFFSET(SDL_Finger, id));
	engine->RegisterObjectProperty("touch_finger", "const float x", asOFFSET(SDL_Finger, x));
	engine->RegisterObjectProperty("touch_finger", "const float y", asOFFSET(SDL_Finger, y));
	engine->RegisterObjectProperty("touch_finger", "const float pressure", asOFFSET(SDL_Finger, pressure));
	engine->RegisterEnum(_O("key_modifier"));
	engine->RegisterEnum(_O("key_code"));
	engine->RegisterEnum(_O("touch_device_type"));
	engine->RegisterEnum(_O("joystick_type"));
	engine->RegisterEnum(_O("joystick_bind_type"));
	engine->RegisterEnum(_O("joystick_power_state"));
	engine->RegisterEnum(_O("joystick_control_type"));
	engine->RegisterGlobalFunction(_O("bool start_text_input()"), asFUNCTION(StartTextInput), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool stop_text_input()"), asFUNCTION(StopTextInput), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool text_input_active()"), asFUNCTION(TextInputActive), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_KEYBOARD_AVAILABLE() property"), asFUNCTION(SDL_HasKeyboard), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int get_key_code(const string&in name)"), asFUNCTION(GetKeyCode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_key_name(int key)"), asFUNCTION(GetKeyName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool set_key_name(int key, const string&in name)"), asFUNCTION(SetKeyName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_pressed(int key)"), asFUNCTION(KeyPressed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_repeating(int key)"), asFUNCTION(KeyRepeating), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_down(int key)"), asFUNCTION(key_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_released(int key)"), asFUNCTION(KeyReleased), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_up(int key)"), asFUNCTION(key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool insure_key_up(int key)"), asFUNCTION(insure_key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool simulate_key_down(int key)"), asFUNCTION(simulate_key_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool simulate_key_up(int key)"), asFUNCTION(simulate_key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int[]@ keys_pressed()"), asFUNCTION(keys_pressed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int[]@ keys_down()"), asFUNCTION(keys_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int total_keys_down()"), asFUNCTION(total_keys_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int[]@ keys_released()"), asFUNCTION(keys_released), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("key_modifier get_keyboard_modifiers() property"), asFUNCTION(SDL_GetModState), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void set_keyboard_modifiers(key_modifier modifier) property"), asFUNCTION(SDL_SetModState), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void reset_keyboard()"), asFUNCTION(SDL_ResetKeyboard), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool mouse_pressed(uint8 button)"), asFUNCTION(MousePressed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool mouse_down(uint8 button)"), asFUNCTION(mouse_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool mouse_released(uint8 button)"), asFUNCTION(MouseReleased), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool mouse_up(uint8 button)"), asFUNCTION(mouse_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void mouse_update()"), asFUNCTION(mouse_update), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_MOUSE_AVAILABLE() property"), asFUNCTION(SDL_HasMouse), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_mouse_grab() property"), asFUNCTION(GetMouseGrab), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void set_mouse_grab(bool grabbed) property"), asFUNCTION(SetMouseGrab), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_cursor_visible() property"), asFUNCTION(SDL_CursorVisible), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void set_cursor_visible(bool state) property"), asFUNCTION(SetCursorVisible), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool is_screen_keyboard_shown()"), asFUNCTION(ScreenKeyboardShown), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_SCREEN_KEYBOARD_SUPPORTED() property"), asFUNCTION(SDL_HasScreenKeyboardSupport), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_characters()"), asFUNCTION(get_characters), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool install_keyhook()"), asFUNCTION(install_keyhook), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void uninstall_keyhook()"), asFUNCTION(uninstall_keyhook), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint[]@ get_keyboards()"), asFUNCTION(GetKeyboards), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_keyboard_name(uint id)"), asFUNCTION(GetKeyboardName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint[]@ get_mice()"), asFUNCTION(GetMice), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_mouse_name(uint id)"), asFUNCTION(GetMouseName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64[]@ get_touch_devices()"), asFUNCTION(get_touch_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_touch_device_name(uint64 device_id)"), asFUNCTION(get_touch_device_name), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("touch_device_type get_touch_device_type(uint64 device_id)"), asFUNCTION(get_touch_device_type), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("touch_finger[]@ query_touch_device(uint64 device_id = 0)"), asFUNCTION(query_touch_device), asCALL_CDECL);
	engine->RegisterGlobalProperty(_O("const float MOUSE_X"), &g_MouseX);
	engine->RegisterGlobalProperty(_O("const float MOUSE_Y"), &g_MouseY);
	engine->RegisterGlobalProperty(_O("const float MOUSE_Z"), &g_MouseZ);
	engine->RegisterGlobalProperty(_O("const float MOUSE_ABSOLUTE_X"), &g_MouseAbsX);
	engine->RegisterGlobalProperty(_O("const float MOUSE_ABSOLUTE_Y"), &g_MouseAbsY);
	engine->RegisterGlobalProperty(_O("const float MOUSE_ABSOLUTE_Z"), &g_MouseAbsZ);
	engine->RegisterEnumValue("touch_device_type", "TOUCH_DEVICE_TYPE_INVALID", SDL_TOUCH_DEVICE_INVALID);
	engine->RegisterEnumValue("touch_device_type", "TOUCH_DEVICE_DIRECT", SDL_TOUCH_DEVICE_DIRECT);
	engine->RegisterEnumValue("touch_device_type", "TOUCH_DEVICE_INDIRECT_ABSOLUTE", SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE);
	engine->RegisterEnumValue("touch_device_type", "TOUCH_DEVICE_INDIRECT_RELATIVE", SDL_TOUCH_DEVICE_INDIRECT_RELATIVE);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_NONE", SDL_KMOD_NONE);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_LSHIFT", SDL_KMOD_LSHIFT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_RSHIFT", SDL_KMOD_RSHIFT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_LCTRL", SDL_KMOD_LCTRL);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_RCTRL", SDL_KMOD_RCTRL);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_LALT", SDL_KMOD_LALT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_RALT", SDL_KMOD_RALT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_LGUI", SDL_KMOD_LGUI);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_RGUI", SDL_KMOD_RGUI);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_NUM", SDL_KMOD_NUM);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_CAPS", SDL_KMOD_CAPS);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_MODE", SDL_KMOD_MODE);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_SCROLL", SDL_KMOD_SCROLL);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_CTRL", SDL_KMOD_CTRL);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_SHIFT", SDL_KMOD_SHIFT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_ALT", SDL_KMOD_ALT);
	engine->RegisterEnumValue("key_modifier", "KEYMOD_GUI", SDL_KMOD_GUI);
	engine->RegisterEnumValue("key_code", "KEY_UNKNOWN", SDL_SCANCODE_UNKNOWN);
	engine->RegisterEnumValue("key_code", "KEY_A", SDL_SCANCODE_A);
	engine->RegisterEnumValue("key_code", "KEY_B", SDL_SCANCODE_B);
	engine->RegisterEnumValue("key_code", "KEY_C", SDL_SCANCODE_C);
	engine->RegisterEnumValue("key_code", "KEY_D", SDL_SCANCODE_D);
	engine->RegisterEnumValue("key_code", "KEY_E", SDL_SCANCODE_E);
	engine->RegisterEnumValue("key_code", "KEY_F", SDL_SCANCODE_F);
	engine->RegisterEnumValue("key_code", "KEY_G", SDL_SCANCODE_G);
	engine->RegisterEnumValue("key_code", "KEY_H", SDL_SCANCODE_H);
	engine->RegisterEnumValue("key_code", "KEY_I", SDL_SCANCODE_I);
	engine->RegisterEnumValue("key_code", "KEY_J", SDL_SCANCODE_J);
	engine->RegisterEnumValue("key_code", "KEY_K", SDL_SCANCODE_K);
	engine->RegisterEnumValue("key_code", "KEY_L", SDL_SCANCODE_L);
	engine->RegisterEnumValue("key_code", "KEY_M", SDL_SCANCODE_M);
	engine->RegisterEnumValue("key_code", "KEY_N", SDL_SCANCODE_N);
	engine->RegisterEnumValue("key_code", "KEY_O", SDL_SCANCODE_O);
	engine->RegisterEnumValue("key_code", "KEY_P", SDL_SCANCODE_P);
	engine->RegisterEnumValue("key_code", "KEY_Q", SDL_SCANCODE_Q);
	engine->RegisterEnumValue("key_code", "KEY_R", SDL_SCANCODE_R);
	engine->RegisterEnumValue("key_code", "KEY_S", SDL_SCANCODE_S);
	engine->RegisterEnumValue("key_code", "KEY_T", SDL_SCANCODE_T);
	engine->RegisterEnumValue("key_code", "KEY_U", SDL_SCANCODE_U);
	engine->RegisterEnumValue("key_code", "KEY_V", SDL_SCANCODE_V);
	engine->RegisterEnumValue("key_code", "KEY_W", SDL_SCANCODE_W);
	engine->RegisterEnumValue("key_code", "KEY_X", SDL_SCANCODE_X);
	engine->RegisterEnumValue("key_code", "KEY_Y", SDL_SCANCODE_Y);
	engine->RegisterEnumValue("key_code", "KEY_Z", SDL_SCANCODE_Z);
	engine->RegisterEnumValue("key_code", "KEY_1", SDL_SCANCODE_1);
	engine->RegisterEnumValue("key_code", "KEY_2", SDL_SCANCODE_2);
	engine->RegisterEnumValue("key_code", "KEY_3", SDL_SCANCODE_3);
	engine->RegisterEnumValue("key_code", "KEY_4", SDL_SCANCODE_4);
	engine->RegisterEnumValue("key_code", "KEY_5", SDL_SCANCODE_5);
	engine->RegisterEnumValue("key_code", "KEY_6", SDL_SCANCODE_6);
	engine->RegisterEnumValue("key_code", "KEY_7", SDL_SCANCODE_7);
	engine->RegisterEnumValue("key_code", "KEY_8", SDL_SCANCODE_8);
	engine->RegisterEnumValue("key_code", "KEY_9", SDL_SCANCODE_9);
	engine->RegisterEnumValue("key_code", "KEY_0", SDL_SCANCODE_0);
	engine->RegisterEnumValue("key_code", "KEY_RETURN", SDL_SCANCODE_RETURN);
	engine->RegisterEnumValue("key_code", "KEY_ESCAPE", SDL_SCANCODE_ESCAPE);
	engine->RegisterEnumValue("key_code", "KEY_BACK", SDL_SCANCODE_BACKSPACE);
	engine->RegisterEnumValue("key_code", "KEY_TAB", SDL_SCANCODE_TAB);
	engine->RegisterEnumValue("key_code", "KEY_SPACE", SDL_SCANCODE_SPACE);
	engine->RegisterEnumValue("key_code", "KEY_MINUS", SDL_SCANCODE_MINUS);
	engine->RegisterEnumValue("key_code", "KEY_EQUALS", SDL_SCANCODE_EQUALS);
	engine->RegisterEnumValue("key_code", "KEY_LEFTBRACKET", SDL_SCANCODE_LEFTBRACKET);
	engine->RegisterEnumValue("key_code", "KEY_RIGHTBRACKET", SDL_SCANCODE_RIGHTBRACKET);
	engine->RegisterEnumValue("key_code", "KEY_BACKSLASH", SDL_SCANCODE_BACKSLASH);
	engine->RegisterEnumValue("key_code", "KEY_NONUSHASH", SDL_SCANCODE_NONUSHASH);
	engine->RegisterEnumValue("key_code", "KEY_SEMICOLON", SDL_SCANCODE_SEMICOLON);
	engine->RegisterEnumValue("key_code", "KEY_APOSTROPHE", SDL_SCANCODE_APOSTROPHE);
	engine->RegisterEnumValue("key_code", "KEY_GRAVE", SDL_SCANCODE_GRAVE);
	engine->RegisterEnumValue("key_code", "KEY_COMMA", SDL_SCANCODE_COMMA);
	engine->RegisterEnumValue("key_code", "KEY_PERIOD", SDL_SCANCODE_PERIOD);
	engine->RegisterEnumValue("key_code", "KEY_SLASH", SDL_SCANCODE_SLASH);
	engine->RegisterEnumValue("key_code", "KEY_CAPSLOCK", SDL_SCANCODE_CAPSLOCK);
	engine->RegisterEnumValue("key_code", "KEY_F1", SDL_SCANCODE_F1);
	engine->RegisterEnumValue("key_code", "KEY_F2", SDL_SCANCODE_F2);
	engine->RegisterEnumValue("key_code", "KEY_F3", SDL_SCANCODE_F3);
	engine->RegisterEnumValue("key_code", "KEY_F4", SDL_SCANCODE_F4);
	engine->RegisterEnumValue("key_code", "KEY_F5", SDL_SCANCODE_F5);
	engine->RegisterEnumValue("key_code", "KEY_F6", SDL_SCANCODE_F6);
	engine->RegisterEnumValue("key_code", "KEY_F7", SDL_SCANCODE_F7);
	engine->RegisterEnumValue("key_code", "KEY_F8", SDL_SCANCODE_F8);
	engine->RegisterEnumValue("key_code", "KEY_F9", SDL_SCANCODE_F9);
	engine->RegisterEnumValue("key_code", "KEY_F10", SDL_SCANCODE_F10);
	engine->RegisterEnumValue("key_code", "KEY_F11", SDL_SCANCODE_F11);
	engine->RegisterEnumValue("key_code", "KEY_F12", SDL_SCANCODE_F12);
	engine->RegisterEnumValue("key_code", "KEY_PRINTSCREEN", SDL_SCANCODE_PRINTSCREEN);
	engine->RegisterEnumValue("key_code", "KEY_SCROLLLOCK", SDL_SCANCODE_SCROLLLOCK);
	engine->RegisterEnumValue("key_code", "KEY_PAUSE", SDL_SCANCODE_PAUSE);
	engine->RegisterEnumValue("key_code", "KEY_INSERT", SDL_SCANCODE_INSERT);
	engine->RegisterEnumValue("key_code", "KEY_HOME", SDL_SCANCODE_HOME);
	engine->RegisterEnumValue("key_code", "KEY_PAGEUP", SDL_SCANCODE_PAGEUP);
	engine->RegisterEnumValue("key_code", "KEY_DELETE", SDL_SCANCODE_DELETE);
	engine->RegisterEnumValue("key_code", "KEY_END", SDL_SCANCODE_END);
	engine->RegisterEnumValue("key_code", "KEY_PAGEDOWN", SDL_SCANCODE_PAGEDOWN);
	engine->RegisterEnumValue("key_code", "KEY_RIGHT", SDL_SCANCODE_RIGHT);
	engine->RegisterEnumValue("key_code", "KEY_LEFT", SDL_SCANCODE_LEFT);
	engine->RegisterEnumValue("key_code", "KEY_DOWN", SDL_SCANCODE_DOWN);
	engine->RegisterEnumValue("key_code", "KEY_UP", SDL_SCANCODE_UP);
	engine->RegisterEnumValue("key_code", "KEY_NUMLOCKCLEAR", SDL_SCANCODE_NUMLOCKCLEAR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_DIVIDE", SDL_SCANCODE_KP_DIVIDE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MULTIPLY", SDL_SCANCODE_KP_MULTIPLY);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MINUS", SDL_SCANCODE_KP_MINUS);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_PLUS", SDL_SCANCODE_KP_PLUS);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_ENTER", SDL_SCANCODE_KP_ENTER);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_1", SDL_SCANCODE_KP_1);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_2", SDL_SCANCODE_KP_2);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_3", SDL_SCANCODE_KP_3);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_4", SDL_SCANCODE_KP_4);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_5", SDL_SCANCODE_KP_5);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_6", SDL_SCANCODE_KP_6);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_7", SDL_SCANCODE_KP_7);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_8", SDL_SCANCODE_KP_8);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_9", SDL_SCANCODE_KP_9);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_0", SDL_SCANCODE_KP_0);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_PERIOD", SDL_SCANCODE_KP_PERIOD);
	engine->RegisterEnumValue("key_code", "KEY_NONUSBACKSLASH", SDL_SCANCODE_NONUSBACKSLASH);
	engine->RegisterEnumValue("key_code", "KEY_APPLICATION", SDL_SCANCODE_APPLICATION);
	engine->RegisterEnumValue("key_code", "KEY_POWER", SDL_SCANCODE_POWER);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_EQUALS", SDL_SCANCODE_KP_EQUALS);
	engine->RegisterEnumValue("key_code", "KEY_F13", SDL_SCANCODE_F13);
	engine->RegisterEnumValue("key_code", "KEY_F14", SDL_SCANCODE_F14);
	engine->RegisterEnumValue("key_code", "KEY_F15", SDL_SCANCODE_F15);
	engine->RegisterEnumValue("key_code", "KEY_F16", SDL_SCANCODE_F16);
	engine->RegisterEnumValue("key_code", "KEY_F17", SDL_SCANCODE_F17);
	engine->RegisterEnumValue("key_code", "KEY_F18", SDL_SCANCODE_F18);
	engine->RegisterEnumValue("key_code", "KEY_F19", SDL_SCANCODE_F19);
	engine->RegisterEnumValue("key_code", "KEY_F20", SDL_SCANCODE_F20);
	engine->RegisterEnumValue("key_code", "KEY_F21", SDL_SCANCODE_F21);
	engine->RegisterEnumValue("key_code", "KEY_F22", SDL_SCANCODE_F22);
	engine->RegisterEnumValue("key_code", "KEY_F23", SDL_SCANCODE_F23);
	engine->RegisterEnumValue("key_code", "KEY_F24", SDL_SCANCODE_F24);
	engine->RegisterEnumValue("key_code", "KEY_EXECUTE", SDL_SCANCODE_EXECUTE);
	engine->RegisterEnumValue("key_code", "KEY_HELP", SDL_SCANCODE_HELP);
	engine->RegisterEnumValue("key_code", "KEY_MENU", SDL_SCANCODE_MENU);
	engine->RegisterEnumValue("key_code", "KEY_SELECT", SDL_SCANCODE_SELECT);
	engine->RegisterEnumValue("key_code", "KEY_STOP", SDL_SCANCODE_STOP);
	engine->RegisterEnumValue("key_code", "KEY_AGAIN", SDL_SCANCODE_AGAIN);
	engine->RegisterEnumValue("key_code", "KEY_UNDO", SDL_SCANCODE_UNDO);
	engine->RegisterEnumValue("key_code", "KEY_CUT", SDL_SCANCODE_CUT);
	engine->RegisterEnumValue("key_code", "KEY_COPY", SDL_SCANCODE_COPY);
	engine->RegisterEnumValue("key_code", "KEY_PASTE", SDL_SCANCODE_PASTE);
	engine->RegisterEnumValue("key_code", "KEY_FIND", SDL_SCANCODE_FIND);
	engine->RegisterEnumValue("key_code", "KEY_MUTE", SDL_SCANCODE_MUTE);
	engine->RegisterEnumValue("key_code", "KEY_VOLUMEUP", SDL_SCANCODE_VOLUMEUP);
	engine->RegisterEnumValue("key_code", "KEY_VOLUMEDOWN", SDL_SCANCODE_VOLUMEDOWN);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_COMMA", SDL_SCANCODE_KP_COMMA);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_EQUALSAS400", SDL_SCANCODE_KP_EQUALSAS400);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL1", SDL_SCANCODE_INTERNATIONAL1);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL2", SDL_SCANCODE_INTERNATIONAL2);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL3", SDL_SCANCODE_INTERNATIONAL3);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL4", SDL_SCANCODE_INTERNATIONAL4);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL5", SDL_SCANCODE_INTERNATIONAL5);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL6", SDL_SCANCODE_INTERNATIONAL6);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL7", SDL_SCANCODE_INTERNATIONAL7);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL8", SDL_SCANCODE_INTERNATIONAL8);
	engine->RegisterEnumValue("key_code", "KEY_INTERNATIONAL9", SDL_SCANCODE_INTERNATIONAL9);
	engine->RegisterEnumValue("key_code", "KEY_LANG1", SDL_SCANCODE_LANG1);
	engine->RegisterEnumValue("key_code", "KEY_LANG2", SDL_SCANCODE_LANG2);
	engine->RegisterEnumValue("key_code", "KEY_LANG3", SDL_SCANCODE_LANG3);
	engine->RegisterEnumValue("key_code", "KEY_LANG4", SDL_SCANCODE_LANG4);
	engine->RegisterEnumValue("key_code", "KEY_LANG5", SDL_SCANCODE_LANG5);
	engine->RegisterEnumValue("key_code", "KEY_LANG6", SDL_SCANCODE_LANG6);
	engine->RegisterEnumValue("key_code", "KEY_LANG7", SDL_SCANCODE_LANG7);
	engine->RegisterEnumValue("key_code", "KEY_LANG8", SDL_SCANCODE_LANG8);
	engine->RegisterEnumValue("key_code", "KEY_LANG9", SDL_SCANCODE_LANG9);
	engine->RegisterEnumValue("key_code", "KEY_ALTERASE", SDL_SCANCODE_ALTERASE);
	engine->RegisterEnumValue("key_code", "KEY_SYSREQ", SDL_SCANCODE_SYSREQ);
	engine->RegisterEnumValue("key_code", "KEY_CANCEL", SDL_SCANCODE_CANCEL);
	engine->RegisterEnumValue("key_code", "KEY_CLEAR", SDL_SCANCODE_CLEAR);
	engine->RegisterEnumValue("key_code", "KEY_SDL_PRIOR", SDL_SCANCODE_PRIOR);
	engine->RegisterEnumValue("key_code", "KEY_RETURN2", SDL_SCANCODE_RETURN2);
	engine->RegisterEnumValue("key_code", "KEY_SEPARATOR", SDL_SCANCODE_SEPARATOR);
	engine->RegisterEnumValue("key_code", "KEY_OUT", SDL_SCANCODE_OUT);
	engine->RegisterEnumValue("key_code", "KEY_OPER", SDL_SCANCODE_OPER);
	engine->RegisterEnumValue("key_code", "KEY_CLEARAGAIN", SDL_SCANCODE_CLEARAGAIN);
	engine->RegisterEnumValue("key_code", "KEY_CRSEL", SDL_SCANCODE_CRSEL);
	engine->RegisterEnumValue("key_code", "KEY_EXSEL", SDL_SCANCODE_EXSEL);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_00", SDL_SCANCODE_KP_00);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_000", SDL_SCANCODE_KP_000);
	engine->RegisterEnumValue("key_code", "KEY_THOUSANDSSEPARATOR", SDL_SCANCODE_THOUSANDSSEPARATOR);
	engine->RegisterEnumValue("key_code", "KEY_DECIMALSEPARATOR", SDL_SCANCODE_DECIMALSEPARATOR);
	engine->RegisterEnumValue("key_code", "KEY_CURRENCYUNIT", SDL_SCANCODE_CURRENCYUNIT);
	engine->RegisterEnumValue("key_code", "KEY_CURRENCYSUBUNIT", SDL_SCANCODE_CURRENCYSUBUNIT);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_LEFTPAREN", SDL_SCANCODE_KP_LEFTPAREN);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_RIGHTPAREN", SDL_SCANCODE_KP_RIGHTPAREN);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_LEFTBRACE", SDL_SCANCODE_KP_LEFTBRACE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_RIGHTBRACE", SDL_SCANCODE_KP_RIGHTBRACE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_TAB", SDL_SCANCODE_KP_TAB);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_BACKSPACE", SDL_SCANCODE_KP_BACKSPACE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_A", SDL_SCANCODE_KP_A);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_B", SDL_SCANCODE_KP_B);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_C", SDL_SCANCODE_KP_C);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_D", SDL_SCANCODE_KP_D);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_E", SDL_SCANCODE_KP_E);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_F", SDL_SCANCODE_KP_F);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_XOR", SDL_SCANCODE_KP_XOR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_POWER", SDL_SCANCODE_KP_POWER);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_PERCENT", SDL_SCANCODE_KP_PERCENT);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_LESS", SDL_SCANCODE_KP_LESS);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_GREATER", SDL_SCANCODE_KP_GREATER);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_AMPERSAND", SDL_SCANCODE_KP_AMPERSAND);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_DBLAMPERSAND", SDL_SCANCODE_KP_DBLAMPERSAND);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_VERTICALBAR", SDL_SCANCODE_KP_VERTICALBAR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_DBLVERTICALBAR", SDL_SCANCODE_KP_DBLVERTICALBAR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_COLON", SDL_SCANCODE_KP_COLON);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_HASH", SDL_SCANCODE_KP_HASH);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_SPACE", SDL_SCANCODE_KP_SPACE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_AT", SDL_SCANCODE_KP_AT);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_EXCLAM", SDL_SCANCODE_KP_EXCLAM);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMSTORE", SDL_SCANCODE_KP_MEMSTORE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMRECALL", SDL_SCANCODE_KP_MEMRECALL);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMCLEAR", SDL_SCANCODE_KP_MEMCLEAR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMADD", SDL_SCANCODE_KP_MEMADD);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMSUBTRACT", SDL_SCANCODE_KP_MEMSUBTRACT);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMMULTIPLY", SDL_SCANCODE_KP_MEMMULTIPLY);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_MEMDIVIDE", SDL_SCANCODE_KP_MEMDIVIDE);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_PLUSMINUS", SDL_SCANCODE_KP_PLUSMINUS);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_CLEAR", SDL_SCANCODE_KP_CLEAR);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_CLEARENTRY", SDL_SCANCODE_KP_CLEARENTRY);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_BINARY", SDL_SCANCODE_KP_BINARY);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_OCTAL", SDL_SCANCODE_KP_OCTAL);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_DECIMAL", SDL_SCANCODE_KP_DECIMAL);
	engine->RegisterEnumValue("key_code", "KEY_NUMPAD_HEXADECIMAL", SDL_SCANCODE_KP_HEXADECIMAL);
	engine->RegisterEnumValue("key_code", "KEY_LCTRL", SDL_SCANCODE_LCTRL);
	engine->RegisterEnumValue("key_code", "KEY_LSHIFT", SDL_SCANCODE_LSHIFT);
	engine->RegisterEnumValue("key_code", "KEY_LALT", SDL_SCANCODE_LALT);
	engine->RegisterEnumValue("key_code", "KEY_LGUI", SDL_SCANCODE_LGUI);
	engine->RegisterEnumValue("key_code", "KEY_RCTRL", SDL_SCANCODE_RCTRL);
	engine->RegisterEnumValue("key_code", "KEY_RSHIFT", SDL_SCANCODE_RSHIFT);
	engine->RegisterEnumValue("key_code", "KEY_RALT", SDL_SCANCODE_RALT);
	engine->RegisterEnumValue("key_code", "KEY_RGUI", SDL_SCANCODE_RGUI);
	engine->RegisterEnumValue("key_code", "KEY_MODE", SDL_SCANCODE_MODE);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_NEXT_TRACK", SDL_SCANCODE_MEDIA_NEXT_TRACK);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_PREVIOUS_TRACK", SDL_SCANCODE_MEDIA_PREVIOUS_TRACK);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_STOP", SDL_SCANCODE_MEDIA_STOP);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_PLAY", SDL_SCANCODE_MEDIA_PLAY);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_SELECT", SDL_SCANCODE_MEDIA_SELECT);
	engine->RegisterEnumValue("key_code", "KEY_AC_SEARCH", SDL_SCANCODE_AC_SEARCH);
	engine->RegisterEnumValue("key_code", "KEY_AC_HOME", SDL_SCANCODE_AC_HOME);
	engine->RegisterEnumValue("key_code", "KEY_AC_BACK", SDL_SCANCODE_AC_BACK);
	engine->RegisterEnumValue("key_code", "KEY_AC_FORWARD", SDL_SCANCODE_AC_FORWARD);
	engine->RegisterEnumValue("key_code", "KEY_AC_STOP", SDL_SCANCODE_AC_STOP);
	engine->RegisterEnumValue("key_code", "KEY_AC_REFRESH", SDL_SCANCODE_AC_REFRESH);
	engine->RegisterEnumValue("key_code", "KEY_AC_BOOKMARKS", SDL_SCANCODE_AC_BOOKMARKS);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_EJECT", SDL_SCANCODE_MEDIA_EJECT);
	engine->RegisterEnumValue("key_code", "KEY_SLEEP", SDL_SCANCODE_SLEEP);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_REWIND", SDL_SCANCODE_MEDIA_REWIND);
	engine->RegisterEnumValue("key_code", "KEY_MEDIA_FAST_FORWARD", SDL_SCANCODE_MEDIA_FAST_FORWARD);
	engine->RegisterEnumValue("key_code", "KEY_SOFTLEFT", SDL_SCANCODE_SOFTLEFT);
	engine->RegisterEnumValue("key_code", "KEY_SOFTRIGHT", SDL_SCANCODE_SOFTRIGHT);
	engine->RegisterEnumValue("key_code", "KEY_CALL", SDL_SCANCODE_CALL);
	engine->RegisterEnumValue("key_code", "KEY_ENDCALL", SDL_SCANCODE_ENDCALL);
	// Joystick enumerations
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_UNKNOWN", SDL_GAMEPAD_TYPE_UNKNOWN);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_STANDARD", SDL_GAMEPAD_TYPE_STANDARD);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_XBOX360", SDL_GAMEPAD_TYPE_XBOX360);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_XBOX1", SDL_GAMEPAD_TYPE_XBOXONE);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_PS3", SDL_GAMEPAD_TYPE_PS3);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_PS4", SDL_GAMEPAD_TYPE_PS4);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_NINTENDO_SWITCH_PRO", SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_PS5", SDL_GAMEPAD_TYPE_PS5);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_NINTENDO_SWITCH_JOYCON_LEFT", SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT", SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT);
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_NINTENDO_SWITCH_JOYCON_PAIR", SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR);
	engine->RegisterEnumValue("joystick_bind_type", "JOYSTICK_BIND_TYPE_NONE", SDL_GAMEPAD_BINDTYPE_NONE);
	engine->RegisterEnumValue("joystick_bind_type", "JOYSTICK_BIND_TYPE_BUTTON", SDL_GAMEPAD_BINDTYPE_BUTTON);
	engine->RegisterEnumValue("joystick_bind_type", "JOYSTICK_BIND_TYPE_AXIS", SDL_GAMEPAD_BINDTYPE_AXIS);
	engine->RegisterEnumValue("joystick_bind_type", "JOYSTICK_BIND_TYPE_HAT", SDL_GAMEPAD_BINDTYPE_HAT);
	// SDL_PowerState enum values for joystick power state
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_ERROR", SDL_POWERSTATE_ERROR);
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_UNKNOWN", SDL_POWERSTATE_UNKNOWN);
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_ON_BATTERY", SDL_POWERSTATE_ON_BATTERY);
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_NO_BATTERY", SDL_POWERSTATE_NO_BATTERY);
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_CHARGING", SDL_POWERSTATE_CHARGING);
	engine->RegisterEnumValue("joystick_power_state", "JOYSTICK_POWER_CHARGED", SDL_POWERSTATE_CHARGED);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_INVALID", SDL_GAMEPAD_BUTTON_INVALID);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_A", SDL_GAMEPAD_BUTTON_SOUTH);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_B", SDL_GAMEPAD_BUTTON_EAST);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_X", SDL_GAMEPAD_BUTTON_WEST);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_Y", SDL_GAMEPAD_BUTTON_NORTH);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_BACK", SDL_GAMEPAD_BUTTON_BACK);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_GUIDE", SDL_GAMEPAD_BUTTON_GUIDE);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_START", SDL_GAMEPAD_BUTTON_START);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_LEFT_STICK", SDL_GAMEPAD_BUTTON_LEFT_STICK);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_RIGHT_STICK", SDL_GAMEPAD_BUTTON_RIGHT_STICK);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_LEFT_SHOULDER", SDL_GAMEPAD_BUTTON_LEFT_SHOULDER);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_RIGHT_SHOULDER", SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_DPAD_UP", SDL_GAMEPAD_BUTTON_DPAD_UP);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_DPAD_DOWN", SDL_GAMEPAD_BUTTON_DPAD_DOWN);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_DPAD_LEFT", SDL_GAMEPAD_BUTTON_DPAD_LEFT);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_DPAD_RIGHT", SDL_GAMEPAD_BUTTON_DPAD_RIGHT);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_BUTTON_MISC", SDL_GAMEPAD_BUTTON_MISC1);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_PADDLE1", SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_PADDLE2", SDL_GAMEPAD_BUTTON_LEFT_PADDLE1);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_PADDLE3", SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_PADDLE4", SDL_GAMEPAD_BUTTON_LEFT_PADDLE2);
	engine->RegisterEnumValue("joystick_control_type", "JOYSTICK_CONTROL_TOUCHPAD", SDL_GAMEPAD_BUTTON_TOUCHPAD);
	engine->RegisterGlobalFunction(_O("int joystick_count(bool = true)"), asFUNCTION(joystick_count), asCALL_CDECL);
	// Register joystick_power_info struct
	engine->RegisterObjectType("joystick_power_info", sizeof(joystick_power_info), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS_ALLINTS | asGetTypeTraits<joystick_power_info>());
	engine->RegisterObjectBehaviour("joystick_power_info", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(joystick_power_info_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("joystick_power_info", asBEHAVE_CONSTRUCT, "void f(int, int)", asFUNCTION(joystick_power_info_construct_params), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("joystick_power_info", asBEHAVE_CONSTRUCT, "void f(const joystick_power_info&in)", asFUNCTION(joystick_power_info_copy_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("joystick_power_info", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(joystick_power_info_destruct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("joystick_power_info", "int state", asOFFSET(joystick_power_info, state));
	engine->RegisterObjectProperty("joystick_power_info", "int percentage", asOFFSET(joystick_power_info, percentage));
	engine->RegisterObjectMethod("joystick_power_info", "string get_state_name() const property", asMETHOD(joystick_power_info, get_state_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick_power_info", "string to_string() const", asMETHOD(joystick_power_info, to_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick_power_info", "string opConv() const", asMETHOD(joystick_power_info, to_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick_power_info", "string opImplConv() const", asMETHOD(joystick_power_info, to_string), asCALL_THISCALL);
	engine->RegisterObjectType("joystick", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("joystick", asBEHAVE_FACTORY, "joystick@ f()", asFUNCTION(joystick_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("joystick", asBEHAVE_ADDREF, "void f()", asMETHOD(joystick, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("joystick", asBEHAVE_RELEASE, "void f()", asMETHOD(joystick, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "uint get_joysticks() const property", asMETHOD(joystick, get_joysticks), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_x() const property", asMETHOD(joystick, get_has_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_y() const property", asMETHOD(joystick, get_has_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_z() const property", asMETHOD(joystick, get_has_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_r_x() const property", asMETHOD(joystick, get_has_r_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_r_y() const property", asMETHOD(joystick, get_has_r_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_r_z() const property", asMETHOD(joystick, get_has_r_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "uint get_buttons() const property", asMETHOD(joystick, get_buttons), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "uint get_sliders() const property", asMETHOD(joystick, get_sliders), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "uint get_povs() const property", asMETHOD(joystick, get_povs), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "string get_name() const property", asMETHOD(joystick, get_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_active() const property", asMETHOD(joystick, get_active), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_preferred_joystick() const property", asMETHOD(joystick, get_preferred_joystick), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "void set_preferred_joystick(int index) property", asMETHOD(joystick, set_preferred_joystick), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_x() const property", asMETHOD(joystick, get_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_y() const property", asMETHOD(joystick, get_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_z() const property", asMETHOD(joystick, get_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_r_x() const property", asMETHOD(joystick, get_r_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_r_y() const property", asMETHOD(joystick, get_r_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_r_z() const property", asMETHOD(joystick, get_r_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_slider_1() const property", asMETHOD(joystick, get_slider_1), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_slider_2() const property", asMETHOD(joystick, get_slider_2), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_pov_1() const property", asMETHOD(joystick, get_pov_1), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_pov_2() const property", asMETHOD(joystick, get_pov_2), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_pov_3() const property", asMETHOD(joystick, get_pov_3), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_pov_4() const property", asMETHOD(joystick, get_pov_4), asCALL_THISCALL);
	// Velocity properties (not implemented in SDL, return 0)
	engine->RegisterObjectMethod("joystick", "int get_v_x() const property", asMETHOD(joystick, get_v_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_v_y() const property", asMETHOD(joystick, get_v_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_v_z() const property", asMETHOD(joystick, get_v_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_vr_x() const property", asMETHOD(joystick, get_vr_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_vr_y() const property", asMETHOD(joystick, get_vr_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_vr_z() const property", asMETHOD(joystick, get_vr_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_v_slider_1() const property", asMETHOD(joystick, get_v_slider_1), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_v_slider_2() const property", asMETHOD(joystick, get_v_slider_2), asCALL_THISCALL);
	// Acceleration properties (not implemented in SDL, return 0)
	engine->RegisterObjectMethod("joystick", "int get_a_x() const property", asMETHOD(joystick, get_a_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_a_y() const property", asMETHOD(joystick, get_a_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_a_z() const property", asMETHOD(joystick, get_a_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_ar_x() const property", asMETHOD(joystick, get_ar_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_ar_y() const property", asMETHOD(joystick, get_ar_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_ar_z() const property", asMETHOD(joystick, get_ar_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_a_slider_1() const property", asMETHOD(joystick, get_a_slider_1), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_a_slider_2() const property", asMETHOD(joystick, get_a_slider_2), asCALL_THISCALL);
	// Force feedback properties (not implemented in SDL, return 0)
	engine->RegisterObjectMethod("joystick", "int get_f_x() const property", asMETHOD(joystick, get_f_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_f_y() const property", asMETHOD(joystick, get_f_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_f_z() const property", asMETHOD(joystick, get_f_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_fr_x() const property", asMETHOD(joystick, get_fr_x), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_fr_y() const property", asMETHOD(joystick, get_fr_y), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_fr_z() const property", asMETHOD(joystick, get_fr_z), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_f_slider_1() const property", asMETHOD(joystick, get_f_slider_1), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_f_slider_2() const property", asMETHOD(joystick, get_f_slider_2), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool button_down(int button)", asMETHOD(joystick, button_down), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool button_pressed(int button)", asMETHOD(joystick, button_pressed), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool button_released(int button)", asMETHOD(joystick, button_released), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool button_up(int button)", asMETHOD(joystick, button_up), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int[]@ buttons_down()", asMETHOD(joystick, buttons_down), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int[]@ buttons_pressed()", asMETHOD(joystick, buttons_pressed), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int[]@ buttons_released()", asMETHOD(joystick, buttons_released), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int[]@ buttons_up()", asMETHOD(joystick, buttons_up), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "string[]@ list_joysticks()", asMETHOD(joystick, list_joysticks), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool pov_centered(int pov)", asMETHOD(joystick, pov_centered), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool refresh_joystick_list()", asMETHOD(joystick, refresh_joystick_list), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool set(int index)", asMETHOD(joystick, set), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "uint get_type() const property", asMETHOD(joystick, type), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "joystick_power_info get_power_info() const property", asMETHOD(joystick, get_power_info), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_led() const property", asMETHOD(joystick, has_led), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_can_vibrate() const property", asMETHOD(joystick, can_vibrate), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_can_vibrate_triggers() const property", asMETHOD(joystick, can_vibrate_triggers), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "int get_touchpads() const property", asMETHOD(joystick, touchpads), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "string get_serial() const property", asMETHOD(joystick, serial), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool set_led(uint8 red, uint8 green, uint8 blue)", asMETHOD(joystick, set_led), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool vibrate(uint16 low_frequency, uint16 high_frequency, int duration)", asMETHOD(joystick, vibrate), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool vibrate_triggers(uint16 left, uint16 right, int duration)", asMETHOD(joystick, vibrate_triggers), asCALL_THISCALL);
}
