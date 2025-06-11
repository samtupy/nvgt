/* tonesynth.cpp - code for the tone_synth object
 * Written by Day Garwood, 30th May 2025
 * This wraps a C implementation I made during September 2024.
 * It's my first dive into low level synthesis and processing (yes, with the help of AI) so it's probably not ideal.
 * It's certainly slower than I'd like, but it gets the feature started and working until a better implementation can be found.
 * Todo: Since we're already using MiniAudio, discover how we might use ma_waveform for this, though not sure how much anti-aliasing it has.
 * Todo: Musical concepts (notes, tempo, transposition etc), bends, and reverb still to be implemented.
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

#include "tonesynth.h"
#include "sound.h"

tone_synth::tone_synth() {
	gen = new elz_tonar{};
	el_tonar_reset(gen);
}
tone_synth::~tone_synth() {
	if (!gen) return;
	elz_tonar_cleanup(gen);
	delete gen;
}
void tone_synth::AddRef() {
	asAtomicInc(refCount);
}
void tone_synth::Release() {
	if (asAtomicDec(refCount) < 1) {
		delete this;
	}
}
void tone_synth::set_waveform(int type) {
	el_tonar_set_waveform(gen, type);
}
int tone_synth::get_waveform() {
	return gen->waveform;
}
void tone_synth::set_volume(double db) {
	el_tonar_set_volume(gen, db);
}
double tone_synth::get_volume() {
	return gen->volume;
}
void tone_synth::set_pan(double pan) {
	el_tonar_set_pan(gen, pan);
}
double tone_synth::get_pan() {
	return gen->pan;
}
bool tone_synth::set_edge_fades(int start, int end) {
	return el_tonar_set_edge_fades(gen, start, end)? true: false;
}
bool tone_synth::freq(double freq, int ms) {
	return el_tonar_freq(gen, freq, ms)? true: false;
}
bool tone_synth::rest(int ms) {
	return el_tonar_rest(gen, ms)? true: false;
}
sound* tone_synth::generate_sound() {
	int size = el_tonar_output_buffer_size(gen);
	if (size <= 0) return nullptr;
	char* buffer = new char[size];
	if (!buffer) return nullptr;
	if (!el_tonar_output_buffer(gen, buffer, size)) {
		delete[] buffer;
		return nullptr;
	}
	sound *s = new_global_sound();
	if (!s) {
		delete[] buffer;
		return nullptr;
	}
	bool loaded = s->load_pcm(buffer, static_cast<unsigned int>(size), ma_format_s16, gen->sample_rate, gen->channels);
	delete[] buffer;
	if (!loaded) {
		s->release();
		return nullptr;
	}
	return s;
}
bool tone_synth::generate_file(const std::string& filename) {
	return el_tonar_output_file(gen, const_cast<char*> (filename.c_str()))? true: false;
}
tone_synth *script_tone_synth_factory() {
	return new tone_synth();
}
void RegisterScriptTonesynth(asIScriptEngine* engine) {
	engine->RegisterObjectType("tone_synth", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_FACTORY, "tone_synth@ f()", asFUNCTION(script_tone_synth_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_ADDREF, "void f()", asMETHOD(tone_synth, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_RELEASE, "void f()", asMETHOD(tone_synth, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_waveform_type(int type) property", asMETHOD(tone_synth, set_waveform), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "int get_waveform_type() const property", asMETHOD(tone_synth, get_waveform), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_volume(double value) property", asMETHOD(tone_synth, set_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_volume() const property", asMETHOD(tone_synth, get_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_pan(double value) property", asMETHOD(tone_synth, set_pan), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_pan() const property", asMETHOD(tone_synth, get_pan), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool set_edge_fades(int start, int end)", asMETHOD(tone_synth, set_edge_fades), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool freq(double freq, int ms)", asMETHOD(tone_synth, freq), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool rest(int ms)", asMETHOD(tone_synth, rest), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "sound@ write_wave_sound()", asMETHOD(tone_synth, generate_sound), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool write_wave_file(const string &in filename)", asMETHOD(tone_synth, generate_file), asCALL_THISCALL);
}
