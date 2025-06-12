/* input.h - human input handling header
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

#include <string>
#include <angelscript.h>
#include <scriptarray.h>
#include <Poco/RefCountedObject.h>

union SDL_Event;
extern std::string g_UserInput;

class joystick : Poco::RefCountedObject {
	SDL_Gamepad* stick;

public:
	unsigned int type() const;
	unsigned int power_level() const;
	bool has_led() const;
	bool can_vibrate() const;
	bool can_vibrate_triggers() const;
	int touchpads() const;
	unsigned int buttons() const;
	unsigned int sliders() const;
	unsigned int povs() const;
	std::string name() const;
	bool active() const;
	std::string serial() const;
	int preferred_joystick() const;
	unsigned int x() const;
	unsigned int y() const;
	unsigned int z() const;
	unsigned int r_x() const;
	unsigned int r_y() const;
	unsigned int r_z() const;
	unsigned int slider_1() const;
	unsigned int slider_2() const;
	unsigned int pov_1() const;
	unsigned int pov_2() const;
	unsigned int pov_3() const;
	unsigned int pov_4() const;
	unsigned int v_x() const;
	unsigned int v_y() const;
	unsigned int v_z() const;
	unsigned int vr_x() const;
	unsigned int vr_y() const;
	unsigned int vr_z() const;
	unsigned int v_slider_1() const;
	unsigned int v_slider_2() const;
	unsigned int a_x() const;
	unsigned int a_y() const;
	unsigned int a_z() const;
	unsigned int ar_x() const;
	unsigned int ar_y() const;
	unsigned int ar_z() const;
	unsigned int a_slider_1() const;
	unsigned int a_slider_2() const;
	unsigned int f_x() const;
	unsigned int f_y() const;
	unsigned int f_z() const;
	unsigned int fr_x() const;
	unsigned int fr_y() const;
	unsigned int fr_z() const;
	unsigned int f_slider_1() const;
	unsigned int f_slider_2() const;

	joystick();
	~joystick();
	bool button_down(int button);
	bool button_pressed(int button);
	bool button_released(int button);
	bool button_up(int button);
	CScriptArray* buttons_down();
	CScriptArray* buttons_pressed();
	CScriptArray* buttons_released();
	CScriptArray* buttons_up();
	CScriptArray* list_joysticks();
	bool pov_centered(int pov);
	bool set_led(unsigned char red, unsigned char green, unsigned char blue);
	bool vibrate(unsigned short low_frequency, unsigned short high_frequency, int duration);
	bool vibrate_triggers(unsigned short left, unsigned short right, int duration);
	bool refresh_joystick_list();
	bool set(int index);
};

void InputInit();
void InputDestroy();
bool InputEvent(SDL_Event* evt);
void InputClearFrame();
void lost_window_focus();
void regained_window_focus();
void RegisterInput(asIScriptEngine* engine);
