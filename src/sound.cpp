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

// Globals, currently NVGT does not support instanciating multiple miniaudio engines or contexts.
static ma_context g_sound_context;
static ma_engine g_sound_engine;
static bool g_soundsystem_initialized = false;
static ma_result g_soundsystem_last_error = MA_SUCCESS;

bool init_sound() {
	if (g_soundsystem_initialized) return true;
	if ((g_soundsystem_last_error = ma_context_init(nullptr, 0, nullptr, &g_sound_context)) != MA_SUCCESS) return false;
	if ((g_soundsystem_last_error = ma_engine_init(nullptr, &g_sound_engine)) != MA_SUCCESS) return false;
	return true;
}



class sound_impl : public sound {
	ma_sound snd;
}
