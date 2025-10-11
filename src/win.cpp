/* win.cpp - code that only gets built when compiling for windows, things like SAPI, keyhooks etc
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#ifdef _WIN32 // Never include win.h outside of windows builds and this file can be lazy wildcarded into builds.

#include <stdexcept>
#include <Poco/AtomicFlag.h>
#include <Poco/UnicodeConverter.h>
#include <UniversalSpeech.h>
#include "win.h"
using namespace std;

void register_native_tts() { tts_engine_register("sapi5", []() -> shared_ptr<tts_engine> { return make_shared<sapi5_engine>(); }); }

sapi5_engine::sapi5_engine() : tts_engine_impl("SAPI5") {
	inst = (sb_sapi *)malloc(sizeof(sb_sapi));
	if (!inst) throw runtime_error("Failed to allocate SAPI5 instance");
	memset(inst, 0, sizeof(sb_sapi));
	if (!sb_sapi_initialise(inst)) {
		free(inst);
		throw runtime_error("Failed to initialize SAPI5 engine");
	}
}
sapi5_engine::~sapi5_engine() {
	if (inst) {
		sb_sapi_cleanup(inst);
		free(inst);
	}
}
bool sapi5_engine::is_available() { return true; }
tts_pcm_generation_state sapi5_engine::get_pcm_generation_state() { return PCM_PREFERRED; }
tts_audio_data* sapi5_engine::speak_to_pcm(const string &text) {
	if (text.empty()) return nullptr;
	void *temp = nullptr;
	int bufsize = 0;
	if (!sb_sapi_speak_to_memory(inst, const_cast<char*>(text.c_str()), &temp, &bufsize)) return nullptr;
	if (!temp || bufsize <= 0) return nullptr;
	return new tts_audio_data(this, temp, bufsize, sb_sapi_get_sample_rate(inst), sb_sapi_get_channels(inst), sb_sapi_get_bit_depth(inst));
}
float sapi5_engine::get_rate() { return sb_sapi_get_rate(inst); }
float sapi5_engine::get_pitch() { return sb_sapi_get_pitch(inst); }
float sapi5_engine::get_volume() { return sb_sapi_get_volume(inst); }
void sapi5_engine::set_rate(float rate) { sb_sapi_set_rate(inst, rate); }
void sapi5_engine::set_pitch(float pitch) { sb_sapi_set_pitch(inst, pitch); }
void sapi5_engine::set_volume(float volume) { sb_sapi_set_volume(inst, volume); }
bool sapi5_engine::get_rate_range(float& minimum, float& midpoint, float& maximum) { minimum = -10; midpoint = 0; maximum = 10; return true; }
bool sapi5_engine::get_pitch_range(float& minimum, float& midpoint, float& maximum) { minimum = -10; midpoint = 0; maximum = 10; return true; }
bool sapi5_engine::get_volume_range(float& minimum, float& midpoint, float& maximum) { minimum = 0; midpoint = 50; maximum = 100; return true; }
int sapi5_engine::get_voice_count() { return inst->voice_count; }
string sapi5_engine::get_voice_name(int index) {
	if (index < 0 || index >= inst->voice_count) return "";
	char *result = sb_sapi_get_voice_name(inst, index);
	return result? string(result) : "";
}
string sapi5_engine::get_voice_language(int index) {
	if (!inst || index < 0 || index >= get_voice_count()) return "";
	char *lang = sb_sapi_get_voice_language(inst, index);
	if (!lang) return "";
	string result(lang);
	free(lang);
	return result;
}
bool sapi5_engine::set_voice(int voice) {
	if (voice < 0 || voice >= inst->voice_count) return false;
	if (!sb_sapi_set_voice(inst, voice)) return false;
	return true;
}
int sapi5_engine::get_current_voice() { return sb_sapi_get_voice(inst); }

static Poco::AtomicFlag g_sr_loaded;
static Poco::AtomicFlag g_sr_available;
bool screen_reader_load() {
	if (g_sr_loaded) return true;
	speechSetValue(SP_ENABLE_NATIVE_SPEECH, 0);
	g_sr_available.set();
	g_sr_loaded.set();
	return true;
}
void screen_reader_unload() {
	if (g_sr_loaded) g_sr_loaded.reset();
}
std::string screen_reader_detect() {
	if (!screen_reader_load()) return "";
	int engine = speechGetValue(SP_ENGINE);
	if (engine < 0) return "";
	const std::wstring srname = speechGetString(SP_ENGINE + engine);
	std::string result;
	Poco::UnicodeConverter::convert(srname, result);
	return result;
}
bool screen_reader_has_speech() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_ENGINE) > -1;
}
bool screen_reader_has_braille() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_ENGINE) > -1;
}
bool screen_reader_is_speaking() {
	if (!screen_reader_load()) return false;
	return speechGetValue(SP_BUSY) != 0;
}
bool screen_reader_output(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0 && brailleDisplay(textW.c_str()) != 0;
}
bool screen_reader_speak(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0;
}
bool screen_reader_braille(const std::string& text) {
	if (!screen_reader_load()) return false;
	std::wstring textW(text.begin(), text.end());
	return brailleDisplay(textW.c_str()) != 0;
}
bool screen_reader_silence() {
	if (!screen_reader_load()) return false;
	return speechStop();
}

#endif
