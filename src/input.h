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
#include <vector>
#include <angelscript.h>
#include <scriptarray.h>
#include <Poco/RefCountedObject.h>

union SDL_Event;
extern std::string g_UserInput;

class joystick : public Poco::RefCountedObject {
    SDL_Gamepad* stick;
    SDL_Joystick* js_handle; // For low-level joystick access
    int current_index;
    std::vector<bool> button_states;
    std::vector<bool> button_pressed_states;
    std::vector<bool> button_released_states;
    std::vector<int16_t> axis_values;
    std::vector<uint8_t> hat_values;

public:
    // BGT compatibility properties
    unsigned int get_joysticks() const;
    bool get_has_x() const;
    bool get_has_y() const;
    bool get_has_z() const;
    bool get_has_r_x() const;
    bool get_has_r_y() const;
    bool get_has_r_z() const;
    unsigned int get_buttons() const;
    unsigned int get_sliders() const;
    unsigned int get_povs() const;
    std::string get_name() const;
    bool get_active() const;
    int get_preferred_joystick() const;
    void set_preferred_joystick(int index);

    // Axis position properties (BGT compatibility)
    int get_x() const;
    int get_y() const;
    int get_z() const;
    int get_r_x() const;
    int get_r_y() const;
    int get_r_z() const;
    int get_slider_1() const;
    int get_slider_2() const;
    int get_pov_1() const;
    int get_pov_2() const;
    int get_pov_3() const;
    int get_pov_4() const;

    // Velocity properties (BGT compatibility - not implemented in SDL)
    int get_v_x() const {
        return 0;
    }
    int get_v_y() const {
        return 0;
    }
    int get_v_z() const {
        return 0;
    }
    int get_vr_x() const {
        return 0;
    }
    int get_vr_y() const {
        return 0;
    }
    int get_vr_z() const {
        return 0;
    }
    int get_v_slider_1() const {
        return 0;
    }
    int get_v_slider_2() const {
        return 0;
    }

    // Acceleration properties (BGT compatibility - not implemented in SDL)
    int get_a_x() const {
        return 0;
    }
    int get_a_y() const {
        return 0;
    }
    int get_a_z() const {
        return 0;
    }
    int get_ar_x() const {
        return 0;
    }
    int get_ar_y() const {
        return 0;
    }
    int get_ar_z() const {
        return 0;
    }
    int get_a_slider_1() const {
        return 0;
    }
    int get_a_slider_2() const {
        return 0;
    }

    // Force feedback properties (BGT compatibility - not implemented in SDL)
    int get_f_x() const {
        return 0;
    }
    int get_f_y() const {
        return 0;
    }
    int get_f_z() const {
        return 0;
    }
    int get_fr_x() const {
        return 0;
    }
    int get_fr_y() const {
        return 0;
    }
    int get_fr_z() const {
        return 0;
    }
    int get_f_slider_1() const {
        return 0;
    }
    int get_f_slider_2() const {
        return 0;
    }

    // Additional modern properties
    unsigned int type() const;
    unsigned int power_level() const;
    bool has_led() const;
    bool can_vibrate() const;
    bool can_vibrate_triggers() const;
    int touchpads() const;
    std::string serial() const;

    joystick();
    ~joystick();

    // BGT compatibility methods
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
    bool refresh_joystick_list();
    bool set(int index);

    // Additional modern methods
    bool set_led(unsigned char red, unsigned char green, unsigned char blue);
    bool vibrate(unsigned short low_frequency, unsigned short high_frequency, int duration);
    bool vibrate_triggers(unsigned short left, unsigned short right, int duration);

    // Internal update method
    void update();
};

void JoystickInit();
void InputInit();
void InputDestroy();
bool InputEvent(SDL_Event* evt);
void lost_window_focus();
void regained_window_focus();
void update_joysticks();
void RegisterInput(asIScriptEngine* engine);

#ifdef _WIN32
// Keyhook functions
bool install_keyhook();
void uninstall_keyhook();
void remove_keyhook();
bool reinstall_keyhook_only();
void process_keyhook_commands();
#endif
