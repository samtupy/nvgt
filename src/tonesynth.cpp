/* tonesynth.cpp - code for the tone_synth object
 * Written by Day Garwood, 30th May 2025
 * This wraps a C implementation I made during September 2024.
 * It's my first dive into low level synthesis and processing (yes, with the help of AI) so it's probably not ideal.
 * It's certainly slower than I'd like, but it gets the feature started and working until a better implementation can be found.
 * Todo: Since we're already using MiniAudio, discover how we might use ma_waveform for this, though not sure how much anti-aliasing it has.
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
void tone_synth::reset() {
	el_tonar_reset(gen);
	el_tonar_set_waveform(gen, 3);
	el_tonar_set_allow_silence(gen, 1);
}
void tone_synth::set_waveform(int type) {
	int real_type = bgt_to_tonar_waveform(type);
	if (real_type < 0) return;
	el_tonar_set_waveform(gen, real_type);
}
int tone_synth::get_waveform() {
	return bgt_to_tonar_waveform(el_tonar_get_waveform(gen));
}
void tone_synth::set_volume(double db) {
	el_tonar_set_volume(gen, db);
}
double tone_synth::get_volume() {
	return el_tonar_get_volume(gen);
}
void tone_synth::set_pan(double pan) {
	el_tonar_set_pan(gen, pan);
}
double tone_synth::get_pan() {
	return el_tonar_get_pan(gen);
}
void tone_synth::set_allow_silence(bool silence) {
	el_tonar_set_allow_silence(gen, (silence? 1: 0));
}
bool tone_synth::get_allow_silence() {
	return (el_tonar_get_allow_silence(gen)? true: false);
}
bool tone_synth::set_edge_fades(int start, int end) {
	return el_tonar_set_edge_fades(gen, start, end)? true: false;
}
void tone_synth::set_tempo(double tempo) {
	el_tonar_set_tempo(gen, tempo);
}
double tone_synth::get_tempo() {
	return el_tonar_get_tempo(gen);
}
void tone_synth::set_note_transpose(double note_transpose) {
	el_tonar_set_note_transpose(gen, note_transpose);
}
double tone_synth::get_note_transpose() {
	return el_tonar_get_note_transpose(gen);
}
void tone_synth::set_freq_transpose(double freq_transpose) {
	el_tonar_set_freq_transpose(gen, freq_transpose);
}
double tone_synth::get_freq_transpose() {
	return el_tonar_get_freq_transpose(gen);
}
bool tone_synth::note(std::string note, double length) {
	return el_tonar_note(gen, const_cast<char*> (note.c_str()), length)? true: false;
}
bool tone_synth::note_ms(std::string note, int ms) {
	return el_tonar_note_ms(gen, const_cast<char*> (note.c_str()), ms)? true: false;
}
bool tone_synth::note_bend(std::string note, int bend_amount, double length, double bend_start, double bend_length) {
	return el_tonar_note_bend(gen, const_cast<char*> (note.c_str()), bend_amount, length, bend_start, bend_length)? true: false;
}
bool tone_synth::note_bend_ms(std::string note, int bend_amount, int length, int bend_start, int bend_length) {
	return el_tonar_note_bend_ms(gen, const_cast<char*> (note.c_str()), bend_amount, length, bend_start, bend_length)? true: false;
}
bool tone_synth::freq(double freq, double length) {
	return el_tonar_freq(gen, freq, length)? true: false;
}
bool tone_synth::freq_ms(double freq, int ms) {
	return el_tonar_freq_ms(gen, freq, ms)? true: false;
}
bool tone_synth::freq_bend(double freq, int bend_amount, double length, double bend_start, double bend_length) {
	return el_tonar_freq_bend(gen, freq, bend_amount, length, bend_start, bend_length)? true: false;
}
bool tone_synth::freq_bend_ms(double freq, int bend_amount, int length, int bend_start, int bend_length) {
	return el_tonar_freq_bend_ms(gen, freq, bend_amount, length, bend_start, bend_length)? true: false;
}
bool tone_synth::rest(double length) {
	return el_tonar_rest(gen, length)? true: false;
}
bool tone_synth::rest_ms(int ms) {
	return el_tonar_rest_ms(gen, ms)? true: false;
}
double tone_synth::get_length() {
	return el_tonar_get_length(gen);
}
int tone_synth::get_length_ms() {
	return el_tonar_get_length_ms(gen);
}
double tone_synth::get_position() {
	return el_tonar_get_position(gen);
}
int tone_synth::get_position_ms() {
	return el_tonar_get_position_ms(gen);
}
bool tone_synth::seek(double position) {
	return el_tonar_seek(gen, position)? true: false;
}
bool tone_synth::seek_ms(int position) {
	return el_tonar_seek_ms(gen, position)? true: false;
}
bool tone_synth::rewind(double amount) {
	return el_tonar_rewind(gen, amount)? true: false;
}
bool tone_synth::rewind_ms(int amount) {
	return el_tonar_rewind_ms(gen, amount)? true: false;
}
sound* tone_synth::generate_sound() {
init_sound();
	int size = el_tonar_output_buffer_size(gen);
	if (size <= 0) return nullptr;
	char* buffer = new char[size];
	if (!buffer) return nullptr;
	if (!el_tonar_output_buffer(gen, buffer, size)) {
		delete[] buffer;
		return nullptr;
	}
	sound *s = g_audio_engine->new_sound();
	if (!s) {
		delete[] buffer;
		return nullptr;
	}
	bool loaded = s->load_pcm(buffer, static_cast<unsigned int>(size), ma_format_s16, gen->sample_rate, gen->channels);
	delete[] buffer;
	if (!loaded) {
		s->release(); // Sound object is not passed to the script if load fails, delete it.
		return nullptr;
	}
	return s;
}
bool tone_synth::generate_file(const std::string& filename) {
	return el_tonar_output_file(gen, const_cast<char*> (filename.c_str()))? true: false;
}
int tone_synth::bgt_to_tonar_waveform(int type) {
	if (type == 1) return 3;
	if (type == 2) return 2;
	if (type == 3) return 0;
	if (type == 4) return 1;
	return -1;
}
tone_synth *script_tone_synth_factory() {
	return new tone_synth();
}
void RegisterScriptTonesynth(asIScriptEngine* engine) {
	engine->RegisterObjectType("tone_synth", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_FACTORY, "tone_synth@ f()", asFUNCTION(script_tone_synth_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_ADDREF, "void f()", asMETHOD(tone_synth, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("tone_synth", asBEHAVE_RELEASE, "void f()", asMETHOD(tone_synth, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void reset()", asMETHOD(tone_synth, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_waveform_type(int type) property", asMETHOD(tone_synth, set_waveform), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "int get_waveform_type() const property", asMETHOD(tone_synth, get_waveform), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_allow_silent_output(bool silence) property", asMETHOD(tone_synth, set_allow_silence), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool get_allow_silent_output() const property", asMETHOD(tone_synth, get_allow_silence), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_volume(double value) property", asMETHOD(tone_synth, set_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_volume() const property", asMETHOD(tone_synth, get_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_pan(double value) property", asMETHOD(tone_synth, set_pan), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_pan() const property", asMETHOD(tone_synth, get_pan), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_tempo(double value) property", asMETHOD(tone_synth, set_tempo), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_tempo() const property", asMETHOD(tone_synth, get_tempo), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_note_transpose(double value) property", asMETHOD(tone_synth, set_note_transpose), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_note_transpose() const property", asMETHOD(tone_synth, get_note_transpose), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "void set_freq_transpose(double value) property", asMETHOD(tone_synth, set_freq_transpose), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_freq_transpose() const property", asMETHOD(tone_synth, get_freq_transpose), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_position() const property", asMETHOD(tone_synth, get_position), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "int get_position_ms() const property", asMETHOD(tone_synth, get_position_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "double get_length() const property", asMETHOD(tone_synth, get_length), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "int get_length_ms() const property", asMETHOD(tone_synth, get_length_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool seek(double position)", asMETHOD(tone_synth, seek), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool seek_ms(int position)", asMETHOD(tone_synth, seek_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool rewind(double amount)", asMETHOD(tone_synth, rewind), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool rewind_ms(int amount)", asMETHOD(tone_synth, rewind_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool set_edge_fades(int start, int end)", asMETHOD(tone_synth, set_edge_fades), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool note(string note, double length)", asMETHOD(tone_synth, note), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool note_ms(string note, int ms)", asMETHOD(tone_synth, note_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool note_bend(string note, int bend_amount, double length, double bend_start, double bend_length)", asMETHOD(tone_synth, note_bend), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool note_bend_ms(string note, int bend_amount, int length, int bend_start, int bend_length)", asMETHOD(tone_synth, note_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool freq(double freq, double length)", asMETHOD(tone_synth, freq), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool freq_ms(double freq, int ms)", asMETHOD(tone_synth, freq_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool freq_bend(double freq, int bend_amount, double length, double bend_start, double bend_length)", asMETHOD(tone_synth, freq_bend), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool freq_bend_ms(double freq, int bend_amount, int length, int bend_start, int bend_length)", asMETHOD(tone_synth, freq_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool rest(double length)", asMETHOD(tone_synth, rest), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool rest_ms(int ms)", asMETHOD(tone_synth, rest_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "sound@ write_wave_sound()", asMETHOD(tone_synth, generate_sound), asCALL_THISCALL);
	engine->RegisterObjectMethod("tone_synth", "bool write_wave_file(const string &in filename)", asMETHOD(tone_synth, generate_file), asCALL_THISCALL);
}
