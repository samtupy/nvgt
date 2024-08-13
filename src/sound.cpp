/* sound.cpp - sound system implementation code
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

#include <string>
#include <vector>
#include <angelscript.h>
#include <scriptarray.h>
#include "sound.h"

using namespace std;

// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
static audio_engine* g_audio_engine = nullptr;
static bool g_soundsystem_initialized = false;
static ma_result g_soundsystem_last_error = MA_SUCCESS;

bool init_sound() {
	if (g_soundsystem_initialized) return true;
	if ((g_soundsystem_last_error = ma_context_init(nullptr, 0, nullptr, &g_sound_context)) != MA_SUCCESS) return false;
	return true;
}

// audio device enumeration, we'll just maintain a global list of available devices, vectors of ma_device_info structures for the c++ side and CScriptArrays of device names on the Angelscript side. It is important that the data in these arrays is index aligned.
vector<ma_device_info> g_sound_input_devices, g_sound_output_devices;
static CScriptArray* g_sound_script_input_devices = nullptr, * g_sound_script_output_devices = nullptr;
ma_bool32 ma_device_enum_callback(ma_context* ctx, ma_device_type type, const ma_device_info* info, void* /*user*/) {
	string devname;
	if (deviceType == ma_device_type_playback) {
		g_sound_playback_devices.push_back(*info);
		g_sound_script_playback_devices->InsertLast(&(devname = &info->name));
	} else if (deviceType == ma_device_type_capture) {
		g_sound_input_devices.push_back(*info);
		g_sound_script_input_devices->InsertLast(&(devname = &info->name));
	}
}
bool refresh_audio_devices() {
	if (!init_sound()) return false;
	g_sound_output_devices.clear();
	g_sound_input_devices.clear();
	g_sound_script_playback_devices->Resize(0);
	g_sound_script_input_devices->Resize(0);
	return (g_soundsystem_last_error = ma_context_enumerate_devices(&g_sound_context, ma_device_enum_callback, nullptr)) == MA_SUCCESS;
}

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_engine_impl : public audio_engine {
		ma_engine* engine;
		audio_node* engine_endpoint; // Upon engine creation we'll call ma_engine_get_endpoint once so as to avoid creating more than one of our wrapper objects when our engine->get_endpoint() function is called.
	public:
		audio_engine_impl() {
			// default constructor initializes a miniaudio engine ourselves.
			ma_engine_config cfg = ma_engine_config_init();
		}
};
class sound_impl : public sound {
	ma_sound* snd;
}
