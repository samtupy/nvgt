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

class tone_synth {
public:
	tone_synth();
	~tone_synth();

	void AddRef();
	void Release();

	void reset();
	void set_waveform(int type);
	int get_waveform();
	void set_volume(double db);
	double get_volume();
	void set_pan(double pan);
	double get_pan();
	bool set_edge_fades(int start, int end);
	void set_tempo(double tempo);
	double get_tempo();
	void set_note_transpose(double note_transpose);
	double get_note_transpose();
	void set_freq_transpose(double freq_transpose);
	double get_freq_transpose();
	bool note(std::string note, double length);
	bool note_ms(std::string note, int ms);
	bool note_bend(std::string note, int bend_amount, double length, double bend_start, double bend_length);
	bool note_bend_ms(std::string note, int bend_amount, int length, int bend_start, int bend_length);
	bool freq(double freq, double length);
	bool freq_ms(double freq, int ms);
	bool freq_bend(double freq, int bend_amount, double length, double bend_start, double bend_length);
	bool freq_bend_ms(double freq, int bend_amount, int length, int bend_start, int bend_length);
	bool rest(double length);
	bool rest_ms(int ms);
	double get_length();
	int get_length_ms();
	double get_position();
	int get_position_ms();
	bool seek(double position);
	bool seek_ms(int position);
	bool rewind(double amount);
	bool rewind_ms(int amount);

	sound* generate_sound();
	bool generate_file(const std::string& filename);

private:
	int bgt_to_tonar_waveform(int type);

	int refCount = 1;
	el_tonar* gen = nullptr;
};

tone_synth *script_tone_synth_factory();
void RegisterScriptTonesynth(asIScriptEngine* engine);
