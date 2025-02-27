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
#else
	#include <cstring>
#endif
#include <SDL3/SDL.h>
#include <angelscript.h>
#include <obfuscate.h>
#include <sstream>
#include <string>
#include <unordered_map>
#include <functional>
#include "nvgt_angelscript.h"
#include "input.h"
#include "misc_functions.h"
#include "nvgt.h"
#include "UI.h"

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
static HHOOK g_keyhook_hHook = nullptr;
bool g_keyhook_active = false;
#endif
// Wrapper function for sdl
//  This function is useful for getting keyboard, mice and touch devices.
// Pass the callback with the signature `unsigned int*(int*)`
CScriptArray* GetDevices(std::function<uint32_t*(int*)> callback) {
	asITypeInfo* array_type = get_array_type("uint[]");
	if (!array_type) return nullptr;
	int device_count = 0;
	uint32_t* devices = callback(&device_count);
	if (!devices) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) {
		SDL_free(devices);
		return nullptr;
	}
	array->Reserve(device_count);
	for (int i = 0; i < device_count; i++) array->InsertLast(devices + i);
	SDL_free(devices);
	return array;
}
void InputInit() {
	if (SDL_WasInit(0)&SDL_INIT_VIDEO) return;
	memset(g_KeysPressed, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysRepeating, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysForced, 0, SDL_SCANCODE_COUNT);
	memset(g_KeysReleased, 0, SDL_SCANCODE_COUNT);
	SDL_Init(SDL_INIT_VIDEO);
	g_KeysDown = SDL_GetKeyboardState(&g_KeysDownArrayLen);
}
void InputDestroy() {
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
	else if (evt->type == SDL_EVENT_FINGER_DOWN) g_TouchLastDevice = evt->tfinger.touchID;
	else return false;
	return true;
}

void remove_keyhook();
bool install_keyhook(bool allow_reinstall = true);
void lost_window_focus() {
	SDL_ResetKeyboard();
	#ifdef _WIN32
	if (g_keyhook_active) remove_keyhook();
	#endif
}
void regained_window_focus() {
	#ifdef _WIN32
	if (g_keyhook_active) install_keyhook();
	#endif
}
bool ScreenKeyboardShown() {
	return SDL_ScreenKeyboardShown(g_WindowHandle);
}
unsigned int GetKeyCode(const std::string& name) {
	if (name.empty()) return SDLK_UNKNOWN;
	return SDL_GetScancodeFromName(name.c_str());
}
std::string GetKeyName(unsigned int key) {
	if (key >= SDL_SCANCODE_COUNT) return "";
	const char* result = SDL_GetScancodeName(static_cast<SDL_Scancode>(key));
	if (!result) return "";
	return result;
}
bool SetKeyName(unsigned int key, const std::string& name) {
	if (key >= SDL_SCANCODE_COUNT || name.empty()) return false;
	g_KeyNames[key] = name;
	return SDL_SetScancodeName(static_cast<SDL_Scancode>(key), g_KeyNames[key].c_str());
}
bool KeyPressed(unsigned int key) {
	if (key >= SDL_SCANCODE_COUNT) return false;
	bool r = g_KeysPressed[key] == 1;
	g_KeysPressed[key] = 0;
	return r;
}
bool KeyRepeating(unsigned int key) {
	if (key >= SDL_SCANCODE_COUNT) return false;
	bool r = g_KeysPressed[key] == 1 || g_KeysRepeating[key] == 1;
	g_KeysPressed[key] = 0;
	g_KeysRepeating[key] = 0;
	return r;
}
bool key_down(unsigned int key) {
	if (key >= SDL_SCANCODE_COUNT || !g_KeysDown) return false;
	return g_KeysReleased[key] == 0 && (g_KeysDown[key] == 1 || g_KeysForced[key]);
}
bool KeyReleased(unsigned int key) {
	if (key >= SDL_SCANCODE_COUNT || !g_KeysDown) return false;
	bool r = g_KeysReleased[key] == 1;
	if (r && g_KeysDown[key] == 1) return false;
	g_KeysReleased[key] = 0;
	return r;
}
bool key_up(unsigned int key) {
	return !key_down(key);
}
bool insure_key_up(unsigned short key) {
	if (key >= SDL_SCANCODE_COUNT || !g_KeysDown) return false;
	if (g_KeysDown[key] == 1)
		g_KeysReleased[key] = 1;
	else
		return false;
	g_KeysForced[key] = false;
	return true;
}
inline bool post_key_event(unsigned int key, SDL_EventType evt_type) {
	if (key >= SDL_SCANCODE_COUNT || !g_KeysDown) return false;
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
	evt_type == SDL_EVENT_KEY_DOWN? SDL_SetModState(SDL_GetModState() | mods) : SDL_SetModState(SDL_GetModState() & ~mods);
	e.key.key = SDL_GetKeyFromScancode(e.key.scancode, SDL_GetModState(), true);
	return SDL_PushEvent(&e);
}
bool simulate_key_down(unsigned int key) { return post_key_event(key, SDL_EVENT_KEY_DOWN); }
bool simulate_key_up(unsigned int key) { return post_key_event(key, SDL_EVENT_KEY_UP); }
CScriptArray* keys_pressed() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!key_code_array_type)
		key_code_array_type = engine->GetTypeInfoByDecl("array<key_code>");
	CScriptArray* array = CScriptArray::Create(key_code_array_type);
	for (int i = 0; i < SDL_SCANCODE_COUNT; i++) {
		unsigned int k = (unsigned int)i;
		if (KeyPressed(k))
			array->InsertLast(&k);
	}
	return array;
}
CScriptArray* keys_down() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!key_code_array_type)
		key_code_array_type = engine->GetTypeInfoByDecl("array<key_code>");
	CScriptArray* array = CScriptArray::Create(key_code_array_type);
	if (!g_KeysDown) return array;
	for (int i = 0; i < g_KeysDownArrayLen; i++) {
		if (g_KeysDown[i] == 1 || g_KeysForced[i])
			array->InsertLast(&i);
	}
	return array;
}
int g_TotalKeysDownCache = -1;
int total_keys_down() {
	if (!g_KeysDown) return 0;
	if (!g_KeyboardStateChange && g_TotalKeysDownCache > 0) return g_TotalKeysDownCache;
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
		key_code_array_type = engine->GetTypeInfoByDecl("array<key_code>");
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
	if (button > 31) return false;
	bool r = g_MouseButtonsPressed[button] == 1;
	g_MouseButtonsPressed[button] = 0;
	return r;
}
bool mouse_down(unsigned char button) {
	if (button > 31) return false;
	if (!g_KeysDown) return false;
	return (SDL_GetMouseState(&g_MouseAbsX, &g_MouseAbsY)&SDL_BUTTON(button)) != 0;
}
bool MouseReleased(unsigned char button) {
	if (button > 31) return false;
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
	state? SDL_ShowCursor() : SDL_HideCursor();
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
	if (!result) return "";
	return result;
}
CScriptArray* GetMice() {
	return GetDevices(SDL_GetMice);
}
std::string GetMouseName(unsigned int id) {
	const char* result = SDL_GetMouseNameForID((SDL_MouseID)id);
	if (!result) return "";
	return result;
}



/* unfinished joystick stuff - to be converted to SDL3
int joystick_count(bool only_active = true) {
	int total_joysticks;
	SDL_JoystickID* sticks = SDL_GetJoysticks(&total_joysticks);
	SDL_free(sticks);
	if (!only_active) return total_joysticks;
	int ret = 0;
	for (int i = 0; i < total_joysticks; i++) {
		if (SDL_IsGamepad(i))
			ret++;
	}
	return ret;
}
CScriptArray* joystick_mappings() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	if (!joystick_mapping_array_type)
		joystick_mapping_array_type = engine->GetTypeInfoByDecl("array<string>@");
	CScriptArray* array = CScriptArray::Create(joystick_mapping_array_type);
	int num_mappings = SDL_GameControllerNumMappings();
	for (int i = 0; i < num_mappings; i++) {
		std::string mapping = SDL_GameControllerMappingForIndex(i);
		array->InsertLast(&mapping);
	}
	return array;
}

joystick::joystick() {
	if (joystick_count() > 0)
		stick = SDL_OpenGamepad(0);
}
joystick::~joystick() {
	SDL_CloseGamepad(stick);
}

unsigned int joystick::type() const {
	return SDL_GetGamepadType(stick);
}
unsigned int joystick::power_level() const {
	return SDL_JoystickCurrentPowerLevel(SDL_GetGamepadJoystick(stick));
}
std::string joystick::name() const {
	return SDL_GetGamepadName(stick);
}
bool joystick::active() const {
	return SDL_GamepadConnected(stick);
}
std::string joystick::serial() const {
	const char* serial = SDL_GetGamepadSerial(stick);
	if (serial == nullptr) return "";
	return std::string(serial);
}
bool joystick::has_led() const {
	return SDL_GameControllerHasLED(stick);
}
bool joystick::can_vibrate() const {
	return SDL_GameControllerHasRumble(stick);
}
bool joystick::can_vibrate_triggers() const {
	return SDL_GameControllerHasRumbleTriggers(stick);
}
int joystick::touchpads() const {
	return SDL_GetNumGamepadTouchpads(stick);
}

bool joystick::set_led(unsigned char red, unsigned char green, unsigned char blue) {
	return SDL_SetGamepadLED(stick, red, green, blue);
}
bool joystick::vibrate(unsigned short low_frequency, unsigned short high_frequency, int duration) {
	return SDL_RumbleGamepad(stick, low_frequency, high_frequency, duration);
}
bool joystick::vibrate_triggers(unsigned short left, unsigned short right, int duration) {
	return SDL_RumbleGamepadTriggers(stick, left, right, duration);
}
*/

#ifdef _WIN32
// Thanks Quentin Cosendey (Universal Speech) for this jaws keyboard hook code as well as to male-srdiecko and silak for various improvements and fixes that have taken place since initial implementation.
bool altPressed = false;
bool capsPressed = false;
bool insertPressed = false;

LRESULT CALLBACK HookKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
	if (nCode != HC_ACTION)
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
			return 0; // Do nothing for other keys
	}

	return CallNextHookEx(g_keyhook_hHook, nCode, wParam, lParam);
}
#endif

void uninstall_keyhook();
bool install_keyhook(bool allow_reinstall) {
	#ifdef _WIN32
	if (g_keyhook_hHook && !allow_reinstall) return false;
	if (g_keyhook_hHook) uninstall_keyhook();
	g_keyhook_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, HookKeyboardProc, GetModuleHandle(NULL), NULL);
	g_keyhook_active = true;
	return g_keyhook_hHook ? true : false;
	#else
	return false;
	#endif
}
void remove_keyhook() {
	#ifdef _WIN32
	if (!g_keyhook_hHook) return;
	UnhookWindowsHookEx(g_keyhook_hHook);
	g_keyhook_hHook = NULL;
	#endif
}
void uninstall_keyhook() {
	#ifdef _WIN32
	remove_keyhook();
	g_keyhook_active = false;
	#endif
}

// Low level touch interface
CScriptArray* get_touch_devices() {
	asITypeInfo* array_type = get_array_type("uint64[]");
	if (!array_type) return nullptr;
	int device_count;
	SDL_TouchID* devices = SDL_GetTouchDevices(&device_count);
	if (!devices) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) {
		SDL_free(devices);
		return nullptr;;
	}
	array->Reserve(device_count);
	for (int i = 0; i < device_count; i++) array->InsertLast(devices + i);
	SDL_free(devices);
	return array;
}
std::string get_touch_device_name(uint64_t device_id) {
	const char* result = SDL_GetTouchDeviceName((SDL_TouchID)device_id);
	if (!result) return "";
	return result;
}
int get_touch_device_type(uint64_t device_id) {
	return SDL_GetTouchDeviceType((SDL_TouchID)device_id);
}
CScriptArray* query_touch_device(uint64_t device_id) {
	asITypeInfo* array_type = get_array_type("touch_finger[]");
	if (!array_type) return nullptr;
	CScriptArray* array = CScriptArray::Create(array_type);
	if (!array) return nullptr;
	if (!device_id && g_TouchLastDevice) device_id = g_TouchLastDevice;
	if (!device_id) return array;
	int finger_count;
	SDL_Finger** fingers = SDL_GetTouchFingers(device_id, &finger_count);
	if (!fingers) return array;
	array->Reserve(finger_count);
	for (int i = 0; i < finger_count; i++) array->InsertLast(*(fingers + i));
	SDL_free(fingers);
	return array;
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
	engine->RegisterEnum(_O("joystick_power_level"));
	engine->RegisterEnum(_O("joystick_control_type"));
	engine->RegisterGlobalFunction(_O("bool get_KEYBOARD_AVAILABLE() property"), asFUNCTION(SDL_HasKeyboard), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint get_key_code(const string&in name)"), asFUNCTION(GetKeyCode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_key_name(uint key)"), asFUNCTION(GetKeyName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool set_key_name(uint key, const string&in name)"), asFUNCTION(SetKeyName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_pressed(uint key)"), asFUNCTION(KeyPressed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_repeating(uint key)"), asFUNCTION(KeyRepeating), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_down(uint key)"), asFUNCTION(key_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_released(uint key)"), asFUNCTION(KeyReleased), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool key_up(uint key)"), asFUNCTION(key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool insure_key_up(uint key)"), asFUNCTION(insure_key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool simulate_key_down(uint key)"), asFUNCTION(simulate_key_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool simulate_key_up(uint key)"), asFUNCTION(simulate_key_up), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("key_code[]@ keys_pressed()"), asFUNCTION(keys_pressed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("key_code[]@ keys_down()"), asFUNCTION(keys_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint total_keys_down()"), asFUNCTION(total_keys_down), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("key_code[]@ keys_released()"), asFUNCTION(keys_released), asCALL_CDECL);
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
	engine->RegisterGlobalFunction(_O("bool install_keyhook(bool=true)"), asFUNCTION(install_keyhook), asCALL_CDECL);
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
	engine->RegisterEnumValue("touch_device_type", "TOUCH_DEVICE_TYPE_INVLAID", SDL_TOUCH_DEVICE_INVALID);
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
	/* joystick stuff needs converting to SDL3
	engine->RegisterEnumValue("joystick_type", "JOYSTICK_TYPE_UNKNOWN", SDL_GAMEPAD_TYPE_STANDARD);
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
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_UNKNOWN", SDL_JOYSTICK_POWER_UNKNOWN);
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_EMPTY", SDL_JOYSTICK_POWER_EMPTY);
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_LOW", SDL_JOYSTICK_POWER_LOW);
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_MEDIUM", SDL_JOYSTICK_POWER_MEDIUM);
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_FULL", SDL_JOYSTICK_POWER_FULL);
	engine->RegisterEnumValue("joystick_power_level", "JOYSTICK_POWER_WIRED", SDL_JOYSTICK_POWER_WIRED);
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
	engine->RegisterGlobalFunction("int joystick_count(bool = true)", asFUNCTION(joystick_count), asCALL_CDECL);
	engine->RegisterGlobalFunction("array<string>@ joystick_mappings()", asFUNCTION(joystick_mappings), asCALL_CDECL);
	engine->RegisterObjectType("joystick", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("joystick", asBEHAVE_ADDREF, "void f()", asMETHODPR(joystick, duplicate, () const, void), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("async<T>", asBEHAVE_RELEASE, "void f()", asMETHODPR(async_result, release, () const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("joystick", "bool get_has_LED() const property", asFUNCTION(SDL_GameControllerHasLED), asCALL_CDECL_OBJFIRST, 0, asOFFSET(joystick, stick), false);
	end joystick stuff*/
}
