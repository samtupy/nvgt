/* tts.cpp - code for engine based text to speech system
 * On windows this is SAPI, on macOS it is NSSpeech/AVSpeechSynthesizer, on linux speech dispatcher etc.
 * If no OS based speech system can be found for a given platform, a derivative of RSynth that is built into NVGT will be used instead.
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

#include <limits>
#include <algorithm>
#include <unordered_map>
#include <thread>
#include <miniaudio.h>
#include <Poco/FileStream.h>
#include <Poco/Format.h>
#include <Poco/String.h>
#include <Poco/StringTokenizer.h>
#include <obfuscate.h>
#include "nvgt_angelscript.h"
#include "tts.h"
#include "misc_functions.h"
#include "UI.h"
#include "xplatform.h"
using namespace std;

// Trim prenormalized TTS based on minimum thresholds in dB. Size is in frames.
template <class t> static t *tts_trim_internal(t *data, unsigned int* size_in_frames, int channels, float begin_db, float end_db) {
	t min_begin_sample = ceil(ma_volume_db_to_linear(begin_db) * (double)numeric_limits<t>::max());
	t min_end_sample = ceil(ma_volume_db_to_linear(end_db) * (double)numeric_limits<t>::max());
	for (unsigned long i = 0; i < *size_in_frames; i++) {
		double mean = 0;
		for (int c = 0; c < channels; c++)
			mean += abs(data[(i * channels) + c]);
		mean /= channels;
		if (mean >= min_begin_sample) {
			*size_in_frames -= i;
			data += i * channels;
			break;
		}
	}
	for (int i = *size_in_frames -1; i >= 0; i--) {
		double mean = 0;
		for (int c = 0; c < channels; c++)
			mean += abs(data[(i * channels) + c]);
		mean /= channels;
		if (mean > min_end_sample) {
			if (i < *size_in_frames - 1) i++;
			*size_in_frames -= (*size_in_frames - i);
			break;
		}
	}
	return data;
}

static void* tts_trim(tts_audio_data* data, float begin_db = -60, float end_db = -60) {
	unsigned int size_in_frames;
	void* trimmed_data;
	switch (data->bitsize) {
		case 16:
			size_in_frames = data->size_in_bytes / 2 / data->channels;
			trimmed_data = tts_trim_internal<int16_t>((int16_t*)data->data, &size_in_frames, data->channels, begin_db, end_db);
			data->size_in_bytes = size_in_frames * 2 * data->channels;
			return trimmed_data;
		case 8:
			size_in_frames = data->size_in_bytes / data->channels;
			trimmed_data = tts_trim_internal<char>((char*)data->data, &size_in_frames, data->channels, begin_db, end_db);
			data->size_in_bytes = size_in_frames * data->channels;
			return trimmed_data;
		default:
			return data->data;
	}
}

tts_audio_data::tts_audio_data(tts_engine* eng, void* dat, unsigned int size, unsigned int rate, unsigned int chans, unsigned int bits, void* ctx) : engine(eng), data(dat), size_in_bytes(size), sample_rate(rate), channels(chans), bitsize(bits), context(ctx) {}
void tts_audio_data::free() { if (engine) engine->free_pcm(this); }

// Fallback voice engine using RSynth
class fallback_voice_engine : public tts_engine_impl {
	float rate, pitch, volume;
public:
	fallback_voice_engine() : tts_engine_impl("fallback"), rate(10), pitch(1330), volume(60) {}
	tts_pcm_generation_state get_pcm_generation_state() override { return PCM_PREFERRED; }
	tts_audio_data* speak_to_pcm(const string &text) override {
		if (text.empty()) return nullptr;
		int samples;
		char *data = (char *)speech_gen(&samples, text.c_str(), 20 - rate, pitch, volume, NULL); // smaller rate values mean faster so we must reverse the rate value here.
		if (!data) return nullptr;
		return new tts_audio_data(this, data, samples * 4, 44100, 2, 16);
	}
	void free_pcm(tts_audio_data* data) override {
		if (data && data->data) {
			speech_free((short *)data->data, NULL);
			data->data = nullptr;
		}
		tts_engine_impl::free_pcm(data);
	}
	float get_rate() override { return rate; }
	float get_pitch() override { return pitch; }
	float get_volume() override { return volume; }
	void set_rate(float rate) override { this->rate = rate; }
	void set_pitch(float pitch) override { this->pitch = pitch; }
	void set_volume(float volume) override { this->volume = volume; }
	bool get_rate_range(float& minimum, float& midpoint, float& maximum) override { minimum = 3; midpoint = 10; maximum = 17; return true; }
	bool get_pitch_range(float& minimum, float& midpoint, float& maximum) override { minimum = 400; midpoint = 1330; maximum = 4000; return true; }
	bool get_volume_range(float& minimum, float& midpoint, float& maximum) override { minimum = 0; midpoint = 30; maximum = 70; return true; }
	string get_voice_name(int index) override { return index == 0? "builtin fallback voice" : ""; }
};

// Engine factory registry
static vector<string> engine_names;
static unordered_map<string, tts_engine_factory> engine_registry;
bool tts_engine_register(const string &name, tts_engine_factory factory) {
	if (engine_registry.find(name) != engine_registry.end()) return false;
	engine_registry[name] = factory;
	engine_names.push_back(name);
	return true;
}

vector<string> tts_get_engine_names() { return engine_names; }

shared_ptr<tts_engine> tts_create_engine(const string &name) {
	auto it = engine_registry.find(name);
	if (it == engine_registry.end()) return nullptr;
	try { return it->second(); }
	catch (...) { return nullptr; }
}

static void register_builtin_engines() {
	tts_engine_register("fallback", []() -> shared_ptr<tts_engine> { return make_shared<fallback_voice_engine>(); });
	register_native_tts();
}

// tts_voice implementation
tts_voice::tts_voice(const string &engine_list) : RefCount(1), current_voice_index(-1) {
	if (engine_registry.empty()) register_builtin_engines();
	speaking.clear();
	vector<string> engine_names;
	if (engine_list.empty()) engine_names = tts_get_engine_names();
	else {
		Poco::StringTokenizer tokens(engine_list, ",");
		for (const string& e : tokens) engine_names.push_back(Poco::trim(e));
	}
	for (const string &name : engine_names) {
		shared_ptr<tts_engine> engine = tts_create_engine(name);
		if (engine) engines.push_back(engine);
	}
	refresh();
}
void tts_voice::AddRef() { asAtomicInc(RefCount); }
void tts_voice::Release() { if (asAtomicDec(RefCount) < 1) delete this; }
voice_info *tts_voice::get_voice_info(int voice_index) {
	if (voice_index < 0 || voice_index >= static_cast<int>(voices.size())) return nullptr;
	return &voices[voice_index];
}
void *tts_voice::speak_to_pcm(const string &text, tts_audio_data** datablock) {
	voice_info *voice = get_voice_info(current_voice_index);
	if (!datablock || !voice || voice->engine->get_pcm_generation_state() == PCM_UNSUPPORTED) return nullptr;
	*datablock = voice->engine->speak_to_pcm(text);
	if (!*datablock) return nullptr;
	return tts_trim(*datablock);
}
bool tts_voice::speak(const string &text, bool interrupt) {
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice) return false;
	if (voice->engine->get_pcm_generation_state() == PCM_PREFERRED) {
		tts_audio_data* datablock = nullptr;
		void *trimmed_data = speak_to_pcm(text, &datablock);
		if (!trimmed_data || !datablock) return false;
		soundptr s(new_global_sound());
		ma_format format = (datablock->bitsize == 16) ? ma_format_s16 : ma_format_u8;
		if (!s->load_pcm(trimmed_data, datablock->size_in_bytes, format, datablock->sample_rate, datablock->channels)) {
			datablock->free();
			return false;
		}
		datablock->free();
		return schedule(s, interrupt);
	} else return voice->engine->speak(text, interrupt, false);
}
bool tts_voice::speak_to_file(const string &filename, const string &text) {
	tts_audio_data* datablock;
	void *trimmed_data = speak_to_pcm(text, &datablock);
	if (!trimmed_data || !datablock) return false;
	try {
		string output;
		output.resize(datablock->size_in_bytes + 44);
		ma_format format = (datablock->bitsize == 16)? ma_format_s16 : ma_format_u8;
		if (!sound::pcm_to_wav(trimmed_data, datablock->size_in_bytes, format, datablock->sample_rate, datablock->channels, &output[0])) {
			datablock->free();
			return false;
		}
		Poco::FileOutputStream file(filename, ios::binary);
		file.write(output.data(), output.size());
		file.close();
		datablock->free();
		return true;
	} catch (...) {
		datablock->free();
		return false;
	}
}
string tts_voice::speak_to_memory(const string &text) {
	tts_audio_data* datablock;
	void *trimmed_data = speak_to_pcm(text, &datablock);
	if (!trimmed_data || !datablock) return "";
	string output;
	output.resize(datablock->size_in_bytes + 44);
	ma_format format = (datablock->bitsize == 16)? ma_format_s16 : ma_format_u8;
	if (!sound::pcm_to_wav(trimmed_data, datablock->size_in_bytes, format, datablock->sample_rate, datablock->channels, &output[0])) {
		datablock->free();
		return "";
	}
	datablock->free();
	return output;
}
bool tts_voice::speak_wait(const string &text, bool interrupt) {
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice) return false;
	if (voice->engine->get_pcm_generation_state() == PCM_PREFERRED) {
		if (!speak(text, interrupt)) return false;
		while (get_speaking()) wait(10);
		return true;
	} else return voice->engine->speak(text, interrupt, true);
}
sound *tts_voice::speak_to_sound(const string &text) {
	tts_audio_data* datablock;
	void *trimmed_data = speak_to_pcm(text, &datablock);
	if (!trimmed_data || !datablock) return nullptr;
	sound *s = new_global_sound();
	ma_format format = (datablock->bitsize == 16)? ma_format_s16 : ma_format_u8;
	if (!s->load_pcm(trimmed_data, datablock->size_in_bytes, format, datablock->sample_rate, datablock->channels)) {
		datablock->free();
		s->release();
		return nullptr;
	}
	datablock->free();
	return s;
}
float tts_voice::get_rate() {
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_rate_range(engine_min, engine_mid, engine_max)) return 0;
	return fRound(range_convert_midpoint(voice->engine->get_rate(), engine_min, engine_mid, engine_max, -10.0f, 0.0f, 10.0f), 3);
}
float tts_voice::get_pitch() {
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_pitch_range(engine_min, engine_mid, engine_max)) return 0;
	return fRound(range_convert_midpoint(voice->engine->get_pitch(), engine_min, engine_mid, engine_max, -10.0f, 0.0f, 10.0f), 3);
}
float tts_voice::get_volume() {
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_volume_range(engine_min, engine_mid, engine_max)) return 0;
	return fRound(range_convert_midpoint(voice->engine->get_volume(), engine_min, engine_mid, engine_max, -100.0f, -50.0f, 0.0f), 3);
}
int tts_voice::get_voice_count() { return voices.size(); }
string tts_voice::get_voice_name(int index) {
	voice_info *voice = get_voice_info(index);
	return voice? voice->name : "";
}
int tts_voice::get_current_voice() { return current_voice_index; }
void tts_voice::set_rate(float rate) {
	rate = clamp(rate, -10.0f, 10.0f);
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_rate_range(engine_min, engine_mid, engine_max)) return;
	voice->engine->set_rate(range_convert_midpoint(rate, -10.0f, 0.0f, 10.0f, engine_min, engine_mid, engine_max));
}
void tts_voice::set_pitch(float pitch) {
	pitch = clamp(pitch, -10.0f, 10.0f);
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_pitch_range(engine_min, engine_mid, engine_max)) return;
	voice->engine->set_pitch(range_convert_midpoint(pitch, -10.0f, 0.0f, 10.0f, engine_min, engine_mid, engine_max));
}
void tts_voice::set_volume(float volume) {
	volume = clamp(volume, -100.0f, 0.0f);
	float engine_min, engine_mid, engine_max;
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice || !voice->engine->get_volume_range(engine_min, engine_mid, engine_max)) return;
	voice->engine->set_volume(range_convert_midpoint(volume, -100.0f, -50.0f, 0.0f, engine_min, engine_mid, engine_max));
}
CScriptArray *tts_voice::list_voices() {
	asIScriptContext *ctx = asGetActiveContext();
	asIScriptEngine *engine = ctx->GetEngine();
	asITypeInfo *arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray *array = CScriptArray::Create(arrayType);
	array->Reserve(voices.size());
	for (const auto &voice : voices) {
		string voice_name = voice.name;
		array->InsertLast(&voice_name);
	}
	return array;
}
bool tts_voice::set_voice(int voice) {
	if (voice < 0 || voice >= voices.size()) return false;
	voice_info *old_voice = get_voice_info(current_voice_index);
	voice_info *new_voice = get_voice_info(voice);
	if (!new_voice) return false;
	int nvgt_rate = 0, nvgt_pitch = 0, nvgt_volume = 0;
	if (old_voice) {
		nvgt_rate = get_rate();
		nvgt_pitch = get_pitch();
		nvgt_volume = get_volume();
	}
	current_voice_index = voice;
	new_voice->engine->set_voice(new_voice->engine_voice_index);
	if (old_voice) {
		set_rate(nvgt_rate);
		set_pitch(nvgt_pitch);
		set_volume(nvgt_volume);
	}
	return true;
}
bool tts_voice::get_speaking() {
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice) return false;
	if (voice->engine->get_pcm_generation_state() == PCM_PREFERRED) return speaking.test();
	else return voice->engine->is_speaking();
}
bool tts_voice::refresh() {
	string old_voice_name;
	tts_engine* old_engine;
	bool had_voice = false;
	if (current_voice_index >= 0 && current_voice_index < voices.size()) {
		old_voice_name = voices[current_voice_index].name;
		old_engine = voices[current_voice_index].engine;
		had_voice = true;
	}
	voices.clear();
	for (auto &engine : engines) {
		if (!engine->is_available()) continue;
		int voice_count = engine->get_voice_count();
		for (int i = 0; i < voice_count; i++) {
			std::string lang = engine->get_voice_language(i);
			if (current_language.empty() || lang == current_language) voices.emplace_back(voice_info{engine.get(), i, engine->get_voice_name(i), lang});
		}
	}
	if (had_voice && !voices.empty()) {
		for (size_t i = 0; i < voices.size(); i++) {
			if (voices[i].engine != old_engine || voices[i].name != old_voice_name) continue;
			current_voice_index = i;
			return true;
		}
	} else if (!voices.empty()) {
		tts_engine* engine = engines.size() > 1 && engines[0]->get_engine_name() == "fallback"? &*engines[1] : &*engines[0]; // Avoid selecting the fallback engine at all costs, yet it's better than nothing.
		int engine_voice_index = engine->get_current_voice();
		for (current_voice_index = 0; engine_voice_index > -1 && current_voice_index < voices.size(); current_voice_index++) {
			if (voices[current_voice_index].engine == engine && voices[current_voice_index].engine_voice_index == engine_voice_index) break;
		}
	}
	return !voices.empty();
}
bool tts_voice::stop() {
	voice_info *voice = get_voice_info(current_voice_index);
	if (!voice) return false;
	if (voice->engine->get_pcm_generation_state() == PCM_PREFERRED) {
		unique_lock<mutex> lock(queue_mtx);
		clear();
		return true;
	} else return voice->engine->stop();
}
string tts_voice::get_engine_name() {
	voice_info *voice = get_voice_info(current_voice_index);
	return voice? voice->engine->get_engine_name() : "";
}
int tts_voice::get_engine_count() { return engines.size(); }
string tts_voice::get_engine_name(int index) {
	if (index < 0 || index >= engines.size()) return "";
	return engines[index]->get_engine_name();
}
string tts_voice::get_voice_language(int index) {
	if (index < 0 || index >= voices.size()) return "";
	return voices[index].language;
}
bool tts_voice::set_language(const string& language) {
	current_language = language;
	refresh();
	return !voices.empty();
}
string tts_voice::get_language() { return current_language; }

bool tts_voice::schedule(soundptr &s, bool interrupt) {
	try {
		cleanup_completed_fades();
		ma_sound_set_end_callback(s->get_ma_sound(), at_end, this);
		unique_lock<mutex> lock(queue_mtx);
		if (interrupt) clear();
		queue.push(s);
		speaking.test_and_set();
		if (queue.size() == 1) s->play();
		return true;
	} catch (exception &) { return false; }
}
void tts_voice::clear() {
	if (!queue.empty() && queue.front()->get_playing()) fade(queue.front());
	while (!queue.empty()) queue.pop();
	speaking.clear();
}
bool tts_voice::fade(soundptr &item) {
	ma_sound_set_fade_in_milliseconds(item->get_ma_sound(), -1, 0, 20);
	try {
		fade_queue.push(item);
		return true;
	} catch (const exception &) { return false; }
}
void tts_voice::cleanup_completed_fades() {
	if (fade_queue.empty()) return;
	if ((fade_queue.front()->get_playing() && fade_queue.front()->get_current_fade_volume() > 0)) return;
	while (!fade_queue.empty() && fade_queue.front()->is_load_completed()) fade_queue.pop();
}
void tts_voice::at_end(void *pUserData, ma_sound *pSound) {
	tts_voice *voice = static_cast<tts_voice *>(pUserData);
	ma_job job = ma_job_init(MA_JOB_TYPE_CUSTOM);
	job.data.custom.data0 = (ma_uintptr)voice;
	job.data.custom.data1 = (ma_uintptr)pSound;
	job.data.custom.proc = job_proc;
	ma_resource_manager_post_job(g_audio_engine->get_ma_engine()->pResourceManager, &job);
}
ma_result tts_voice::job_proc(ma_job *pJob) {
	tts_voice *voice = (tts_voice *)pJob->data.custom.data0;
	ma_sound *expected_front = (ma_sound *)pJob->data.custom.data1;
	unique_lock<mutex> lock(voice->queue_mtx);
	if (voice->queue.empty() || voice->queue.front()->get_ma_sound() != expected_front) return MA_CANCELLED;
	voice->queue.pop();
	if (voice->queue.size() == 0) {
		voice->speaking.clear();
		return MA_SUCCESS;
	}
	voice->queue.front()->play();
	return MA_SUCCESS;
}

CScriptArray *tts_get_engines() {
	asIScriptContext *ctx = asGetActiveContext();
	asIScriptEngine *engine = ctx->GetEngine();
	asITypeInfo *arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray *array = CScriptArray::Create(arrayType);
	array->Reserve(engine_names.size());
	for (const string &name : engine_names) array->InsertLast(&const_cast<string&>(name));
	return array;
}

tts_voice* new_tts_voice(const string& engines) { return new tts_voice(engines); }
void RegisterTTSVoice(asIScriptEngine *engine) {
	engine->RegisterObjectType("tts_voice", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_FACTORY, _O("tts_voice @t(const string&in engines = \"\")"), asFUNCTION(new_tts_voice), asCALL_CDECL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_ADDREF, "void f()", asMETHOD(tts_voice, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_RELEASE, "void f()", asMETHOD(tts_voice, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak(const string &in text, bool interrupt = false)", asMETHOD(tts_voice, speak), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt(const string &in text)", asMETHOD(tts_voice, speak_interrupt), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_to_file(const string& in filename, const string &in text)", asMETHOD(tts_voice, speak_to_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_wait(const string &in text, bool interrupt = false)", asMETHOD(tts_voice, speak_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string speak_to_memory(const string &in text)", asMETHOD(tts_voice, speak_to_memory), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", Poco::format("%s::sound@ speak_to_sound(const string &in text)", get_system_namespace("sound")).c_str(), asMETHOD(tts_voice, speak_to_sound), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt_wait(const string &in text)", asMETHOD(tts_voice, speak_interrupt_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool refresh()", asMETHOD(tts_voice, refresh), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool stop()", asMETHOD(tts_voice, stop), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "array<string>@ list_voices() const", asMETHOD(tts_voice, list_voices), asCALL_THISCALL);
	// Alias the above as get_voice_names() for legacy BGT code.
	engine->RegisterObjectMethod("tts_voice", "array<string>@ get_voice_names() const", asMETHOD(tts_voice, list_voices), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool set_voice(int index)", asMETHOD(tts_voice, set_voice), asCALL_THISCALL);
	// Alias the above as set_current_voice() for legacy BGT code.
	engine->RegisterObjectMethod("tts_voice", "bool set_current_voice(int index)", asMETHOD(tts_voice, set_voice), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "float get_rate() const property", asMETHOD(tts_voice, get_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_rate(float rate) property", asMETHOD(tts_voice, set_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "float get_pitch() const property", asMETHOD(tts_voice, get_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_pitch(float pitch) property", asMETHOD(tts_voice, set_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "float get_volume() const property", asMETHOD(tts_voice, get_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_volume(float volume) property", asMETHOD(tts_voice, set_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_voice_count() const property", asMETHOD(tts_voice, get_voice_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string get_voice_name(int index) const", asMETHOD(tts_voice, get_voice_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string get_voice_language(int index) const", asMETHOD(tts_voice, get_voice_language), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool set_language(const string& in language)", asMETHOD(tts_voice, set_language), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string get_language() const property", asMETHOD(tts_voice, get_language), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool get_speaking() const property", asMETHOD(tts_voice, get_speaking), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_voice() const property", asMETHOD(tts_voice, get_current_voice), asCALL_THISCALL);
	engine->RegisterGlobalFunction("bool get_SCREEN_READER_AVAILABLE() property", asFUNCTION(screen_reader_load), asCALL_CDECL);
	engine->RegisterGlobalFunction("string screen_reader_detect()", asFUNCTION(screen_reader_detect), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_has_speech()", asFUNCTION(screen_reader_has_speech), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_has_braille()", asFUNCTION(screen_reader_has_braille), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_is_speaking()", asFUNCTION(screen_reader_is_speaking), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_output(const string &in text, bool interrupt = true)", asFUNCTION(screen_reader_output), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_speak(const string &in text, bool interrupt = true)", asFUNCTION(screen_reader_speak), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_braille(const string &in text)", asFUNCTION(screen_reader_braille), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_silence()", asFUNCTION(screen_reader_silence), asCALL_CDECL);
}
