/* tonesynth.h - header for the tone_synth object
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

extern "C" {
	#include <tonar.h>
}

#include <string>

#include <angelscript.h>

// Forward declare a few things so they'll work.
class sound;
sound* new_global_sound();

class tone_synth {
public:
	tone_synth();
	~tone_synth();

	void AddRef();
	void Release();

	void set_waveform(int type);
	int get_waveform();
	void set_volume(double db);
	double get_volume();
	void set_pan(double pan);
	double get_pan();
	bool set_edge_fades(int start, int end);
	bool freq(double freq, int ms);
	bool rest(int ms);
	sound* generate_sound();
	bool generate_file(const std::string& filename);

private:
	int refCount = 1;
	el_tonar* gen = nullptr;
};

tone_synth *script_tone_synth_factory();
void RegisterScriptTonesynth(asIScriptEngine* engine);
